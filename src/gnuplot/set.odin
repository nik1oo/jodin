package gnuplot
import "core:fmt"
import "core:strings"
import "core:c/libc"
import "core:os"
import "core:math"
import "core:path/filepath"


Position:: union {
	[2]f32,
	[3]f32 }
@(private) position_aprint:: proc(position: Maybe(Position)) -> string {
	if position == nil do return ""
	switch v in position.(Position) {
	case [2]f32: return fmt.aprintf("%f,%f", v.x, v.y)
	case [3]f32: return fmt.aprintf("%f,%f,%f", v.x, v.y, v.z) }
	return "" }


@(private) tag_aprint:: proc(tag: Maybe(int)) -> string {
	if tag == nil do return ""
	return fmt.aprint(tag.(int)) }


Angles:: enum { Degrees, Radians }


new_canvas:: proc() -> (canvas: ^Canvas) {
	canvas = new(Canvas)
	canvas.sb = strings.builder_make_len_cap(0, 10_000)
	return new(Canvas) }


set_angles:: proc(canvas: ^Canvas, angles: Angles) {
	fmt.sbprintfln(&canvas.sb, "set angles %s", (angles == .Degrees) ? "degrees" : "radians") }


set_arrow:: proc(
		canvas: ^Canvas,
		tag: Maybe(int) = nil,
		from: Maybe(Position) = nil,
		to: Maybe(Position) = nil,
		rto: Maybe(Position) = nil) {
	fmt.sbprintfln(&canvas.sb, "set arrow %s %s %s %s",
		tag_aprint(tag),
		(from != nil) ? fmt.aprintf("from %s", position_aprint(from)) : "",
		(to != nil) ? fmt.aprintf("to %s", position_aprint(to)) : "",
		(rto != nil) ? fmt.aprintf("rto %s", position_aprint(rto)) : "") }


Border:: enum uint {
	Bottom,
	Left,
	Top,
	Right,
	Bottom_Left_Front,
	Bottom_Left_Back,
	Bottom_Right_Front,
	Bottom_Right_Back,
	Left_Vertical,
	Back_Vertical,
	Right_Vertical,
	Front_Vertical,
	Top_Left_Back,
	Top_Right_Back,
	Top_Left_Front,
	Top_Rgith_Front,
	Polar }


Color_Name:: enum {
	Antique_White,
	Aquamarine,
	Beige,
	Bisque,
	Black,
	Blue,
	Brown_4,
	Brown,
	Chartreuse,
	Coral,
	Cyan,
	Dark_Blue,
	Dark_Chartreuse,
	Dark_Cyan,
	Dark_Golden_Rod,
	Dark_Gray,
	Dark_Green,
	Dark_Khaki,
	Dark_Magenta,
	Dark_Olive_Green,
	Dark_Orange,
	Dark_Pink,
	Dark_Plum,
	Dark_Red,
	Dark_Salmon,
	Dark_Spring_Green,
	Dark_Turquoise,
	Dark_Violet,
	Dark_Yellow,
	Forest_Green,
	Golden_Rod,
	Gold,
	Gray_0,
	Gray_10,
	Gray_20,
	Gray_30,
	Gray_40,
	Gray_50,
	Gray_60,
	Gray_70,
	Gray_80,
	Gray_90,
	Gray_100,
	Gray,
	Green,
	Green_Yellow,
	Honeydew,
	Khaki_1,
	Khaki,
	Lemonchiffon,
	Light_Blue,
	Light_Coral,
	Light_Cyan,
	Light_Goldenrod,
	Light_Gray,
	Light_Green,
	Light_Magenta,
	Light_Pink,
	Light_Red,
	Light_Salmon,
	Light_Turquoise,
	Magenta,
	Medium_Blue,
	Medium_Purple_3,
	Midnight_Blue,
	Navy,
	Olive,
	Orange,
	Orange_Red_4,
	Orange_Red,
	Orchid_4,
	Orchid,
	Pink,
	Plum,
	Purple,
	Red,
	Royal_Blue,
	Salmon,
	Sandy_Brown,
	Sea_Green,
	Seagreen,
	Sienna_1,
	Sienna_4,
	Sky_Blue,
	Slate_Blue,
	Slate_Gray,
	Spring_Green,
	Steel_Blue,
	Tan_1,
	Turquoise,
	Violet,
	Web_Blue,
	Web_Green,
	White,
	Yellow_4,
	Yellow }
