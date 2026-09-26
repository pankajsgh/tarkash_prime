import 'package:calculation_panel/core/network/api_path.dart';
import 'package:calculation_panel/core/network/api_repository.dart';
import 'package:calculation_panel/core/vars/global_vars.dart';
import 'package:calculation_panel/core/widget/toast.dart';
import 'package:calculation_panel/core/widget/widget_updater.dart';
import 'package:calculation_panel/core/database/sql_database_manager.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../../../core/ulitls/utility.dart';
import 'model/other_charge_model.dart';

class OtherChargeController extends ChangeNotifier {
  // ===========================================================================
  // TEXT CONTROLLERS
  // ===========================================================================

  final TextEditingController chargeNameController = TextEditingController();

  final TextEditingController printNameController = TextEditingController();

  final TextEditingController defaultValueController = TextEditingController();

  // ===========================================================================
  // WIDGET UPDATER
  // ===========================================================================

  final WidgetUpdater updateCharges = WidgetUpdater();

  // ===========================================================================
  // DATA
  // ===========================================================================

  List<OtherChargeModel> allCharges = [];
  List<OtherChargeModel> searchCharges = [];
  OtherChargeModel? selectedCharge;

  // ===========================================================================
  // STATE
  // ===========================================================================

  String? chargeType;
  String? hsn;
  String? hsnTax;

  String chargeNature = 'Additional';
  String calculationType = 'Amount';
  String appliedOn = 'Item Wise';
  String distributionMethod = 'By Amount';
  String taxTreatment = 'Taxable';

  bool allowManualChange = true;
  bool isActive = true;

  bool isSaving = false;
  bool isDeleting = false;

  // ===========================================================================
  // CONSTANTS
  // ===========================================================================

  static const String defaultChargeNature = 'Additional';
  static const String defaultCalculationType = 'Amount';
  static const String defaultAppliedOn = 'Item Wise';
  static const String defaultDistributionMethod = 'By Amount';
  static const String defaultTaxTreatment = 'Taxable';

  static const String defaultValue = '0.0';

  // ===========================================================================
  // CHARGE TYPES
  // ===========================================================================

  final List<String> chargeTypes = [
    'Select Charge Type',
    'Freight',
    'Packing',
    'Loading',
    'Unloading',
    'Handling',
    'Discount',
    'Other',
  ];

  // ===========================================================================
  // HSN LIST
  // ===========================================================================

  final Map<String, String> hsnList = {
    'Select HSN': '',
    '996511': '5',
    '996519': '12',
    '998599': '18',
  };

  // ===========================================================================
  // GETTERS
  // ===========================================================================

  bool get isEditMode => selectedCharge != null;

  String? get selectedChargeId {
    return selectedCharge?.id?.toString();
  }

  String get defaultValueText {
    final value = defaultValueController.text.trim();

    return value.isEmpty ? defaultValue : value;
  }

  // ===========================================================================
  // RESET
  // ===========================================================================

  void resetForm() {
    chargeNameController.clear();
    printNameController.clear();
    defaultValueController.clear();

    chargeType = null;
    hsn = null;
    hsnTax = null;

    chargeNature = defaultChargeNature;
    calculationType = defaultCalculationType;
    appliedOn = defaultAppliedOn;
    distributionMethod = defaultDistributionMethod;
    taxTreatment = defaultTaxTreatment;

    allowManualChange = true;
    isActive = true;

    selectedCharge = null;
    searchCharges = [];

    updateCharges.update();
    notifyListeners();
  }

  // ===========================================================================
  // SELECT CHARGE FOR EDIT
  // ===========================================================================

  void setChargeName(OtherChargeModel? value) {
    if (value == null) {
      resetForm();
      return;
    }

    selectedCharge = value;

    chargeNameController.text = value.chargeName?.toString() ?? '';
    printNameController.text = value.printName?.toString() ?? '';
    defaultValueController.text =
        value.defaultValue?.toString() ?? defaultValue;

    // Charge Type
    final selectedChargeType = value.chargeType?.toString().trim() ?? '';

    chargeType = selectedChargeType.isEmpty ? null : selectedChargeType;

    // HSN
    final selectedHsn = value.hsn?.toString().trim() ?? '';

    hsn = selectedHsn.isEmpty ? null : selectedHsn;

    // Charge Nature
    chargeNature = _valueOrDefault(value.chargeNature, defaultChargeNature);

    // Calculation Type
    calculationType = _valueOrDefault(
      value.calculationType,
      defaultCalculationType,
    );

    // Applied On
    appliedOn = _valueOrDefault(value.appliedOn, defaultAppliedOn);

    // Distribution Method
    distributionMethod = _valueOrDefault(
      value.distributionMethod,
      defaultDistributionMethod,
    );

    // Tax Treatment
    taxTreatment = _valueOrDefault(value.taxTreatment, defaultTaxTreatment);

    // Manual Change
    allowManualChange = value.allowManualChange?.toString() == '1';

    // Active Status
    isActive = value.isActive?.toString() == '1';

    // Set HSN tax from selected HSN
    hsnTax = hsn == null ? null : hsnList[hsn];

    notifyListeners();
  }

