import pandas as pd
import os

def process_remote_csv(input_path):
    if not os.path.exists(input_path):
        print(f"❌ 错误：找不到文件: {input_path}")
        return

    print(f"📂 正在读取文件: {input_path}")
    
    # --- 解决编码问题的读取方式 ---
    try:
        df = pd.read_csv(input_path, encoding='gbk')
    except UnicodeDecodeError:
        df = pd.read_csv(input_path, encoding='utf-8-sig') # utf-8-sig 可以处理带 BOM 的 UTF8
    except Exception as e:
        print(f"❌ 读取失败: {e}")
        return

    def map_line(x):
        try:
            val = float(x)
            if val >= 800: return 801
            return (val // 200) * 200 + 199
        except: return x

    def map_complexity_count(x):
        try:
            val = float(x)
            if val >= 80: return 81
            return (val // 20) * 20 + 19
        except: return x

    # 处理列 (根据截图增加可能的截断列名)
    if 'line' in df.columns:
        df['line'] = df['line'].apply(map_line)

    cols_to_process = ['cyclomatic_complexity', 'cyclomati', 'function_count', 'function_']
    for col in df.columns:
        if col in cols_to_process:
            print(f"✅ 正在处理列: {col}")
            df[col] = df[col].apply(map_complexity_count)

    # 保存结果
    base_name = os.path.basename(input_path)
    output_path = os.path.join(os.getcwd(), f"processed_{base_name}")
    
    # 保存时建议用 utf-8-sig，这样 Excel 打开不会乱码
    df.to_csv(output_path, index=False, encoding='utf-8-sig')
    print(f"✨ 处理完成！结果已保存至: {output_path}")

if __name__ == "__main__":
    TARGET_FILE = r'C:\Users\Jiahao He\OneDrive\博士\论文\合约漏洞修复\Empirical Study\论文实验数据统计\RQ1\原合约\gpt4\fixed_result_4.csv'
    # TARGET_FILE = "合约复杂度信息-3.csv"
    process_remote_csv(TARGET_FILE)