@(private) color_name_aprint:: proc(color_name: Color_Name) -> string {
	switch color_name {
	case .Antique_White:     return "antiquewhite"
	case .Aquamarine:        return "aquamarine"
	case .Beige:             return "beige"
	case .Bisque:            return "bisque"
	case .Black:             return "black"
	case .Blue:              return "blue"
	case .Brown_4:           return "brown4"
	case .Brown:             return "brown"
	case .Chartreuse:        return "chartreuse"
	case .Coral:             return "coral"
	case .Cyan:              return "cyan"
	case .Dark_Blue:         return "dark-blue"
	case .Dark_Chartreuse:   return "dark-chartreuse"
	case .Dark_Cyan:         return "dark-cyan"
	case .Dark_Golden_Rod:   return "dark-goldenrod"
	case .Dark_Gray:         return "dark-gray"
	case .Dark_Green:        return "dark-green"
	case .Dark_Khaki:        return "dark-khaki"
	case .Dark_Magenta:      return "dark-magenta"
	case .Dark_Olive_Green:  return "dark-olivegreen"
	case .Dark_Orange:       return "dark-orange"
	case .Dark_Pink:         return "dark-pink"
	case .Dark_Plum:         return "dark-plum"
	case .Dark_Red:          return "dark-red"
	case .Dark_Salmon:       return "dark-salmon"
	case .Dark_Spring_Green: return "dark-spring-green"
	case .Dark_Turquoise:    return "dark-turquoise"
	case .Dark_Violet:       return "dark-violet"
	case .Dark_Yellow:       return "dark-yellow"
	case .Forest_Green:      return "forest-green"
	case .Golden_Rod:        return "goldenrod"
	case .Gold:              return "gold"
	case .Gray_0:            return "gray0"
	case .Gray_10:           return "gray10"
	case .Gray_20:           return "gray20"
	case .Gray_30:           return "gray30"
	case .Gray_40:           return "gray40"
	case .Gray_50:           return "gray50"
	case .Gray_60:           return "gray60"
	case .Gray_70:           return "gray70"
	case .Gray_80:           return "gray80"
	case .Gray_90:           return "gray90"
	case .Gray_100:          return "gray100"
	case .Gray:              return "gray"
	case .Green:             return "green"
	case .Green_Yellow:      return "greenyellow"
	case .Honeydew:          return "honeydew"
	case .Khaki_1:           return "khaki1"
	case .Khaki:             return "khaki"
	case .Lemonchiffon:      return "lemonchiffon"
	case .Light_Blue:        return "light-blue"
	case .Light_Coral:       return "light-coral"
	case .Light_Cyan:        return "light-cyan"
	case .Light_Goldenrod:   return "light-goldenrod"
	case .Light_Gray:        return "light-gray"
	case .Light_Green:       return "light-green"
	case .Light_Magenta:     return "light-magenta"
	case .Light_Pink:        return "light-pink"
	case .Light_Red:         return "light-red"
	case .Light_Salmon:      return "light-salmon"
	case .Light_Turquoise:   return "light-turquoise"
	case .Magenta:           return "magenta"
	case .Medium_Blue:       return "medium-blue"
	case .Medium_Purple_3:   return "mediumpurple3"
	case .Midnight_Blue:     return "midnight-blue"
	case .Navy:              return "navy"
	case .Olive:             return "olive"
	case .Orange:            return "orange"
	case .Orange_Red_4:      return "orangered4"
	case .Orange_Red:        return "orange-red"
	case .Orchid_4:          return "orchid4"
	case .Orchid:            return "orchid"
	case .Pink:              return "pink"
	case .Plum:              return "plum"
	case .Purple:            return "purple"
	case .Red:               return "red"
	case .Royal_Blue:        return "royalblue"
	case .Salmon:            return "salmon"
	case .Sandy_Brown:       return "sandybrown"
	case .Sea_Green:         return "sea-green"
	case .Seagreen:          return "seagreen"
	case .Sienna_1:          return "sienna1"
	case .Sienna_4:          return "sienna4"
	case .Sky_Blue:          return "skyblue"
	case .Slate_Blue:        return "slateblue"
	case .Slate_Gray:        return "slategray"
	case .Spring_Green:      return "spring-green"
	case .Steel_Blue:        return "steelblue"
	case .Tan_1:             return "tan1"
	case .Turquoise:         return "turquoise"
	case .Violet:            return "violet"
	case .Web_Blue:          return "web-blue"
	case .Web_Green:         return "web-green"
	case .White:             return "white"
	case .Yellow_4:          return "yellow4"
	case .Yellow:            return "yellow" }
	return "" }

