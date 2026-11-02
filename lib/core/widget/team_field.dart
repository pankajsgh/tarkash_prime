
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../network/api_path.dart';
import '../network/api_repository.dart';
import '../ulitls/utility.dart';

class TeamField extends StatefulWidget {
  final double? width;
  final double? height;
  final TeamController controller;
  final Team? initialTeam;
  final String hint;
  final ValueChanged<Team?>? onSelected;
  final FocusNode? focusNode;

  const TeamField({
    super.key,
    required this.controller,
    this.focusNode,
    this.width,
    this.height,
    this.hint = 'Search Team',
    this.initialTeam,
    this.onSelected,
  });

  @override
  State<TeamField> createState() => TeamFieldState();
}

class TeamFieldState extends State<TeamField> {
  static const double dropdownWidth = 260;
  static const double optionHeight = 55;

  static const Color blue = Color(0xff3B82F6);
  static const Color textDark = Color(0xff1E293B);
  static const Color textLight = Color(0xff94A3B8);
  static const Color borderColor = Color(0xffE2E8F0);

  final TextEditingController _textController =
  TextEditingController();

  final FocusNode _internalFocusNode = FocusNode();

  FocusNode get _effectiveFocusNode =>
      widget.focusNode ?? _internalFocusNode;

  final ScrollController _scrollController = ScrollController();
  final ValueNotifier<int> _overlayUpdater = ValueNotifier<int>(0);

  List<Team> _teams = [];

  Timer? _searchDebounce;

  int _selectedIndex = -1;
  int _requestId = 0;

  bool _isUpdatingText = false;
  bool _isLoading = false;
  bool _hasError = false;
  bool _isOpen = false;
  bool _isDisposed = false;

  String _lastQuery = '';

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

    if (widget.initialTeam != null &&
        widget.controller.value == null) {
      widget.controller.selectTeam(widget.initialTeam);
    }

