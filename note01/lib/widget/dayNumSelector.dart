import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class dayNumSelector extends StatelessWidget {
  const dayNumSelector({
    Key key,
    @required this.dayNumCon,
    @required this.dayNumFocus,
  }) : super(key: key);

  final TextEditingController dayNumCon;
  final FocusNode dayNumFocus;

  @override
  Widget build(BuildContext context) {
    return new Container(
        height: 20,
        width: 90,
        child: Row(
          children: [
            new Container(
              margin:
              EdgeInsets.only(right: 5),
              child: Text('持续'),
            ),
            new Expanded(child:
            new TextField(
              controller: dayNumCon,
              focusNode: dayNumFocus,
              maxLines: 1,
              keyboardType:
              TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter
                    .digitsOnly,
                LengthLimitingTextInputFormatter(
                    3)
              ],
              textInputAction:
              TextInputAction.done,
              autofocus: false,
              decoration: InputDecoration(
                contentPadding:
                EdgeInsets.fromLTRB(
                    5, 0, 0, 0),
                hintText: '0',
                border: OutlineInputBorder(
                    borderRadius:
                    BorderRadius
                        .circular(8),
                    borderSide: BorderSide(
                      color:
                      Colors.blueGrey,
                      style:
                      BorderStyle.solid,
                    )),
              ),
            )
            ),
            new Container(
              margin:
              EdgeInsets.only(left: 5),
              child: Text('天'),
            )
          ],
        ));
  }
}