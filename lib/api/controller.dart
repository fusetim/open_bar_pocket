import 'dart:convert';
import 'dart:developer';

import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:native_dio_adapter/native_dio_adapter.dart';
import 'package:open_bar_pocket/models/account.dart';
import 'package:open_bar_pocket/models/category.dart';

class ApiController {
  final Dio _httpClient = Dio()..httpClientAdapter = NativeAdapter();

  String? baseUrl = null;
  OpenBarConfig? _config = null;
  CookieJar _jar = CookieJar();

  /// Set the base url of the OpenBar server.
  ///
  /// The following url is not the URL of the API endpoint but of the OpenBar application.
  /// The api endpoint will be fetched in the future by [updateApiConfig].
  void setBaseUri(String url) {
    if (baseUrl == null) {
      _httpClient.interceptors.add(CookieManager(_jar));
    }
    baseUrl = url;
  }

  /// Update the API configuration using the OpenBar public cnnfig (`<baseUri>/config.json`).
  ///
  /// Throws an error if [baseUrl] is null.
  Future<OpenBarConfig> updateApiConfig() {
    if (baseUrl == null) {
      throw Exception("baseUrl must not be null");
    }

    return _httpClient
        .get(
      "$baseUrl/config.json",
    )
        .then((resp) {
      if (resp.statusCode == 200) {
        _config = OpenBarConfig(
            resp.data["api"], resp.data["apiws"], resp.data["local_token"]);
        _httpClient.options.headers
            .addAll({"X-Local-Token": _config!.local_token});
        log("config set to: $_config, local_token: ${_config!.local_token}");
        return _config!;
      } else {
        log("error: unable to retrieve open bar config");
        throw Exception("Cannot retrieve the OpenBar server configuration.");
      }
    });
  }

  /// Is ready to accept requests
  bool isReady() {
    return _config != null;
  }

  /// Attemps to connect to someone account by card.
  ///
  /// If the login attempt is successful, the credentials are saved by the controller,
  /// and used for futures requests.
  Future<Account> connectByCard(String card_id, String card_pin) {
    if (_config == null) {
      throw Exception("Configuration has not been loaded!");
    }

    var req = _httpClient.post(_config!.getApiUrlFor("auth/card"),
        data: jsonEncode({
          "card_id": card_id.toLowerCase(),
          "card_pin": card_pin,
        }));
    return req.then((resp) {
      if (resp.statusCode == 200) {
        log("Authentification succeed: ${resp.data}");
        return Account.fromJson(resp.data["account"]);
      } else {
        log("Authentification failed, status ${resp.statusCode}, body: ${resp.data}");
        throw Exception("Authentification failed");
      }
    });
  }

  Future<List<Category>> getCategories() {
    if (!isReady()) {
      throw Exception("ApiController is not ready yet!");
    }

    return _httpClient.get(_config!.getApiUrlFor("categories")).then((resp) {
      if (resp.statusCode == 200) {
        List<dynamic> cats = resp.data;
        return cats.map((e) => Category.fromJson(e)).toList(growable: false);
      } else {
        throw Exception(
            "Request failed with status ${resp.statusCode}; ${resp.data}");
      }
    });
  }
}

class OpenBarConfig {
  final String api_endpoint;
  final String websocket_endpoint;
  final String local_token;

  const OpenBarConfig(
      this.api_endpoint, this.websocket_endpoint, this.local_token);

  String getApiUrlFor(String path) {
    return "$api_endpoint/$path";
  }
}
