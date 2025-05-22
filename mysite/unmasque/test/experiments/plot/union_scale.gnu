# Set output to EPS
set terminal postscript eps enhanced color font 'Helvetica,24'
set output '../figs/polynomial_fit.eps'

# Set titles and labels
set xlabel "|AuxTables(Q_H)|"
set ylabel "Number of Q_H invocations"
set key left top
set grid
set yrange [-100:*]

# Define data file
datafile = "../data/tpcds_union_fpt.dat"

# Plot
plot \
    datafile using 1:3 with linespoints lt rgb "red" pointsize 2 title "Worst case",\
    datafile using 1:2 with linespoints lt rgb "blue" pointsize 2 title "runtime (2 unions)", \
    datafile using 1:4 with linespoints lt rgb "dark-violet" pointsize 2 title "runtime (increasing unions)"
