import 'package:path_provider/path_provider.dart'; //查找目录的类库
import 'dart:convert'; //convert中包含了json相关方法
import 'package:flutter/material.dart';
import 'Page_main.dart';
import 'package:flutter/cupertino.dart';
import 'Func_json.dart';
//关于数据库的操作，具体是使用一套可逆的加密方法加密以后以密文形式储存在txt文件中，可以将密码本导入我的PrivPass网站中，只有自己知道，因此也不会产生密码泄露
import 'dart:io';

TextEditingController _PwdController; //设置密码输入框的控制器

class PassBook {
  setPwd(String pwd) {
    //首次进入软件设置密码
  }

  Future<Null> _showDialog(BuildContext _context) {
    _PwdController = TextEditingController();
    showDialog<Null>(
      barrierDismissible: false,
      context: _context,
      child: new CupertinoAlertDialog(
        title: new Text("第一次使用，请输入全局密码[第一版默认AES加密]"),
        content: new CupertinoTextField(
          placeholder: "全局密码",
          controller: _PwdController,
        ),
        actions: <Widget>[
          new CupertinoButton(
            child: new Text("保存"),
            onPressed: () {
              print("保存");
              //执行保存操作,写入默认密码,一般是这样
              writeJSON(
                      '{"pwd":"${_PwdController.text}","data": [{"title":"null","content":"null"},]}')
                  .then((_) {
                //写入以后要更新首页
                result = Father_PwdList.fromJson(jsonDecode(
                    '{"pwd":"${_PwdController.text}","data": [{"title":"null","content":"null"}]}'));
              });

              Navigator.pop(_context);
            },
          )
        ],
      ),
    );
  }

  localPath() async {
    //获得app缓存位置
    try {
      Directory appDocDir = await getApplicationDocumentsDirectory();
      String appDocPath = appDocDir.path; //获取到程序路径
      print(appDocPath);
    } catch (err) {
      print(err);
    }
  }

  localFile(path) async {
    //获取具体文件位置，然后得到该文件的实例
    return new File('$path/PwdBook.json'); //密码是以加密的形式保存在软件目录下的PwdBook.json文件中
  }

//_getLocalFile函数，获取本地文件目录
  Future<File> _getLocalFile() async {
    // 获取本地文档目录
    String dir = (await getApplicationDocumentsDirectory()).path;
    // 返回本地文件目录
    return new File('$dir/PwdBook.txt');
  }

  // 读取 json 数据,这里直接把json文件读取进来，再在程序里做解析
  Future<String> readJSON(BuildContext _context) async {
    try {
      //File file = await _getLocalFile();
      String dir = (await getApplicationDocumentsDirectory()).path;
      File file=new File('$dir/PwdBook.txt');
      String str=await file.readAsString();
      //print("readJSON读取数据:"+str);
      return str;
      //g();
      
     
    } catch (err) {
      _showDialog(_context);
      //return "err";
    }
  }

// 写入 json 数据,也是直接写入string到文件
  Future<Null> writeJSON(String p) async {
    try {
      _getLocalFile().then((_) {
        _.writeAsString(p);
      });
    } catch (err) {
      //print(err);
    }
  }
}
