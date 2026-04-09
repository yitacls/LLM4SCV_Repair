## 📁 File Description

### Related Files When Traditional Contract Vulnerability Repair Tools
```
├── gpt-detect.py : Main script for detecting vulnerability with LLM
├── gpt-downgrade.py : Main script for downgrade the version of contract with LLM
└── tips.py : Main script for batch processing with traditional tool TIPS
```

## 🔁 Reproducibility Steps

### Detecting Vulnerability With LLM

- First, change the relative parameters in gpt.py that we use as 'api_key' and 'path1'

- Use `gpt-detect.py` to patch processing, such as:

    ```bash
    python gpt-detect.py
    ```
    
- Then we get the analysis result in the file

### Downgrading Contract With LLM

- First, change the relative parameters in gpt-detect.py that we use as 'api_key' and 'path1'

- Use `gpt-downgrade.py` to patch processing, such as:

  ```bash
  python gpt-downgrade.py
  ```

- Then we get the analysis result in the file

### Patch Processing For Traditional Repair Tool  TIPS

- First, change the relative parameters in tips.py as annotated after the parameter

- Use `tips.py` to patch processing, such as:

  ```bash
  python tips.py
  ```

