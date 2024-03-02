import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:sukoon/Const/constant.dart';
import 'package:sukoon/Pages/deviceInstr.dart';
import 'package:sukoon/Pages/ffff.dart';
import 'package:sukoon/Pages/mainDania.dart';
import 'package:sukoon/widgets.dart';
import 'package:get/get.dart';
import 'dart:async';
import 'package:http/http.dart' as http;

class EEG_Session extends StatefulWidget {
  const EEG_Session({super.key});

  @override
  State<EEG_Session> createState() => _EEG_SessionState();
}
///////////////////////////////////////////////////////

class _EEG_SessionState extends State<EEG_Session> {

  Future<void> fetchresult(String result) async {
    final url = Uri.parse("http://10.0.2.2:8000/history/1/result");
    final response = await http.put(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'result': result,
      }),
    );

        if (response.statusCode == 200) {
      // Data updated successfully
      print('Data updated successfully');
    } else {
      // Error updating data
      print('Failed to update data. Status code: ${response.statusCode}');
      print('Response body: ${response.body}');
    }
  }

Future<String> getDataResult() async {
  try {
    var response = await http.get(Uri.parse("http://10.0.2.2:8000/history/1/result"));
    if (response.statusCode == 200) {
      var responseBody = jsonDecode(response.body) as List<dynamic>; 
      if (responseBody.isNotEmpty) {
        var firstItem = responseBody.first; 
        if (firstItem is String) {
          return firstItem;
        } else {
          throw Exception('Response body does not contain a string');
        }
      } else {
        throw Exception('Response body is empty');
      }
    } else {
      throw Exception('Failed to fetch data. Status code: ${response.statusCode}');
    }
  } catch (e) {
    print('Error getting data: $e');
    throw e;
  }
}



  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        Container(
          height: 236,
          decoration: const BoxDecoration(color: Color(darkBlue), boxShadow: [
            BoxShadow(
              color: Color(darkerGray),
              blurRadius: 5,
              spreadRadius: 2,
              offset: Offset(0, 2),
            )
          ]),
          child: Column(
            children: [
              SizedBox(
                height: 70,
              ),
              Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => Settings()));
                    },
                    child: const Padding(
                      padding: EdgeInsets.all(15.0),
                      child: Align(
                        alignment: Alignment.topLeft,
                        child: Icon(
                          Icons.settings_outlined,
                          color: Color(lightBlue1),
                          size: 30,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 20,
                  ),
                  Text(
                    "Emotion Recognition",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "5 ",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold),
                  ),
                  Text(
                    "rounds",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                    ),
                  ),
                  SizedBox(
                    width: 40,
                  ),
                  Text(
                    "10 ",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold),
                  ),
                  Text(
                    "min each",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
        Column(
          children: [
            const SizedBox(
              height: 240,
            ),
            //Image(image: AssetImage("")),
            const wideGrayBotton(
                label: "Instrection Device", page: DeviceInstr()),
            const SizedBox(
              height: 15,
            ),
            const SizedBox(
              height: 15,
            ),
            wideGrayBotton(
                label: "EEG Session",
                weindow: () => _showModalBottomSheet(context)),
            const SizedBox(
              height: 15,
            ),
          ],
        ),
      ],
    );
  }
}

void _showDialog(
  BuildContext context,
) {
  showDialog(
      context: context,
      builder: (BuildContext context) {
        return AdvancedCustomAlert();
      });
}


void _showModalBottomSheet(BuildContext context) async {
   var result = await getDataResult(); 
  await showModalBottomSheet(
    backgroundColor: Color(lightGray),
    context: context,
    builder: (BuildContext context) {
      return SizedBox(
        height: 500,
        child: Column(
          children: [
            SizedBox(
              height: 30,
            ),

            Timer1(),
            //const wideBlueBotton( label: "Start",page: EEG_Session(),),
            SizedBox(height: 10), // Add spacing between elements
            // Add other elements as needed
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.receipt_long_outlined,
                  color: Color(darkBlue),
                  size: 50,
                ),
             Text(
  "Result:  $result",
  style: TextStyle(color: Color(darkBlue), fontSize: 30),
)

              ],
            )
          ],
        ),
      );
    },
  );
}

class TimerController extends GetxController {
  Timer? _timer;
  int remainingSeconds = 1;
  final time = '00.00'.obs;

  @override
  void onReady() {
    _startTimer(900);
    super.onReady();
  }

  @override
  void onClose() {
    if (_timer != null) {
      _timer!.cancel();
    }

    super.onClose();
  }

  _startTimer(int seconds) {
    const duration = Duration(seconds: 1);
    remainingSeconds = seconds;
    _timer = Timer.periodic(duration, (timer) {
      if (remainingSeconds == 0) {
        timer.cancel();
      } else {
        int minutes = remainingSeconds ~/ 60;
        int seconds = (remainingSeconds % 60);
        time.value = minutes.toString().padLeft(2, "0") +
            ":" +
            seconds.toString().padLeft(2, "0");
        remainingSeconds--;
      }
    });
  }
}
