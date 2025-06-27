#+feature dynamic-literals
package jodin
import "core:fmt"
import "core:image"
import "core:bytes"


Audio_Format:: enum u8 {
	AAC,
	MP3,
	WAV,
	WEBM }
@(rodata) @(private) AUDIO_MIME_TYPES:= [?]string{
	Audio_Format.AAC  = "audio/aac",
	Audio_Format.MP3  = "audio/mpeg",
	Audio_Format.WAV  = "audio/wav",
	Audio_Format.WEBM = "audio/webm" }
// HANDLED //
display_audio:: proc(data: []u8, format: Audio_Format, element_id: string = "", loc: = #caller_location) -> (err: Error) {
	if data == nil do return error_handler(General_Error.Data_Empty, "Data is nil.")
	if format > .WEBM do return error_handler(General_Error.Invalid_Format, "Invalid audio format.")
	return display_data(data, AUDIO_MIME_TYPES[format], 0, 0, display_id = element_id) }


Image_Format:: enum u8 {
	PNG,
	JPEG,
	GIF,
	WEBP }
@(rodata) @(private) IMAGE_MIME_TYPES:= [?]string{
	Image_Format.PNG  = "image/png",
	Image_Format.JPEG = "image/jpeg",
	Image_Format.GIF  = "image/gif",
	Image_Format.WEBP = "image/webp" }
// HANDLED //
display_image:: proc(data: []u8, format: Image_Format, width: uint, height: uint, display_id: string = "", loc: = #caller_location) -> (err: Error) {
	if data == nil do return error_handler(General_Error.Data_Empty, "Data is nil.")
	if format > .WEBP do return error_handler(General_Error.Invalid_Format, "Invalid image format.")
	if width == 0 || height == 0 do return error_handler(General_Error.Invalid_Argument, "Invalid image dimensions")
	return display_data(data, IMAGE_MIME_TYPES[format], auto_cast width, auto_cast height, display_id = display_id) }

