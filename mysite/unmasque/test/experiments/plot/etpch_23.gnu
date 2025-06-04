
set terminal pngcairo size 850,350 enhanced font 'Arial,18'
set output '../figs/etpch_23.png'

set xlabel "QID" font ", 20" offset 0, 0.5
set ylabel "Extraction Time (Minutes)" font ", 18"
set key top center
set style data histogram
set style histogram rowstacked
set style fill solid border -1
set style fill pattern 4 border -1  # Set a texture for the first group
set boxwidth 0.5
set grid ytics

set xtics rotate by 90 font ", 12" offset 0, -0.75
set xtics nomirror
set ytics nomirror


# Define colors and styles
set style line 1 lc rgb "#8a2be2"  # FROM (Violet) - with texture
set style line 2 lc rgb "#ff7f0e"  # DB Minimization (Orange) - with texture
set style line 3 lc rgb "#2ca02c"  # XRE-others (Green) - with texture
set style line 4 lc rgb "#d62728"  # XFE-LLM (Red) - different texture
set style line 5 lc rgb "#FFD700"  # XFE-Comb (Yellow) - different texture

# Define inline data
$DATA << EOD
1   5   5    10  240   126  15.2    2
2   5   313  5   240  0     0   7
3   17  19.5 20  240  0     0   8
4  13  15   8   240  0 0   11
5  8.5 9.5  7   240  0 0   12
6  12  8    3   136  32    0   13
7  8   27   6   240  0 0   15
8  13  50   4   120  0 0   16
9  10  21   5   120  0 0   17
10  15  150  40  240  0 0   18
11  5   54   25  160  0 0   20
12  2   27   15  120  0 0   21
13  8   425  30  240  0 0   22
14   22  18   6   120   0    13  e1
15   36  24   20  240   0    1.3 e3
16   2   14   10  120   0    2.5 e4
17   2   50   30  120   0    2.5 e5
18   19  6    3   120   0    2   e6
19   10  726  10  240   0    4   e7
20  17  82   10  120   0    7   e9
21  15  41   6   120   0    2   e10
22  17  19   12  240   0    1.8 e12
23  17  37   7   240   0    1.9 e14
24  16  52   10  240   0    2   e15
25  11  69   30  120   0    2   e23
26  30  221  78  120   0    3.1 e24
EOD

# Plot the stacked bars
# Plot the stacked bars (Dividing values by 60 to convert seconds to minutes)
plot $DATA using (($2+$3+$4)/60):xtic(8) title "XRE" ls 1 with histogram fill pattern 25 , \
     '' using (($5+$6)/60) title "XFE" ls 2 with histogram fill pattern 2
