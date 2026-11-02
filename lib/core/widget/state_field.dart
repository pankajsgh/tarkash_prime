
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../network/api_path.dart';
import '../network/api_repository.dart';
import '../theme/colors.dart';
import '../ulitls/utility.dart';

class StateField extends StatefulWidget {
  final double? width;
  final double? height;
  final StateController controller;
  final StateData? initialState;
  final String hint;
  final ValueChanged<StateData?>? onSelected;
  final FocusNode? focusNode;

  const StateField({
    super.key,
    required this.controller,
    this.focusNode,
    this.width,
    this.height,
    this.hint = 'Search State',
    this.initialState,
    this.onSelected,
  });

  @override
  State<StateField> createState() => StateFieldState();
}

class StateFieldState extends State<StateField> {
  static const double dropdownWidth = 260;
  static const double optionHeight = 51;

  final TextEditingController _textController =
  TextEditingController();

  final FocusNode _internalFocusNode = FocusNode();

  FocusNode get _effectiveFocusNode =>
      widget.focusNode ?? _internalFocusNode;

  final ScrollController _scrollController = ScrollController();
  final ValueNotifier<int> _overlayUpdater = ValueNotifier<int>(0);

  List<StateData> _states = [];

  int _selectedIndex = -1;
  int _requestId = 0;

  bool _isLoading = false;
  bool _hasError = false;
  bool _isOpen = false;
  bool _isUpdatingText = false;
  bool _isDisposed = false;

  void focusAndOpen() {
    if (!mounted || _isDisposed) return;

    _effectiveFocusNode.requestFocus();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _isDisposed) return;
      _openDropdown();
    });
  }

  @override
  void initState() {
    super.initState();

    if (widget.initialState != null &&
        widget.controller.value == null) {
      widget.controller.selectState(widget.initialState);
    }

    _setStateText();
    _effectiveFocusNode.addListener(_onFocusChanged);

    _fetchStates();
  }

  @override
  void didUpdateWidget(covariant StateField oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.focusNode != widget.focusNode) {
      oldWidget.focusNode?.removeListener(_onFocusChanged);
      _effectiveFocusNode.addListener(_onFocusChanged);
    }

    if (oldWidget.controller != widget.controller) {
      _setStateText();
    }

    if (oldWidget.initialState != widget.initialState &&
        widget.controller.value == null) {
      widget.controller.selectState(widget.initialState);
      _setStateText();
    }
  }

// ============================================================
// FETCH STATES - NO PAGINATION
// ============================================================

  Future<void> _fetchStates() async {
    if (_isDisposed) return;

    final request = ++_requestId;

    if (mounted) {
      setState(() {
        _isLoading = true;
        _hasError = false;
      });
    }

    _refreshOverlay();

    try {
      final result = await requestStates();

      if (!mounted || _isDisposed || request != _requestId) {
        return;
      }

      setState(() {
        _states = result;
        _isLoading = false;
        _hasError = false;
      });

      final selected = widget.controller.value;

      if (selected != null) {
        for (final state in result) {
          if (state.id == selected.id) {
            if (!identical(selected, state)) {
              widget.controller.selectState(state);
            }
            break;
          }
        }
      }

      _refreshOverlay();
    } catch (e) {
      if (!mounted || _isDisposed || request != _requestId) {
        return;
      }

      setState(() {
        _isLoading = false;
        _hasError = true;
        _states = [];
      });

      printLog('stateFetchError: $e');
      _refreshOverlay();
    }
  }

  Future<List<StateData>> requestStates() async {
    final Map<String, dynamic> requestBody = {
      'search': '',
      'limit': '0',
    };

    final response = await ApiProvider.createServerRequest(
      apiUrl: ApiPath.getStateList,
      requestBody: requestBody,
      isFormData: true,
    );

    final model = StateModel.fromJson(
      Map<String, dynamic>.from(response),
    );

    if (model.code == 1 && model.error == true) {
      return model.stateList;
    }

    return [];
  }

