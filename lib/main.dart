import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'Page_main.dart';
import 'Func_json.dart';
import 'dart:io';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import 'package:xxtea/xxtea.dart';
import 'package:passcode_screen/passcode_screen.dart';
import 'package:passcode_screen/circle.dart';
import 'package:passcode_screen/keyboard.dart';
import 'package:passcode_screen/passcode_screen.dart';
import 'dart:async';

void main() => runApp(new _Login());
String UserPwd = "";

class _Login extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: "私密笔记",
      home: Login(),
    );
  }
}

class Login extends StatefulWidget {
  @override
  createState() => new LoginState();
}

class LoginState extends State<Login> {
  BuildContext _context;
  TextEditingController _PwdController; //设置密码输入框的控制器

  _showDialog(BuildContext _context) {
    // _PwdController = TextEditingController();
    showDialog<Null>(
      context: _context,
      barrierDismissible: false,
      child: new CupertinoAlertDialog(
        title: new Text("第一次使用，请输入全局密码"),
        content: new CupertinoTextField(
          clearButtonMode: OverlayVisibilityMode.editing,
          placeholder: "全局密码",
          controller: _PwdController,
          obscureText: true,
        ),
        actions: <Widget>[
          new CupertinoButton(
            child: new Text("保存"),
            onPressed: () {
              print("保存");
              UserPwd = _PwdController.text; //储存用户全局密码
              //执行保存操作,写入默认密码,一般是这样
              //2.1更新：将密码以加密的形式写入字符串
              //使用用户的密码将第一条信息写入
              String json_p =
                  '{"pwd":"${xxtea.encryptToString(_PwdController.text, _PwdController.text)}","data": [{"title":"${xxtea.encryptToString("欢迎使用~", _PwdController.text)}","content":"${xxtea.encryptToString("欢迎使用私密笔记本，本软件无网络权限，可以安心使用，导出密码本后可以存放在任何地方，后续会有相应的WEB版本制作，请放心使用。做这个软件的初衷是因为我的密码太多，而且有保存的需求，同时也想学习 flutter框架的应用，于是就诞生了这个软件。软件依旧在更新，开发者就在酷安，请大家多多关注！~", _PwdController.text)}"}]}';
              writeJSON(json_p).then((_) {
                //写入以后要更新首页

                //setState(() {
                result = Father_PwdList.fromJson(jsonDecode(json_p));
                //});
              });

              Navigator.pop(_context);
            },
          )
        ],
      ),
    );
  }

  _readJson() async {
    String p = await readJSON(_context);
    print("2---" + p);
    //用then等待异步操作，等文件读取完成再开始构建list
    //setState(() {
    // print("即将解析result:" + p);
    result =
        Father_PwdList.fromJson(jsonDecode(p)); //这里将result读取进入,result储存了所有的密码
    //}); //list的生成在return 之前，因此在这里写比较好
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
      // print("path获取完毕:"+dir);
      File file = new File('$dir/PwdBook.txt');
      //print("file新建完毕:");
      print(file);
      String str = await file.readAsString();
      //print("readJSON读取数据:"+str);
      return str;
      //g();

    } catch (err) {
      _showDialog(_context);
      return "err";
    }
  }

  // 写入 json 数据,也是直接写入string到文件
  Future<Null> writeJSON(String p) async {
    try {
      await (await _getLocalFile()).writeAsString(p);
    } catch (err) {
      print(err);
    }
  }

  Save(String title, String content) {
    setState(() {
      result.data.add(new PwdList(title, content));
      //print("添加页面的：" + jsonEncode(result));
      writeJSON(jsonEncode(result));
    });
  }

  @override
  void initState() {
    _PwdController = new TextEditingController();
    super.initState();
  }

  ppp() async {
    //print("主界面读取json");
    await _readJson(); //这是检查第一次是否是新用户的
  }

  final StreamController<bool> _verificationNotifier =
      StreamController<bool>.broadcast();
  bool isAuthenticated = false;

  _onPasscodeEntered(String enteredPasscode) {
    bool isValid = false;
      _verificationNotifier.add(isValid);
    if (xxtea.encryptToString(enteredPasscode, enteredPasscode) != result.pwd) {
      showDialog<Null>(
          context: context,
          child: new CupertinoAlertDialog(
            title: Text(
              "密码错误，登录失败",
              style: TextStyle(color: Color.fromRGBO(255, 0, 0, 1)),
            ),
          ));
    } else {
      //Navigator.pop(context);
      //登录成功就跳转到主界面
      UserPwd = enteredPasscode; //登录成功，更新密码
      isValid = true;
      setState(() {
        this.isAuthenticated = isValid;
      });
      Navigator.push(context, CupertinoPageRoute(builder: (context) => Cmain));
    }
  }

  @override
  Widget build(BuildContext context) {
    /* if(result!=null){
      print('${result.pwd}');
    }*/
    _context = context;

    ppp();
    print("reset_main");
    return new CupertinoPageScaffold(
      navigationBar: new CupertinoNavigationBar(
        middle: new Text('请输入密码'),
      ),
      child: new Center(
          child: ListView(
        children: <Widget>[
          new Padding(
            padding: new EdgeInsets.all(50),
          ),
          new Padding(
            padding: new EdgeInsets.all(20),
            child: new CupertinoTextField(
              clearButtonMode: OverlayVisibilityMode.editing,
              obscureText: true,
              placeholder: "请输入密码",
              controller: _PwdController,
            ),
          ),
          new CupertinoButton(
            child: Text("进入"),
            onPressed: () {
              if (xxtea.encryptToString(
                      _PwdController.text, _PwdController.text) !=
                  result.pwd) {
                showDialog<Null>(
                    context: context,
                    child: new CupertinoAlertDialog(
                      title: Text(
                        "密码错误，登录失败",
                        style: TextStyle(color: Color.fromRGBO(255, 0, 0, 1)),
                      ),
                    ));
              } else {
                //Navigator.pop(context);
                //登录成功就跳转到主界面
                UserPwd = _PwdController.text; //登录成功，更新密码
                Navigator.push(context,
                    CupertinoPageRoute(builder: (context) => Cmain)).then((_) {
                  exit(0);
                });
              }
            },
          ),
          new CupertinoButton(
            child: Text("PIN码登录"),
            onPressed: () {
              Navigator.push(
                  context,
                  PageRouteBuilder(
                      opaque: false,
                      pageBuilder: (context, animation, secondaryAnimation) {
                        return PasscodeScreen(
                          title: "6位数字密码",
                          passwordDigits: 6,
                          passwordEnteredCallback: _onPasscodeEntered,
                          cancelLocalizedText: '取消',
                          deleteLocalizedText: '删除',
                          shouldTriggerVerification:
                              _verificationNotifier.stream,
                        );
                      }));
            },
          )
          /* CupertinoButton(
            child: Text("加密测试"),
            onPressed: () async {
              String str = "198111";
              String key = "198111";
              String encrypt_data = xxtea.encryptToString(str, key);

              String decrypt_data = xxtea.decryptToString(encrypt_data, key);
             // print(xxtea.decryptToString(_PwdController.text, _PwdController.text));
              print(
                  "密匙：{$key},字串:{$str},加密:{$encrypt_data},解密:{$decrypt_data}");
            },
          )*/
        ],
      )),
    );
  }
}
