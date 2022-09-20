import 'package:sqflite/sqflite.dart';

class Dbconnect {
  Database? db;

  Dbconnect() {
    initializeDB();
  }

  //static Database? _database;

  Future<Database> initializeDB() async {
    return await openDatabase('ecom.db', version: 1,
        onCreate: (Database db, int version) async {
      // When creating the db, create the table
      await db.execute('''CREATE TABLE cart (
            id INTEGER PRIMARY KEY,
            product_id INTEGER,
            image CHAR(500),
            title CHAR(100),
            sku CHAR(100),
            quantity CHAR(10),
            price  CHAR(10) ,
            total_price CHAR(10),
            order_id CHAR(10)) 
            ''');
    });
  }

  Future<int> insertData(tablename, insertDataObject) async {
    final Database db = await initializeDB();
    int id2 = await db.insert(tablename, insertDataObject.toMap());
    return id2;
  }

  Future<List<dynamic>> getDataByQuery(String query) async {
    final Database db = await initializeDB();
    List maps = await db.rawQuery(query);
    if (maps.isEmpty) {
      print("no data");
      return [
        {"id": 0}
      ];
    } else {
      return maps;
    }
  }

  Future<Map> updateTable(
      String tablename, Map<String, dynamic> updateList, int primaryKey) async {
    final Database db = await initializeDB();
    List updateListData = [];
    List updateValue = [];
    updateList.forEach((key, value) {
      String column = "$key = ?";
      updateListData.add(column);
      updateValue.add(value);
    });
    await db.update(
      tablename,
      updateList,
      where: 'id = ?',
      whereArgs: [primaryKey],
    );
    return updateList;
  }

  String queryCreator(Map inputlist) {
    List inputListData = [];
    inputlist.forEach((key, value) {
      String column = "$key = ?";
      inputListData.add(column);
    });
    return inputListData.join(", ");
  }

  Future<void> deleteTableData(String tablename) async {
    final Database db = await initializeDB();
    await db.delete(tablename);
  }

  Future<int> updateTableCondition(
      String tablename, Map updateList, Map updateConditions) async {
    final Database db = await initializeDB();
    String updateString = queryCreator(updateList);
    String updateConditionString = queryCreator(updateConditions);

    List updatevalues =
        updateList.values.toList() + updateConditions.values.toList();

    String query =
        'UPDATE $tablename SET $updateString WHERE $updateConditionString';
    print('updated: $query');
    int count = await db.rawUpdate(query, updatevalues);
    print('updated: $count');
    return count;
  }
}
