import 'package:flutter/material.dart';

class nodeDetail extends StatefulWidget {
  const nodeDetail({Key key, @required this.message}) : super(key: key);
  final Map message;
  @override
  _nodeDetailState createState() => _nodeDetailState(message:message);
}

class _nodeDetailState extends State<nodeDetail> {
  _nodeDetailState({this.message});
  final Map message;

  var nodeDetailContrl = new TextEditingController() ;
  var nodeDetailFocus = new FocusNode();

  var time;
  var date;
  var dayNum;

  //是否被编辑
  bool noChange = true;
  bool noTime = false; //是否设置了时间
  bool noDate = false; //是否设置了日期
  bool noDayNum = false; //是否设置了天数

  //是否更改信息
  bool messageUpdate =  false;
  bool timeUpdate = false;
  bool dateUpdate = false;
  bool dayNumUpdate = false;
  bool updateAnyone = false;

  @override
  void initState() {
    nodeDetailContrl.text = '${message['message']}';
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    print(message);
    if(message['time']==''||message['time']==null){
      noTime = true;
    }
    if(message['date']==''||message['date']==null){
      noDate = true;
    }
    if(message['dayNum']==''||message['dayNum']==null){
      noDayNum = true;
    }


    if(messageUpdate==true||timeUpdate==true||dateUpdate==true||dayNumUpdate==true){
      updateAnyone=true;
    }else{
      updateAnyone=false;
    }

    _judgeUpdate(){
      if(nodeDetailContrl.text != message['message'] && nodeDetailContrl.text!=''&& nodeDetailContrl.text!=null){
        messageUpdate=true;
      }else{
        messageUpdate=false;
      }
      if(time != message['time'] && time!=''&& time!=null){
        timeUpdate=true;
      }else{
        timeUpdate=false;
      }
      if(date != message['date'] && date!=''&& date!=null){
        dateUpdate=true;
      }else{
        dateUpdate=false;
      }
      if(dayNum != message['dayNum'] && dayNum!=''&& dayNum!=null){
        dayNumUpdate=true;
      }else{
        dayNumUpdate=false;
      }
    };

    return Scaffold(
      resizeToAvoidBottomPadding: false,
      appBar: AppBar(
        title: Text('提醒事项'),
        actions: [
          updateAnyone ? TextButton.icon(onPressed: null, icon: Icon(Icons.done,color: Colors.blue,), label: Text('保存',style: TextStyle(color: Colors.blue),)) : Text('')
        ]
      ),
      body: Center(
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
                      autofocus: false,
                      maxLines: 50,
                      keyboardType: TextInputType.text,
                      textInputAction: TextInputAction.done,
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.all(20),
                        border: OutlineInputBorder(
                            borderRadius:
                            BorderRadius.circular(5),
                            borderSide: BorderSide.none),
                        fillColor: Color(0xffFFEFD5),
                        filled: true,
                      ),
                      onChanged: (val){
                        setState(() {
                          nodeDetailContrl.text = val;
                          _judgeUpdate();
                        });
                      },
                    ),
                  ),
                ),
                new Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    new RaisedButton(
                        color: Colors.blueGrey,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(7))),
                        onPressed: (){},
                        child: new Text(noTime? '设置时间' : '时间：${message['time']}',style: TextStyle(fontSize: 12,color: Colors.white),)),
                    new RaisedButton(
                        padding: EdgeInsets.all(5),
                        color: Colors.blueGrey,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(7))),
                        onPressed: (){},
                        child: new Text(noDate? '设置日期' : '日期：${message['date']}',style: TextStyle(fontSize: 12,color: Colors.white),)),
                    new RaisedButton(
                        color: Colors.blueGrey,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(7))),
                        onPressed: (){},
                        child: new Text(noDayNum? '设置天数' : '持续：${message['dayNum']}天',style: TextStyle(fontSize: 12,color: Colors.white),))
                  ],)
              ],
            )),
      ),
    );
  }
}



