set terminal pngcairo size 600,400
set output "plot.png"
set arrow  from 0.000,0.000 to 1.000,2.000 
plot sin(x) 