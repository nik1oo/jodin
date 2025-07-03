#+feature dynamic-literals
package jodin
import "core:os"
import "core:fmt"
import "core:path/filepath"
import "core:image"
import "core:image/png"
import "core:bytes"
import "jpeg"


Audio_Format:: enum u8 { AAC, MP3, WAV, WEBM }
@(private) @(rodata) AUDIO_MIME_TYPES:= [?]string{
	Audio_Format.AAC  = "audio/aac",
	Audio_Format.MP3  = "audio/mpeg",
	Audio_Format.WAV  = "audio/wav",
	Audio_Format.WEBM = "audio/webm" }


display_audio:: proc(data: []u8, format: Audio_Format, element_id: string = "", loc: = #caller_location) -> (err: Error) {
	if data == nil do return General_Error.Data_Empty
	if format > .WEBM do return General_Error.Invalid_Format
	return display_data(data, AUDIO_MIME_TYPES[format], 0, 0, display_id = element_id) }


Image_Format:: enum u8 { PNG, JPEG, GIF, WEBP }
@(private) @(rodata) IMAGE_MIME_TYPES:= [?]string{
	Image_Format.PNG  = "image/png",
	Image_Format.JPEG = "image/jpeg",
	Image_Format.GIF  = "image/gif",
	Image_Format.WEBP = "image/webp" }


display_image:: proc{ display_image_from_data_and_format_and_size, display_image_from_data_and_format, display_image_from_filepath, display_image_from_filepath_and_size }
display_image_from_data_and_format_and_size:: proc(data: []u8, format: Image_Format, size: [2]uint, display_id: string = "", loc: = #caller_location) -> (err: Error) {
	if data == nil do return General_Error.Data_Empty
	if format > .WEBP do return General_Error.Invalid_Format
	if size.x == 0 || size.y == 0 do return General_Error.Invalid_Argument
	return display_data(data, IMAGE_MIME_TYPES[format], auto_cast size.x, auto_cast size.y, display_id = display_id) }


display_image_from_data_and_format:: proc(data: []u8, format: Image_Format, display_id: string = "", loc: = #caller_location) -> (err: Error) {
	#partial switch format {
		case .PNG:
			im: ^image.Image
			im, err = png.load_from_bytes(data, image.Options{.return_metadata, .do_not_decompress_image})
			return display_image_from_data_and_format_and_size(data, Image_Format.PNG, [2]uint{cast(uint)im.width, cast(uint)im.height}, display_id, loc)
		case .JPEG:
			im: ^image.Image
			im, err = jpeg.load_from_bytes(data, image.Options{.return_metadata, .do_not_decompress_image})
			return display_image_from_data_and_format_and_size(data, Image_Format.JPEG, [2]uint{cast(uint)im.width, cast(uint)im.height}, display_id, loc)
		case: return General_Error.Invalid_Format } }


display_image_from_filepath_and_size:: proc(path: string, size: [2]uint, display_id: string = "", loc: = #caller_location) -> (err: Error) {
	data, _: = os.read_entire_file_from_filename_or_err(path)
	format: Image_Format
	switch filepath.ext(path) {
		case ".png": format = .PNG
		case ".jpg", ".jpeg": format = .JPEG
		case ".gif": format = .GIF
		case ".webp": format = .WEBP
		case: return General_Error.Invalid_Format }
	return display_image_from_data_and_format_and_size(data, format, size, display_id, loc) }


display_image_from_filepath:: proc(path: string, display_id: string = "", loc: = #caller_location) -> (err: Error) {
	switch filepath.ext(path) {
		case ".png":
			data, _: = os.read_entire_file_from_filename_or_err(path)
			im: ^image.Image
			im, err = png.load_from_bytes(data, image.Options{.return_metadata, .do_not_decompress_image})
			return display_image_from_data_and_format_and_size(data, Image_Format.PNG, [2]uint{cast(uint)im.width, cast(uint)im.height}, display_id, loc)
		case ".jpg", ".jpeg":
			data, _: = os.read_entire_file_from_filename_or_err(path)
			im: ^image.Image
			im, err = jpeg.load_from_bytes(data, image.Options{.return_metadata, .do_not_decompress_image})
			return display_image_from_data_and_format_and_size(data, Image_Format.JPEG, [2]uint{cast(uint)im.width, cast(uint)im.height}, display_id, loc)
		case: return General_Error.Invalid_Format } }