Color_Spec:: union {
	Color_Name,
	[3]f32,
	[4]f32 }


@(private) color_spec_aprint:: proc(colorspec: Color_Spec) -> string {
	switch v in colorspec {
	case Color_Name: return fmt.aprintf("rgb \"%s\"", color_name_aprint(v))
	case [3]f32: return fmt.aprintf("rgbcolor 0x%x%x", v.x, v.y, v.z)
	case [4]f32: return fmt.aprintf("rgbcolor 0x%x%x%x", v.w, v.x, v.y, v.z) }
	return "" }


Dash_Type:: union {
	uint,    // predefined dashtype invoked by number
	string } // string containing a combination of the characters dot (.) hyphen (-) underscore(_) and space


@(private) dash_type_aprint:: proc(dash_type: Dash_Type) -> string {
	switch v in dash_type {
	case uint: return fmt.aprintf("%d", v)
	case string: return fmt.aprintf("\"%s\"", v) }
	return "" }


set_border:: proc(
		canvas: ^Canvas,
		borders: bit_set[Border] = {},
		layer: enum{ Front, Back, Behind },
		line_style: uint = 1,
		line_type: uint = 1,
		line_width: f32 = 1,
		line_color: Color_Spec = .Black,
		dash_type: Dash_Type = 1) {
	integer: uint = 0
	for border in borders {
		switch border {
		case .Bottom:             integer += 1
		case .Left:               integer += 2
		case .Top:                integer += 4
		case .Right:              integer += 8
		case .Bottom_Left_Front:  integer += 1
		case .Bottom_Left_Back:   integer += 2
		case .Bottom_Right_Front: integer += 4
		case .Bottom_Right_Back:  integer += 8
		case .Left_Vertical:      integer += 16
		case .Back_Vertical:      integer += 32
		case .Right_Vertical:     integer += 64
		case .Front_Vertical:     integer += 128
		case .Top_Left_Back:      integer += 256
		case .Top_Right_Back:     integer += 512
		case .Top_Left_Front:     integer += 1024
		case .Top_Rgith_Front:    integer += 2048
		case .Polar:              integer += 4096 } }
	fmt.sbprintfln(&canvas.sb, "set border %d %s linestyle %d linetype %d linewidth %f linecolor %s dashtype",
		integer,
		(layer == .Front) ? "front" : (layer == .Back) ? "back" : "behind",
		line_style,
		line_type,
		line_width,
		color_spec_aprint(line_color),
		dash_type_aprint(dash_type)) }


set_boxwidth:: proc(
		canvas: ^Canvas,
		width: f32,
		scale: enum{ Absolute, Relative }) {
	fmt.sbprintfln(&canvas.sb, "set boxwidth %d %s",
		width,
		(scale == .Absolute) ? "absolute" : "relative") }


