
import 'package:flutter/material.dart';
import '../network/api_path.dart';
import '../network/api_repository.dart';


class CountryField extends StatefulWidget {
  final double? width;
  final double? height;
  final CountryController controller;
  final Country? initialCountry;
  final String hint;
  final ValueChanged<Country?>? onSelected;
  final FocusNode? focusNode;

  const CountryField({
    super.key,
    required this.controller,
    this.width,
    this.height,
    this.initialCountry,
    this.hint = 'Search Country',
    this.onSelected,
    this.focusNode,
  });

  @override
  State<CountryField> createState() => _CountryFieldState();
}

class _CountryFieldState extends State<CountryField> {
  static const double dropdownWidth = 260;
  static const double optionHeight = 51;

  static const Color _textDark = Color(0xff1E293B);
  static const Color _textLight = Color(0xff94A3B8);
  static const Color _textMedium = Color(0xff64748B);
  static const Color _borderColor = Color(0xffCBD5E1);
  static const Color _blue = Color(0xff3B82F6);
  static const Color _selectedColor = Color(0xffEEF2FF);
  static const Color _avatarColor = Color(0xffEAF2FF);
  static const Color _dividerColor = Color(0xffE2E8F0);

  final TextEditingController _textController =
  TextEditingController();

  final FocusNode _internalFocusNode = FocusNode();

  FocusNode get _effectiveFocusNode =>
      widget.focusNode ?? _internalFocusNode;

  final LayerLink _layerLink = LayerLink();

  List<Country> _countries = [];
  List<Country> _filteredCountries = [];

  bool _isLoading = false;
  bool _isOpen = false;
  bool _isUpdatingText = false;

  Country? _selectedCountry;
  OverlayEntry? _overlayEntry;

  @override
  void initState() {
    super.initState();

    if (widget.initialCountry != null &&
        widget.controller.value == null) {
      widget.controller.selectCountry(widget.initialCountry);
    }

    _selectedCountry = widget.controller.value;
    _setCountryText();

    widget.controller.addListener(_onControllerChanged);
    _effectiveFocusNode.addListener(_onFocusChanged);

    _fetchCountries();
  }

  @override
  void didUpdateWidget(covariant CountryField oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_onControllerChanged);
      widget.controller.addListener(_onControllerChanged);

