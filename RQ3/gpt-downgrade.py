import os
import requests
# from docx import Document

# def read_issue_file(file_path):
#     """ 从.docx文件中读取问题内容 """
#     doc = Document(file_path)
#     issue_content = " ".join([para.text for para in doc.paragraphs]).strip()
#     return issue_content

def analyze_issue_with_gpt4(source_code, api_key):
    """ 使用 GPT-4 分析区块链问题内容 """
    headers = {
        "Authorization": f"Bearer {api_key}"
    }
    data = {
        "model": "GPT-3.5-turbo",
        "messages": [
            {"role": "system", "content": "You are a smart contract auditor."},
            {"role": "user", "content": f"""You are a smart contract developer and now have a high version of a smart contract
              that you need to convert to version 0.4.26 with the following contract:{source_code} Output: [downgraded code]…

            """
                        }]
    }
    
    try:
        response = requests.post("https://api.gptapi.us/v1/chat/completions", json=data, headers=headers)
        response_json = response.json()
        return response_json['choices'][0]['message']['content'] if response_json['choices'] else "无法获取分析结果"
    except Exception as e:
        print(f"OpenAI API 请求出错: {e}")
        return "分析失败"

def save_analysis_results(folder_path, original_file_name, analysis):
    """ 保存分析结果到文件 """
    new_file_name = f"analysis-{original_file_name.split('.')[0]}.txt"
    with open(os.path.join(folder_path, new_file_name), 'a', encoding='utf-8') as file:
        file.writelines(analysis)

def main():
    """ 主函数 """
    api_key = ""  # 替换为您的 OpenAI API 密钥
    path1="" #替换为您的文件路径   
    with open(path1) as f:
        source_code = f.read()

    # issue_content = "I have a problem with my smart contract. It's not working as expected. Can you help me?"
    analysis = analyze_issue_with_gpt4(source_code, api_key)
    unfixed_path = ""  # Define the path
    file_name = "example.docx"  # Define the file name
    if analysis != "分析失败":
        save_analysis_results(unfixed_path, file_name, analysis)
        print(analysis)
        print(f"已完成对文件 '{file_name}' 的分析。")
    else:
        print(f"文件 '{file_name}' 的分析失败。")


if __name__ == "__main__":
    main()