Square:: u8


set_boxdepth:: proc(
		canvas: ^Canvas,
		extent: union{ f32, Square }) {
	extent_string: string
	switch v in extent {
	case f32:    extent_string = fmt.aprintf("%f", v)
	case Square: extent_string = fmt.aprintf("\"square\"") }
	fmt.sbprintfln(&canvas.sb, "set boxdepth %s",
		extent_string) }


set_contour:: proc(
		canvas: ^Canvas,
		placement: enum{ Base, Surface, Both }) {
	fmt.sbprintfln(&canvas.sb, "set contour %s",
		(placement == .Base) ? "base" :
		(placement == .Surface) ? "surface" :
		"both") }


unset_contour:: proc(
		canvas: ^Canvas) {
	fmt.sbprintln(&canvas.sb, "unset contour") }


set_cornerpoles:: proc(
		canvas: ^Canvas) {
	fmt.sbprintln(&canvas.sb, "set cornerpoles") }


unset_cornerpoles:: proc(
		canvas: ^Canvas) {
	fmt.sbprintln(&canvas.sb, "unset cornerpoles") }


Bar_Size:: enum{
	Small,
	Large,
	Fullwidth }
End:: enum {
	Front,
	Back }


set_errorbars:: proc(
		canvas: ^Canvas,
		size: union{ Bar_Size, f32 },
		which: Maybe(End)) {
	size_string: string
	switch v in size {
	case Bar_Size: size_string = (v == .Small) ? "small" : (v == .Large) ? "large" : "fullwidth"
	case f32:      size_string = fmt.aprintf("%d", size) }
	fmt.sbprintfln(&canvas.sb, "set errorbars %s %s",
		size_string,
		(which == nil) ? "" : (which == .Front) ? "front" : "back") }


unset_errorbars:: proc(
		canvas: ^Canvas) {
	fmt.sbprintln(&canvas.sb, "unset errorbars") }


Axis:: enum {
	X,
	Y,
	XY,
	X2,
	Y2,
	Z,
	CB }
axis_string: [len(Axis)]string = {
	"x",
	"y",
	"xy",
	"x2",
	"y2",
	"z",
	"cb" }


set_format:: proc(
		canvas: ^Canvas,
		axes: Axis,
		format_string: string,
		kind: enum{ Numeric, Timedate, Geographic } = .Numeric) {
	fmt.sbprintfln(&canvas.sb, "set format %s \"%s\" %s",
		axis_string[axes],
		format_string,
		(kind == .Numeric) ? "numeric" : (kind == .Timedate) ? "timedate" : "geographic") }


