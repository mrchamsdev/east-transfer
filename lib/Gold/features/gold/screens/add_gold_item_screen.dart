import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/responsive_extensions.dart';
import '../../../core/utils/screen_utility.dart';
import '../../../widgets/gold_back_button.dart';
import '../models/gold_purchase_model.dart';

class AddGoldItemScreen extends StatefulWidget {
  final List<GoldBilledItem>? initialItems;

  const AddGoldItemScreen({super.key, this.initialItems});

  @override
  State<AddGoldItemScreen> createState() => _AddGoldItemScreenState();
}

class GoldItemInputSet {
  final grossWeightController = TextEditingController();
  final side1Controller = TextEditingController();
  final side2Controller = TextEditingController();
  final averageController = TextEditingController();
  final pureWeightController = TextEditingController();

  GoldItemInputSet() {
    grossWeightController.addListener(_calculatePureWeight);
    side1Controller.addListener(_calculateAverage);
    side2Controller.addListener(_calculateAverage);
    averageController.addListener(_calculatePureWeight);
  }

  void _calculateAverage() {
    final s1 = double.tryParse(side1Controller.text) ?? 0.0;
    final s2 = double.tryParse(side2Controller.text) ?? 0.0;
    if (side1Controller.text.isNotEmpty && side2Controller.text.isNotEmpty) {
      final avg = (s1 + s2) / 2;
      averageController.text = avg.toStringAsFixed(2);
    }
  }

  void _calculatePureWeight() {
    final gw = double.tryParse(grossWeightController.text) ?? 0.0;
    final avg = double.tryParse(averageController.text) ?? 0.0;
    if (gw > 0 && avg > 0) {
      final pw = (gw * avg) / 100;
      pureWeightController.text = pw.toStringAsFixed(2);
    } else {
      pureWeightController.text = '';
    }
  }

  void dispose() {
    grossWeightController.dispose();
    side1Controller.dispose();
    side2Controller.dispose();
    averageController.dispose();
    pureWeightController.dispose();
  }
}

class _AddGoldItemScreenState extends State<AddGoldItemScreen> {
  final List<GoldItemInputSet> _itemSets = [];

  @override
  void initState() {
    super.initState();
    if (widget.initialItems != null && widget.initialItems!.isNotEmpty) {
      for (final item in widget.initialItems!) {
        final set = GoldItemInputSet();
        set.grossWeightController.text =
            item.grossWeight > 0 ? item.grossWeight.toString() : '';
        set.side1Controller.text = item.side1 > 0 ? item.side1.toString() : '';
        set.side2Controller.text = item.side2 > 0 ? item.side2.toString() : '';
        set.averageController.text = item.averagePercentage > 0
            ? item.averagePercentage.toString()
            : '';
        set.pureWeightController.text =
            item.pureWeight > 0 ? item.pureWeight.toString() : '';
        _itemSets.add(set);
      }
    } else {
      _itemSets.add(GoldItemInputSet());
    }
  }

  @override
  void dispose() {
    for (final itemSet in _itemSets) {
      itemSet.dispose();
    }
    super.dispose();
  }

  void _onAddMore() => setState(() => _itemSets.add(GoldItemInputSet()));

  void _removeItem(int index) {
    if (_itemSets.length > 1) {
      setState(() {
        _itemSets[index].dispose();
        _itemSets.removeAt(index);
      });
    }
  }

  void _onSave() {
    final List<GoldBilledItem> items = [];
    for (final itemSet in _itemSets) {
      final gw = double.tryParse(itemSet.grossWeightController.text) ?? 0.0;
      final s1 = double.tryParse(itemSet.side1Controller.text) ?? 0.0;
      final s2 = double.tryParse(itemSet.side2Controller.text) ?? 0.0;
      final avg = double.tryParse(itemSet.averageController.text) ?? 0.0;
      final pw = double.tryParse(itemSet.pureWeightController.text) ?? 0.0;

      if (gw <= 0.0 || pw <= 0.0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text(
                  'Please enter valid Gross Weight and Average % for all items.')),
        );
        return;
      }

