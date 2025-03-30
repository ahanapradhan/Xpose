# Set terminal to PNG format for saving the output as an image
set terminal pngcairo size 400,500 enhanced font 'Arial,18'
set output 'stack_calls.png'

# Set title and labels
set xlabel "QID"
set ylabel "# Q_H Executions"

# Set grid for better readability
set grid

# Hide legend (key)
unset key

# Set box width and style for bars
set style data histograms
set style fill solid 1.0 border -1
set boxwidth 0.5 relative

# Set y-axis range and log scale
set yrange [0:*]
set logscale y
set format y "10^%T"

# Rotate x-axis labels
set xtics rotate by 45 offset 0,-1

# Define inline data block
$DATA << EOD
7   534
8   3180
9   789
10  700
EOD

# Plot from named data block
plot $DATA using 2:xtic(1) with boxes ls 1 notitle
