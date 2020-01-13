import 'package:args/args.dart';
import 'package:stripe_income/load_functions.dart';
import 'package:stripe_income/api.dart';

const apiLimit = 5; // data per request, limit is 100 max
const apiFilename = "api.yml";
const settingsFilename = "settings.yml";

void main(List<String> args) async {

  var parser = ArgParser();
  parser.addFlag("debug", abbr: "d");

  var argResults = parser.parse(args);
  var debug = argResults["debug"] ?? false;

  try {
    var secret = loadApiKey(apiFilename);
    var options = loadOptions(settingsFilename);
    var api = Api(secret, options, apiLimit);

    print("Fetching transactions...");

    await api.fetchResults();

    var income = api.calculateIncomeAndFees();
    print("Your income: Total \$(${income['income']}), Net Total \$(${income['income_net']}), Fees \$(${income['fees']})");

    // create debug info
    if(debug) {
      api.debugData();
    }

  } on Exception catch(e) {
    print("There was an error: ${errMsg(e.toString())}");
  }
}

String errMsg(String msg) {
  return msg.replaceAll("Exception: ", "");
}