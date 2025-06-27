

- `test_client_server_connection` -- If the pipe is initialized on the client-side seconds before it is initialized on the server-side, does the connection succeed?
- `test_server_client_connection` -- If the pipe is initialized on the server-side seconds before it is initialized on the client-side, does the connection succeed?
- `test_client_server_message_early` -- If the client sends a message to the server seconds before the server has started expecting the message, does the messaging succeed?
- `test_client_server_message_late` -- If the client sends a message to the server seconds after the server has started expecting hte message, does the messaging succeed?
- `test_server_client_message_early` -- If the server sends a message to the client seconds before the client has started expecting the message, does the messaging succeed?
- `test_server_client_message_late` -- If the server sends a message to the client seconds after the client has started expecting hte message, does the messaging succeed?

