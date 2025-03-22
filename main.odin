package main

import "core:fmt"
import "core:mem"
import "core:net"
import "core:os"

main :: proc() {
	endpoint, ok := net.parse_endpoint("127.0.0.1:8888")
	if !ok {
		fmt.println("Parse error")
		os.exit(1)
	}

	socket, socket_err := net.listen_tcp(endpoint)
	if socket_err != nil {
		fmt.println("Socket listening error:", socket_err)
		os.exit(1)
	}
	defer net.close(socket)
	fmt.println("Listening on port", endpoint.port)

	for {
		defer mem.free_all(context.temp_allocator)

		client, source, accept_err := net.accept_tcp(socket)
		if accept_err != nil {
			fmt.println("Failed to accept tcp:", accept_err)
			continue
		}
		defer net.close(client)

		req_content := make([]u8, 2048, allocator = context.temp_allocator)
		bytes_read, receive_err := net.recv_tcp(client, req_content)
		if receive_err != nil {
			fmt.println("Receive error:", receive_err)
			continue
		}
		fmt.printf(
			"Connected: %v\nBytes Received: %d\nContent: %s\n",
			source,
			bytes_read,
			string(req_content),
		)

		res_content := make([dynamic]byte, 0, 1024)
		defer free(&res_content)
		append(&res_content, "temp content")

		bytes_sent, send_err := net.send_tcp(client, res_content[:])
		if send_err != nil {
			fmt.println("Send error:", send_err)
			continue
		}
		fmt.println("Sent", bytes_sent, "bytes")
	}
}
