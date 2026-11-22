#!/usr/bin/env python3
"""Unblind judge verdicts and count judged errors.

Usage: python3 -I aggregate.py CASES.json VERDICTS_DIR MAPS_DIR
VERDICTS_DIR holds <editor>-<n>.json files in the judge-prompt.md format.
MAPS_DIR holds map-<editor>.json: {case_id: {"P": cond, "Q": cond, "R": cond}}.
"""
import json, sys, pathlib, collections
KEYS = ["preservation_failure", "unnecessary_edit", "missed_justified_edit", "invented_content"]

def main():
    cases = {c["id"]: c for c in json.loads(pathlib.Path(sys.argv[1]).read_text(encoding="utf-8"))["cases"]}
    vdir, mdir = pathlib.Path(sys.argv[2]), pathlib.Path(sys.argv[3])
    agg = collections.defaultdict(collections.Counter)
    for vf in sorted(vdir.glob("*.json")):
        editor = vf.stem.rsplit("-", 1)[0]
        mp = json.loads((mdir / f"map-{editor}.json").read_text())
        for c in json.loads(vf.read_text(encoding="utf-8"))["cases"]:
            cid = c["id"]; typ = cases[cid]["type"]
            for lab, res in c["results"].items():
                cond = mp[cid][lab]
                for key in [(editor, cond, "all"), ("ALL", cond, "all"), ("ALL", cond, typ)]:
                    a = agg[key]; a["n"] += 1; a["rank_sum"] += res.get("rank", 0); a["first"] += res.get("rank") == 1
                    for k in KEYS: a[k] += len(res.get(k) or [])
    print(f"{'editor':8}{'cond':8}{'type':5}{'n':>4}{'pres':>6}{'unnec':>7}{'missed':>8}{'invent':>8}{'rank':>6}{'1st':>5}")
    for (e, c, t), a in sorted(agg.items()):
        print(f"{e:8}{c:8}{t:5}{a['n']:>4}{a['preservation_failure']:>6}{a['unnecessary_edit']:>7}{a['missed_justified_edit']:>8}{a['invented_content']:>8}{a['rank_sum']/a['n']:>6.2f}{a['first']:>5}")

if __name__ == "__main__":
    main()
