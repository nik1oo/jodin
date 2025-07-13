package test
import "core:os"
import "core:fmt"
import "../jpeg"


main:: proc() {
	data, _: = os.read_entire_file_from_filename_or_err(`C:\Code\jodin\examples\jupyter.jpg`)
	fmt.println(len(data))
	im, err: = jpeg.load_from_bytes(data)
	fmt.println(im)
}
