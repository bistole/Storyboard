package server

import (
	"context"
	"fmt"
	"log"
	"net/http"
	"sync"
	"time"

	"github.com/gorilla/mux"

	"Storyboard/backend/database"
)

// RestfulServer is wrapper for http server and wait group
type restfulServer struct {
	Server *http.Server
	Wg     *sync.WaitGroup
}

// RestfulServer is RESTful API Server
var RestfulServer restfulServer = restfulServer{Server: nil, Wg: nil}

func (rs restfulServer) ProcessError(err error) {
	if err != nil {
		panic(err)
	}
}

func (rs restfulServer) route() *mux.Router {
	r := mux.NewRouter()
	r.HandleFunc("/tasks", TaskCtrl.GetTasks).Methods("GET")
	r.HandleFunc("/tasks", TaskCtrl.CreateTask).Methods("POST")
	r.HandleFunc("/tasks/{id}", TaskCtrl.GetTask).Methods("GET")
	r.HandleFunc("/tasks/{id}", TaskCtrl.UpdateTask).Methods("POST")
	r.HandleFunc("/tasks/{id}", TaskCtrl.DeleteTask).Methods("DELETE")
	return r
}

// Start to build RESTful API Server
func (rs restfulServer) Start() bool {
	if rs.Wg != nil || rs.Server != nil {
		return false
	}

	rs.Wg = &sync.WaitGroup{}
	rs.Wg.Add(1)
	rs.Server = &http.Server{
		Addr:    ":3000",
		Handler: rs.route(),
	}

	go func() {
		database.DBWrapper.Init()
		defer func() {
			database.DBWrapper.Close()
			rs.Server = nil
		}()

		defer rs.Wg.Done()
		if err := rs.Server.ListenAndServe(); err != nil && err != http.ErrServerClosed {
			log.Fatalf("ListenAndServe(): %v", err)
		}
	}()

	return true
}

// Stop the RESTful server
func (rs restfulServer) Stop() bool {
	ctx, cancelFunc := context.WithTimeout(
		context.Background(),
		5*time.Second,
	)
	defer cancelFunc()
	if err := rs.Server.Shutdown(ctx); err != nil {
		panic(err)
	}

	rs.Wg.Wait()
	rs.Wg = nil

	fmt.Println("Stopped")
	return true
}
