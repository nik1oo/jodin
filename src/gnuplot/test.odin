package gnuplot
import "core:fmt"


main:: proc() {
	canvas: = new_canvas()
	set_size(canvas, {600, 400})
	set_output(canvas, "plot.png")
	set_arrow(canvas,
		from = [2]f32{0, 0},
		to = [2]f32{1, 2})
	plot(canvas,
		expression = sin("x"))
	render_canvas(canvas) }

