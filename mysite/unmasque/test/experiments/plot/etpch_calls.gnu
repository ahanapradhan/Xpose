# Set terminal to PNG format for saving the output as an image
set terminal pngcairo size 800,320 enhanced font 'Arial,18'
set output '../figs/etpch_calls_plot.png'

# Set title and labels
set xlabel "QID" offset 0, 0.5
set ylabel "# Q_H Executions\n(Log Scale)" font ", 16"

# Set grid for better readability
set grid
# Set legend (key) in the top-left corner
unset key

# Set box width and style for bars with gaps (set boxwidth to a value less than 1)
set style data histograms
set style fill solid 1.0 border -1
set boxwidth 0.8 relative  # Use 0.8 relative to default, creating space between bars

# Set y-axis range to start from 0
set yrange [1:*]
set logscale y
set format y "^%T"
set xtics rotate by 90 font ", 12" offset 0, -0.75

plot '-' using 3:xtic(2) notitle with boxes ls 1

# Data to plot
1   2	331
2   7	9700
3   8	450
4  11	200
5  12	1397
6  13	166
7  15	500
8  16	700
9  17	651
10  18	850
11  20	450
12  21  500
13  22	36000
14  e1   852
15   e3	1916
16   e4	1266
17   e5	1686
18   e6	589
19   e7	19390
20  e9   466
21  e10  746
22  e12	2784
23  e14  400
24  e15	990
25  e23  500
26  e24  900