// ============================================================
// SET SELECTED STATE TEXT
// ============================================================

  void _setStateText() {
    final text = widget.controller.value?.stateName ?? '';

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
// LOCAL TEXT SEARCH - NO API CALL
// ============================================================

  void _onTextChanged(String value) {
    if (_isUpdatingText || _isDisposed) return;

    final query = value.trim().toLowerCase();

    _selectedIndex = -1;
    _isOpen = true;

    if (query.isEmpty) {
      _states = List<StateData>.from(_allStates);
    } else {
      _states = _allStates.where((state) {
        return state.stateName.toLowerCase().contains(query) ||
            state.stateCode.toLowerCase().contains(query) ||
            state.id.contains(query);
      }).toList();
    }

    _refreshOverlay();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_scrollController.hasClients) return;
      _scrollController.jumpTo(0);
    });
  }

  List<StateData> get _allStates => _cachedStates;

// ============================================================
// OPEN DROPDOWN
// ============================================================

  void _openDropdown() {
    _isOpen = true;
    _selectedIndex = -1;

    _onTextChanged(_textController.text);
    _refreshOverlay();
  }

  void _onFocusChanged() {
    if (_isDisposed) return;

    if (_effectiveFocusNode.hasFocus) {
      _isOpen = true;
      _onTextChanged(_textController.text);
    } else {
      _isOpen = false;
      _selectedIndex = -1;
    }

    _refreshOverlay();
  }

// ============================================================
// CLEAR STATE
// ============================================================

  void _clearText() {
    widget.controller.clear();
    widget.onSelected?.call(null);

    _isUpdatingText = true;
    _textController.clear();
    _isUpdatingText = false;

    _selectedIndex = -1;
    _isOpen = true;

    _states = List<StateData>.from(_allStates);

    _refreshOverlay();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _isDisposed) return;

      _effectiveFocusNode.requestFocus();

      if (_scrollController.hasClients) {
        _scrollController.jumpTo(0);
      }
    });
  }

// ============================================================
// SELECT STATE
// ============================================================

  void _selectState(StateData state) {
    _isUpdatingText = true;

    _textController.value = TextEditingValue(
      text: state.stateName,
      selection: TextSelection.collapsed(
        offset: state.stateName.length,
      ),
    );

    _isUpdatingText = false;

    widget.controller.selectState(state);
    widget.onSelected?.call(state);

    _selectedIndex = -1;
    _isOpen = false;

    _effectiveFocusNode.unfocus();
    _refreshOverlay();
  }

// ============================================================
// KEYBOARD NAVIGATION
// ============================================================

  KeyEventResult _handleKey(
      FocusNode node,
      KeyEvent event,
      ) {
    if (event is! KeyDownEvent) {
      return KeyEventResult.ignored;
    }

    if (event.logicalKey == LogicalKeyboardKey.escape) {
      _isOpen = false;
      _selectedIndex = -1;
      _effectiveFocusNode.unfocus();
      _refreshOverlay();

      return KeyEventResult.handled;
    }

    if (event.logicalKey == LogicalKeyboardKey.enter) {
      if (_selectedIndex >= 0 &&
          _selectedIndex < _states.length) {
        _selectState(_states[_selectedIndex]);
      }

      return KeyEventResult.handled;
    }

    if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
      if (_states.isEmpty) {
        return KeyEventResult.handled;
      }

      _isOpen = true;

      _selectedIndex = _selectedIndex >= _states.length - 1
          ? 0
          : _selectedIndex + 1;

      _refreshOverlay();
      _scrollToSelected();

      return KeyEventResult.handled;
    }

    if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
      if (_states.isEmpty) {
        return KeyEventResult.handled;
      }

      _isOpen = true;

      _selectedIndex = _selectedIndex <= 0
          ? _states.length - 1
          : _selectedIndex - 1;

      _refreshOverlay();
      _scrollToSelected();

      return KeyEventResult.handled;
    }

    return KeyEventResult.ignored;
  }

  void _scrollToSelected() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_scrollController.hasClients) return;

      if (_selectedIndex < 0 ||
          _selectedIndex >= _states.length) {
        return;
      }

      final position = _scrollController.position;
      final itemTop = _selectedIndex * optionHeight;
      final itemBottom = itemTop + optionHeight;

      double target = position.pixels;

      if (itemTop < position.pixels) {
        target = itemTop;
      } else if (itemBottom >
          position.pixels + position.viewportDimension) {
        target = itemBottom - position.viewportDimension;
      }

      target = target.clamp(0.0, position.maxScrollExtent);

      if ((target - position.pixels).abs() < 0.5) return;

      _scrollController.animateTo(
        target,
        duration: const Duration(milliseconds: 80),
        curve: Curves.easeOut,
      );
    });
  }

  void _refreshOverlay() {
    if (!_isDisposed) {
      _overlayUpdater.value++;
    }
  }

