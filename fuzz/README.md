# QOI 解码器模糊测试与正确性验证

一键复现（在仓库根目录执行，需要 gcc 与 python3）：

```sh
sh fuzz/run_all.sh
```

产物写入 `artifacts/fuzz-report/`：

- `REPORT.md` — 汇总报告
- `corpus/valid/` — 500 个合法文件（`.qoi` + `.raw` 基准像素 + `manifest.txt`）
- `corpus/malformed/` — 5000 个畸形文件（8 类，确定性种子，可复现）
- `malformed_results.jsonl` — 每个畸形文件的解码结果与失败偏移/原因
- `valid_results.jsonl` / `ref_valid_results.jsonl` — C 与 Python 参考实现的逐像素比对
- `counterexamples/` — 每种失败原因的最小反例（delta 最小化）

## 组件

| 文件 | 作用 |
|---|---|
| `gen_valid.c` | 生成合法语料（`qoi_encode` 编码随机图像） |
| `gen_malformed.py` | 生成 5000 个畸形文件 |
| `qoi_diag.h` | 严格校验器：按规范独立实现，失败报告字节偏移 |
| `harness.c` | 主测试台，ASan/UBSan/LSan 下运行 |
| `ref_decode.py` | Python 参考解码器（逐像素一致性基准） |
| `decode_one.c` + `minimize.py` | 崩溃复现器与 ddmin 最小化（本次运行零崩溃，未触发） |
| `diag_one.c` | 单文件严格校验 + 库行为对照 |
| `min_counterexamples.py` | 按失败原因做 delta 最小化 |

## 崩溃最小化（如有）

```sh
python3 fuzz/minimize.py fuzz/decode_one <crashing.qoi> <minimized.qoi>
```
