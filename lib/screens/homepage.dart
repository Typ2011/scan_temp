import 'dart:async';
import 'package:flutter/material.dart';
import 'package:scan_temp/addSensor.dart';
import 'package:scan_temp/LocalKeyValuePersistence.dart';
import 'package:scan_temp/api/mqtt.dart';

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<addSensor> sensors = [];
  StreamController<String> _controller = StreamController<String>.broadcast();
  SharedPref sharedPref = SharedPref();
  MQTTClient mqttClient = new MQTTClient();


  @override
  void initState() {
    mqttClient.setFunctions(updateList, _showDialog);
    loadSharedPrefs();
    super.initState();
  }

  void loadSharedPrefs() async {
    try {
      await mqttClient.connect();
      List<String> sensorList = await sharedPref.readStringList("sensors");
      print("[SharedPref] Loaded SensorName List: " + sensorList.toString());
      sensorList.forEach((sensorName) async {
        addSensor tempSensor = addSensor.fromJson(await sharedPref.read(sensorName));
        tempSensor.setStream(_controller.stream);
        setState(() {
          sensors.add(tempSensor);
        });
        mqttClient.subscribeToTopic(tempSensor.mqtt);
      });
    } catch (Excepetion) {
      print(Excepetion);
    }
  }

  void _showDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: new Text("ERROR"),
          content: new Text("Verbindung zum MQTT Server abgebrochen! Verbing erneut herstellen?"),
          actions: <Widget>[
            new FlatButton(
              child: new Text("Close"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            new FlatButton(
                onPressed: () {
                  mqttClient.connect();
                  Navigator.of(context).pop();
                },
                child: new Text("Reconnect")
            ),
          ],
        );
      },
    );
  }

  _navigateAndDisplayAdd(BuildContext context) async {
    final result = await Navigator.pushNamed(context, "/addSensor", arguments: _controller);
    if(result != null) {
      setState(() {
        sensors.add(result);
      });
      addSensor resultSensor = result;
      sharedPref.save(resultSensor.name, resultSensor);

      List<String> sensorList = [];
      if(await sharedPref.readStringList("sensors") != null) {
        sensorList = await sharedPref.readStringList("sensors");
      }
      sensorList.add(resultSensor.name);
      sharedPref.saveStringList("sensors", sensorList);

      mqttClient.subscribeToTopic(resultSensor.mqtt);
    }
  }

  void updateList(String topic, String message) {
    setState(() {
      sensors.forEach((sensor) {
        if(sensor.mqtt == topic) {
          sensor.tempTemp = double.parse(message);
          _controller.add(topic);
          sharedPref.save(sensor.name, sensor);
        }
      });
    });
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
      ),
      body: ListView.builder(
        itemCount: sensors.length,
        itemBuilder: (context, index) {
            return Dismissible(
                key: UniqueKey(),
                child: sensors[index],
                background: Container(color: Colors.red),
                onDismissed: (direction) {
                  addSensor tempSensor = sensors[index];
                  setState(() {
                    sensors.removeAt(index);
                  });
                  mqttClient.unsubscribeToTopic(tempSensor.mqtt);
                  sharedPref.remove(tempSensor.name);
                  sharedPref.findAndRemoveStringList("sensors", tempSensor.name);
                },
            );
          },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () =>_navigateAndDisplayAdd(context),
        tooltip: 'Add Sensor',
        child: Icon(Icons.add, color: Colors.white,),
      ),
    );
  }
}