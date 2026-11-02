import 'package:calculation_panel/core/theme/colors.dart';
import 'package:calculation_panel/core/ulitls/utility.dart';
import 'package:calculation_panel/core/vars/global_vars.dart';
import 'package:calculation_panel/features/components/custome_dropdown_widget.dart';
import 'package:calculation_panel/features/purchase_challan/representaion/supplier_header/controller/supplier_controller.dart';
import 'package:calculation_panel/features/purchase_challan/representaion/supplier_header/supplier_dropdown.dart';
import 'package:flutter/material.dart';

import '../../../../core/widget/series_field.dart';
import '../../../dashboard/model/store_model.dart';
import '../../model/party_model.dart';
import '../../model/store_model.dart';
import '../../model/transport_model.dart';
import '../../controller/purchase_controller.dart';
import '../../model/supplier_model.dart';

class SupplierHeader extends StatefulWidget {
  final PurchaseController purchaseController;
  final bool isEditMode;

  const SupplierHeader({
    super.key,
    required this.purchaseController,
    required this.isEditMode,
  });

  @override
  State<SupplierHeader> createState() => _SupplierHeaderState();
}

class _SupplierHeaderState extends State<SupplierHeader> {
  late final SupplierController controller;

  static const double fieldWidth = 230;
  static const double dateFieldWidth = 160;
  static const double fieldHeight = 36;

  @override
  void initState() {
    super.initState();

    controller = SupplierController();
    controller.dateController.text = formatDate(DateTime.now());

    widget.purchaseController.setData(controller.dateController.text);
    GlobalVars.currentData = controller.dateController.text;

    Future.delayed(const Duration(milliseconds: 500), () {
      if (!mounted) return;
      controller.getPartyTypeList('');
    });
  }

  void _selectSupplier(Party? supplier) {
    if (widget.purchaseController.selectedAgent == null) {
      widget.purchaseController.setAgent(supplier?.agency);
    }

    widget.purchaseController.setSupplier(supplier);
  }

