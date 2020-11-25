package server

import (
	"Storyboard/backend/dao"
	"Storyboard/backend/database"
	"encoding/json"
	"io/ioutil"
	"net/http"
	"time"

	"github.com/google/uuid"
	"github.com/gorilla/mux"
)

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

func buildSuccTaskResponse(w http.ResponseWriter, task dao.Task) {
	type SuccTask struct {
		Succ bool     `json:"succ"`
		Task dao.Task `json:"task"`
	}
	var response SuccTask
	response.Succ = true
	response.Task = task
	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(response)
}

func buildSuccTasksResponse(w http.ResponseWriter, tasks []dao.Task) {
	type SuccTasks struct {
		Succ  bool       `json:"succ"`
		Tasks []dao.Task `json:"tasks"`
	}
	var response SuccTasks
	response.Succ = true
	response.Tasks = tasks
	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(response)
}

// GetTasks is a restful API handler to get tasks
func GetTasks(w http.ResponseWriter, r *http.Request) {
	tasks := database.GetTasks(20, 0)
	buildSuccTasksResponse(w, tasks)
}

// CreateTask is a restful API handler to create task
func CreateTask(w http.ResponseWriter, r *http.Request) {
	reqBody, _ := ioutil.ReadAll(r.Body)

	var task dao.Task
	// decode json
	json.Unmarshal(reqBody, &task)

	// create uuid
	UUID, _ := uuid.NewRandom()
	task.UUID = UUID.String()
	task.CreatedAt = time.Now().Unix()
	task.UpdatedAt = time.Now().Unix()

	ret := database.CreateTask(task)
	if ret {
		buildSuccTaskResponse(w, task)
	} else {
		buildSuccResponse(w, false)
	}
}

// GetTask is a restful API handler to get task
func GetTask(w http.ResponseWriter, r *http.Request) {
	vars := mux.Vars(r)
	id := vars["id"]

	task := database.GetTask(id)
	if task == nil {
		buildSuccResponse(w, false)
	} else {
		buildSuccTaskResponse(w, *task)
	}
}

// UpdateTask is a restful API handler to update task
func UpdateTask(w http.ResponseWriter, r *http.Request) {
	vars := mux.Vars(r)
	id := vars["id"]

	task := database.GetTask(id)
	if task == nil {
		buildSuccResponse(w, false)
		return
	}

	reqBody, _ := ioutil.ReadAll(r.Body)
	var updatedTask dao.Task
	json.Unmarshal(reqBody, &updatedTask)

	updatedTask.UUID = id
	updatedTask.UpdatedAt = time.Now().Unix()
	updatedTask.CreatedAt = task.CreatedAt
	ret := database.UpdateTask(updatedTask)

	if ret {
		buildSuccTaskResponse(w, updatedTask)
	} else {
		buildSuccResponse(w, false)
	}
}

// DeleteTask is a restful API handler to delete task
func DeleteTask(w http.ResponseWriter, r *http.Request) {
	vars := mux.Vars(r)
	id := vars["id"]
	ret := database.DeleteTask(id)
	buildSuccResponse(w, ret)
}