set_grid:: proc(
		canvas: ^Canvas,
		xtics: Maybe(bool) = nil,
		ytics: Maybe(bool) = nil,
		ztics: Maybe(bool) = nil,
		x2tics: Maybe(bool) = nil,
		y2tics: Maybe(bool) = nil,
		rtics: Maybe(bool) = nil,
		cbtics: Maybe(bool) = nil,
		mxtics: Maybe(bool) = nil,
		mytics: Maybe(bool) = nil,
		mztics: Maybe(bool) = nil,
		mx2tics: Maybe(bool) = nil,
		my2tics: Maybe(bool) = nil,
		mrtics: Maybe(bool) = nil,
		mcbtics: Maybe(bool) = nil,
		polar: bool = false,
		spacing: f32 = math.PI / 6,
		layer: enum { Default, Front, Back } = .Default,
		vertical: bool = false) {
	fmt.sbprint(&canvas.sb, "set grid ")
	if xtics != nil do if xtics.(bool) { fmt.sbprint(&canvas.sb, "xtics ") } else do fmt.sbprint(&canvas.sb, "noxtics ")
	if ytics != nil do if ytics.(bool) { fmt.sbprint(&canvas.sb, "ytics ") } else do fmt.sbprint(&canvas.sb, "noytics ")
	if ztics != nil do if ztics.(bool) { fmt.sbprint(&canvas.sb, "ztics ") } else do fmt.sbprint(&canvas.sb, "noztics ")
	if x2tics != nil do if x2tics.(bool) { fmt.sbprint(&canvas.sb, "x2tics ") } else do fmt.sbprint(&canvas.sb, "nox2tics ")
	if y2tics != nil do if y2tics.(bool) { fmt.sbprint(&canvas.sb, "y2tics ") } else do fmt.sbprint(&canvas.sb, "noy2tics ")
	if rtics != nil do if rtics.(bool) { fmt.sbprint(&canvas.sb, "rtics ") } else do fmt.sbprint(&canvas.sb, "nortics ")
	if cbtics != nil do if cbtics.(bool) { fmt.sbprint(&canvas.sb, "cbtics ") } else do fmt.sbprint(&canvas.sb, "nocbtics ")
	if mxtics != nil do if mxtics.(bool) { fmt.sbprint(&canvas.sb, "mxtics ") } else do fmt.sbprint(&canvas.sb, "nomxtics ")
	if mytics != nil do if mytics.(bool) { fmt.sbprint(&canvas.sb, "mytics ") } else do fmt.sbprint(&canvas.sb, "nomytics ")
	if mztics != nil do if mztics.(bool) { fmt.sbprint(&canvas.sb, "mztics ") } else do fmt.sbprint(&canvas.sb, "nomztics ")
	if mx2tics != nil do if mx2tics.(bool) { fmt.sbprint(&canvas.sb, "mx2tics ") } else do fmt.sbprint(&canvas.sb, "nomx2tics ")
	if my2tics != nil do if my2tics.(bool) { fmt.sbprint(&canvas.sb, "my2tics ") } else do fmt.sbprint(&canvas.sb, "nomy2tics ")
	if mrtics != nil do if mrtics.(bool) { fmt.sbprint(&canvas.sb, "mrtics ") } else do fmt.sbprint(&canvas.sb, "nomrtics ")
	if mcbtics != nil do if mcbtics.(bool) { fmt.sbprint(&canvas.sb, "mcbtics ") } else do fmt.sbprint(&canvas.sb, "nomcbtics ")
	if polar do fmt.sbprintf(&canvas.sb, "polar %f ", spacing)
	fmt.sbprintf(&canvas.sb, "layer %f ", (layer == .Default) ? "default" : (layer == .Front) ? "front" : "back")
	fmt.sbprintf(&canvas.sb, "%s ", vertical ? "vertical" : "novertical")
	fmt.sbprintln(&canvas.sb) }


unset_grid:: proc(
		canvas: ^Canvas) {
	fmt.sbprintln(&canvas.sb, "unset grid") }


set_isosamples:: proc(
		canvas: ^Canvas,
		iso: union{ int, [2]int }) {
	iso_string: string
	switch v in iso {
	case int: iso_string = fmt.aprintf("%d, %d", v, v)
	case [2]int: iso_string = fmt.aprintf("%d, %d", v.x, v.y) }
	fmt.sbprintfln(&canvas.sb, "set isosamples %s",
		iso_string) }


set_isosurface:: proc(
		canvas: ^Canvas,
		shape: enum{ Mixed, Triangles } = .Triangles) {
	fmt.sbprintfln(&canvas.sb, "set isosurface %s",
		(shape == .Mixed) ? "mixed" : "triangles") }


set_output:: proc(
		canvas: ^Canvas,
		file_name: string) {
	switch filepath.ext(file_name) {
	case ".png", ".jpg", ".jpeg", ".gif":
	case: return }
	fmt.sbprintfln(&canvas.sb, "set output \"%s\"",
		file_name) }


set_size:: proc(
		canvas: ^Canvas,
		size: [2]int) {
	fmt.sbprintfln(&canvas.sb, "set size %d,%d",
		size.x, size.y) }

