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

type taskCtrl struct{}

// TaskCtrl is task controller
var TaskCtrl taskCtrl = taskCtrl{}

// Response for task
func (t taskCtrl) buildSuccResponse(w http.ResponseWriter, succ bool) {
	type Succ struct {
		Succ bool `json:"succ"`
	}
	var response Succ
	response.Succ = succ
	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(response)
}

func (t taskCtrl) buildSuccTaskResponse(w http.ResponseWriter, task dao.Task) {
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

func (t taskCtrl) buildSuccTasksResponse(w http.ResponseWriter, tasks []dao.Task) {
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
func (t taskCtrl) GetTasks(w http.ResponseWriter, r *http.Request) {
	ts := ConvertQueryParamToInt(r, "ts", 0)
	limit := ConvertQueryParamToInt(r, "c", 20)
	tasks := database.TaskRepo.GetTasks(int64(ts), limit, 0)
	t.buildSuccTasksResponse(w, tasks)
}

// CreateTask is a restful API handler to create task
func (t taskCtrl) CreateTask(w http.ResponseWriter, r *http.Request) {
	reqBody, _ := ioutil.ReadAll(r.Body)

	var task dao.Task
	// decode json
	json.Unmarshal(reqBody, &task)

	// create uuid
	UUID, _ := uuid.NewRandom()
	task.UUID = UUID.String()
	task.CreatedAt = time.Now().Unix()
	task.UpdatedAt = time.Now().Unix()

	ret := database.TaskRepo.CreateTask(task)
	if ret {
		task := database.TaskRepo.GetTask(task.UUID)
		if task != nil {
			t.buildSuccTaskResponse(w, *task)
			return
		}
	}
	t.buildSuccResponse(w, false)
}

// GetTask is a restful API handler to get task
func (t taskCtrl) GetTask(w http.ResponseWriter, r *http.Request) {
	vars := mux.Vars(r)
	id := vars["id"]

	task := database.TaskRepo.GetTask(id)
	if task == nil {
		t.buildSuccResponse(w, false)
		return
	}
	t.buildSuccTaskResponse(w, *task)
}

// UpdateTask is a restful API handler to update task
func (t taskCtrl) UpdateTask(w http.ResponseWriter, r *http.Request) {
	vars := mux.Vars(r)
	id := vars["id"]

	task := database.TaskRepo.GetTask(id)
	if task == nil {
		t.buildSuccResponse(w, false)
		return
	}

	reqBody, _ := ioutil.ReadAll(r.Body)
	var updatedTask dao.Task
	json.Unmarshal(reqBody, &updatedTask)

	updatedTask.UUID = id
	updatedTask.UpdatedAt = time.Now().Unix()
	updatedTask.CreatedAt = task.CreatedAt
	ret := database.TaskRepo.UpdateTask(updatedTask)

	if ret {
		task := database.TaskRepo.GetTask(id)
		if task != nil {
			t.buildSuccTaskResponse(w, *task)
			return
		}
	}
	t.buildSuccResponse(w, false)
}

// DeleteTask is a restful API handler to delete task
func (t taskCtrl) DeleteTask(w http.ResponseWriter, r *http.Request) {
	vars := mux.Vars(r)
	id := vars["id"]
	ret := database.TaskRepo.DeleteTask(id)
	if ret {
		task := database.TaskRepo.GetTask(id)
		if task != nil {
			t.buildSuccTaskResponse(w, *task)
			return
		}
	}
	t.buildSuccResponse(w, ret)
}
