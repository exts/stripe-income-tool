import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:random_string/random_string.dart';
import 'package:stripe_income/options_model.dart';
import 'package:stripe_income/transaction_model.dart';

class Api {
  int limit;
  int total = 10;
  String type = "charge";

  String secret;
  OptionsModel options;
  Map<String, dynamic> queryData = Map<String, dynamic>();
  List<TransactionModel> transactions = List<TransactionModel>();
  List<TransactionModel> transactionsPagination = List<TransactionModel>();

  String apiUrl = "https://api.stripe.com/v1/balance_transactions";

  Api(this.secret, this.options, [this.limit = 100]) {
    buildQueryData();
  }

  void buildQueryData() {
    queryData["type"] = type;
    queryData["limit"] = this.limit.toString();

    if(options.startDate != null) {
      queryData["created[gte]"] = options.startDate.unix().toString();
    }

    if(options.endDate != null) {
      queryData["created[lte]"] = options.endDate.unix().toString();
    }
  }

  Uri buildUri() {
    var uri = Uri.parse(apiUrl);
    return Uri(scheme: uri.scheme, host: uri.host, path: uri.path, queryParameters: queryData);
  }

  void fetchResults([String objectId = null]) async {
    if(objectId != null) {
      queryData["starting_after"] = objectId;
    }

    var url = buildUri().toString();
    var client = http.Client();
    try {
      var headers = {
        HttpHeaders.authorizationHeader: "Bearer ${this.secret}",
        HttpHeaders.contentTypeHeader: "application/x-www-form-urlencoded",
      };

      var response = await client.get(url, headers: headers);
      var data = jsonDecode(response.body);

      if(data["error"] != null) {
        var error = data["error"];
        throw Exception("There was an error fetching data from stripe: ${error['code']} - ${error['message']}");
      }
      
      for(var result in data["data"]) {
        var entry = TransactionModel.fromMap(result);
        transactionsPagination.add(entry);
        if(options.ignoreYear.contains(entry.created.year)) continue;
        transactions.add(entry);
      }
      
      if(data["has_more"] != null && data["has_more"] == true && transactionsPagination.length > 0) {
        await fetchResults(transactionsPagination.last.id);
      }

    } finally {
      client.close();
    }
  }

  Map calculateIncomeAndFees() {
    if(transactions.length <= 0) {
      return {
        "fees": 0,
        "income": 0,
        "income_net": 0,
      };
    }

    double income = 0, income_net = 0, fees = 0;

    for(var transaction in transactions) {
      fees += transaction.fee;
      income += transaction.amount;
      income_net += transaction.net;
    }

    return {
      "fees": fees,
      "income": income,
      "income_net": income_net,
    };
  }

  void debugData() {
    List<Map> data = List<Map>();

    for(var transaction in transactions) {
      data.add(transaction.toMap());
    }

    var filename = "debug.${randomAlphaNumeric(10)}.log";
    var file = File(filename);
    try {
      file.writeAsStringSync(jsonEncode(data));
      print("Debug file created: ${filename}");
    } catch (e) {
      print("Problem creating debug file: ${filename}");
    }
  }
}