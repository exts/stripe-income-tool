import 'package:args/args.dart';
import 'package:money2/money2.dart';
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

    var total = debug ? "\$${income['income']}" : Money.from(income['income'], Currency.create('USD', 2));
    var totalNet = debug ? "\$${income['income_net']}": Money.from(income['income_net'], Currency.create('USD', 2));
    var totalFee = debug ? "\$${income['fees']}" : Money.from(income['fees'], Currency.create('USD', 2));

    print("Your income: Total $total, Net Total $totalNet, Fees $totalFee");

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