from .header import *


def test_server_client_message_early():
	print("[ test_server_client_message_early ]", flush=True)
	p = pexpect.popen_spawn.PopenSpawn("../../src/interpreter/tests/test_server_client_message_early.exe")
	pipe = External_Pipe(r"test_server_client_message_early", win32file.GENERIC_READ)
	time.sleep(2)
	message = pipe.read_string()
	assert(message == "message")
	time.sleep(2)
	try: p.expect("done", timeout=5)
	except pexpect.TIMEOUT: raise Exception("Timed out!")