    _setTeamText();
    _effectiveFocusNode.addListener(_onFocusChanged);
    _fetchTeams('');
  }

  @override
  void didUpdateWidget(covariant TeamField oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.focusNode != widget.focusNode) {
      oldWidget.focusNode?.removeListener(_onFocusChanged);
      _effectiveFocusNode.addListener(_onFocusChanged);
    }

    if (oldWidget.controller != widget.controller) {
      _setTeamText();
    }

    if (oldWidget.initialTeam != widget.initialTeam &&
        widget.controller.value == null) {
      widget.controller.selectTeam(widget.initialTeam);
      _setTeamText();
    }
  }

  // ============================================================
  // FETCH TEAMS
  // ============================================================

  Future<void> _fetchTeams(String query) async {
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
      final result = await requestTeams(query);

      if (!mounted || _isDisposed || request != _requestId) {
        return;
      }

      setState(() {
        _teams = result;
        _isLoading = false;
        _hasError = false;
      });

      final selected = widget.controller.value;

      if (selected != null) {
        for (final team in result) {
          if (team.id == selected.id) {
            if (!identical(selected, team)) {
              widget.controller.selectTeam(team);
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
        _teams = [];
      });

      printLog('teamFetchError: $e');

      _refreshOverlay();
    }
  }

  Future<List<Team>> requestTeams(String query) async {
    final response = await ApiProvider.createServerRequest(
      apiUrl: ApiPath.urlTeamList,
      requestBody: {
        'search': query,
        'limit': '0',
      },
      isFormData: true,
    );

    final model = TeamResponse.fromJson(
      Map<String, dynamic>.from(response),
    );

    if (model.code == 1 && model.error) {
      return model.teamList;
    }

    return [];
  }

  void _setTeamText() {
    final text = widget.controller.value?.name ?? '';

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
  // TEXT SEARCH
  // ============================================================

  void _onTextChanged(String value) {
    if (_isUpdatingText || _isDisposed) return;

    _selectedIndex = -1;
    _isOpen = true;

    final query = value.trim();

    _searchDebounce?.cancel();

    if (query == _lastQuery && !_isLoading) {
      _refreshOverlay();
      return;
    }

    _searchDebounce = Timer(
      const Duration(milliseconds: 300),
          () {
        if (!mounted || _isDisposed) return;

        _lastQuery = query;
        _fetchTeams(query);
      },
    );

    _refreshOverlay();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_scrollController.hasClients) return;
      _scrollController.jumpTo(0);
    });
  }

  void _openDropdown() {
    if (_isDisposed) return;

    _isOpen = true;
    _selectedIndex = -1;

    final query = _textController.text.trim();

    if (query != _lastQuery || _hasError || _teams.isEmpty) {
      _lastQuery = query;
      _fetchTeams(query);
    }

    _refreshOverlay();
  }

  void _onFocusChanged() {
    if (_isDisposed) return;

    if (_effectiveFocusNode.hasFocus) {
      _isOpen = true;

      final query = _textController.text.trim();

      if (query != _lastQuery || _hasError || _teams.isEmpty) {
        _lastQuery = query;
        _fetchTeams(query);
      }
    } else {
      _isOpen = false;
      _selectedIndex = -1;
    }

    _refreshOverlay();
  }

  // ============================================================
  // CLEAR TEAM
  // ============================================================

  void _clearText() {
    _searchDebounce?.cancel();

    widget.controller.clear();
    widget.onSelected?.call(null);

    _isUpdatingText = true;
    _textController.clear();
    _isUpdatingText = false;

    _selectedIndex = -1;
    _lastQuery = '';
    _isOpen = true;

    _fetchTeams('');

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _isDisposed) return;

      _effectiveFocusNode.requestFocus();

      if (_scrollController.hasClients) {
        _scrollController.jumpTo(0);
      }
    });
  }

  // ============================================================
  // SELECT TEAM
  // ============================================================

  void _selectTeam(Team team) {
    _searchDebounce?.cancel();

    _isUpdatingText = true;

    _textController.value = TextEditingValue(
      text: team.name,
      selection: TextSelection.collapsed(
        offset: team.name.length,
      ),
    );

    _isUpdatingText = false;

    widget.controller.selectTeam(team);
    widget.onSelected?.call(team);

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

    if (event.logicalKey == LogicalKeyboardKey.enter ||
        event.logicalKey == LogicalKeyboardKey.numpadEnter) {
      if (_selectedIndex >= 0 &&
          _selectedIndex < _teams.length) {
        _selectTeam(_teams[_selectedIndex]);
      }

      return KeyEventResult.handled;
    }

    if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
      if (_teams.isEmpty) return KeyEventResult.handled;

      _isOpen = true;

      _selectedIndex = _selectedIndex >= _teams.length - 1
          ? 0
          : _selectedIndex + 1;

      _refreshOverlay();
      _scrollToSelected();

      return KeyEventResult.handled;
    }

    if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
      if (_teams.isEmpty) return KeyEventResult.handled;

      _isOpen = true;

      _selectedIndex = _selectedIndex <= 0
          ? _teams.length - 1
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
          _selectedIndex >= _teams.length) {
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
        Icons.groups_outlined,
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
          color: blue,
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
        message: 'Searching team members...',
        showProgress: true,
      );
    }

    if (_hasError) {
      return _messageDropdown(
        icon: Icons.refresh_rounded,
        message: 'Unable to load team. Click to retry.',
        onTap: () => _fetchTeams(_textController.text.trim()),
      );
    }

    if (_teams.isEmpty) {
      return _messageDropdown(
        icon: Icons.search_off_rounded,
        message: 'No team member found',
      );
    }

    return Material(
      elevation: 8,
      color: Colors.white,
      borderRadius: BorderRadius.circular(8),
      clipBehavior: Clip.antiAlias,
      child: SizedBox(
        width: dropdownWidth,
        height: _teams.length > 6
            ? 330
            : _teams.length * optionHeight,
        child: ListView.separated(
          controller: _scrollController,
          padding: EdgeInsets.zero,
          physics: const ClampingScrollPhysics(),
          itemCount: _teams.length,
          separatorBuilder: (_, __) => const Divider(
            height: 1,
            color: Color(0xffE2E8F0),
          ),
          itemBuilder: (context, index) {
            return _teamItem(_teams[index], index);
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
  // TEAM OPTION
  // ============================================================

  Widget _teamItem(Team team, int index) {
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
              onTap: () => _selectTeam(team),
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
                    _avatar(team),
                    const SizedBox(width: 10),
                    Expanded(child: _teamDetails(team)),
                    const SizedBox(width: 8),
                    if (selected)
                      const Icon(
                        Icons.keyboard_return_rounded,
                        size: 13,
                        color: blue,
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

  Widget _teamDetails(Team team) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          team.name,
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
          '${team.role} • ${team.mobile}',
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

  Widget _avatar(Team team) {
    final name = team.name.trim();
    final letter = name.isNotEmpty ? name[0].toUpperCase() : '?';

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
            color: textDark,
          ),
        ),
        const SizedBox(height: 6),
        ValueListenableBuilder<Team?>(
          valueListenable: widget.controller,
          builder: (context, selectedTeam, _) {
            return SizedBox(
              width: widget.width ?? dropdownWidth,
              height: widget.height ?? 36,
              child: RawAutocomplete<Team>(
                textEditingController: _textController,
                focusNode: _effectiveFocusNode,
                displayStringForOption: (team) => team.name,
                optionsBuilder: (TextEditingValue value) => _teams,
                onSelected: _selectTeam,
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
                      if (!_isOpen || !_effectiveFocusNode.hasFocus) {
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

    _searchDebounce?.cancel();
    _effectiveFocusNode.removeListener(_onFocusChanged);

    _internalFocusNode.dispose();
    _textController.dispose();
    _scrollController.dispose();
    _overlayUpdater.dispose();

    super.dispose();
  }
}



class TeamController extends ValueNotifier<Team?> {
  TeamController({Team? initialTeam}) : super(initialTeam);

  Team? get selectedTeam => value;

  void selectTeam(Team? team) {
    value = team;
  }

  void clear() {
    value = null;
  }
}

class TeamResponse {
  final int code;
  final bool error;
  final String message;
  final String totalData;
  final List<Team> teamList;

  TeamResponse({
    required this.code,
    required this.error,
    required this.message,
    required this.totalData,
    required this.teamList,
  });

  factory TeamResponse.fromJson(Map<String, dynamic> json) {
    return TeamResponse(
      code: int.tryParse('${json['code'] ?? 0}') ?? 0,
      error: json['error'] == true,
      message: json['message']?.toString() ?? '',
      totalData: json['TotalData']?.toString() ?? '0',
      teamList: (json['data'] as List?)
          ?.map(
            (e) => Team.fromJson(
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
      'TotalData': totalData,
      'data': teamList.map((e) => e.toJson()).toList(),
    };
  }
}

class Team {
  final String id;
  final String name;
  final String mobile;
  final String role;

  Team({
    required this.id,
    required this.name,
    required this.mobile,
    required this.role,
  });

  factory Team.fromJson(Map<String, dynamic> json) {
    return Team(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      mobile: json['mobile']?.toString() ?? '',
      role: json['role']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'mobile': mobile,
      'role': role,
    };
  }
}