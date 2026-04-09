import os
import sys
import re
import csv
import solcx
from pathlib import Path
from solcx import install_solc, get_installed_solc_versions
from solcx.exceptions import SolcError
from collections import Counter

# --- 环境补丁 ---
os.environ["PYTHONUTF8"] = "1"
if sys.platform == "win32":
    import subprocess
    from functools import partial
    subprocess.Popen = partial(subprocess.Popen, encoding='utf-8', errors='ignore')

def classify_error(error_msg):
    """精细化错误分类"""
    error_msg = error_msg.lower()
    if "safemath" in error_msg and ("not found" in error_msg or "file not found" in error_msg):
        return "Fix Issue: SafeMath Missing (修复逻辑依赖缺失)"
    if "@openzeppelin" in error_msg:
        return "External Dependency: OZ Missing (外部库缺失)"
    if "not found" in error_msg or "file not found" in error_msg:
        return "Import Missing (其他依赖缺失)"
    if "parsererror" in error_msg:
        return "Syntax Error (语法错误)"
    if "declarationerror" in error_msg:
        return "Declaration Error (定义错误)"
    if "not compatible" in error_msg or "source file requires" in error_msg:
        return "Version Mismatch (版本不匹配)"
    return "Other Logic Error (其他逻辑错误)"

def check_compilation_rate(target_folder_name):
    target_path = Path.cwd() / target_folder_name
    if not target_path.exists():
        print(f"Error: 找不到文件夹 {target_path}")
        return

    sol_files = list(target_path.glob("**/*.sol"))
    total_files = len(sol_files)
    success_count = 0
    results = []
    error_stats = Counter()

    print(f">>> 启动检测: {target_folder_name} | 总数: {total_files}")
    print("-" * 60)

    for file_path in sol_files:
        version = "0.8.19" # 默认初始值
        try:
            content = file_path.read_bytes().decode('utf-8', errors='ignore')
            v_match = re.search(r'pragma\s+solidity\s+([^;]+);', content)
            if v_match:
                v_num = re.search(r'\d+\.\d+\.\d+', v_match.group(1))
                if v_num:
                    version = v_num.group(0)
        except Exception as e:
            results.append([file_path.name, "N/A", "READ_ERROR", str(e), "IO Error"])
            error_stats["IO Error (文件读取失败)"] += 1
            continue

        try:
            if version not in [str(v) for v in get_installed_solc_versions()]:
                print(f"正在安装缺失的 solc {version}...")
                install_solc(version)

            compile_kwargs = {"solc_version": version, "output_values": ["abi"]}
            v_parts = [int(p) for p in version.split('.')]
            if len(v_parts) >= 3 and (v_parts[0] > 0 or (v_parts[0] == 0 and v_parts[1] > 8) or (v_parts[0] == 0 and v_parts[1] == 8 and v_parts[2] >= 8)):
                compile_kwargs["base_path"] = str(file_path.parent)
                compile_kwargs["allow_paths"] = str(target_path.parent)
            
            solcx.compile_files([file_path], **compile_kwargs)
            success_count += 1
            print(f"[OK] {file_path.name}")
            results.append([file_path.name, version, "SUCCESS", "", "N/A"])

        except SolcError as e:
            detailed_err = e.stderr_data if e.stderr_data else str(e)
            category = classify_error(detailed_err)
            error_stats[category] += 1
            clean_err = detailed_err.replace('\n', ' ').replace('\r', '')[:200]
            print(f"[FAIL] {file_path.name} | 类型: {category}")
            results.append([file_path.name, version, "FAILED", clean_err, category])
        except Exception as e:
            error_stats["System/Internal (系统异常)"] += 1
            print(f"[ERR] {file_path.name} 系统异常: {str(e)[:50]}")
            results.append([file_path.name, version, "SYSTEM_ERROR", str(e), "System/Internal"])

    # --- 关键修复：在写入 CSV 前先计算好 rate ---
    rate = (success_count / total_files) * 100 if total_files > 0 else 0
    fail_count = total_files - success_count

    # --- 3. 生成报告 ---
    safe_name = target_folder_name.replace('/', '_').replace('\\', '_')
    report_file = f"Report_{safe_name}.csv"
    os.makedirs(os.path.dirname(report_file) if os.path.dirname(report_file) else '.', exist_ok=True)
    
    with open(report_file, 'w', newline='', encoding='utf-8') as f:
        writer = csv.writer(f)
        writer.writerow(["FileName", "SolcVersion", "Status", "ErrorMessage", "ErrorCategory"])
        writer.writerows(results)
        
        # 追加汇总统计
        writer.writerow([])
        writer.writerow(["=== 编译率统计汇总 ==="])
        writer.writerow(["总计文件", total_files])
        writer.writerow(["成功数量", success_count])
        writer.writerow(["失败数量", fail_count])
        writer.writerow(["最终成功率", f"{rate:.2f}%"])
        
        writer.writerow([])
        writer.writerow(["=== 错误原因分布 ==="])
        writer.writerow(["错误类型", "出现次数", "占比"])
        for err_type, count in error_stats.most_common():
            p = (count / fail_count * 100) if fail_count > 0 else 0
            writer.writerow([err_type, count, f"{p:.2f}%"])

    print("-" * 60)
    print(f"【检测完成】 成功率: {success_count}/{total_files} ({rate:.2f}%)")
    if error_stats:
        print("\n【错误原因分布统计】:")
        for err_type, count in error_stats.most_common():
            print(f" - {err_type}: {count} 个")
    print("-" * 60)
    print(f"报告已生成: {report_file}")

if __name__ == "__main__":
    if len(sys.argv) > 1:
        check_compilation_rate(sys.argv[1])
    else:
        print("请指定目录路径。")