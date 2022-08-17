import 'package:flutter/material.dart';
import 'PortlandsLakeEast.dart';
import 'PondA.dart';
import 'PondB.dart';
import 'BeforeJunction.dart';
import 'AfterJunction.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: "River Temperature Monitor",
      theme: new ThemeData(primarySwatch: Colors.blue),
      home: new Homepage(),
    );
  }
}

class Homepage extends StatefulWidget {
  const Homepage({Key? key}) : super(key: key);

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(
            appBar: AppBar(
              title: Text('River Temperature Monitor'),
            ),
            body: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 25.0, top: 70.0),
                  child: Text('Select the location you want to browse',
                      style: TextStyle(fontSize: 20)),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 30.0),
                  child: Namelist(),
                ),
                Notification(),
              ],
            )));
  }
}
// app bar

class Namelist extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(children: [
        Column(children: [
          ElevatedButton(
            child: Text('1. Portlands Lake East'),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return PagePortlandsLakeEast();
              }));
            },
            style: TextButton.styleFrom(
              primary: Colors.white, // Text Color
            ),
          ),
          ElevatedButton(
            child: Text('2. Pond A'),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return PagePondA();
              }));
            },
          ),
          ElevatedButton(
            child: Text('3. Pond B'),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return PagePondB();
              }));
            },
          ),
          ElevatedButton(
            child: Text('4. Before Junction'),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return PageBeforeJunction();
              }));
            },
          ),
          ElevatedButton(
            child: Text('5. After Junction'),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return PageAfterJunction();
              }));
            },
          )
        ]),
      ]),
    );
  }
}

// buttons

class Notification extends StatefulWidget {
  const Notification({Key? key}) : super(key: key);

  @override
  State<Notification> createState() => _NotificationState();
}

class _NotificationState extends State<Notification> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 2.0, top: 20.0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(30),
              child: Image.asset('image/Map.jpg'),
            ),
          ),
        ],
      ),
    );
  }
}
// map
