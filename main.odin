package main

import "core:fmt"
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
		client, source, accept_err := net.accept_tcp(socket)
		if accept_err != nil {
			fmt.println("Failed to accept tcp:", accept_err)
			continue
		}
		defer net.close(client)
		fmt.println("Connected:", source)
	}
}
