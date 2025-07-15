import pytest
import time
import subprocess
import platform
import pexpect
import pexpect.popen_spawn
from jodin.external_pipe import External_Pipe


if platform.system() == "Windows":
    EXTENSION = ".exe"
elif platform.system() == "Linux":
    EXTENSION = ".out"