package server

import (
	"encoding/json"
	"net/http"
)

// Ping to check server status
func (rs RESTServer) Ping(w http.ResponseWriter, r *http.Request) {
	type Succ struct {
		Pong bool `json:"pong"`
	}
	var response Succ
	response.Pong = true
	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(response)
}
