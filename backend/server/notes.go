package server

// TODO: test succ case for create/update/delete note

import (
	"encoding/json"
	"fmt"
	"io/ioutil"
	"net/http"
	"storyboard/backend/interfaces"

	"github.com/gorilla/mux"
)

// Note is defined in interfaces
type Note = interfaces.Note

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

func (rs RESTServer) buildSuccNoteResponse(w http.ResponseWriter, note Note) {
	type SuccNote struct {
		Succ bool `json:"succ"`
		Note Note `json:"note"`
	}
	var response SuccNote
	response.Succ = true
	response.Note = note
	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(response)
}

func (rs RESTServer) buildSuccNotesResponse(w http.ResponseWriter, notes []Note) {
	type SuccNotes struct {
		Succ  bool   `json:"succ"`
		Notes []Note `json:"notes"`
	}
	var response SuccNotes
	response.Succ = true
	response.Notes = notes
	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(response)
}

// GetNotes is a restful API handler to get notes
func (rs RESTServer) GetNotes(w http.ResponseWriter, r *http.Request) {
	ts := ConvertQueryParamToInt(r, "ts", 0)
	limit := ConvertQueryParamToInt(r, "c", 20)
	notes, err := rs.NoteRepo.GetNotesByTS(int64(ts), limit, 0)
	if err != nil {
		rs.buildErrorResponse(w, err)
		return
	}
	rs.buildSuccNotesResponse(w, notes)
}

// CreateNote is a restful API handler to create note
func (rs RESTServer) CreateNote(w http.ResponseWriter, r *http.Request) {
	reqBody, _ := ioutil.ReadAll(r.Body)

	clientID := r.Header.Get(headerNameClientID)
	if clientID == "" {
		rs.buildErrorResponse(w, fmt.Errorf("Missing request header: %s", headerNameClientID))
		return
	}

	// decode json
	var inNote Note
	json.Unmarshal(reqBody, &inNote)

	// validate json
	if err := IsStringUUID(inNote.UUID, "UUID is invalid"); err != nil {
		rs.buildErrorResponse(w, err)
		return
	}
	if err := IsStringNotEmpty(inNote.Title, "Title is missing"); err != nil {
		rs.buildErrorResponse(w, err)
		return
	}
	if err := IsIntValidDate(inNote.CreatedAt, "CreatedAt is missing"); err != nil {
		rs.buildErrorResponse(w, err)
		return
	}
	inNote.UpdatedAt = inNote.CreatedAt

	outNote, err := rs.NoteRepo.CreateNote(inNote)
	if err != nil {
		rs.buildErrorResponse(w, err)
		return
	}
	param := map[string]string{"type": notifyTypeNote}
	rs.EventServer.Notify(clientID, &param)
	rs.buildSuccNoteResponse(w, *outNote)
}

// GetNote is a restful API handler to get note
func (rs RESTServer) GetNote(w http.ResponseWriter, r *http.Request) {
	vars := mux.Vars(r)
	id := vars["id"]

	note, err := rs.NoteRepo.GetNoteByUUID(id)
	if err != nil {
		rs.buildErrorResponse(w, err)
		return
	}
	rs.buildSuccNoteResponse(w, *note)
}

// UpdateNote is a restful API handler to update note
func (rs RESTServer) UpdateNote(w http.ResponseWriter, r *http.Request) {
	vars := mux.Vars(r)
	id := vars["id"]

	clientID := r.Header.Get(headerNameClientID)
	if clientID == "" {
		rs.buildErrorResponse(w, fmt.Errorf("Missing request header: %s", headerNameClientID))
		return
	}

	reqBody, _ := ioutil.ReadAll(r.Body)
	var updatedNote Note
	json.Unmarshal(reqBody, &updatedNote)

	if err := IsStringNotEmpty(updatedNote.Title, "Title is missing"); err != nil {
		rs.buildErrorResponse(w, err)
		return
	}
	if err := IsIntValidDate(updatedNote.UpdatedAt, "UpdatedAt is missing"); err != nil {
		rs.buildErrorResponse(w, err)
		return
	}

	note, err := rs.NoteRepo.UpdateNote(id, updatedNote)
	if err != nil {
		rs.buildErrorResponse(w, err)
		return
	}
	param := map[string]string{"type": notifyTypeNote}
	rs.EventServer.Notify(clientID, &param)
	rs.buildSuccNoteResponse(w, *note)
}

// DeleteNote is a restful API handler to delete note
func (rs RESTServer) DeleteNote(w http.ResponseWriter, r *http.Request) {
	vars := mux.Vars(r)
	id := vars["id"]

	clientID := r.Header.Get(headerNameClientID)
	if clientID == "" {
		rs.buildErrorResponse(w, fmt.Errorf("Missing request header: %s", headerNameClientID))
		return
	}

	reqBody, _ := ioutil.ReadAll(r.Body)
	var deletedNote Note
	json.Unmarshal(reqBody, &deletedNote)

	if err := IsIntValidDate(deletedNote.UpdatedAt, "UpdatedAt is missing"); err != nil {
		rs.buildErrorResponse(w, err)
		return
	}

	note, err := rs.NoteRepo.DeleteNote(id, deletedNote.UpdatedAt)
	if err != nil {
		rs.buildErrorResponse(w, err)
		return
	}
	param := map[string]string{"type": notifyTypeNote}
	rs.EventServer.Notify(clientID, &param)
	rs.buildSuccNoteResponse(w, *note)
}
