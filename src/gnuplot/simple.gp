#!/usr/local/bin/gnuplot -persist
set terminal pngcairo  transparent enhanced font "arial,10" fontscale 1.0 size 600, 400 background rgb "#FFFFFF"
set output 'simple.png'
unset parametric
set title "Simple Plots"
set title  font ",20" textcolor lt -1 norotate
set xrange [ * : * ] noreverse writeback
set x2range [ * : * ] noreverse writeback
set yrange [ * : * ] noreverse writeback
set y2range [ * : * ] noreverse writeback
set zrange [ * : * ] noreverse writeback
set cbrange [ * : * ] noreverse writeback
set rrange [ * : * ] noreverse writeback
set colorbox vertical origin screen 0.9, 0.2 size screen 0.05, 0.6 front  noinvert bdefault
NO_ANIMATION = 1
plot [-pi/2:pi] cos(x),-(sin(x) > sin(x+1) ? sin(x) : sin(x+1))
