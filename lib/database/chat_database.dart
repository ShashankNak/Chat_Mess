import 'dart:developer';
import 'dart:io';
import 'package:chat_mess/models/chat_user_model.dart';
import 'package:chat_mess/widgets/consts.dart';
import 'package:sqflite/sqflite.dart';

class ChatDatabase {
  static final ChatDatabase instance = ChatDatabase._init();
  static Database? _database;
  ChatDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB(userChatdb);
    return _database!;
  }

  Future<Database> _initDB(String fpath) async {
    final dpath = await createInternalFolder(userChatfolder);
    final path = '$dpath/$fpath';
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future closeDB() async {
    final db = await instance.database;
    db.close();
  }

  Future<void> deleteDatabaseFile() async {
    final dpath = await createInternalFolder(userChatfolder);
    final dbPath = '$dpath/$userChatdb';
    log(dbPath);
    try {
      if (await File(dbPath).exists()) {
        log("existed");
        // Delete the database file
        await deleteDatabase(dbPath);
        log('Database deleted successfully');
      } else {
        log('Database does not exist');
      }
    } catch (e) {
      log(e.toString());
    }
    // Check if the database file exists
  }

  Future _createDB(Database db, int version) async {
    const textType = "TEXT";
    const integerType = "INTEGER";

    await db.execute('''
      CREATE TABLE $tabelChatUser (
        ${ChatUserFields.uid} $textType PRIMARY KEY,
        ${ChatUserFields.name} $textType,
        ${ChatUserFields.about} $textType,
        ${ChatUserFields.phoneNumber} $textType,
        ${ChatUserFields.image} $textType,
        ${ChatUserFields.createdAt} $textType,
        ${ChatUserFields.isOnline} $integerType,
        ${ChatUserFields.lastActive} $textType,
        ${ChatUserFields.pushToken} $textType
      )
      ''');
  }

  Future<void> insertingUser(ChatUser user) async {
    final db = await instance.database;
    int uid;
    try {
      if (await userExists(user.uid)) {
        log("User ${user.name} Already exist in db");
      } else {
        uid = await db.insert(tabelChatUser, user.toJson());
        log("user added: ${uid.toString()}");
      }
    } catch (e) {
      log(e.toString());
    }
  }

  Future<bool> userExists(String uid) async {
    final db = await instance.database;
    final result = await db.query(
      tabelChatUser,
      where: '${ChatUserFields.uid} = ?',
      whereArgs: [uid],
    );
    return result.isNotEmpty;
  }

  Future<ChatUser?> readUser(String uid) async {
    final db = await instance.database;
    final maps = await db.query(
      tabelChatUser,
      where: '${ChatUserFields.uid} = ?',
      whereArgs: [uid],
    );

    if (maps.isNotEmpty) {
      return ChatUser.fromJson(maps.first);
    } else {
      log("return empty");
      return null;
    }
  }

  Future<List<ChatUser>> readAllUsers() async {
    final db = await instance.database;
    const orderBy = '${ChatUserFields.lastActive} ASC';
    // final maps =
    //     await db.rawQuery('SELECT * FROM $tabelChatUser ORDER BY $orderBy');

    final result = await db.query(tabelChatUser, orderBy: orderBy);

    return result.map((e) => ChatUser.fromJson(e)).toList();
  }

  Future<void> updateUser(ChatUser user) async {
    final db = await instance.database;
    final n = db.update(tabelChatUser, user.toJson(),
        where: '${ChatUserFields.uid} = ?', whereArgs: [user.uid]);
    log(n.toString());
  }

  Future<void> deteteUser(String uid) async {
    final db = await instance.database;
    final n = db.delete(tabelChatUser,
        where: '${ChatUserFields.uid} = ?', whereArgs: [uid]);
    log(n.toString());
  }
}
