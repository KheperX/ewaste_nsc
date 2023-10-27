import 'package:flutter/material.dart';
import 'package:mysql1/mysql1.dart';
import 'package:app/collector/receive_task.dart';

class ViewRequest extends StatefulWidget {
  const ViewRequest({super.key});

  @override
  State<ViewRequest> createState() => _ViewRequestState();
}

class _ViewRequestState extends State<ViewRequest> {
  int _counter = 0;
  var db = new Mysql();
  var item = [];
  var ewaste_type = [];
  var request = [];
  Set<int> selectedItems = Set<int>();
  bool value = false;

  @override
  void initState() {
    super.initState();
    _getItem();
  }

  void _getItem() {
    db.getConnection().then((conn) {
      String sql =
          'SELECT * FROM item JOIN request ON item.req_id = request.req_id';
      conn.query(sql).then((results) {
        List<Map<String, dynamic>> items = [];
        for (var row in results) {
          items.add({
            'id': row['item_id'],
            'name': row['item_name'],
            'description': row['item_desc'],
            'image_url': row['img_url'],
            'amount': row['amount'],
            'lat': row['pick_lat'],
            'lng': row['pick_lng'],
            'detail': row['pick_detail'],
          });
        }
        setState(() {
          item = items;
        });
      });
    });
  }

  void _calculateDistance() {}

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: Text('คำขอส่งขยะจากผู้ใช้'),
      ),
      body: ListView.builder(
        itemCount: item.length,
        padding: EdgeInsets.all(5),
        itemBuilder: (BuildContext context, int index) {
          return Card(
              child: ListTile(
            title: Column(
              children: [
                // Text('รหัสสินค้า: ${item[index]['id']}'),
                Text('ชื่อสินค้า: ${item[index]['name']}'),
                Text('จำนวน: ${item[index]["amount"]}'),
                Text('ละติจูด: ${item[index]["lat"]} '),
                Text('ลองจิจูด: ${item[index]["lng"]} '),
                Text('เขต: ${item[index]["detail"]} '),
              ],
            ),
            // subtitle: Text('Item name: ${item[index][1]}'),
            leading: Image.network(
              '${item[index]["image_url"]}',
              width: 100,
              height: 100,
            ),
            trailing: Checkbox(
                value: selectedItems.contains(index),
                onChanged: (value) {
                  setState(() {
                    if (value == true) {
                      selectedItems.add(index);
                    } else {
                      selectedItems.remove(index);
                    }
                  });
                }),
          ));
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          List<Map<String, dynamic>> selectedList = [];
          for (int i = 0; i < item.length; i++) {
            if (selectedItems.contains(i)) {
              selectedList.add(item[i]);
            }
          }
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => receiveTask(selectedList: selectedList)),
          );
        },
        label: const Text('คลิกหน้าถัดไป'),
        icon: const Icon(Icons.skip_next_outlined),
        backgroundColor: Colors.green,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}

class Mysql {
  static String host = 'utcccs.cj5octuotk3f.ap-northeast-1.rds.amazonaws.com',
      user = 'ewuser',
      password = 'ewuser123',
      db = 'ewastedb';

  static int port = 3306;

  Mysql();

  Future<MySqlConnection> getConnection() async {
    var settings = new ConnectionSettings(
        host: host, port: port, user: user, password: password, db: db);

    return await MySqlConnection.connect(settings);
  }
}
