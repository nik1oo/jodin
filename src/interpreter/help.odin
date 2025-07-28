package jodin
HELP_STRING:string:`
JODIN: Interactive/live programming environment for Odin.
Usage:
	jodin [subcommand] [options]
Subcommands:
	shell                     Start the interactive JODIN shell.
	jupyter-console           Start the Jupyter console with the JODIN kernel selected.
	jupyter-notebook          Start the Jupyter notebook.
	jupyter-server            Start the Jupyter server with the JODIN kernel.
	server                    Start the JODIN interpreter in server mode, allowing the JODIN kernel to connect to it.
	venv                      Start the Python virtual environment.
	help                      Print the help text.
	version                   Print version.
Options:
	-print-source-on-error    Print the source code of the cell in case of an error.
	-notebook-dir=<dir>      Set the working directory for notebooks.`[1:]