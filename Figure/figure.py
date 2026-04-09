import matplotlib.pyplot as plt
import numpy as np

# 1. 准备数据
models = ['GPT-3.5', 'GPT-4', 'DeepSeek', 'Qwen']
colors = ['#1f77b4', '#d62728', '#2ca02c', '#ff7f0e'] 

# 添加了 Total 数据
data_loc = {
    'labels': ['0-199', '200-399', '400-599', '600-799', '800+'],
    'totals': [656, 219, 40, 30, 15],
    'GPT-3.5': [421, 113, 24, 15, 11],
    'GPT-4': [332, 92, 27, 11, 8],
    'DeepSeek': [482, 128, 26, 15, 14],
    'Qwen': [432, 119, 20, 9, 10]
}

data_cc = {
    'labels': ['0-19', '20-39', '40-59', '60-79', '80+'],
    'totals': [557, 233, 58, 42, 69],
    'GPT-3.5': [345, 129, 37, 27, 46],
    'GPT-4': [269, 106, 32, 27, 36],
    'DeepSeek': [396, 158, 34, 33, 38],
    'Qwen': [365, 156, 28, 32, 27]
}

data_nof = {
    'labels': ['0-19', '20-39', '40-59', '60-79', '80+'],
    'totals': [703, 162, 51, 29, 14],
    'GPT-3.5': [431, 89, 33, 21, 11],
    'GPT-4': [341, 74, 28, 20, 7],
    'DeepSeek': [493, 118, 30, 18, 10],
    'Qwen': [451, 102, 51, 23, 7]
}

def plot_complexity(ax, data, title, xlabel):
    x = np.arange(len(data['labels']))
    width = 0.2
    
    for i, model in enumerate(models):
        rects = ax.bar(x + i*width, data[model], width, label=model, color=colors[i], edgecolor='black', linewidth=0.7)
        # 在柱子顶部添加具体数值
        for rect in rects:
            height = rect.get_height()
            ax.annotate('{}'.format(height),
                        xy=(rect.get_x() + rect.get_width() / 2, height),
                        xytext=(0, 3),  # 3点纵向偏移
                        textcoords="offset points",
                        ha='center', va='bottom', fontsize=8, fontweight='bold')
    
    ax.set_title(title, fontsize=13, fontweight='bold', pad=15)
    ax.set_xlabel(xlabel, fontsize=11)
    ax.set_ylabel('Number of Successful Repairs', fontsize=11)
    
    # 修改 X 轴标签，加入 Total (N=xxx)
    new_labels = [f"{lbl}\n(N={tot})" for lbl, tot in zip(data['labels'], data['totals'])]
    ax.set_xticks(x + width * 1.5)
    ax.set_xticklabels(new_labels, fontsize=9)
    
    ax.grid(axis='y', linestyle='--', alpha=0.4)
    # 增加 y 轴留白空间，避免数字被顶掉
    ax.set_ylim(0, max([max(v) for k, v in data.items() if k in models]) * 1.25)

fig, (ax1, ax2, ax3) = plt.subplots(1, 3, figsize=(18, 6.5))

plot_complexity(ax1, data_loc, '(a) Lines of Code (LoC)', 'Range of LoC')
plot_complexity(ax2, data_cc, '(b) Cyclomatic Complexity (CC)', 'Range of CC')
plot_complexity(ax3, data_nof, '(c) Number of Functions (NoF)', 'Range of NoF')

handles, labels = ax1.get_legend_handles_labels()
fig.legend(handles, labels, loc='upper center', bbox_to_anchor=(0.5, 0.98), 
           ncol=4, fontsize=12, frameon=False)

plt.tight_layout(rect=[0, 0, 1, 0.92])
plt.show()