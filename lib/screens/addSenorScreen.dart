import 'dart:async';

import 'package:flutter/material.dart';
import 'package:scan_temp/addSensor.dart';

class addSensorScreen extends StatefulWidget {
  //addSensorScreen({Key key}) : super(key: key);

  @override
  _addSensorScreenState createState() => _addSensorScreenState();
}

class _addSensorScreenState extends State<addSensorScreen> {
  TextEditingController _controllerName = TextEditingController();
  TextEditingController _controllerMqttTopic = TextEditingController();
  TextEditingController _controllerMin = TextEditingController();
  TextEditingController _controllerMax = TextEditingController();



  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    _controllerName.dispose();
    _controllerMqttTopic.dispose();
    _controllerMin.dispose();
    _controllerMax.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final StreamController<String> stream = ModalRoute.of(context).settings.arguments;
    return Scaffold(
      appBar: AppBar(
        title: Text("ScanTemp",
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: ListView(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(0.0, 20.0, 0.0, 10.0),
            child: Center(child: Text("Sensor Name:")),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 10.0),
            child: TextField(
              controller: _controllerName,
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(0.0, 10.0, 0.0, 10.0),
            child: Center(child: Text("MQTT Topic:")),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 10.0),
            child: TextField(
              controller: _controllerMqttTopic,
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(0.0, 10.0, 0.0, 10.0),
            child: Center(child: Text("Min Temp:")),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 10.0),
            child: TextField(
              controller: _controllerMin,
              keyboardType: TextInputType.number,
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(0.0, 10.0, 0.0, 10.0),
            child: Center(child: Text("Max Temp:")),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 10.0),
            child: TextField(
              controller: _controllerMax,
              keyboardType: TextInputType.number,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(25.0),
            child: Center(
              child: RaisedButton(
                onPressed: () {
                  var temp = new addSensor(_controllerMax.text, _controllerMin.text, _controllerMqttTopic.text, _controllerName.text, stream.stream);
                  Navigator.pop(context, temp);
                  },
                child: Text("Add Sensor", style: TextStyle(color: Colors.white),),
                color: Colors.lightGreen,

              )
            ),
          )
        ],
      ),
    );
  }
}