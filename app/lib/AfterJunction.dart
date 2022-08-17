import 'package:flutter/material.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

class PageAfterJunction extends StatefulWidget {
  const PageAfterJunction({Key? key}) : super(key: key);

  @override
  State<PageAfterJunction> createState() => _PageAfterJunctionState();
}

class _PageAfterJunctionState extends State<PageAfterJunction> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(
            appBar: AppBar(
              title: const Text('After Junction'),
              leading: IconButton(
                icon: Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
            body: Column(
              children: [
                FixedAfterJunction(),
                Padding(
                  padding: const EdgeInsets.only(left: 50.0),
                  child: TemperatureView(),
                )
              ],
            )));
  }
}

class FixedAfterJunction extends StatelessWidget {
  const FixedAfterJunction({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 0.0, top: 40.0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(30),
              child: Image.asset('image/AfterJunction.jpg'),
            ),
          ),
        ],
      ),
    );
  }
}

class TemperatureView extends StatefulWidget {
  @override
  TemperatureViewState createState() {
    return TemperatureViewState();
  }
}

class TemperatureViewState extends State<TemperatureView> {
  String? TemperatureAfterJunction;

  final client =
      MqttServerClient('eu1.cloud.thethings.network:1883', 'mandymadongyimsm');

  @override
  void initState() {
    super.initState();

    TemperatureAfterJunction = "Please wait a second!";

    startMQTT();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    client.disconnect();
    print('client disconnected');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        child: Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(right: 40, top: 40.0),
          child: Text(
            'Temperature: $TemperatureAfterJunction',
            textAlign: TextAlign.left,
            style: TextStyle(fontSize: 20),
          ),
        ),
      ],
    ));
  }

  updateList(String s, int i) {
    setState(() {
      if (i == 0) {
        TemperatureAfterJunction = s;
      }
    });
  }

  Future<void> startMQTT() async {
    client.port = 1884;
    client.setProtocolV311();
    client.keepAlivePeriod = 10;
    const String username = 'dissertationwater@ttn';
    const String password =
        'NNSXS.45L2GK6JKH5XXUZHBBJI7YW3JD3L5KRGKZUBU5I.A7GUGVYVLCSSS6S6CIH6QKYOH4YY7CBUTN63CICIVFP73CMM7QPA';
    try {
      await client.connect(username, password);
    } catch (e) {
      print('client exception - $e');
      client.disconnect();
    }
    if (client.connectionStatus!.state == MqttConnectionState.connected) {
      print('Mosquitto client connected');
    } else {
      print(
          'ERROR Mosquitto client connection failed - disconnecting, state is ${client.connectionStatus!.state}');
      client.disconnect();
    }
    const topic1 = 'v3/dissertationwater@ttn/devices/eui-a8610a3135268218/up';
    client.subscribe(topic1, MqttQos.atMostOnce);
    client.updates!.listen((List<MqttReceivedMessage<MqttMessage?>>? c) {
      final receivedMessage = c![0].payload as MqttPublishMessage;
      final messageString = MqttPublishPayload.bytesToStringAsString(
          receivedMessage.payload.message);
      print(
          'Change notification:: topic is <${c[0].topic}>, payload is <-- $messageString -->');
      if (c[0].topic == topic1) {
        updateList(messageString, 0);
      }
    });
  }
}