  InputDecoration _inputDecoration(
      String hint, {
        IconData? prefix,
      }) {
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: borderColor),
    );

    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(
        fontSize: 11,
        color: textLight,
      ),
      prefixIcon: prefix == null
          ? null
          : Icon(
        prefix,
        size: 17,
        color: textLight,
      ),
      filled: true,
      fillColor: const Color(0xffF8FAFC),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 11,
        vertical: 9,
      ),
      isDense: true,
      border: border,
      enabledBorder: border,
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(
          color: Color(0xff3B82F6),
          width: 1.3,
        ),
      ),
    );
  }

  Widget _textField(
      TextEditingController textController, {
        required String hint,
        IconData? prefix,
        bool isEnable = true,
      }) {
    return SizedBox(
      width: fieldWidth,
      height: fieldHeight,
      child: TextField(
        enabled: isEnable,
        controller: textController,
        style: const TextStyle(
          fontSize: 12,
          color: textDark,
        ),
        decoration: _inputDecoration(
          hint,
          prefix: prefix,
        ),
        onChanged: (value) {
          widget.purchaseController.setChallanNo(
            controller.challanController.text,
            value,
          );
        },
      ),
    );
  }

  DateTime? _parseDate(String value) {
    final parts = value.split('/');

    if (parts.length != 3) return null;

    final day = int.tryParse(parts[0]);
    final month = int.tryParse(parts[1]);
    final year = int.tryParse(parts[2]);

    if (day == null || month == null || year == null) {
      return null;
    }

    final date = DateTime(year, month, day);

    if (date.year != year ||
        date.month != month ||
        date.day != day) {
      return null;
    }

    return date;
  }

  Future<void> selectDate(BuildContext context) async {
    final currentDate = _parseDate(controller.dateController.text);

    final result = await showDatePicker(
      context: context,
      initialDate: currentDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xff2563EB),
            ),
          ),
          child: child!,
        );
      },
    );

    if (result == null || !mounted) return;

    final selectedDate = formatDate(result);

    controller.setDate(selectedDate);
    widget.purchaseController.setData(selectedDate);
    GlobalVars.currentData = selectedDate;
  }

  Widget _dateField() {
    return SizedBox(
      width: dateFieldWidth,
      height: fieldHeight,
      child: TextField(
        controller: controller.dateController,
        readOnly: true,
        onTap: () => selectDate(context),
        style: const TextStyle(
          fontSize: 12,
          color: textDark,
        ),
        decoration: _inputDecoration(
          'Select date',
          prefix: Icons.calendar_today_outlined,
        ),
      ),
    );
  }

  Widget _storeField() {
    return SizedBox(
      width: fieldWidth,
      height: fieldHeight,
      child: ListenableBuilder(
        listenable: controller,
        builder: (context, _) {
          return SearchableCustomerDropdown<StoreModel>(
            value: widget.purchaseController.selectedStore,
            height: fieldHeight,
            borderColor: Colors.grey.shade300,
            borderRadius: 8,
            items: controller.stores,
            onSearch: (value) {},
            displayString: (item) => item.store ?? '',
            onSelect: (value) {
              widget.purchaseController.setStore(value);
            },
          );
        },
      ),
    );
  }

  Widget _transportField() {
    return SizedBox(
      width: fieldWidth,
      height: fieldHeight,
      child: ListenableBuilder(
        listenable: controller,
        builder: (context, _) {
          return SearchableCustomerDropdown<TransportModel>(
            value: widget.purchaseController.selectedTransport,
            height: fieldHeight,
            borderColor: Colors.grey.shade300,
            borderRadius: 8,
            items: controller.transports,
            onSearch: (value) {},
            displayString: (item) => item.transport ?? '',
            onSelect: (value) {
              widget.purchaseController.setTransport(value);
            },
          );
        },
      ),
    );
  }


  Widget _supplierField() {
    return SizedBox(
      width: fieldWidth,
      height: fieldHeight,
      child: ListenableBuilder(
        listenable: controller,
        builder: (context, _) {
          if (widget.isEditMode) {
            return SupplierDisplayDropdown(
              selectedSupplier: widget.purchaseController.selectSupplier,
            );
          }

          return SupplierDropdown(
            suppliers: controller.suppliers,
            selectedSupplier: widget.purchaseController.selectSupplier,
            onSearch: (value) {
              controller.getPartyTypeList(value);
            },
            onSelect: _selectSupplier,
          );
        },
      ),
    );
  }

  Widget _fieldBlock(String label, Widget field) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 17,
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: Color(0xff475569),
            ),
          ),
        ),
        const SizedBox(height: 6),
        field,
      ],
    );
  }

  Widget _seriesField() {
    if(widget.isEditMode)
      {
        return SizedBox(
          width: 160,
          child: _fieldBlock(
            'Reference Number',
            _textField(
              TextEditingController(text: widget.purchaseController.referenceNo),
              isEnable: !widget.isEditMode,
              hint: '',
              prefix: Icons.numbers_rounded,
            ),
          )
        );
      }
    return SizedBox(
      width: 160,
      child: SeriesField(
        seriesId: '2',
        controller: SeriesController(
          initialSeries: widget.purchaseController.selectedSeries,
        ),
        onSelected: (Series? series) {
          widget.purchaseController.setSeries(series);
        },
      ),
    );
  }

  Widget _buildFormField(int index) {
    switch (index) {
      case 0:
        return _fieldBlock(
          'Supplier',
          _supplierField(),
        );

      case 1:
        return _seriesField();

      case 2:
        return _fieldBlock(
          'GSTIN Number',
          _textField(
            TextEditingController(
              text: widget.purchaseController.gstNo,
            ),
            hint: 'Enter GSTIN number',
            prefix: Icons.badge_outlined,
          ),
        );

      case 3:
        return _fieldBlock(
          'Store',
          _storeField(),
        );

      case 4:
        return _fieldBlock(
          'Challan Number',
          _textField(
            controller.challanController,
            isEnable: !widget.isEditMode,
            hint: 'Enter challan number',
            prefix: Icons.numbers_rounded,
          ),
        );

      case 5:
        return _fieldBlock(
          'Date',
          _dateField(),
        );

      case 6:
        return _fieldBlock(
          'Transport',
          _transportField(),
        );

      default:
        return const SizedBox.shrink();
    }
  }

  @override
  void didUpdateWidget(covariant SupplierHeader oldWidget) {
    super.didUpdateWidget(oldWidget);

    controller.challanController.text =
        widget.purchaseController.challanNo;
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xffE6EBF2),
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 15,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Wrap(
        spacing: 15,
        runSpacing: 12,
        children: List.generate(
          7,
          _buildFormField,
        ),
      ),
    );
  }
}