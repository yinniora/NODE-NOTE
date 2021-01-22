import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'widget/dayNumSelector.dart';
import 'widget/nodeDetail.dart';

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
        resizeToAvoidBottomPadding: false,
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
  var _focusNode = new FocusNode();
  var dayNumCon = new TextEditingController();
  var dayNumFocus = new FocusNode();
  var nodeDetailContrl = new TextEditingController();
  var nodeDetailFocus = new FocusNode();
  int hintT = 1;
  var _storageString = '';
  var noteData = {};

  //存储所有的提醒事项的数组
  var noteList = List();
  var time = '';
  var date = '';
  bool selected = true;
  bool noNodes = true; //有没有已经存储的提醒

  @override
  Widget build(BuildContext context) {
    // noteList.clear();
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
                  onPressed: () => {
                    setState(() {
                      selected = false;
                      FocusScope.of(context).requestFocus(_focusNode);
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
                      FocusScope.of(context).requestFocus(_focusNode);
                    });
                  },
                  child: Center(
                    child: AnimatedContainer(
                      height: selected ? 60 : 350,
                      duration: Duration(seconds: 1), //动画持续时间
                      curve: Curves.fastOutSlowIn, //差值器（动画效果）
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
                                        focusNode: _focusNode,
                                        keyboardType: TextInputType.text,
                                        maxLines: selected ? 2 : 7,
                                        decoration: InputDecoration(
                                          contentPadding: EdgeInsets.fromLTRB(
                                              15, 30, 10, 0),
                                          labelText: '',
                                          hintText: '',
                                          helperText: '',
                                          border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(5),
                                              borderSide: BorderSide.none),
                                          fillColor: Color(0xffFFEFD5),
                                          filled: true,
                                        ),
                                        textInputAction: TextInputAction.done,
                                        autofocus: false,
                                        style: TextStyle(
                                          fontSize: 20,
                                        ),


                                      ),
                                    )
                                  ],
                                )),
                                //时间日期选项
                                new Container(
                                  margin: EdgeInsets.fromLTRB(0, 0, 0, 10),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      new IconButton(
                                        icon: new Icon(Icons.schedule),
                                        onPressed: () => _showTimePicker(),
                                      ),
                                      //设置时间
                                      new IconButton(
                                          icon: new Icon(Icons.today_outlined),
                                          onPressed: () => _showDataPicker()),
                                      //日期
                                      dayNumSelector(
                                          dayNumCon: dayNumCon,
                                          dayNumFocus: dayNumFocus), //天数
                                    ],
                                  ),
                                ),
                                //提交按钮
                                new Container(
                                    margin: EdgeInsets.fromLTRB(0, 5, 0, 0),
                                    child: Column(
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                          children: [
                                            new Container(
                                                child: Container(
                                              height: 30,
                                              width: 100,
                                              decoration: new BoxDecoration(
                                                  color: Colors.lightBlueAccent,
                                                  borderRadius:
                                                      BorderRadius.all(
                                                          Radius.circular(
                                                              10.0))),
                                              child: MaterialButton(
                                                  onPressed: () {
                                                    setState(() {
                                                      var _tempMessage =
                                                          nodeController.text
                                                              .trim();
                                                      print(_tempMessage);
                                                      if (_tempMessage !=
                                                              null &&
                                                          _tempMessage != '') {
                                                        noteList.add({
                                                          'message': nodeController.text,
                                                          'time': time,
                                                          'date': date,
                                                          'dayNum': dayNumCon.text
                                                        });
                                                      } else {
                                                        Scaffold.of(context)
                                                            .showSnackBar(SnackBar(
                                                                content: Text(
                                                                    '您并没有保存任何信息')));
                                                      }
                                                      selected = true;
                                                      _focusNode.unfocus();
                                                      dayNumFocus.unfocus();
                                                      nodeController.clear();
                                                      dayNumCon.clear();
                                                      time='';
                                                      date='';
                                                    });
                                                  },
                                                  child: Text(
                                                    "保存",
                                                    style: TextStyle(
                                                        color: Colors.white,
                                                        fontWeight:
                                                            FontWeight.w600),
                                                  )),
                                            )),
                                            new Container(
                                                child: Container(
                                              height: 30,
                                              width: 100,
                                              decoration: new BoxDecoration(
                                                  color: Colors.redAccent,
                                                  borderRadius:
                                                      BorderRadius.all(
                                                          Radius.circular(
                                                              10.0))),
                                              child: MaterialButton(
                                                  onPressed: () {
                                                    nodeController.clear();
                                                    dayNumCon.clear();
                                                    FocusScope.of(context)
                                                        .requestFocus(
                                                            _focusNode);
                                                    time='';
                                                    date='';
                                                  },
                                                  child: Text(
                                                    "重置",
                                                    style: TextStyle(
                                                        color: Colors.white,
                                                        fontWeight:
                                                            FontWeight.w600),
                                                  )),
                                            ))
                                          ],
                                        ),
                                        new Container(
                                          alignment: Alignment.center,
                                          height: 30,
                                          margin: EdgeInsets.only(top: 5),
                                          child: IconButton(
                                            icon: Icon(
                                              Icons.keyboard_arrow_up,
                                              color: Colors.grey,
                                            ),
                                            onPressed: () {
                                              setState(() {
                                                selected = true;
                                              });
                                              _focusNode.unfocus();
                                            },
                                          ),
                                        )
                                      ],
                                    )),
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

          //显示已经添加的提醒事项列表
          noteList.length == 0
              ? new Card(
                  margin: EdgeInsets.fromLTRB(25, 0, 25, 10),
                  child: Container(
                    constraints: BoxConstraints(minHeight: 130),
                    child: Center(
                        child: Text(
                      "暂无内容",
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    )),
                  ))
              : new Expanded(
                  child: Card(
                    elevation:selected? 15.0 : 2.0,
                    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(16.0))),
                  margin: EdgeInsets.fromLTRB(20, 0, 20, 10),
                  color: Color(0xffF5F5F5),
                  child: Container(
                    padding: EdgeInsets.fromLTRB(0, 15, 0, 5),
                    child: ListView.builder(
                        itemCount: noteList.length,
                        shrinkWrap: true,
                        itemBuilder: (context, index) {
                          // print(noteList);
                          return GestureDetector(
                            onTap: (){
                              _navigateToMessageDetail(context,noteList[index]);
                            },
                            child: Card(
                              shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(20.0))),
                              color: Color(0xffFFFAF0),
                              margin: EdgeInsets.all(7),
                              child: new Container(
                                  padding: EdgeInsets.all(5),
                                  child: Column(children: [
                                    new ListTile(
                                      title: Text('${noteList[index]['message']}'),
                                    ),
                                  ],
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                  )
                              ),
                            ),
                          );
                        }),
                  ),
                )),
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
  var _tempTime;
  var _tempDate;

  _showTimePicker() async {
    var picker =
        await showTimePicker(context: context, initialTime: TimeOfDay.now());
    setState(() {
      _tempTime = picker.toString().substring(10,15);
      time = _tempTime;
    });
    print(time);
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
      _tempDate = picker.toString().substring(0, 9);
      date = _tempDate;
    });
    print(date);
  }

  //跳转页面
  _navigateToMessageDetail(BuildContext context,message) async{
    final result = await Navigator.push(context, MaterialPageRoute(builder: (context)=> nodeDetail(message:message,nodeDetailContrl:nodeDetailContrl,nodeDetailFocus:nodeDetailFocus)));
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
