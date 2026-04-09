# -*- coding: utf-8 -*-
import os
import requests
from docx import Document
import re
import json
import logging
from time import sleep, strftime, localtime, time
import json
import shutil
import tiktoken


from utils import load_vulnerabilities, ModelType
from config import csv_path, api_key, root_dirs, contracts_dir, gpt_model

# # 日志配置,输出到文件
# logging.basicConfig(level=logging.INFO, filename='analysis.log', filemode='w', format='%(asctime)s - %(name)s - %(levelname)s - %(message)s')



# 问题提示管理器
class PromptManager:
    def __init__(self):
        self.role = "You are an expert Solidity developer tasked with repairing a vulnerable smart contract function."
        self.task_description = "You are an expert Solidity developer tasked with repairing a vulnerable smart contract function."
        self.output_format = "Return only the corrected smart contract function, ensuring that it adheres to Solidity's best practices, is concise, and eliminates the identified vulnerability. Each code block should contain only one function"
        self.example = "Return each corrected function in Markdown format without other output(eg.contract、pragma), enclosed in separate code blocks, like this:【Here are the corrected functions:1.<fix_info>:\n\n```solidity\n<corrected_function_1>\n```2.<fix_info>:\n```solidity\n<corrected_function_2>\n```】"
        self.constraints = "Your job is to fix the vulnerabilities in each function while preserving their original functionality."
        self.expected_tone = "Think step by step, carefully."
    
    # def generate_prompt(self, code, version=None):
    #     context = f"Below is the vulnerable contract code:\n\n{code}\n\n"
        
    #     if version is None:
    #         user_content = f"{context} {self.constraints} {self.output_format} {self.expected_tone} {self.example}"
    #     else:
    #         user_content = f"{context} The Solidity version of the contract is {version}. {self.constraints} {self.output_format} {self.expected_tone} {self.example}"
        
    #     if gpt_model in [ModelType.GPT4_O1_PREVIEW, ModelType.GPT4_O1_MINI]:
    #         return [
    #             {"role": "user", "content": self.role+user_content}
    #         ]
    #     else:
    #         return [
    #             {"role": "system", "content": self.role},
    #             {"role": "user", "content": user_content}
    #         ]  
    
    # 输出json格式的问题提示
    def generate_prompt_json(self, code, version=None, vul_type=None, contract_name=None):
        context = f"Below is the vulnerable contract code:\n\n【{code}】\n\n."
        # 以json格式输出问题提示
        output_format = '''Return the result in the following JSON format and only JSON, ensuring the code is properly formatted with indentation and line breaks.\nEnsure the code follows best practices and is concise. '''
        # example = '''Return the result in the following JSON format, like this:\n【Here is the fixed code:{{\n  \'solidity_version\': \<solidity_version>\n,\n  \'fixed_function1\': <fix_function_code1>,\n \'fixed_function2\': <fix_function_code1>,...,\n \'fixed_functionn\': <fix_function_coden>}}】.\n'''
        example = '''Return the corrected functions in JSON format, as this without others context, and only return the function code you fixed:
            【```json
            [{
                "contract_name": "<contract_name>",
                "contract_version": "<contract_version>",
                "state_variables": [
                    {
                        "variable_name": "<variable_name>",
                        "fix_info": "<fix_description>",
                        "variable_code": "<variable_code>",
                        "change_type": "<added|modified|deleted>"
                    }
                ],
                "modifiers": [
                    {
                        "modifier_name": "<modifier_name>",
                        "fix_info": "<fix_description>",
                        "modifier_code": "<modifier_code>",
                        "change_type": "<added|modified|deleted>"
                    }
                ],
                "functions": [
                    {
                        "function_name": "<function_name>",
                        "fix_info": "<fix_description>",
                        "corrected_code": "<corrected_function_code>",
                        "change_type": "<added|modified|deleted>"
                    }
                ],
            }]
            ```】'''
        
        contract_info = ""
        if version:
            contract_info += f"The Solidity version of the contract is {version}. "
        if vul_type:
            contract_info += f"The vulnerability type is {vul_type}. "
        if contract_name:
            contract_info += f"The contract name is {contract_name}. "

        user_content = f"{context} {contract_info} {self.constraints} {output_format} {self.expected_tone} {example}"
        
        if gpt_model in [ModelType.GPT4_O1_PREVIEW, ModelType.GPT4_O1_MINI]:
            # return [
            #     {"role": "user", "content": "Are you ok?"}
            # ]
            return [
                {"role": "user", "content": self.role+user_content}
            ]
        else:
            return [
                {"role": "system", "content": self.role},
                {"role": "user", "content": user_content}
            ] 
    
