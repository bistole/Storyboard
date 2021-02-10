package server

import (
	"encoding/json"
	"fmt"
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

	clientID := r.Header.Get(headerNameClientID)
	if clientID == "" {
		rs.buildErrorResponse(w, fmt.Errorf("Missing request header: %s", headerNameClientID))
		return
	}

	// decode json
	var inTask Task
	json.Unmarshal(reqBody, &inTask)

	// validate json
	if err := IsStringUUID(inTask.UUID, "UUID is invalid"); err != nil {
		rs.buildErrorResponse(w, err)
		return
	}
	if err := IsStringNotEmpty(inTask.Title, "Title is missing"); err != nil {
		rs.buildErrorResponse(w, err)
		return
	}
	if err := IsIntValidDate(inTask.CreatedAt, "CreatedAt is missing"); err != nil {
		rs.buildErrorResponse(w, err)
		return
	}
	inTask.UpdatedAt = inTask.CreatedAt

	outTask, err := rs.TaskRepo.CreateTask(inTask)
	if err != nil {
		rs.buildErrorResponse(w, err)
		return
	}
	param := map[string]string{"type": notifyTypeTask}
	rs.EventServer.Notify(clientID, &param)
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

	clientID := r.Header.Get(headerNameClientID)
	if clientID == "" {
		rs.buildErrorResponse(w, fmt.Errorf("Missing request header: %s", headerNameClientID))
		return
	}

	reqBody, _ := ioutil.ReadAll(r.Body)
	var updatedTask Task
	json.Unmarshal(reqBody, &updatedTask)

	if err := IsStringNotEmpty(updatedTask.Title, "Title is missing"); err != nil {
		rs.buildErrorResponse(w, err)
		return
	}
	if err := IsIntValidDate(updatedTask.UpdatedAt, "UpdatedAt is missing"); err != nil {
		rs.buildErrorResponse(w, err)
		return
	}

	task, err := rs.TaskRepo.UpdateTask(id, updatedTask)
	if err != nil {
		rs.buildErrorResponse(w, err)
		return
	}
	param := map[string]string{"type": notifyTypeTask}
	rs.EventServer.Notify(clientID, &param)
	rs.buildSuccTaskResponse(w, *task)
}

// DeleteTask is a restful API handler to delete task
func (rs RESTServer) DeleteTask(w http.ResponseWriter, r *http.Request) {
	vars := mux.Vars(r)
	id := vars["id"]

	clientID := r.Header.Get(headerNameClientID)
	if clientID == "" {
		rs.buildErrorResponse(w, fmt.Errorf("Missing request header: %s", headerNameClientID))
		return
	}

	reqBody, _ := ioutil.ReadAll(r.Body)
	var deletedTask Task
	json.Unmarshal(reqBody, &deletedTask)

	if err := IsIntValidDate(deletedTask.UpdatedAt, "UpdatedAt is missing"); err != nil {
		rs.buildErrorResponse(w, err)
		return
	}

	task, err := rs.TaskRepo.DeleteTask(id, deletedTask.UpdatedAt)
	if err != nil {
		rs.buildErrorResponse(w, err)
		return
	}
	param := map[string]string{"type": notifyTypeTask}
	rs.EventServer.Notify(clientID, &param)
	rs.buildSuccTaskResponse(w, *task)
}
