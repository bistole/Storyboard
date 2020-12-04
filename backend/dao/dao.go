package dao

// Task is data object of Task
type Task struct {
	UUID      string `json:"uuid"`
	Title     string `json:"title"`
	Deleted   int8   `json:"deleted"`
	CreatedAt int64  `json:"createdAt"`
	UpdatedAt int64  `json:"updatedAt"`
	TS        int64  `json:"_ts"`
}
