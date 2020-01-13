import 'package:jiffy/jiffy.dart';
import 'package:yaml/yaml.dart';

class OptionsModel {

  Jiffy startDate;
  Jiffy endDate;
  List<int> ignoreYear = List<int>();

  OptionsModel();

  OptionsModel.fromYamlMap(YamlMap data) {
    // optional
    if(data["start_date"] != null) {
      startDate = Jiffy(data["start_date"]);
    }

    if(data["end_date"] != null) {
      endDate = Jiffy(data["end_date"]);
    }

    if(data["ignore_year"] != null) {
      ignoreYear.clear();
      for(var year in data["ignore_year"]) {
        ignoreYear.add(year);  
      }
    }
  }

  Map toMap() {
    return {
      "start_date": startDate,
      "end_date": endDate,
      "ignore_year": ignoreYear,
    };
  }

  String toString() {
    return toMap().toString();
  }
}