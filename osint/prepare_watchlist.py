#!/usr/bin/env python3
# Prepare a CSV for a Sentinel Watchlist from analyzed records.
import os, json, csv, argparse

def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--input", default="data/osint/analysis.jsonl")
    ap.add_argument("--output", default="osint/osint_watchlist.csv")
    args = ap.parse_args()

    os.makedirs(os.path.dirname(args.output), exist_ok=True)
    rows = set()
    with open(args.input, "r", encoding="utf-8") as f:
        for line in f:
            rec = json.loads(line)
            apts = rec.get("analysis",{}).get("apts", [])
            for a in apts:
                if a:
                    rows.add(a.strip())

    with open(args.output, "w", newline="", encoding="utf-8") as csvf:
        w = csv.writer(csvf)
        w.writerow(["SearchKey"])
        for key in sorted(rows):
            w.writerow([key])
    print(f"[watchlist] wrote {len(rows)} keys -> {args.output}")

if __name__ == "__main__":
    main()
