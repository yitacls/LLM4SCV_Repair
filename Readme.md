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
│  ├─ repeat_count_detection_results/ ...
│  └─ (other discussion experiment artifacts and CSV/SOL/TXT outputs)
├─ Dataset/
│  ├─ original_contracts.csv
│  ├─ high_version_contracts.csv
│  ├─ contract_cyclomatic_complexity_and_function_count/
│  │  ├─ original_contracts.csv
│  │  └─ high_version_contracts.csv
│  └─ Repaired Contract/
│     └─ Origin/
│        ├─ csv/
│        │  ├─ vul_info.csv
│        │  └─ filtered_summary.csv
│        └─ (sample .sol contracts)
└─ Figure/
   └─ figure.py
```

## Model Configuration

| Model | Description | Max_tokens | Training Data | Temp | Top_p | Freq_P |
|---|---|---|---|---|---|---|
| gpt-3.5-turbo-0125 | Optimized for efficiency and speed in general dialogue tasks. | 16k | Up to Sep 2021 | 0 | 1 | 0 |
| gpt-4-0613 | Standard version of GPT-4, excels at complex reasoning. | 8k | Up to Sep 2021 | 0 | 1 | 0 |
| DeepSeek-V3.2 | Features DSA and MoE architecture, optimized for long-context reasoning. | 160k | Up to Dec 2025 | 0 | 1 | 0 |
| Qwen3-Coder-480B | An agentic MoE model (480B) specialized for autonomous coding tasks. | 256k | Up to Jul 2025 | 0 | 1 | 0 |

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