# gpt-3.5-turbo（上下文长度8K） 和 gpt-4-all（上下文长度32K） 是ChatGPT官网逆向模型
# gpt-4-all 和 gpt-4o-all 模型由于封号严重、次数有限故存在降至3.5的情况，请谨慎使用

def count_tokens(text, model=ModelType.GPT3_5_TURBO): # 利用tiktoken计算token数量
    if model in [ModelType.GPT4_O1_PREVIEW, ModelType.GPT4_O1_MINI]:
        # raise ValueError("GPT-4 O1 模型不支持计算 token 数量")
        encoding = tiktoken.encoding_for_model(ModelType.GPT3_5_TURBO.value)
    else:
        # 获取模型的编码器
        encoding = tiktoken.encoding_for_model(model.value)
    
    # 将文本编码为tokens
    tokens = encoding.encode(text)
    
    # 返回token数量
    return len(tokens)

# 文件读取问题
# 如何从较长合约中截取漏洞代码片段，特别是涉及内部函数调用的情况
def read_issue_file(file_path):
    """ 从.docx文件中读取问题内容 """
    doc = Document(file_path)
    issue_content = " ".join([para.text for para in doc.paragraphs]).strip()
    return issue_content

# 使用GPT修复合约漏洞
def analyze_vulnerability_with_gpt4(api_key, code, version=None, vul_type=None, contract_name=None, model=ModelType.GPT4, retries=5, delay=5):
    """ 使用 GPT-4 模型分析合约漏洞 """
    headers = {
        "Authorization": f"Bearer {api_key}"
    }
    
    prompt_manager = PromptManager()
    # messages = prompt_manager.generate_prompt(code, version)
    messages = prompt_manager.generate_prompt_json(code, version, vul_type, contract_name)
    if gpt_model in [ModelType.GPT4_O1_PREVIEW, ModelType.GPT4_O1_MINI]:
        data = {
            "model": model.value,
            "messages": messages,
            "temperature": 0
        }
    else:
        data = {
            "model": model.value,
            "messages": messages
        }
    
    # 使用 json.dumps 格式化 data
    formatted_data = json.dumps(data, indent=4, ensure_ascii=False)
    logging.info(f"请求数据:\n{formatted_data}")

    for attempt in range(retries):
        elapsed_time = 0
        try:
            start_time = time()  # 记录请求前的时间
            # https://api.gptapi.us/v1/chat/completions gptapi.us提供的接口
            response = requests.post("https://api.gptapi.us/v1/chat/completions", json=data, headers=headers)
            end_time = time()  # 记录响应时间
            elapsed_time = end_time - start_time  # 计算耗时，保留两位小数
            elapsed_time = round(elapsed_time, 2)
            
            response_json = response.json()
            # print(f"API 响应: {response_json}")
            if 'choices' in response_json:
                # token_usage = response_json.get('usage', {}) # 无法获取
                # logging.info(f"请求耗时: {elapsed_time:.2f} 秒")
                # logging.info(f"Token 使用情况: {token_usage}")
                gpt_ret = response_json['choices'][0]['message']['content'] if response_json['choices'] else "无法获取分析结果"
                if gpt_ret == "无法获取分析结果":
                    continue
                else:
                    # 查看返回结果是否包含示例中的关键字
                    # if "change_type" not in gpt_ret or "corrected_code" not in gpt_ret:
                    #     print(f"API 响应中不包含 'change_type' 或 'corrected_code' 字段: {response_json}")
                    #     continue
                    # 计算token使用情况，由于接口无法获取，故使用tiktoken计算
                    if model in [ModelType.GPT4_O1_PREVIEW, ModelType.GPT4_O1_MINI]:
                        user_message = messages[0]['content']
                        user_tokens = count_tokens(user_message, model)
                        response_tokens = count_tokens(gpt_ret, model)
                        total_tokens = user_tokens + response_tokens
                        # analysis 包含gpt_ret,耗时和token使用情况
                        analysis = (gpt_ret, elapsed_time, total_tokens)
                        return analysis
                    else:
                        system_message = messages[0]['content']
                        user_message = messages[1]['content']
                        system_tokens = count_tokens(system_message, model)
                        user_tokens = count_tokens(user_message, model)
                        response_tokens = count_tokens(gpt_ret, model)
                        total_tokens = system_tokens + user_tokens + response_tokens
                        # analysis 包含gpt_ret,耗时和token使用情况
                        analysis = (gpt_ret, elapsed_time, total_tokens)
                        return analysis
            else:
                print(f"API 响应中没有 'choices' 字段: {response_json}")
                continue
            # return response_json['choices'][0]['message']['content'] if response_json['choices'] else "无法获取分析结果"
        except Exception as e:
            print(f"    OpenAI API 请求出错: {e}，重试中...")
            # print(f"    返回结果: {response_json}")
            if attempt < retries - 1:
                sleep(delay+attempt)
            else:
                raise e
    if gpt_ret == "无法获取分析结果":
        return "无法获取分析结果"
    else: 
        return "分析失败"

