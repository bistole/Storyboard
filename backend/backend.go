package backend

import (
	"fmt"
	"storyboard/backend/config"
	"storyboard/backend/database"
	"storyboard/backend/interfaces"
	"storyboard/backend/server"
	"storyboard/backend/taskrepo"
)

// Backend implements
type Backend struct {
	init     bool
	c        interfaces.ConfigService
	db       interfaces.DatabaseService
	taskrepo interfaces.TaskRepo
	ss       interfaces.RESTService
}

// NewBackend create backend instance
func NewBackend() *Backend {
	return &Backend{init: false}
}

// Start to start backend server
func (b *Backend) Start() {
	if b.init {
		fmt.Printf("Already Started")
		return
	}
	fmt.Println("Hello, Backend Server")

	// config service
	b.c = config.NewConfigService()

	// database service
	b.db = database.NewDatabaseService(b.c)
	b.db.Init()

	// task repo
	b.taskrepo = taskrepo.NewTaskRepo(b.db)

	// server
	b.ss = server.NewRESTServer(b.taskrepo)
	go b.ss.Start()
}

// Stop standalone RESTful API server
func (b Backend) Stop() {
	fmt.Println("Goodbye, Backend Server")

	// server
	b.ss.Stop()

	// database
	b.db.Close()

	b.ss = nil
	b.taskrepo = nil
	b.db = nil
	b.c = nil
	b.init = false
}
