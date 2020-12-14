package main

import "C"

import (
	"bufio"
	"fmt"
	"os"
	"storyboard/backend/config"
	"storyboard/backend/database"
	"storyboard/backend/interfaces"
	"storyboard/backend/photorepo"
	"storyboard/backend/server"
	"storyboard/backend/taskrepo"
)

var inited bool = false
var c interfaces.ConfigService
var db interfaces.DatabaseService
var taskRepo interfaces.TaskRepo
var photoRepo interfaces.PhotoRepo
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
	photoRepo = photorepo.NewPhotoRepo(db)

	// server
	ss = server.NewRESTServer(taskRepo, photoRepo)
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

func console() {
	reader := bufio.NewReader(os.Stdin)
	fmt.Println("Press 'q' and 'enter' to quit")
	for {
		input, _ := reader.ReadString('\n')
		if input[0] == 'q' {
			break
		}
	}
}

func main() {
	Backend_Start()
	console()
	Backend_Stop()
}
