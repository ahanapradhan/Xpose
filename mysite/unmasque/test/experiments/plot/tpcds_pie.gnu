reset
set terminal postscript eps enhanced color font 'Arial,18'
set output '../figs/piechart.eps'

# Data definition
# Format: label value color
$data << EOD
"XRE-correct"        17  "blue"
"XPOSE-correct"       9  "green"
"XPOSE-a-correct"     4  "orange"
"XPOSE-m-incorrect"   7  "purple"
"XPOSE-incorrect"     3  "red"
EOD

# Total sum
total = 0
do for [i=1:|$data|] {
    total = total + word($data[i], 2)
}

# Polar plot setup
set polar
set size square
unset key
unset border
unset tics

start = 0
do for [i=1:|$data|] {
    label = word($data[i], 1)
    value = word($data[i], 2)
    color = word($data[i], 3)
    angle = value / total * 2*pi
    set object i+100 polygon from 0,0 to cos(start),sin(start) \
        to cos(start+angle),sin(start+angle) to 0,0 fc rgb color fs solid 1.0 border -1
    # place label
    mid_angle = start + angle/2
    set label i sprintf("%s\n(%.1f%%)", label, value/total*100.0) \
        at 1.3*cos(mid_angle), 1.3*sin(mid_angle) center
    start = start + angle
}

# Draw circle to ensure full pie
set parametric
plot [t=0:2*pi] cos(t), sin(t) notitle lt -1
