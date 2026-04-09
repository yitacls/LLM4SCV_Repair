import os
import subprocess
import sys

def run_command(command):
    # run the command
    try:
        subprocess.run(command, check=True, shell=True)
    except subprocess.CalledProcessError as e:
        print(f"command failed: {e}")
        sys.exit(1)

def main():
    
    # change the following variables to your own
    contract_dir = ""  #contract dir
    target_dir = "" #slither result dir
    defectList_dir = ""#defect list dir
    ast_file_dir = "" #output AST dir
    output_dir = "" #output fixed result dir

    # run the following commands for TIPS
    run_command(f"./exeslither.sh {contract_dir} {target_dir}")
    run_command(f"python3 generateDefectList.py {target_dir} {contract_dir} {defectList_dir}")
    run_command(f"cd ./src")
    run_command(f"./getAST.sh {contract_dir} {ast_file_dir}")
    run_command(f"python3 ./src/TIPS.py -d {defectList_dir} -a {ast_file_dir} -i {contract_dir} -o {output_dir}")

if __name__ == "__main__":
    main()
