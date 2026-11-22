#!/usr/bin/env python3
"""Mechanical scoring of rewrite outputs against annotated cases.

Usage: python3 -I score.py CASES.json TEXTS_DIR OUT_ROOT [--json]
OUT_ROOT contains one directory per condition, named out-<editor>-<condition>,
each holding <case-id>.md files. Phrases are literal (no regex): matching ignores
case, treats ё as е and collapses whitespace.
The dash column counts U+2014/U+2013 characters. It describes typography and
is not a defect unless a house style forbids dashes.
"""
import json, re, sys, difflib, pathlib, collections

def norm(t):
    t = t.lower().replace("ё", "е").replace("\u2014", "-").replace("\u2013", "-")
    return re.sub(r"\s+", " ", t).strip()

def hit(rule, text):
    return any(norm(p) in text for p in rule["any"])

def words(t):
    return re.findall(r"\w+", t.lower())

def score_one(case, src, out):
    n = norm(out)
    sw, ow = words(src), words(out)
    return {
        "preservation_failure": sum(not hit(r, n) for r in case.get("protected", [])),
        "voice_lost": sum(not hit(r, n) for r in case.get("voice", [])),
        "missed_change": sum(hit(r, n) for r in case.get("must_change", [])),
        "keep": round(difflib.SequenceMatcher(None, sw, ow, autojunk=False).ratio(), 3),
        "dash": out.count("\u2014") + out.count("\u2013"),
        "editor_note": len(re.findall(r"\[TODO|\[источник|Уточнить:", out)),
        "words": len(ow),
    }

def main():
    cases_p, texts_p, root_p = map(pathlib.Path, sys.argv[1:4])
    as_json = "--json" in sys.argv
    cases = json.loads(cases_p.read_text(encoding="utf-8"))["cases"]
    rows = []
    for d in sorted(root_p.glob("out-*")):
        editor, cond = d.name[4:].split("-", 1)
        for c in cases:
            f = d / f"{c['id']}.md"
            if not f.exists():
                continue
            src = (texts_p / f"{c['id']}.md").read_text(encoding="utf-8")
            rows.append({"case": c["id"], "type": c["type"], "editor": editor, "cond": cond,
                         **score_one(c, src, f.read_text(encoding="utf-8"))})
    if as_json:
        print(json.dumps(rows, ensure_ascii=False, indent=1)); return
    agg = collections.defaultdict(lambda: collections.Counter())
    for r in rows:
        for key in [(r["editor"], r["cond"], "all"), (r["editor"], r["cond"], r["type"]), ("ALL", r["cond"], "all"), ("ALL", r["cond"], r["type"])]:
            a = agg[key]; a["n"] += 1
            for k in ("preservation_failure", "voice_lost", "missed_change", "dash", "editor_note"): a[k] += r[k]
            a["keep_sum"] += r["keep"]
    print(f"{'editor':8}{'cond':8}{'type':5}{'n':>4}{'pres_fail':>10}{'voice_lost':>11}{'missed':>8}{'keep':>7}{'dash':>6}{'notes':>6}")
    for (e, c, t), a in sorted(agg.items()):
        print(f"{e:8}{c:8}{t:5}{a['n']:>4}{a['preservation_failure']:>10}{a['voice_lost']:>11}{a['missed_change']:>8}{a['keep_sum']/a['n']:>7.2f}{a['dash']:>6}{a['editor_note']:>6}")

if __name__ == "__main__":
    main()
