import matplotlib.pyplot as plt

# Single font size variable
label_fontsize = 18

# H1 dataset
predicates1 = [1, 2, 3, 4]
running_time1 = [28.022, 28.256, 29.34, 31.77]
min_time1 = [3.162, 3.186, 3.18, 3.19]

# H2 dataset
predicates2 = [1, 2, 3, 4]
running_time2 = [37.33, 40.85, 42.52, 43.63]
min_time2 = [3.79, 4.07, 4.67, 4.84]

# Plot and annotate first dataset
line1, = plt.plot(predicates1, running_time1, marker='o', color='blue')
plt.annotate("H1 - Total",
             (predicates1[-1] - 0.1, running_time1[-1]),  # shift left
             fontsize=label_fontsize, va='bottom',
             ha='right', color=line1.get_color())

line2, = plt.plot(predicates1, min_time1, marker='s', color='purple')
plt.annotate("H1 - Minimization",
             (predicates2[-1] - 1.5, min_time2[-1]),
             fontsize=label_fontsize, va='bottom',
             ha='right', color=line2.get_color())

# Plot and annotate second dataset
line3, = plt.plot(predicates2, running_time2, marker='^', color='tomato')
plt.annotate("H2 - Total",
             (predicates2[-1] - 0.1, running_time2[-1]),
             fontsize=label_fontsize, va='bottom',
             ha='right', color=line3.get_color())

line4, = plt.plot(predicates2, min_time2, marker='d',color='red')
plt.annotate("H2 - Minimization",
             (predicates2[-1] - 0.1, min_time2[-1]),
             fontsize=label_fontsize, va='bottom',
             ha='right', color=line4.get_color())

# Labels and ticks
plt.xlabel('# Predicates', fontsize=label_fontsize)
plt.ylabel('Time (s)', fontsize=label_fontsize)

# Force x-axis ticks to be integers 1 unit apart
max_predicates = max(max(predicates1), max(predicates2))
plt.xticks(range(1, max_predicates + 1), fontsize=label_fontsize)

plt.yticks(fontsize=label_fontsize)
plt.grid(True)

# Save and show
plt.tight_layout()
plt.savefig("complexity_expt.pdf", format="pdf", bbox_inches='tight')
plt.show()
