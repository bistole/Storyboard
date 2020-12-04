package backend

import (
	"Storyboard/backend/server"
	"fmt"
)

// Start to create a standalone RESTful API server
func Start() {
	fmt.Println("Hello, Hover")
	go server.RestfulServer.Start()
}

// Stop standalone RESTful API server
func Stop() {
	fmt.Println("Goodbye, Hover")
	server.RestfulServer.Stop()
}
