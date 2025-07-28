package build
import "core:fmt"
import "core:os"
import "core:os/os2"
import "core:c/libc"
import "core:path/filepath"
import "core:strings"


// RElevant comamands:
//


main:: proc() {
	ccommand: cstring
	command: []string
	current_directory: = os.get_current_directory()

	make_command:: proc(text: string) -> []string {
		return strings.split(text, " ") }

	// ADD TO PATH //
	// add_to_path(current_directory)

	// COMPILE INTERPRETER //
	interpreter_directory: = filepath.join({current_directory, "src/interpreter"})
	ccommand = fmt.caprintf(`make -C "%s"`, interpreter_directory)
	libc.system(ccommand)

	// SET VENV DIRECTORY //
	os.make_directory(`./venv`)
	state, stdout, stderr, err: = os2.process_exec(
		{command={`poetry`, `--directory=./src/python_kernel`, `config`, `virtualenvs.path`, `../../venv`}},
		allocator=context.allocator)
	fmt.println(string(stdout), string(stderr))
	assert(err == nil)

	// INSTALL DEPENDENCIES //
	state, stdout, stderr, err = os2.process_exec(
		{command={`poetry`, `--directory=./src/python_kernel`, `install`, `--compile`}},
		allocator=context.allocator)
	fmt.println(string(stdout), string(stderr))
	assert(err == nil)

	// INSTALL KERNEL //
	state, stdout, stderr, err = os2.process_exec(
		{command={`poetry`, `--directory=./src/python_kernel`, `run`, `jupyter`, `kernelspec`, `install`, `./src/jodin`, `--name=jodin`}},
		allocator=context.allocator)
	fmt.println(string(stdout), string(stderr))
	assert(err == nil)

	// assert(1 == 2)

	// state, stdout, stderr, err = os2.process_exec(
	// 	desc=os2.Process_Desc{
	// 		command={`poetry`, `--directory=./src/python_kernel`, `env`, `activate`},
	// 		working_dir=current_directory },
	// 	allocator=context.allocator)

	// _, venv_path, _, _: = os2.process_exec(
	// 	desc=os2.Process_Desc{
	// 		command={`poetry`, `--directory=./src/python_kernel`, `env`, `info`, `-p`},
	// 		working_dir=current_directory },
	// 	allocator=context.allocator)
	// fmt.println("venv path:", string(venv_path))
	// python_path: string
	// python_path, err = os2.join_path({ strings.trim_right(string(venv_path), "\n\r"), "Scripts", "Python.exe" }, context.allocator)
	// python_path = fmt.aprintf(`"%s"`, python_path)
	// fmt.println(python_path)

	// state, stdout, stderr, err = os2.process_exec(
	// 	desc=os2.Process_Desc{
	// 		command={python_path, `print("wow")`},
	// 		working_dir=current_directory },
	// 	allocator=context.allocator)
	// fmt.println("python version:", state, string(stdout), string(stderr), err)



	// if err == nil {
	// 	venv: {
		// poetry`, `--directory=./src/python_kernel`, `env`, `activate

			// env_activate_command: = string(stdout)
			// status: = libc.system(fmt.caprint(`eval (poetry --directory=./src/python_kernel env activate)`))
			// status = libc.system(fmt.caprint(`Invoke-Expression (poetry --directory=./src/python_kernel env activate)`))
			// status = libc.system(fmt.caprint(`source (poetry --directory=./src/python_kernel env activate)`))
			// status = libc.system(fmt.caprint(`(poetry --directory=./src/python_kernel env activate)`))
			// status: = libc.system(fmt.caprintf(`call %s && poetry --directory=./src/python_kernel env info`, env_activate_command))
			// status: = libc.system(fmt.caprintf(`call %s && (poetry --directory=./src/python_kernel env info > lol.txt)`, env_activate_command))
			// fmt.println(status) } }

			// env_activate_command: = string(stdout)
			// status: = libc.system(fmt.caprintf(`eval %s`, env_activate_command))
			// status = libc.system(fmt.caprintf(`Invoke-Expression %s`, env_activate_command))
			// status = libc.system(fmt.caprintf(`source %s`, env_activate_command))
			// status = libc.system(fmt.caprintf(`%s`, env_activate_command))
			// fmt.println(status) } }

	// state, stdout, stderr, err = os2.process_exec(
	// 	desc=os2.Process_Desc{
	// 		command={`eval`, `(poetry --directory=./src/python_kernel env activate)`},
	// 		working_dir=current_directory },
	// 	allocator=context.allocator)
	// fmt.println(state, stdout, stderr, err)

	// state, stdout, stderr, err = os2.process_exec(
	// 	desc=os2.Process_Desc{
	// 		command={`Invoke-Expression`, `(poetry --directory=./src/python_kernel env activate)`},
	// 		working_dir=current_directory },
	// 	allocator=context.allocator)
	// fmt.println(state, stdout, stderr, err)

	// state, stdout, stderr, err = os2.process_exec(
	// 	desc=os2.Process_Desc{
	// 		command={`source`, `(poetry --directory=./src/python_kernel env activate)`},
	// 		working_dir=current_directory },
	// 	allocator=context.allocator)
	// fmt.println(state, stdout, stderr, err)

	// state, stdout, stderr, err = os2.process_exec(
	// 	desc=os2.Process_Desc{
	// 		command={`(poetry --directory=./src/python_kernel env activate)`},
	// 		working_dir=current_directory },
	// 	allocator=context.allocator)
	// fmt.println(state, stdout, stderr, err)

	// state, stdout, stderr, err = os2.process_exec(
	// 	desc=os2.Process_Desc{
	// 		command=command,
	// 		working_dir=current_directory },
	// 	allocator=context.allocator)
	// fmt.println(state, stdout, stderr, err)

	// command = { `PS1>`, `Invoke-Expression`, env_activate_command }
	// if err != nil {
	// 	state, stdout, stderr, err = os2.process_exec(
	// 		desc=os2.Process_Desc{
	// 			command=command,
	// 			working_dir=current_directory },
	// 		allocator=context.allocator)
	// 	fmt.println(state, stdout, stderr, err)
	// }
}



