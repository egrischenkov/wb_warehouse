import 'dart:async';

import 'package:elementary/elementary.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/subjects.dart';
import 'package:wb_warehouse/common/ui/table_widget/cell/base_cell_widget.dart';
import 'package:wb_warehouse/common/ui/table_widget/cell/check_box_cell_widget.dart';
import 'package:wb_warehouse/common/ui/table_widget/cell/network_image_cell_widget.dart';
import 'package:wb_warehouse/common/ui/table_widget/cell/text_cell_widget.dart';
import 'package:wb_warehouse/common/ui/table_widget/table_widget_data.dart';
import 'package:wb_warehouse/features/rest_of_goods/pages/rest_of_goods_page/l10n/rest_of_goods_l10n.dart';
import 'package:wb_warehouse/features/rest_of_goods/pages/rest_of_goods_page/navigation/rest_of_goods_navigator.dart';
import 'package:wb_warehouse/features/rest_of_goods/pages/rest_of_goods_page/rest_of_goods_model.dart';
import 'package:wb_warehouse/features/rest_of_goods/pages/rest_of_goods_page/rest_of_goods_page.dart';
import 'package:wb_warehouse/features/rest_of_goods/pages/rest_of_goods_page/table_data/rest_of_goods_row_data.dart';
import 'package:wb_warehouse/features/rest_of_goods/pages/update_rest_of_goods_page/models/rest_good_item_data.dart';
import 'package:wb_warehouse/features/rest_of_goods/pages/update_rest_of_goods_page/models/update_rest_of_goods_initial_data.dart';
import 'package:wb_warehouse/utils/extensions/context_extension.dart';
import 'package:wb_warehouse/utils/themes/theme_provider.dart';

class RestOfGoodsWm extends WidgetModel<RestOfGoodsPage, RestOfGoodsModel> {
  final searchTextController = TextEditingController();

  final RestOfGoodsL10n _l10n;
  final RestOfGoodsNavigator _navigator;

  final _loadingController = StreamController<bool>.broadcast();
  final _tableDataController = BehaviorSubject<TableWidgetData>();
  final _filterController = BehaviorSubject<FilterType>.seeded(FilterType.name);
  final _isUpdataButtonActiveController = StreamController<bool>.broadcast();

  var _loadedRows = <RestOfGoodsRowData>[];

  RestOfGoodsWm(
    this._l10n,
    this._navigator,
    super.model,
  );

  Stream<bool> get loadingStream => _loadingController.stream;
  Stream<TableWidgetData> get tableDataStream => _tableDataController.stream;
  Stream<bool> get isUpdataButtonActiveStream => _isUpdataButtonActiveController.stream;

  String get updateDataButtonTitle => _l10n.updateDataButtonTitle;
  String get updateRestOfGoodsButtonTitle => _l10n.updateRestOfGoodsButtonTitle;

  Color get filtersIconColor => context.watch<ThemeProvider>().appTheme.filtersIconColor;

  @override
  void initWidgetModel() {
    super.initWidgetModel();
    _initialLoading();
  }

  @override
  void dispose() {
    _loadingController.close();
    _tableDataController.close();
    _filterController.close();
    _isUpdataButtonActiveController.close();
    searchTextController.dispose();
    super.dispose();
  }

  Future<void> showFiltersDialog() async {
    final selectedFilter = (await _navigator.showFiltersDialog(
          initialType: _filterController.value,
          getFilterTitle: _getFilterTitle,
        )) ??
        _filterController.value;

    _filterController.add(selectedFilter);
    _searchProccess(searchTextController.text);
  }

  void onDataUpdateTap() {
    _initialLoading();
  }

  void onUpdateRestOfGoodsTap() {
    final selectedRows = _loadedRows.where((row) => row.isSelected);
    final initialData = UpdateRestOfGoodsInitialData(itemsData: selectedRows.map((row) {
      return RestGoodItemData(
        url: row.pictureUrl,
        name: row.name,
        barcode: row.barcode,
        amount: row.quantity,
      );
    }));
    _navigator.goToUpdateRestOfGoodsPage(initialData, _onFinishUpdating);
  }

  void onSearchInput(String query) => _searchProccess(query);

  void _searchProccess(String query) {
    final suggestions = _loadedRows.where((row) {
      final filteredRowData = _getFilteredRowData(row).toLowerCase();
      final input = query.toLowerCase();

      return filteredRowData.contains(input);
    });

    _tableDataController.add(_getTableData(suggestions));
  }

  Future<void> _initialLoading() async {
    _loadingController.add(true);

    _loadedRows = await model.getWarehouseGoodsTableData();
    _tableDataController.add(_getTableData(_loadedRows));
    _loadingController.add(false);
  }

  String _getFilteredRowData(RestOfGoodsRowData rowData) {
    switch (_filterController.value) {
      case FilterType.name:
        return rowData.name;
      case FilterType.supplierArticle:
        return rowData.supplierArticle;
      case FilterType.barcode:
        return rowData.barcode;
    }
  }

  TableWidgetData _getTableData(Iterable<RestOfGoodsRowData> data) {
    return TableWidgetData(
      columnNames: [
        _l10n.pictureColumnTitle,
        _l10n.nameColumnTitle,
        _l10n.supplierArticleColumnTitle,
        _l10n.barcodeColumnTitle,
        _l10n.quantityColumnTitle,
        _l10n.updateRestOfGoods,
      ],
      rows: data
          .map((e) => <BaseCellWidget>[
                NetworkImageCellWidget(
                  url: e.pictureUrl,
                  onTap: () => _onPictureTap(e.pictureUrl!),
                ),
                TextCellWidget(title: e.name),
                TextCellWidget(title: e.supplierArticle),
                TextCellWidget(title: e.barcode),
                TextCellWidget(title: e.quantity.toString()),
                CheckBoxCellWidget(initialValue: e.isSelected, onChanged: (value) => _onSelectItem(e, value)),
              ])
          .toList(),
    );
  }

  void _onPictureTap(String url) {
    _navigator.showPictureDialog(url);
  }

  void _onSelectItem(RestOfGoodsRowData rowData, bool? isSelected) {
    _loadedRows.firstWhere((row) => row.barcode == rowData.barcode).isSelected = isSelected ?? false;
    _setUpUpdateButtonAvailability();
  }

  void _setUpUpdateButtonAvailability() {
    final isAvailable = _loadedRows.any((row) => row.isSelected);
    _isUpdataButtonActiveController.add(isAvailable);
  }

  String _getFilterTitle(FilterType type) {
    switch (type) {
      case FilterType.name:
        return context.localizations.restOfGoodsFilterName;
      case FilterType.supplierArticle:
        return context.localizations.restOfGoodsFilterSupplierArticle;
      case FilterType.barcode:
        return context.localizations.restOfGoodsFilterBarcode;
    }
  }

  void _onFinishUpdating() {
    _initialLoading();
    searchTextController.clear();
  }
}

enum FilterType { name, supplierArticle, barcode }
