import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:pedometer/pedometer.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

String formatDate(DateTime d) {
  return d.toString().substring(0, 19);
}

class _HomePageState extends State<HomePage> {
  int dist = 0;
  int calories = 0;
  static DateTime dateTime = DateTime.now();
  String date = DateFormat('dd-MM-yyyy').format(dateTime);
  double dateValue = double.parse(DateFormat('dd').format(dateTime));
  int totalDist = 0;
  int totalCalories = 0;
  int dailySteps = 0;
  int graphNum1=5;
  bool b1 = true;
  bool b2 = false;
  bool b3 = false;
  bool b4 = true;
  bool b5 = false;
  bool b6 = false;

  SharedPreferences sharedPreferences;
  Stream<StepCount> _stepCountStream;
  Stream<PedestrianStatus> _pedestrianStatusStream;
  String _status = '?',
      _steps = '?';
  int sub;
  List<SalesData> stepsData = [
    SalesData(26, 3221),
    SalesData(27, 4478),
    SalesData(28, 2672),
  ];
  List<SalesData> calorieData = [
    SalesData(26, 129),
    SalesData(27, 179),
    SalesData(28, 106),
  ];
  List<SalesData> distanceData = [
    SalesData(26, 2),
    SalesData(27, 3),
    SalesData(28, 2),
  ];
  List<SalesData> monthlyStepsData = [
    SalesData(26, 3221),
    SalesData(27, 4478),
    SalesData(28, 2672),
  ];
  List<SalesData> monthlyCalorieData = [
    SalesData(26, 129),
    SalesData(27, 179),
    SalesData(28, 106),
  ];
  List<SalesData> monthlyDistanceData = [
    SalesData(26, 2),
    SalesData(27, 3),
    SalesData(28, 2),
  ];
  static int hour = int.parse(DateFormat('h').format(dateTime));
  static int min = int.parse(DateFormat('m').format(dateTime));
  int time = 1440 - (hour * 60 + min);
  int graphNum = 0;
  var data;

  @override
  void initState() {
    super.initState();
    getSteps();
    initFirebase();
    initPlatformState();
    print("time" + dateValue.toString());
    Timer.periodic(Duration(minutes: time), (timer) {
      print("insideTime");
      updateData(0);
    });
  }

  initFirebase() {
    Firebase.initializeApp();
  }

  getSteps() async {
    sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setString("todayDate", date);
  }

  void onStepCount(StepCount event) {
    print(event);

    setState(() {
      _steps = event.steps.toString();
    });
    if (sharedPreferences.getString("first") == null) {
      sharedPreferences.setInt("steps1", int.parse(_steps));
      sharedPreferences.setString("first", "done");
      sub = sharedPreferences.getInt("steps1");
      dailySteps = int.parse(_steps) - sub;
      dist = (dailySteps * 0.0008).round();

      calories = (dailySteps * 0.04).round();

      updateData(0);
    } else {
      if (sub == null) {
        setPrevData();
      }
      if (sub != null) {
        dailySteps = int.parse(_steps) - sub;
        dist = (dailySteps * 0.0008).round();

        calories = (dailySteps * 0.04).round();

        updateData(1);
      }
    }
    totalDist = (int.parse(_steps) * 0.0008).round();
    totalCalories = (int.parse(_steps) * 0.04).round();
  }

  void onPedestrianStatusChanged(PedestrianStatus event) {
    print(event);
    setState(() {
      _status = event.status;
    });
  }

  void onPedestrianStatusError(error) {
    print('onPedestrianStatusError: $error');
    setState(() {
      _status = 'Pedestrian Status not available';
    });
    print(_status);
  }

  void onStepCountError(error) {
    print('onStepCountError: $error');
    setState(() {
      _steps = 'Step Count not available';
    });
  }

