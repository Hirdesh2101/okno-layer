import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class AuthForm extends StatefulWidget {
  // ignore: use_key_in_widget_constructors
  const AuthForm(
    this.submitFn,
    this.isLoading,
  );

  final bool isLoading;
  final void Function(
    String email,
    String password,
    String userName,
    String gender,
    String age,
    BuildContext ctx,
  ) submitFn;

  @override
  _AuthFormState createState() => _AuthFormState();
}

class _AuthFormState extends State<AuthForm> {
  final _formKey = GlobalKey<FormState>();
  var _userEmail = '';
  var _userName = '';
  var _userPassword = '';
  int _showing = 0;
  var _age = '';

  void _trySubmit() {
    final isValid = _formKey.currentState!.validate();
    FocusScope.of(context).unfocus();
    if (_showing == 0) {
      Fluttertoast.showToast(
          msg: "Please Select Age",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          // backgroundColor: Colors.red,
          // textColor: Colors.white,
          fontSize: 16.0);
    }
    if (_gender == '') {
      Fluttertoast.showToast(
          msg: "Please Select Gender",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          // backgroundColor: Colors.red,
          // textColor: Colors.white,
          fontSize: 16.0);
    }

    if (isValid && _gender != '' && _showing != 0) {
      _formKey.currentState!.save();
      switch (_showing) {
        case 1:
          _age = '0-10';
          break;
        case 2:
          _age = '10-20';
          break;
        case 3:
          _age = '20-25';
          break;
        case 4:
          _age = '25-30';
          break;
        case 5:
          _age = '30-35';
          break;
        case 6:
          _age = '35-45';
          break;
        case 7:
          _age = '45+';
          break;
      }
      widget.submitFn(_userEmail.trim(), _userPassword.trim(), _userName.trim(),
          _gender.trim(), _age.trim(), context);
    }
  }

  int _radioValue = 0;
  String _gender = '';
  void _handelRadioValueChange(int? value) {
    setState(() {
      _radioValue = value!;
    });
    switch (_radioValue) {
      case 1:
        _gender = 'Male';
        break;
      case 2:
        _gender = 'Female';
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue,
      appBar: AppBar(
        elevation: 0,
      ),
      body: Center(
        child: Card(
          margin: const EdgeInsets.all(20),
          elevation: 10,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    TextFormField(
                      enabled: widget.isLoading ? false : true,
                      key: const ValueKey('email'),
                      validator: (value) {
                        if (value!.isEmpty || !value.contains('@')) {
                          return 'Please enter a valid email address.';
                        }
                        return null;
                      },
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: 'Email address',
                      ),
                      onSaved: (value) {
                        _userEmail = '$value';
                      },
                    ),
                    TextFormField(
                      enabled: widget.isLoading ? false : true,
                      key: const ValueKey('username'),
                      validator: (value) {
                        if (value!.isEmpty || value.length < 4) {
                          return 'Please enter at least 4 characters';
                        }
                        return null;
                      },
                      decoration: const InputDecoration(labelText: 'Username'),
                      onSaved: (value) {
                        _userName = '$value';
                      },
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const Text('Select Age: '),
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.14,
                        ),
                        Container(
                          width: MediaQuery.of(context).size.width * 0.40,
                          height: MediaQuery.of(context).size.height * 0.07,
                          decoration: BoxDecoration(
                              border: Border.all(
                                color: Colors.white,
                              ),
                              borderRadius: BorderRadius.circular(0)),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton(
                                isExpanded: true,
                                hint: const Text('Select Age'),
                                value: _showing,
                                items: const [
                                  DropdownMenuItem(
                                    child: Text('Select Age'),
                                    value: 0,
                                  ),
                                  DropdownMenuItem(
                                    child: Text('0-10'),
                                    value: 1,
                                  ),
                                  DropdownMenuItem(
                                    child: Text('10-20'),
                                    value: 2,
                                  ),
                                  DropdownMenuItem(
                                    child: Text('20-25'),
                                    value: 3,
                                  ),
                                  DropdownMenuItem(
                                    child: Text('25-30'),
                                    value: 4,
                                  ),
                                  DropdownMenuItem(
                                    child: Text('30-35'),
                                    value: 5,
                                  ),
                                  DropdownMenuItem(
                                    child: Text('35-45'),
                                    value: 6,
                                  ),
                                  DropdownMenuItem(
                                    child: Text('45+'),
                                    value: 7,
                                  ),
                                ],
                                onChanged: (value) {
                                  setState(() {
                                    _showing = value as int;
                                  });
                                },
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      enabled: widget.isLoading ? false : true,
                      key: const ValueKey('password'),
                      validator: (value) {
                        if (value!.isEmpty || value.length < 7) {
                          return 'Password must be at least 7 characters long.';
                        }
                        return null;
                      },
                      decoration: const InputDecoration(labelText: 'Password'),
                      obscureText: true,
                      onSaved: (value) {
                        _userPassword = '$value';
                      },
                    ),
                    Row(
                      children: [
                        const Text('Gender: '),
                        // ignore: unnecessary_new
                        new Radio(
                          value: 1,
                          groupValue: _radioValue,
                          onChanged: _handelRadioValueChange,
                        ),
                        const Text('Male'),
                        // ignore: unnecessary_new
                        new Radio(
                          value: 2,
                          groupValue: _radioValue,
                          onChanged: _handelRadioValueChange,
                        ),
                        const Text('Female'),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (widget.isLoading) const CircularProgressIndicator(),
                    if (!widget.isLoading)
                      Container(
                        width: MediaQuery.of(context).size.width * 0.58,
                        height: MediaQuery.of(context).size.height * 0.07,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            gradient: const LinearGradient(colors: [
                              Color.fromARGB(255, 52, 63, 95),
                              Color.fromARGB(200, 32, 29, 48)
                            ])),
                        child: ElevatedButton(
                          //shape: RoundedRectangleBorder(
                          // borderRadius: BorderRadius.circular(20)),
                          style: ButtonStyle(),
                          child: const Text(
                            'SIGNUP',
                            style: TextStyle(
                              color: Colors.white,
                            ),
                          ),
                          onPressed: _trySubmit,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
