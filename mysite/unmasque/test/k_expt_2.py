import matplotlib.pyplot as plt
import numpy as np

# Data
K = [0.08, 0.4, 0.6, 0.8, 1, 2, 3]
Dmin = [1, 5,8, 13, 14, 31, 47]
min_time = np.array([5, 20, 33, 141, 404, 918, 1464])
extraction_time = np.array([41, 60, 71, 175, 471, 963, 1522])

# Stack the data manually to compute the boundaries
bottom = np.zeros_like(min_time)
top1 = min_time
top2 = extraction_time

# Create figure and axis
fig, ax1 = plt.subplots(figsize=(10, 6))

# Plot stacked filled areas with transparency
ax1.fill_between(K, bottom, top1, color='#ff6666', alpha=0.3, label="Minimization")
ax1.fill_between(K, top1, top2, color='#6a408d', alpha=0.3, label="Query Extraction")

# Overlay boundary lines with alpha=1
ax1.plot(K, top1, color='#ff6666', linewidth=2, alpha=1)  # top of Size
ax1.plot(K, top2, color='#6a408d', linewidth=2, alpha=1)   # top of Min Time
ax1.plot(K, bottom, color="black", linewidth=1)           # base line

# Axis labels, ticks, and styles
title_fontsize = 26
label_fontsize = 28
tick_fontsize = 22
legend_fontsize = 28

ax1.set_xlabel("K (Filter Predicate Constant)", fontsize=label_fontsize)
ax1.set_ylabel("Time (s)", fontsize=label_fontsize)
ax1.tick_params(axis='both', labelsize=tick_fontsize)
ax1.legend(loc="upper left", fontsize=legend_fontsize)

# Add secondary X-axis for Dmin
ax2 = ax1.twiny()
ax2.set_xlim(ax1.get_xlim())
ax2.set_xticks(K)
ax2.set_xticklabels(Dmin, fontsize=tick_fontsize)
ax2.set_xlabel(r'$|\mathcal{D}_{min}|$', fontsize=label_fontsize)
ax2.tick_params(axis='x', labelsize=tick_fontsize)

# Align axes to origin
ax1.set_xlim(left=0)
ax1.set_ylim(bottom=0)
plt.subplots_adjust(right=0.98)

# Optional: Grid
ax1.grid(True, linestyle='--', alpha=0.3)

plt.tight_layout()
plt.savefig("k_expt_2.pdf", format="pdf", bbox_inches='tight')
plt.show()
