import pandas as pd
import os

def merge_and_update():
    # --- 1. 设置文件名 ---
    file_1_name = "合约复杂度信息-1.csv" 
    file_2_name = "合约复杂度信息-2.csv" 
    
    current_dir = os.path.dirname(os.path.abspath(__file__))
    file_1_path = os.path.join(current_dir, file_1_name)
    file_2_path = os.path.join(current_dir, file_2_name)

    # --- 2. 读取并清洗列名 ---
    def load_and_clean_df(path):
        df = None
        for enc in ['utf-8-sig', 'gbk', 'utf-8']:
            try:
                df = pd.read_csv(path, encoding=enc)
                break
            except:
                continue
        
        if df is not None:
            # 关键步骤：去掉列名两边的空格和隐藏字符 (BOM等)
            df.columns = df.columns.str.strip().str.replace('\ufeff', '')
            return df
        raise Exception(f"无法读取文件 {path}")

    print(f"读取并清洗文件 1: {file_1_name}")
    df_source = load_and_clean_df(file_1_path)
    print(f"读取并清洗文件 2: {file_2_name}")
    df_target = load_and_clean_df(file_2_path)

    # --- 3. 智能匹配列名 ---
    # 我们要找的目标列关键字
    target_keys = ['file', 'line', 'cyclomatic_complexity', 'function_count']
    actual_map = {}

    for key in target_keys:
        for col in df_source.columns:
            # 模糊匹配：只要列名里包含关键字（忽略大小写）
            if key.lower() in col.lower():
                actual_map[key] = col
                break
    
    if 'file' not in actual_map:
        print("❌ 严重错误：在源文件中找不到包含 'file' 的列！")
        print(f"当前源文件列名为: {list(df_source.columns)}")
        return

    print(f"🔍 最终匹配映射: {actual_map}")

    # --- 4. 提取与合并 ---
    # 提取源文件列并重命名为标准名
    v1_subset = df_source[list(actual_map.values())].copy()
    # 建立 反向映射进行重命名
    rename_map = {v: k for k, v in actual_map.items()}
    v1_subset.rename(columns=rename_map, inplace=True)

    # 同时也清洗一下文件2的列名，确保 merge 时 'file' 对得上
    target_file_col = None
    for col in df_target.columns:
        if 'file' in col.lower():
            target_file_col = col
            break
            
    if not target_file_col:
        print("❌ 错误：目标文件中找不到 'file' 列")
        return

    # 为了合并，统一把目标文件的 file 列也改名为 'file'
    df_target.rename(columns={target_file_col: 'file'}, inplace=True)

    # 删除目标文件中已存在的同名列（除 file 外）
    cols_to_drop = [k for k in actual_map.keys() if k != 'file' and k in df_target.columns]
    df_target_clean = df_target.drop(columns=cols_to_drop)

    # 合并
    df_final = pd.merge(df_target_clean, v1_subset, on='file', how='left')

    # --- 5. 保存 ---
    output_name = f"final_updated_{file_2_name}"
    df_final.to_csv(os.path.join(current_dir, output_name), index=False, encoding='utf-8-sig')
    print(f"✨ 成功！文件已保存: {output_name}")

if __name__ == "__main__":
    merge_and_update()