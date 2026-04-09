import os
import requests
from docx import Document
import re
from enum import Enum
import json
import logging
from time import sleep
import json
from collections import Counter
import subprocess
import shlex

from utils import ModelType, load_vulnerabilities
from config import root_dirs, gpt_model, contracts_dir, csv_path

# # 日志配置,输出到文件
# logging.basicConfig(level=logging.INFO, filename='analysis.log', filemode='w', format='%(asctime)s - %(name)s - %(levelname)s - %(message)s')

def gptret_convert_to_str_list(text):
    matches = re.findall(r'```json(.*?)```', text, re.DOTALL)
    if not matches:
        raise ValueError("未找到匹配的 JSON 块")
    if len(matches) > 1:
        raise ValueError("多个 JSON 块")
    
    text = matches[0]
    # text = text.replace('\n', '').replace('\r', '').replace('\t', '')# 去除无效的控制字符 
    # 将text转换为字符串列表，每个字符串代表一个JSON块，即list中的最外层大括号
    str_list = []
    braces_count = 0
    str_start = 0
    for i in range(len(text)):
        if text[i] == '{':
            braces_count += 1
            if braces_count == 1:
                str_start = i
        elif text[i] == '}':
            braces_count -= 1
            if braces_count == 0:
                str_list.append(text[str_start:i+1])
                str_start = i + 1
    return str_list

def str_convert_to_json_list(str_list):
    # 将字符串列表转换为JSON列表
    # return [json.loads(s) for s in str_list]
    json_list = [] 
    for s in str_list: 
        try: 
            # 移除多余的逗号
            # s = re.sub(r',\s*}', '}', s)
            # s = re.sub(r',\s*]', ']', s)
            # # 将“\'”替换为“\”，将“\"”替换为“"”等,避免json.loads解析出错
            # # s = re.sub(r"\\'", "'", s)
            # # s = re.sub(r'\\"', '"', s)
            # s = re.sub(r'\\n', '\n', s)
            # # 将字符串中的\\n替换为换行
            # s = re.sub(r'\\\\n', '\n', s)
            # # s = re.sub(r'\\\\n')
            # s = re.sub(r'\\t', '\t', s)
            json_list.append(json.loads(s, strict=False)) 
        except json.JSONDecodeError as e:
            print("s:", s) 
            print(f"JSONDecodeError: {e.msg} at line {e.lineno} column {e.colno} (char {e.pos})") # 打印出错位置附近的字符 
            error_position = e.pos 
            print(f"> Error context: {s[max(0, error_position-3):min(len(s), error_position+3)]}") 
    return json_list

