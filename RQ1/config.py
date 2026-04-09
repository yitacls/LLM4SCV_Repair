import logging

from utils import ModelType

# 日志配置,输出到文件
logging.basicConfig(level=logging.INFO, filename='analysis.log', filemode='w', format='%(asctime)s - %(name)s - %(levelname)s - %(message)s')

# dataset_preprocessing.py参数
csv_path = './datasets/dataset0/vul_info.csv' # 原始漏洞合约的信息
contracts_dir = 'datasets/dataset0/vul_contracts' # 原始漏洞合约的目录
output_dir = 'datasets/dataset1/vul_functions' # 保存切片函数的目录
gpt_model = ModelType.GPT4O  # 指定的模型类型
# gpt_model = ModelType.GPT4_O1_PREVIEW  # 指定的模型类型
# gpt_model = ModelType.GPT4_O1_MINI

# gpt_query.py参数
api_key = "sk-..."  # 替换为您的 OpenAI API 密钥

root_dirs = [
        'datasets/dataset1'
    ]  # 指定的根目录


