    #!/usr/bin/env python3
    import argparse, datetime, os, pathlib, sys, tempfile

    def read_text(path):
        p = pathlib.Path(path)
        return p.read_text(encoding="utf-8") if p.exists() else ""

    def write_atomic(path, content):
        p = pathlib.Path(path)
        p.parent.mkdir(parents=True, exist_ok=True)
        with tempfile.NamedTemporaryFile("w", delete=False, dir=str(p.parent), encoding="utf-8") as tmp:
            tmp.write(content)
            tmp_path = tmp.name
        os.replace(tmp_path, p)

    def main():
        ap = argparse.ArgumentParser(description="Deterministically compact .docs/MEMORY.md")
        ap.add_argument("--file", default=".docs/MEMORY.md", help="Path to MEMORY.md")
        ap.add_argument("--archive", default=".docs/MEMORY-archive.md", help="Archive file or index")
        ap.add_argument("--max-lines", type=int, default=120, help="Max lines to keep in MEMORY.md")
        ap.add_argument("--shard-monthly", action="store_true", help="Shard archived tail into .docs/archive/YYYY-MM.md")
        args = ap.parse_args()

        mem_path = pathlib.Path(args.file)
        if not mem_path.exists():
            print(f"{args.file} not found; nothing to compact.", file=sys.stderr)
            sys.exit(0)

        text = read_text(mem_path)
        lines = text.splitlines()

        # Locate sections
        def find_header(prefixes):
            for i, line in enumerate(lines):
                if any(line.strip().lower().startswith(p) for p in prefixes):
                    return i
            return None

        idx_check = find_header(("# session checkpoints", "## session checkpoints"))
        idx_cons  = find_header(("# constraints", "## constraints"))

        if idx_check is None:
            print("No 'Session Checkpoints' header found; aborting to avoid damaging content.", file=sys.stderr)
            sys.exit(1)

        # Define slices: [0 : idx_check] preamble, then checkpoints until constraints or EOF, then constraints..EOF
        preamble = lines[:idx_check]
        if idx_cons is None or idx_cons <= idx_check:
            checkpoints_block = lines[idx_check:]
            constraints_block = []
        else:
            checkpoints_block = lines[idx_check:idx_cons]
            constraints_block = lines[idx_cons:]

        # If within limit, nothing to do
        total_len = len(preamble) + len(checkpoints_block) + len(constraints_block)
        if total_len <= args.max_lines:
            print(f"MEMORY ok: {total_len} lines (≤ {args.max_lines})")
            sys.exit(0)

        # Keep: preamble + first K lines of checkpoints_block, where K ensures overall ≤ max_lines
        head_allow = max(args.max_lines - len(preamble) - len(constraints_block), 0)
        keep_checkpoints = checkpoints_block[:head_allow]
        tail_checkpoints = checkpoints_block[head_allow:]

        # Write MEMORY (atomic)
        new_text = "
".join(preamble + keep_checkpoints + constraints_block).rstrip() + "
"
        write_atomic(mem_path, new_text)

        # Prepare archive destination
        today = datetime.date.today()
        if args.shard_monthly:
            shard = pathlib.Path(".docs") / "archive" / f"{today.year:04d}-{today.month:02d}.md"
            arch_path = shard
            header = f"## Archived on {today.isoformat()}\n"
        else:
            arch_path = pathlib.Path(args.archive)
            header = f"---\n## Archived on {today.isoformat()}\n"

        # Ensure archive has a header if new
        existing = read_text(arch_path)
        if existing.strip() == "":
            if args.shard_monthly:
                existing = f"# Memory Archive {today.year:04d}-{today.month:02d}\n\n"
            else:
                existing = "# Memory Archive\n\n"

        append_blob = header + "\n".join(tail_checkpoints).rstrip() + "\n"
        write_atomic(arch_path, existing + append_blob)

        print(f"Compacted MEMORY: kept {len(keep_checkpoints)} chkpt lines; archived {len(tail_checkpoints)} to {arch_path}")

    if __name__ == "__main__":
        main()
