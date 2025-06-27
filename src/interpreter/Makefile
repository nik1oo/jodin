

JODIN_FOLDER := "$(shell odin root)shared\jodin"
JODIN_EXE := "$(shell odin root)shared\jodin\jodin.exe"

main:
	rm -rf $(JODIN_FOLDER)
	cp -r ../interpreter $(JODIN_FOLDER)
	odin build . -out:../../jodin.exe -debug -max-error-count:8

test:
	odin build tests/test_server_client_connection -out:tests/test_server_client_connection.exe
	odin build tests/test_client_server_connection -out:tests/test_client_server_connection.exe
	odin build tests/test_client_server_message_early -out:tests/test_client_server_message_early.exe
	odin build tests/test_client_server_message_late -out:tests/test_client_server_message_late.exe
	odin build tests/test_server_client_message_early -out:tests/test_server_client_message_early.exe
	odin build tests/test_server_client_message_late -out:tests/test_server_client_message_late.exe

