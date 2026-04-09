import json
import os
import re
import shutil
import tiktoken
from time import strftime, localtime, time, sleep
from utils import load_vulnerabilities, ModelType
import requests
from config import csv_path, api_key, contracts_dir, gpt_model


def count_tokens(text, model=ModelType.GPT3_5_TURBO):
    if model in [ModelType.GPT4_O1_PREVIEW, ModelType.GPT4_O1_MINI]:
        encoding = tiktoken.encoding_for_model(ModelType.GPT3_5_TURBO.value)
    else:
        encoding = tiktoken.encoding_for_model(model.value)

    tokens = encoding.encode(text)
    return len(tokens)


class PromptManager:
    def __init__(self):
        self.role = "You're a professional Solidity developer who detects vulnerable smart contracts for " \
                    "vulnerabilities."
        self.task_description = "You are a professional Solidity developer responsible for detecting vulnerable smart " \
                                "contract vulnerabilities."
        self.output_format = "Returns only ""Yes"" or ""No""to ensure that it has identified the pinned " \
                             "vulnerability. Each block of code should contain only one function."
        self.example = "Returns each judgment in text format along with the rationale, with no other output, " \
                       "like this:【Here are the results of the code audit:" \
                       "1.<Judgment info>:\n```Yes\n<Basis of Judgment>\n```" \
                       "2.<Judgment info>:\n```No\n<Basis of Judgment>\n```】"
        self.constraints = "Your job is to determine if there are vulnerabilities in each smart contract. If so, conduct an audit."
        self.expected_tone = "Think step by step, carefully."

    # Hints for problems with the output in JSON format
    def generate_prompt_json(self, code, version=None, vul_type=None):
        context = f"Below is the vulnerable contract code:\n【{code}】\n.  "
        output_format = '''Return the result in the following JSON format and only JSON, ensuring the code is properly formatted.
        Ensure the code follows best practices and is concise. 
        Analyze the preceding contract code to check whether it contains OWASP Top 10 vulnerabilities. 
        If so, describe the type of vulnerability and the line of code where the vulnerability is located. There is no need to give reasons for judgment. For the line where the vulnerability is located, mark it precisely to the code where the vulnerability may occur.
        Please note that the OWASP Top 10 includes access control, arithmetic, bad randomness, dos, front running, reentrancy, short addresses, time manipylation, unchecked low level calls, short address attack'''

        example = '''The result is returned in the following JSON format and ends with [END] at the end of the output, like this:\n
            【
            {
            "vulnerabilities":[
            {"vulnerability type":<access control|arithmetic|bad randomness|dos|front running|reentrancy|short addresses|time manipylation|unchecked low level calls|short address attack>,
            "row":<The number of lines in the code where the vulnerability resides>
            },
            ...]
            }[End]
            】'''

        lines = code.count('\n') + 1
        contract_info = ""
        if lines:
            contract_info += f'This contract file has a total of {lines} lines of code'
        # if version:
        #     contract_info += f"The Solidity version of the contract is {version}. "
        # if vul_type:
        #     contract_info += f"The vulnerability type is {vul_type}. "
        # if contract_name:
        #     contract_info += f"The contract name is {contract_name}. "
        output_format = output_format.replace("\n", "")
        user_content = f"{context} {contract_info} {self.constraints} {output_format} {self.expected_tone} {example}"

        if gpt_model in [ModelType.GPT4_O1_PREVIEW, ModelType.GPT4_O1_MINI]:
            return [
                {"role": "user", "content": self.role + user_content}
            ]
        else:
            return [
                {"role": "system", "content": self.role},
                {"role": "user", "content": user_content}
            ]


