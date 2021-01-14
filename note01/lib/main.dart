import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';


void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '记事本',
      theme: new ThemeData(
        primaryColor: Colors.white,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: Text('提醒事项'),
        ),
        body: Center(
          child: RandomWorlds(),
        ),
      ),
    );
  }
}

class RandomWorlds extends StatefulWidget {
  @override
  _RandomWorldsState createState() => _RandomWorldsState();
}

class _RandomWorldsState extends State<RandomWorlds> {
  var nodeController = new TextEditingController();
  var _storageString = '';
  var noteData = {};
  var hintM = "添加提醒……";
  //存储所有的提醒事项的数组
  var noteList = List();



  @override
  Widget build(BuildContext context) {
    return buildContainer();
  }

  Container buildContainer() {
    return Container(
      child: new Column(
        children: [
          /*输入框*/
          new Container(
            child: Row(children: [
              new Container(
                child: Icon(
                  Icons.bookmark_border,
                  size: 25,
                ),
                margin: EdgeInsets.fromLTRB(0, 0, 5, 10),
              ),
              new Expanded(
                child: TextField(
                  controller: nodeController,
                  keyboardType: TextInputType.text,
                  maxLines: null,
                  onChanged: subAction(),
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.fromLTRB(15, 0, 10, 0),
                    labelText: hintM,
                    hintText: "",
                    helperText: '',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5),
                        borderSide: BorderSide.none),
                    filled: true,
                  ),
                  autofocus: false,
                  style: TextStyle(
                    fontSize: 20,
                  ),
                ),
              )
            ]),
            margin: EdgeInsets.fromLTRB(10, 30, 10, 30),
          ),


          /*提醒列表显示*/
          new Container(
              //显示已经添加的提醒事项列表
              )
        ],
      ),
    );
  }

  //设置时间和日期，并保存信息到集合
  subAction(){
    print(nodeController.value.text);
    if(nodeController.value.text.toString() != null && nodeController.value.text.toString() != ''){
      print(nodeController.value.text);
      noteData["note"] = nodeController.value.text.toString();
      hintM = '正在添加…';
    }else{
        hintM = '添加提醒……';
    }
    // DatePicker.showTimePicker(context,
    //   showTitleActions: true,
    //   onConfirm: (date){
    //     noteData["time"] = date;
    //   //  设定闹铃
    //   //  保存数据
    //     noteList.add(noteData);
    //   },
    //   currentTime: DateTime.now(),
    // );
  }

  //利用SharedPreferences存储数据
  Future saveString() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setString(nodeController.value.text.toString(),
        nodeController.value.text.toString());
  }

//获取存在SharedPreferences中的数据
  Future getString() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    setState(() {
      _storageString =
          sharedPreferences.get(nodeController.value.text.toString());
    });
  }

  //获取所有数据
  Future getAllString() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    setState(() {
      Set<String> keys = sharedPreferences.getKeys();
      for (var item in keys) {
        noteList.add(item);
      }
    });
  }

  //删除操作
  Future deleteString() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    //  key
    sharedPreferences.remove(nodeController.value.text.toString());
    //清空所有
    // sharedPreferences.clear();
  }

  //改操作
  Future updateString() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setString(nodeController.value.text.toString(),
        nodeController.value.text.toString());
  }

}
