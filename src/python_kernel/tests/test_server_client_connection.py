from .header import *


def test_server_client_connection():
	print("[ test_server_client_connection ]", flush=True)
	p = pexpect.popen_spawn.PopenSpawn("../../src/interpreter/tests/test_server_client_connection" + EXTENSION)
	time.sleep(2)
	write_pipe = External_Pipe(r"test_server_client_connection", "write", 1000)
	time.sleep(2)
	try: p.expect("done", timeout=5)
	except pexpect.TIMEOUT: raise Exception("Timed out!")

