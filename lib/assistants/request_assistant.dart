import 'dart:convert';

import 'package:http/http.dart' as http;

class RequestAssistant {
  static Future<dynamic> recieveRequest(String url) async {
    http.Response httpResponse = await http.get(Uri.parse(url));

    try {
      if (httpResponse.statusCode == 200) //successfull response
      {
        String responseData = httpResponse.body; //json response

        var decodeResponseData = jsonDecode(responseData);

        return decodeResponseData;
      } else {
        return "Error occured,No response.";
      }
    } catch (exp) {
      return "Error occured,No Response.";
    }
  }
}
