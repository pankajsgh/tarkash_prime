
import 'package:calculation_panel/core/widget/widget_updater.dart';
import 'package:calculation_panel/features/supplier_voucher/view/supplier_header/widget/auto_open_series_field.dart' hide Series, SeriesController;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/ulitls/utility.dart';
import '../../../../core/widget/series_field.dart';
import '../../../components/custome_dropdown_widget.dart';
import '../../../dashboard/model/store_model.dart';
import '../../../purchase_challan/model/party_model.dart';
import '../../../purchase_challan/model/transport_model.dart';
import '../../../purchase_challan/representaion/supplier_header/controller/supplier_controller.dart';
import '../../../purchase_challan/representaion/supplier_header/supplier_dropdown.dart';

class CustomSupplierHeader extends StatefulWidget {
  final bool isEditMode;
  final Party? selectedSupplier;
  final StoreModel? selectedStore;
  final TransportModel? selectedTransport;
  final Series? selectedSeries;
  final String gstNo;
  final String challanNo;
  final String selectedDate;
  final String referenceNo;

  final ValueChanged<Party?> onSupplierChanged;
  final ValueChanged<StoreModel?> onStoreChanged;
  final ValueChanged<TransportModel?> onTransportChanged;
  final ValueChanged<Series?> onSeriesChanged;
  final ValueChanged<String> onDateChanged;
  final ValueChanged<String> onChallanNoChanged;
  final ValueChanged<String> onGstChanged;


  const CustomSupplierHeader({
    super.key,
    this.isEditMode = false,
    required this.selectedSupplier,
    required this.selectedStore,
    required this.selectedTransport,
    required this.selectedSeries,
    required this.gstNo,
    required this.challanNo,
    required this.selectedDate,
    required this.referenceNo,
    required this.onSupplierChanged,
    required this.onStoreChanged,
    required this.onTransportChanged,
    required this.onSeriesChanged,
    required this.onDateChanged,
    required this.onChallanNoChanged,
    required this.onGstChanged,
  });

  @override
  State<CustomSupplierHeader> createState() =>
      _CustomSupplierHeaderState();
}

class _CustomSupplierHeaderState extends State<CustomSupplierHeader> {
  static const double fieldWidth = 230;
  static const double dateFieldWidth = 160;
  static const double fieldHeight = 36;

  late final SupplierController supplierController;
  late final SeriesController seriesController;

  final TextEditingController challanController =
  TextEditingController();
  final TextEditingController gstController =
  TextEditingController();
  final TextEditingController dateController =
  TextEditingController();
  final TextEditingController referenceController =
  TextEditingController();
  WidgetUpdater updater = WidgetUpdater();


  final FocusNode supplierFocusNode = FocusNode();
  final FocusNode seriesFocusNode = FocusNode();
  final FocusNode gstFocusNode = FocusNode();
  final FocusNode storeFocusNode = FocusNode();
  final FocusNode challanFocusNode = FocusNode();
  final FocusNode dateFocusNode = FocusNode();
  final FocusNode transportFocusNode = FocusNode();

  final GlobalKey<AutoOpenSeriesFieldState> seriesFieldKey =
  GlobalKey<AutoOpenSeriesFieldState>();

