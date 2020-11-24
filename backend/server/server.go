package server

import (
	"context"
	"database/sql"
	"fmt"
	"log"
	"net/http"
	"sync"
	"time"

	"github.com/gorilla/mux"

	"Storyboard/backend/database"
)

// RestfulServer is wrapper for http server and wait group
type RestfulServer struct {
	Server *http.Server
	Wg     *sync.WaitGroup
	DB     *sql.DB
}

var restful *RestfulServer

func route() *mux.Router {
	r := mux.NewRouter()
	r.HandleFunc("/tasks", GetTasks).Methods("GET")
	r.HandleFunc("/tasks", CreateTask).Methods("POST")
	r.HandleFunc("/tasks/{id}", GetTask).Methods("GET")
	r.HandleFunc("/tasks/{id}", UpdateTask).Methods("POST")
	r.HandleFunc("/tasks/{id}", DeleteTask).Methods("DELETE")
	return r
}

// Start to build RESTful API Server
func Start() bool {
	if restful != nil {
		return false
	}

	restful = &RestfulServer{}
	restful.Wg = &sync.WaitGroup{}
	restful.Wg.Add(1)

	restful.Server = &http.Server{Addr: ":3000", Handler: route()}

	go func() {
		database.InitDatabase()
		defer database.Close()

		defer restful.Wg.Done()
		if err := restful.Server.ListenAndServe(); err != nil && err != http.ErrServerClosed {
			log.Fatalf("ListenAndServe(): %v", err)
		}
	}()

	return true
}

// Stop the RESTful server
func Stop() bool {
	if restful == nil {
		return false
	}

	database.Close()

	ctx, cancelFunc := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancelFunc()
	if err := restful.Server.Shutdown(ctx); err != nil {
		panic(err)
	}
	restful.Wg.Wait()
	restful = nil
	fmt.Println("Stopped")
	return true
}
