# Set terminal to PNG format for saving the output as an image
set terminal pngcairo size 800,320 enhanced font 'Arial,18'
set output 'etpch_calls_plot.png'

# Set title and labels
set xlabel "QID"
set ylabel "# Q_H Executions\n(Log Scale)" font ", 16"

# Set grid for better readability
set grid
# Set legend (key) in the top-left corner
unset key

# Set box width and style for bars with gaps (set boxwidth to a value less than 1)
set style data histograms
set style fill solid 1.0 border -1
set boxwidth 0.5 relative  # Use 0.8 relative to default, creating space between bars

# Set y-axis range to start from 0
set yrange [1:*]
set logscale y
set format y "^%T"
# Rotate x-axis labels by 45 degrees and offset them downward
set xtics rotate by -45

# Plot the data with red-colored bars
plot '-' using 2:xtic(1) title "Database Minimization"  with boxes ls 1

# Data to plot
1   852
2	331
3	1916
4	1266
5	1686
6	589
7	19390
8	450
9   466
10  746
11	390
12	2784
13	166
14  400
15	990
16	700
17	651
18	850
20	450
21  500
22	36000
23  500
24  900
