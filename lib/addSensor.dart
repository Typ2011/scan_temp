import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

// ignore: camel_case_types
class addSensor extends StatefulWidget {
  addSensor(this.maxTemp, this.minTemp, this.mqtt, this.name);
  String minTemp;
  String maxTemp;
  String name;
  String mqtt;
  double temp = 0.0;
  @override
  _addSensorState createState() => _addSensorState();
}


// ignore: camel_case_types
class _addSensorState extends State<addSensor> {


  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8.0, 20.0, 8.0, 10.0),
      child: Card(
        elevation: 5.0,
        child: Center(
          child: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(15.0),
                child: new Text(widget.name),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(15.0, 0.0, 15.0, 20.0),
                child: new LinearPercentIndicator(
                  center: new Text(widget.temp.toString() + " °C"),
                  leading: new Text( widget.minTemp + " °C"),
                  trailing: new Text(widget.maxTemp + " °C"),
                  percent: 0.1,
                  lineHeight: 20.0,
                  progressColor: Colors.blue,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}