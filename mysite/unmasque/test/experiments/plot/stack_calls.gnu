# Set terminal to PNG format for saving the output as an image
set terminal pngcairo size 500,400 enhanced font 'Arial,24'
set output 'stack_calls.png'

# Set title and labels
set xlabel "QID" font ", 24"
set ylabel "# Q_H Executions\n (Log Scale)" offset -2,0 font ", 24"

# Set grid for better readability
set grid

# Hide legend (key)
unset key

# Set box width and style for bars
set style data histograms
set style fill solid 1.0 border -1
set boxwidth 0.5 relative

# Set y-axis range and log scale
set yrange [1:*]
set logscale y
set format y "%T"

# Rotate x-axis labels
set xtics rotate by 45 offset 0,-0.5

# Define inline data block
$DATA << EOD
7   534
8   7935
9   3316
10  700
EOD

# Plot from named data block
plot $DATA using 2:xtic(1) with boxes ls 1 notitle
