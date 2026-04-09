import re
import logging
import os
# from concurrent.futures import ThreadPoolExecutor, as_completed
from tqdm import tqdm
import pandas as pd

from config import csv_path, contracts_dir, output_dir
from utils import load_vulnerabilities

def save_results(results, output_dir):
    # 保存结果output_dir文件夹的sol文件中
    os.makedirs(output_dir, exist_ok=True)
    for result in results:
        file_path = f"{output_dir}/{result['address'].lower()}({result['vul_line']}).sol"
        with open(file_path, 'w') as file:
            file.write(result['function_code'])

def extract_function_code(contract_code, vul_line):
    # 使用正则表达式匹配函数定义的起始部分
    # function_start_pattern = re.compile(r'function\s*\w*\s*\(.*?\)\s*(?:payable|public|private|internal|external|view|pure|constant|returns\s*\(.*?\))?\s*{', re.DOTALL)
    # function_start_pattern = re.compile(r'function\s*\w*\s*\(.*?\)\s*(?:\w+\s*)*{', re.DOTALL)
    # function_start_pattern = re.compile(
    #     r'function\s+\w*\s*\([^)]*\)\s*(?:\s*(?:payable|public|private|internal|external|view|pure|constant|returns\s*\([^)]*\))\s*)*\s*{',
    #     re.DOTALL
    # )
    # function_start_pattern = re.compile(
    #     r'function\s+\w*\s*\([^)]*\)\s*\w*\s*(?:\s*(?:payable|public|private|internal|external|view|pure|constant|returns\s*\([^)]*\))\s*)*\s*\w*\s*{',
    #     re.DOTALL
    # )
    # function_start_pattern = re.compile(
    #     r'function\s*\w*\s*\([^)]*\)',
    #     re.DOTALL
    # )
    # function_start_pattern = re.compile(
    #     r'(function\s*\w*\s*\([^)]*\)\s*|receive\s*\(\)\s*|modifier\s*\w*\s*|constructor\s*\([^)]*\)\s*)',
    #     re.DOTALL
    # )
    # function_start_pattern = re.compile(
    #     r'(function\s+\w+\s*\([^)]*\)\s*(public|private|internal|external)?\s*[^)]*|receive\s*\(\)\s*|modifier\s+\w+\s*|constructor\s*\([^)]*\)\s*)',
    #     re.DOTALL
    # )
    # function_start_pattern = re.compile(
    #     r'(function\s*\([^)]*\)\s*(public|private|internal|external|view|pure|payable|nonpayable|constant|override|virtual|returns\s*\([^)]*\))?\s*[^)]*|'
    #     r'function\s+\w+\s*\([^)]*\)\s*(public|private|internal|external|view|pure|payable|nonpayable|constant|override|virtual|returns\s*\([^)]*\))?\s*[^)]*|'
    #     r'receive\s*\(\)\s*|'
    #     r'modifier\s+\w+\s*|'
    #     r'constructor\s*\([^)]*\)\s*)',
    #     re.DOTALL
    # )
    function_start_pattern = re.compile(
        r'(function\s*\([^)]*\)\s*(public|private|internal|external|view|pure|payable|nonpayable|constant|override|virtual|returns\s*\([^)]*\))?|'
        r'function\s+\w+\s*\([^)]*\)\s*(public|private|internal|external|view|pure|payable|nonpayable|constant|override|virtual|returns\s*\([^)]*\))?|'
        r'receive\s*\(\)\s*|'
        r'modifier\s+\w+\s*|'
        r'constructor\s*\([^)]*\)\s*)',
        re.DOTALL
    )
    matches = function_start_pattern.finditer(contract_code)
    
    for match in matches:
        start_line = contract_code[:match.start()].count('\n') + 1
        if start_line <= vul_line:
            # 找到函数起始位置，接下来匹配整个函数体
            start_pos = match.start()
            end_pos = start_pos
            flag_interface = False
            # flag_comment = False
            
            # 找到第一个左大括号
            while end_pos < len(contract_code) and contract_code[end_pos] != '{' and not flag_interface:
                if contract_code[end_pos] == ';': # 排除函数接口
                    flag_interface = True
                # elif contract_code[end_pos] == '*': # 排除注释 /* */
                #     flag_comment = True
                open_braces = 1
                end_pos += 1
            if flag_interface: # 函数接口，继续查找下一个函数
                continue
            # if flag_comment:
            #     continue
            end_pos += 1 # 跳过第一个左大括号
            
            while open_braces > 0 and end_pos < len(contract_code):
                if contract_code[end_pos] == '{':
                    open_braces += 1
                elif contract_code[end_pos] == '}':
                    open_braces -= 1
                end_pos += 1
            
            end_line = contract_code[:end_pos].count('\n') + 1
            if start_line <= vul_line <= end_line:
                return contract_code[start_pos:end_pos]
    
    raise ValueError(f"Function containing line {vul_line} not found.")


def process_contracts(vulnerabilities, contracts_dir, issues_addresses = set()):
    results = []
    # for vul in vulnerabilities:
    for vul in tqdm(vulnerabilities, desc="Processing contracts"):
        if vul['file'] in issues_addresses:
            continue
        file_path = f"{contracts_dir}/{vul['file'].lower()}.sol"
        with open(file_path, 'r') as file:
            contract_code = file.read()
        
        try:
            function_code = extract_function_code(contract_code, int(vul['vul']))
            results.append({
                'address': vul['file'],
                'vul_line':  int(vul['vul']),
                'function_code': function_code
            })
            # logging.info(f"File: {vul['file']}, Line: {vul['vul']}")
        except ValueError as e:
            # print(f"Error processing {vul['file']} at line {vul['vul']}: {e}")
            logging.error(f"Error processing {vul['file']} at line {int(vul['vul'])}: {e}")
            # logging.info(f"code:\n{contract_code}")
                
        
    
    return results

# 检查数据集是否正确
def check_vulnerabilities(df, contracts_dir):
    issues_addresses = set()
    for index, row in df.iterrows():
        file_path = f"{contracts_dir}/{row['file'].lower()}.sol"
        if not os.path.exists(file_path):
            logging.error(f"File not found: {file_path}")
            issues_addresses.add(row['file'])
            continue
        
        with open(file_path, 'r') as file:
            contract_code = file.read()
            total_lines = contract_code.count('\n')
        
        if total_lines != int(row['line']) and total_lines != int(row['line']-1): 
            logging.error(f"Line number mismatch in file {row['file']}: total_lines {total_lines} != row['line']{row['line']}")
            issues_addresses.add(row['file'])
            continue
        
        for column in df.columns:
            if pd.isna(row[column]):
                logging.error(f"Empty value in file {row['file']} at column {column}")
                issues_addresses.add(row['file'])
                break
    logging.info("Check vulnerabilities done.\n")
    return issues_addresses

def dateset1():
    df,vulnerabilities = load_vulnerabilities(csv_path)
    
    # 检查漏洞信息
    issues_addresses = check_vulnerabilities(df, contracts_dir) # file列存储的是链上地址
    
    results = process_contracts(vulnerabilities, contracts_dir,issues_addresses)
    save_results(results, output_dir)

dateset1()

# # 将制定文件夹output_dir的{file}_{vul}.sol下划线改为{file}({vul}).sol
# def rename_files(output_dir):
#     for file in os.listdir(output_dir):
#         if '_' in file:
#             new_file = file.replace('_', '(').replace('.sol', ').sol')
#             os.rename(f"{output_dir}/{file}", f"{output_dir}/{new_file}")
#     logging.info("Rename files done.\n")
    
# rename_files(output_dir)