import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'widget/dayNumSelector.dart';
import 'widget/nodeDetail.dart';
import 'dart:convert' as JSON;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '记事本',
      theme: new ThemeData(
        primaryColor: Colors.white,
      ),
      home:RandomWorlds()
    );
  }
}

class RandomWorlds extends StatefulWidget {
  @override
  _RandomWorldsState createState() => _RandomWorldsState();
}

class _RandomWorldsState extends State<RandomWorlds> {
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();
  var nodeController = new TextEditingController();
  var _focusNode = new FocusNode();
  var dayNumCon = new TextEditingController();
  var dayNumFocus = new FocusNode();
  int hintT = 1;
  var _storageString = '';
  var viewListKey = new GlobalKey();

  //存储所有的提醒事项的数组
  var noteList = List();

  var time = '';
  var date = '';
  bool selected = true;
  bool noNodes = true; //有没有已经存储的提醒

  @override
  void initState() {
    super.initState();
    //开启软件时初始化数组元素
    getAllData().then((value) => noteList=value);

    //通知初始化
    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('app_icon');
    final IOSInitializationSettings initializationSettingsIOS =
    IOSInitializationSettings(
        requestSoundPermission: false,
        requestBadgePermission: false,
        requestAlertPermission: false,
        onDidReceiveLocalNotification: onDidReceiveLocalNotification);
    final InitializationSettings initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid,
        iOS: initializationSettingsIOS);
    flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: onSelectNotification);
  }

  @override
  Widget build(BuildContext context) {
    getAllData().then((value) => noteList=value);
    print(noteList);
    // deleteAll();
    // noteList.clear();
    return Scaffold(
      resizeToAvoidBottomPadding: false,
      appBar: AppBar(
        title: Text('提醒事项'),
        actions: [
          TextButton.icon(onPressed: (){_removeAllnote();}, icon: Icon(Icons.restore_from_trash_rounded,color: Colors.blueGrey,), label: Text(''))
        ],
      ),
      body: Center(
        child: buildContainer(),
      ),
    );
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
                                      new Row(children: [
                                        new IconButton(
                                          icon: new Icon(Icons.schedule),
                                          onPressed: () => _showTimePicker(),
                                        ),
                                        new Text(time!=null&&time!=''?'${time}':''),
                                      ],),
                                      //设置时间
                                      new Row(children: [
                                        new IconButton(
                                            icon: new Icon(Icons.today_outlined),
                                            onPressed: () => _showDataPicker()),
                                        new Text(date!=null&&date!=''?'${date}':''),
                                      ],),
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
                                                    var _tempMessage =
                                                    nodeController.text
                                                        .trim();
                                                    setState(() {
                                                      if (_tempMessage !=
                                                              null &&
                                                          _tempMessage != '') {
                                                        saveAction(nodeController.text,time,date,dayNumCon.text);
                                                      } else {
                                                        Scaffold.of(context)
                                                            .showSnackBar(SnackBar(
                                                                content: Text(
                                                                    '您并没有填写任何提醒')));
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
                                                    setState(() {
                                                      nodeController.clear();
                                                      dayNumCon.clear();
                                                      FocusScope.of(context)
                                                          .requestFocus(
                                                          _focusNode);
                                                      time='';
                                                      date='';
                                                    });
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
                  child: Builder(
                    builder: (BuildContext context){
                      return Card(
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
                                var item = noteList[index].toString();
                                return GestureDetector(
                                    onTap: (){
                                      _navigateToMessageDetail(context,noteList[index]);
                                    },
                                    child: Dismissible(
                                      key: Key(UniqueKey().toString()),
                                      direction: DismissDirection.endToStart,
                                      onDismissed: (direction){
                                        setState(() {
                                          deleteString(noteList[index]['message']);
                                          noteList.removeAt(index);
                                        });
                                      },
                                      dismissThresholds: {DismissDirection.endToStart:0.6},
                                      background: Card(
                                          margin: EdgeInsets.all(10),
                                          color: Colors.redAccent,
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(15))),
                                          child: Container(
                                            alignment: Alignment.centerRight,
                                            padding: EdgeInsets.only(right: 10),
                                            child: Icon(
                                              Icons.restore_from_trash,
                                              color: Colors.white,
                                            ),
                                          )
                                      ),

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
                                    )
                                );
                              }),
                        ),
                      );
                    },
                  )),
        ],
      ),
    );
  }


  //保存信息到集合
  saveAction(nodeMsg,time,date,dayNum) {
    String randomNum='';
    for(int i=0; i<4;i++){
      var temp = Random().nextInt(10);
      randomNum += temp.toString();
    }
      var msg = {
        'key' : nodeMsg+"("+randomNum+")",
        'message': nodeMsg,
        'time': time,
        'date': date,
        'dayNum': dayNum
      };
      String saveTemp = JSON.jsonEncode(msg);
      saveString(msg['key'],saveTemp);
      //更新一下notelist
    getAllData().then((value) => noteList=value);
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
    final result = await Navigator.push(context, MaterialPageRoute(builder: (context)=> nodeDetail(message:message))).whenComplete(() => setState(() {
    }));

  }

  _removeAllnote(){
    showCupertinoDialog(context: context, builder: (BuildContext context){
      return AlertDialog(
        content: new Text('全部清空',style: TextStyle(color: Colors.redAccent),),
        actions: [
          new TextButton(onPressed: (){Navigator.of(context).pop(true);}, child: Text('确定',style: TextStyle(color: Colors.blueGrey),)),
          new TextButton(onPressed: (){Navigator.of(context).pop(false);}, child: Text('取消',style: TextStyle(color: Colors.blue),)),
        ],
      );
    }).then((value){
      print(value);
      if(value==true){
        deleteAll();
        setState(() {});
      }
    });
  }

  //利用SharedPreferences存储数据
  Future saveString(key,msg) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setString(key,
        msg);
  }

