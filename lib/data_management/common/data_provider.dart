import 'package:flutter/material.dart';
import 'package:wb_warehouse/data_management/common/network_client.dart';

enum DataProviderType {
  restOfGoods,
}

typedef ApiAccessor<T> = Future<T> Function([Map<String, dynamic>? payload]);

abstract class DataProvider {
  final NetworkClient _networkClient;

  DataProvider({required NetworkClient networkClient}) : _networkClient = networkClient;

  @protected
  ApiAccessor<T> getApiAccessor<T>(String path, NetworkClientType type) {
    return ([payload]) async {
      return _networkClient.get<T>(path: path, type: type, payload: payload);
    };
  }

  @protected
  ApiAccessor<T> postApiAccessor<T>(String path, NetworkClientType type) {
    return ([payload]) async {
      return _networkClient.post<T>(path: path, type: type, payload: payload);
    };
  }

  @protected
  ApiAccessor<T> putApiAccessor<T>(String path, NetworkClientType type) {
    return ([payload]) async {
      return _networkClient.put<T>(path: path, type: type, payload: payload);
    };
  }
}
