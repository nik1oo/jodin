from .header import *


def test_client_server_message_late():
	print("[ test_client_server_message_late ]", flush=True)
	p = pexpect.popen_spawn.PopenSpawn("../../src/interpreter/tests/test_client_server_message_late" + EXTENSION)
	pipe = External_Pipe(r"test_client_server_message_late", "write", 1000)
	time.sleep(2)
	pipe.write_string("message")
	time.sleep(2)
	try: p.expect("done", timeout=5)
	except pexpect.TIMEOUT: raise Exception("Timed out!")

