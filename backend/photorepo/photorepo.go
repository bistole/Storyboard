package photorepo

import (
	"log"
	"storyboard/backend/interfaces"

	"database/sql"
	"fmt"
	"image"
	"image/draw"
	_ "image/gif"
	"image/jpeg"
	"image/png"
	"io"
	"os"
	"path"
	"time"

	"github.com/google/uuid"
	"github.com/nfnt/resize"
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

var validMimeType = []string{"image/jpeg", "image/png", "image/gif"}

func isMimeTypeValid(mimeType string) bool {
	for _, v := range validMimeType {
		if v == mimeType {
			return true
		}
	}
	return false
}

// AddPhoto add photo
func (p PhotoRepo) AddPhoto(filename string, mimeType string, size string, src io.Reader) (outPhoto *Photo, err error) {
	if !isMimeTypeValid(mimeType) {
		return nil, fmt.Errorf("Invalid MIME type")
	}

	UUID, _ := uuid.NewRandom()
	dst, err := p._getFileHandler(UUID.String(), false)
	if err != nil {
		log.Println(err)
		return nil, fmt.Errorf("Failed to save photo")
	}
	defer dst.Close()

	err = p._writeToDisk(src, dst)
	if err != nil {
		log.Println(err)
		return nil, fmt.Errorf("Failed to save photo")
	}

	p._createThumbnail(UUID.String(), mimeType)

	inPhoto := Photo{
		UUID:      UUID.String(),
		Filename:  filename,
		Size:      size,
		Mime:      mimeType,
		UpdatedAt: time.Now().Unix(),
		CreatedAt: time.Now().Unix(),
	}
	if err = p._createPhoto(inPhoto); err != nil {
		log.Println(err)
		return nil, fmt.Errorf("Failed to save to DB")
	}
	outPhoto, err = p._getPhoto(inPhoto.UUID)
	if err != nil {
		log.Println(err)
		return nil, fmt.Errorf("Failed to load from DB")
	}

	return outPhoto, nil
}

// GetPhoto get photo
func (p PhotoRepo) GetPhoto(UUID string) (src io.ReadCloser, err error) {
	src, err = p._readFromDisk(UUID, false)
	if err != nil {
		return nil, err
	}
	return src, nil
}

// GetPhotoThumbnail get thumbnail
func (p PhotoRepo) GetPhotoThumbnail(UUID string) (src io.ReadCloser, err error) {
	src, err = p._readFromDisk(UUID, true)
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

const (
	thumbWidth  = 320
	thumbHeight = 320
)

// create thumbnail
func (p PhotoRepo) _createThumbnail(UUID string, mimeType string) {
	reader, err := p._readFromDisk(UUID, false)
	if err != nil {
		log.Fatalln(err)
	}

	srcImage, _, err := image.Decode(reader)
	if err != nil {
		log.Fatalln(err)
	}

	originW := srcImage.Bounds().Max.X
	originH := srcImage.Bounds().Max.Y

	var ratioW float64 = 1.0
	var ratioH float64 = 1.0
	if originW > thumbWidth {
		ratioW = float64(originW) / thumbWidth
	}
	if originH > thumbHeight {
		ratioH = float64(originH) / thumbHeight
	}

	var ratio float64 = 1
	if ratioH > ratioW {
		ratio = ratioW
	} else {
		ratio = ratioH
	}

	var finalW int
	var finalH int
	if ratio > 1 {
		// need to resize
		finalW = int(float64(originW) / ratio)
		finalH = int(float64(originH) / ratio)
		srcImage = resize.Resize(uint(finalW), uint(finalH), srcImage, resize.Bilinear)
	} else {
		finalW = originW
		finalH = originH
	}

	dstImage := image.NewRGBA(image.Rect(0, 0, finalW, finalH))
	draw.Draw(dstImage, image.Rect(0, 0, finalW, finalH), srcImage, image.ZP, draw.Src)

	dst, err := p._getFileHandler(UUID, true)
	if err != nil {
		log.Fatalln(err)
	}

	if mimeType == "image/png" {
		png.Encode(dst, dstImage)
	} else {
		jpeg.Encode(dst, dstImage, &jpeg.Options{Quality: jpeg.DefaultQuality})
	}
}

func (p PhotoRepo) _getFileHandler(UUID string, thumbnail bool) (writer io.WriteCloser, err error) {
	p.createPhotoFolder()
	localPath := path.Join(p.db.GetDataFolder(), "photos", UUID)
	if thumbnail {
		localPath += "_thumbnail"
	}

	f, err := os.Create(localPath)
	if err != nil {
		return nil, err
	}
	return f, nil
}

// Write to disk
func (p PhotoRepo) _writeToDisk(src io.Reader, dst io.Writer) (err error) {
	_, err = io.Copy(dst, src)
	if err != nil {
		return err
	}
	return nil
}

func (p PhotoRepo) _readFromDisk(UUID string, thumbnail bool) (reader io.ReadCloser, err error) {

	localPath := path.Join(p.db.GetDataFolder(), "photos", UUID)
	if thumbnail {
		localPath += "_thumbnail"
	}

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
	originPath := path.Join(p.db.GetDataFolder(), "photos", UUID)
	os.Remove(originPath)

	thumbnailPath := path.Join(p.db.GetDataFolder(), "photos", UUID+"_thumbnail")
	os.Remove(thumbnailPath)
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
