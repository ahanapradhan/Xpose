import matplotlib.pyplot as plt
import numpy as np

# Data
K = [0, 0.2, 0.4, 0.6, 0.8, 1, 1.2, 1.4, 1.6, 1.8]
Dmin = [1, 3, 5, 8, 11, 13, 17, 20, 25, 24]
min_time = np.array([1.97, 2.48, 4.3, 6.38, 5.39, 10.25, 9.44, 27.63, 38.15, 22.53])
extraction_time = np.array([24.51, 24.87, 23.9, 25.03, 31.65, 30.09, 24.77, 45.48, 56.02, 51.52])

# Stack the data manually to compute the boundaries
bottom = np.zeros_like(min_time)
top1 = min_time
top2 = extraction_time

# Create figure and axis
fig, ax1 = plt.subplots(figsize=(10, 6))

# Plot stacked filled areas with transparency
ax1.fill_between(K, bottom, top1, color='#ff6666', alpha=0.3, label="Minimization")
ax1.fill_between(K, top1, top2, color='#6a408d', alpha=0.3, label="Total")

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
ax2.set_xlabel(r'$\mathcal{D}_{min}$ Size', fontsize=label_fontsize)
ax2.tick_params(axis='x', labelsize=tick_fontsize)

# Align axes to origin
ax1.set_xlim(left=0)
ax1.set_ylim(bottom=0)
plt.subplots_adjust(right=0.98)

# Optional: Grid
ax1.grid(True, linestyle='--', alpha=0.3)

plt.tight_layout()
plt.savefig("k_expt_1.pdf", format="pdf", bbox_inches='tight')
plt.show()


#boated groups