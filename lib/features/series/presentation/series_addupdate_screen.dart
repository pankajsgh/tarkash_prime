
import 'package:calculation_panel/core/network/api_repository.dart';
import 'package:calculation_panel/core/ulitls/utility.dart';
import 'package:calculation_panel/core/widget/toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/extensions/map_ext.dart';
import '../../../core/network/api_path.dart';
import '../../../core/routes/routes.dart';
import '../../dashboard/data/controller/routes_controller.dart';
import '../models/model_voucher_configuration.dart';

class SeriesAddUpdateScreen extends StatefulWidget {
  final RoutesController routesController;

  const SeriesAddUpdateScreen({
    super.key,
    required this.routesController,
  });

  @override
  State<SeriesAddUpdateScreen> createState() => _SeriesListScreenState();
}

class _SeriesListScreenState extends State<SeriesAddUpdateScreen> {
  static const Color pageBg = Color(0xffF4F6FA);
  static const Color primary = Color(0xff2563EB);
  static const Color borderColor = Color(0xffD9E1EC);
  static const Color textColor = Color(0xff253247);
  static const Color mutedColor = Color(0xff718096);

  final TextEditingController _seriesController =
  TextEditingController(text: '');
  final TextEditingController _prefixController =
  TextEditingController(text: '');

  final TextEditingController _suffixController =
  TextEditingController(text: '');

  final TextEditingController _startingNoController =
  TextEditingController(text: '1');
  final TextEditingController _endingNoController =
  TextEditingController();
  final TextEditingController _warningBeforeController =
  TextEditingController();
  final TextEditingController _warningMessageController =
  TextEditingController();
  final TextEditingController _totalLengthController =
  TextEditingController(text: '4');
  final TextEditingController _paddingController =
  TextEditingController(text: '0');
  final TextEditingController _manualSampleController =
  TextEditingController();

  final ValueNotifier<int> _sampleNotifier = ValueNotifier<int>(0);

  List<VoucherType> voucherList = List.empty(growable: true);
  VoucherType? _voucherType;
  VoucherSeries? _editabaleSeries;

  String _numberingType = 'Automatic';
  String _manualValidation = 'Both';
  String _frequency = 'Yearly';
  String _yearFormat = 'YYYY-YY';
  String _separator = '/';
  String _maintainBookNo = 'N';
  String _fixLength = 'Y';
  String _yearPosition = 'As Suffix';
  String _specifyEndingNo = 'N';

  String get _sampleYear {
    final now = DateTime.now();
    final year = now.year;
    final nextYear = year + 1;

    switch (_yearFormat) {
      case 'YYYY-YY':
        return '$year-${(nextYear % 100).toString().padLeft(2, '0')}';
      case 'YY-YY':
        return '${(year % 100).toString().padLeft(2, '0')}-${(nextYear % 100).toString().padLeft(2, '0')}';
      case 'YYYY':
        return year.toString();
      case 'YY':
        return (year % 100).toString().padLeft(2, '0');
      default:
        return '$year-${(nextYear % 100).toString().padLeft(2, '0')}';
    }
  }


  String get _sampleVoucherNo {
    if (_numberingType == 'Manual') {
      final manual = _manualSampleController.text.trim();
      return manual.isEmpty ? 'Enter voucher number' : manual;
    }

    final prefix = _prefixController.text;
    final suffix = _suffixController.text;
    final startingText = _startingNoController.text.trim();
    final starting = int.tryParse(startingText);

    String numericPart = _getNumericNumber();

    final hasYear = _frequency == 'Yearly' &&
        (_yearPosition == 'As Prefix' || _yearPosition == 'As Suffix');

    final year = hasYear ? _sampleYear : '';

    final voucherParts = <String>[
      if (_yearPosition != 'As Prefix' && prefix.isNotEmpty) prefix,
      if (numericPart.isNotEmpty) numericPart,
      if (_yearPosition != 'As Suffix' && suffix.isNotEmpty) suffix,
    ];

    if (_specifyEndingNo == 'Y' &&
        _endingNoController.text.trim().isNotEmpty) {
      voucherParts.add(_endingNoController.text.trim());
    }

    final voucherNumber = voucherParts.join();

    if (!hasYear) {
      return voucherNumber.isEmpty ? 'Not configured' : voucherNumber;
    }

    if (_yearPosition == 'As Prefix') {
      if (voucherNumber.isEmpty) return year;
      return '$year${_separator == 'None' ? '' : _separator}$voucherNumber';
    }

    if (voucherNumber.isEmpty) return year;

    return '$voucherNumber${_separator == 'None' ? '' : _separator}$year';
  }

