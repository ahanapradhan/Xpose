# Set EPS output
set terminal postscript eps enhanced color font 'Helvetica,32'

set output '../figs/aoa_fit_plot.eps'

set size ratio 1.2
# Axis and title settings
set xlabel "# inequality predicates in Q_H" font 'Helvetica,42'
set ylabel "# Q_H invocations" font 'Helvetica,42'
set y2label "Time (s)" font 'Helvetica,42'
set y2tics
set ytics nomirror
set grid
set ytics 2000

# Define cubic fits
f_y1(x) = 7.7595*x**3 - 88.2442*x**2 + 934.3902*x - 662.9
f_y2(x) = 0.0995*x**3 - 1.2698*x**2 + 14.7822*x - 11.5

# Plot data and fits
plot \
    '../data/aoa_scale.dat' using 1:2 with linesp pointsize 1.5 lw 5 lt rgb "blue" title "calls to Q_H", \
    '../data/aoa_scale.dat' using 1:3 axes x1y2 with linesp pointsize 1.5 lw 5 lt rgb "red" title "Time(s)", \