ACTIVATE:string:`
# This file must be used with "source bin/activate" *from bash*
# you cannot run it directly


if [ "${BASH_SOURCE-}" = "$0" ]; then
    echo "You must source this script: \$ source $0" >&2
    exit 33
fi

deactivate () {
    unset -f pydoc >/dev/null 2>&1 || true

    # reset old environment variables
    # ! [ -z ${VAR+_} ] returns true if VAR is declared at all
    if ! [ -z "${_OLD_VIRTUAL_PATH:+_}" ] ; then
        PATH="$_OLD_VIRTUAL_PATH"
        export PATH
        unset _OLD_VIRTUAL_PATH
    fi
    if ! [ -z "${_OLD_VIRTUAL_PYTHONHOME+_}" ] ; then
        PYTHONHOME="$_OLD_VIRTUAL_PYTHONHOME"
        export PYTHONHOME
        unset _OLD_VIRTUAL_PYTHONHOME
    fi

    # The hash command must be called to get it to forget past
    # commands. Without forgetting past commands the $PATH changes
    # we made may not be respected
    hash -r 2>/dev/null

    if ! [ -z "${_OLD_VIRTUAL_PS1+_}" ] ; then
        PS1="$_OLD_VIRTUAL_PS1"
        export PS1
        unset _OLD_VIRTUAL_PS1
    fi

    unset VIRTUAL_ENV
    unset VIRTUAL_ENV_PROMPT
    if [ ! "${1-}" = "nondestructive" ] ; then
    # Self destruct!
        unset -f deactivate
    fi
}

# unset irrelevant variables
deactivate nondestructive

VIRTUAL_ENV='C:\Users\Nikola Stefanov\AppData\Local\pypoetry\Cache\virtualenvs\jodin-JelGYP0r-py3.13'
if ([ "$OSTYPE" = "cygwin" ] || [ "$OSTYPE" = "msys" ]) && $(command -v cygpath &> /dev/null) ; then
    VIRTUAL_ENV=$(cygpath -u "$VIRTUAL_ENV")
fi
export VIRTUAL_ENV

_OLD_VIRTUAL_PATH="$PATH"
PATH="$VIRTUAL_ENV/"Scripts":$PATH"
export PATH

if [ "x"jodin-py3.13 != x ] ; then
    VIRTUAL_ENV_PROMPT=jodin-py3.13
else
    VIRTUAL_ENV_PROMPT=$(basename "$VIRTUAL_ENV")
fi
export VIRTUAL_ENV_PROMPT

# unset PYTHONHOME if set
if ! [ -z "${PYTHONHOME+_}" ] ; then
    _OLD_VIRTUAL_PYTHONHOME="$PYTHONHOME"
    unset PYTHONHOME
fi

if [ -z "${VIRTUAL_ENV_DISABLE_PROMPT-}" ] ; then
    _OLD_VIRTUAL_PS1="${PS1-}"
    PS1="(${VIRTUAL_ENV_PROMPT}) ${PS1-}"
    export PS1
fi

# Make sure to unalias pydoc if it's already there
alias pydoc 2>/dev/null >/dev/null && unalias pydoc || true

pydoc () {
    python -m pydoc "$@"
}

# The hash command must be called to get it to forget past
# commands. Without forgetting past commands the $PATH changes
# we made may not be respected
hash -r 2>/dev/null || true
`