import 'dart:async';
// import 'dart:nativewrappers/_internal/vm/lib/core_patch.dart';
import 'package:flutter/material.dart';
import 'package:mynotes/services/crud/crud_exception.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p show join;


class NotesService {
  Database? _db;

  Future<DatabaseNote> updateNote ({required DatabaseNote  note,required String text,}) async{
    final db = await _getDatabaseOrThrow();
    await getNote(id: note.id);
    final updatCount = await db.update(notesTable, {
      noteColumn:text,
      isSyncWithCloudColumn: 0,
    });
    if(updatCount == 0) {
      throw CouldNotUpdateNote();
    } else {
      return await getNote(id: note.id);
    }
  }

  Future<Iterable<DatabaseNote>> getAllNotes () async{
    final db = await _getDatabaseOrThrow();
    final notes = await db.query(notesTable);

    return notes.map((noteRow) => DatabaseNote.fromRow(noteRow));
  }
  
  Future<DatabaseNote> getNote({required int id}) async {
    final db = await _getDatabaseOrThrow();
    final notes = await db.query('notes',limit: 1, where: 'id = ?', whereArgs: [id]);
    if(notes.isEmpty){
      throw CouldNotFoundNote();
    }
    return DatabaseNote.fromRow(notes.first);
  }

  Future<int> deleteAllNote() async {
    final db = await _getDatabaseOrThrow();
    return await db.delete(notesTable);
  }

  Future<void> deleteNote({required int id}) async {
    final dbUser = await _getDatabaseOrThrow();
    final deleteCount = await dbUser.delete(
      userTable,
      where: 'id = ?',
      whereArgs: [id],
    );
    if (deleteCount != 1) {
      throw CouldNotDeletNote();
    }
  }

  Future<DatabaseNote> createNote({required DatabaseUser owner}) async{
    final db = await _getDatabaseOrThrow();

    final dbUser = await getUser(email:owner.email);
    if(dbUser!=owner){
      throw CouldNotFoundUser();
    }

    const text = '';
    final noteId = await db.insert(notesTable, {
      userIdColumn : owner.id,
      noteColumn : text,
      isSyncWithCloudColumn: 1,
    });

    final note = DatabaseNote(id: noteId, userId: owner.id, note: text, isSyncWithCloud: true);
    return note;
  }
  // method to get user
  Future<DatabaseUser> getUser({required String email}) async {
    final db = await _getDatabaseOrThrow();
    final result = await db.query(
    userTable,
    limit: 1,
    where: 'email = ?',
    whereArgs: [email.toLowerCase()],
  );
  if(result.isEmpty){
    throw UserDoesNotExist();
  } else {
    return DatabaseUser.fromRow(result.first);
  }
  }
//  method to create user
  Future<DatabaseUser> createUser({required String email}) async {
  final db = await _getDatabaseOrThrow(); // Await the database fetch

  // Check if user already exists
  final result = await db.query(
    userTable,
    limit: 1,
    where: 'email = ?',
    whereArgs: [email.toLowerCase()],
  );
  
  if (result.isNotEmpty) {
    throw UserAlreadyExist(); // User already exists, throw an exception
  }

  // Insert new user
  final userId = await db.insert(userTable, {
    emailColumn: email.toLowerCase(),
  });

  // Return the newly created user
  return DatabaseUser(
    id: userId,
    email: email.toLowerCase(),
  );
}


  // Method to delete user by email
  Future<void> deleteUser({required String email}) async {
    final dbUser = await _getDatabaseOrThrow();
    final deleteCount = await dbUser.delete(
      userTable,
      where: 'email = ?',
      whereArgs: [email.toLowerCase()],
    );
    if (deleteCount != 1) {
      throw CouldNotDeletUser();
    }
  }

  // Method to get the database or throw an exception if not open
  Future<Database> _getDatabaseOrThrow() async {
    final db = _db;
    if (db == null) {
      throw DatabaseNotOpen();
    } else {
      return db;
    }
  }

  // Method to close the database
  Future<void> close() async {
    final db = _db;
    if (db == null) {
      throw DatabaseNotOpen();
    } else {
      await db.close();
      _db = null;
    }
  }

  // Method to open the database and create tables
  Future<void> open() async {
    if (_db != null) {
      throw DatabaseAlreadyOpenException();
    }
    try {
      final docsPath = await getApplicationDocumentsDirectory();
      final dbPath = p.join(docsPath.path, dbName);
      final db = await openDatabase(dbPath);
      _db = db;

      // Create User Table
      await db.execute(createUserTable);
      // Create Notes Table
      await db.execute(createNotesTable);
    } on MissingPlatformDirectoryException {
      throw UnabletoGetDocumentsAuthException();
    }
  }
}

@immutable
class DatabaseUser {
  final int id;
  final String email;

  const DatabaseUser({
    required this.id,
    required this.email,
  });

  // Create DatabaseUser from a Map (SQL Row)
  DatabaseUser.fromRow(Map<String, Object?> map)
      : id = map[idColumn] as int,
        email = map[emailColumn] as String;

  @override
  String toString() => 'Person, ID=$id, Email=$email';

  @override
  bool operator ==(covariant DatabaseUser other) => id == other.id;

  @override
  int get hashCode => id.hashCode;
}

class DatabaseNote {
  final int id;
  final int userId;
  final String note;
  final bool isSyncWithCloud;

  DatabaseNote({
    required this.id,
    required this.userId,
    required this.note,
    required this.isSyncWithCloud,
  });

  // Create DatabaseNote from a Map (SQL Row)
  DatabaseNote.fromRow(Map<String, Object?> map)
      : id = map[idColumn] as int,
        userId = map[userIdColumn] as int,
        note = map[noteColumn] as String,
        isSyncWithCloud = (map[isSyncWithCloudColumn] as int) == 1 ? true : false;

  @override
  String toString() => 'Note, ID=$id, userId=$userId, isSyncWithCloud=$isSyncWithCloud,text=&note';

  @override
  bool operator ==(covariant DatabaseNote other) => id == other.id;

  @override
  int get hashCode => id.hashCode;
}

// Database constants
const dbName = 'notes.db';
const notesTable = 'notes';
const userTable = 'user';
const idColumn = 'id';
const emailColumn = 'email';
const userIdColumn = 'user_id';
const noteColumn = 'note';
const isSyncWithCloudColumn = 'is_sync_with_cloud';

// SQL queries for creating tables
const createUserTable = '''
CREATE TABLE IF NOT EXISTS "user" (
	"id"	INTEGER NOT NULL,
	"email"	TEXT NOT NULL UNIQUE,
	PRIMARY KEY("id" AUTOINCREMENT)
); 
''';

const createNotesTable = '''
CREATE TABLE IF NOT EXISTS "notes" (
	"id"	INTEGER NOT NULL,
	"user_id"	INTEGER NOT NULL,
	"note"	TEXT,
	"is_sync_with_cloud"	INTEGER NOT NULL DEFAULT 0,
	PRIMARY KEY("id" AUTOINCREMENT),
	FOREIGN KEY("user_id") REFERENCES "user"("id")
);
''';
