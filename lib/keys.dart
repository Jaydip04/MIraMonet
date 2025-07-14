// String Publishablekey = "pk_test_51Oma0oHv8tw3Pk25d2VPv1ilLFSBBYysoPtRjh6F01FOFUX5COqN4HVNUCwuudmlqUlrSoVuCooHQewpUfDUQSWJ00vmyt0jYB";
// String Secretkey = "sk_test_51Oma0oHv8tw3Pk25iuZk5eGcViMTIQfXb9TQm4rcdsKBcsh8GxITolT3fUMU5gG0HVP6hehbMaM8sIsgtXmSZZ1100MjVS8Vw8";
class StripeKeys {
  static String publishableKey = "";
  static String secretKey = "";

  static void setKeys(String pubKey, String secKey) {
    publishableKey = pubKey;
    secretKey = secKey;
  }
}
