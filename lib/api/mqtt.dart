import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:mqtt_client/mqtt_client.dart' as mqtt;
import 'package:scan_temp/addSensor.dart';

class MQTTClient {

  String broker           = 'hairdresser.cloudmqtt.com';
  int port                = 18806;
  String username         = 'gpldchfk';
  String passwd           = '0orDOEQ7IvWW';
  String clientIdentifier = UniqueKey().toString();

  mqtt.MqttClient client;
  mqtt.MqttConnectionState connectionState;
  StreamSubscription subscription;

  Function updateList;
  Function showDialog;

  void setFunctions(Function pUpdateList, Function pShowDialog) {
    updateList = pUpdateList;
    showDialog = pShowDialog;
  }

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

    client.keepAlivePeriod = 180;

    client.onDisconnected = _onDisconnected;

    final mqtt.MqttConnectMessage connMess = mqtt.MqttConnectMessage()
        .withClientIdentifier(clientIdentifier)
//        .startClean() // Non persistent session for testing
        .keepAliveFor(120)
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

  Future sleep5() {
    return new Future.delayed(const Duration(seconds: 5), () => "5");
  }

  Future<void> _disconnect() async {
    print('[MQTT client] _disconnect()');
    client.disconnect();
    _onDisconnected();
//    print('[MQTT client] MQTT client reconnecting...');
//    connect();
//    await loadSharedPrefs();
//    print('[MQTT client] connected');
  }

  Future<void> _onDisconnected() async {
    print('[MQTT client] _onDisconnected');
//    topics.clear();
    connectionState = client.connectionState;
    client = null;
    subscription.cancel();
    subscription = null;
    await sleep5();
    showDialog();
//    print('[MQTT client] MQTT client disconnected');
//    await sleep5();
//    print('[MQTT client] MQTT client reconnecting...');
//    await connect();
//    await loadSharedPrefs();
//    print('[MQTT client] connected');
  }

  void onMessage(List<mqtt.MqttReceivedMessage> event) {
    print(event.length);
    final mqtt.MqttPublishMessage recMess =
    event[0].payload as mqtt.MqttPublishMessage;
    final String message =
    mqtt.MqttPublishPayload.bytesToStringAsString(recMess.payload.message);

    print('[MQTT client] MQTT message: topic is <${event[0].topic}>, '
        'payload is <-- ${message} -->');
    print("[MQTT client] " + client.connectionStatus.toString());
    print("[MQTT client] message with topic: ${event[0].topic}");
    print("[MQTT client] message with message: ${message}");
    updateList(event[0].topic, message);
  }
}