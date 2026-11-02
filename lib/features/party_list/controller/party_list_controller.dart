import 'dart:async';

import 'package:calculation_panel/core/network/api_path.dart';
import 'package:calculation_panel/core/network/api_repository.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../../purchase_challan/model/party_model.dart';
import '../../purchase_challan/model/supplier_model.dart';

class PartyListController extends ChangeNotifier {
  PartyListController();

  static const int pageSize = 20;
  static String partyType = '';

  final List<Party> parties = [];

  final TextEditingController searchController = TextEditingController();
  final ScrollController scrollController = ScrollController();

  Timer? _debounce;

  bool isLoading = false;
  bool isLoadingMore = false;
  bool hasMore = true;
  bool isDisposed = false;

  String errorMessage = '';
  String search = '';

  int skip = 0;
  int totalData = 0;
  int _requestId = 0;

  @override
  void dispose() {
    isDisposed = true;
    _requestId++;

    _debounce?.cancel();
    searchController.dispose();
    scrollController.dispose();

    super.dispose();
  }

  void _notify() {
    if (!isDisposed) {
      notifyListeners();
    }
  }

  String _responseMessage(dynamic response, String fallback) {
    if (response is Map) {
      return response['msg']?.toString() ??
          response['message']?.toString() ??
          fallback;
    }

    return fallback;
  }

  void onSearchChanged(String value) {
    _debounce?.cancel();

    final newSearch = value.trim();

    if (newSearch == search) return;

    search = newSearch;

    // Invalidate requests belonging to the previous search immediately.
    _requestId++;

    _debounce = Timer(
      const Duration(milliseconds: 400),
          () {
        if (!isDisposed) {
          loadParties(refresh: true);
        }
      },
    );
  }

  Future<void> refresh() async {
    if (isDisposed) return;

    _debounce?.cancel();
    search = searchController.text.trim();

    await loadParties(refresh: true);
  }

  Future<void> loadParties({bool refresh = false}) async {
    if (isDisposed) return;

    if (!refresh && (isLoading || isLoadingMore || !hasMore)) {
      return;
    }

    if (refresh) {
      // Invalidate any previous request before starting a new one.
      _requestId++;

      skip = 0;
      totalData = 0;
      hasMore = true;
      errorMessage = '';
      isLoading = true;
      isLoadingMore = false;
    } else {
      isLoadingMore = true;
      errorMessage = '';
    }

    final requestId = ++_requestId;
    final requestedSkip = refresh ? 0 : skip;
    final requestedSearch = search;
    final requestedPartyType = partyType;

    _notify();

    try {
      final response = await ApiProvider.createServerRequest(
        apiUrl: ApiPath.getPartyList,
        requestBody: {
          'PartyType': requestedPartyType,
          'search': requestedSearch,
          'limit': pageSize.toString(),
          'skip': requestedSkip.toString(),
          'offset': requestedSkip.toString(),
        },
        isFormData: true,
      );

      // Ignore results from an old search, refresh, or disposed controller.
      if (isDisposed || requestId != _requestId) return;

      if (response is! Map) {
        errorMessage = 'Invalid response received from server.';
        return;
      }

      // Your API convention: error=true means success.
      if (response['error'] != true) {
        errorMessage = _responseMessage(
          response,
          'Unable to fetch party list.',
        );
        return;
      }

      final rawList = response['PartyList'];

      final newParties = rawList is List
          ? rawList
          .whereType<Map>()
          .map(
            (item) => Party.fromJson(
          Map<String, dynamic>.from(item),
        ),
      )
          .toList()
          : <Party>[];

      totalData = int.tryParse(
        response['TotalData']?.toString() ?? '',
      ) ??
          0;

      if (refresh) {
        parties
          ..clear()
          ..addAll(newParties);
      } else {
        // Prevent duplicate records if the API returns overlapping pages.
        parties.addAll(newParties);
      }

      skip = parties.length;

      hasMore = newParties.length == pageSize &&
          (totalData <= 0 || parties.length < totalData);

      errorMessage = '';
    } on DioException catch (e) {
      if (isDisposed || requestId != _requestId) return;

      final data = e.response?.data;

      errorMessage = data is Map
          ? _responseMessage(data, 'Unable to fetch party list.')
          : 'Unable to connect to the server. Check your connection and API URL.';
    } catch (e) {
      if (isDisposed || requestId != _requestId) return;

      errorMessage = e.toString().replaceFirst('Exception: ', '');
    } finally {
      if (!isDisposed && requestId == _requestId) {
        isLoading = false;
        isLoadingMore = false;
        _notify();
      }
    }
  }

  Future<void> loadMore() async {
    await loadParties();
  }

  void clearSearch() {
    if (isDisposed) return;

    _debounce?.cancel();
    searchController.clear();

    if (search.isEmpty) return;

    search = '';

    // Invalidate an in-flight request before refreshing.
    _requestId++;

    loadParties(refresh: true);
  }
}