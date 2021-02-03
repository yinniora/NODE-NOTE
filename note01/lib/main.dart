import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'widget/dayNumSelector.dart';
import 'widget/nodeDetail.dart';
import 'dart:convert' as JSON;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: '记事本',
        theme: new ThemeData(
          primaryColor: Colors.white,
        ),
        home: RandomWorlds());
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
    //开启软件时初始化数组元素以及添加本地提醒
    getAllData().then((value) => noteList = value);

    //通知初始化
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('app_icon');
    final IOSInitializationSettings initializationSettingsIOS =
        IOSInitializationSettings(
            onDidReceiveLocalNotification: onDidReceiveLocalNotification);
    final InitializationSettings initializationSettings =
        InitializationSettings(
            android: initializationSettingsAndroid,
            iOS: initializationSettingsIOS);
    flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: onSelectNotification);
    tz.initializeTimeZones();
  }

  @override
  Widget build(BuildContext context) {
    getAllData().then((value) => noteList = value);
    //初始化通知
    _initNotifications(noteList);
    // deleteAll();
    // noteList.clear();

    return Scaffold(
      resizeToAvoidBottomPadding: false,
      appBar: AppBar(
        title: Text('提醒事项'),
        actions: [
          TextButton.icon(
              onPressed: () {
                _removeAllnote();
              },
              icon: Icon(
                Icons.restore_from_trash_rounded,
                color: Colors.blueGrey,
              ),
              label: Text(''))
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
                                      new Row(
                                        children: [
                                          new IconButton(
                                            icon: new Icon(Icons.schedule),
                                            onPressed: () => _showTimePicker(),
                                          ),
                                          new Text(time != null && time != ''
                                              ? '${time}'
                                              : ''),
                                        ],
                                      ),
                                      //设置时间
                                      new Row(
                                        children: [
                                          new IconButton(
                                              icon: new Icon(
                                                  Icons.today_outlined),
                                              onPressed: () =>
                                                  _showDataPicker()),
                                          new Text(date != null && date != ''
                                              ? '${date}'
                                              : ''),
                                        ],
                                      ),
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
                                                        saveAction(
                                                            nodeController.text,
                                                            time,
                                                            date,
                                                            dayNumCon.text);
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
                                                      time = '';
                                                      date = '';
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
                                                      time = '';
                                                      date = '';
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
              : new Expanded(child: Builder(
                  builder: (BuildContext context) {
                    return Card(
                      elevation: selected ? 15.0 : 2.0,
                      shape: const RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.all(Radius.circular(16.0))),
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
                                  onTap: () {
                                    _navigateToMessageDetail(
                                        context, noteList[index]);
                                  },
                                  child: Dismissible(
                                    key: Key(UniqueKey().toString()),
                                    direction: DismissDirection.endToStart,
                                    onDismissed: (direction) {
                                      setState(() {
                                        deleteString(noteList[index]['key']);
                                        noteList.removeAt(index);
                                      });
                                    },
                                    dismissThresholds: {
                                      DismissDirection.endToStart: 0.6
                                    },
                                    background: Card(
                                        margin: EdgeInsets.all(10),
                                        color: Colors.redAccent,
                                        shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(15))),
                                        child: Container(
                                          alignment: Alignment.centerRight,
                                          padding: EdgeInsets.only(right: 10),
                                          child: Icon(
                                            Icons.restore_from_trash,
                                            color: Colors.white,
                                          ),
                                        )),
                                    child: Card(
                                      shape: const RoundedRectangleBorder(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(20.0))),
                                      color: Color(0xffFFFAF0),
                                      margin: EdgeInsets.all(7),
                                      child: new Container(
                                          padding: EdgeInsets.all(5),
                                          child: Column(
                                            children: [
                                              new ListTile(
                                                title: Text(
                                                    '${noteList[index]['message']}'),
                                              ),
                                            ],
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                          )),
                                    ),
                                  ));
                            }),
                      ),
                    );
                  },
                )),
        ],
      ),
    );
  }

  _initNotifications(List _list){
    _cancelAllNotifications();
    for(var item in _list){
      //需要判断在有日期有时间没有天数的情况下，日期是否过期
      if(item['date']!=null&&item['date']!=''&&item['time']!=null&&item['time']!=''&&(item['dayNum']==null||item['dayNum']=='')){
        int _year = int.parse(item['date'].substring(0,4));
        int _month = int.parse(item['date'].substring(5,7));
        int _days = int.parse(item['date'].substring(8));
        DateTime scheduleDate = DateTime(_year,_month,_days);
        DateTime now = DateTime.now();
        if(scheduleDate.isAfter(now)){
          _showDateTimeDaysNotification(item['date'],item['time'],item['dayNum'],item['storeTime'],item['message']);
        }else{
          return;
        }
      }else{
        _showDateTimeDaysNotification(item['date'],item['time'],item['dayNum'],item['storeTime'],item['message']);
      }
    }
  }

  //保存信息到集合
  saveAction(nodeMsg, time, date, dayNum) {
    String randomNum = '';
    for (int i = 0; i < 4; i++) {
      var temp = Random().nextInt(10);
      randomNum += temp.toString();
    }
    var msg = {
      'key': nodeMsg + "(" + randomNum + ")",
      'message': nodeMsg,
      'time': time,
      'date': date,
      'dayNum': dayNum,
      'storeTime': DateTime.now().toString()
    };
    String saveTemp = JSON.jsonEncode(msg);
    saveString(msg['key'], saveTemp);
    //更新一下notelist
    getAllData().then((value) => noteList = value);
  }

  //时间选择器和日期选择器
  var _tempTime;
  var _tempDate;

  _showTimePicker() async {
    var picker = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
        builder: (context, child) {
          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            child: Theme(
              data: ThemeData.light(),
              child: child,
            ),
          );
        });
    if (picker != null) {
      setState(() {
        _tempTime = picker.toString().substring(10, 15);
        time = _tempTime;
      });
      print(time);
    }
  }

  _showDataPicker() async {
    Locale myLocale = Localizations.localeOf(context);
    var picker = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime.now(),
        lastDate: DateTime(2040),
        locale: myLocale,
        builder: (context, child) {
          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            child: Theme(
              data: ThemeData.light(),
              child: child,
            ),
          );
        });
    if (picker != null) {
      setState(() {
        _tempDate = picker.toString().substring(0, 10);
        date = _tempDate;
      });
      print(date);
    }
  }

  //跳转页面
  _navigateToMessageDetail(BuildContext context, message) async {
    final result = await Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => nodeDetail(message: message)))
        .whenComplete(() => setState(() {}));
  }

  _removeAllnote() {
    showCupertinoDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            content: new Text(
              '全部清空',
              style: TextStyle(color: Colors.redAccent),
            ),
            actions: [
              new TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(true);
                  },
                  child: Text(
                    '确定',
                    style: TextStyle(color: Colors.blueGrey),
                  )),
              new TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(false);
                  },
                  child: Text(
                    '取消',
                    style: TextStyle(color: Colors.blue),
                  )),
            ],
          );
        }).then((value) {
      print(value);
      if (value == true) {
        deleteAll();
        setState(() {});
      }
    });
  }

  //利用SharedPreferences存储数据
  Future saveString(key, msg) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setString(key, msg);
  }

