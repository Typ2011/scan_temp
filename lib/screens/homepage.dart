import 'dart:async';
import 'package:mqtt_client/mqtt_client.dart' as topMqtt;
import 'package:flutter/material.dart';
import 'package:scan_temp/addSensor.dart';
import 'package:scan_temp/api/mqtt.dart' as mqtt;
class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<addSensor> sensors = [];
  static StreamController<Map<int, double>> streamController = new StreamController.broadcast();
  mqtt.MQTTClient client = new mqtt.MQTTClient();



  @override
  void initState() {
    client.setSensorsList(sensors);
    client.setStream(streamController);
    print("Setting Sensors done!");

    streamController.stream.listen((data) {
      print(data);
      print("-----------------------------");
      var tempKeys = data.keys;
      setState(() {
        var temp = sensors.elementAt(tempKeys.toList()[0]);
        var temp2 = tempKeys.toList();
        print(" KEY" + temp2[1].toString());
      });
    }, onError: (error) {print(error);});

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("ScanTemp",
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        actions: <Widget>[
          IconButton(icon: Icon(Icons.cast_connected, color: Colors.white,), onPressed: () => client.connect()),
        ],
      ),
      body: ListView.builder(
        itemCount: sensors.length,
        itemBuilder: (context, index) { return sensors[index];},
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () =>_navigateAndDisplayAdd(context),
        tooltip: 'Add Sensor',
        child: Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  _navigateAndDisplayAdd(BuildContext context) async {
    // Navigator.push returns a Future that completes after calling
    // Navigator.pop on the Selection Screen.
    final result = await Navigator.pushNamed(context, "/addSensor");
    setState(() {
      sensors.add(result);
    });
    addSensor resultSensor = result;
    client.subscribeToTopic(resultSensor.mqtt);
  }
}