  String _valueOrDefault(dynamic value, String defaultValue) {
    final text = value?.toString().trim() ?? '';

    return text.isEmpty ? defaultValue : text;
  }

  // ===========================================================================
  // SEARCH
  // ===========================================================================

  Future<List<OtherChargeModel>> loadOtherCharges(String search) async {
    try {
      final query = search.trim();

      if (GlobalVars.isOffline) {
        final data = await DatabaseHelper.instance.getExtraCharges(query);

        final charges = data
            .map(
              (item) =>
                  OtherChargeModel.fromJson(Map<String, dynamic>.from(item)),
            )
            .toList();

        allCharges = charges;

        updateCharges.update();

        return charges;
      }

      final responseData = await ApiProvider.createServerRequest(
        apiUrl: ApiPath.searchOtherCharges,
        requestBody: {'search': query},
        isFormData: true,
      );

      if (responseData['status'] != true) {
        allCharges = [];
        updateCharges.update();
        return [];
      }

      final data =
          (responseData['data'] as List?)
              ?.map(
                (item) =>
                    OtherChargeModel.fromJson(Map<String, dynamic>.from(item)),
              )
              .toList() ??
          [];

      allCharges = data;

      updateCharges.update();

      return data;
    } on DioException catch (e) {
      debugPrint('Search Other Charges Dio Error: ${e.message}');

      debugPrint('Response: ${e.response?.data}');

      return [];
    } catch (e) {
      debugPrint('Search Other Charges Error: $e');

      return [];
    }
  }

  // ===========================================================================
  // SETTERS
  // ===========================================================================

  void setChargeType(String? value) {
    chargeType = value == null || value == 'Select Charge Type' ? null : value;

    notifyListeners();
  }

  void setHSN(String? value) {
    if (value == null || value == 'Select HSN') {
      hsn = null;
      hsnTax = null;
    } else {
      hsn = value;
      hsnTax = hsnList[value];
    }

    notifyListeners();
  }

  void setChargeNature(String value) {
    chargeNature = value;

    // Deduction cannot be applied separately.
    if (chargeNature == 'Deduction' && appliedOn == 'Separate') {
      appliedOn = 'Item Wise';
    }

    notifyListeners();
  }

  void setCalculationType(String value) {
    calculationType = value;

    distributionMethod = calculationType == 'Per Main Qty'
        ? 'By Quantity'
        : 'By Amount';

    notifyListeners();
  }

  void setAppliedOn(String value) {
    appliedOn = value;

    // HSN is only required when applied separately.
    if (appliedOn != 'Separate') {
      hsn = null;
      hsnTax = null;
    }

    notifyListeners();
  }

  void setDistributionMethod(String value) {
    distributionMethod = value;
    notifyListeners();
  }

  void setTaxTreatment(String value) {
    taxTreatment = value;
    notifyListeners();
  }

  void setAllowManualChange(bool value) {
    allowManualChange = value;
    notifyListeners();
  }

  void setStatus(bool value) {
    isActive = value;
    notifyListeners();
  }

  // ===========================================================================
  // SAVE / UPDATE
  // ===========================================================================

