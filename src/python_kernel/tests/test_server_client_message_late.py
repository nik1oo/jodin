from .header import *


def test_server_client_message_late():
	print("[ test_server_client_message_late ]", flush=True)
	p = pexpect.popen_spawn.PopenSpawn("../../src/interpreter/tests/test_server_client_message_late" + EXTENSION)
	pipe = External_Pipe(r"test_server_client_message_late", "read", 1000)
	message = pipe.read_string()
	assert(message == "message")
	time.sleep(2)
	try: p.expect("done", timeout=5)
	except pexpect.TIMEOUT: raise Exception("Timed out!")

