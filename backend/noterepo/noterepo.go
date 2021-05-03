package noterepo

// TODO: error cases

import (
	"log"
	"storyboard/backend/interfaces"

	"database/sql"
	"fmt"
)

// Note is defined in interfaces
type Note = interfaces.Note

// NoteRepo is Note repository implement
type NoteRepo struct {
	db interfaces.DatabaseService
}

// NewNoteRepo create instance of note repo
func NewNoteRepo(db interfaces.DatabaseService) NoteRepo {
	return NoteRepo{db}
}

// CreateNote in DB
func (t NoteRepo) CreateNote(inNote Note) (outNote *Note, err error) {
	// create note
	if err := t._createNote(inNote); err != nil {
		return nil, err
	}
	outNote, err = t._getNote(inNote.UUID)
	if err != nil {
		return nil, err
	}
	return outNote, nil
}

// UpdateNote in DB
func (t NoteRepo) UpdateNote(UUID string, inNote Note) (outNote *Note, err error) {
	note, err := t._getNote(UUID)
	if err != nil {
		return nil, fmt.Errorf("Note is not existed")
	}

	inNote.UUID = UUID
	inNote.CreatedAt = note.CreatedAt

	if err := t._updateNote(inNote); err != nil {
		return nil, err
	}
	outNote, err = t._getNote(UUID)
	if err != nil {
		return nil, err
	}
	return outNote, nil
}

// DeleteNote in DB
func (t NoteRepo) DeleteNote(UUID string, updatedAt int64) (outNote *Note, err error) {
	if err := t._deleteNote(UUID, updatedAt); err != nil {
		return nil, err
	}
	outNote, err = t._getNote(UUID)
	if err != nil {
		return nil, err
	}
	return outNote, nil
}

// GetNoteByUUID in DB
func (t NoteRepo) GetNoteByUUID(UUID string) (outNote *Note, err error) {
	outNote, err = t._getNote(UUID)
	if err != nil {
		return nil, err
	}
	return outNote, nil
}

func (t NoteRepo) _createNote(note Note) error {
	db := t.db.GetConnection()
	stmt, err := db.Prepare("INSERT INTO `notes` (" +
		"uuid, title, updatedAt, createdAt, _ts" +
		") VALUES (:uuid, :title, :updatedAt, :createdAt, :ts)")
	if err != nil {
		return err
	}

	ts := t.db.GetTS()

	result, err := stmt.Exec(
		sql.Named("uuid", note.UUID),
		sql.Named("title", note.Title),
		sql.Named("updatedAt", note.UpdatedAt),
		sql.Named("createdAt", note.CreatedAt),
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
	return fmt.Errorf("Failed to create note")
}

// UpdateNote in DB
func (t NoteRepo) _updateNote(note Note) error {
	db := t.db.GetConnection()
	stmt, err := db.Prepare("UPDATE `notes` SET " +
		"`title` = :title, " +
		"`updatedAt` = :updatedAt, " +
		"`_ts` = :ts " +
		"WHERE `uuid` = :uuid ")
	if err != nil {
		return err
	}

	ts := t.db.GetTS()

	result, err := stmt.Exec(
		sql.Named("title", note.Title),
		sql.Named("updatedAt", note.UpdatedAt),
		sql.Named("uuid", note.UUID),
		sql.Named("ts", ts),
	)
	if err != nil {
		return err
	}

	affectRow, err := result.RowsAffected()
	if err != nil {
		return err
	}

	log.Printf("Updated: %t\n", affectRow > 0)
	if affectRow > 0 {
		return nil
	}
	return fmt.Errorf("Failed to update note")
}

// DeleteNote in DB
func (t NoteRepo) _deleteNote(UUID string, updatedAt int64) error {
	db := t.db.GetConnection()
	stmt, err := db.Prepare("UPDATE `notes` SET " +
		"`deleted` = 1," +
		"`updatedAt` = :updatedAt," +
		"`_ts` = :ts " +
		"WHERE `uuid` = :uuid ")
	if err != nil {
		return err
	}

	ts := t.db.GetTS()

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

	log.Printf("Deleted: %t\n", affectRow > 0)
	if affectRow > 0 {
		return nil
	}
	return fmt.Errorf("Failed to delete note")
}

// GetNote in DB
func (t NoteRepo) _getNote(UUID string) (*Note, error) {
	db := t.db.GetConnection()
	stmt, err := db.Prepare("SELECT uuid, title, deleted, updatedAt, createdAt, _ts " +
		"FROM `notes` WHERE `uuid` = :uuid ")
	if err != nil {
		return nil, err
	}

	row := stmt.QueryRow(sql.Named("uuid", UUID))

	var note Note
	err = row.Scan(
		&note.UUID, &note.Title, &note.Deleted,
		&note.UpdatedAt, &note.CreatedAt, &note.TS,
	)
	if err == sql.ErrNoRows {
		return nil, err
	}
	return &note, nil
}

// GetNotesByTS in DB
func (t NoteRepo) GetNotesByTS(ts int64, limit int, offset int) (notes []Note, err error) {
	db := t.db.GetConnection()
	stmt, err := db.Prepare("SELECT uuid, title, deleted, updatedAt, createdAt, _ts " +
		"FROM `notes` WHERE `_ts` >= :ts ORDER BY `_ts` ASC LIMIT :limit OFFSET :offset")
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

	notes = make([]Note, 0, limit)
	for rows.Next() {
		var note Note
		rows.Scan(
			&note.UUID, &note.Title, &note.Deleted,
			&note.UpdatedAt, &note.CreatedAt, &note.TS,
		)
		notes = append(notes, note)
	}
	return notes, nil
}
