import "package:flutter_dotenv/flutter_dotenv.dart";
import "package:http/http.dart";

Future createPaymentIntent(
    {required String name,
    required String address,
    required String pin,
    required String city,
    required String state,
    required String country,
    required String currency,
    required String amount}) async {
  // final url =
  // final secretKey =
  final body = {
      "amount": amount,
      "currency": currency.toLowerCase(),
      // "automatic_payment_methods[enabled]"
      "description": "payment for $name",
      "shipping[name]": name,
      "shipping[address][line1]": address,
      "shipping[address][potal_code]": pin,
      "shipping[address][city]": city,
      "shipping[address][state]": state,
      "shipping[address][country]": country
  };
}
