package photorepo

import (
	"io"
	"log"
	"os"
	"path"
	"storyboard/backend/database"
	"storyboard/backend/interfaces"
	"storyboard/backend/mocks"
	"testing"
	"time"

	"github.com/google/uuid"
	"github.com/stretchr/testify/assert"
)

const testVendorName = "Laterhorse_"
const testAppName = "Storyboard_"
const testDBName = "foo_photo_"

func initDB(suffix string) interfaces.DatabaseService {
	conf := &mocks.ConfigMock{
		GetAppNameFn: func() string {
			return testAppName + suffix
		},
		GetDatabaseNameFn: func() string {
			return testDBName + suffix + ".db"
		},
	}
	db := database.NewDatabaseService(conf)
	folder := db.GetDataFolder()
	os.Remove(path.Join(folder, "photos"))

	db.Init()
	return db
}

func destoyDB(suffix string, db interfaces.DatabaseService) {
	db.Close()

	folder := db.GetDataFolder()
	os.Remove(path.Join(folder, testDBName+suffix+".db"))
	os.Remove(path.Join(folder, "photos"))
	os.Remove(folder)
}

func _testAdd(t *testing.T, photoRepo PhotoRepo) *Photo {
	reader, err := os.Open("./photorepo_test.jpg")
	if err != nil {
		t.Errorf("Failed to open photo: %v", err)
	}

	uuid := uuid.New().String()
	filename := "filename"
	mime := "image/jpeg"
	size := "2048000"
	ts := time.Now().Unix()
	createdPhoto, err := photoRepo.AddPhoto(uuid, filename, mime, size, reader, ts)
	if err != nil {
		log.Fatalf("Failed to add photo: %v\n", err)
	}

	nownano := time.Now().UnixNano()

	assert.Equal(t, createdPhoto.UUID, uuid)
	assert.Equal(t, createdPhoto.Filename, filename)
	assert.Equal(t, createdPhoto.Mime, mime)
	assert.Equal(t, createdPhoto.Size, size)
	assert.Equal(t, createdPhoto.Deleted, int8(0))
	assert.Equal(t, createdPhoto.CreatedAt, ts)
	assert.Equal(t, createdPhoto.UpdatedAt, ts)
	assert.Less(t, nownano-2000000000, createdPhoto.TS)
	assert.Greater(t, nownano+2000000000, createdPhoto.TS)

	return createdPhoto
}

func _testGet(t *testing.T, photoRepo PhotoRepo, createdPhoto *Photo) {
	raw, err := photoRepo.GetPhoto(createdPhoto.UUID)
	if err != nil {
		log.Fatalf("Failed to get photo: %v\n", err)
	}
	defer raw.Close()

	buff := make([]byte, 1024)
	tot := 0
	for {
		n, err := raw.Read(buff)
		if err != nil {
			if err == io.EOF {
				break
			}
			log.Fatalf("Failed to get photo buff: %v\n", err)
		}
		tot += n
	}
	if tot == 0 {
		log.Fatalf("Size of photo is 0\n")
	}
}

func _testThumb(t *testing.T, photoRepo PhotoRepo, createdPhoto *Photo) {
	raw, err := photoRepo.GetPhotoThumbnail(createdPhoto.UUID)
	if err != nil {
		log.Fatalf("Failed to get thumbnail: %v\n", err)
	}

	buff := make([]byte, 1024)
	tot := 0
	for {
		n, err := raw.Read(buff)
		if err != nil {
			if err == io.EOF {
				break
			}
			log.Fatalf("Failed to get thumbnail buff: %v\n", err)
		}
		tot += n
	}
	if tot == 0 {
		log.Fatalf("Size of thumbnail is 0\n")
	}
}

func _testMeta(t *testing.T, photoRepo PhotoRepo, createdPhoto *Photo) {
	getPhoto, err := photoRepo.GetPhotoMeta(createdPhoto.UUID)
	if err != nil {
		log.Fatalf("Failed to get meta: %v\n", err)
	}

	assert.Equal(t, getPhoto.UUID, createdPhoto.UUID)
	assert.Equal(t, getPhoto.Filename, createdPhoto.Filename)
	assert.Equal(t, getPhoto.Size, createdPhoto.Size)
	assert.Equal(t, getPhoto.Mime, createdPhoto.Mime)
	assert.Equal(t, getPhoto.Deleted, int8(0))
	assert.Equal(t, getPhoto.CreatedAt, createdPhoto.CreatedAt)
	assert.Equal(t, getPhoto.UpdatedAt, createdPhoto.UpdatedAt)
	assert.Equal(t, getPhoto.TS, createdPhoto.TS)
}

func _testDelete(t *testing.T, photoRepo PhotoRepo, createdPhoto *Photo) *Photo {
	ts := time.Now().Unix()
	deletedPhoto, err := photoRepo.DeletePhoto(createdPhoto.UUID, ts)
	if err != nil {
		log.Fatalf("Failed to delete: %v\n", err)
	}

	nownano := time.Now().UnixNano()
	assert.Equal(t, deletedPhoto.UUID, createdPhoto.UUID)
	assert.Equal(t, deletedPhoto.Filename, createdPhoto.Filename)
	assert.Equal(t, deletedPhoto.Size, createdPhoto.Size)
	assert.Equal(t, deletedPhoto.Mime, createdPhoto.Mime)
	assert.Equal(t, deletedPhoto.Deleted, int8(1))
	assert.Equal(t, deletedPhoto.CreatedAt, createdPhoto.CreatedAt)
	assert.Equal(t, deletedPhoto.UpdatedAt, ts)
	assert.Less(t, nownano-2000000000, deletedPhoto.TS)
	assert.Greater(t, nownano+2000000000, deletedPhoto.TS)

	return deletedPhoto
}

func _testGetList(t *testing.T, photoRepo PhotoRepo, deletedPhoto *Photo) {
	photos, err := photoRepo.GetPhotoMetaByTS(0, 10, 0)
	if err != nil {
		log.Fatalf("Failed to get list: %v\n", err)
	}

	assert.Equal(t, photos[0].UUID, deletedPhoto.UUID)
	assert.Equal(t, photos[0].Filename, deletedPhoto.Filename)
	assert.Equal(t, photos[0].Size, deletedPhoto.Size)
	assert.Equal(t, photos[0].Mime, deletedPhoto.Mime)
	assert.Equal(t, photos[0].Deleted, int8(1))
	assert.Equal(t, photos[0].CreatedAt, deletedPhoto.CreatedAt)
	assert.Equal(t, photos[0].UpdatedAt, deletedPhoto.UpdatedAt)
	assert.Equal(t, photos[0].TS, deletedPhoto.TS)
}

func TestPhotoRepo(t *testing.T) {
	db := initDB("test")
	defer destoyDB("test", db)

	photoRepo := NewPhotoRepo(db)

	createdPhoto := _testAdd(t, photoRepo)

	_testGet(t, photoRepo, createdPhoto)
	_testThumb(t, photoRepo, createdPhoto)

	_testMeta(t, photoRepo, createdPhoto)

	time.Sleep(time.Second * 1)
	deletedPhoto := _testDelete(t, photoRepo, createdPhoto)

	_testGetList(t, photoRepo, deletedPhoto)
}
