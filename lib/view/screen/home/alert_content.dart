import 'package:flutter/material.dart';

class AlertContent extends StatefulWidget {
  @override
  _AlertContentState createState() => _AlertContentState();
}

class _AlertContentState extends State<AlertContent> {
  final _usernameController = TextEditingController();
  final _phoneNumberController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          TextFormField(
            controller: _usernameController,
            decoration: InputDecoration(labelText: 'ឈ្មោះ',),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'សូមបំពេញឈ្មោះ';
              }
              return null;
            },
          ),
          TextFormField(
            controller: _phoneNumberController,
            decoration: InputDecoration(labelText: 'លេខទូរស័ព្ទ'),
            keyboardType: TextInputType.phone,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'សូមបំពេញលេខទូរស័ព្ទ';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }
}