//获取存在SharedPreferences中的某一项数据
  Future getString(key) async {
    var tempMap = new Map();
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    setState(() {
      tempMap = JSON.jsonDecode(sharedPreferences.get(key));
    });
  }

  //获取所有数据 resList为拿值的空数组
  Future getAllData() async {
    List list = [];
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    Set<String> keys = sharedPreferences.getKeys();
    if (keys != '' && keys != null) {
      for (var item in keys) {
        var content = sharedPreferences.get(item);
        Map msgMap = JSON.jsonDecode(content);
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
  Future updateString(key, msg) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setString(key, msg);
  }

  /*
  *
  *    手机通知设置
  *
  * */

  //安卓定时通知处理方法
  Future _showScheduledNotification(String _date, String _time) async {
    //安卓的通知配置，必填参数是渠道id, 名称, 和描述, 可选填通知的图标，重要度等等。
    var androidPlatformChannelSpecifics = new AndroidNotificationDetails(
        '0', 'your channel name', 'your channel description',
        icon: 'app_icon',
        importance: Importance.max,
        priority: Priority.high,
        ticker: 'ticker');
    NotificationDetails platformChannelSpecifics =
        new NotificationDetails(android: androidPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.zonedSchedule(0, 'NODE & NOTE',
        '提醒事项：', _scheduledDate(_date, _time), platformChannelSpecifics,
        androidAllowWhileIdle: true,
        payload: 'item x',
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime);
  }
  tz.TZDateTime _scheduledDate(String _date, String _time) {
    String _dateTime = _date + ' ' + _time;
    tz.TZDateTime scheduledDate = tz.TZDateTime.parse(tz.local, _dateTime);
    print(tz.TZDateTime.now(tz.local));
    return scheduledDate;
  }

  //只設置時間沒設置日期，按每日提醒處理
  //每日提醒
  Future _showDailyTimeNotification(String _time) async {
    var androidPlatformChannelSpecifics = new AndroidNotificationDetails(
        '1', 'channelName', 'channelDescription',
        icon: 'app_icon',
        importance: Importance.high,
        priority: Priority.max,
        ticker: 'ticker1');
    NotificationDetails platformChannelSpecifics =
        new NotificationDetails(android: androidPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.zonedSchedule(0, 'NODE & NOTE',
        '提醒事项：', _scheduledDailyDate(_time), platformChannelSpecifics,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        androidAllowWhileIdle: true);
  }
  tz.TZDateTime _scheduledDailyDate(String _time) {
    int _hours = int.parse(_time.substring(0,2));
    int _minutes = int.parse(_time.substring(3,5));
    tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate =
        tz.TZDateTime(tz.local, now.year, now.month, now.day, _hours, _minutes);
    if (scheduledDate.isBefore(now)) {
      scheduledDate.add(Duration(days: 1));
    }
    return scheduledDate;
  }

  //优化通知
  Future _showDateTimeDaysNotification(String _date,String _time,String _dayNum,String _storeTime,String _message) async {
    var androidPlatformChannelSpecifics = new AndroidNotificationDetails(
        '1', 'channelName', 'channelDescription',
        icon: 'app_icon',
        importance: Importance.high,
        priority: Priority.max,
        ticker: 'ticker1');
    NotificationDetails platformChannelSpecifics =
    new NotificationDetails(android: androidPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.zonedSchedule(1000, 'NODE & NOTE',
        '提醒事项：${_message}', _scheduledDateTimeDays(_date,_time,_dayNum,_storeTime), platformChannelSpecifics,
        uiLocalNotificationDateInterpretation:
        UILocalNotificationDateInterpretation.absoluteTime,
        androidAllowWhileIdle: true);
  }
  tz.TZDateTime _scheduledDateTimeDays(String _date,String _time,String _dayNum,String _storeTime) {
    var _dayNumTemp = 0;
    if(_time!=null&&_time!=''){
      if(_date!=null&&_date!=''){
        if(_dayNum!=null&&_dayNum!=''){
          //有时间有日期有天数
          int _year = int.parse(_date.substring(0,4));
          int _month = int.parse(_date.substring(5,7));
          int _days = int.parse(_date.substring(8));
          int _hours = int.parse(_time.substring(0,2));
          int _minutes = int.parse(_time.substring(3,5));
          tz.TZDateTime now = tz.TZDateTime.now(tz.local);
          tz.TZDateTime scheduledDate = tz.TZDateTime(tz.local, _year, _month,_days, _hours, _minutes); //计划日期
          tz.TZDateTime scheduleEndDay =  tz.TZDateTime(tz.local, _year, _month,_days+int.parse(_dayNum)); //计划持续几天的结束日期
          if (scheduledDate.isBefore(now)&&scheduledDate.isBefore(scheduleEndDay)) {
            scheduledDate.add(Duration(days: 1));
          }
          return scheduledDate;
        }else{
          //有时间有日期没天数(需要日期没过期)
          tz.TZDateTime now = tz.TZDateTime.now(tz.local);
            int _year = int.parse(_date.substring(0,4));
            int _month = int.parse(_date.substring(5,7));
            int _days = int.parse(_date.substring(8));
            int _hours = int.parse(_time.substring(0,2));
            int _minutes = int.parse(_time.substring(3,5));
            tz.TZDateTime scheduledDate = tz.TZDateTime(tz.local, _year, _month,_days, _hours, _minutes);
            return scheduledDate;
        }
      }else{
        if(_dayNum!=null&&_dayNum!=''){
          //有时间没日期有天数
          int _hours = int.parse(_time.substring(0,2));
          int _minutes = int.parse(_time.substring(3,5));
          tz.TZDateTime now = tz.TZDateTime.now(tz.local);
          tz.TZDateTime scheduledDate = tz.TZDateTime(tz.local, now.year, now.month,now.day, _hours, _minutes); //计划日期
          tz.TZDateTime scheduleEndDay = tz.TZDateTime.parse(tz.local, _storeTime);
          if (scheduledDate.isBefore(now)&&scheduledDate.isBefore(scheduleEndDay)) {
            scheduledDate.add(Duration(days: 1));
          }
          return scheduledDate;
        }else{
          //有时间没日期没天数
          int _hours = int.parse(_time.substring(0,2));
          int _minutes = int.parse(_time.substring(3,5));
          tz.TZDateTime now = tz.TZDateTime.now(tz.local);
          tz.TZDateTime scheduledDate = tz.TZDateTime(tz.local, now.year, now.month,now.day, _hours, _minutes); //计划日期
          if (scheduledDate.isBefore(now)) {
            scheduledDate.add(Duration(days: 1));
          }
          return scheduledDate;
        }
      }
    }else{
      if(_date!=null&&_date!=''){
        if(_dayNum!=null&&_dayNum!=''){
          //没时间有日期有天数(预订没时间按每天早六点)
          int _year = int.parse(_date.substring(0,4));
          int _month = int.parse(_date.substring(5,7));
          int _days = int.parse(_date.substring(8));
          tz.TZDateTime now = tz.TZDateTime.now(tz.local);
          tz.TZDateTime scheduledDate = tz.TZDateTime(tz.local, _year, _month,_days, 6); //计划日期
          tz.TZDateTime scheduleEndDay =  tz.TZDateTime(tz.local, _year, _month,_days+int.parse(_dayNum)); //计划持续几天的结束日期
          if (scheduledDate.isBefore(now)&&scheduledDate.isBefore(scheduleEndDay)) {
            scheduledDate.add(Duration(days: 1));
          }
          return scheduledDate;
        }else{
          //没时间有日期没天数(预订没时间按每天早六点)
          int _year = int.parse(_date.substring(0,4));
          int _month = int.parse(_date.substring(5,7));
          int _days = int.parse(_date.substring(8));
          tz.TZDateTime scheduledDate = tz.TZDateTime(tz.local, _year, _month,_days, 6); //计划日期
          return scheduledDate;
        }
      }else{
        if(_dayNum!=null&&_dayNum!=''){
          //没时间没日期有天数(预订没时间按每天早六点)
          tz.TZDateTime now = tz.TZDateTime.now(tz.local);
          tz.TZDateTime scheduledDate = tz.TZDateTime(tz.local,  now.year, now.month,now.day, 6); //计划日期
          tz.TZDateTime scheduleEndDay =  tz.TZDateTime.parse(tz.local, _storeTime); //计划持续几天的结束日期
          if (scheduledDate.isBefore(now)&&scheduledDate.isBefore(scheduleEndDay)) {
            scheduledDate.add(Duration(days: 1));
          }
          return scheduledDate;
        }
      }
    }
  }

  //只有日期没有时间，当天六点提醒
  Future _showDailyAtSixNotification(String _date) async{
    var androidPlatformChannelSpecifics = new AndroidNotificationDetails('channelId', 'channelName', 'channelDescription',
    priority: Priority.high,importance: Importance.max,icon: "app_icon");
    NotificationDetails platformChannelSpecifics = new NotificationDetails(android: androidPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.zonedSchedule(001, 'NODE & NOTE',
        '提醒事项：', _scheduledDateAtSix(_date), platformChannelSpecifics,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        androidAllowWhileIdle: true);
  }
  tz.TZDateTime _scheduledDateAtSix(String _date){
    int _year = int.parse(_date.substring(0,4));
    int _month = int.parse(_date.substring(5,7));
    int _day = int.parse(_date.substring(8));
    tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDateTime = tz.TZDateTime(tz.local,_year,_month,_day,6);
    if(scheduledDateTime.isBefore(now)){
      scheduledDateTime = scheduledDateTime.add(Duration(days: 1));
    }
    return scheduledDateTime;
  }

  //删除单个通知
  Future _cancelNotification(notiId) async {
    //参数 0 为需要删除的通知的id
    await flutterLocalNotificationsPlugin.cancel(notiId);
  }

//删除所有通知
  Future _cancelAllNotifications() async {
    await flutterLocalNotificationsPlugin.cancelAll();
  }

  //在适当的位置 申请手机通知权限
  _useIOSNotification() async {
    final bool result = await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
  }


  //点击通知后应触发的函数
  Future onSelectNotification(String payload) async {
    if (payload != null) {
      debugPrint('notification payload: $payload');
    }
    //payload 可作为通知的一个标记，区分点击的通知。
    if (payload != null && payload == "complete") {}
  }

  //ios通知处理方法
  Future onDidReceiveLocalNotification(
      int id, String title, String body, String payload) async {
    // display a dialog with the notification details, tap ok to go to another page
    showDialog(
      context: context,
      builder: (BuildContext context) => CupertinoAlertDialog(
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

  //初始化工作（初始化list和初始化）
}
