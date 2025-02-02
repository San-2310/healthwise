import 'dart:async';
import 'dart:convert';

import 'package:healthwise_patient_app/sos_call.dart';
import 'package:http/http.dart' as http;

const String vitalsUrl = 'http://10.21.9.214:8080';
const String postUrl = 'http://10.21.9.214:8000/monitor_vitals';
final TwilioService twilioService = TwilioService(
  accountSid: 'AC24d4c38e95b1445415f975fbb1cb9064',
  authToken: 'd19f53e11fcc22c3889adcf79e9191cd',
);
Future<void> fetchAndSendVitals() async {
  try {
    // Fetch vitals from vitals server
    final vitalsResponse = await http.get(Uri.parse(vitalsUrl));
    if (vitalsResponse.statusCode != 200) {
      print('Error fetching vitals: ${vitalsResponse.statusCode}');
      return;
    }

    // Parse the fetched JSON
    final Map<String, dynamic> vitals = jsonDecode(vitalsResponse.body);

    // Convert all values to int
    // final Map<String, int> vitalsData = {
    //   "heart_rate": (vitals["heart_rate"] ?? 70),
    //   "blood_pressure_systolic": (vitals["blood_pressure_systolic"] ?? 80),
    //   "blood_pressure_diastolic": (vitals["blood_pressure_diastolic"] ?? 120),
    //   "spo2": (vitals["spo2"] ?? 98),
    //   "temperature": (vitals["temperature"] ?? 36),
    // };
    // final Map<String, int> vitalsData = {
    //   "heart_rate": (120),
    //   "blood_pressure_systolic": (188),
    //   "blood_pressure_diastolic": (100),
    //   "spo2": (94),
    //   "temperature": (40),
    // };

    final Map<String, int> vitalsData = {
      "heart_rate": (78),
      "blood_pressure_systolic": (118),
      "blood_pressure_diastolic": (80),
      "spo2": (98),
      "temperature": (37),
    };

    // Send POST request
    final postResponse = await http.post(
      Uri.parse(postUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(vitalsData),
    );

    if (postResponse.statusCode == 200) {
      // Convert response to string
      String responseString = postResponse.body.toString();
      print(responseString);
      if (responseString.contains('true')) {
        await twilioService.makeCall(
          to: '+917506547624', // The recipient's phone number
          from: '+17856209248', // Your Twilio phone number
          url:
              'https://handler.twilio.com/twiml/EH83be83e4747facf3a85789e34aaeee82', // TwiML Bin URL
        );
        print('Anomaly detected');
      } else {
        print('No anomaly detected');
      }
      // Extract character after `{\"is_anomaly\":`
      // int index = responseString.indexOf('{\"is_anomaly\":') + 14;
      // if (index > 13 && index < responseString.length) {
      //   String anomalyChar = responseString[index];
      //   if (anomalyChar == 'f') {
      //     print('false');
      //   } else if (anomalyChar == 't') {
      //     print('true');
      //   } else {
      //     print('Unexpected format');
      //   }
      // } else {
      //   print('Error parsing response');
      // }
    } else {
      print('Error sending vitals: ${postResponse.statusCode}');
    }
  } catch (e) {
    print('Exception: $e');
  }
}

void main() {
  print('Starting vital sign monitor...');
  fetchAndSendVitals(); // Initial call
  Timer.periodic(Duration(minutes: 2), (timer) => fetchAndSendVitals());
}
