import 'package:flutter/material.dart';

class nodeDetail extends StatefulWidget {
  const nodeDetail({Key key, @required this.message,@required this.nodeDetailContrl,@required this.nodeDetailFocus}) : super(key: key);
  final Map message;
  final TextEditingController nodeDetailContrl;
  final FocusNode nodeDetailFocus;
  @override
  _nodeDetailState createState() => _nodeDetailState(message:message,nodeDetailContrl:nodeDetailContrl,nodeDetailFocus:nodeDetailFocus);
}

class _nodeDetailState extends State<nodeDetail> {
  _nodeDetailState({ this.message,this.nodeDetailContrl, this.nodeDetailFocus});
  @override
  Widget build(BuildContext context) {
    final Map message = this.message;
    final TextEditingController nodeDetailContrl = nodeDetailContrl;
    final FocusNode nodeDetailFocus = nodeDetailFocus;
    //是否被编辑
    bool noChange = true;
    bool noTime = false; //是否设置了时间
    bool noDate = false; //是否设置了日期
    bool noDayNum = false; //是否设置了天数
    nodeDetailContrl.text = '${message['message']}';
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


    return Scaffold(
      resizeToAvoidBottomPadding: false,
      appBar: AppBar(
        title: Text('提醒事项'),
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


class nodeDetail1 extends StatelessWidget {


  @override

  _showTimePicker() async {
    var picker =
    await showTimePicker(context: context, initialTime: TimeOfDay.now());
    setState(() {
      _tempTime = picker.toString().substring(10,15);
      time = _tempTime;
    });
    print(time);
  }
}

