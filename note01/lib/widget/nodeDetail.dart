import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:note01/widget/sharedPreferencesFunc.dart';
import 'dayNumSelector.dart';
import 'dart:convert' as JSON;

class nodeDetail extends StatefulWidget {
  const nodeDetail({Key key, @required this.message}) : super(key: key);
  final Map message;

  @override
  _nodeDetailState createState() => _nodeDetailState(message: message);
}

class _nodeDetailState extends State<nodeDetail> {
  _nodeDetailState({this.message});

  final Map message;

  var _scaffoldkey = new GlobalKey<ScaffoldState>();
  var nodeDetailContrl = new TextEditingController();
  var dayNumInputContrl = new TextEditingController();
  var dayNumInputFocus = new FocusNode();

  var nodeDetailFocus = new FocusNode();

  var time='';
  var date='';
  var dayNum='';

  //是否被编辑
  bool noChange = true;
  bool noTime = false; //是否设置了时间
  bool noDate = false; //是否设置了日期
  bool noDayNum = false; //是否设置了天数

  //是否更改信息
  bool messageUpdate = false;
  bool timeUpdate = false;
  bool dateUpdate = false;
  bool dayNumUpdate = false;
  bool updateAnyone = false;

  @override
  void dispose() {
    nodeDetailContrl.dispose(); //避免内存泄露
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    nodeDetailContrl.text = '${message['message']}';
    time = message['time'];
    date = message['date'];
    dayNum = message['dayNum'];
    nodeDetailContrl.addListener(() {
      _judgeUpdate();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (time == '' || time == null) {
      noTime = true;
    }
    if (date == '' || date == null) {
      noDate = true;
    }
    if (dayNum == '' || dayNum == null) {
      noDayNum = true;
    }
    if (messageUpdate == true ||
        timeUpdate == true ||
        dateUpdate == true ||
        dayNumUpdate == true) {
      updateAnyone = true;
    } else {
      updateAnyone = false;
    }
    print(message);

    return Scaffold(
      key: _scaffoldkey,
      resizeToAvoidBottomPadding: false,
      appBar: AppBar(
          automaticallyImplyLeading: false,
          leading: new IconButton(icon: Icon(Icons.arrow_back_ios), onPressed: (){
            nodeDetailFocus.unfocus();
            _backActionJudage();}),
          title: Text('提醒事项'), actions: [
        updateAnyone
            ? TextButton.icon(
                onPressed: () {
                  nodeDetailFocus.unfocus();
                  Navigator.pop(context,nodeDetailContrl.text);
                  _saveAction(nodeDetailContrl.text, time, date, dayNum);
                },
                icon: Icon(
                  Icons.done,
                  color: Colors.blue,
                  size: 15,
                ),
                label: Text(
                  '保存',
                  style: TextStyle(color: Colors.blue),
                ))
            : Text('')
      ]),
      body: new Builder(builder: (BuildContext context){
        return Center(
          child: Container(
              margin: EdgeInsets.all(10),
              child: Column(
                children: [
                  new Expanded(
                    child: Card(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(15))),
                      elevation: 10,
                      child: TextField(
                        controller: nodeDetailContrl,
                        focusNode: nodeDetailFocus,
                        autofocus: false,
                        maxLines: 50,
                        keyboardType: TextInputType.text,
                        textInputAction: TextInputAction.done,
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.all(20),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5),
                              borderSide: BorderSide.none),
                          fillColor: Color(0xffFFEFD5),
                          filled: true,
                        ),
                      ),
                    ),
                  ),
                  new Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      new RaisedButton(
                          color: Colors.blueGrey,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.all(Radius.circular(7))),
                          onPressed: () {
                            _showTimePicker();
                          },
                          child: new Text(
                            noTime ? '设置时间' : '时间：${time}',
                            style: TextStyle(fontSize: 12, color: Colors.white),
                          )),
                      new RaisedButton(
                          padding: EdgeInsets.all(5),
                          color: Colors.blueGrey,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.all(Radius.circular(7))),
                          onPressed: () {
                            _showDatePicker();
                          },
                          child: new Text(
                            noDate ? '设置日期' : '日期：${date}',
                            style: TextStyle(fontSize: 12, color: Colors.white),
                          )),
                      new RaisedButton(
                          color: Colors.blueGrey,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.all(Radius.circular(7))),
                          onPressed: () {
                            showCupertinoDialog(
                                context: context,
                                barrierDismissible: false,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    contentPadding: EdgeInsets.all(30),
                                    actionsPadding:
                                    EdgeInsets.fromLTRB(0, 0, 20, 0),
                                    elevation: 50,
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20)),
                                    content: new Container(
                                        child: new SizedBox(
                                          child: TextField(
                                            controller: dayNumInputContrl,
                                            focusNode: dayNumInputFocus,
                                            autofocus: false,
                                            keyboardType: TextInputType.number,
                                            inputFormatters: [
                                              FilteringTextInputFormatter.digitsOnly,
                                              LengthLimitingTextInputFormatter(3)
                                            ],
                                            maxLines: 1,
                                            textInputAction: TextInputAction.done,
                                            decoration: InputDecoration(
                                                prefixIcon:
                                                Icon(Icons.calendar_today),
                                                contentPadding: EdgeInsets.fromLTRB(
                                                    50, 10, 0, 10),
                                                labelText: '输入天数',
                                                labelStyle: TextStyle(
                                                    color: Colors.blue, fontSize: 15),
                                                border: OutlineInputBorder(
                                                    borderRadius:
                                                    BorderRadius.circular(8),
                                                    borderSide: BorderSide(
                                                      width: 1,
                                                      color: Colors.red,
                                                      style: BorderStyle.solid,
                                                    ))),
                                          ),
                                        )),
                                    actions: [
                                      new Row(
                                        children: [
                                          new TextButton(
                                            onPressed: () {
                                              Navigator.of(context).pop('ok');
                                              if (dayNumInputContrl.text !=
                                                  null &&
                                                  dayNumInputContrl.text != '') {
                                                _dayInputSave();
                                                print(dayNumInputContrl.text);
                                              }else{
                                                _scaffoldkey.currentState.showSnackBar(SnackBar(
                                                  content: Text('没有变更'),
                                                  duration: Duration(milliseconds: 800),
                                                ));
                                              }
                                            },
                                            child: Text(
                                              '保存',
                                              style: TextStyle(
                                                  color: Colors.blue,
                                                  fontSize: 15),
                                            ),
                                          ),
                                          new TextButton(
                                              onPressed: () {
                                                Navigator.of(context)
                                                    .pop('cancel');
                                                dayNumInputContrl.clear();
                                              },
                                              child: Text('取消',
                                                  style: TextStyle(
                                                      color: Colors.blueGrey,
                                                      fontSize: 15))),
                                        ],
                                      )
                                    ],
                                  );
                                });
                          },
                          child: new Text(
                            noDayNum ? '设置天数' : '持续：${dayNum}天',
                            style: TextStyle(fontSize: 12, color: Colors.white),
                          ))
                    ],
                  )
                ],
              )),
        );
      })
    );
  }

  _dayInputSave() {
    setState(() {
      dayNum = dayNumInputContrl.text;
      dayNumUpdate = true;
      noDayNum = false;
    });
  }
  
  _backActionJudage(){
    if(nodeDetailContrl.text==message['message'] && time==message['time'] && date==message['date'] && dayNum==message['dayNum']){
      Navigator.pop(context);
    }else{
      showCupertinoDialog(
          context: context,
          barrierDismissible: false, //防止用户在弹出筐外点击消失
          builder: (BuildContext context) {
            return AlertDialog(
              contentPadding: EdgeInsets.all(30),
              actionsPadding:
              EdgeInsets.fromLTRB(0, 0, 20, 0),
              elevation: 50,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              content: new Text('有更改，是否保存？'),
              actions: [
                new Row(
                  children: [
                    new TextButton(
                      onPressed: () {
                        _saveAction(nodeDetailContrl.text, time, date, dayNum);
                        Navigator.of(context).pop(true);
                      },
                      child: Text(
                        '保存',
                        style: TextStyle(
                            color: Colors.blue,
                            fontSize: 15),
                      ),
                    ),
                    new TextButton(
                        onPressed: () {
                          Navigator.of(context)
                              .pop(false);
                        },
                        child: Text('不保存',
                            style: TextStyle(
                                color: Colors.blue,
                                fontSize: 15))),
                  ],
                )
              ],
            );
          }).whenComplete(() => Navigator.pop(context));
    }
  }

  _saveAction(nodeMsg, time, date, dayNum) {
    var msg = {
      'key': message['key'],
      'message': nodeMsg,
      'time': time,
      'date': date,
      'dayNum': dayNum
    };
    String msgTemp = JSON.jsonEncode(msg);
    sharedPerencesFunc().updateString(message['key'], msgTemp);
  }

  _judgeUpdate() {
    setState(() {
      if (nodeDetailContrl.text != message['message'] &&
          nodeDetailContrl.text != '' &&
          nodeDetailContrl.text != null) {
        messageUpdate = true;
      } else {
        messageUpdate = false;
      }
      if (time != message['time'] && time != '' && time != null) {
        timeUpdate = true;
      } else {
        timeUpdate = false;
      }
      if (date != message['date'] && date != '' && date != null) {
        dateUpdate = true;
      } else {
        dateUpdate = false;
      }
      if (dayNum != message['dayNum'] && dayNum != '' && dayNum != null) {
        dayNumUpdate = true;
      } else {
        dayNumUpdate = false;
      }
    });
  }

  _showTimePicker() async {
    var picker =
        await showTimePicker(context: context, initialTime: TimeOfDay.now());
    setState(() {
      var _tempTime = picker.toString().substring(10, 15);
      time = _tempTime;
      timeUpdate = true;
      noTime = false;
    });
  }

  _showDatePicker() async {
    Locale mylocale = Localizations.localeOf(context);
    var picker = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime.now(),
        lastDate: DateTime(2040),
        locale: mylocale);
    setState(() {
      var _tempDate = picker.toString().substring(0, 9);
      date = _tempDate;
      dateUpdate = true;
      noDate = false;
    });
  }
}