//获取存在SharedPreferences中的某一项数据
  Future getString(key) async {
    var tempMap = new Map();
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    setState(() {
      tempMap =
          JSON.jsonDecode(sharedPreferences.get(key));
    });
  }

  //获取所有数据 resList为拿值的空数组
  Future getAllData() async {
    List list = [];
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    Set<String> keys = sharedPreferences.getKeys();
    if(keys!=''&&keys!=null){
      for (var item in keys) {
        var content = sharedPreferences.get(item);
        Map msgMap =  JSON.jsonDecode(content);
        list.add(msgMap);
      }
      //将元素倒序排序（新node排在前面）
      // noteList = tempList.reversed.toList();
      // tempList = [];
      List res = [];
      res = list.reversed.toList();
      return res;
    }
  }


  //删除操作
  Future deleteString(key) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    //  key
    sharedPreferences.remove(key);
  }
  //删除操作
  Future deleteAll() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    //清空所有
    sharedPreferences.clear();
  }

  //改操作
  Future updateString(key,msg) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setString(key,
        msg);
  }

  /*
  *
  *    手机通知设置
  *
  * */
  //点击通知后应触发的函数
  Future onSelectNotification(String payload) async {
    if (payload != null) {
      debugPrint('notification payload: $payload');
    }
  }
  //ios通知处理方法
  Future onDidReceiveLocalNotification(
      int id, String title, String body, String payload) async {
    // display a dialog with the notification details, tap ok to go to another page
    showDialog(
      context: context,
      builder: (BuildContext context) =>
          CupertinoAlertDialog(
            title: Text(title),
            content: Text(body),
            actions: [
              CupertinoDialogAction(
                isDefaultAction: true,
                child: Text('Ok'),
                onPressed: () async {
                  Navigator.of(context, rootNavigator: true).pop();
                },
              )
            ],
          ),
    );
  }
  //安卓通知处理方法
  Future _showNotification() async {
    //安卓的通知配置，必填参数是渠道id, 名称, 和描述, 可选填通知的图标，重要度等等。
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
    AndroidNotificationDetails(
        'your channel id', 'your channel name', 'your channel description',
        importance: Importance.max,
        priority: Priority.high,
        showWhen: false);
    const NotificationDetails platformChannelSpecifics =
    NotificationDetails(android: androidPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
        0, 'plain title', 'plain body', platformChannelSpecifics,
        payload: 'item x');
  }

  //定期显示指定间隔的通知 (默认每天一次)
  Future _periodicallyDailyShow() async{
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
    AndroidNotificationDetails('repeating channel id',
        'repeating channel name', 'repeating description');
    const NotificationDetails platformChannelSpecifics =
    NotificationDetails(android: androidPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.periodicallyShow(0, 'repeating title',
        'repeating body', RepeatInterval.daily, platformChannelSpecifics,
        androidAllowWhileIdle: true);
  }

  //删除单个通知
  Future _cancelNotification() async {
    //参数 0 为需要删除的通知的id
    await flutterLocalNotificationsPlugin.cancel(0);
  }
//删除所有通知
  Future _cancelAllNotifications() async {
    await flutterLocalNotificationsPlugin.cancelAll();
  }


}
