package server

import (
	"encoding/json"
	"fmt"
	"io"
	"net/http"
	"storyboard/backend/interfaces"
	"strings"

	"github.com/gorilla/mux"
)

// Photo is defined in interfaces
type Photo = interfaces.Photo

func (rs RESTServer) buildSuccPhotoResponse(w http.ResponseWriter, photo Photo) {
	type SuccPhoto struct {
		Succ  bool  `json:"succ"`
		Photo Photo `json:"photo"`
	}
	var response SuccPhoto
	response.Succ = true
	response.Photo = photo
	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(response)
}

func (rs RESTServer) buildSuccPhotosResponse(w http.ResponseWriter, photos []Photo) {
	type SuccPhotos struct {
		Succ   bool    `json:"succ"`
		Photos []Photo `json:"photos"`
	}
	var response SuccPhotos
	response.Succ = true
	response.Photos = photos
	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(response)
}

// GetPhoto is a resfult PI handler to get photo metadata
func (rs RESTServer) GetPhoto(w http.ResponseWriter, r *http.Request) {
	vars := mux.Vars(r)
	id := vars["id"]

	photo, err := rs.PhotoRepo.GetPhotoMeta(id)
	if err != nil {
		rs.buildErrorResponse(w, err)
		return
	}
	rs.buildSuccPhotoResponse(w, *photo)
}

// GetPhotos is a restful API handler to get tasks
func (rs RESTServer) GetPhotos(w http.ResponseWriter, r *http.Request) {
	ts := ConvertQueryParamToInt(r, "ts", 0)
	limit := ConvertQueryParamToInt(r, "c", 20)
	photos, err := rs.PhotoRepo.GetPhotoMetaByTS(int64(ts), limit, 0)
	if err != nil {
		rs.buildErrorResponse(w, err)
		return
	}
	rs.buildSuccPhotosResponse(w, photos)
}

// UploadPhoto is a restful API handler to upload photo
func (rs RESTServer) UploadPhoto(w http.ResponseWriter, r *http.Request) {
	mimeHeader := r.Header.Get("Content-Type")
	size := r.Header.Get("Content-Length")
	filename := r.Header.Get("Content-Name")

	fmt.Printf("File Name: %+v\n", filename)
	fmt.Printf("File Size: %+v\n", size)
	fmt.Printf("MIME Header: %+v\n", mimeHeader)
	mimeTypeArr := strings.Split(mimeHeader, ";")

	photo, err := rs.PhotoRepo.AddPhoto(filename, mimeTypeArr[0], size, r.Body)
	if err != nil {
		rs.buildErrorResponse(w, err)
		return
	}
	rs.buildSuccPhotoResponse(w, *photo)
}

// DownloadPhoto is a restful API handler to download photo
func (rs RESTServer) DownloadPhoto(w http.ResponseWriter, r *http.Request) {
	vars := mux.Vars(r)
	id := vars["id"]

	src, err := rs.PhotoRepo.GetPhoto(id)
	if err != nil {
		rs.buildErrorResponse(w, err)
		return
	}

	_, err = io.Copy(w, src)
	if err != nil {
		rs.buildErrorResponse(w, err)
		return
	}
}

// ThumbnailPhoto is a restful API handler to download photo
func (rs RESTServer) ThumbnailPhoto(w http.ResponseWriter, r *http.Request) {
	vars := mux.Vars(r)
	id := vars["id"]

	src, err := rs.PhotoRepo.GetPhotoThumbnail(id)
	if err != nil {
		rs.buildErrorResponse(w, err)
		return
	}

	_, err = io.Copy(w, src)
	if err != nil {
		rs.buildErrorResponse(w, err)
		return
	}
}

// DeletePhoto is a restful API handler to delete photo
func (rs RESTServer) DeletePhoto(w http.ResponseWriter, r *http.Request) {
	vars := mux.Vars(r)
	id := vars["id"]
	photo, err := rs.PhotoRepo.DeletePhoto(id)
	if err != nil {
		rs.buildErrorResponse(w, err)
		return
	}
	rs.buildSuccPhotoResponse(w, *photo)
}
