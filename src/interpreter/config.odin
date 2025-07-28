package jodin
import "core:fmt"
import "core:os"
import "core:os/os2"
import "core:encoding/ini"


Config:: struct {
	python_path: string,
	poetry_path: string,
	notebooks_path: string }
config: Config


load_config:: proc() {
	if os.exists("config.ini") do load_existing_config()
	else do load_default_config()
	// print_config()
	}


load_existing_config:: proc() {
	load_default_config()
	ini_map, err, ok: = ini.load_map_from_path("config.ini", context.allocator)
	for section, kv_pair in ini_map do switch section {
	case `paths`: for key, value in kv_pair do switch key {
		case `python_path`: config.python_path = value
		case `poetry_path`: config.poetry_path = value
		case `notebooks_path`: config.notebooks_path = value } } }


load_default_config:: proc() {
	// fmt.aprintf(`"%s"`, notebooks_path)
	config.python_path = `python`
	config.poetry_path = `poetry`
	config.notebooks_path, _ = os2.user_home_dir(context.allocator) }


print_config:: proc() {
	fmt.println(JODIN_LOG_PREFIX, "Python path: ", config.python_path, sep="")
	fmt.println(JODIN_LOG_PREFIX, "Poetry path: ", config.poetry_path, sep="")
	fmt.println(JODIN_LOG_PREFIX, "Notebooks path: ", config.notebooks_path, sep="") }

