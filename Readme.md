## Folder Overview (Experimental Data Statistics)

This directory contains the code, data, and results used for the empirical study. The materials are organized by research questions (RQ1–RQ3), discussion experiments, datasets, and plotting scripts.

## Directory Structure

```text
LLM4SCV_Repair/
├─ Readme.md
├─ RQ1/
│  ├─ README.md
│  ├─ environment.yml
│  ├─ processed_fixed_result_4.csv
│  ├─ Compile_Rate.py
│  ├─ data_preprocessing.py
│  ├─ gpt_check_vul.py
│  ├─ gpt_query.py
│  ├─ gpt_query_ret_json.py
│  ├─ result_processing.py
│  ├─ file_process.py
│  ├─ Info_check.py
│  ├─ config.py
│  └─ utils.py
├─ RQ2/
│  ├─ Traditional_Contract_Vulnerability_Repair_Tools/
│  │  └─ README.md
│  ├─ origin/ ...
│  └─ high-level contract/ ...
├─ RQ3/
│  ├─ README.md
│  ├─ gpt-detect.py
│  ├─ gpt-downgrade.py
│  └─ tips.py
├─ Discussion/
│  ├─ GPT-o1 For Contract Vulnerability Repair/
│  │  └─ README.md
│  ├─ Prompt Optimization/
│  │  └─ README.md
│  ├─ Pass@k/ ...
│  ├─ 不同重复次数检测结果/ ...
│  └─ (other discussion experiment artifacts and CSV/SOL/TXT outputs)
├─ Dataset/
│  ├─ 原合约.csv
│  ├─ 高版本合约.csv
│  ├─ 合约圈复杂度和函数数量/
│  │  ├─ 原合约.csv
│  │  └─ 高版本合约.csv
│  └─ Repaired Contract/
│     └─ Origin/
│        ├─ csv/
│        │  ├─ vul_info.csv
│        │  └─ filtered_summary.csv
│        └─ (sample .sol contracts)
└─ Figure/
   └─ figure.py
```

## What Each Folder Contains

- **RQ1**: Experimental code and results for **LLM-only smart contract vulnerability repair**.
- **RQ2**: Contains two parts:
  - **(1)** Experimental code and results for **LLM-based detection + repair**.
  - **(2)** Code and results for **traditional smart contract vulnerability repair tools** (including batch scripts and tool outputs).
- **RQ3**: Process and results for **optimizing LLM-based smart contract vulnerability repair methods**.
- **Discussion**: Results for discussion experiments, including:
  - Sampling-based repair results of **GPT-o1, GPT-4o, and GPT-5-mini**
  - **Pass@k** results
  - Results under different **prompting strategies**
  - Experiments on **enhancing vulnerability information**
- **Dataset**: The datasets used in the study, including:
  - The **original vulnerability dataset**
  - **100 additional high-level vulnerable contract source codes**
  - **103 manually repaired vulnerable contracts**