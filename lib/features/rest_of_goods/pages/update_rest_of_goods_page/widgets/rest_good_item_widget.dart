import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:wb_warehouse/common/ui/common_network_image_widget.dart';
import 'package:wb_warehouse/utils/extensions/context_extension.dart';
import 'package:wb_warehouse/utils/themes/theme_provider.dart';

class RestGoodItemWidget extends StatelessWidget {
  final String? url;
  final String name;
  final String barcode;
  final int amount;
  final VoidCallback onDelete;
  final ValueChanged<String> onAmountChanged;

  const RestGoodItemWidget({
    this.url,
    required this.name,
    required this.barcode,
    required this.amount,
    required this.onDelete,
    required this.onAmountChanged,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final appTheme = context.watch<ThemeProvider>().appTheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: appTheme.restGoodItemWidgetBackgroundColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            blurRadius: 10,
            spreadRadius: 3,
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CommonNetworkImageWidget(url: url),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Text('${context.localizations.updateRestOfGoodsBarcode}: $barcode', overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(
                width: 30,
                child: TextFormField(
                  initialValue: amount.toString(),
                  onChanged: onAmountChanged,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                ),
              ),
              TextButton(
                onPressed: onDelete,
                child: Text(context.localizations.delete),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
