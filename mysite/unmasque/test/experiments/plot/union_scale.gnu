# Set output to EPS
set terminal postscript eps enhanced color font 'Helvetica,28'
set output '../figs/polynomial_fit.eps'

# Set titles and labels
set xlabel "|AuxTables(Q_H)|" font 'Helvetica,42'
set ylabel "# Q_H invocations" font 'Helvetica,42'
set y2label "Time (s)" font 'Helvetica,42'
set y2tics
set key top left
set grid
set yrange [-100:500]
set y2range [-40: 400]

set y2tics 100
set ytics 0, 100

set ytics textcolor rgb "blue" # Color left y-axis tics blue
set y2tics textcolor rgb "red" # Color right y-axis tics red

# Define data file
datafile = "../data/tpcds_union_fpt.dat"

# Plot
plot \
    datafile using 1:5 with linespoints lw 5 lt rgb "blue" pointsize 2 title "#Q_H Calls", \
    datafile using 1:6 axes x1y2 with linespoints pointsize 1.5 lw 5 lt rgb "red" title "Time(s)"
