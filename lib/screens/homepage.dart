import 'dart:async';
import 'package:mqtt_client/mqtt_client.dart' as mqtt;
import 'package:flutter/material.dart';
import 'package:scan_temp/addSensor.dart';
import 'package:scan_temp/LocalKeyValuePersistence.dart';
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

  @override
  void initState() {
    loadSharedPrefs();
    super.initState();
  }

  loadSharedPrefs() async {
    try {
      await connect();
      List<String> sensorList = await sharedPref.readStringList("sensors");
      sensorList.forEach((sensorName) async {
        addSensor tempSensor = addSensor.fromJson(await sharedPref.read(sensorName));
        tempSensor.setStream(_controller.stream);
        setState(() {
          sensors.add(tempSensor);
        });
        subscribeToTopic(tempSensor.mqtt);
      });
    } catch (Excepetion) {

    }
  }

  findAndRemoveStringList(String key, String listKey) async {
    List<String> list = await sharedPref.readStringList(key);
    await sharedPref.remove(key);
    var counter = 0;
    list.forEach((data) {
      print(counter.toString() + " : " + data + " : " + listKey);
      if(data == listKey) {
        list.removeAt(counter);
      }
      counter++;
    });
    await sharedPref.saveStringList(key, list);
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
//        actions: <Widget>[
//          IconButton(icon: Icon(Icons.cast_connected, color: Colors.white,), onPressed: () => connect()),
//        ],
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
                  unsubscribeToTopic(tempSensor.mqtt);
                  sharedPref.remove(tempSensor.name);
                  findAndRemoveStringList("sensors", tempSensor.name);
                },
            );
          },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () =>_navigateAndDisplayAdd(context),
        tooltip: 'Add Sensor',
        child: Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  _navigateAndDisplayAdd(BuildContext context) async {
    final result = await Navigator.pushNamed(context, "/addSensor", arguments: _controller);
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

    subscribeToTopic(resultSensor.mqtt);
  }

  //MQTT Client, da immoment nichts anderes funktioniert
  //TODO: MQTT in seperater Klasse

  String broker           = 'hairdresser.cloudmqtt.com';
  int port                = 18806;
  String username         = 'gpldchfk';
  String passwd           = '0orDOEQ7IvWW';
  String clientIdentifier = 'android';

  mqtt.MqttClient client;
  mqtt.MqttConnectionState connectionState;
  StreamSubscription subscription;

  void unsubscribeToTopic(String topic) {
    if (connectionState == mqtt.MqttConnectionState.connected) {
      print('[MQTT client] Unsubscribing from ${topic.trim()}');
      client.unsubscribe(topic);
    }
  }

  void subscribeToTopic(String topic) {
    if (connectionState == mqtt.MqttConnectionState.connected) {
      print('[MQTT client] Subscribing to ${topic.trim()}');
      client.subscribe(topic, mqtt.MqttQos.exactlyOnce);
    }
  }

  void connect() async {

    client = mqtt.MqttClient(broker, '');

    client.port = port;

//    client.logging(on: true);

    client.keepAlivePeriod = 30;

    client.onDisconnected = _onDisconnected;

    final mqtt.MqttConnectMessage connMess = mqtt.MqttConnectMessage()
        .withClientIdentifier(clientIdentifier)
        .startClean() // Non persistent session for testing
        .keepAliveFor(30)
        .withWillQos(mqtt.MqttQos.atMostOnce);
    print('[MQTT client] MQTT client connecting....');
    client.connectionMessage = connMess;

    try {
      await client.connect(username, passwd);
    } catch (e) {
      print(e);
      _disconnect();
    }

    if (client.connectionState == mqtt.MqttConnectionState.connected) {
      print('[MQTT client] connected');
      connectionState = client.connectionState;
    } else {
      print('[MQTT client] ERROR: MQTT client connection failed - '
          'disconnecting, state is ${client.connectionStatus}');
      _disconnect();
    }

    subscription = client.updates.listen(onMessage);

  }

  void _disconnect() {
    print('[MQTT client] _disconnect()');
    client.disconnect();
    _onDisconnected();
    print('[MQTT client] MQTT client reconnecting...');
    connect();
    print('[MQTT client] connected');
  }

  void _onDisconnected() {
    print('[MQTT client] _onDisconnected');
    //topics.clear();
    connectionState = client.connectionState;
    client = null;
    subscription.cancel();
    subscription = null;
    print('[MQTT client] MQTT client disconnected');
    print('[MQTT client] MQTT client reconnecting...');
    connect();
    print('[MQTT client] connected');
  }

  void onMessage(List<mqtt.MqttReceivedMessage> event) {
    print(event.length);
    final mqtt.MqttPublishMessage recMess =
    event[0].payload as mqtt.MqttPublishMessage;
    final String message =
    mqtt.MqttPublishPayload.bytesToStringAsString(recMess.payload.message);

    print('[MQTT client] MQTT message: topic is <${event[0].topic}>, '
        'payload is <-- ${message} -->');
    print(client.connectionStatus);
    print("[MQTT client] message with topic: ${event[0].topic}");
    print("[MQTT client] message with message: ${message}");
    setState(() {
      sensors.forEach((sensor) {
        if(sensor.mqtt == event[0].topic) {
            sensor.tempTemp = double.parse(message);
            _controller.add(event[0].topic);
            sharedPref.save(sensor.name, sensor);
        }
      });
    });
  }
}