def replace_function_in_contract(contract_code, json_list_obj):
    # 用于提取合约体的函数
    def extract_contract_body(contract_code, contract_name):
        #contract NetcToken is StandardToken{
        #library TransferHelper {
        # contract_start_pattern = re.compile(
        #     rf'(contract|library)\s+{contract_name}(\s+is[\w\s,]+\w+)?\s*{{', 
        #     re.DOTALL
        # )
        contract_start_pattern = re.compile(
            rf'\b(contract|library)\s+{contract_name}(\s+is[\w\s,]+\w+)?\s*{{',
            re.DOTALL
        )
        contract_start_match = contract_start_pattern.search(contract_code)

        if not contract_start_match:
            # print(f"context: {contract_code}")
            raise ValueError(f"Contract {contract_name} not found in the provided code.")
        else:
            logging.info(f"Contract {contract_name} found in the provided code.")

        # 找到合约体的起点
        start_index = contract_start_match.end()
        open_brackets = 1
        current_index = start_index

        # 手动匹配合约体内的括号
        while open_brackets > 0 and current_index < len(contract_code):
            if contract_code[current_index] == '{':
                open_brackets += 1
            elif (contract_code[current_index] == '}'):
                open_brackets -= 1
            current_index += 1
        end_index = current_index - 1

        # 提取合约体内容
        contract_body = contract_code[start_index:end_index]
        # print(f"contract_body: {contract_body}")
        # print(f"contract_next: {contract_code[end_index:current_index]}")
        return contract_body, start_index, end_index

    # 用于替换函数的函数
    def replace_function_body(contract_body, function_name, corrected_code):
        # function_pattern = re.compile(rf'function\s+{function_name}\s*\(.*?\)\s*.*?{{', re.DOTALL)
        # function_pattern = re.compile(
        #     rf'(function\s+{function_name}\s*\(.*?\)\s*.*?{{|'
        #     rf'\b{function_name}\s*\(.*?\)\s*.*?{{|'
        #     rf'\b{function_name}\s*{{)', 
        #     re.DOTALL
        # )
        # function_pattern = re.compile(
        #     rf'(function\s+{function_name}\s*\(.*?\)\s*.*?{{|'
        #     rf'\b{function_name}\s*\(.*?\)\s*.*?{{|'
        #     rf'\b{function_name}\s*{{|'
        #     rf'function\s*\(.*?\)\s*.*?{{)|'
        #     rf'\bcontract\s+{function_name}\s+is\s+[\w\s,_]+\s*{{',
        #     re.DOTALL
        # )
        # function_pattern = re.compile(
        #     rf'('
        #     rf'(contract|library)\s+{function_name}\s*\(.*?\)\s*.*?{{|'
        #     rf'\b{function_name}\s*\(.*?\)\s*.*?{{|'
        #     rf'\b{function_name}\s*{{|'
        #     rf'(contract|library)\s*\(.*?\)\s*.*?{{'
        #     rf')',
        #     re.DOTALL
        # )
        function_pattern = re.compile(
            rf'function\s*{function_name}\s*\(.*?\)\s*[\w\s]*?{{',
            re.DOTALL
        )
        # rf'\b{function_name}\s*\(.*?\)\s*(public|private|internal|external|view|pure|payable|nonpayable|constant|override|virtual|returns\s*\([^)]*\))?{{'
    
        # 	function destory(){
        if function_name == "fallback" \
            or "function()" in corrected_code \
            or "function ()" in corrected_code:
            #function () payable public { 
            function_pattern = re.compile(
                rf'function\s*\(.*?\)\s*.*?{{',
                re.DOTALL
            )
        if function_name == "receive":
            # receive() external payable {
            function_pattern = re.compile(
                rf'receive\s*\(.*?\)\s*.*?{{',
                re.DOTALL
            )
                
        function_match = function_pattern.search(contract_body)

        if not function_match:
            logging.info(f"pattern: {function_pattern}")
            raise ValueError(f"Function {function_name} not found in the contract body.") #contract_body:{contract_body}

        # 找到函数体的起点
        start_index = function_match.end()
        open_brackets = 1
        current_index = start_index

        # 手动匹配函数体内的括号
        while open_brackets > 0 and current_index < len(contract_body):
            if contract_body[current_index] == '{':
                open_brackets += 1
            elif contract_body[current_index] == '}':
                open_brackets -= 1
            current_index += 1

        # 替换原函数体
        function_body = contract_body[function_match.start():current_index]
        updated_contract_body = contract_body.replace(function_body, corrected_code)
        return updated_contract_body

    # 用于替换状态变量的函数
    def replace_state_variable(contract_body, variable_name, variable_code):
        variable_pattern = re.compile(rf'\b{variable_name}\b\s*=\s*.*?;', re.DOTALL)
        variable_match = variable_pattern.search(contract_body)

        if not variable_match:
            raise ValueError(f"State variable {variable_name} not found in the contract body.")

        # 替换状态变量
        variable_body = contract_body[variable_match.start():variable_match.end()]
        updated_contract_body = contract_body.replace(variable_body, variable_code)
        return updated_contract_body

    # 用于替换修饰符的函数
    def replace_modifier(contract_body, modifier_name, modifier_code):
        # modifier onlyOwner() {
        # modifier_pattern = re.compile(rf'modifier\s+{modifier_name}\s*{{', re.DOTALL)
        # modifier_pattern = re.compile(rf'modifier\s+{modifier_name}\s*\(\s*\)\s*{{', re.DOTALL)
        modifier_pattern = re.compile(
            r'('
            rf'modifier\s+{modifier_name}\s*{{|'
            rf'\bmodifier\s+{modifier_name}\s*\([^)]*\)\s*{{'
            r')',
            re.DOTALL
        )
        modifier_match = modifier_pattern.search(contract_body)

        if not modifier_match:
            print(f"context: {contract_body}")
            raise ValueError(f"Modifier {modifier_name} not found in the contract body.")

        # 找到修饰符体的起点
        start_index = modifier_match.end()
        open_brackets = 1
        current_index = start_index

        # 手动匹配修饰符体内的括号
        while open_brackets > 0 and current_index < len(contract_body):
            if contract_body[current_index] == '{':
                open_brackets += 1
            elif contract_body[current_index] == '}':
                open_brackets -= 1
            current_index += 1

        # 替换原修饰符体
        modifier_body = contract_body[modifier_match.start():current_index]
        updated_contract_body = contract_body.replace(modifier_body, modifier_code)
        # trcik: 修复修饰符的替换问题
        if "modifier modifier" in updated_contract_body:
            updated_contract_body.replace("modifier modifier", "modifier")
        return updated_contract_body

    # 遍历 json 对象列表，修复原来的合约代码
    for json_obj in json_list_obj:
        contract_name = json_obj.get("contract_name")
        # state_variables = json_obj.get("state_variables", [])
        modifiers = json_obj.get("modifiers", [])
        functions = json_obj.get("functions", [])
        # 如果functions大于1，说明有多个函数被修改，需要手动处理
        if len(functions) > 1:
            raise ValueError("Invalid JSON content: multiple functions modified. manual intervention required.")
        # if len(state_variables) > 1:
        #     raise ValueError("Invalid JSON content: multiple state variables modified. manual intervention required.")
        if len(modifiers) > 1:
            raise ValueError("Invalid JSON content: multiple modifiers modified. manual intervention required.")

        if not contract_name:
            raise ValueError("Invalid JSON content: missing contract_name.")
        
        contract_body, contract_start, contract_end = extract_contract_body(contract_code, contract_name)

        # 替换发生修改的状态变量
        # for var in state_variables:
        #     variable_name = var.get("variable_name")
        #     variable_code = var.get("variable_code")

        #     if not variable_name or not variable_code:
        #         raise ValueError("Invalid JSON content: missing variable_name or variable_code.")
            
        #     if var.get("change_type", "modified") != "modified":
        #         #TODO 统计需要手动处理的合约情况
        #         raise ValueError(f"Invalid JSON content: change_type is not 'modified'. manual intervention required.")

        #     # 替换状态变量
        #     contract_body = replace_state_variable(contract_body, variable_name, variable_code)

        # 替换发生修改的修饰符
        for mod in modifiers:
            modifier_name = mod.get("modifier_name")
            modifier_code = mod.get("modifier_code")

            if not modifier_name or not modifier_code:
                raise ValueError("Invalid JSON content: missing modifier_name or modifier_code.")
            
            if mod.get("change_type", "modified") != "modified":
                #TODO 统计需要手动处理的合约情况
                raise ValueError(f"Invalid JSON content: change_type is not 'modified'. manual intervention required.")

            # 替换修饰符
            contract_body = replace_modifier(contract_body, modifier_name, modifier_code)

        # 替换发生修改的函数
        for func in functions:
            function_name = func.get("function_name")
            corrected_code = func.get("corrected_code")
            # 确保 corrected_code 是字符串
            try:
                if isinstance(corrected_code, list):
                    # 拼接为字符串
                    corrected_code = "".join(corrected_code)
            except TypeError as e:
                raise ValueError(f"Invalid JSON content: corrected_code is not a string. {e}")

            if not function_name or not corrected_code:
                raise ValueError("Invalid JSON content: missing function_name or corrected_code.")
            
            if func.get("change_type", "modified") != "modified":
                #TODO 统计需要手动处理的合约情况
                raise ValueError(f"Invalid JSON content: change_type is not 'modified'. manual intervention required.")

            # 替换函数体
            contract_body = replace_function_body(contract_body, function_name, corrected_code)

        # 将修复后的合约代码插回原始代码中
        contract_code = contract_code[:contract_start] + contract_body + contract_code[contract_end:]
        # print(f"contract_code: {contract_code}")

    return contract_code

