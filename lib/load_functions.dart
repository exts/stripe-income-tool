import 'dart:io';
import 'package:stripe_income/options_model.dart';
import 'package:yaml/yaml.dart';

String loadApiKey(String filename) {
  var file = new File(filename);
  if(!file.existsSync()) {
    throw Exception("Api settings file ($filename) doesn't exist");
  }

  var data = file.readAsStringSync();
  if(data.length <= 0) {
    throw Exception("Api settings file ($filename) is empty");
  }

  Map yaml;

  try {
    yaml = loadYaml(data);
  } catch (e) {
    throw Exception("Settings file ($filename) contains invalid yaml");
  }

  if(yaml["secret"] == null || yaml["secret"].length <= 0) {
    throw Exception("'secret' key isn't set in api file");
  }

  return yaml["secret"];  
}

OptionsModel loadOptions(String filename) {
  var file = new File(filename);
  if(!file.existsSync()) {
    return OptionsModel();
  }

  var data = file.readAsStringSync();
  if(data.length <= 0) {
    return OptionsModel();
  }

  Map yaml;

  try {
    yaml = loadYaml(data);
  } catch (e) {
    throw Exception("Options file ($filename) contains invalid yaml");
  }

  try {
    return OptionsModel.fromYamlMap(yaml);
  } catch (e) {
    throw Exception("Couldn't parse options model from yaml data - $e");
  }
}