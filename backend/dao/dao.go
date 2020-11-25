package dao

// Task DAO
type Task struct {
	UUID      string `json:"uuid"`
	Title     string `json:"title"`
	CreatedAt int64  `json:"createdAt"`
	UpdatedAt int64  `json:"updatedAt"`
}