  String _getNumericNumber() {
    final startingText = _startingNoController.text.trim();
    final starting = int.tryParse(startingText);

    String numericPart = startingText;

    if (starting != null) {
      if (_fixLength == 'Y') {
        final length =
        (int.tryParse(_totalLengthController.text) ?? 4).clamp(1, 9);

        final padding = _paddingController.text.isEmpty
            ? '0'
            : _paddingController.text.characters.first;

        numericPart = starting.toString().padLeft(length, padding);
      } else {
        numericPart = starting.toString();
      }
    }

    return numericPart;
  }


  void _refreshSample() {
    _sampleNotifier.value++;
  }

  VoucherType? voucherItem;

  @override
  void initState() {
    super.initState();

    final Map<String, dynamic>? voucherParams =
        widget.routesController.params;

    if (voucherParams!=null && voucherParams.isNotEmpty) {
      voucherItem = voucherParams['voucher'];

      _voucherType = voucherItem;
      voucherList.addAll(voucherParams['voucherList']!);
      int editableIndex = voucherParams['editableIndex'];

      if(editableIndex!=-1){
        _seriesController.text = _voucherType!.series[editableIndex].name;
      }
    }

    for (final controller in [
      _seriesController,
      _prefixController,
      _suffixController,
      _startingNoController,
      _endingNoController,
      _totalLengthController,
      _paddingController,
      _manualSampleController,
    ]) {
      controller.addListener(_refreshSample);
    }

    _refreshSample();
  }

  @override
  void dispose() {
    _seriesController.dispose();
    _prefixController.dispose();
    _startingNoController.dispose();
    _endingNoController.dispose();
    _warningBeforeController.dispose();
    _warningMessageController.dispose();
    _totalLengthController.dispose();
    _paddingController.dispose();
    _manualSampleController.dispose();
    _sampleNotifier.dispose();
    super.dispose();
  }

  void _saveConfiguration() {
    if (_seriesController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a series name.')),
      );
      return;
    }

