#!/usr/bin/env python3
# Analyze text using Ollama if available; otherwise use simple keyword/regex fallback.
import os, json, re, argparse, subprocess, shutil

APT_KEYWORDS = ["lazarus", "apt29", "panda", "bronze", "bear", "turla", "fin7", "apt28"]
IOC_PATTERNS = {
    "ipv4": r"\b(?:\d{1,3}\.){3}\d{1,3}\b",
    "domain": r"\b[a-z0-9.-]+\.[a-z]{2,}\b",
    "email": r"\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}\b",
}

PROMPT = """Extract APT group names (e.g., Lazarus, APT29), and IOCs (IPv4, domains, emails) from the passage.
Return compact JSON: {"apts":[...], "iocs":{"ipv4":[...], "domain":[...], "email":[...]}} ONLY.
Text:
"""

def use_ollama(text):
    if not shutil.which("ollama"):
        return None
    try:
        proc = subprocess.run(
            ["ollama", "run", "llama3"],
            input=(PROMPT + text).encode("utf-8"),
            stdout=subprocess.PIPE, stderr=subprocess.PIPE, timeout=30
        )
        out = proc.stdout.decode("utf-8").strip()
        start = out.find("{"); end = out.rfind("}")
        if start != -1 and end != -1 and end > start:
            return json.loads(out[start:end+1])
    except Exception:
        return None
    return None

def fallback_extract(text):
    low = text.lower()
    apts = sorted({k for k in APT_KEYWORDS if k in low})
    iocs = {k: sorted(set(re.findall(p, text, flags=re.IGNORECASE))) for k, p in IOC_PATTERNS.items()}
    return {"apts": apts, "iocs": iocs}

def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--input", default="data/osint/collected.jsonl")
    ap.add_argument("--output", default="data/osint/analysis.jsonl")
    args = ap.parse_args()

    os.makedirs(os.path.dirname(args.output), exist_ok=True)
    n=0
    with open(args.input, "r", encoding="utf-8") as f, open(args.output, "w", encoding="utf-8") as out:
        for line in f:
            rec = json.loads(line)
            text = rec.get("text","")
            parsed = use_ollama(text) or fallback_extract(text)
            rec["analysis"] = parsed
            out.write(json.dumps(rec, ensure_ascii=False) + "\n")
            n+=1
    print(f"[analyze] processed {n} records -> {args.output}")

if __name__ == "__main__":
    main()
