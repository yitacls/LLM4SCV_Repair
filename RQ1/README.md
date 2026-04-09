## 📁 Dataset Description

```
dataset0/: Raw and manually reviewed dataset (1,290 contracts, 1,410 vulnerabilities)
dataset1/: Preprocessed input and LLM-repaired output
```

## 📁 Repair Results Folders

- `origin/`: Repair results for the **original 882 vulnerable contracts**.
- `high-level contracts/`: Repair results for the **additional 100 high-version vulnerable contracts**.

## 📄 Environment Setup

To reproduce the environment, use:

```bash
conda env export --no-builds > environment.yml
conda env create -f environment.yml
```

## 🔁 Reproducibility Steps

### 1.Data Preprocessing

- Use `gpt_check_vul.py` to detect vulnerability information, such as:

  ```bash
  python gpt_check_vul.py
  ```
- Use `data_preprocessing.py` to extract vulnerable functions and related data for LLM input

### 2.Obtaining Contract Repair Information via LLM

- `gpt_query.py` performs single-line vulnerability repair
- `gpt_query_ret_json.py` performs multi-line vulnerability repair

### 3.Applying Contract Repairs

- Use result_processing.py to apply the repair to the original contract

## 📌 Notes

Please ensure OpenAI API key is configured if using GPT-based scripts.

Solidity version compatibility is essential for traditional tools — see solcversion.py.
