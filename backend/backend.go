package main

import "C"

import (
	"bufio"
	"encoding/json"
	"fmt"
	"log"
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
		log.Printf("Already Started")
		return
	}
	inited = true
	log.Println("Hello, Backend Server")

	// config service
	c = config.NewConfigService()

	// database service
	db = database.NewDatabaseService(c)
	db.Init()

	// task repo
	taskRepo = taskrepo.NewTaskRepo(db)
	photoRepo = photorepo.NewPhotoRepo(db)

	// server
	ss = server.NewRESTServer(c, taskRepo, photoRepo)
	go ss.Start()
}

//export Backend_Stop
func Backend_Stop() {
	log.Println("Closing Backend Service")
	// server
	if ss != nil {
		ss.Stop()
		ss = nil
	}

	taskRepo = nil
	photoRepo = nil

	// database
	if db != nil {
		db.Close()
		db = nil
	}

	c = nil
	inited = false
	log.Println("Goodbye, Backend Server")
}

//export Backend_GetCurrentIP
func Backend_GetCurrentIP() *C.char {
	var ip = ss.GetCurrentIP()
	return C.CString(ip)
}

//export Backend_SetCurrentIP
func Backend_SetCurrentIP(ip *C.char) {
	ss.SetCurrentIP(C.GoString(ip))
}

//export Backend_GetAvailableIPs
func Backend_GetAvailableIPs() *C.char {
	var ipsMap = ss.GetServerIPs()
	var ipsBytes, err = json.Marshal(ipsMap)
	if err != nil {
		return C.CString("{}")
	}
	var ipsStr = string(ipsBytes)
	return C.CString(ipsStr)
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