  @override
  void initState() {
    super.initState();

    supplierController = SupplierController();
    seriesController = SeriesController();

    challanController.text = widget.challanNo;
    gstController.text = widget.gstNo;
    dateController.text = widget.selectedDate;
    referenceController.text = widget.referenceNo;

    supplierController.getPartyTypeList('');

    if (widget.selectedSeries != null) {
      seriesController.selectSeries(widget.selectedSeries);
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || widget.isEditMode) return;

      supplierFocusNode.requestFocus();
    });
  }

  @override
  void didUpdateWidget(covariant CustomSupplierHeader oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (challanController.text != widget.challanNo) {
      challanController.text = widget.challanNo;
    }

    if (gstController.text != widget.gstNo) {
      gstController.text = widget.gstNo;
    }

    if (dateController.text != widget.selectedDate) {
      dateController.text = widget.selectedDate;
    }

    if (referenceController.text != widget.referenceNo) {
      referenceController.text = widget.referenceNo;
    }

    if (widget.selectedSeries != null &&
        oldWidget.selectedSeries != widget.selectedSeries) {
      seriesController.selectSeries(widget.selectedSeries);
    }
  }

  InputDecoration _inputDecoration(
      String hint, {
        IconData? prefix,
      }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(
        fontSize: 12,
        color: Colors.grey,
      ),
      prefixIcon: prefix == null
          ? null
          : Icon(
        prefix,
        size: 16,
        color: Colors.grey.shade600,
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 8,
      ),
      isDense: true,
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(8)),
        borderSide: BorderSide(color: Colors.blue),
      ),
      disabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
    );
  }

  void _moveFocus(FocusNode node) {
    if (!mounted || !node.canRequestFocus) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !node.canRequestFocus) return;

      FocusScope.of(context).requestFocus(node);
    });
  }

  void _clearFocus() {
    if (!mounted) return;

    FocusScope.of(context).unfocus();
  }

  Widget _textField({
    required String hint,
    required TextEditingController controller,
    required ValueChanged<String> onChanged,
    required FocusNode focusNode,
    FocusNode? nextFocusNode,
    IconData? prefix,
    bool enabled = true,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return SizedBox(
      width: fieldWidth,
      height: fieldHeight,
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        enabled: enabled,
        keyboardType: keyboardType,
        textInputAction: nextFocusNode == null
            ? TextInputAction.done
            : TextInputAction.next,
        style: const TextStyle(
          fontSize: 12,
          color: textDark,
        ),
        decoration: _inputDecoration(
          hint,
          prefix: prefix,
        ),
        onChanged: onChanged,
        onSubmitted: (_) {
          if (focusNode == gstFocusNode) {
            _moveFocus(storeFocusNode);
          } else if (focusNode == challanFocusNode) {
            // Always go to Date after Challan Number.
            _moveFocus(dateFocusNode);
          } else if (focusNode == dateFocusNode) {
            // Always go to Transport after Date.
            _moveFocus(transportFocusNode);
          } else if (nextFocusNode != null) {
            _moveFocus(nextFocusNode);
          } else {
            _clearFocus();
          }
        },
      ),
    );
  }

  Future<void> _selectDate({bool autoOpen = false}) async {
    final DateTime today = DateUtils.dateOnly(DateTime.now());

    final DateTime initialDate = widget.isEditMode
        ? _parseDate(dateController.text)
        : today;

    final DateTime? result = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: Colors.blue,
            ),
          ),
          child: child!,
        );
      },
    );

    if (!mounted) return;

    if (result == null) {
      if (autoOpen) {
        _moveFocus(dateFocusNode);
      }
      return;
    }

    final String formattedDate = formatDate(result);

    setState(() {
      dateController.text = formattedDate;
    });

    widget.onDateChanged(formattedDate);

    // After selecting a date, move to Transport.
    _moveFocus(transportFocusNode);
  }

  DateTime _parseDate(String value) {
    try {
      final parts = value.split('/');

      if (parts.length == 3) {
        return DateTime(
          int.parse(parts[2]),
          int.parse(parts[1]),
          int.parse(parts[0]),
        );
      }
    } catch (_) {}

    return DateTime.now();
  }

  Widget _fieldBlock({
    required String label,
    required Widget child,
  }) {
    return SizedBox(
      width: fieldWidth,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 5),
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                color: textDark,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          child,
        ],
      ),
    );
  }


  Widget _supplierField() {
    return SizedBox(
      width: fieldWidth,
      height: fieldHeight,
      child: ListenableBuilder(
        listenable: supplierController,
        builder: (context, _) {
          if (widget.isEditMode) {
            return SupplierDisplayDropdown(
              selectedSupplier: widget.selectedSupplier,
            );
          }

          return SupplierDropdown(
            suppliers: supplierController.suppliers,
            selectedSupplier: widget.selectedSupplier,
            onSearch: supplierController.getPartyTypeList,
            focusNode: supplierFocusNode,
            onSelect: (supplier) {
              widget.onSupplierChanged(supplier);

              if (supplier == null) return;

              if (widget.isEditMode) {
                _moveFocus(gstFocusNode);
                return;
              }

              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (!mounted) return;

                seriesFieldKey.currentState?.focusAndOpen();
              });
            },

          );
        },
      ),
    );
  }


  // Widget _supplierField() {
  //
  //
  //   return SizedBox(
  //     width: fieldWidth,
  //     height: fieldHeight,
  //     child: SupplierDropdown(
  //     suppliers: supplierController.suppliers,
  //     selectedSupplier: widget.selectedSupplier,
  //     focusNode: supplierFocusNode,
  //     openOnFocus: true,
  //     onSearch: supplierController.getPartyTypeList,
  //     onSelect: (supplier) {
  //       widget.onSupplierChanged(supplier);
  //
  //       if (supplier == null) return;
  //
  //       if (widget.isEditMode) {
  //         _moveFocus(gstFocusNode);
  //         return;
  //       }
  //
  //       WidgetsBinding.instance.addPostFrameCallback((_) {
  //         if (!mounted) return;
  //
  //         seriesFieldKey.currentState?.focusAndOpen();
  //       });
  //     },
  //   ),
  //   );
  // }

  Widget _seriesField() {
    if (widget.isEditMode) {
      return SizedBox(
        width: fieldWidth,
        height: fieldHeight,
        child: TextField(
          controller: referenceController,
          readOnly: true,
          style: const TextStyle(
            fontSize: 12,
            color: textDark,
          ),
          decoration: _inputDecoration(
            'Reference Number',
            prefix: Icons.numbers,
          ),
        ),
      );
    }

    return SizedBox(
        width: fieldWidth,
        height: fieldHeight,
        child: ListenableBuilder(
            listenable: seriesController,
            builder: (context, child) {
              return AutoOpenSeriesField(
                key: seriesFieldKey,
                seriesId: '3',
                showHeading: false,
                controller:  SeriesController(
                  initialSeries: widget.selectedSeries
                ),
                onSelected: (series) {
                  widget.onSeriesChanged(series);
                  // Series -> GSTIN.
                  _moveFocus(gstFocusNode);
                },
              );
            })
    );
  }

  Widget _storeField() {
    return SizedBox(
      width: fieldWidth,
      height: fieldHeight,
      child: SearchableCustomerDropdown<StoreModel>(
        value: widget.selectedStore,
        focusNode: storeFocusNode,
        openOnFocus: true,
        height: fieldHeight,
        borderColor: Colors.grey.shade300,
        borderRadius: 8,
        items: supplierController.stores,
        onSearch: (_) {},
        displayString: (store) => store.store ?? '',
        onSelect: (store) {
          widget.onStoreChanged(store);

          // Store -> Challan Number.
          _moveFocus(challanFocusNode);
        },
      ),
    );
  }

  Widget _transportField() {

    return SizedBox(
      width: fieldWidth,
      height: fieldHeight,

      child: SearchableCustomerDropdown<TransportModel>(
        value: widget.selectedTransport,
        focusNode: transportFocusNode,
        height: fieldHeight,
        openOnFocus: true,
        borderColor: Colors.grey.shade300,
        borderRadius: 8,
        items: supplierController.transports,
        onSearch: (_) {},
        displayString: (transport) => transport.transport ?? '',
        onSelect: (transport) {
          widget.onTransportChanged(transport);
          _clearFocus();
        },
      ),
    );
  }


  Widget _dateField() {
    return SizedBox(
      width: dateFieldWidth,
      height: fieldHeight,
      child: TextField(
        controller: dateController,
        focusNode: dateFocusNode,
        readOnly: false,
        keyboardType: TextInputType.number,
        textInputAction: TextInputAction.next,
        inputFormatters: [
          DateInputFormatter(),
        ],
        style: const TextStyle(
          fontSize: 12,
          color: textDark,
        ),
        decoration: _inputDecoration(
          'DD/MM/YYYY',
          prefix: Icons.calendar_month_outlined,
        ).copyWith(
          prefixIcon: IconButton(
            icon: const Icon(
              Icons.calendar_month_outlined,
              size: 16,
            ),
            onPressed: () => _selectDate(),
          ),
        ),
        onChanged: (value) {
          widget.onDateChanged(value);
        },
        onSubmitted: (_) {
          _moveFocus(transportFocusNode);
        },
      ),
    );
  }

  Widget _buildFormField(int index) {
    switch (index) {
      case 0:
        return _fieldBlock(
          label: 'Supplier',
          child: _supplierField(),
        );

      case 1:
        return _fieldBlock(
          label: widget.isEditMode ? 'Reference Number' : 'Series',
          child: _seriesField(),
        );

      case 2:
        return _fieldBlock(
          label: 'GSTIN',
          child: _textField(
            hint: 'Enter GSTIN',
            controller: gstController,
            focusNode: gstFocusNode,
            nextFocusNode: storeFocusNode,
            onChanged: widget.onGstChanged,
            prefix: Icons.receipt_long_outlined,
          ),
        );

      case 3:
        return _fieldBlock(
          label: 'Store',
          child: _storeField(),
        );

      case 4:

        return _fieldBlock(
          label: 'Challan Number',
          child: _textField(
            hint: 'Enter Challan Number',
            controller: challanController,
            focusNode: challanFocusNode,
            nextFocusNode: dateFocusNode,
            onChanged: widget.onChallanNoChanged,
            prefix: Icons.numbers,
          ),
        );

      case 5:
        return _fieldBlock(
          label: 'Date',
          child: _dateField(),
        );

      case 6:
        return _fieldBlock(
          label: 'Transport',
          child: _transportField(),
        );

      default:
        return const SizedBox.shrink();
    }
  }

  @override
  void dispose() {
    supplierController.dispose();
    seriesController.dispose();

    challanController.dispose();
    gstController.dispose();
    dateController.dispose();
    referenceController.dispose();

    supplierFocusNode.dispose();
    seriesFocusNode.dispose();
    gstFocusNode.dispose();
    storeFocusNode.dispose();
    challanFocusNode.dispose();
    dateFocusNode.dispose();
    transportFocusNode.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: supplierController,
      builder: (context, child) {
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: Colors.grey.shade200,
            ),
          ),
          child: Wrap(
            spacing: 15,
            runSpacing: 12,
            crossAxisAlignment: WrapCrossAlignment.start,
            children: List.generate(
              7,
              _buildFormField,
            ),
          ),
        );
      },
    );
  }
}


