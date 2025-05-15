import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:io';
import 'package:employ_management/models/employee.dart';

class DBHelper {
  static final DBHelper _instance = DBHelper._internal();
  factory DBHelper() => _instance;
  DBHelper._internal();

  static Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await initDB();
    return _db!;
  }

  Future<Database> initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'employee.db');

    return await openDatabase(
      path,
      version: 3, // bumped version for upgrade
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE employees (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT,
            contactNumber TEXT,
            hobby TEXT,
            designation TEXT,
            email TEXT,
            imagePath TEXT
          )
        ''');

        await db.execute('''
          CREATE TABLE attendance (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            employeeId INTEGER,
            status TEXT,
            date TEXT,
            FOREIGN KEY (employeeId) REFERENCES employees(id)
          )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        print("Upgrading database from version $oldVersion to $newVersion");

        if (oldVersion < 2) {
          // Add designation column if upgrading from version 1
          await db.execute('ALTER TABLE employees ADD COLUMN designation TEXT');
        }

        if (oldVersion < 3) {
          // SQLite doesn't support direct column rename
          // So we need to create a new table, copy data, and drop the old one

          // 1. Create a new table with the updated schema
          await db.execute('''
            CREATE TABLE employees_new (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              name TEXT,
              contactNumber TEXT,
              hobby TEXT,
              designation TEXT,
              email TEXT,
              imagePath TEXT
            )
          ''');

          // 2. Copy data from old table to new table (with column mapping)
          await db.execute('''
            INSERT INTO employees_new (id, name, contactNumber, hobby, designation, email, imagePath)
            SELECT id, name, empId, department, designation, email, imagePath FROM employees
          ''');

          // 3. Drop the old table
          await db.execute('DROP TABLE employees');

          // 4. Rename the new table to the original name
          await db.execute('ALTER TABLE employees_new RENAME TO employees');

          print("Schema upgrade to version 3 completed successfully");
        }
      },
    );
  }

  // Helper method to reset the database (for troubleshooting)
  Future<void> resetDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'employee.db');

    print("Attempting to delete database at: $path");

    // Close the database before deleting
    if (_db != null) {
      await _db!.close();
      _db = null;
    }

    try {
      // Delete the database file
      await deleteDatabase(path);
      print("Database deleted successfully");
    } catch (e) {
      print("Error deleting database: $e");
    }

    // Reinitialize the database
    _db = await initDB();
    print("Database reinitialized");
  }

  // -------------------- Employee CRUD --------------------

  Future<int> insertEmployee(Employee employee) async {
    final db = await database;
    try {
      print("Database: Preparing to insert employee");
      print("Database: Employee data: ${employee.toMap()}");
      final result = await db.insert('employees', employee.toMap());
      print("Database: Insert successful with id: $result");
      return result;
    } catch (e) {
      print('Error inserting employee: $e');
      // Let's get the database schema to debug
      try {
        final tableInfo = await db.rawQuery("PRAGMA table_info(employees)");
        print("Database schema: $tableInfo");
      } catch (e2) {
        print("Could not get schema: $e2");
      }
      return -1; // indicate failure
    }
  }

  Future<List<Employee>> getEmployees() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('employees');
    return List.generate(maps.length, (i) => Employee.fromMap(maps[i]));
  }

  Future<int> updateEmployee(Employee employee) async {
    final db = await database;
    return await db.update(
      'employees',
      employee.toMap(),
      where: 'id = ?',
      whereArgs: [employee.id],
    );
  }

  Future<int> deleteEmployee(int id) async {
    final db = await database;
    return await db.delete('employees', where: 'id = ?', whereArgs: [id]);
  }

  // -------------------- Attendance Operations --------------------

  Future<int> insertAttendance({
    required int employeeId,
    required String status,
    required String date,
  }) async {
    final db = await database;
    return await db.insert('attendance', {
      'employeeId': employeeId,
      'status': status,
      'date': date,
    });
  }

  Future<int> getEmployeeCount() async {
    final db = await database;
    final result = await db.rawQuery('SELECT COUNT(*) FROM employees');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<int> getAttendanceCountFor(String status) async {
    final db = await database;
    final today = DateTime.now().toIso8601String().split('T')[0];
    final result = await db.rawQuery(
      'SELECT COUNT(*) FROM attendance WHERE status = ? AND date = ?',
      [status, today],
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }
  Future<int> getAttendanceCountForDate(String status, String date) async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) FROM attendance WHERE status = ? AND date = ?',
      [status, date],
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }


  Future<int> deleteAttendance(int id) async {
    final db = await database;
    return await db.delete('attendance', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Map<String, dynamic>>> getAttendanceByDate(String date) async {
    final db = await database;
    return await db.query('attendance', where: 'date = ?', whereArgs: [date]);
  }
}
