import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

// ignore: camel_case_types
class addSensor extends StatefulWidget {
  addSensor(this.maxTemp, this.minTemp, this.mqtt, this.name, this.stream);
  String minTemp;
  String maxTemp;
  String name;
  String mqtt;
  double temp = 0.0;
  double tempTemp = 0.0;
  double percent = 0.0;
  Color percentColor = Colors.blue;
  Stream<String> stream;

  void setStream(Stream<String> pStream) => stream = pStream;

  addSensor.fromJson(Map<String, dynamic> json)
    : name = json['name'],
      mqtt = json['mqtt'],
      minTemp = json['minTemp'],
      maxTemp = json['maxTemp'],
      temp = json['temp'],
      percent = json['percent'];

  Map<String, dynamic> toJson() => {
    'name': name,
    'mqtt': mqtt,
    'minTemp': minTemp,
    'maxTemp': maxTemp,
    'temp': temp,
    'percent': percent,
  };

  @override
  _addSensorState createState() => _addSensorState();
}


// ignore: camel_case_types
class _addSensorState extends State<addSensor> {

@override
  void initState() {
    widget.stream.listen((mqtt) {
      if (mqtt == widget.mqtt) {
        if (this.mounted) {
          setState(() {
            widget.temp = widget.tempTemp;
            if(updatePercent() >= 0.0 && updatePercent() <= 1.0) {
              widget.percent = updatePercent();
              if(widget.percentColor != Colors.blue) {
                widget.percentColor = Colors.blue;
              }
            } else {
              widget.percent = 1.0;
              widget.percentColor = Colors.red;
            }
          });
        }
      }
    });
    super.initState();
  }

  double updatePercent() {
        return (widget.temp - double.parse(widget.minTemp)) / (double.parse(widget.maxTemp) - double.parse(widget.minTemp));
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8.0, 20.0, 8.0, 20.0),
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
                  center: new Text(widget.temp.toString() + " °C", style: TextStyle(color: Colors.white),),
                  leading: Padding(
                    padding: const EdgeInsets.only(right: 5.0),
                    child: new Text(widget.minTemp + " °C"),
                  ),
                  trailing: Padding(
                    padding: const EdgeInsets.only(left: 5.0),
                    child: new Text(widget.maxTemp + " °C"),
                  ),
                  percent: widget.percent,
                  lineHeight: 20.0,
                  progressColor: widget.percentColor,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}