#!/usr/bin/env python3
# Ethical OSINT scraper (simulated). Collects from an included sample feed.
import json, os, argparse, datetime

def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--output", default="data/osint/collected.jsonl")
    ap.add_argument("--sample", default="data/osint/sample_feed.json")
    args = ap.parse_args()

    os.makedirs(os.path.dirname(args.output), exist_ok=True)

    with open(args.sample, "r", encoding="utf-8") as f:
        feed = json.load(f)

    cnt = 0
    with open(args.output, "w", encoding="utf-8") as out:
        for item in feed:
            item["collected_at"] = datetime.datetime.utcnow().isoformat() + "Z"
            out.write(json.dumps(item, ensure_ascii=False) + "\n")
            cnt += 1
    print(f"[scrape] wrote {cnt} items to {args.output}")

if __name__ == "__main__":
    main()
