import 'package:wb_warehouse/data_management/common/data_provider.dart';
import 'package:wb_warehouse/data_management/common/network_client.dart';
import 'package:wb_warehouse/features/prices_and_discounts/data_providers/prices_and_discounts_data_provider.dart';
import 'package:wb_warehouse/features/rest_of_goods/data_providers/rest_of_goods_data_provider.dart';
import 'package:wb_warehouse/features/reviews/data_providers/chat_gpt_data_provider.dart';
import 'package:wb_warehouse/features/reviews/data_providers/reviews_data_provider.dart';

class DataManager {
  final NetworkClient _networkClient;
  final Map<DataProviderType, DataProvider> _providers = {};

  DataManager(this._networkClient);

  RestOfGoodsDataProvider get restOfGoodsDataProvider =>
      _getOrCreateProvider(DataProviderType.restOfGoods) as RestOfGoodsDataProvider;

  PricesAndDiscountsDataProvider get pricesAndDiscountsDataProvider =>
      _getOrCreateProvider(DataProviderType.pricesAndDiscounts) as PricesAndDiscountsDataProvider;

  ReviewsDataProvider get reviewsDataProvider => _getOrCreateProvider(DataProviderType.reviews) as ReviewsDataProvider;

  ChatGPTDataProvider get chatGPTDataProvider =>
      _getOrCreateProvider(DataProviderType.chatGPTDataProvider) as ChatGPTDataProvider;

  DataProvider _getOrCreateProvider(DataProviderType type) {
    if (_providers.containsKey(type)) {
      return _providers[type]!;
    }

    switch (type) {
      case DataProviderType.restOfGoods:
        return RestOfGoodsDataProvider(networkClient: _networkClient);
      case DataProviderType.pricesAndDiscounts:
        return PricesAndDiscountsDataProvider(networkClient: _networkClient);
      case DataProviderType.reviews:
        return ReviewsDataProvider(networkClient: _networkClient);
      case DataProviderType.chatGPTDataProvider:
        return ChatGPTDataProvider(networkClient: _networkClient);
      default:
        throw ArgumentError('Cannot create provider of type ${type.toString()}');
    }
  }
}