    if (_numberingType == 'Automatic' &&
        _startingNoController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a starting number.')),
      );
      return;
    }

    final starting = int.tryParse(_startingNoController.text.trim());
    final ending = int.tryParse(_endingNoController.text.trim());

    if (_specifyEndingNo == 'Y' &&
        _endingNoController.text.trim().isNotEmpty &&
        starting != null &&
        ending != null &&
        ending < starting) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ending number must be greater than starting number.'),
        ),
      );
      return;
    }

    requestAddVoucher();
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(
        fontSize: 12,
        color: Color(0xFF94A3B8),
      ),
      filled: true,
      fillColor: const Color(0xFFFBFCFE),
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 12,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(7),
        borderSide: const BorderSide(
          color: Color(0xFFDCE4EF),
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(7),
        borderSide: const BorderSide(
          color: Color(0xFFDCE4EF),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(7),
        borderSide: const BorderSide(
          color: Color(0xFF3B82F6),
          width: 1.5,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(7),
        borderSide: const BorderSide(color: Colors.red),
      ),
    );
  }

  Widget _textField(
      TextEditingController controller, {
        String hint = '',
        double width = 230,
        bool numeric = false,
        bool enabled = true,
      }) {
    return SizedBox(
      width: width,
      height: 40,
      child: TextField(
        controller: controller,
        enabled: enabled,
        keyboardType:
        numeric ? TextInputType.number : TextInputType.text,
        inputFormatters: numeric
            ? [FilteringTextInputFormatter.digitsOnly]
            : null,
        style: const TextStyle(
          fontSize: 12,
          color: Color(0xFF253247),
          fontWeight: FontWeight.w500,
        ),
        decoration: _inputDecoration(hint),
      ),
    );
  }

  Widget _dropdown<T>({
    required T? value,
    required List<T> options,
    required String Function(T item) getLabel,
    required ValueChanged<T?> onChanged,
    String hint = 'Select an option',
    double width = 230,
    bool enabled = true,
  }) {
    // Dropdown values must be unique.
    final selectedValue = options.where((item) => item == value).firstOrNull;

    return SizedBox(
      width: width,
      height: 40,
      child: DropdownButtonFormField<T>(
        initialValue: selectedValue,
        isExpanded: true,
        isDense: true,
        autofocus: false,
        focusColor: const Color(0xFFEAF2FF),
        dropdownColor: Colors.white,
        borderRadius: BorderRadius.circular(9),
        menuMaxHeight: 320,
        icon: Icon(
          enabled
              ? Icons.keyboard_arrow_down_rounded
              : Icons.lock_outline_rounded,
          size: 20,
          color: const Color(0xFF64748B),
        ),
        style: const TextStyle(
          fontSize: 12,
          color: Color(0xFF253247),
          fontWeight: FontWeight.w500,
        ),
        decoration: _inputDecoration(hint),
        selectedItemBuilder: (context) {
          return options.map((item) {
            return Align(
              alignment: Alignment.centerLeft,
              child: Text(
                getLabel(item),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF253247),
                ),
              ),
            );
          }).toList();
        },
        items: options.map((item) {
          final isSelected = item == selectedValue;

          return DropdownMenuItem<T>(
            value: item,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 9,
              ),
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFFEAF2FF)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(5),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      getLabel(item),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.w400,
                        color: isSelected
                            ? const Color(0xFF2563EB)
                            : const Color(0xFF334155),
                      ),
                    ),
                  ),
                  if (isSelected)
                    const Icon(
                      Icons.check_rounded,
                      size: 16,
                      color: Color(0xFF2563EB),
                    ),
                ],
              ),
            ),
          );
        }).toList(),
        onChanged: enabled
            ? (selected) {
          if (selected == null) return;

          onChanged(selected);
          _refreshSample();

          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;
            FocusScope.of(context).nextFocus();
          });
        }
            : null,
      ),
    );
  }

  Widget _formRow(
      String label,
      Widget field, {
        String? help,
      }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 245,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: textColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          field,
          if (help != null) ...[
            const SizedBox(width: 12),
            Flexible(
              child: Text(
                help,
                style: const TextStyle(fontSize: 11, color: mutedColor),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _section({
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: borderColor),
        borderRadius: BorderRadius.circular(7),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 3,
                height: 16,
                decoration: BoxDecoration(
                  color: primary,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 9),
          ...children,
        ],
      ),
    );
  }

  Widget _buildVoucherConfiguration() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(9),
        border: Border.all(color: borderColor),
      ),
      child: FocusTraversalGroup(
        policy: ReadingOrderTraversalPolicy(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Voucher Numbering heading
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 16,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(9),
                border: Border.all(color: borderColor),
              ),
              child: Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEAF1FF),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.format_list_numbered_rounded,
                      color: primary,
                      size: 23,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Voucher Numbering',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: textColor,
                          ),
                        ),
                        SizedBox(height: 3),
                        Text(
                          'Configure voucher series and numbering rules',
                          style: TextStyle(fontSize: 11, color: mutedColor),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 11,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEAF8EF),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: const Text(
                      'CONFIGURATION',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF16834A),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
        
            _section(
              title: 'Voucher Series',
              children: [
                _formRow(
                  'Voucher Type',
                  _dropdown<VoucherType>(
                    value: _voucherType,
                    options: voucherList,
                    getLabel: (item) => item.name,
                    onChanged: (item) {
                      setState(() {
                        _voucherType = item;
                      });
                    },
                    hint: 'Select voucher type',
                    enabled: voucherItem == null,
                  ),
                ),
                _formRow(
                  'Series',
                  _textField(_seriesController, hint: 'Enter series name'),
                ),
                _formRow(
                  'Numbering Type',
                    _dropdown<String>(
                      value: _numberingType,
                      options: ['Automatic', 'Manual'],
                      getLabel: (item) => item,
                      onChanged: (item) {
                        if (item == null) return;

                        setState(() {
                          _numberingType = item;
                        });
                      },
                      enabled: false,
                      hint: 'Select numbering type',
                    ),
                ),
                if (_numberingType == 'Manual') ...[
                  _formRow(
                    'Manual Numbering Validation',
                    _dropdown<String>(
                      value: _manualValidation,
                      options: ['Both', 'Duplicate Voucher Number', 'Blank Voucher Number', 'None'],
                      getLabel: (item) => item, onChanged: (value) {
                        if(value!=null){
                          setState(() => _manualValidation = value);
                        }

                      },
                    ),
                  ),
                  _formRow(
                    'Sample Manual Voucher No.',
                    _textField(
                      _manualSampleController,
                      hint: 'Enter sample voucher number',
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 14),
        
            _section(
              title: 'Auto Numbering Info',
              children: [
                _formRow(
                  'Renumbering Frequency',
                  _dropdown<String>(
                    value: _frequency,
                    options: ['Yearly', 'Monthly'],
                    getLabel: (item) => item,
                    onChanged: (item) {
                      if (item == null) return;
                      setState(() {
                        _frequency = item;
                      });

                    }
                  ),
                ),
                if (_frequency == 'Yearly') ...[
                  _formRow(
                    'Year Format',
                    _dropdown<String>(
                      value: _yearFormat,
                      options: ['YYYY-YY', 'YY-YY', 'YYYY', 'YY'],
                      getLabel: (item) => item,
                      onChanged: (item) {
                        if (item == null) return;
                        setState(() {
                          _yearFormat = item;
                        });
                      },
                    ),
                  ),
                  _formRow(
                    'Embed Year in Vch. No.',
                    _dropdown<String>(
                      value: _yearPosition,
                      options: ['As Suffix', 'As Prefix', 'None'],
                      getLabel: (item) => item,
                      onChanged: (item) {
                        if (item == null) return;
                        setState(() {
                          _yearPosition = item;
                        });
                      },)
                  ),
                ],
                _formRow(
                  'Year & Vch. No. Separator',
                  _dropdown<String>(
                    value: _separator,
                    options: ['/', '-', 'None'],
                    getLabel: (item) => item,
                    enabled: _yearPosition != 'None',
                    onChanged: (item) {
                      if (item == null) return;
                      setState(() {
                        _separator = item;
                      });
                    },
                  ),
                ),
                if (_yearPosition != 'As Prefix' || _yearPosition == 'None')
                  _formRow(
                    'Prefix',
                    _textField(
                      _prefixController,
                      hint: 'Optional prefix',
                    ),
                  ),
                if (_yearPosition == 'As Prefix' || _yearPosition == 'None')
                  _formRow(
                    'Suffix',
                    _textField(
                      _suffixController,
                      hint: 'Optional suffix',
                    ),
                  ),
                _formRow(
                  'Starting No.',
                  _textField(
                    _startingNoController,
                    hint: 'Enter starting number',
                    numeric: true,
                  ),
                ),
                _formRow(
                  'Specify Ending No.',
                  _dropdown<String>(
                    value: _specifyEndingNo,
                    options: ['Y', 'N'],
                    getLabel: (item) => item,
                    onChanged: (item) {
                      if (item == null) return;
                      setState(() {
                        _specifyEndingNo = item;
                      });
                    },
                  ),
                ),
                if (_specifyEndingNo == 'Y') ...[
                  const SizedBox(height: 10),
                  _section(
                    title: 'Ending Details',
                    children: [
                      _formRow(
                        'Ending No.',
                        _textField(
                          _endingNoController,
                          hint: 'Enter ending number',
                          numeric: true,
                        ),
                      ),
                      _formRow(
                        'Warning before No. of Vouchers left',
                        _textField(
                          _warningBeforeController,
                          hint: 'Optional',
                          numeric: true,
                        ),
                      ),
                      _formRow(
                        'Warning Message',
                        _textField(
                          _warningMessageController,
                          hint: 'Enter warning message',
                          width: 350,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),

            const SizedBox(height: 14),
        
            _section(
              title: 'Additional Settings',
              children: [
                _formRow(
                  'Maintain Book No.',
                  _dropdown<String>(
                    value: _maintainBookNo,
                    options: ['Y', 'N'],
                    getLabel: (item) => item,
                    onChanged: (item) {
                      if (item == null) return;
                      setState(() {
                        _maintainBookNo = item;
                      });
                    },)
                ),
                if (_fixLength == 'Y') ...[
                  const SizedBox(height: 8),
                  _section(
                    title: 'Padding Details',
                    children: [
                      _formRow(
                        'Total Length of Numeric Part',
                        _dropdown<String>(
                          value: _totalLengthController.text.isNotEmpty?_totalLengthController.text:'4',
                          options: ['1', '2', '3', '4', '5', '6', '7', '8', '9'],
                          getLabel: (item) => item,
                          onChanged: (v) {
                            if (v == null) return;

                            setState(() {
                              _totalLengthController.text = v;
                            });
                          },
                          width: 100,
                        ),
                        help: '(Maximum 9)',
                      ),
                    ],
                  ),
                ],
              ],
            ),
            const SizedBox(height: 14),
        
            ValueListenableBuilder<int>(
              valueListenable: _sampleNotifier,
              builder: (context, _, __) {
                return Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFFEFF5FF),
                        Color(0xFFF8FAFF),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFCFDFFF)),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.visibility_outlined,
                        color: primary,
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Sample Voucher No.',
                              style: TextStyle(
                                fontSize: 11,
                                color: mutedColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Preview based on current settings',
                              style: TextStyle(fontSize: 10, color: mutedColor),
                            ),
                          ],
                        ),
                      ),
                      Flexible(
                        child: SelectableText(
                          _sampleVoucherNo,
                          textAlign: TextAlign.end,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFFB42335),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: pageBg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildVoucherConfiguration(),
              const SizedBox(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(
                    onPressed: () => Navigator.of(context).maybePop(),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(110, 40),
                      foregroundColor: textColor,
                      side: const BorderSide(color: borderColor),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    child: const Text('Quit'),
                  ),
                  const SizedBox(width: 10),
                  FilledButton.icon(
                    onPressed: _saveConfiguration,
                    style: FilledButton.styleFrom(
                      backgroundColor: primary,
                      minimumSize: const Size(130, 40),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    icon: const Icon(Icons.check_rounded, size: 17),
                    label: const Text('OK'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void requestAddVoucher() async{
    Map<String, dynamic> requestBody = {};
    requestBody['voucher_id'] = _voucherType!.id;
    requestBody['name'] = _seriesController.text.trim();
    requestBody['invoice_formate'] = _sampleVoucherNo;
    requestBody['serial_no'] = _getNumericNumber();

    var response = await ApiProvider.createServerRequest(apiUrl: ApiPath.urlVoucherConfigurationAdd, requestBody: requestBody, isFormData: true);
    if(response['error']){
      Toast.show(message: response['msg'], type: .success);
      widget.routesController.setRoute(Routes.seriesListScreen);
    }
    else{
      Toast.show(message: response['msg'], type: .error);
    }
  }
}