class DateInputFormatter extends TextInputFormatter {
  static final DateTime minDate =
  DateTime(DateTime.now().year, 4, 1);

  static final DateTime maxDate =
  DateTime(DateTime.now().year + 1, 3, 31);

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue,
      TextEditingValue newValue,
      ) {
    final digits = newValue.text.replaceAll(RegExp(r'\D'), '');

    if (digits.length > 8) {
      return oldValue;
    }

    // Automatically add slashes: DD/MM/YYYY
    final buffer = StringBuffer();

    for (int i = 0; i < digits.length; i++) {
      buffer.write(digits[i]);

      if (i == 1 && digits.length > 2) {
        buffer.write('/');
      } else if (i == 3 && digits.length > 4) {
        buffer.write('/');
      }
    }

    String text = buffer.toString();

    // Validate day
    if (digits.length >= 2) {
      int day = int.parse(digits.substring(0, 2));

      if (day < 1) day = 1;
      if (day > 31) day = 31;

      text = text.replaceRange(
        0,
        2,
        day.toString().padLeft(2, '0'),
      );
    }

    // Validate month
    if (digits.length >= 4) {
      int month = int.parse(digits.substring(2, 4));

      if (month < 1) month = 1;
      if (month > 12) month = 12;

      text = text.replaceRange(
        3,
        5,
        month.toString().padLeft(2, '0'),
      );
    }

    // Validate complete date against the allowed financial year.
    if (digits.length == 8) {
      int day = int.parse(text.substring(0, 2));
      int month = int.parse(text.substring(3, 5));
      int year = int.parse(digits.substring(4, 8));

      final maxDay = DateUtils.getDaysInMonth(year, month);

      if (day > maxDay) {
        day = maxDay;
      }

      final date = DateTime(year, month, day);

      if (date.isBefore(minDate)) {
        text = '01/04/2026';
      } else if (date.isAfter(maxDate)) {
        text = '31/03/2027';
      } else {
        text =
        '${day.toString().padLeft(2, '0')}/'
            '${month.toString().padLeft(2, '0')}/'
            '${year.toString().padLeft(4, '0')}';
      }
    }

    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(
        offset: text.length,
      ),
    );
  }
}