// ============================================================
// INPUT DECORATION
// ============================================================

  InputDecoration _decoration() {
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: borderColor),
    );

    return InputDecoration(
      hintText: '${widget.hint}...',
      hintStyle: const TextStyle(
        fontSize: 11,
        color: textLight,
      ),
      prefixIcon: const Icon(
        Icons.location_on_outlined,
        size: 17,
        color: textLight,
      ),
      suffixIcon: _textController.text.isNotEmpty
          ? IconButton(
        onPressed: _clearText,
        icon: const Icon(
          Icons.close_rounded,
          size: 17,
          color: textLight,
        ),
      )
          : const Icon(
        Icons.keyboard_arrow_down_rounded,
        size: 18,
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

// ============================================================
// DROPDOWN
// ============================================================

  Widget _dropdown() {
    if (_isLoading) {
      return _messageDropdown(
        icon: null,
        message: 'Loading states...',
        showProgress: true,
      );
    }

    if (_hasError) {
      return _messageDropdown(
        icon: Icons.refresh_rounded,
        message: 'Unable to load states. Click to retry.',
        onTap: _fetchStates,
      );
    }

    if (_states.isEmpty) {
      return _messageDropdown(
        icon: Icons.search_off_rounded,
        message: 'No state found',
      );
    }

    return Material(
      elevation: 8,
      color: Colors.white,
      borderRadius: BorderRadius.circular(8),
      clipBehavior: Clip.antiAlias,
      child: SizedBox(
        width: dropdownWidth,
        height: _states.length > 7
            ? 360
            : _states.length * optionHeight,
        child: ListView.separated(
          controller: _scrollController,
          padding: EdgeInsets.zero,
          physics: const ClampingScrollPhysics(),
          itemCount: _states.length,
          separatorBuilder: (_, __) => const Divider(
            height: 1,
            color: Color(0xffE2E8F0),
          ),
          itemBuilder: (context, index) {
            return _stateItem(_states[index], index);
          },
        ),
      ),
    );
  }

  Widget _messageDropdown({
    required IconData? icon,
    required String message,
    bool showProgress = false,
    VoidCallback? onTap,
  }) {
    return Material(
      elevation: 8,
      color: Colors.white,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
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
                    color: Color(0xff64748B),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

// ============================================================
// STATE OPTION
// ============================================================

  Widget _stateItem(StateData state, int index) {
    return ValueListenableBuilder<int>(
      valueListenable: _overlayUpdater,
      builder: (context, _, __) {
        final selected = _selectedIndex == index;

        return SizedBox(
          height: optionHeight,
          child: MouseRegion(
            cursor: SystemMouseCursors.click,
            onEnter: (_) {
              if (_selectedIndex == index) return;

              _selectedIndex = index;
              _refreshOverlay();
            },
            child: InkWell(
              onTap: () => _selectState(state),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                color: selected
                    ? const Color(0xffEEF2FF)
                    : Colors.transparent,
                child: Row(
                  children: [
                    _avatar(state),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _stateDetails(state),
                    ),
                    const SizedBox(width: 8),
                    if (selected)
                      const Icon(
                        Icons.keyboard_return_rounded,
                        size: 13,
                        color: Color(0xff3B82F6),
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _stateDetails(StateData state) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          state.stateName,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: textDark,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          '${state.stateCode} • ID: ${state.id}',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 10,
            color: Color(0xff64748B),
          ),
        ),
      ],
    );
  }

  Widget _avatar(StateData state) {
    final letter = state.stateCode.trim().isNotEmpty
        ? state.stateCode.trim().substring(0, 1).toUpperCase()
        : '?';

    return Container(
      width: 32,
      height: 32,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: const Color(0xffEAF2FF),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        letter,
        style: const TextStyle(
          color: blue,
          fontSize: 13,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
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
            color: textMedium,
          ),
        ),
        const SizedBox(height: 6),
        ValueListenableBuilder<StateData?>(
          valueListenable: widget.controller,
          builder: (context, selectedState, _) {
            return SizedBox(
              width: widget.width ?? dropdownWidth,
              height: widget.height ?? 36,
              child: RawAutocomplete<StateData>(
                textEditingController: _textController,
                focusNode: _effectiveFocusNode,
                displayStringForOption: (state) => state.stateName,
                optionsBuilder: (TextEditingValue value) {
                  return _states;
                },
                onSelected: _selectState,
                fieldViewBuilder: (
                    context,
                    textController,
                    fieldFocusNode,
                    onFieldSubmitted,
                    ) {
                  return Focus(
                    onKeyEvent: _handleKey,
                    child: TextField(
                      controller: textController,
                      focusNode: fieldFocusNode,
                      onTap: _openDropdown,
                      onChanged: _onTextChanged,
                      style: const TextStyle(
                        fontSize: 12,
                        color: textDark,
                      ),
                      decoration: _decoration(),
                    ),
                  );
                },
                optionsViewBuilder: (context, onSelected, options) {
                  return ValueListenableBuilder<int>(
                    valueListenable: _overlayUpdater,
                    builder: (context, _, __) {
                      if (!_isOpen ||
                          !_effectiveFocusNode.hasFocus) {
                        return const SizedBox.shrink();
                      }

                      return Align(
                        alignment: Alignment.topLeft,
                        child: _dropdown(),
                      );
                    },
                  );
                },
              ),
            );
          },
        ),
      ],
    );
  }

// ============================================================
// DISPOSE
// ============================================================

  @override
  void dispose() {
    _isDisposed = true;
    _requestId++;

    _effectiveFocusNode.removeListener(_onFocusChanged);

    _internalFocusNode.dispose();
    _textController.dispose();
    _scrollController.dispose();
    _overlayUpdater.dispose();

    super.dispose();
  }

// Keep the complete API result separate from filtered results.
  List<StateData> _cachedStates = [];
}

class StateController extends ValueNotifier<StateData?> {
  StateController({StateData? initialState}) : super(initialState);

  StateData? get selectedState => value;

  void selectState(StateData? state) {
    value = state;
  }

  void clear() {
    value = null;
  }
}

class StateModel {
  final int code;
  final bool error;
  final String nums;
  final String totalData;
  final String msg;
  final List<StateData> stateList;

  StateModel({
    required this.code,
    required this.error,
    required this.nums,
    required this.totalData,
    required this.msg,
    required this.stateList,
  });

  factory StateModel.fromJson(Map<String, dynamic> json) {
    return StateModel(
      code: int.tryParse('${json['code'] ?? 0}') ?? 0,
      error: json['error'] == true,
      nums: json['nums']?.toString() ?? '0',
      totalData: json['TotalData']?.toString() ?? '0',
      msg: json['msg']?.toString() ?? '',
      stateList: (json['StateListList'] as List?)
          ?.map(
            (e) => StateData.fromJson(
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
      'nums': nums,
      'TotalData': totalData,
      'msg': msg,
      'StateListList': stateList.map((e) => e.toJson()).toList(),
    };
  }
}

class StateData {
  final String id;
  final String stateName;
  final String stateCode;

  StateData({
    required this.id,
    required this.stateName,
    required this.stateCode,
  });

  factory StateData.fromJson(Map<String, dynamic> json) {
    return StateData(
      id: json['id']?.toString() ?? '',
      stateName: json['state_name']?.toString() ?? '',
      stateCode: json['state_code']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'state_name': stateName,
      'state_code': stateCode,
    };
  }
}
