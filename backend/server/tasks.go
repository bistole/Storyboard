package server

import (
	"encoding/json"
	"io/ioutil"
	"net/http"
	"storyboard/backend/interfaces"

	"github.com/gorilla/mux"
)

// Task is defined in interfaces
type Task = interfaces.Task

func (rs RESTServer) buildErrorResponse(w http.ResponseWriter, err error) {
	type Succ struct {
		Succ  bool   `json:"succ"`
		Error string `jsson:"error"`
	}
	var response Succ
	response.Succ = false
	response.Error = err.Error()
	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(response)
}

func (rs RESTServer) buildSuccTaskResponse(w http.ResponseWriter, task Task) {
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

func (rs RESTServer) buildSuccTasksResponse(w http.ResponseWriter, tasks []Task) {
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

// GetTasks is a restful API handler to get tasks
func (rs RESTServer) GetTasks(w http.ResponseWriter, r *http.Request) {
	ts := ConvertQueryParamToInt(r, "ts", 0)
	limit := ConvertQueryParamToInt(r, "c", 20)
	tasks, err := rs.TaskRepo.GetTasksByTS(int64(ts), limit, 0)
	if err != nil {
		rs.buildErrorResponse(w, err)
		return
	}
	rs.buildSuccTasksResponse(w, tasks)
}

// CreateTask is a restful API handler to create task
func (rs RESTServer) CreateTask(w http.ResponseWriter, r *http.Request) {
	reqBody, _ := ioutil.ReadAll(r.Body)

	// decode json
	var inTask Task
	json.Unmarshal(reqBody, &inTask)

	outTask, err := rs.TaskRepo.CreateTask(inTask)
	if err != nil {
		rs.buildErrorResponse(w, err)
		return
	}
	rs.buildSuccTaskResponse(w, *outTask)
}

// GetTask is a restful API handler to get task
func (rs RESTServer) GetTask(w http.ResponseWriter, r *http.Request) {
	vars := mux.Vars(r)
	id := vars["id"]

	task, err := rs.TaskRepo.GetTaskByUUID(id)
	if err != nil {
		rs.buildErrorResponse(w, err)
		return
	}
	rs.buildSuccTaskResponse(w, *task)
}

// UpdateTask is a restful API handler to update task
func (rs RESTServer) UpdateTask(w http.ResponseWriter, r *http.Request) {
	vars := mux.Vars(r)
	id := vars["id"]

	reqBody, _ := ioutil.ReadAll(r.Body)
	var updatedTask Task
	json.Unmarshal(reqBody, &updatedTask)

	task, err := rs.TaskRepo.UpdateTask(id, updatedTask)
	if err != nil {
		rs.buildErrorResponse(w, err)
		return
	}
	rs.buildSuccTaskResponse(w, *task)
}

// DeleteTask is a restful API handler to delete task
func (rs RESTServer) DeleteTask(w http.ResponseWriter, r *http.Request) {
	vars := mux.Vars(r)
	id := vars["id"]
	task, err := rs.TaskRepo.DeleteTask(id)
	if err != nil {
		rs.buildErrorResponse(w, err)
		return
	}
	rs.buildSuccTaskResponse(w, *task)
}