# 保存分析结果
def save_analysis_results(folder_path, original_file_name, analysis,model=ModelType.GPT4, version=None):
    """ 保存分析结果到文件 """
    #保存到文件夹./output/fixed_{model.value}/fixed_fragment
    save_folder = os.path.join(folder_path, f'output/fixed_{model.value}')
    if version: # 时间戳版本
        save_folder = os.path.join(save_folder, version)
    os.makedirs(save_folder, exist_ok=True)
    new_file_name = f"{original_file_name.split('.')[0]}_gpt_return.txt"
    # analysis = (gpt_ret, elapsed_time, token_usage)
    gpt_ret, elapsed_time, token_usage = analysis
    with open(os.path.join(save_folder, new_file_name), 'w', encoding='utf-8') as file:
        file.write(gpt_ret)
    # 保存修复时间和token使用情况到save_folder文件夹的vul_info.csv文件中
    # address, vul_line = original_file_name.split('.')[0].split('_')
    # vul_line = original_file_name.split('_')[-1].split('.')[0]
    # address = original_file_name.replace(f'_{vul_line}.sol', '')
    # original_file_name为{address}({vul_line}).sol格式
    address = original_file_name.split('(')[0]
    vul_line = original_file_name.split('(')[1].split(')')[0]
    
    # 如果vul_info.csv文件不存在，则从csv_path复制到save_folder文件夹的vul_info子文件夹
    csv_save_folder = os.path.join(save_folder, 'vul_info')
    output_csv_path = os.path.join(csv_save_folder, 'vul_info.csv')
    os.makedirs(csv_save_folder, exist_ok=True) # 创建vul_info文件夹
    if not os.path.exists(output_csv_path):
        shutil.copy(csv_path, output_csv_path)
        # 新增两列：fix_time和token_usage
        df, _ = load_vulnerabilities(output_csv_path)
        df['fix_time'] = None
        df['token_usage'] = None
    else:
        df, _ = load_vulnerabilities(output_csv_path)
    # 读取vul_info.csv文件,并将修复时间和token使用情况写入到vul_info.csv文件的对应行（address对应'file'列，vul_line对应'vul'列）中
    df.loc[(df['file'].lower() == address) & (df['vul'] == int(vul_line)), 'fix_time'] = elapsed_time
    df.loc[(df['file'].lower() == address) & (df['vul'] == int(vul_line)), 'token_usage'] = token_usage
    # 保存到vul_info.csv文件
    df.to_csv(output_csv_path, index=False)

