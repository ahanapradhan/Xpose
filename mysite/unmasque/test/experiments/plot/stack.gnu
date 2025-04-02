
set terminal pngcairo size 600,400 enhanced font 'Arial,24'
set output 'stack_times.png'

set xlabel "QID" font ", 24" offset 0,0.7
set ylabel "Extraction Time\n (Minutes)" font ", 24"
set key font ",14"

set key top right
set style data histogram
set style histogram rowstacked
set style fill solid border -1
set style fill pattern 4 border -1  # Set a texture for the first group
set boxwidth 0.5
set grid ytics
set ytics 20

set xtics rotate by 45 offset 0,-0.5
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
7   1367  50
8   5520   100
9   2569  200
10  2400   100

EOD

# Plot the stacked bars
# Plot the stacked bars (Dividing values by 60 to convert seconds to minutes)
plot $DATA using ($2/60):xtic(1) title "XRE" ls 1 with histogram fill pattern 25, \
     '' using ($3/60) title "XFE" ls 2 with histogram fill pattern 2
