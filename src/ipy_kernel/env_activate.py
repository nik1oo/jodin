import subprocess
import json
import os

# Run `poetry env info --path` to get the virtual environment path
result = subprocess.run(["poetry", "env", "info", "--path"], capture_output=True, text=True, check=True)
venv_path = result.stdout.strip()

# Construct the path to the Python interpreter
# On Windows, it's in Scripts/python.exe; on Unix-like systems, it's in bin/python
venv_python = os.path.join(venv_path, "Scripts" if os.name == "nt" else "bin", "python")

# Verify the Python interpreter exists
if not os.path.exists(venv_python):
    raise FileNotFoundError(f"Python interpreter not found at {venv_python}")

# Run a command or script in the virtual environment
subprocess.run([venv_python, "-c", "import sys; print(sys.version)"])