def analyze_vulnerability_with_gpt4(api_key, code, version=None, vul_type=None, model=ModelType.GPT4, retries=5,
                                    delay=5):
    headers = {
        "Authorization": f"Bearer {api_key}"
    }

    prompt_manager = PromptManager()
    # messages = prompt_manager.generate_prompt(code, version)
    messages = prompt_manager.generate_prompt_json(code, version, vul_type)
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

    for attempt in range(retries):
        try:
            start_time = time()
            response = requests.post("https://api.gptapi.us/v1/chat/completions", json=data, headers=headers)
            end_time = time()
            elapsed_time = end_time - start_time
            elapsed_time = round(elapsed_time, 2)

            response_json = response.json() if response.status_code == 200 else None
            if not response_json:
                gpt_ret = "Unable to get analysis results"
                continue

            if 'choices' in response_json:
                gpt_ret = response_json['choices'][0]['message']['content'] if response_json[
                    'choices'] else "Unable to get analysis results"
                if gpt_ret == "Unable to get analysis results":
                    continue
                else:
                    if model in [ModelType.GPT4_O1_PREVIEW, ModelType.GPT4_O1_MINI]:
                        user_message = messages[0]['content']
                        user_tokens = count_tokens(user_message, model)
                        response_tokens = count_tokens(gpt_ret, model)
                        total_tokens = user_tokens + response_tokens
                        analysis = (gpt_ret, elapsed_time, total_tokens)
                        return analysis
                    else:
                        system_message = messages[0]['content']
                        user_message = messages[1]['content']
                        system_tokens = count_tokens(system_message, model)
                        user_tokens = count_tokens(user_message, model)
                        response_tokens = count_tokens(gpt_ret, model)
                        total_tokens = system_tokens + user_tokens + response_tokens
                        analysis = (gpt_ret, elapsed_time, total_tokens)
                        return analysis
            else:
                print(f"There is no 'choices' field in the API response, {response_json}")
                continue
        except Exception as e:
            print(f"    OpenAI API request error: {e}, retrying...")
            if attempt < retries - 1:
                sleep(delay + attempt)
            else:
                raise e
    if gpt_ret == "Unable to get analysis results":
        return "Unable to get analysis results"
    else:
        return "Analysis failed"


def save_analysis_results(folder_path, original_file_name, analysis, vul, vul_line, model=ModelType.GPT4, version=None):
    """ Save analysis results to a file """
    global vul_iden
    save_folder = os.path.join(folder_path, f'output/fixed_{model.value}')
    if version:  # Timestamp version
        save_folder = os.path.join(save_folder, version)
    os.makedirs(save_folder, exist_ok=True)
    new_file_name = f"{original_file_name.split('.')[0]}_gpt_return.txt"
    # analysis = (gpt_ret, elapsed_time, token_usage)
    # gpt_ret = analysis
    gpt_ret, elapsed_time, token_usage = analysis
    with open(os.path.join(save_folder, new_file_name), 'w', encoding='utf-8') as file:
        file.write(gpt_ret)

    # Determine whether the output is complete
    address = original_file_name.split('(')[0]

    if "[End]" in gpt_ret or "[END]" in gpt_ret:
        gpt_ret.replace('[End]', '')
        gpt_ret.replace("[END]", '')
        # str to json
        vul_line = original_file_name.split('(')[1].split(')')[0]
        match = re.search(r'\{.*\}', gpt_ret, re.DOTALL)
        extracted_text = match.group(0).replace('\n', '')
        gpt_ret_json = json.loads(extracted_text)
        # Convert to a dictionary type
        vulner = gpt_ret_json['vulnerabilities']
        vulDict = {}
        for vulnerability in vulner:
            if "vulnerability type" not in vulnerability or "row" not in vulnerability:
                continue
            vuln_type = vulnerability["vulnerability type"]
            row = vulnerability["row"]
            row = str(row)
            if isinstance(row, list):
                rows = [str(r) for r in row]
            elif isinstance(row, str):
                if "-" in row:
                    start, end = map(int, row.split("-"))
                    rows = [str(i) for i in range(start, end + 1)]
                elif "," in row:
                    rows = [r.strip() for r in row.split(",")]
                elif re.compile(r'^\d+$').match(row):
                    rows = [row]
                else:
                    continue
            elif isinstance(row, int):
                rows = [str(row)]
            else:
                continue
            for r in rows:
                if r not in vulDict:
                    vulDict[r] = []
                vulDict[r].append(vuln_type)

        for idx in vulDict.keys():
            vul = vul.replace("_", ' ').lower()
            if abs(int(vul_line) - int(idx)) <= 5 and (vul in vulDict[f'{idx}']):
                # if abs(int(vul_line) - int(idx)) == 0:
                vul_iden = "Yes"
                break
            else:
                vul_iden = "No"
    else:
        vul_iden = "Token_limited"

    # If the vul_info.csv file does not exist, copy from csv_path to the vul_info subfolder of the save_folder folder
    csv_save_folder = os.path.join(save_folder, 'vul_info')
    output_csv_path = os.path.join(csv_save_folder, 'vul_info.csv')
    os.makedirs(csv_save_folder, exist_ok=True)  # 创建vul_info文件夹
    if not os.path.exists(output_csv_path):
        shutil.copy(csv_path, output_csv_path)
        df, _ = load_vulnerabilities(output_csv_path)
        df['result'] = None
        df['time'] = None
    else:
        df, _ = load_vulnerabilities(output_csv_path)
    df.loc[(df['file'].map(str.lower) == address) & (df['vul'] == int(vul_line)), 'result'] = vul_iden
    df.loc[(df['file'].map(str.lower) == address) & (df['vul'] == int(vul_line)), 'time'] = elapsed_time
    df.to_csv(output_csv_path, index=False)


