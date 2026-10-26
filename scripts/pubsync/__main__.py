"""CLI: python -m scripts.pubsync [--dry-run] [--max-new N] [--summary PATH]"""
import argparse
import sys
from pathlib import Path

from . import eurocontrol, sync

KEYS_FILE = Path(__file__).resolve().parent / ".last-run-keys"


def _summary(results, unmatched, unmatched_error) -> str:
    lines = ["## Publication sync", ""]
    added = [(r.key, n) for r in results for n in r.added]
    if added:
        lines += [f"- Added `{key}`: {n.item['title']} ({n.item['date']})" for key, n in added]
    else:
        lines.append("No new publications.")
    errors = [r for r in results if r.error]
    if errors:
        lines += ["", "### Errors", ""] + [f"- `{r.key}`: {r.error}" for r in errors]
    if unmatched or unmatched_error:
        lines += ["", "### Unmatched STATFOR entries", ""]
        lines += [f"- [{e.title}]({e.url})" for e in unmatched]
        if unmatched_error:
            lines.append(f"- Check failed: {unmatched_error}")
    return "\n".join(lines) + "\n"


def main(argv=None) -> int:
    ap = argparse.ArgumentParser(prog="python -m scripts.pubsync")
    ap.add_argument("--dry-run", action="store_true", help="report only, write nothing")
    ap.add_argument("--max-new", type=int, default=5)
    ap.add_argument("--summary", type=Path, help="write a Markdown summary to this path")
    args = ap.parse_args(argv)

    results = sync.run(sync.REPO_ROOT, dry_run=args.dry_run, max_new=args.max_new)
    unmatched, unmatched_error = [], None
    try:
        unmatched = sync.report_unmatched(eurocontrol.fetch)
    except Exception as e:
        unmatched_error = f"{type(e).__name__}: {e}"

    prefix = "would add" if args.dry_run else "added"
    for r in results:
        for n in r.added:
            print(f"{prefix} {r.key}: {n.item['title']} ({n.item['date']})")
        if r.error:
            print(f"ERROR {r.key}: {r.error}", file=sys.stderr)
    for e in unmatched:
        print(f"unmatched STATFOR entry: {e.title} {e.url}")
    if unmatched_error:
        print(f"WARNING STATFOR check failed: {unmatched_error}", file=sys.stderr)

    if args.summary:
        args.summary.write_text(_summary(results, unmatched, unmatched_error), encoding="utf-8")
    if not args.dry_run:
        KEYS_FILE.write_text(",".join(r.key for r in results if r.added), encoding="utf-8")
    return 2 if any(r.error for r in results) else 0


if __name__ == "__main__":
    sys.exit(main())
