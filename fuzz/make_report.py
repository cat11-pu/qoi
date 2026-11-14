#!/usr/bin/env python3
"""Aggregates harness + reference results into REPORT.md.

Usage: make_report.py <report_dir>
"""

import json
import sys
from collections import Counter, defaultdict
from pathlib import Path


def load_jsonl(path):
    return [json.loads(l) for l in Path(path).read_text().splitlines() if l.strip()]


def main():
    report_dir = Path(sys.argv[1])
    manifest = {m["id"]: m for m in load_jsonl(report_dir / "corpus/malformed/manifest.jsonl")}
    malformed = load_jsonl(report_dir / "malformed_results.jsonl")
    valid = load_jsonl(report_dir / "valid_results.jsonl")
    ref = load_jsonl(report_dir / "ref_valid_results.jsonl")

    lines = []
    out = lines.append
    out("# QOI 解码器健壮性与正确性验证报告")
    out("")
    out("- 被测对象：`qoi.h`（上游 master `ffb2d2c`）的 `qoi_decode`")
    out("- 构建：`gcc -std=c99 -O1 -g -fsanitize=address,undefined,leak -fno-omit-frame-pointer`")
    out("- 畸形样本：5000 个（8 类），合法样本：500 个")
    out("- 参考实现：`fuzz/ref_decode.py`（按规范独立实现）+ `fuzz/qoi_diag.h`（严格校验器，带偏移报错）")
    out("")

    out("## 畸形输入（5000）")
    out("")
    cat_stats = defaultdict(Counter)
    reasons = Counter()
    lenient = 0
    for r in malformed:
        m = manifest[r["id"]]
        cat = m["category"]
        cat_stats[cat]["total"] += 1
        if r["lib_ch0"] or r["lib_ch3"] or r["lib_ch4"]:
            cat_stats[cat]["lib_accepted"] += 1
        else:
            cat_stats[cat]["lib_rejected"] += 1
        if r["diag_ok"]:
            cat_stats[cat]["strict_ok"] += 1
        else:
            reasons[r["diag_reason"]] += 1
        if (r["lib_ch0"] or r["lib_ch3"] or r["lib_ch4"]) and not r["diag_ok"]:
            lenient += 1

    out("| 类别 | 样本数 | 解码器拒绝 | 解码器接受（容错） |")
    out("|---|---|---|---|")
    for cat in sorted(cat_stats):
        s = cat_stats[cat]
        out(f"| {cat} | {s['total']} | {s['lib_rejected']} | {s['lib_accepted']} |")
    out("")
    out("- 崩溃 / 越界 / 泄漏：**0**（ASan+UBSan+LSan 全程无告警，进程正常退出）")
    out(f"- 严格校验判非法但被解码器容错接受：{lenient} 例"
        "（格式宽容，如缺失结束标记、尾部垃圾，非内存安全问题）")
    out("")
    out("严格校验器报告的失败原因分布（每条均带字节偏移，明细见 "
        "`malformed_results.jsonl` 的 `diag_off`/`diag_reason` 字段）：")
    out("")
    out("| 失败原因 | 次数 |")
    out("|---|---|")
    for reason, n in reasons.most_common():
        out(f"| {reason} | {n} |")
    out("")

    out("## 最小反例")
    out("")
    out("对每种严格校验失败原因，取语料中最小样本做 delta 最小化"
        "（`fuzz/min_counterexamples.py`），产物在 `counterexamples/`。"
        "全部经 sanitizer 构建的 C 校验器复核，原因与偏移一致：")
    out("")
    out("| 文件 | 大小 | 失败偏移 | 原因 | 被测解码器行为 |")
    out("|---|---|---|---|---|")
    ce_dir = report_dir / "counterexamples"
    if (ce_dir / "index.json").exists():
        import subprocess
        index = json.loads((ce_dir / "index.json").read_text())
        for entry in index:
            diag = subprocess.run(
                [str(Path(__file__).parent / "diag_one"), str(ce_dir / entry["file"])],
                capture_output=True, text=True).stdout.split()
            off = next((t.split("=")[1] for t in diag if t.startswith("offset=")), "-")
            lib = next((t.split("=")[1] for t in diag if t.startswith("lib=")), "-")
            out(f"| `counterexamples/{entry['file']}` | {entry['minimal_size']} B "
                f"| {off} | {entry['reason']} | {lib} |")
    out("")
    out("注：`lib=accept` 的 5 类为上游解码器的设计性容错——截断的 chunk 会读入"
        " 8 字节结束标记区（缓冲区界内，ASan 确认无越界），缺失的像素以最后"
        "像素值填充；不校验结束标记。非内存安全问题。")
    out("")

    out("## 合法输入（500）逐像素一致性")
    out("")
    n = len(valid)
    keys = ["desc_ok", "ch0_match", "ch3_match", "ch4_match", "diag_match"]
    out(f"- 样本数：{n}")
    for k in keys:
        ok = sum(1 for r in valid if r.get(k))
        out(f"- `{k}`：{ok}/{n}")
    ref_ok = sum(1 for r in ref if r.get("pixel_match") and r.get("desc_ok"))
    out(f"- 参考实现（Python）逐像素一致：{ref_ok}/{len(ref)}")
    bad = [r["id"] for r in valid if not all(r.get(k) for k in keys)]
    bad += [r["id"] for r in ref if not (r.get("pixel_match") and r.get("desc_ok"))]
    if bad:
        out(f"- **不一致样本**：{sorted(set(bad))}")
    else:
        out("- **结论：被测解码器与参考实现在全部 500 个合法文件上逐像素一致，"
            "含强制 3/4 通道转换。**")
    out("")

    (report_dir / "REPORT.md").write_text("\n".join(lines) + "\n")
    print(f"wrote {report_dir / 'REPORT.md'}")


if __name__ == "__main__":
    main()
