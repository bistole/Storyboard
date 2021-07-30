package main

import "C"

import (
	"bufio"
	"encoding/json"
	"fmt"
	"os"
	"storyboard/backend/config"
	"storyboard/backend/database"
	"storyboard/backend/interfaces"
	"storyboard/backend/noterepo"
	"storyboard/backend/photorepo"
	"storyboard/backend/server"
	"storyboard/backend/slog"
	"storyboard/backend/wrapper"
)

var inited bool = false
var c interfaces.ConfigService
var db interfaces.DatabaseService
var noteRepo interfaces.NoteRepo
var photoRepo interfaces.PhotoRepo
var ss interfaces.RESTService

//export Backend_Start
func Backend_Start(app *C.char) {
	if inited {
		slog.Printf("Already Started")
		return
	}
	inited = true
	slog.Println("Hello, Backend Server")

	// config service
	appStr := ""
	if app != nil {
		appStr = C.GoString(app)
	}
	slog.SetPath(appStr)
	c = config.NewConfigService(appStr)

	// database service
	db = database.NewDatabaseService(c)
	db.Init()

	// note & photo repo
	noteRepo = noterepo.NewNoteRepo(db)
	photoRepo = photorepo.NewPhotoRepo(db)

	// server
	httpProxy := *wrapper.NewHTTPWrapper()
	netProxy := *wrapper.NewNetWrapper()
	ss = server.NewRESTServer(netProxy, httpProxy, c, noteRepo, photoRepo)
	go ss.Start()
}

//export Backend_Stop
func Backend_Stop() {
	slog.Println("Closing Backend Service")
	// server
	if ss != nil {
		ss.Stop()
		ss = nil
	}

	noteRepo = nil
	photoRepo = nil

	// database
	if db != nil {
		db.Close()
		db = nil
	}

	c = nil
	inited = false
	slog.Println("Goodbye, Backend Server")
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

//export Backend_GetDataFolder
func Backend_GetDataFolder() *C.char {
	var folder = c.GetHomeDir()
	return C.CString(folder)
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

func getCurrentPwd() *C.char {
	dir, err := os.Getwd()
	if err != nil {
		panic("can not find current pwd")
	}
	var c = C.CString(dir)
	return c
}

func main() {
	var c = getCurrentPwd()
	Backend_Start(c)
	console()
	Backend_Stop()
}
