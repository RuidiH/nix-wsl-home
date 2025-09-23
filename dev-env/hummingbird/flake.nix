
{
  description = "Minimal dev environment for Innovation Sandbox on AWS deployment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        lsEndpoint = "http://localhost:4566";

        # real 'terraform' binary that delegates to tofu (works in scripts/Makefiles)
        terraformShim = pkgs.writeShellScriptBin "terraform" ''
          exec ${pkgs.opentofu}/bin/tofu "$@"
        '';

        # awslocal = thin wrapper around aws with LocalStack endpoint
        awslocal = pkgs.writeShellScriptBin "awslocal" ''
          exec ${pkgs.awscli2}/bin/aws --endpoint-url="''${AWS_ENDPOINT_URL:-http://localhost:4566}" "$@"
        '';

        # tflocal: Comprehensive LocalStack wrapper for OpenTofu/Terraform
        # This wrapper automatically generates provider and backend override files
        # to ensure all AWS service calls are routed to LocalStack instead of real AWS
        tflocal = pkgs.writeShellScriptBin "tflocal" ''
          #!/usr/bin/env bash
          set -euo pipefail
          
          # ============================================================================
          # ENVIRONMENT CONFIGURATION
          # These variables configure the LocalStack connection and credentials
          # ============================================================================
          ENDPOINT="''${AWS_ENDPOINT_URL:-http://localhost:4566}"
          REGION="''${AWS_REGION:-us-west-2}"
          AWS_ACCESS_KEY="''${AWS_ACCESS_KEY_ID:-test}"
          AWS_SECRET_KEY="''${AWS_SECRET_ACCESS_KEY:-test}"
          
          # ============================================================================
          # AWS SERVICES LIST
          # Comprehensive list of all AWS services that need endpoint configuration
          # Without this, Terraform would try to connect to real AWS for each service
          # ============================================================================
          # VALID AWS TERRAFORM PROVIDER ENDPOINTS ONLY
          # This list contains only endpoints recognized by AWS provider v5.x
          # Invalid endpoints have been removed to prevent "Unsupported argument" errors
          AWS_SERVICES=(
            # Core Services
            "acm" "acmpca" "amplify" "apigateway" "apigatewayv2" "appautoscaling"
            "appconfig" "appflow" "appsync" "athena" "autoscaling" "backup" "batch"
            
            # Analytics & Cost Management
            "budgets" "ce" "cloudcontrol" "cloudformation" "cloudfront" "cloudtrail"
            "cloudwatch" "cloudwatchevents" "cloudwatchlogs" "codecommit" "cognitoidentity"
            "cognitoidp" "comprehend" "config" "connect" "datasync"
            
            # Database Services
            "dax" "devicefarm" "directconnect" "dlm" "dms" "docdb" "ds" "dynamodb"
            "ec2" "ecr" "ecrpublic" "ecs" "efs" "eks" "elasticache" "elasticbeanstalk"
            "elasticsearch" "elastictranscoder" "elasticloadbalancing" "elasticloadbalancingv2"
            
            # Big Data & Analytics
            "emr" "emrcontainers" "emrserverless" "es" "eventbridge" "events"
            "evidently" "finspace" "firehose" "fis" "fms" "fsx" "gamelift"
            
            # Storage & Content
            "glacier" "globalaccelerator" "glue" "grafana" "greengrass" "groundstation"
            "guardduty" "healthlake" "iam" "identitystore" "imagebuilder" "inspector"
            "inspector2" "internetmonitor" "iot" "iotanalytics" "iotevents" "ivs" "ivschat"
            
            # Streaming & Messaging
            "kafka" "kafkaconnect" "kendra" "keyspaces" "kinesis" "kinesisanalytics"
            "kinesisanalyticsv2" "kinesisvideo" "kms" "lakeformation" "lambda"
            "lexmodels" "lexmodelsv2" "licensemanager" "lightsail" "location" "logs"
            
            # AI/ML & Analytics
            "lookoutmetrics" "macie2" "mediaconnect" "mediaconvert" "medialive"
            "mediapackage" "mediastore" "memorydb" "mq" "mwaa" "neptune"
            
            # Networking & Security
            "networkfirewall" "networkmanager" "oam" "opensearch" "opensearchserverless"
            "opensearchservice" "opsworks" "organizations" "outposts" "pinpoint" 
            "pipes" "polly" "pricing" "prometheus" "prometheusservice"
            
            # Database & Querying
            "qldb" "quicksight" "ram" "rbin" "rds" "redshift" "redshiftdata"
            "redshiftserverless" "rekognition" "resiliencehub" "resourceexplorer2"
            "resourcegroups" "resourcegroupstagging" "rolesanywhere" "route53"
            
            # DNS & Domains
            "route53domains" "route53recoverycontrolconfig" "route53recoveryreadiness"
            "route53resolver" "rum" "s3" "s3control" "s3outposts" "sagemaker"
            "scheduler" "schemas" "secretsmanager" "securityhub" "securitylake"
            
            # Application Services
            "serverlessrepo" "servicecatalog" "servicediscovery" "servicequotas"
            "ses" "sesv2" "sfn" "shield" "signer" "sns" "sqs" "ssm" "ssmcontacts"
            "ssmincidents" "ssmsap" "sso" "ssoadmin" "stepfunctions" "storagegateway"
            
            # Additional Services
            "sts" "swf" "synthetics" "timestreamquery" "timestreamwrite" 
            "transcribe" "transfer" "vpclattice" "waf" "wafregional" "wafv2" 
            "wellarchitected" "workspaces" "workspacesweb" "xray"
          )
          
          # ============================================================================
          # PROVIDER OVERRIDE GENERATION
          # Creates a Terraform provider configuration that routes all AWS API calls
          # to LocalStack instead of real AWS endpoints
          # ============================================================================
          generate_provider_override() {
            local override_file="''${1:-localstack_providers_override.tf}"
            
            {
              echo '# Auto-generated LocalStack provider configuration'
              echo '# This file ensures all AWS API calls go to LocalStack'
              echo 'provider "aws" {'
              echo "  access_key = \"$AWS_ACCESS_KEY\""
              echo "  secret_key = \"$AWS_SECRET_KEY\""
              echo "  region     = \"$REGION\""
              echo ""
              echo "  # Skip AWS account validation (LocalStack doesn't need real credentials)"
              echo "  skip_credentials_validation = true"
              echo "  skip_metadata_api_check     = true"
              echo "  skip_requesting_account_id   = true"
              echo ""
              echo "  # CRITICAL: Force S3 to use path-style URLs instead of virtual-hosted-style"
              echo "  # Without this, S3 bucket operations fail with subdomain routing issues"
              echo "  s3_use_path_style            = true"
              echo ""
              echo "  # Configure endpoints for all AWS services to point to LocalStack"
              echo "  endpoints {"
              
              # Generate endpoint configuration for each AWS service
              for service in "''${AWS_SERVICES[@]}"; do
                echo "    $service = \"$ENDPOINT\""
              done
              
              echo "  }"
              echo "}"
            } > "$override_file"
            
            echo "Generated LocalStack provider override: $override_file" >&2
          }
          
          # ============================================================================
          # BACKEND OVERRIDE GENERATION
          # Special configuration for S3 backend (used for remote Terraform state)
          # Only generated when Terraform is configured to use S3 for state storage
          # ============================================================================
          generate_backend_override() {
            local override_file="''${1:-backend_override.tf}"
            
            # Only generate if main.tf contains S3 backend configuration
            if [[ -f "main.tf" ]] && grep -q 'backend\s*"s3"' main.tf 2>/dev/null; then
              {
                echo '# Auto-generated LocalStack backend configuration'
                echo '# This ensures Terraform state is stored in LocalStack S3, not real AWS'
                echo 'terraform {'
                echo '  backend "s3" {'
                echo "    endpoint                    = \"$ENDPOINT\""
                echo "    sts_endpoint                = \"$ENDPOINT\""
                echo "    iam_endpoint                = \"$ENDPOINT\""
                echo "    dynamodb_endpoint           = \"$ENDPOINT\""
                echo ""
                echo "    # Force path-style S3 URLs for state bucket access"
                echo "    force_path_style           = true"
                echo ""
                echo "    # Skip AWS validation for LocalStack"
                echo "    skip_credentials_validation = true"
                echo "    skip_metadata_api_check    = true"
                echo "    skip_requesting_account_id = true"
                echo "  }"
                echo "}"
              } > "$override_file"
              
              echo "Generated LocalStack backend override: $override_file" >&2
            fi
          }
          
          # ============================================================================
          # CLEANUP FUNCTION
          # Removes generated override files after Terraform execution
          # This prevents accidental commits of LocalStack-specific configuration
          # Set TFLOCAL_KEEP_OVERRIDES=true to preserve files for debugging
          # ============================================================================
          cleanup() {
            local exit_code=$?
            
            if [[ "''${TFLOCAL_KEEP_OVERRIDES:-}" != "true" ]]; then
              echo "Cleaning up LocalStack override files..." >&2
              rm -f localstack_providers_override.tf backend_override.tf
            else
              echo "Keeping override files (TFLOCAL_KEEP_OVERRIDES=true)" >&2
            fi
            
            exit $exit_code
          }
          
          # ============================================================================
          # MAIN EXECUTION
          # 1. Validates environment
          # 2. Generates override files
          # 3. Runs OpenTofu with LocalStack configuration
          # 4. Cleans up afterward
          # ============================================================================
          main() {
            # Warn if no Terraform files found
            if ! ls *.tf &>/dev/null; then
              echo "Warning: No Terraform files found in current directory" >&2
            fi
            
            # Set up cleanup to run on exit (success or failure)
            trap cleanup EXIT INT TERM
            
            # Export AWS credentials for OpenTofu to use
            export AWS_ACCESS_KEY_ID="$AWS_ACCESS_KEY"
            export AWS_SECRET_ACCESS_KEY="$AWS_SECRET_KEY"
            export AWS_REGION="$REGION"
            
            # Always generate provider override
            generate_provider_override
            
            # Generate backend override only for init command
            if [[ "''${1:-}" == "init" ]]; then
              echo "Detected 'init' command - generating backend override..." >&2
              generate_backend_override
            fi
            
            # Execute OpenTofu with all passed arguments
            echo "Executing: ${pkgs.opentofu}/bin/tofu $*" >&2
            exec ${pkgs.opentofu}/bin/tofu "$@"
          }
          
          # Start execution
          main "$@"
        '';

      in
      {
        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            nodejs_22                # Required: Node 22
            gnumake
            awslocal
            terraformShim
            tflocal
          ];

          shellHook = ''
            # Claude / AWS env
            export AWS_REGION="us-west-2"
            export CLAUDE_CODE_USE_BEDROCK=1
            export CLAUDE_CODE_MAX_OUTPUT_TOKENS=4096
            export MAX_THINKING_TOKENS=1024
          '';

        };
      });
}