def main(root_dirs=None):
    if root_dirs is None:
        root_dirs = ['datasets/dataset1']
    print("The GPT models currently in use are:" + gpt_model.value)
    choice = None
    while choice not in ['1', '2']:
        print("Please select: 1. Detect the new version 2. Continue to detect the previous version")
        choice = input()
    if choice == '1':
        time_version = strftime("%Y%m%d-%H%M%S", localtime())
    else:
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
        print("Please select the version you want to continue testing:")
        for i, version in enumerate(versions):
            print(f"{i + 1}. {version}")
        choice = None
        while choice not in range(1, len(versions) + 1):
            choice = int(input())
        time_version = versions[choice - 1].split('\\')[-1]

    failed_files = set()
    for root_dir in root_dirs:
        if os.path.isdir(root_dir):
            print(f"The catalog is being processed '{root_dir}'...")
            root_dir = os.path.abspath(root_dir)
            contract_dir = os.path.join(root_dir, 'vul_functions')
            for file_name in os.listdir(contract_dir):
                pattern = re.compile(
                    r'^(0x[a-fA-F0-9]{40}|\w+[-\w]*|\d{4}-\d{5})\(\d+\)\.sol$')
                # 0x0a66d93d08ff6c2720267936d48655452745652c.sol
                if pattern.match(file_name):
                    # 如果gpt修复结果已经存在则跳过
                    save_folder = os.path.join(root_dir, f'output/fixed_{gpt_model.value}')
                    if time_version:  # 时间戳版本
                        save_folder = os.path.join(save_folder, time_version)
                    new_file_name = f"{file_name.split('.')[0]}_gpt_return.txt"
                    if os.path.exists(os.path.join(save_folder, new_file_name)):
                        print(f"The analysis results for file '{file_name}' already exist, skip.")
                        continue
                    print(f"Analyzing file '{file_name}'...")
                    file_path = root_dir.replace('dataset1', 'dataset0') + '\\contractsVul\\' + file_name.split("(")[
                        0] + ".sol"
                    with open(file_path, 'r', encoding='utf-8') as file:
                        code = file.read()
                        model = gpt_model
                        codevul = code.count('\n') + 1
                        try:
                            vul_line = file_name.split('(')[1].split(')')[0]
                            address = file_name.split('(')[0]
                            df, vulnerabilities = load_vulnerabilities(csv_path)
                            for vul in vulnerabilities:
                                if vul['file'].lower() == address and vul['vul'] == int(vul_line):
                                    version = vul['version']
                                    vul_type = vul['vultype']
                                    break
                            else:
                                version = None
                                vul_type = None

                            analysis = analyze_vulnerability_with_gpt4(api_key, code, version, vul_type, model)
                            if analysis != "Analysis failed" and analysis != "Unable to get analysis results":
                                # analysis = (gpt_ret, elapsed_time, token_usage)
                                save_analysis_results(root_dir, file_name, analysis, vul_type, vul_line=codevul,
                                                      model=model, version=time_version)
                                print(f"The analysis of file '{file_name}' has been completed. √")
                            else:
                                print(f"Parsing error for file '{file_name}'. ×")
                                new_file_name = f"{file_name.split('.')[0]}_gpt_return.txt"
                                with open(os.path.join(save_folder, new_file_name), 'w', encoding='utf-8') as file:
                                    file.write("Time Timited.")
                                failed_files.add(file_name)
                        except Exception as e:
                            print(f"Parsing error for file '{file_name}', {e} ×")
                            failed_files.add(file_name)
    for file_name in failed_files:
        print(f"Parsing failed for file '{file_name}'.")
    print(f"Number of failed contracts: {len(failed_files)}")


if __name__ == "__main__":
    main()
