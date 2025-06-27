from .header import *


def test_client_server_connection():
	print("[ test_client_server_connection ]", flush=True)
	p = pexpect.popen_spawn.PopenSpawn("../../src/interpreter/tests/test_client_server_connection.exe")
	write_pipe = External_Pipe(r"test_client_server_connection", win32file.GENERIC_WRITE)
	time.sleep(2)
	try: p.expect("done", timeout=2)
	except pexpect.TIMEOUT: raise Exception("Timed out!")

