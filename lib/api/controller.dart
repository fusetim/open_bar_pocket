import 'dart:collection';
import 'dart:convert';
import 'dart:developer';
import 'dart:ffi';
import 'dart:typed_data';

import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:native_dio_adapter/native_dio_adapter.dart';
import 'package:open_bar_pocket/api/responses/last_orders_response.dart';
import 'package:open_bar_pocket/models/account.dart';
import 'package:open_bar_pocket/models/category.dart';
import 'package:open_bar_pocket/models/order.dart';
import 'package:open_bar_pocket/models/price_role.dart';
import 'package:open_bar_pocket/models/product.dart';

class ApiController {
  final Dio _httpClient = Dio()..httpClientAdapter = NativeAdapter();
  final DefaultCacheManager _cache = DefaultCacheManager();

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

  Future<Uint8List> getPicture(String uri) async {
    if (!isReady()) {
      throw Exception("ApiController is not ready yet!");
    }

    String url = _config!.getApiUrlFor(uri);
    //FileInfo? fi = await _cache.getFileFromCache(url);
    //if (fi != null) {
    //  return await fi.file.readAsBytes();
    //}

    return await _httpClient
        .get(url, options: Options(responseType: ResponseType.bytes))
        .then((resp) {
      if (resp.statusCode == 200) {
        Uint8List data = Uint8List.fromList(resp.data);
        //_cache.putFile(url, data, key: url, eTag: resp.headers.value("etag"));
        return data;
      } else {
        throw Exception(
            "Request failed with status ${resp.statusCode}; ${resp.data}");
      }
    });
  }

  Future<List<Category>> getCategories() {
    if (!isReady()) {
      throw Exception("ApiController is not ready yet!");
    }

    return _httpClient
        .get(_config!.getApiUrlFor("categories"))
        .then((resp) async {
      if (resp.statusCode == 200) {
        List<dynamic> cats_data = resp.data;
        List<Category> cats = List.empty(growable: true);
        for (var c in cats_data) {
          Uint8List? picture = await getPicture(c["picture_uri"])
              .then((value) => value as Uint8List?)
              .onError((_, __) => null);
          cats.add(
              Category(name: c["name"], id: c["id"], picture_data: picture));
        }
        return cats;
      } else {
        throw Exception(
            "Request failed with status ${resp.statusCode}; ${resp.data}");
      }
    });
  }

  Future<List<Product>> getProducts(String category_id,
      {int page = 0, int limit = 20, String? state = "buyable"}) async {
    if (!isReady()) {
      throw Exception("ApiController is not ready yet!");
    }
    String state_param = state == null ? "" : "&state=$state";
    var resp = await _httpClient.get(_config!.getApiUrlFor(
        "categories/$category_id/items?page=$page&limit=$limit$state_param"));
    if (resp.statusCode != 200) {
      throw Exception(
          "Failed to get products for category `$category_id`, status: ${resp.statusCode}, body: ${resp.data}");
    }
    List<dynamic> items = resp.data["items"];
    List<Product> products = List.empty(growable: true);
    for (Map<String, dynamic> item in items) {
      Map<String, dynamic> rPrices = item["prices"];
      List<int> prices = List.filled(PriceRole.length, 0);
      for (var p in rPrices.entries) {
        PriceRole pr = PriceRole.fromText(p.key);
        prices[pr.index] = p.value;
      }
      Uint8List? pictureData = await getPicture(item["picture_uri"])
          .then((value) => value as Uint8List?)
          .onError((_, __) => null);
      var prod = Product(
          id: item["id"],
          name: item["name"],
          prices: prices,
          amountLeft: item["amount_left"],
          buyLimit: item["buy_limit"],
          pictureData: pictureData);
      products.add(prod);
    }
    return products;
  }

  Future<()> newTransaction(UnmodifiableListView<(Product, int)> items, String pin) {
    if (!isReady()) {
      throw Exception("ApiController is not ready yet!");
    }

    List<Map<String, dynamic>> itemsData = List.empty(growable: true);
    for (var (p, q) in items) {
      itemsData.add({"item_id": p.id, "amount": q});
    }
    var req = _httpClient.post(_config!.getApiUrlFor("account/transactions"),
        data: jsonEncode({"items": itemsData, "card_pin": pin}));
    return req.then((resp) {
      if (resp.statusCode == 201) {
        return ();
      } else {
        throw Exception(
            "Failed to create transaction, status: ${resp.statusCode}, body: ${resp.data}");
      }
    });
  }

  Future<Account> getMyAccount() {
    if (!isReady()) {
      throw Exception("ApiController is not ready yet!");
    }

    return _httpClient.get(_config!.getApiUrlFor("account")).then((resp) {
      if (resp.statusCode == 200) {
        return Account.fromJson(resp.data["account"]);
      } else {
        throw Exception(
            "Failed to get account, status: ${resp.statusCode}, body: ${resp.data}");
      }
    });
  }

  Future<LastOrdersResponse> getLastOrders({int pageNumber = 0, int limit = 14, String state = "all"}) {
    if (!isReady()) {
      throw Exception("ApiController is not ready yet!");
    }

    Map<String, dynamic> params = {
      "page": pageNumber,
      "limit": limit,
    };
    if (state != "all") {
      params["state"] = state;
    }

    return _httpClient.get(_config!.getApiUrlFor("account/transactions"), queryParameters: params).then((resp) {
      if (resp.statusCode == 200) {
        return LastOrdersResponse.fromJson(resp.data);
      } else {
        throw Exception(
            "Failed to get orders, status: ${resp.statusCode}, body: ${resp.data}");
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
    if (path.startsWith("/")) {
      path = path.substring(1);
    }
    return "$api_endpoint/$path";
  }
}
