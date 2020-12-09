package main

import "C"

import (
	"fmt"
	"storyboard/backend/config"
	"storyboard/backend/database"
	"storyboard/backend/interfaces"
	"storyboard/backend/server"
	"storyboard/backend/taskrepo"
)

var inited bool = false
var c interfaces.ConfigService
var db interfaces.DatabaseService
var taskRepo interfaces.TaskRepo
var ss interfaces.RESTService

//export Backend_Start
func Backend_Start() {
	if inited {
		fmt.Printf("Already Started")
		return
	}
	inited = true
	fmt.Println("Hello, Backend Server")

	// config service
	c = config.NewConfigService()

	// database service
	db = database.NewDatabaseService(c)
	db.Init()

	// task repo
	taskRepo = taskrepo.NewTaskRepo(db)

	// server
	ss = server.NewRESTServer(taskRepo)
	go ss.Start()
}

//export Backend_Stop
func Backend_Stop() {
	fmt.Println("Goodbye, Backend Server")

	// server
	ss.Stop()

	// database
	db.Close()

	ss = nil
	taskRepo = nil
	db = nil
	c = nil
	inited = false
}

func main() {
	Backend_Start()
	for true {
	}
}
