package server

import (
	"Storyboard/backend/interfaces"
	"context"
	"fmt"
	"log"
	"net/http"
	"sync"
	"time"

	"github.com/gorilla/mux"
)

// RESTServer is wrapper for http server and wait group
type RESTServer struct {
	Server   *http.Server
	Wg       *sync.WaitGroup
	TaskRepo interfaces.TaskRepo
}

// NewRESTServer create REST server
func NewRESTServer(taskRepo interfaces.TaskRepo) *RESTServer {
	var wg = &sync.WaitGroup{}
	wg.Add(1)

	return &RESTServer{
		Server:   nil,
		Wg:       wg,
		TaskRepo: taskRepo,
	}
}

func (rs RESTServer) route() *mux.Router {
	r := mux.NewRouter()
	r.HandleFunc("/tasks", rs.GetTasks).Methods("GET")
	r.HandleFunc("/tasks", rs.CreateTask).Methods("POST")
	r.HandleFunc("/tasks/{id}", rs.GetTask).Methods("GET")
	r.HandleFunc("/tasks/{id}", rs.UpdateTask).Methods("POST")
	r.HandleFunc("/tasks/{id}", rs.DeleteTask).Methods("DELETE")
	return r
}

// Start to build RESTful API Server
func (rs *RESTServer) Start() {
	rs.Server = &http.Server{
		Addr:    ":3000",
		Handler: rs.route(),
	}

	go func() {
		defer func() {
			rs.Server = nil
			rs.Wg.Done()
		}()

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
	rs.Wg = nil

	fmt.Println("Stopped")
}
