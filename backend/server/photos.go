package server

// TODO: test succ case when deleting photo
// TODO: test error cases

import (
	"encoding/json"
	"fmt"
	"io"
	"io/ioutil"
	"log"
	"net/http"
	"storyboard/backend/interfaces"
	"strconv"
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

// GetPhotos is a restful API handler to get photos
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

func (rs RESTServer) getUUIDFromParameters(r *http.Request) (string, error) {
	if r.Form["uuid"] == nil {
		return "", fmt.Errorf("uuid is missing")
	}
	uuid := r.Form["uuid"][0]
	if err := IsStringUUID(uuid, "uuid is invalid"); err != nil {
		return "", err
	}
	return uuid, nil
}

func (rs RESTServer) getDirectionFromParameter(r *http.Request) (int32, error) {
	if r.Form["direction"] == nil {
		return 0, fmt.Errorf("direction is missing")
	}
	direction64, err := strconv.ParseInt(r.Form["direction"][0], 10, 64)
	if err != nil {
		return 0, fmt.Errorf("direction is invalid")
	}

	direction := int32(direction64)
	if err := IsIntValidDirection(direction, "direction is missing"); err != nil {
		return 0, err
	}
	return direction, nil
}

func (rs RESTServer) getCreatedAtFromParameter(r *http.Request) (int64, error) {
	if r.Form["createdAt"] == nil {
		return 0, fmt.Errorf("createdAt is missing")
	}
	createdAt, err := strconv.ParseInt(r.Form["createdAt"][0], 10, 64)
	if err != nil {
		return 0, fmt.Errorf("createdAt is invalid")
	}
	if err := IsIntValidDate(createdAt, "createdAt is missing"); err != nil {
		return 0, err
	}

	return createdAt, nil
}

// UploadPhoto is a restful API handler to upload photo
func (rs RESTServer) UploadPhoto(w http.ResponseWriter, r *http.Request) {
	r.ParseMultipartForm(10 << 20)

	clientID := r.Header.Get(headerNameClientID)
	if clientID == "" {
		rs.buildErrorResponse(w, fmt.Errorf("Missing request header: %s", headerNameClientID))
		return
	}

	file, handler, err := r.FormFile("photo")
	if err != nil {
		rs.buildErrorResponse(w, err)
		return
	}

	uuid, err := rs.getUUIDFromParameters(r)
	if err != nil {
		rs.buildErrorResponse(w, err)
		return
	}
	filename := handler.Filename
	mimeType := handler.Header.Get("Content-Type")
	size := handler.Header.Get("Content-Length")
	direction, err := rs.getDirectionFromParameter(r)
	if err != nil {
		rs.buildErrorResponse(w, err)
		return
	}
	createdAt, err := rs.getCreatedAtFromParameter(r)
	if err != nil {
		rs.buildErrorResponse(w, err)
		return
	}

	log.Printf("File Name: %+v\n", filename)
	log.Printf("File Size: %+v\n", size)
	log.Printf("MIME Header: %+v\n", mimeType)
	mimeTypeArr := strings.Split(mimeType, ";")

	photo, err := rs.PhotoRepo.AddPhoto(uuid, filename, mimeTypeArr[0], size, direction, file, createdAt)
	if err != nil {
		rs.buildErrorResponse(w, err)
		return
	}
	param := map[string]string{"type": notifyTypePhoto}
	rs.EventServer.Notify(clientID, &param)
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

// DeletePhoto is a restful API handler to update photo
func (rs RESTServer) UpdatePhoto(w http.ResponseWriter, r *http.Request) {
	vars := mux.Vars(r)
	id := vars["id"]

	clientID := r.Header.Get(headerNameClientID)
	if clientID == "" {
		rs.buildErrorResponse(w, fmt.Errorf("Missing request header: %s", headerNameClientID))
		return
	}

	reqBody, _ := ioutil.ReadAll(r.Body)
	var updatedPhoto Photo
	json.Unmarshal(reqBody, &updatedPhoto)

	if err := IsIntValidDirection(updatedPhoto.Direction, "Direction is invalid"); err != nil {
		rs.buildErrorResponse(w, err)
		return
	}

	if err := IsIntValidDate(updatedPhoto.UpdatedAt, "UpdatedAt is missing"); err != nil {
		rs.buildErrorResponse(w, err)
		return
	}

	photo, err := rs.PhotoRepo.UpdatePhoto(id, updatedPhoto)
	if err != nil {
		rs.buildErrorResponse(w, err)
		return
	}

	param := map[string]string{"type": notifyTypePhoto}
	rs.EventServer.Notify(clientID, &param)
	rs.buildSuccPhotoResponse(w, *photo)
}

// DeletePhoto is a restful API handler to delete photo
func (rs RESTServer) DeletePhoto(w http.ResponseWriter, r *http.Request) {
	vars := mux.Vars(r)
	id := vars["id"]

	clientID := r.Header.Get(headerNameClientID)
	if clientID == "" {
		rs.buildErrorResponse(w, fmt.Errorf("Missing request header: %s", headerNameClientID))
		return
	}

	reqBody, _ := ioutil.ReadAll(r.Body)
	var deletedPhoto Photo
	json.Unmarshal(reqBody, &deletedPhoto)

	if err := IsIntValidDate(deletedPhoto.UpdatedAt, "UpdatedAt is missing"); err != nil {
		rs.buildErrorResponse(w, err)
		return
	}

	photo, err := rs.PhotoRepo.DeletePhoto(id, deletedPhoto.UpdatedAt)
	if err != nil {
		rs.buildErrorResponse(w, err)
		return
	}

	param := map[string]string{"type": notifyTypePhoto}
	rs.EventServer.Notify(clientID, &param)
	rs.buildSuccPhotoResponse(w, *photo)
}
