#+private
package jodin
import "base:runtime"
import "core:reflect"
import "core:fmt"
import "core:dynlib"
import "core:strings"
import "core:os"
import "core:c/libc"
import "core:odin/parser"
import "core:odin/tokenizer"
import "core:odin/ast"
import "core:path/filepath"
import "core:log"
import "core:io"
import "core:slice"
import "core:time"
import "core:sys/posix"
import "core:sys/windows"
import "core:unicode/utf16"
import "core:bytes"
import "core:thread"


NL::                     "\n"
NULL::                   "\x00"
EOT::                    "\x03"
HASH_SEED::              281091900
ANSI_RED::               "\e[2;31m"
ANSI_GREEN::             "\e[2;32m"
ANSI_YELLOW::            "\e[2;33m"
ANSI_BLUE::              "\e[2;34m"
ANSI_PURPLE::            "\e[2;35m"
ANSI_CYAN::              "\e[2;36m"
ANSI_UNDERLINED_BLACK::  "\e[4;30m"
ANSI_UNDERLINED_RED::    "\e[4;31m"
ANSI_UNDERLINED_GREEN::  "\e[4;32m"
ANSI_UNDERLINED_YELLOW:: "\e[4;33m"
ANSI_UNDERLINED_BLUE::   "\e[4;34m"
ANSI_UNDERLINED_PURPLE:: "\e[4;35m"
ANSI_UNDERLINED_CYAN::   "\e[4;36m"
ANSI_UNDERLINED_WHITE::  "\e[4;37m"
ANSI_BOLD_BLACK::        "\e[1;30m"
ANSI_BOLD_RED::          "\e[1;31m"
ANSI_BOLD_GREEN::        "\e[1;32m"
ANSI_BOLD_YELLOW::       "\e[1;33m"
ANSI_BOLD_BLUE::         "\e[1;34m"
ANSI_BOLD_PURPLE::       "\e[1;35m"
ANSI_BOLD_CYAN::         "\e[1;36m"
ANSI_BOLD_WHITE::        "\e[1;37m"
ANSI_RESET::             "\e[0m"


open_or_make:: proc(dir: string) -> (os.Handle, os.Errno) {
	if ! os.exists(dir) {
		handle, errno := os.open(dir, os.O_CREATE, 0o777)
		assert(errno == os.ERROR_NONE)
		os.close(handle) }
	return os.open(dir, os.O_RDWR) }


windows_get_last_error:: proc() -> windows.System_Error {
	return auto_cast windows.GetLastError() }


get_temp_directory:: proc() -> string {
	return filepath.join({os.get_current_directory(), "temp"}) }


clear_directory:: proc(path: string) -> (err: Error) {
	if ! os.exists(path) do return NOERR
	if ! os.is_dir(path) do return os.remove(path)
	handle: os.Handle
	handle, err = os.open(path)
	if err != NOERR do return err
	fi: []os.File_Info
	fi, err = os.read_dir(handle, 100)
	for f in fi do clear_directory(f.fullpath)
	err = os.remove_directory(path)
	if err != NOERR do return err
	return NOERR }


time_string:: proc() -> string {
	output, was_allocation: = strings.replace(time.time_to_string_hms(time.now(), make([]u8, 8)), ":", "_", 3)
	return output }


slice_contains_cell:: proc(cells: []^Cell, cell: ^Cell) -> bool {
	for other_cell in cells do if other_cell.frontend_cell_id == cell.frontend_cell_id do return true
	return false }


string_or_newline:: proc(str: string) -> string {
	if str != "" do return str
	else do return "\n" }


in_range:: proc(x, a, b: int) -> bool { return (x >= a) && (x < b) }


string_is_corrupt:: proc(str: string) -> bool {
	return strings.contains_rune(str, '\x00') }


string_builder_is_corrupt:: proc(sb: strings.Builder) -> bool {
	return string_is_corrupt(strings.to_string(sb)) }

