package gnuplot
import "core:fmt"
import "core:strings"
import "core:c/libc"
import "core:os"
import "core:math"


Canvas:: struct {
	sb: strings.Builder }


Style:: enum {
	Lines,
	Dots,
	Steps,
	Vectors,
	Y_Error_Lines,
	Points,
	Impulses,
	F_Steps,
	X_Error_Bar,
	XY_Error_Bars,
	Lines_Points,
	Labels,
	HI_Steps,
	X_Error_Lines,
	XY_Error_Lines,
	Finance_Bars,
	Surface,
	Arrows,
	Y_Error_Bar,
	Parallel_Axes,
	Boxes,
	Box_Plot,
	Ellipses,
	Histograms,
	RGB_Alpha,
	Box_Error_Bars,
	Candlesticks,
	Filled_Curves,
	Image,
	RGB_Image,
	Box_XY_Error,
	Circles,
	Fill_Steps,
	PM_3D,
	Polygons,
	Marks,
	Isosurface,
	Z_Error_Fill }


plot:: proc(
		canvas: ^Canvas,
		// iteration: _,
		// definition: Maybe(_),
		// sampling_range: Maybe(_),
		expression: Maybe(^Expression) = nil,
		data_file: Maybe(string) = nil,
		// data_source: Maybe(_),
		// keyentry: Maybe(_),
		// axes: Axis,
		// title_spec: _,
		style: Maybe(Style) = nil) {
	fmt.sbprint(&canvas.sb, "plot ")
	// pg. 132 //
	switch {
	// case definition != nil:
	case expression != nil:
		fmt.sbprintf(&canvas.sb, "%s ",
			expression_aprint(expression.(^Expression)))
	case data_file != nil:
		fmt.sbprintf(&canvas.sb, "\"%s\" ",
			data_file.(string))
	// case data_source != nil:
	}
	if style != nil {
		fmt.sbprint(&canvas.sb, "with ")
		_style: = style.(Style)
		switch style {
		case .Lines:          fmt.sbprint(&canvas.sb, "lines")
		case .Dots:           fmt.sbprint(&canvas.sb, "dots")
		case .Steps:          fmt.sbprint(&canvas.sb, "steps")
		case .Vectors:        fmt.sbprint(&canvas.sb, "vectors")
		case .Y_Error_Lines:  fmt.sbprint(&canvas.sb, "yerrorlines")
		case .Points:         fmt.sbprint(&canvas.sb, "points")
		case .Impulses:       fmt.sbprint(&canvas.sb, "impulses")
		case .F_Steps:        fmt.sbprint(&canvas.sb, "fsteps")
		case .X_Error_Bar:    fmt.sbprint(&canvas.sb, "xerrorbar")
		case .XY_Error_Bars:  fmt.sbprint(&canvas.sb, "xyerrorbars")
		case .Lines_Points:   fmt.sbprint(&canvas.sb, "linespoints")
		case .Labels:         fmt.sbprint(&canvas.sb, "labels")
		case .HI_Steps:       fmt.sbprint(&canvas.sb, "histeps")
		case .X_Error_Lines:  fmt.sbprint(&canvas.sb, "xerrorlines")
		case .XY_Error_Lines: fmt.sbprint(&canvas.sb, "xyerrorlines")
		case .Finance_Bars:   fmt.sbprint(&canvas.sb, "financebars")
		case .Surface:        fmt.sbprint(&canvas.sb, "surface")
		case .Arrows:         fmt.sbprint(&canvas.sb, "arrows")
		case .Y_Error_Bar:    fmt.sbprint(&canvas.sb, "yerrorbar")
		case .Parallel_Axes:  fmt.sbprint(&canvas.sb, "parallelaxes")
		case .Boxes:          fmt.sbprint(&canvas.sb, "boxes")
		case .Box_Plot:       fmt.sbprint(&canvas.sb, "boxplot")
		case .Ellipses:       fmt.sbprint(&canvas.sb, "ellipses")
		case .Histograms:     fmt.sbprint(&canvas.sb, "histograms")
		case .RGB_Alpha:      fmt.sbprint(&canvas.sb, "rgbalpha")
		case .Box_Error_Bars: fmt.sbprint(&canvas.sb, "boxerrorbars")
		case .Candlesticks:   fmt.sbprint(&canvas.sb, "candlesticks")
		case .Filled_Curves:  fmt.sbprint(&canvas.sb, "filledcurves")
		case .Image:          fmt.sbprint(&canvas.sb, "image")
		case .RGB_Image:      fmt.sbprint(&canvas.sb, "rgbimage")
		case .Box_XY_Error:   fmt.sbprint(&canvas.sb, "boxxyerror")
		case .Circles:        fmt.sbprint(&canvas.sb, "circles")
		case .Fill_Steps:     fmt.sbprint(&canvas.sb, "fillsteps")
		case .PM_3D:          fmt.sbprint(&canvas.sb, "pm3d")
		case .Polygons:       fmt.sbprint(&canvas.sb, "polygons")
		case .Marks:          fmt.sbprint(&canvas.sb, "marks")
		case .Isosurface:     fmt.sbprint(&canvas.sb, "isosurface")
		case .Z_Error_Fill:   fmt.sbprint(&canvas.sb, "zerrorfill") } } }


command:: proc(
		canvas: ^Canvas,
		command: string) {
	fmt.sbprint(&canvas.sb, command) }


render_canvas:: proc(canvas: ^Canvas) {
	text: = strings.to_string(canvas.sb)
	fmt.println(text)
	handle, err: = os.open("plot.gp", os.O_RDWR | os.O_CREATE)
	os.write_string(handle, text)
	command: = fmt.aprintfln("gnuplot -c plot.gp")
	os.remove("plot.gp")
	libc.system(strings.clone_to_cstring(command)) }

