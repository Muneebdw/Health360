import 'package:flutter/material.dart';
import 'package:health360/Comm/comHelper.dart';
import 'package:health360/Comm/genTextFormField.dart';
import 'package:health360/DatabaseHandler/DbHelper.dart';
import 'package:health360/Model/UserModel.dart';
import 'package:health360/Screens/LoginForm.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeForm extends StatefulWidget {
  @override
  _HomeFormState createState() => _HomeFormState();
}

class _HomeFormState extends State<HomeForm> {
  final _formKey = new GlobalKey<FormState>();
  Future<SharedPreferences> _pref = SharedPreferences.getInstance();

  DbHelper dbHelper;
  final _conUserId = TextEditingController();
  final _conDelUserId = TextEditingController();
  final _conUserName = TextEditingController();
  final _conEmail = TextEditingController();
  final _conPassword = TextEditingController();

  @override
  void initState() {
    super.initState();
    getUserData();

    dbHelper = DbHelper();
  }

  Future<void> getUserData() async {
    final SharedPreferences sp = await _pref;

    setState(() {
      _conUserId.text = sp.getString("user_id");
      _conDelUserId.text = sp.getString("user_id");
      _conUserName.text = sp.getString("user_name");
      _conEmail.text = sp.getString("email");
      _conPassword.text = sp.getString("password");
    });
  }

  update() async {
    String uid = _conUserId.text;
    String uname = _conUserName.text;
    String email = _conEmail.text;
    String passwd = _conPassword.text;

    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();

      UserModel user = UserModel(uid, uname, email, passwd);
      await dbHelper.updateUser(user).then((value) {
        if (value == 1) {
          alertDialog(context, "Successfully Updated");

          updateSP(user, true).whenComplete(() {
            Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => LoginForm()),
                (Route<dynamic> route) => false);
          });
        } else {
          alertDialog(context, "Error Update");
        }
      }).catchError((error) {
        print(error);
        alertDialog(context, "Error");
      });
    }
  }

  delete() async {
    String delUserID = _conDelUserId.text;

    await dbHelper.deleteUser(delUserID).then((value) {
      if (value == 1) {
        alertDialog(context, "Successfully Deleted");

        updateSP(null, false).whenComplete(() {
          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => LoginForm()),
              (Route<dynamic> route) => false);
        });
      }
    });
  }

  Future updateSP(UserModel user, bool add) async {
    final SharedPreferences sp = await _pref;

    if (add) {
      sp.setString("user_name", user.user_name);
      sp.setString("email", user.email);
      sp.setString("password", user.password);
    } else {
      sp.remove('user_id');
      sp.remove('user_name');
      sp.remove('email');
      sp.remove('password');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dashboard'),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Container(
            margin: EdgeInsets.only(top: 20.0),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  //Create a steps button
                  RaisedButton(
                    child: Text('Steps'),
                    onPressed: () {
                      Navigator.pushNamed(context, '/steps');
                    },
                  ),
                  //Create a weight button
                  RaisedButton(
                    child: Text('Weight'),
                    onPressed: () {
                      Navigator.pushNamed(context, '/weight');
                    },
                  ),
                  //Create a BMI button
                  RaisedButton(
                    child: Text('BMI'),
                    onPressed: () {
                      Navigator.pushNamed(context, '/bmi');
                    },
                  ),
                  //create a timer when clicked starts timer
                  RaisedButton(
                    child: Text('Timer'),
                    onPressed: () {
                      Navigator.pushNamed(context, '/timer');
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
