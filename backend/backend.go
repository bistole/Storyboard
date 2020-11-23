package backend

import (
	"Storyboard/backend/server"
	"fmt"
)

// Start to create a standalone RESTful API server
func Start() error {
	fmt.Println("Hello, Hover")

	err := server.Server()
	return err
}