# 获取漏洞文件中漏洞行所在合约名
def get_contract_name(contracts_dir, address, vul_line):
    """ 获取漏洞文件中漏洞行所在合约名 """
    # 获取原漏洞合约文件路径
    vul_file_path = os.path.join(contracts_dir, f"{address}.sol")
    with open(vul_file_path, 'r', encoding='utf-8') as file:
        code = file.read()
        lines = code.split('\n')
        line_num = 0
        contract_name = None
        for line in lines:
            # if re.match(r'^(abstract\s+)?contract\s+\w+(\s+is\s+\w+)?\s*{?', line, re.MULTILINE): # 无法匹配下划线
            # if re.match(r'^(abstract\s+)?contract\s+[\w_]+(\s+is\s+\w+)?\s*{?', line, re.MULTILINE):
            # if re.match(r'^(abstract\s+)?contract\s+[\w_]+(\s+is\s+[\w\s,_]+)?\s*{?', line, re.MULTILINE):
            # if re.match(r'^\s*(abstract\s+)?contract\s+[\w_]+(\s+is\s+[\w\s,._]+)?\s*\{', line, re.MULTILINE):
            if re.match(r'^\s*(abstract\s+)?(contract|library)\s+[\w_]+(\s+is\s+[\w\s,._]+)?\s*\{?', line, re.MULTILINE): # 增加对library的支持
                # 去除abstract关键字
                if line.startswith('abstract'):
                    contract_name = line.split()[2]
                else:
                    contract_name = line.split()[1]
                # 去除合约名后的左括号
                if contract_name.endswith('{'):
                    contract_name = contract_name[:-1]
            line_num += 1
            if line_num >= int(vul_line):
                print(f"合约名：{contract_name}")
                logging.info(f"合约名：{contract_name}")
                if contract_name == None:
                    raise ValueError(f"Contract name containing line {vul_line} not found.")
                return contract_name
        raise ValueError(f"Contract name containing line {vul_line} not found.")
            
        
        

