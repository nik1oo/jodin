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
	if data == nil do return error_handler(General_Error.Data_Empty, "Data is nil.")
	if format > .WEBM do return error_handler(General_Error.Invalid_Format, "Invalid audio format.")
	return display_data(data, AUDIO_MIME_TYPES[format], 0, 0, display_id = element_id) }


Image_Format:: enum u8 { PNG, JPEG, GIF, WEBP }
@(private) @(rodata) IMAGE_MIME_TYPES:= [?]string{
	Image_Format.PNG  = "image/png",
	Image_Format.JPEG = "image/jpeg",
	Image_Format.GIF  = "image/gif",
	Image_Format.WEBP = "image/webp" }


display_image:: proc{ display_image_from_raw_data, display_image_from_filepath }
display_image_from_raw_data:: proc(data: []u8, format: Image_Format, size: [2]uint, display_id: string = "", loc: = #caller_location) -> (err: Error) {
	if data == nil do return error_handler(General_Error.Data_Empty, "Data is nil.")
	if format > .WEBP do return error_handler(General_Error.Invalid_Format, "Invalid image format.")
	if size.x == 0 || size.y == 0 do return error_handler(General_Error.Invalid_Argument, "Invalid image dimensions")
	return display_data(data, IMAGE_MIME_TYPES[format], auto_cast size.x, auto_cast size.y, display_id = display_id) }


display_image_from_filepath:: proc(path: string, display_id: string = "", loc: = #caller_location) -> (err: Error) {
	switch filepath.ext(path) {
		case ".png":
			data, _: = os.read_entire_file_from_filename_or_err(path)
			im: ^image.Image
			im, err = png.load_from_bytes(data, image.Options{.return_metadata, .do_not_decompress_image})
			// if err != NOERR do return err
			return display_image_from_raw_data(data, Image_Format.PNG, [2]uint{cast(uint)im.width, cast(uint)im.height}, display_id, loc)
		case ".jpg", ".jpeg":
			data, _: = os.read_entire_file_from_filename_or_err(path)
			im: ^image.Image
			im, err = jpeg.load_from_bytes(data, image.Options{.return_metadata, .do_not_decompress_image})
			fmt.eprintln(im.width, im.height)
			// if err != NOERR do return err
			return display_image_from_raw_data(data, Image_Format.JPEG, [2]uint{cast(uint)im.width, cast(uint)im.height}, display_id, loc)
		case: return General_Error.Invalid_Format } }

