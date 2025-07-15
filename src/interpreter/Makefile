
ifeq ($(OS),Windows_NT)
	JODIN_FOLDER := "$(shell odin root)shared\jodin"
	OUT_FILENAME := jodin.exe
	EXTENSION := .exe
else
	UNAME_S := $(shell uname -s)
	ifeq ($(UNAME_S),Linux)
		JODIN_FOLDER := "$(shell odin root)shared/jodin"
		OUT_FILENAME := jodin.out
		EXTENSION := .out
	endif
endif

main:
	echo $(shell odin root)
	rm -rf $(JODIN_FOLDER)
	cp -r ../interpreter $(JODIN_FOLDER)
	odin build . -out:../../$(OUT_FILENAME) -debug -max-error-count:8

test:
	odin build tests/test_server_client_connection -out:tests/test_server_client_connection$(EXTENSION)
	odin build tests/test_client_server_connection -out:tests/test_client_server_connection$(EXTENSION)
	odin build tests/test_client_server_message_early -out:tests/test_client_server_message_early$(EXTENSION)
	odin build tests/test_client_server_message_late -out:tests/test_client_server_message_late$(EXTENSION)
	odin build tests/test_server_client_message_early -out:tests/test_server_client_message_early$(EXTENSION)
	odin build tests/test_server_client_message_late -out:tests/test_server_client_message_late$(EXTENSION)

