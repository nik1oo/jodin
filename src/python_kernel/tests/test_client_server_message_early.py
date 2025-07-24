from .header import *


def test_client_server_message_early():
	print("[ test_client_server_message_early ]", flush=True)
	p = pexpect.popen_spawn.PopenSpawn("../../src/interpreter/tests/test_client_server_message_early" + EXTENSION)
	pipe = External_Pipe(r"test_client_server_message_early", "write", 1000)
	pipe.write_string("message")
	time.sleep(2)
	try: p.expect("done", timeout=5)
	except pexpect.TIMEOUT: raise Exception("Timed out!")