      items.add(GoldBilledItem(
        grossWeight: gw,
        side1: s1,
        side2: s2,
        averagePercentage: avg,
        pureWeight: pw,
      ));
    }

    Navigator.pop(context, items);
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtility().init(context);
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      behavior: HitTestBehavior.opaque,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: Text(
            'Add Item Details',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          centerTitle: true,
          leading: GoldBackButton(
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(5.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ...List.generate(_itemSets.length, (index) {
                      return Padding(
                        padding: EdgeInsets.only(bottom: 3.h),
                        child: _buildItemDetailsCard(index),
                      );
                    }),
                    TextButton(
                      onPressed: _onAddMore,
                      child: Text(
                        '+ Add More Items',
                        style: TextStyle(
                          color: AppColors.primaryBlue,
                          fontWeight: FontWeight.bold,
                          fontSize: 10.sp,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (MediaQuery.of(context).viewInsets.bottom == 0)
              _buildBottomButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildItemDetailsCard(int index) {
    final itemSet = _itemSets[index];
    final isMultiple = _itemSets.length > 1;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              isMultiple
                  ? 'Item ${(index + 1).toString().padLeft(2, '0')} Details'
                  : 'Item Details',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12.sp,
                color: AppColors.textPrimary,
              ),
            ),
            if (isMultiple)
              GestureDetector(
                onTap: () => _removeItem(index),
                child: Icon(
                  Icons.delete_outline,
                  color: AppColors.textSecondary,
                  size: 20.sp,
                ),
              ),
          ],
        ),
        SizedBox(height: 1.5.h),
        Container(
          width: double.infinity,
          padding: EdgeInsets.fromLTRB(4.w, 1.h, 4.w, 2.h),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(4.r),
            border: Border.all(color: const Color(0xFFF1F5F9), width: 1.5),
          ),
          child: Column(
            children: [
              _buildItemRow(label: 'Gross Weight', child: _numField(itemSet.grossWeightController)),
              SizedBox(height: 1.5.h),
              _buildItemRow(label: 'Side 1', child: _numField(itemSet.side1Controller)),
              SizedBox(height: 1.5.h),
              _buildItemRow(label: 'Side 2', child: _numField(itemSet.side2Controller)),
              SizedBox(height: 1.5.h),
              _buildItemRow(label: 'Average (%)', child: _numField(itemSet.averageController)),
              SizedBox(height: 1.5.h),
              _buildItemRow(
                label: 'Pure Weight',
                child: _numField(itemSet.pureWeightController, readOnly: true, bold: true),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _numField(
    TextEditingController ctrl, {
    bool readOnly = false,
    bool bold = false,
  }) {
    return TextFormField(
      controller: ctrl,
      readOnly: readOnly,
      keyboardType: readOnly
          ? null
          : const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: readOnly
          ? null
          : [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))],
      style: TextStyle(
        fontSize: 14.sp,
        fontWeight: bold ? FontWeight.bold : FontWeight.w600,
        color: AppColors.textPrimary,
      ),
      decoration: InputDecoration(
        hintText: '0.00',
        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14.sp),
        enabledBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: Color(0xFFF1F5F9))),
        focusedBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: AppColors.primaryBlue, width: 1.5)),
        filled: false,
        fillColor: Colors.transparent,
        contentPadding: EdgeInsets.symmetric(vertical: 1.h),
      ),
    );
  }

  Widget _buildItemRow({required String label, required Widget child}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: 28.w,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 10.sp,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        SizedBox(width: 4.w),
        Expanded(child: child),
      ],
    );
  }

  Widget _buildBottomButtons() {
    return Container(
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.divider)),
      ),
      child: Row(
        children: [
          Expanded(
            child: SizedBox(
              height: 7.h,
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                style: TextButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.zero),
                ),
                child: Text('Back',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 15.sp)),
              ),
            ),
          ),
          Container(width: 1, height: 5.h, color: Colors.white.withOpacity(0.3)),
          Expanded(
            child: SizedBox(
              height: 7.h,
              child: TextButton(
                onPressed: _onSave,
                style: TextButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.zero),
                ),
                child: Text('Save',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 15.sp)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
