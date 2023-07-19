class PredictedPlaces {
  String? placeid;
  String? maintext;
  String? secondarytext;

  PredictedPlaces({
    this.placeid,
    this.maintext,
    this.secondarytext,
  });

  PredictedPlaces.fromJson(Map<String, dynamic> jsonData) {
    placeid = jsonData["place_id"];
    maintext = jsonData["structured_formatting"]["main_text"];
    secondarytext = jsonData["structured_formatting"]["secondary_text"];
  }
}
