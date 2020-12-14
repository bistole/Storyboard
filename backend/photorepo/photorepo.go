package photorepo

import (
	"database/sql"
	"fmt"
	"io"
	"os"
	"path"
	"storyboard/backend/interfaces"
	"time"

	"github.com/google/uuid"
)

// Photo is defined in interfaces
type Photo = interfaces.Photo

// PhotoRepo is Photo repository implement
type PhotoRepo struct {
	db interfaces.DatabaseService
}

// NewPhotoRepo create instance of photo repo
func NewPhotoRepo(db interfaces.DatabaseService) PhotoRepo {
	return PhotoRepo{db}
}

func (p PhotoRepo) createPhotoFolder() (string, bool) {
	folderPath := path.Join(p.db.GetDataFolder(), "photos")
	_, err := os.Stat(folderPath)
	if os.IsNotExist(err) {
		os.MkdirAll(folderPath, 0755)
		os.Create(folderPath)
		return folderPath, false
	}
	return folderPath, true
}

// AddPhoto add photo
func (p PhotoRepo) AddPhoto(filename string, mimeType string, size string, src io.Reader) (outPhoto *Photo, err error) {
	UUID, _ := uuid.NewRandom()

	err = p._writeToDisk(UUID.String(), src)
	if err != nil {
		return nil, err
	}

	inPhoto := Photo{
		UUID:      UUID.String(),
		Filename:  filename,
		Size:      size,
		Mime:      mimeType,
		UpdatedAt: time.Now().Unix(),
		CreatedAt: time.Now().Unix(),
	}
	if err = p._createPhoto(inPhoto); err != nil {
		return nil, err
	}
	outPhoto, err = p._getPhoto(inPhoto.UUID)
	if err != nil {
		return nil, err
	}
	return outPhoto, nil
}

// GetPhoto get photo
func (p PhotoRepo) GetPhoto(UUID string) (src io.ReadCloser, err error) {
	src, err = p._readFromDisk(UUID)
	if err != nil {
		return nil, err
	}
	return src, nil
}

// GetPhotoMeta get meta data of photo
func (p PhotoRepo) GetPhotoMeta(UUID string) (outPhoto *Photo, err error) {
	photo, err := p._getPhoto(UUID)
	if err != nil {
		return nil, err
	}
	return photo, nil
}

// DeletePhoto delete photo
func (p PhotoRepo) DeletePhoto(UUID string) (outPhoto *Photo, err error) {
	updatedAt := time.Now().Unix()

	// ignore error
	p._removeFromDisk(UUID)

	if err := p._deletePhoto(UUID, updatedAt); err != nil {
		return nil, err
	}
	outPhoto, err = p._getPhoto(UUID)
	if err != nil {
		return nil, err
	}
	return outPhoto, nil
}

func (p PhotoRepo) _createPhoto(photo Photo) error {
	db := p.db.GetConnection()
	stmt, err := db.Prepare("INSERT INTO `photos` (" +
		"uuid, filename, size, mime, updatedAt, createdAt, _ts" +
		") VALUES (:uuid, :filename, :size, :mime, :updatedAt, :createdAt, :ts)")
	if err != nil {
		return err
	}

	ts := p.db.GetTS()

	result, err := stmt.Exec(
		sql.Named("uuid", photo.UUID),
		sql.Named("filename", photo.Filename),
		sql.Named("size", photo.Size),
		sql.Named("mime", photo.Mime),
		sql.Named("updatedAt", photo.UpdatedAt),
		sql.Named("createdAt", photo.CreatedAt),
		sql.Named("ts", ts),
	)
	if err != nil {
		return err
	}

	lastID, err := result.LastInsertId()
	if err != nil {
		return err
	}

	if lastID > 0 {
		return nil
	}
	return fmt.Errorf("Failed to create photo")
}

func (p PhotoRepo) _deletePhoto(UUID string, updatedAt int64) error {
	db := p.db.GetConnection()
	stmt, err := db.Prepare("UPDATE `photos` SET " +
		"`deleted` = 1," +
		"`updatedAt` = :updatedAt," +
		"`_ts` = :ts " +
		"WHERE `uuid` = :uuid ")
	if err != nil {
		return err
	}

	ts := p.db.GetTS()

	result, err := stmt.Exec(
		sql.Named("uuid", UUID),
		sql.Named("updatedAt", updatedAt),
		sql.Named("ts", ts),
	)
	if err != nil {
		return err
	}

	affectRow, err := result.RowsAffected()
	if err != nil {
		return err
	}

	fmt.Printf("Deleted: %t\n", affectRow > 0)
	if affectRow > 0 {
		return nil
	}
	return fmt.Errorf("Failed to delete photo")
}

func (p PhotoRepo) _getPhoto(UUID string) (*Photo, error) {
	db := p.db.GetConnection()
	stmt, err := db.Prepare("SELECT uuid, filename, size, mime, deleted, updatedAt, createdAt, _ts " +
		"FROM `photos` WHERE `uuid` = :uuid ")
	if err != nil {
		return nil, err
	}

	row := stmt.QueryRow(sql.Named("uuid", UUID))

	var photo Photo
	err = row.Scan(
		&photo.UUID, &photo.Filename, &photo.Size, &photo.Mime,
		&photo.Deleted, &photo.UpdatedAt, &photo.CreatedAt, &photo.TS,
	)
	if err == sql.ErrNoRows {
		return nil, err
	}
	return &photo, nil
}

// Write photo to disk
func (p PhotoRepo) _writeToDisk(UUID string, src io.Reader) (err error) {
	p.createPhotoFolder()
	localPath := path.Join(p.db.GetDataFolder(), "photos", UUID)

	f, err := os.Create(localPath)
	defer f.Close()
	if err != nil {
		return err
	}

	_, err = io.Copy(f, src)
	if err != nil {
		return err
	}
	return nil
}

func (p PhotoRepo) _readFromDisk(UUID string) (reader io.ReadCloser, err error) {
	localPath := path.Join(p.db.GetDataFolder(), "photos", UUID)

	_, err = os.Stat(localPath)
	if err != nil {
		return nil, err
	}

	f, err := os.Open(localPath)
	if err != nil {
		return nil, err
	}
	return f, nil
}

// Remove photo from disk
func (p PhotoRepo) _removeFromDisk(UUID string) (err error) {
	localPath := path.Join(p.db.GetDataFolder(), "photos", UUID)

	err = os.Remove(localPath)
	if err != nil {
		return err
	}
	return nil
}

// GetPhotoMetaByTS in DB
func (p PhotoRepo) GetPhotoMetaByTS(ts int64, limit int, offset int) (photos []Photo, err error) {
	db := p.db.GetConnection()
	stmt, err := db.Prepare("SELECT uuid, filename, size, mime, deleted, updatedAt, createdAt, _ts " +
		"FROM `photos` WHERE `_ts` >= :ts ORDER BY `_ts` ASC LIMIT :limit OFFSET :offset")
	if err != nil {
		return nil, err
	}

	rows, err := stmt.Query(
		sql.Named("ts", ts),
		sql.Named("limit", limit),
		sql.Named("offset", offset),
	)
	if err != nil {
		return nil, err
	}

	photos = make([]Photo, 0, limit)
	for rows.Next() {
		var photo Photo
		rows.Scan(
			&photo.UUID, &photo.Filename, &photo.Size, &photo.Mime,
			&photo.Deleted, &photo.UpdatedAt, &photo.CreatedAt, &photo.TS,
		)
		photos = append(photos, photo)
	}
	return photos, nil
}
