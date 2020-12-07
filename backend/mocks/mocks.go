package mocks

import (
	"Storyboard/backend/interfaces"
	"database/sql"
)

// Task is defined in interfaces
type Task = interfaces.Task

// ConfigMock to mock config
type ConfigMock struct {
	GetVendorNameFn   func() string
	GetAppNameFn      func() string
	GetDatabaseNameFn func() string
}

// GetVendorName mock config GetVendorName
func (c *ConfigMock) GetVendorName() string {
	return c.GetVendorNameFn()
}

// GetAppName mock config GetAppName
func (c *ConfigMock) GetAppName() string {
	return c.GetAppNameFn()
}

// GetDatabaseName mock config GetDatabaseName
func (c *ConfigMock) GetDatabaseName() string {
	return c.GetDatabaseNameFn()
}

// DatabaseMock to mock database service
type DatabaseMock struct {
	InitFn          func()
	GetConnectionFn func() *sql.DB
	GetTSFn         func() int64
	CloseFn         func()
}

// Init mock database service
func (d *DatabaseMock) Init() {
	d.InitFn()
}

// GetConnection mock database service
func (d *DatabaseMock) GetConnection() *sql.DB {
	return d.GetConnectionFn()
}

// GetTS mock database service
func (d *DatabaseMock) GetTS() int64 {
	return d.GetTSFn()
}

// Close mock database service
func (d *DatabaseMock) Close() {
	d.CloseFn()
}

// TaskRepoMock to mock task repo
type TaskRepoMock struct {
	CreateTaskFn    func(Task) (*Task, error)
	UpdateTaskFn    func(string, Task) (*Task, error)
	DeleteTaskFn    func(string) (*Task, error)
	GetTaskByUUIDFn func(string) (*Task, error)
	GetTasksByTSFn  func(ts int64, limit int, offset int) ([]Task, error)
}

// CreateTask mock task repo
func (t *TaskRepoMock) CreateTask(task Task) (*Task, error) {
	return t.CreateTaskFn(task)
}

// UpdateTask mock task repo
func (t *TaskRepoMock) UpdateTask(UUID string, task Task) (*Task, error) {
	return t.UpdateTaskFn(UUID, task)
}

// DeleteTask mock task repo
func (t *TaskRepoMock) DeleteTask(UUID string) (*Task, error) {
	return t.DeleteTaskFn(UUID)
}

// GetTaskByUUID mock task repo
func (t *TaskRepoMock) GetTaskByUUID(UUID string) (*Task, error) {
	return t.GetTaskByUUIDFn(UUID)
}

// GetTasksByTS mock task repo
func (t *TaskRepoMock) GetTasksByTS(ts int64, limit int, offset int) ([]Task, error) {
	return t.GetTasksByTSFn(ts, limit, offset)
}

// RESTMock to mock REST service
type RESTMock struct {
	StartFn func()
	StopFn  func()
}

// Start mock REST service
func (r *RESTMock) Start() {
	r.StartFn()
}

// Stop mock REST service
func (r *RESTMock) Stop() {
	r.StopFn()
}
