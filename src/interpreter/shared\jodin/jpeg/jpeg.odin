package jpeg
import "core:fmt"
import "core:image"
import "core:slice"
import "core:io"


SOF_Marker:: struct #packed {
	_:      u8,
	height: u16,
	width:  u16,
	_:      u8 }


load_from_bytes:: proc(data: []u8, options: image.Options = image.Options{}, allocator := context.allocator) -> (img: ^image.Image, err: image.Error) {
	if len(data) == 0 do return nil, io.Error.Unexpected_EOF
	sof_marker: SOF_Marker
	found: bool
	if ! (data[0] == 0xFF && data[1] == 0xD8) do return nil, image.General_Image_Error.Image_Does_Not_Adhere_to_Spec
	LOOP: for i: int = 2; i < len(data)-1; {
		tuple: = [2]u8{data[i], data[i+1]}
		switch tuple {
			case [2]u8{0xFF, 0xC0}:
				found = true
				sof_marker = (cast(^SOF_Marker)(&data[i+4]))^
				break LOOP
			case [2]u8{0xFF, 0xD8}, [2]u8{0xFF, 0xD9}:
				i += 2
			case:
				length: = 0b1<<8 * cast(int)(data[i+2]) + cast(int)(data[i+3])
				i += 2 + length } }
	if ! found do return nil, image.General_Image_Error.Image_Does_Not_Adhere_to_Spec
	img = new(image.Image)
	img.width = cast(int)transmute(u16be)sof_marker.width
	img.height = cast(int)transmute(u16be)sof_marker.height
	return img, nil }

