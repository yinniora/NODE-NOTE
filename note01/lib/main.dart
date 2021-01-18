import 'package:flutter/cupertino.dart';
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

  //存储所有的提醒事项的数组
  var noteList = List();
  bool selected = false;

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
                child: IconButton(
                   icon: new Icon(Icons.bookmark_border),
                  onPressed: ()=>{
                     setState((){
                       selected = false;
                     })
                  },
                ),
                margin: EdgeInsets.fromLTRB(0, 15, 0, 10),
              ),
              new Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      selected = false;
                    });
                  },
                  child: Center(
                    child: AnimatedContainer(
                      height: selected ? 60 : 330,
                      duration: Duration(seconds: 2), //动画持续时间
                      curve: Curves.fastLinearToSlowEaseIn, //差值器（动画效果）
                      child: Card(
                        child: ListView(
                          shrinkWrap: true,
                          children: [
                            new Column(
                              children: [
                                new Container(
                                    child: Column(
                                  children: [
                                    selected
                                        ? new Container(
                                            height: 50,
                                            padding: EdgeInsets.fromLTRB(
                                                15, 0, 0, 0),
                                            decoration: new BoxDecoration(
                                              color: Colors.blueGrey,
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(5.0)),
                                            ),
                                            child: Row(
                                              children: [
                                                Text(
                                                  "添加提醒",
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ],
                                            ))
                                        : new Container(),
                                    new Container(
                                      child: TextField(
                                        controller: nodeController,
                                        keyboardType: TextInputType.text,
                                        maxLines: selected ? 2 : 7,
                                        decoration: InputDecoration(
                                          contentPadding: EdgeInsets.fromLTRB(
                                              15, 30, 10, 0),
                                          labelText: '',
                                          hintText: "",
                                          helperText: '',
                                          border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(5),
                                              borderSide: BorderSide.none),
                                          filled: true,
                                        ),
                                        autofocus: true,
                                        style: TextStyle(
                                          fontSize: 20,
                                        ),
                                      ),
                                    )
                                  ],
                                )),
                                //提交按钮
                                new Container(
                                  margin: EdgeInsets.fromLTRB(0, 0, 0, 10),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      new IconButton(
                                        icon: new Icon(Icons.schedule),
                                        onPressed: () =>_showTimePicker(),
                                      ), //设置时间
                                      new IconButton(
                                          icon: new Icon(
                                              Icons.today_outlined),
                                          onPressed: () => _showDataPicker()), //日期
                                      new IconButton(
                                        icon: new Icon(Icons.calendar_view_day_outlined),
                                        onPressed: () => _dayNumSelector(),
                                      )//天数
                                    ],
                                  ),
                                ),
                                new Container(
                                    alignment: Alignment.center,
                                    margin: EdgeInsets.fromLTRB(0, 0, 0, 15),
                                    child: Container(
                                      height: 30,
                                      width: 100,
                                      decoration: new BoxDecoration(
                                          color: Colors.lightBlueAccent,
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(10.0))),
                                      child: MaterialButton(
                                          onPressed: (){
                                            setState(() {
                                              selected = true;
                                            });
                                          },
                                          child: Text(
                                            "保存",
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.w600),
                                          )),
                                    ))
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                //动画效果拉伸收缩输入框
              )
            ]),
            margin: EdgeInsets.fromLTRB(10, 30, 10, 30),
          ),

          /*提醒列表显示*/
          new Container(
            //显示已经添加的提醒事项列表
            child: ListView.builder(
                itemCount: noteList.length,
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  return Card(
                    child: new Column(
                      children: [
                        ListTile(
                          title: Text('${noteList[index]}'),
                        )
                      ],
                    ),
                  );
                }),
          )
        ],
      ),
    );
  }

  //保存信息到集合
  subAction() {
    print(nodeController.value.text);
    if (nodeController.value.text.toString() != null &&
        nodeController.value.text.toString() != '') {
      print(nodeController.value.text);
      noteData["note"] = nodeController.value.text.toString();
      noteList.add(noteData);
    }
  }

  //时间选择器和日期选择器
  var _time;
  var _date;
  var _dayNum;
  _showTimePicker() async {
    var picker =
    await showTimePicker(context: context, initialTime: TimeOfDay.now());
    setState(() {
      _time = picker.toString();
    });
    print(_time);
  }
  _showDataPicker() async {
    Locale myLocale = Localizations.localeOf(context);
    var picker = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime.now(),
        lastDate: DateTime(2040),
        locale: myLocale);
    setState(() {
      _date =picker.toString().substring(0,9);
    });
    print(_date);
  }
  _dayNumSelector() {
    var dayList = [];
    for(int i=1;i<=30;i++){
      dayList.add('${i}');
    }
    print(dayList);
    var datListStr = dayList.join(',');
    print(datListStr);
    return DropdownButton(
      onChanged: (String newValue){
        setState(() {
          _dayNum = newValue;
        });
        print(_dayNum);
      },
      items: <String>[datListStr].map<DropdownMenuItem<String>>((String value) {
      return DropdownMenuItem<String>(
        value: value,
        child: Text(value),
      );
    }).toList(),
    );
  }//天数选择



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
