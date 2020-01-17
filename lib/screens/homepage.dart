import 'package:flutter/material.dart';
import 'package:scan_temp/addSensor.dart';
import 'package:scan_temp/screens/addSenorScreen.dart';

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<addSensor> sensors = [];

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
  }
}