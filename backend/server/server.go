package server

import (
	"context"
	"encoding/json"
	"fmt"
	"io/ioutil"
	"log"
	"net/http"
	"sync"
	"time"

	"github.com/google/uuid"
	"github.com/gorilla/mux"
)

// Task define
type Task struct {
	UUID      string `json:"uuid"`
	Title     string `json:"title"`
	CreatedAt int64  `json:"createdAt"`
	UpdatedAt int64  `json:"updatedAt"`
}

var tasks map[string]Task = make(map[string]Task)
var taskList []string = make([]string, 0, 100)

// Response for task
func buildSuccResponse(w http.ResponseWriter, succ bool) {
	type Succ struct {
		Succ bool `json:"succ"`
	}
	var response Succ
	response.Succ = succ
	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(response)
}

func buildSuccTaskResponse(w http.ResponseWriter, task Task) {
	type SuccTask struct {
		Succ bool `json:"succ"`
		Task Task `json:"task"`
	}
	var response SuccTask
	response.Succ = true
	response.Task = task
	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(response)
}

func buildSuccTasksResponse(w http.ResponseWriter, tasks []Task) {
	type SuccTasks struct {
		Succ  bool   `json:"succ"`
		Tasks []Task `json:"tasks"`
	}
	var response SuccTasks
	response.Succ = true
	response.Tasks = tasks
	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(response)
}

func getTasks(w http.ResponseWriter, r *http.Request) {
	var pickedTasks []Task = make([]Task, 0)
	for _, v := range taskList {
		pickedTasks = append(pickedTasks, tasks[v])
	}

	// response
	buildSuccTasksResponse(w, pickedTasks)
}

func createTask(w http.ResponseWriter, r *http.Request) {
	reqBody, _ := ioutil.ReadAll(r.Body)

	var task Task
	// decode json
	json.Unmarshal(reqBody, &task)

	// create uuid
	UUID, _ := uuid.NewRandom()
	task.UUID = UUID.String()
	task.CreatedAt = time.Now().Unix()
	task.UpdatedAt = time.Now().Unix()

	// save to map
	tasks[task.UUID] = task

	// add to list
	taskList = append(taskList, task.UUID)
	fmt.Println(taskList)
	// response
	buildSuccTaskResponse(w, task)
}

func getTask(w http.ResponseWriter, r *http.Request) {
	vars := mux.Vars(r)
	id := vars["id"]

	task, exists := tasks[id]
	if !exists {
		buildSuccResponse(w, false)
		return
	}

	buildSuccTaskResponse(w, task)
}

func updateTask(w http.ResponseWriter, r *http.Request) {
	vars := mux.Vars(r)
	id := vars["id"]

	task, exists := tasks[id]
	if !exists {
		buildSuccResponse(w, false)
		return
	}

	reqBody, _ := ioutil.ReadAll(r.Body)
	var updatedTask Task
	json.Unmarshal(reqBody, &updatedTask)

	updatedTask.UUID = id
	updatedTask.UpdatedAt = time.Now().Unix()
	updatedTask.CreatedAt = task.CreatedAt
	tasks[id] = updatedTask

	buildSuccTaskResponse(w, task)
}

func deleteTask(w http.ResponseWriter, r *http.Request) {
	vars := mux.Vars(r)
	id := vars["id"]

	// not exists, return false
	_, exists := tasks[id]
	if !exists {
		buildSuccResponse(w, false)
		return
	}

	// delete from map
	delete(tasks, id)

	// remove from list
	for i, v := range taskList {
		if v == id {
			taskList = append(taskList[:i], taskList[i+1:]...)
			break
		}
	}

	// return true
	buildSuccResponse(w, true)
}

// RestfulServer is wrapper for http server and wait group
type RestfulServer struct {
	Server *http.Server
	Wg     *sync.WaitGroup
}

var restful *RestfulServer

// Start to build RESTful API Server
func Start() bool {
	if restful != nil {
		return false
	}

	restful = &RestfulServer{}
	restful.Wg = &sync.WaitGroup{}
	restful.Wg.Add(1)

	r := mux.NewRouter()
	r.HandleFunc("/tasks", getTasks).Methods("GET")
	r.HandleFunc("/tasks", createTask).Methods("POST")
	r.HandleFunc("/tasks/{id}", getTask).Methods("GET")
	r.HandleFunc("/tasks/{id}", updateTask).Methods("POST")
	r.HandleFunc("/tasks/{id}", deleteTask).Methods("DELETE")

	restful.Server = &http.Server{Addr: ":3000", Handler: r}

	go func() {
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
