import pandas as pd
from enum import Enum

def load_vulnerabilities(xlsx_path):
    # # 从 XLSX 文件中加载漏洞信息
    # df = pd.read_excel(xlsx_path, engine='openpyxl')
    # vulnerabilities = df.to_dict(orient='records')
    # return df,vulnerabilities
    # 从 CSV 文件中加载漏洞信息
    df = pd.read_csv(xlsx_path)
    vulnerabilities = df.to_dict(orient='records')
    return df,vulnerabilities



# 模型类型枚举
class ModelType(Enum): 
    GPT4_O1_PREVIEW = "o1-preview-2024-09-12"  #o1-preview-2024-09-12
    GPT4_O1_MINI = "o1-mini-2024-09-12"  #o1-mini-2024-09-12
    GPT4_O1 = "o1-2024-12-17"
    GPT4 = "gpt-4"
    GPT4_TURBO = "gpt-4-turbo"
    GPT4O = "gpt-4o-2024-11-20" #多模态模型
    # 其他多模态的模型暂时pass
    # GPT3_5 = "gpt-3.5" #上下文长度8K
    GPT3_5_TURBO = "gpt-3.5-turbo" #上下文长度8K