  void initPlatformState() {
    _pedestrianStatusStream = Pedometer.pedestrianStatusStream;
    _pedestrianStatusStream
        .listen(onPedestrianStatusChanged)
        .onError(onPedestrianStatusError);

    _stepCountStream = Pedometer.stepCountStream;
    _stepCountStream.listen(onStepCount).onError(onStepCountError);

    if (!mounted) return;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text("Home"),
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(

        child: Column(

          children: <Widget>[
            Center(
              child: Column(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Text(
                      'Pedestrian status:',
                      style: TextStyle(fontSize: 30),
                    ),
                  ),
                  _status == 'walking'
                      ? Lottie.asset(
                    'assets/walking.json',
                    width: 200,
                    repeat: true,
                    height: 200,
                  )
                      : _status == 'stopped'
                      ? Lottie.asset(
                    'assets/standing.json',
                    width: 220,
                    repeat: true,
                    height: 220,
                  )
                      : Icon(Icons.error),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 8.0, top: 3.0, right: 3.0),
              child: Container(
                padding: EdgeInsets.all(5),
                alignment: Alignment.topLeft,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(width: 1, color: Colors.black87)),
                child: Column(
                  children: <Widget>[
                    Text(
                      "Today's Report:",
                      style: GoogleFonts.lato(
                          fontSize: 24, fontWeight: FontWeight.w700),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: <Widget>[
                          Column(
                            children: <Widget>[
                              Text(
                                dailySteps.toString(),
                                style: GoogleFonts.lato(fontSize: 24),
                              ),
                              Padding(
                                padding: EdgeInsets.only(top: 5),
                              ),
                              Image.asset(
                                'assets/steps.png',
                              ),
                            ],
                          ),
                          Column(
                            children: <Widget>[
                              Text(
                                dist.toString(),
                                style: GoogleFonts.lato(fontSize: 24),
                              ),
                              Padding(
                                padding: EdgeInsets.only(top: 5),
                              ),
                              Image.asset(
                                'assets/distance.png',
                              ),
                            ],
                          ),
                          Column(
                            children: <Widget>[
                              Text(
                                calories.toString(),
                                style: GoogleFonts.lato(fontSize: 24),
                              ),
                              Padding(
                                padding: EdgeInsets.only(top: 5),
                              ),
                              Image.asset(
                                'assets/calories.png',
                              ),
                            ],
                          )
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(left: 8.0, top: 15.0, right: 3.0,bottom: 5),
              child: Container(
                padding: EdgeInsets.all(5),
                alignment: Alignment.topLeft,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(width: 1, color: Colors.black87)),
                child: Column(
                  children: <Widget>[
                    Text(
                      "Last 7 Days:",
                      style: GoogleFonts.lato(
                          fontSize: 24, fontWeight: FontWeight.w700),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: <Widget>[
                        FlatButton.icon(
                            icon: Image.asset(
                              'assets/steps.png',
                              width: 32,
                              height: 32,
                            ),
                            color:b1?Colors.black54:Colors.white,

                            onPressed: () {
                              //chartData = dailyGraph();
                              b3=false;
                              b1=true;
                              b2=false;
                              setState(() {
                                graphNum = 0;
                              });
                            },
                            label: Text(
                              '',
                            )),
                        FlatButton.icon(
                            onPressed: () {
                              print("hi");
                              setState(() {
                                b3=false;
                                b1=false;
                                b2=true;
                                graphNum = 1;
                              });
                            },
                            color:b2?Colors.black54:Colors.white,
                            icon: Image.asset(
                              'assets/distance.png',
                              width: 32,
                              height: 32,
                            ),
                            label: Text(
                              '',
                            )),
                        FlatButton.icon(
                            padding: EdgeInsets.all(5),
                            icon: Image.asset(
                              'assets/calories.png',
                              width: 32,
                              height: 32,
                            ),
                            color:b3?Colors.black54:Colors.white,
                            onPressed: () {
                              setState(() {
                                b3=true;
                                b1=false;
                                b2=false;
                                graphNum = 2;
                              });
                            },
                            label: Text(
                              '',
                            )),
                      ],
                    ),
                    if (graphNum == 0)
                      Container(
                          child: SfCartesianChart(series: <ChartSeries>[

                            // Renders line chart
                            ColumnSeries<SalesData, int>(
                                dataSource: stepsData,
                                xValueMapper: (SalesData sales, _) =>
                                sales.date,
                                yValueMapper: (SalesData sales, _) => sales.val,
                                width: 0.3,
                                spacing: 2)
                          ])),
                    if(graphNum==1)Container(
                        child: SfCartesianChart(series: <ChartSeries>[

                          // Renders line chart
                          ColumnSeries<SalesData, int>(
                              dataSource: distanceData,
                              xValueMapper: (SalesData sales, _) =>
                              sales.date,
                              yValueMapper: (SalesData sales, _) => sales.val,
                              width: 0.3,
                              spacing: 2)
                        ])),
                    if(graphNum==2)Container(
                        child: SfCartesianChart(series: <ChartSeries>[

                          // Renders line chart
                          ColumnSeries<SalesData, int>(
                              dataSource: calorieData,
                              xValueMapper: (SalesData sales, _) =>
                              sales.date,
                              yValueMapper: (SalesData sales, _) => sales.val,
                              width: 0.3,
                              spacing: 2)
                        ])),
                  ],
                ),
              ),
            ),Padding(
              padding: EdgeInsets.only(left: 8.0, top: 15.0, right: 3.0,bottom: 3),
              child: Container(
                padding: EdgeInsets.all(5),
                alignment: Alignment.topLeft,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(width: 1, color: Colors.black87)),
                child: Column(
                  children: <Widget>[
                    Text(
                      "Last 30 Days:",
                      style: GoogleFonts.lato(
                          fontSize: 24, fontWeight: FontWeight.w700),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: <Widget>[
                        FlatButton.icon(
                            icon: Image.asset(
                              'assets/steps.png',
                              width: 32,
                              height: 32,
                            ),
                            color:b4?Colors.black54:Colors.white,

                            onPressed: () {
                              //chartData = dailyGraph();

                              setState(() {
                                graphNum1 = 5;
                                b6=false;
                                b4=true;
                                b5=false;
                              });
                            },
                            label: Text(
                              '',
                            )),
                        FlatButton.icon(
                            onPressed: () {
                              print("hi");
                              setState(() {
                                b4=false;
                                b6=false;
                                b5=true;
                                graphNum1 = 6;
                              });
                            },
                            color:b5?Colors.black54:Colors.white,
                            icon: Image.asset(
                              'assets/distance.png',
                              width: 32,
                              height: 32,
                            ),
                            label: Text(
                              '',
                            )),
                        FlatButton.icon(
                            padding: EdgeInsets.all(5),
                            icon: Image.asset(
                              'assets/calories.png',
                              width: 32,
                              height: 32,
                            ),
                            color:b6?Colors.black54:Colors.white,
                            onPressed: () {
                              setState(() {
                                b6=true;
                                b5=false;
                                b4=false;
                                graphNum1 = 7;
                              });
                            },
                            label: Text(
                              '',
                            )),
                      ],
                    ),
                    if (graphNum1 == 5)
                      Container(
                          child: SfCartesianChart(series: <ChartSeries>[

                            // Renders line chart
                            SplineSeries<SalesData, int>(
                                dataSource: stepsData,
                                xValueMapper: (SalesData sales, _) =>
                                sales.date,
                                yValueMapper: (SalesData sales, _) => sales.val,
                                width: 3,
                                )
                          ])),
                    if(graphNum1==6)Container(
                        child: SfCartesianChart(series: <ChartSeries>[

                          // Renders line chart
                          SplineSeries<SalesData, int>(
                              dataSource: distanceData,
                              xValueMapper: (SalesData sales, _) =>
                              sales.date,
                              yValueMapper: (SalesData sales, _) => sales.val,
                              width: 3,
                              )
                        ])),
                    if(graphNum1==7)Container(
                        child: SfCartesianChart(series: <ChartSeries>[

                          // Renders line chart
                          SplineSeries<SalesData, int>(
                              dataSource: calorieData,
                              xValueMapper: (SalesData sales, _) =>
                              sales.date,
                              yValueMapper: (SalesData sales, _) => sales.val,
                              width: 3,
                             )
                        ])),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 8.0, top: 3.0, right: 3.0),
              child: Container(
                padding: EdgeInsets.all(5),
                alignment: Alignment.topLeft,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(width: 1, color: Colors.black87)),
                child: Column(
                  children: <Widget>[
                    Text(
                      "Total Report:",
                      style: GoogleFonts.lato(
                          fontSize: 24, fontWeight: FontWeight.w700),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: <Widget>[
                          Column(
                            children: <Widget>[
                              Text(
                                _steps,
                                style: GoogleFonts.lato(fontSize: 24),
                              ),
                              Padding(
                                padding: EdgeInsets.only(top: 5),
                              ),
                              Image.asset(
                                'assets/steps.png',
                              ),
                            ],
                          ),
                          Column(
                            children: <Widget>[
                              Text(
                                totalDist.toString(),
                                style: GoogleFonts.lato(fontSize: 24),
                              ),
                              Padding(
                                padding: EdgeInsets.only(top: 5),
                              ),
                              Image.asset(
                                'assets/distance.png',
                              ),
                            ],
                          ),
                          Column(
                            children: <Widget>[
                              Text(
                                totalCalories.toString(),
                                style: GoogleFonts.lato(fontSize: 24),
                              ),
                              Padding(
                                padding: EdgeInsets.only(top: 5),
                              ),
                              Image.asset(
                                'assets/calories.png',
                              ),
                            ],
                          )
                        ],
                      ),
                    )
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  updateData(int x) {
    String id = FirebaseAuth.instance.currentUser.uid;

    DocumentReference reference =
    FirebaseFirestore.instance.collection("user").doc(id);

    reference
        .collection("dailySteps")
        .doc(date)
        .set({"date": dateValue, "steps": dailySteps});
    if (x == 0) {
      reference.collection("steps").doc("steps").set({"steps": _steps});
    }
    reference
        .collection("distance")
        .doc(date)
        .set({"date": dateValue, "distance": dist});
    reference
        .collection("calorie")
        .doc(date)
        .set({"date": dateValue, "calorie": calories});
  }

  setPrevData() {
    String id = FirebaseAuth.instance.currentUser.uid;

    DocumentReference reference =
    FirebaseFirestore.instance.collection("user").doc(id);
    reference.collection("steps").doc("steps").get().then((queryData) {
      sub = int.parse(queryData.data()["steps"]);
      print(sub);
    });
  }

  dailyGraph() {
    String id = FirebaseAuth.instance.currentUser.uid;
    var mapData = Map();
    DocumentReference reference =
    FirebaseFirestore.instance.collection("user").doc(id);
    reference
        .collection("calorie")
        .orderBy("date", descending: true)
        .limit(7)
        .get()
        .then((querySnapshot) {
      querySnapshot.docs.forEach((result) {
        int cal = result.data()['calorie'];
        int date = result.data()['date'];
        mapData[date] = cal;
      });
    });
    List<SalesData> chartData;
    mapData.forEach((key, value) => chartData.add(SalesData(key, value)));
    return chartData;
  }
}

class SalesData {
  SalesData(this.date, this.val);

  final int date;
  final int val;
}
