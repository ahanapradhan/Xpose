# Set output to EPS
set terminal postscript eps enhanced color font 'Helvetica,28'
set output '../figs/polynomial_fit.eps'

# Set titles and labels
set xlabel "|AuxTables(Q_H)|" font 'Helvetica,42'
set ylabel "# Q_H invocations" font 'Helvetica,42'
set key top left
set grid
set yrange [-100:1500]
set ytics 400

# Define data file
datafile = "../data/tpcds_union_fpt.dat"

# Plot
plot \
    datafile using 1:3 with linespoints lt rgb "red" pointsize 2 title "Power Set",\
    datafile using 1:2 with linespoints lt rgb "blue" pointsize 2 title "Fixed U", \
    datafile using 1:4 with linespoints lt rgb "dark-violet" pointsize 2 title "Growing U"