      _selectedCountry = widget.controller.value;
      _setCountryText();
    }

    if (oldWidget.focusNode != widget.focusNode) {
      oldWidget.focusNode?.removeListener(_onFocusChanged);
      _effectiveFocusNode.addListener(_onFocusChanged);
    }

    if (oldWidget.initialCountry != widget.initialCountry &&
        widget.controller.value == null) {
      widget.controller.selectCountry(widget.initialCountry);
    }
  }

  // ============================================================
  // FETCH COUNTRIES - NO PAGINATION
  // ============================================================

  Future<void> _fetchCountries() async {
    if (!mounted) return;

    setState(() => _isLoading = true);
    _overlayEntry?.markNeedsBuild();

    try {
      final response = await ApiProvider.createServerRequest(
        apiUrl: ApiPath.getCountryList,
        // requestBody: {},
        // isFormData: true,
      );

      print("this is good");
      print(response);

      final model = CountryListModel.fromJson(
        Map<String, dynamic>.from(response),
      );

      if (!mounted) return;

      setState(() {
        _countries = model.countryList
            .where((country) => country.status == '1')
            .toList()
          ..sort(
                (a, b) => a.countryName.compareTo(b.countryName),
          );

        _filteredCountries = List.from(_countries);
        _isLoading = false;
      });

      final selected = widget.controller.value;

      if (selected != null) {
        for (final country in _countries) {
          if (country.id == selected.id) {
            widget.controller.selectCountry(country);
            break;
          }
        }
      }

      _overlayEntry?.markNeedsBuild();
    } catch (e) {
      if (!mounted) return;

      setState(() => _isLoading = false);
      debugPrint('Country fetch error: $e');

      _overlayEntry?.markNeedsBuild();
    }
  }

  // ============================================================
  // CONTROLLER & TEXT
  // ============================================================

  void _onControllerChanged() {
    if (!mounted) return;

    _selectedCountry = widget.controller.value;
    _setCountryText();

    if (_isOpen) {
      _filterCountries(_textController.text);
    }
  }

  void _setCountryText() {
    final text = widget.controller.value?.countryName ?? '';

    if (_textController.text == text) return;

    _isUpdatingText = true;

    _textController.value = TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(
        offset: text.length,
      ),
    );

    _isUpdatingText = false;
  }

  // ============================================================
  // FOCUS
  // ============================================================

  void _onFocusChanged() {
    if (!_effectiveFocusNode.hasFocus) {
      Future.delayed(const Duration(milliseconds: 150), () {
        if (!mounted) return;

        if (!_effectiveFocusNode.hasFocus) {
          _closeDropdown();
          _setCountryText();
        }
      });
    }
  }

  // ============================================================
  // LOCAL SEARCH - NO API CALL
  // ============================================================

  void _filterCountries(String query) {
    final search = query.trim().toLowerCase();

    _filteredCountries = _countries.where((country) {
      return country.countryName.toLowerCase().contains(search) ||
          country.countryCode.toLowerCase().contains(search) ||
          country.phoneCode.toLowerCase().contains(search);
    }).toList();

    _overlayEntry?.markNeedsBuild();
  }

  void _onTextChanged(String value) {
    if (_isUpdatingText) return;

    if (_selectedCountry != null) {
      _selectedCountry = null;
      widget.controller.clear();
      widget.onSelected?.call(null);
    }

    _filterCountries(value);

    if (!_isOpen) {
      _openDropdown();
    }
  }

  // ============================================================
  // OPEN DROPDOWN
  // ============================================================

  void _openDropdown() {
    if (!mounted || _isOpen) return;

    _isOpen = true;
    _overlayEntry = _createOverlayEntry();

    Overlay.of(context).insert(_overlayEntry!);
    _overlayEntry?.markNeedsBuild();
  }

  OverlayEntry _createOverlayEntry() {
    final renderBox = context.findRenderObject() as RenderBox;
    final fieldSize = renderBox.size;

    return OverlayEntry(
      builder: (context) {
        return Positioned(
          width: fieldSize.width,
          child: CompositedTransformFollower(
            link: _layerLink,
            showWhenUnlinked: false,
            offset: Offset(0, fieldSize.height + 4),
            child: Material(
              elevation: 8,
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              clipBehavior: Clip.antiAlias,
              child: _buildOptions(),
            ),
          ),
        );
      },
    );
  }

  // ============================================================
  // DROPDOWN CONTENT
  // ============================================================

  Widget _buildOptions() {
    if (_isLoading) {
      return _messageDropdown(
        icon: null,
        message: 'Loading countries...',
        showProgress: true,
      );
    }

    if (_filteredCountries.isEmpty) {
      return _messageDropdown(
        icon: Icons.search_off_rounded,
        message: 'No countries found',
      );
    }

    return SizedBox(
      height: _filteredCountries.length > 7
          ? 360
          : _filteredCountries.length * optionHeight,
      child: ListView.separated(
        padding: EdgeInsets.zero,
        physics: const ClampingScrollPhysics(),
        itemCount: _filteredCountries.length,
        separatorBuilder: (_, __) => const Divider(
          height: 1,
          thickness: 1,
          color: _dividerColor,
        ),
        itemBuilder: (context, index) {
          return _countryItem(_filteredCountries[index]);
        },
      ),
    );
  }

  Widget _messageDropdown({
    required IconData? icon,
    required String message,
    bool showProgress = false,
  }) {
    return SizedBox(
      width: dropdownWidth,
      height: 90,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (showProgress)
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: _blue,
                ),
              )
            else if (icon != null)
              Icon(
                icon,
                size: 25,
                color: const Color(0xffCBD5E1),
              ),
            const SizedBox(height: 6),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 11,
                color: _textMedium,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // COUNTRY OPTION
  // ============================================================

  Widget _countryItem(Country country) {
    final isSelected = _selectedCountry?.id == country.id;

    return SizedBox(
      height: optionHeight,
      child: InkWell(
        onTap: () => _selectCountry(country),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 8,
            vertical: 4,
          ),
          color: isSelected ? _selectedColor : Colors.transparent,
          child: Row(
            children: [
              _countryAvatar(country),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      country.countryName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: _textDark,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${country.countryCode} • ${country.phoneCode}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 10,
                        color: _textMedium,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              if (isSelected)
                const Icon(
                  Icons.check_rounded,
                  size: 16,
                  color: _blue,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _countryAvatar(Country country) {
    final code = country.countryCode.trim();
    final letter = code.isNotEmpty
        ? code.substring(0, 1).toUpperCase()
        : '?';

    return Container(
      width: 32,
      height: 32,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: _avatarColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        letter,
        style: const TextStyle(
          color: _blue,
          fontSize: 13,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  // ============================================================
  // INPUT DECORATION - MATCHES STATE FIELD
  // ============================================================

  InputDecoration _decoration() {
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: _borderColor),
    );

    return InputDecoration(
      hintText: widget.hint,
      hintStyle: const TextStyle(
        fontSize: 11,
        color: _textLight,
      ),
      prefixIcon: const Icon(
        Icons.public,
        size: 17,
        color: _textLight,
      ),
      prefixIconConstraints: const BoxConstraints(
        minWidth: 38,
        minHeight: 36,
      ),
      suffixIcon: _isLoading
          ? const Padding(
        padding: EdgeInsets.all(10),
        child: SizedBox(
          width: 16,
          height: 16,
          child: CircularProgressIndicator(
            strokeWidth: 2,
          ),
        ),
      )
          : _selectedCountry != null ||
          _textController.text.isNotEmpty
          ? IconButton(
        onPressed: _clearCountry,
        padding: EdgeInsets.zero,
        icon: const Icon(
          Icons.close_rounded,
          size: 17,
          color: _textLight,
        ),
      )
          : const Icon(
        Icons.keyboard_arrow_down_rounded,
        size: 18,
        color: _textLight,
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
          color: _blue,
          width: 1.3,
        ),
      ),
    );
  }

  // ============================================================
  // SELECT COUNTRY
  // ============================================================

  void _selectCountry(Country country) {
    _selectedCountry = country;

    widget.controller.selectCountry(country);
    widget.onSelected?.call(country);

    _setCountryText();
    _closeDropdown();

    _effectiveFocusNode.unfocus();

    if (mounted) setState(() {});
  }

  // ============================================================
  // CLEAR COUNTRY
  // ============================================================

  void _clearCountry() {
    _selectedCountry = null;

    widget.controller.clear();
    widget.onSelected?.call(null);

    _textController.clear();
    _filteredCountries = List.from(_countries);

    if (mounted) setState(() {});

    if (_isOpen) {
      _overlayEntry?.markNeedsBuild();
    }
  }

  // ============================================================
  // CLOSE DROPDOWN
  // ============================================================

  void _closeDropdown() {
    _isOpen = false;
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  // ============================================================
  // FOCUS AND OPEN
  // ============================================================

  void focusAndOpen() {
    if (!mounted) return;

    _effectiveFocusNode.requestFocus();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && !_isOpen) {
        _filterCountries(_textController.text);
        _openDropdown();
      }
    });
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          widget.hint,
          style: const TextStyle(
            fontSize: 9.5,
            fontWeight: FontWeight.w600,
            color: _textMedium,
          ),
        ),
        const SizedBox(height: 6),
        SizedBox(
          width: widget.width ?? dropdownWidth,
          height: widget.height ?? 36,
          child: CompositedTransformTarget(
            link: _layerLink,
            child: TextField(
              controller: _textController,
              focusNode: _effectiveFocusNode,
              onTap: () {
                _filterCountries(_textController.text);
                _openDropdown();
              },
              onChanged: _onTextChanged,
              style: const TextStyle(
                fontSize: 12,
                color: _textDark,
              ),
              decoration: _decoration(),
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    widget.controller.removeListener(_onControllerChanged);
    _effectiveFocusNode.removeListener(_onFocusChanged);

    _closeDropdown();

    _textController.dispose();
    _internalFocusNode.dispose();

    super.dispose();
  }
}


class CountryController extends ValueNotifier<Country?> {
  CountryController({Country? initialCountry}) : super(initialCountry);

  Country? get selectedCountry => value;

  void selectCountry(Country? country) {
    value = country;
  }

  void clear() {
    value = null;
  }
}

class CountryListModel {
  final int code;
  final bool error;
  final String message;
  final List<Country> countryList;

  CountryListModel({
    required this.code,
    required this.error,
    required this.message,
    required this.countryList,
  });

  factory CountryListModel.fromJson(Map<String, dynamic> json) {
    return CountryListModel(
      code: int.tryParse('${json['code'] ?? 0}') ?? 0,
      error: json['error'] == true,
      message: json['message']?.toString() ?? '',
      countryList: (json['data'] as List?)
          ?.map(
            (e) => Country.fromJson(
          Map<String, dynamic>.from(e),
        ),
      )
          .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'error': error,
      'message': message,
      'data': countryList.map((e) => e.toJson()).toList(),
    };
  }
}

class Country {
  final String id;
  final String countryName;
  final String countryCode;
  final String phoneCode;
  final String status;

  Country({
    required this.id,
    required this.countryName,
    required this.countryCode,
    required this.phoneCode,
    required this.status,
  });

  factory Country.fromJson(Map<String, dynamic> json) {
    return Country(
      id: json['id']?.toString() ?? '',
      countryName: json['country_name']?.toString() ?? '',
      countryCode: json['country_code']?.toString() ?? '',
      phoneCode: json['phone_code']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'country_name': countryName,
      'country_code': countryCode,
      'phone_code': phoneCode,
      'status': status,
    };
  }
}