def process_contract_file(file_path, vul_file_path):
    # 读取GPT返回的包含json的修复信息
    with open(file_path, 'r') as file:
        contract_code = file.read()

    # 检查是否存在多个json块，要求只存在一个
    str_list = gptret_convert_to_str_list(contract_code)
    # print(f"json_block: {json_block}")
    json_list = str_convert_to_json_list(str_list)
    with open(vul_file_path, 'r') as file:
        print(f"vul_file_path: {vul_file_path}")
        fixed_contract_code = file.read()
        # print(f"fixed_contract_code: {fixed_contract_code}")

    # 修复合约代码
    json_list_count = len(json_list)
    # for json_obj in json_list: 
    #     fixed_contract_code = replace_function_in_contract(fixed_contract_code, json_obj)
    fixed_contract_code = replace_function_in_contract(fixed_contract_code, json_list)
        
    # 替换原文件中的合约代码
    with open(vul_file_path, 'w') as file:
        file.write(fixed_contract_code)
    if json_list_count == 1:
        logging.info(f"Fixed contract {vul_file_path} with {json_list_count} JSON blocks.")
    else:
        logging.warning(f"Fixed contract {vul_file_path} with {json_list_count} JSON blocks.")
    
    return fixed_contract_code

def main():
    # 遍历root_dirs的所有文件夹，打印其中的output子文件夹的相对路径，并通过输入选择其中一个文件夹
    if len(root_dirs) > 1:
        print("Please select a directory:")
        for i, root_dir in enumerate(root_dirs):
            # 如果output文件夹不存在，则跳过
            if not os.path.exists(f"{root_dir}/output"):
                continue
            print(f"{i}: {root_dir}")
        selected_index = int(input("Enter the index of the directory: "))
        selected_dir = root_dirs[selected_index]
    elif len(root_dirs) == 1:
        selected_dir = root_dirs[0]
    else:
        print("No root directories found.")
        return
    
    # 选择修复基于的GPT返回信息
    selected_dir = f"{selected_dir}/output/fixed_{gpt_model.value}"
    if not os.path.exists(selected_dir):
        print(f"Directory {selected_dir} not found.")
        return
    if len(os.listdir(selected_dir)) == 0:
        print(f"No subdirectories found in {selected_dir}.")
        return
    elif len(os.listdir(selected_dir)) == 1:
        selected_index = 0
    else:
        for i, model_dir in enumerate(os.listdir(selected_dir)):
            print(f"{i}: {model_dir}")
        selected_index = int(input("Enter the index of the directory: "))
    selected_dir = f"{selected_dir}/{os.listdir(selected_dir)[selected_index]}"   
    
    # 修复结果存放在selected_dir的fixed_contract文件夹：如果不存在修复文件则从数据集中获取原合约
    fixed_contract_dir = f"{selected_dir}/single_fixed_contracts"
    os.makedirs(fixed_contract_dir, exist_ok=True)
    
    # 修复选项：1.修复所有合约 2.修复当前未修复的合约
    print("Please select an option:")
    print("1: Fix all contracts")
    print("2: Fix only contracts that have not been fixed")
    print("3: Not fix single fixed contracts, skip ...")
    fix_option = int(input("Enter the option: "))
    if fix_option == 1:
        # 获取selected_dir文件夹中_gpt_return.txt结尾的文件
        for file in os.listdir(fixed_contract_dir):
            os.remove(f"{fixed_contract_dir}/{file}") # 避免之前的修复结果干扰
        # # 复制csv文件csv_path到selected_dir的vul_info文件夹（如果已有则覆盖）
        # try:
        #     csv_name = csv_path.split("/")[-1]
        #     res_csv_path = f"{selected_dir}/vul_info/{csv_name}"
        #     subprocess.run(["cp", csv_path, res_csv_path], check=True)
        # except subprocess.CalledProcessError as e:
        #     print(f"Error copying file: {e}")
    elif fix_option == 2:
        exist_files = os.listdir(fixed_contract_dir)
        # exist_addresses = [f.split(".")[0] for f in exist_files]
        exist_file_vul = set() # 单行修复中已经存在的文件
        for file in exist_files:
            file_vul = file.split(".")[0]
            exist_file_vul.add(file_vul)
        print(f"exist_file_vul count: {len(exist_file_vul)}")
    
    # 记录没有找到的合约
    # missing_contracts = set()
    # 记录处理失败的文件
    failed_files = set()
    # 记录每个文件的漏洞数
    file_counter = Counter()
    # 加载csv文件
    # df, _ = load_vulnerabilities(res_csv_path)
    # # 检查csv是否包含json读取失败和脚本替换失败两列，如果没有则添加
    # if "json_read_failed" not in df.columns:
    #     df["json_read_failed"] = None
    # if "script_replace_failed" not in df.columns:
    #     df["script_replace_failed"] = None
    
    logging.info(f"* Processing directory: {selected_dir}")
    gpt_return_files = [f for f in os.listdir(selected_dir) if f.endswith("_gpt_return.txt")]
    for gpt_ret_file in gpt_return_files:
        file_vul = gpt_ret_file[:-len("_gpt_return.txt")]
        # 文件名(漏洞行数) 文件名 file(vul_line)
        address = file_vul.split("(")[0]
        vul_line = file_vul.split("(")[1].split(")")[0]
        file_counter[address] += 1
        if fix_option == 2: # 只修复未修复过的合约文件
            # address等于文件名去掉后缀_gpt_return.txt
            if file_vul in exist_file_vul:
                print(f"Contract {file_vul} has been fixed. skipping...")
                continue
        if fix_option == 3: # 不修复已经修复过的合约文件
            continue
        print(f"* Processing {gpt_ret_file} ...")
        # 获取漏洞合约文件路径
        # 如果fixed_contract文件夹中存在合约文件则直接修复，否则从数据集中复制原合约文件
        vul_contract_path = f"{fixed_contract_dir}/{file_vul}.sol"
        if not os.path.exists(vul_contract_path):
            vul_contract_path_src = f"{contracts_dir}/{address}.sol"
            if not os.path.exists(vul_contract_path_src):
                print(f"Contract {address} not found in the dataset. ")
                logging.error(f"Contract {address} not found in the dataset.")
                continue
            # if not os.path.exists(vul_contract_path):
            # print(f"Contract {file_vul} not found in the dataset. moving {vul_contract_path_src} to {vul_contract_path}")
            # logging.info(f"Contract {file_vul} not found in the dataset. moving...")
        # os.system(f"cp {vul_contract_path_src} {vul_contract_path}")
        # print(f"Contract {file_vul} not found in the dataset. moving...")
        try:
            subprocess.run(["cp", vul_contract_path_src, vul_contract_path], check=True)
            # print(f"Contract {file_vul} not found in the dataset. moving...")
        except subprocess.CalledProcessError as e:
            print(f"Error copying file: {e}")
                
        # 修复合约代码
        gpt_ret_path = f"{selected_dir}/{gpt_ret_file}"
        try:
            fixed_code = process_contract_file(gpt_ret_path, vul_contract_path)
            # 保存修复后的代码
            with open(f"{vul_contract_path}", 'w') as file:
                file.write(fixed_code)
                print(f"* Fixed contract {vul_contract_path} with {gpt_ret_file}.")
        except ValueError as e:
            print(f"> Error: {e}")
            failed_files.add(gpt_ret_path)
            logging.error(f"Error processing {gpt_ret_path}: \n\t{e}")
    if fix_option == 2:
        print(f"exist_file_vul count: {len(exist_file_vul)}")       
    # 是否处理多行修复的合约
    print(" * Processing multi-fixed contracts ...")
    print("Please select an option:")
    print("1: Fix multi-fixed contracts which are not fixed")
    print("2: exit")
    option = int(input("Enter the option: "))
    if option == 2:
        return
    # 获取多行修复的合约文件
    duplicate_files = {file for file, count in file_counter.items() if count > 1}
    multifixed_contract_dir = f"{selected_dir}/multi_fixed_contracts"
    os.makedirs(multifixed_contract_dir, exist_ok=True)
    exist_files = os.listdir(multifixed_contract_dir) # filename.sol
    for file in duplicate_files:
        if f"{file}.sol" in exist_files:
            continue
        # 多行修复的合约文件
        fixed_file_path = f"{multifixed_contract_dir}/{file}.sol"
        if os.path.exists(fixed_file_path):
            continue
        # 从数据集中获取原合约文件
        vul_contract_path_src = f"{contracts_dir}/{file}.sol"
        if not os.path.exists(vul_contract_path_src):
            print(f"Contract {file} not found in the dataset. ")
            logging.error(f"Contract {file} not found in the dataset.")
            continue
        # 从数据集中复制原合约文件
        os.system(f"cp {vul_contract_path_src} {fixed_file_path}")
        # print(f"Contract {file} not found in the dataset. moving...")
        # logging.info(f"Contract {file} not found in the dataset. moving...")
        # 获取该文件所有的修复信息
        gpt_ret_files = [f for f in os.listdir(selected_dir) if f.startswith(f"{file}_")]
        # 检查脚本是否能正确处理（每个修复只有一个函数修改，且不同重复修改一个函数）
        flag_manual = False # 需要手动处理
        modified_functions = set()
        for gpt_file in gpt_ret_files:
            gpt_ret_path = f"{selected_dir}/{gpt_file}"
            with open(gpt_ret_path, 'r') as read_file:
                contract_code = read_file.read()
            # 正则匹配"function_name": "function"获取函数名
            matches = re.findall(r'"function_name": "(.*?)"', contract_code)
            # 如果有多个函数被修改，需要手动处理
            if len(matches) > 1:
                flag_manual = True
                break
            for match in matches:
                if match in modified_functions or match == "None":
                    flag_manual = True
                    break
                modified_functions.add(match)
        if flag_manual:
            print(f"Contract {file} has multiple functions modified. manual intervention required.")
            logging.warning(f"Contract {file} has multiple functions modified. manual intervention required.")
            continue
        # 依次处理每个修复文件
        for file in gpt_ret_files:
            gpt_ret_path = f"{selected_dir}/{file}"
            try:
                fixed_code = process_contract_file(gpt_ret_path, fixed_file_path)
                # 保存修复后的代码
                with open(f"{fixed_file_path}", 'w') as file:
                    file.write(fixed_code)
                    print(f"* Fixed contract {fixed_file_path} with {gpt_ret_path}.")
            except ValueError as e:
                print(f"> Error: {e}")
                failed_files.add(gpt_ret_path)
                logging.error(f"Error processing {gpt_ret_path}: \n\t{e}")
                
    
    # 输出处理失败的文件
    if failed_files:
        logging.error(f"Failed to process the following files:\n")
        for file in failed_files:
            logging.error(file)
        
    
    
    
    
main()

# TODO输出文件处理：输出文件格式为file_vul.sol，多行漏洞修复人工处理