package jodin
HELP_STRING:string:`
JODIN: Interactive/live programming environment for Odin.
Usage:
	jodin [subcommand] [options]
Subcommands:
	jupyter-console           Start JODIN with the Jupyter console front-end.
	jupyter-notebook          Start JODIN with the Jupyter notebook front-end.
	server                    Start the JODIN interpreter in server mode, allowing the JODIN kernel to connect to it.
	venv                      Start the Python virtual environment.
	help                      Print the help text.
	version                   Print version.
Options:
	-print-source-on-error    Print the source code of the cell in case of an error.
	-notebook-dir=<dir>      Set the working directory for notebooks.`[1:]