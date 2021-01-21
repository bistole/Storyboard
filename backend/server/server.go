package server

import (
	"context"
	"fmt"
	"log"
	"net/http"
	"storyboard/backend/interfaces"
	"sync"
	"time"

	"github.com/gorilla/mux"
)

// RESTServer is wrapper for http server and wait group
type RESTServer struct {
	Config    interfaces.ConfigService
	ServerIP  string
	Server    *http.Server
	Wg        *sync.WaitGroup
	TaskRepo  interfaces.TaskRepo
	PhotoRepo interfaces.PhotoRepo
}

// NewRESTServer create REST server
func NewRESTServer(config interfaces.ConfigService, taskRepo interfaces.TaskRepo, photoRepo interfaces.PhotoRepo) *RESTServer {
	var wg = &sync.WaitGroup{}
	return &RESTServer{
		Config:    config,
		ServerIP:  "",
		Server:    nil,
		Wg:        wg,
		TaskRepo:  taskRepo,
		PhotoRepo: photoRepo,
	}
}

func (rs RESTServer) route() *mux.Router {
	r := mux.NewRouter()
	r.HandleFunc("/ping", rs.Ping).Methods("GET")
	r.HandleFunc("/tasks", rs.GetTasks).Methods("GET")
	r.HandleFunc("/tasks", rs.CreateTask).Methods("POST")
	r.HandleFunc("/tasks/{id}", rs.GetTask).Methods("GET")
	r.HandleFunc("/tasks/{id}", rs.UpdateTask).Methods("POST")
	r.HandleFunc("/tasks/{id}", rs.DeleteTask).Methods("DELETE")
	r.HandleFunc("/photos", rs.GetPhotos).Methods("GET")
	r.HandleFunc("/photos", rs.UploadPhoto).Methods("POST")
	r.HandleFunc("/photos/{id}", rs.DownloadPhoto).Methods("GET")
	r.HandleFunc("/photos/{id}", rs.DeletePhoto).Methods("DELETE")
	r.HandleFunc("/photos/{id}/thumbnail", rs.ThumbnailPhoto).Methods("GET")
	r.HandleFunc("/photos/{id}/meta", rs.GetPhoto).Methods("GET")
	return r
}

// Start to build RESTful API Server
func (rs *RESTServer) Start() {
	rs.Wg.Add(1)
	ip := rs.GetCurrentIP()
	rs.Server = &http.Server{
		Addr:    ip + ":3000",
		Handler: rs.route(),
	}

	go func() {
		defer func() {
			rs.Server = nil
			rs.Wg.Done()
		}()

		fmt.Println("Started: ", ip)
		if err := rs.Server.ListenAndServe(); err != nil && err != http.ErrServerClosed {
			log.Fatalf("ListenAndServe(): %v", err)
		}
	}()
}

// Stop the RESTful server
func (rs *RESTServer) Stop() {
	ctx, cancelFunc := context.WithTimeout(
		context.Background(),
		5*time.Second,
	)
	defer cancelFunc()

	err := rs.Server.Shutdown(ctx)
	if err != nil {
		log.Fatalf("Shutdown(): %v", err)
	}

	rs.Wg.Wait()

	fmt.Println("Stopped")
}

// GetCurrentIP set current ip
func (rs *RESTServer) GetCurrentIP() string {
	if rs.ServerIP != "" {
		return rs.ServerIP
	}
	var configIP = rs.Config.GetIP()
	if configIP == "" {
		configIP = GetOutboundIP()
		rs.Config.SetIP(configIP)
	} else {
		var valid = false
		candidates := GetServerIPs()
		for _, val := range candidates {
			if val == configIP {
				valid = true
				break
			}
		}
		if valid != true {
			// config ip is not valid, use outbound one
			configIP := GetOutboundIP()
			rs.Config.SetIP(configIP)
		}
	}
	rs.ServerIP = configIP
	return configIP
}

// SetCurrentIP set current ip
func (rs *RESTServer) SetCurrentIP(ip string) {
	if rs.ServerIP != ip {
		rs.ServerIP = ip
		rs.Config.SetIP(ip)

		// restart the server with right ip
		rs.Stop()
		rs.Start()
	}
}

// GetServerIPs get available server ips
func (rs *RESTServer) GetServerIPs() map[string]string {
	return GetServerIPs()
}
