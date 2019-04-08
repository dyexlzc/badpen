//添加密码的界面
// Step 3 - Add a stateful widget

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'Page_main.dart';
import 'Func_json.dart';
import 'dart:convert';
import 'Func_file.dart';
import 'main.dart';
import 'package:xxtea/xxtea.dart';

bool isSaved = true; //文本的保存状态
BuildContext _context; //主页面的context
TextEditingController _MsgController, _TitleController;

String Atitle = "";
String Acontent = "";
int Aid = -1; //列表id号

class PageAdd__ extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return PageAdd();
  }
}

class PageAdd extends State<PageAdd__> {
  /* PageAdd() {
    print("re construct");
    _MsgController = new TextEditingController();
    _TitleController = new TextEditingController();
    
    this.Atitle = Atitle;
    this.Acontent = Acontent;
    this.Aid = Aid;
   // print(Acontent);

  }*/
  _Save() {
    if (Aid == -1) {
      //如果id仍为默认值-1，那么说明是添加页面，没有传入值
      result.data.add(new PwdList(
              xxtea.encryptToString(_TitleController.text, UserPwd),
              xxtea.encryptToString(_MsgController.text, UserPwd))
          .toJson()); //加密过后保存
      //print(jsonEncode(result));
    } else {
      //修改id值的内容即可
      isSaved = true;
      var p = new Map<String, String>();
      p['title'] = xxtea.encryptToString(_TitleController.text, UserPwd);
      p['content'] = xxtea.encryptToString(_MsgController.text, UserPwd);
      result.data[Aid] = p; //更新result内容

    }
    //写入文本
    PassBook().writeJSON(jsonEncode(result));
  }

  _showDialog() async {
    //json test
    showDialog<Null>(
      context: _context,
      child: new CupertinoAlertDialog(
        title: new Text("提示"),
        content: new Text("当前笔记已经更改，尚未保存，需要保存吗？"),
        actions: <Widget>[
          new CupertinoButton(
            child: new Text("不保存"),
            onPressed: () {
              print("不保存"); //。。。必须连续弹出两次才能退出，可能是因为把Dialog也算上了
              Navigator.pop(_context);
              Navigator.pop(_context);
            },
          ),
          new CupertinoButton(
            child: new Text("保存"),
            onPressed: () {
              _Save(); //add页面只管save，返回主页面以后由main自动读取
              print("保存");

              //执行保存操作
              Navigator.pop(_context);
              Navigator.pop(_context);
            },
          )
        ],
      ),
    );
  }

  Future<bool> _requestPop() {
    _showDialog();
    return new Future.value(false);
  }

  Widget BuildView() {
    return (new ListView(
      padding: EdgeInsets.all(10),
      children: <Widget>[
        new Divider(
          height: 80.0,
        ),
        new CupertinoTextField(
          clearButtonMode: OverlayVisibilityMode.editing,
          /* onChanged: (String str) {
            //print(str + "has been changed.");
            isSaved = false; //文本更改后更新状态提示用户保存
            // print( _TitleController.text );
          },*/
           controller: _TitleController,
          padding: EdgeInsets.all(8),
          placeholder: ("输入标题"),
          // maxLines: 1,
          decoration: new BoxDecoration(
              border: Border.all(
                color: Colors.black,
                width: 1.0,
              ),
              borderRadius: new BorderRadius.circular(6)),
        ),
        new Divider(
          height: 10.0,
        ),
        new CupertinoTextField(
          /*onChanged: (String str) {
            //print(str + "has been changed.");
            isSaved = false; //文本更改后更新状态提示用户保存
          },*/
           controller: _MsgController,
          padding: EdgeInsets.all(15),
          placeholder: ("输入笔记"),
          maxLines: 20,
          decoration: new BoxDecoration(
              border: Border.all(
                color: Colors.black,
                width: 1.0,
              ),
              borderRadius: new BorderRadius.circular(6)),
        )
      ],
    ));
  }

  @override
  Widget build(BuildContext context) {
    _MsgController = new TextEditingController();
    _TitleController = new TextEditingController();
    isSaved = true;
    _context = context;
    setState(() {
      _MsgController.text = Acontent; //将页面传入的参数作为编辑框的值，方便添加和编辑两个公用一个界面
      _TitleController.text = Atitle;
    });

    print("reset!");
    print(Atitle);
    return CupertinoPageScaffold(
      navigationBar: new CupertinoNavigationBar(
        middle: new Text('添加笔记'),
        trailing: new CupertinoButton(
          padding: EdgeInsets.all(0),
          child: new Icon(CupertinoIcons.play_arrow),
          onPressed: () {
            if ((_MsgController.text != "") || (_TitleController.text != "")) {
              _Save();
              print("save");
              //_MsgController.text = "";
              //_TitleController.text = ""; //保存后清空文本
              Navigator.pop(_context);
            }
          },
        ),
        backgroundColor: new Color.fromRGBO(255, 255, 255, 0),
      ),
      child: BuildView(),
    );
  }
}