## == 主函数 == ##
def main():
    """ 主函数 """
    # 使用GPT模型为
    print("当前使用的GPT模型为：" + gpt_model.value)
    # 根据输入选择是检测新的版本还是继续检测之前的版本（异常终止和错误直接删除）
    choice = None
    while choice not in ['1', '2']:
        print("请选择：1.检测新的版本 2.继续检测之前的版本")
        choice = input()
    if choice == '1':
        # 为了标明版本，使用时间XXXXXX-XXXXXX，使用当前时间精确到秒
        time_version = strftime("%Y%m%d-%H%M%S", localtime())
    else:
        # 已有版本从root_dirs/子文件夹/output/fixed_{model.value}中获取子文件夹名
        versions = []
        for root_dir in root_dirs:
            if os.path.isdir(root_dir):
                root_dir = os.path.abspath(root_dir)
                fixed_dir = os.path.join(root_dir, f'output/fixed_{gpt_model.value}')
                if os.path.isdir(fixed_dir):
                    for version in os.listdir(fixed_dir):
                        # version_path = os.path.join(fixed_dir, version)
                        if len(root_dirs) == 1:
                            version_path = os.path.join(f'fixed_{gpt_model.value}', version)
                            versions.append(version_path)
                        else:
                            version_path = os.path.join(root_dir, f'output/fixed_{gpt_model.value}', version)
                            versions.append(version_path)
        if not versions:
            raise ValueError("No fixed versions found.")
        # 人工选择版本
        print("请选择要继续检测的版本：")
        for i, version in enumerate(versions):
            print(f"{i+1}. {version}")
        choice = None
        while choice not in range(1, len(versions)+1):
            choice = int(input())
        time_version = versions[choice-1].split('/')[-1]
    logging.info("开始基于GPT生成修复信息，当前版本为：" + time_version)
    # 记录处理失败的文件名
    failed_files = set() 
    temp_count = 0  # 临时计数，废弃
    
    for root_dir in root_dirs:
        if os.path.isdir(root_dir):
            #将相对路径转化为绝对路径
            print(f"正在处理目录 '{root_dir}'...")
            logging.info(f"正在处理目录 '{root_dir}'...")
            root_dir = os.path.abspath(root_dir)
            contract_dir = os.path.join(root_dir, 'vul_functions')
            for file_name in os.listdir(contract_dir):
                pattern = re.compile(r'^(0x[a-fA-F0-9]{40}|\w+[-\w]*|\d{4}-\d{5})\(\d+\)\.sol$') #0x0a66d93d08ff6c2720267936d48655452745652c.sol
                if pattern.match(file_name): 
                    # 如果gpt修复结果已经存在则跳过
                    save_folder = os.path.join(root_dir, f'output/fixed_{gpt_model.value}')
                    if time_version: # 时间戳版本
                        save_folder = os.path.join(save_folder, time_version)
                    new_file_name = f"{file_name.split('.')[0]}_gpt_return.txt"
                    if os.path.exists(os.path.join(save_folder, new_file_name)):
                        logging.info(f"文件 '{file_name}' 的分析结果已存在，跳过。")
                        continue
                    logging.info(f"正在分析文件 '{file_name}'...")
                    print(f"正在分析文件 '{file_name}'...") #合约地址_漏洞行数.sol
                    file_path = os.path.join(contract_dir, file_name)
                    with open(file_path, 'r', encoding='utf-8') as file:
                        code = file.read()
                        # model=ModelType.GPT4
                        model = gpt_model
                        # 使用GPT
                        try:
                            # 从文件名获取合约名和漏洞行数，合约名是除去最后的_漏洞函数.sol后的部分，注意合约名中可能包含_
                            # vul_line = file_name.split('_')[-1].split('.')[0]
                            # address = file_name.replace(f'_{vul_line}.sol', '')
                            # original_file_name = f"{address}({vul_line}).sol"
                            vul_line = file_name.split('(')[1].split(')')[0]
                            address = file_name.split('(')[0]
                            # 从excel中获取漏洞信息：根据合约地址和漏洞行数获取excel中的漏洞信息（version、vul_type）
                            df, vulnerabilities = load_vulnerabilities(csv_path)
                            for vul in vulnerabilities:
                                if vul['file'] == address and vul['vul'] == int(vul_line):
                                    version = vul['version']
                                    vul_type = vul['vultype']
                                    break
                            else:
                                version = None
                                vul_type = None
                            # 获取漏洞文件中漏洞行所在合约名
                            contract_name = get_contract_name(contracts_dir, address, vul_line)

                            # 使用GPT分析
                            analysis = analyze_vulnerability_with_gpt4(api_key, code, version, vul_type, contract_name, model)
                            if analysis != "分析失败" and analysis != "无法获取分析结果":
                                # analysis = (gpt_ret, elapsed_time, token_usage)
                                save_analysis_results(root_dir, file_name, analysis, model=model, version=time_version)
                                # print(f"已完成对文件 '{file_name}' 的分析。")
                                print(f"已完成对文件 '{file_name}' 的分析。√")
                                logging.info(f"已完成对文件 '{file_name}' 的分析。√")
                            else:
                                print(f"文件 '{file_name}' 的分析失败。×")
                                failed_files.add(file_name)
                                logging.info(f"文件 '{file_name}' 的分析失败。×")
                        except Exception as e:
                            print(f"文件 '{file_name}' 的分析失败2: {e} ×")
                            failed_files.add(file_name)
                            logging.error(f"文件 '{file_name}' 的分析失败2: {e} ×")
                    sleep(2) # 
                    temp_count += 1
                    # if temp_count > 20:
                    #     break
    #统计检测失败的合约，失败的合约不会保存文件
    logging.info("检测失败的合约：\n")
    for file_name in failed_files:
        print(f"文件 '{file_name}' 的分析失败。")
        logging.info(f"文件 '{file_name}' 的分析失败。")
    logging.info(f"检测失败的合约数量：{len(failed_files)}")
    
   

if __name__ == "__main__":
    main()