  Future<bool> saveCharge(BuildContext context) async {
    // -------------------------------------------------------------------------
    // VALIDATION
    // -------------------------------------------------------------------------

    final chargeName = chargeNameController.text.trim();

    final printName = printNameController.text.trim();

    final defaultValueText = defaultValueController.text.trim().isEmpty
        ? defaultValue
        : defaultValueController.text.trim();

    if (chargeName.isEmpty) {
      debugPrint('Please enter charge name');
      return false;
    }

    if (chargeType == null || chargeType!.trim().isEmpty) {
      debugPrint('Please select charge type');
      return false;
    }

    final parsedDefaultValue = double.tryParse(defaultValueText);

    if (parsedDefaultValue == null) {
      debugPrint('Please enter valid default value');
      return false;
    }

    // -------------------------------------------------------------------------
    // HSN VALIDATION
    // -------------------------------------------------------------------------

    if (appliedOn == 'Separate') {
      final selectedHsn = hsn?.trim() ?? '';

      final selectedHsnTax = hsnTax?.trim() ?? '';

      if (selectedHsn.isEmpty || selectedHsn == 'Select HSN') {
        debugPrint('Please select HSN');
        return false;
      }

      if (selectedHsnTax.isEmpty) {
        debugPrint('Please enter HSN Tax');
        return false;
      }
    }

    // -------------------------------------------------------------------------
    // EDIT ID
    // -------------------------------------------------------------------------

    final id = selectedChargeId;

    if (isEditMode && (id == null || id.isEmpty)) {
      debugPrint('Invalid other charge id');
      return false;
    }

    // -------------------------------------------------------------------------
    // LOADING
    // -------------------------------------------------------------------------

    isSaving = true;
    notifyListeners();

    try {
      // -----------------------------------------------------------------------
      // FORM DATA
      // -----------------------------------------------------------------------

      final Map<String, String> formData = {
        if (isEditMode) 'id': id!,

        'charge_name': chargeName,
        'charge_type': chargeType!,
        'charge_nature': chargeNature,
        'print_name': printName,
        'default_value': defaultValueText,
        'calculation_type': calculationType,
        'applied_on': appliedOn,
        'distribution_method': distributionMethod,
        'tax_treatment': taxTreatment,

        'hsn': appliedOn == 'Separate' ? hsn?.trim() ?? '' : '',

        'hsn_tax': appliedOn == 'Separate' ? hsnTax?.trim() ?? '' : '',

        'allow_manual_change': allowManualChange ? '1' : '0',

        'is_active': isActive ? '1' : '0',
      };

      debugPrint('================ OTHER CHARGE ================');

      debugPrint(formData.toString());

      // -----------------------------------------------------------------------
      // OFFLINE DATABASE
      // -----------------------------------------------------------------------

      if (GlobalVars.isOffline) {
        int chargeId;

        if (isEditMode) {
          chargeId = await DatabaseHelper.instance.updateExtraCharge(
            int.parse(id!),
            formData,
          );
        } else {
          chargeId = await DatabaseHelper.instance.insertExtraCharge(formData);
        }

        debugPrint('Other charge saved. ID: $chargeId');

        resetForm();

        if (context.mounted) {
          Navigator.pop(context, true);
        }

        return true;
      }

      // -----------------------------------------------------------------------
      // API
      // -----------------------------------------------------------------------

      final apiUrl = isEditMode
          ? ApiPath.updateOtherCharges
          : ApiPath.submitOtherCharges;

      final responseData = await ApiProvider.createServerRequest(
        apiUrl: apiUrl,
        requestBody: formData,
        isFormData: true,
      );

      // -----------------------------------------------------------------------
      // RESPONSE
      // -----------------------------------------------------------------------

      if (responseData['status'] == true) {
        debugPrint(
          responseData['message']?.toString() ??
              (isEditMode
                  ? 'Other charge updated successfully'
                  : 'Other charge saved successfully'),
        );

        resetForm();

        if (context.mounted) {
          Navigator.pop(context, true);
        }

        return true;
      }

      debugPrint(
        responseData['message']?.toString() ?? 'Failed to save other charge',
      );

      return false;
    } on DioException catch (e) {
      debugPrint('Dio Error: ${e.message}');

      debugPrint('Status Code: ${e.response?.statusCode}');

      debugPrint('Response: ${e.response?.data}');

      if (e.response?.data is Map) {
        final data = Map<String, dynamic>.from(e.response!.data);

        debugPrint(
          'API Message: '
          '${data['message'] ?? 'Unknown error'}',
        );
      }

      return false;
    } catch (e) {
      debugPrint('Error saving other charge: $e');

      return false;
    } finally {
      isSaving = false;
      notifyListeners();
    }
  }

  // ===========================================================================
  // DELETE
  // ===========================================================================

  Future<bool> deleteOtherCharge({required String id}) async {
    final chargeId = id.trim();

    if (chargeId.isEmpty) {
      showMessage('Charge ID is required', ToastType.info);

      return false;
    }

    isDeleting = true;
    updateCharges.update();

    try {
      // -----------------------------------------------------------------------
      // OFFLINE DATABASE
      // -----------------------------------------------------------------------

      if (GlobalVars.isOffline) {
        final deletedId = await DatabaseHelper.instance.deleteExtraCharge(
          int.parse(chargeId),
        );

        debugPrint('Other charge deleted. ID: $deletedId');

        return true;
      }

      // -----------------------------------------------------------------------
      // API
      // -----------------------------------------------------------------------

      final response = await ApiProvider.createServerRequest(
        apiUrl: ApiPath.deleteOtherCharge,
        requestBody: {'id': chargeId},
        isFormData: true,
      );

      return response['status'] == true;
    } on DioException catch (e) {
      debugPrint('Delete Other Charge Dio Error: ${e.message}');

      return false;
    } catch (e) {
      debugPrint('Delete Other Charge Error: $e');

      return false;
    } finally {
      isDeleting = false;
      updateCharges.update();
    }
  }

  // ===========================================================================
  // DISPOSE
  // ===========================================================================

  @override
  void dispose() {
    chargeNameController.dispose();
    printNameController.dispose();
    defaultValueController.dispose();

    super.dispose();
  }
}
