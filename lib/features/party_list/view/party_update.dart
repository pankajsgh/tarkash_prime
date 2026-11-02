import 'dart:convert';

import 'package:flutter/material.dart';

import '../../account_group/model/account_group_model.dart';
import '../../components/custome_dropdown_widget.dart';
import '../../purchase_challan/model/category_model.dart';
import '../../purchase_challan/model/hsn_model.dart';
import '../../purchase_challan/model/party_model.dart';
import '../../purchase_challan/model/transport_model.dart';
import '../../purchase_challan/model/supplier_model.dart';
import '../controller/party_update_controller.dart';
import '../model/city_model.dart';
import '../model/state_model.dart';

class PartyUpdateWidget extends StatefulWidget {
  final Party? party;
  final Future<void> Function(Map<String, dynamic> data)? onUpdate;
  final VoidCallback? onCancel;
  final ValueChanged<Map<String, dynamic>>? onSaved;

  const PartyUpdateWidget({
    super.key,
    this.party,
    this.onUpdate,
    this.onCancel,
    this.onSaved,
  });

  bool get isCreate => party == null;

  @override
  State<PartyUpdateWidget> createState() => _PartyUpdateWidgetState();
}

class _PartyCategoryMarginRow {
  CategoryModel? category;
  final TextEditingController mrp = TextEditingController();
  final TextEditingController wholesale = TextEditingController();
  final TextEditingController retail = TextEditingController();

  void dispose() {
    mrp.dispose();
    wholesale.dispose();
    retail.dispose();
  }
}

class _PartyUpdateWidgetState extends State<PartyUpdateWidget> {
  static const Color primary = Color(0xFF3267D5);
  static const Color dark = Color(0xFF263449);
  static const Color muted = Color(0xFF718096);
  static const Color border = Color(0xFFDCE3ED);
  static const Color background = Color(0xFFF4F6FA);
  static const Color white = Colors.white;

  late final PartyUpdateController controller;

  late final TextEditingController companyController;
  late final TextEditingController printNameController;
  late final TextEditingController nameController;
  late final TextEditingController mobileController;
  late final TextEditingController gstController;
  late final TextEditingController discountController;
  late final TextEditingController addressController;
  late final TextEditingController pincodeController;
  late final TextEditingController mrpController;
  late final TextEditingController wholesaleMarginController;
  late final TextEditingController retailMarginController;
  late final TextEditingController countryController;
  late final TextEditingController whatsappController;
  late final TextEditingController emailController;
  late final TextEditingController panController;
  late final TextEditingController aadhaarController;
  late final TextEditingController remarkController;
  late final TextEditingController creditDaysController;
  late final TextEditingController creditLimitController;
  late final TextEditingController openingBalanceController;
  late final TextEditingController usernameController;
  late final TextEditingController passwordController;
  late final TextEditingController bankNameController;
  late final TextEditingController bankAccountController;
  late final TextEditingController branchController;
  late final TextEditingController ifscController;

  String dealerType = 'Registered';
  String openingType = 'Debit';

  // GST defaults
  String gstType = 'GST Applicable';
  // String gstExtraType = '';
  String gstPercentage = '';
  String itcEligibility = '';
  String rcmNature = '';

  bool loading = true;
  bool saving = false;

  Map<String, dynamic> _partyDetails = {};

  final List<_PartyCategoryMarginRow> _categoryMarginRows = [];

  bool get isCreate => widget.isCreate;

  String _value(dynamic value) => value?.toString().trim() ?? '';

  String accountGroupSearch = '';

  HsnModel? selectedHsn;

  static const countryCodes = <String, String>{
    '93': 'Afghanistan (+93)',
    '355': 'Albania (+355)',
    '213': 'Algeria (+213)',
    '376': 'Andorra (+376)',
    '244': 'Angola (+244)',
    '54': 'Argentina (+54)',
    '374': 'Armenia (+374)',
    '61': 'Australia (+61)',
    '43': 'Austria (+43)',
    '994': 'Azerbaijan (+994)',
    '973': 'Bahrain (+973)',
    '880': 'Bangladesh (+880)',
    '375': 'Belarus (+375)',
    '32': 'Belgium (+32)',
    '501': 'Belize (+501)',
    '229': 'Benin (+229)',
    '975': 'Bhutan (+975)',
    '591': 'Bolivia (+591)',
    '387': 'Bosnia and Herzegovina (+387)',
    '267': 'Botswana (+267)',
    '55': 'Brazil (+55)',
    '673': 'Brunei (+673)',
    '359': 'Bulgaria (+359)',
    '226': 'Burkina Faso (+226)',
    '257': 'Burundi (+257)',
    '855': 'Cambodia (+855)',
    '237': 'Cameroon (+237)',
    '1': 'United States / Canada (+1)',
    '238': 'Cape Verde (+238)',
    '236': 'Central African Republic (+236)',
    '235': 'Chad (+235)',
    '56': 'Chile (+56)',
    '86': 'China (+86)',
    '57': 'Colombia (+57)',
    '269': 'Comoros (+269)',
    '506': 'Costa Rica (+506)',
    '385': 'Croatia (+385)',
    '53': 'Cuba (+53)',
    '357': 'Cyprus (+357)',
    '420': 'Czech Republic (+420)',
    '45': 'Denmark (+45)',
    '253': 'Djibouti (+253)',
    '593': 'Ecuador (+593)',
    '20': 'Egypt (+20)',
    '503': 'El Salvador (+503)',
    '372': 'Estonia (+372)',
    '251': 'Ethiopia (+251)',
    '679': 'Fiji (+679)',
    '358': 'Finland (+358)',
    '33': 'France (+33)',
    '995': 'Georgia (+995)',
    '49': 'Germany (+49)',
    '233': 'Ghana (+233)',
    '30': 'Greece (+30)',
    '502': 'Guatemala (+502)',
    '224': 'Guinea (+224)',
    '592': 'Guyana (+592)',
    '509': 'Haiti (+509)',
    '504': 'Honduras (+504)',
    '852': 'Hong Kong (+852)',
    '36': 'Hungary (+36)',
    '354': 'Iceland (+354)',
    '91': 'India (+91)',
    '62': 'Indonesia (+62)',
    '98': 'Iran (+98)',
    '964': 'Iraq (+964)',
    '353': 'Ireland (+353)',
    '972': 'Israel (+972)',
    '39': 'Italy (+39)',
    '225': 'Ivory Coast (+225)',
    '81': 'Japan (+81)',
    '962': 'Jordan (+962)',
    '7': 'Kazakhstan / Russia (+7)',
    '254': 'Kenya (+254)',
    '965': 'Kuwait (+965)',
    '996': 'Kyrgyzstan (+996)',
    '856': 'Laos (+856)',
    '371': 'Latvia (+371)',
    '961': 'Lebanon (+961)',
    '266': 'Lesotho (+266)',
    '231': 'Liberia (+231)',
    '218': 'Libya (+218)',
    '423': 'Liechtenstein (+423)',
    '370': 'Lithuania (+370)',
    '352': 'Luxembourg (+352)',
    '853': 'Macau (+853)',
    '389': 'North Macedonia (+389)',
    '261': 'Madagascar (+261)',
    '265': 'Malawi (+265)',
    '60': 'Malaysia (+60)',
    '960': 'Maldives (+960)',
    '223': 'Mali (+223)',
    '356': 'Malta (+356)',
    '222': 'Mauritania (+222)',
    '230': 'Mauritius (+230)',
    '52': 'Mexico (+52)',
    '373': 'Moldova (+373)',
    '377': 'Monaco (+377)',
    '976': 'Mongolia (+976)',
    '382': 'Montenegro (+382)',
    '212': 'Morocco (+212)',
    '258': 'Mozambique (+258)',
    '95': 'Myanmar (+95)',
    '264': 'Namibia (+264)',
    '977': 'Nepal (+977)',
    '31': 'Netherlands (+31)',
    '64': 'New Zealand (+64)',
    '505': 'Nicaragua (+505)',
    '227': 'Niger (+227)',
    '234': 'Nigeria (+234)',
    '47': 'Norway (+47)',
    '968': 'Oman (+968)',
    '92': 'Pakistan (+92)',
    '970': 'Palestine (+970)',
    '507': 'Panama (+507)',
    '595': 'Paraguay (+595)',
    '51': 'Peru (+51)',
    '63': 'Philippines (+63)',
    '48': 'Poland (+48)',
    '351': 'Portugal (+351)',
    '974': 'Qatar (+974)',
    '40': 'Romania (+40)',
    '250': 'Rwanda (+250)',
    '966': 'Saudi Arabia (+966)',
    '221': 'Senegal (+221)',
    '381': 'Serbia (+381)',
    '65': 'Singapore (+65)',
    '421': 'Slovakia (+421)',
    '386': 'Slovenia (+386)',
    '27': 'South Africa (+27)',
    '82': 'South Korea (+82)',
    '34': 'Spain (+34)',
    '94': 'Sri Lanka (+94)',
    '249': 'Sudan (+249)',
    '46': 'Sweden (+46)',
    '41': 'Switzerland (+41)',
    '963': 'Syria (+963)',
    '886': 'Taiwan (+886)',
    '992': 'Tajikistan (+992)',
    '255': 'Tanzania (+255)',
    '66': 'Thailand (+66)',
    '228': 'Togo (+228)',
    '216': 'Tunisia (+216)',
    '90': 'Turkey (+90)',
    '993': 'Turkmenistan (+993)',
    '256': 'Uganda (+256)',
    '380': 'Ukraine (+380)',
    '971': 'United Arab Emirates (+971)',
    '44': 'United Kingdom (+44)',
    '598': 'Uruguay (+598)',
    '998': 'Uzbekistan (+998)',
    '58': 'Venezuela (+58)',
    '84': 'Vietnam (+84)',
    '967': 'Yemen (+967)',
    '260': 'Zambia (+260)',
    '263': 'Zimbabwe (+263)',
  };

  @override
  void initState() {
    super.initState();


    controller = PartyUpdateController();
    countryController = TextEditingController(
      text: countryCodes['91'] ?? '',
    );

    final party = widget.party;
    companyController = TextEditingController(text: _value(party?.company));
    printNameController = TextEditingController(text: _value(party?.printName));
    nameController = TextEditingController(text: _value(party?.name));
    mobileController = TextEditingController(text: _value(party?.mobile));
    gstController = TextEditingController(text: _value(party?.gstNo));
    discountController = TextEditingController(text: _value(party?.discount));
    addressController = TextEditingController(text: _value(party?.address));
    pincodeController = TextEditingController(text: _value(party?.pincode));
    mrpController = TextEditingController(text: _value(party?.mrp));
    wholesaleMarginController = TextEditingController(text: _value(party?.wholesale));
    retailMarginController = TextEditingController(text: _value(party?.retail));
    whatsappController = TextEditingController();
    emailController = TextEditingController();
    panController = TextEditingController();
    aadhaarController = TextEditingController();
    remarkController = TextEditingController();
    creditDaysController = TextEditingController();
    creditLimitController = TextEditingController();
    openingBalanceController = TextEditingController();
    usernameController = TextEditingController();
    passwordController = TextEditingController();
    bankNameController = TextEditingController();
    bankAccountController = TextEditingController();
    branchController = TextEditingController();
    ifscController = TextEditingController();

    if (party?.brandList != null) {
      controller.selectedBrands = List.of(party!.brandList!);
    }

    _initializeForm();
  }

  Future<void> _initializeForm() async {
    try {
      if (!isCreate) {
        final id = _value(widget.party?.id);

        if (id.isNotEmpty) {
          _partyDetails = await controller.getPartyDetails(id) ?? {};

          if (!mounted) return;

          _fillTextFields(_partyDetails);
        }
      }

      await controller.getBrandList();

      if (!mounted) return;

      final rawBrands = _partyDetails['brands'];

      if (rawBrands is List) {
        final ids = rawBrands.map((item) {
          if (item is Map) return _value(item['id']);
          return _value(item);
        }).where((id) => id.isNotEmpty).toSet();

        controller.selectedBrands = controller.brands
            .where((brand) => ids.contains(_value(brand.id)))
            .toList();
      } else if (widget.party?.brandList != null) {
        final ids = widget.party!.brandList!
            .map((brand) => _value(brand.id))
            .toSet();

        controller.selectedBrands = controller.brands
            .where((brand) => ids.contains(_value(brand.id)))
            .toList();
      }

      await _loadDropdowns();
    } catch (e, stackTrace) {
      debugPrint('Party form initialization error: $e');
      debugPrintStack(stackTrace: stackTrace);

      if (mounted) {
        setState(() => loading = false);
      }
    }
  }

  void _fillTextFields(Map<String, dynamic> data) {
    String value(String key) => _value(data[key]);

    companyController.text = value('company');
    printNameController.text = value('print_name');
    nameController.text = value('name');
    mobileController.text = value('mobile');
    gstController.text = value('gst_no');
    discountController.text = value('discount');
    addressController.text = value('address');
    pincodeController.text = value('pincode');
    mrpController.text = value('mrp');
    wholesaleMarginController.text = value('wholesale');
    retailMarginController.text = value('retail');

    whatsappController.text = value('whatsapp_no');
    emailController.text = value('email');
    panController.text = value('pan_no');
    aadhaarController.text = value('aadhaar_no');
    remarkController.text = value('remark');
    creditDaysController.text = value('credit_days');
    creditLimitController.text = value('credit_limit');
    openingBalanceController.text = value('opening_balance');
    usernameController.text = value('username');

    passwordController.clear();

    bankNameController.text = value('bank_name');

    bankAccountController.text = value('bank_account_no').isNotEmpty
        ? value('bank_account_no')
        : value('bank_account');

    branchController.text = value('branch');

    ifscController.text = value('ifsc_code').isNotEmpty
        ? value('ifsc_code')
        : value('ifsc');

    // ---------------- GST DETAILS ----------------

    final savedGstType = value('gst_type');

    gstType = savedGstType.isEmpty
        ? 'GST Applicable'
        : savedGstType;

    final savedGstPercentage = value('gst_percentage');

    gstPercentage = savedGstPercentage.isEmpty
        ? '18%'
        : '${savedGstPercentage.replaceAll('%', '')}%';

    itcEligibility = value('itc_eligibility').isEmpty
        ? 'Input Goods'
        : value('itc_eligibility');

    rcmNature = value('rcm_nature').isEmpty
        ? 'Not Applicable'
        : value('rcm_nature');

    // ------------------------------------------------

    final countryId = value('country_id').replaceAll('+', '');

    countryController.text = countryCodes[countryId] ?? '';

    dealerType = value('dealer_type').isEmpty
        ? 'Registered'
        : value('dealer_type');

    openingType = value('opening_type').isEmpty
        ? 'Debit'
        : value('opening_type');
  }

  Widget _countryDropdown() {
    final countryList = countryCodes.entries
        .map((country) => country.value)
        .toList();

    return _fieldBlock(
      'Country',
      SearchableCustomerDropdown<String>(
        key: const ValueKey('party_country_dropdown'),
        value: countryList.contains(countryController.text)
            ? countryController.text
            : null,
        height: 38,
        borderColor: border,
        borderRadius: 7,
        hint: 'Select country',
        items: countryList,
        onSearch: (_) {},
        displayString: (country) => country,
        onSelect: (country) {
          if (country == null) return;

          setState(() {
            countryController.text = country;
          });
        },
      ),
    );
  }

  Future<void> _loadDropdowns() async {
    try {
      await Future.wait([
        controller.getStateList(''),
        controller.getTransportList(''),
        controller.getAgentList(''),
        controller.getAccountGroupList(''),
        controller.getCategoryList(''),
        controller.getHsnList(''),
      ]);

      if (!mounted) return;

      final party = widget.party;

      final savedHsnCode = _value(_partyDetails['hsn_code']);

      if (savedHsnCode.isNotEmpty) {
        final savedHsn = controller.controllerHsnList
            .where((item) => _value(item.hsnCode) == savedHsnCode)
            .firstOrNull;

        controller.setHsn(savedHsn);
      }

      if (party == null) {
        controller.setState(null);
        controller.setCity(null);
        controller.setTransport(null);
        controller.setAgent(null);
        controller.setSelectedAccountGroup(null);

        _categoryMarginRows.clear();
        _categoryMarginRows.add(_PartyCategoryMarginRow());

        return;
      }

      final stateId = _value(_partyDetails['state_id']).isNotEmpty
          ? _value(_partyDetails['state_id'])
          : _value(party.state?.id);

      final cityId = _value(_partyDetails['city_id']).isNotEmpty
          ? _value(_partyDetails['city_id'])
          : _value(party.city?.id);

      final transportId = _value(_partyDetails['transport_id']).isNotEmpty
          ? _value(_partyDetails['transport_id'])
          : _value(party.transport?.id);

      final agentId = _value(_partyDetails['agency_id']).isNotEmpty
          ? _value(_partyDetails['agency_id'])
          : _value(party.agency?.id);

      final accountGroupId = _value(_partyDetails['party_type']).isNotEmpty
          ? _value(_partyDetails['party_type'])
          : _value(party.partyType);

      final categoryId = _value(_partyDetails['category_id']);

      final rawSavedMargins =
          _partyDetails['margins'] ?? _partyDetails['category_margins'];

      List<dynamic> marginItems = [];
      if (rawSavedMargins is List) {
        marginItems = rawSavedMargins;
      } else if (rawSavedMargins is String && rawSavedMargins.trim().isNotEmpty) {
        try {
          final decoded = jsonDecode(rawSavedMargins);
          if (decoded is List) marginItems = decoded;
        } catch (e) {
          debugPrint('Unable to decode saved category margins: $e');
        }
      }

      final savedMargins = marginItems
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .toList();

      if (!mounted) return;

      _categoryMarginRows.clear();

      for (final item in savedMargins) {
        final row = _PartyCategoryMarginRow();

        final id = _value(item['category_id']);

        row.category = controller.categoryList
            .where((category) => _value(category.id) == id)
            .firstOrNull;

        row.mrp.text = _value(item['mrp']);
        row.wholesale.text = _value(item['wholesale']);
        row.retail.text = _value(item['retail']);

        _categoryMarginRows.add(row);
      }

      if (_categoryMarginRows.isEmpty && categoryId.isNotEmpty) {
        final row = _PartyCategoryMarginRow();

        row.category = controller.categoryList
            .where((category) => _value(category.id) == categoryId)
            .firstOrNull;

        row.mrp.text = _value(_partyDetails['mrp']);
        row.wholesale.text = _value(_partyDetails['wholesale']);
        row.retail.text = _value(_partyDetails['retail']);

        _categoryMarginRows.add(row);
      }

      if (_categoryMarginRows.isEmpty) {
        _categoryMarginRows.add(_PartyCategoryMarginRow());
      }

      final selectedState = controller.states
          .where((item) => _value(item.id) == stateId)
          .firstOrNull;

      final selectedTransport = controller.transports
          .where((item) => _value(item.id) == transportId)
          .firstOrNull;

      final selectedAgent = controller.agents
          .where((item) => _value(item.id) == agentId)
          .firstOrNull;

      final selectedGroup = controller.accountGroups
          .where((item) => _value(item.id) == accountGroupId)
          .firstOrNull;

      controller.setState(selectedState);
      controller.setTransport(selectedTransport);
      controller.setAgent(selectedAgent);
      controller.setSelectedAccountGroup(selectedGroup);

      controller.setCategory(
        controller.categoryList
            .where((item) => _value(item.id) == categoryId)
            .firstOrNull,
      );

      if (selectedState != null) {
        await controller.getCityList(selectedState.id.toString(), '');
      } else {
        controller.setCity(null);
      }

      if (!mounted) return;

      controller.setCity(
        controller.cities
            .where((item) => _value(item.id) == cityId)
            .firstOrNull,
      );
    } catch (e, stackTrace) {
      debugPrint('Party dropdown loading error: $e');
      debugPrintStack(stackTrace: stackTrace);
    } finally {
      if (mounted) {
        setState(() => loading = false);
      }
    }
  }

  void _cancel() {
    if (saving) return;

    if (widget.onCancel != null) {
      widget.onCancel!();
    } else {
      Navigator.of(context).maybePop();
    }
  }

  Widget _fieldBlock(String label, Widget field) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 1, bottom: 5),
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 11,
              color: dark,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        field,
      ],
    );
  }

  Widget _editField(
      String label,
      TextEditingController textController, {
        int maxLines = 1,
        TextInputType keyboardType = TextInputType.text,
        String? hint,
        bool obscureText = false,
      }) {
    return _fieldBlock(
      label,
      TextField(
        controller: textController,
        maxLines: obscureText ? 1 : maxLines,
        obscureText: obscureText,
        keyboardType: keyboardType,
        style: const TextStyle(fontSize: 12, color: dark),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(fontSize: 11, color: muted),
          isDense: true,
          filled: true,
          fillColor: white,
          contentPadding:
          const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(7),
            borderSide: const BorderSide(color: border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(7),
            borderSide: const BorderSide(color: border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(7),
            borderSide: const BorderSide(color: primary, width: 1.3),
          ),
        ),
      ),
    );
  }

  Widget _choiceField({
    required String label,
    required String value,
    required List<String> values,
    required ValueChanged<String> onChanged,
  }) {
    return _fieldBlock(
      label,
      SizedBox(
        height: 38,
        child: DropdownButtonFormField<String>(
          value: values.contains(value) ? value : values.first,
          isExpanded: true,
          style: const TextStyle(fontSize: 12, color: dark),
          decoration: InputDecoration(
            isDense: true,
            contentPadding:
            const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
            filled: true,
            fillColor: white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(7),
              borderSide: const BorderSide(color: border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(7),
              borderSide: const BorderSide(color: border),
            ),
          ),
          items: values
              .map(
                (item) => DropdownMenuItem(
              value: item,
              child: Text(
                item,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          )
              .toList(),
          onChanged: (value) {
            if (value != null) onChanged(value);
          },
        ),
      ),
    );
  }

  Widget _dropdownCategoryField({
    required String label,
    required CategoryModel? value,
    required ValueChanged<CategoryModel?> onChanged,
  }) {
    return _fieldBlock(
      label,
      SizedBox(
        height: 38,
        child: SearchableCustomerDropdown<CategoryModel>(
          value: value,
          items: controller.categoryList,
          borderColor: border,
          onSearch: (value) => controller.getCategoryList(value ?? ''),
          displayString: (item) => item.category,
          onSelect: onChanged,
        ),
      ),
    );
  }

  void _addCategoryMarginRow() {
    setState(() {
      _categoryMarginRows.add(_PartyCategoryMarginRow());
    });
  }

  void _removeCategoryMarginRow(int index) {
    if (_categoryMarginRows.length == 1) {
      final row = _categoryMarginRows.first;

      row.category = null;
      row.mrp.clear();
      row.wholesale.clear();
      row.retail.clear();

      setState(() {});
      return;
    }

    final row = _categoryMarginRows.removeAt(index);
    row.dispose();

    setState(() {});
  }

  Widget _categoryMarginEditor(_PartyCategoryMarginRow row, int index) {
    Widget marginField(
        String label,
        TextEditingController textController,
        ) {
      return SizedBox(
        width: 112,
        child: _editField(
          label,
          textController,
          keyboardType:
          const TextInputType.numberWithOptions(decimal: true),
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFD),
        border: Border.all(color: border),
        borderRadius: BorderRadius.circular(9),
      ),
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        crossAxisAlignment: WrapCrossAlignment.end,
        children: [
          SizedBox(
            width: 220,
            child: _dropdownCategoryField(
              label: 'Category',
              value: row.category,
              onChanged: (value) {
                final duplicate = value != null &&
                    _categoryMarginRows.any(
                          (other) =>
                      !identical(other, row) &&
                          _value(other.category?.id) == _value(value.id),
                    );

                if (duplicate) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('This category is already added.'),
                    ),
                  );
                  return;
                }

                setState(() => row.category = value);
              },
            ),
          ),
          marginField('MRP (%)', row.mrp),
          marginField('Wholesale (%)', row.wholesale),
          marginField('Retail (%)', row.retail),
          Padding(
            padding: const EdgeInsets.only(bottom: 1),
            child: IconButton(
              tooltip: 'Remove category',
              onPressed:
              saving ? null : () => _removeCategoryMarginRow(index),
              icon: const Icon(
                Icons.delete_outline_rounded,
                color: Colors.red,
                size: 21,
              ),
              visualDensity: VisualDensity.compact,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showBrandPopup() async {
    String search = '';

    final selectedIds =
    controller.selectedBrands.map((brand) => _value(brand.id)).toSet();

    final result = await showDialog<List<BrandItem>>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) {
          final filteredBrands = controller.brands.where((brand) {
            return _value(brand.brand)
                .toLowerCase()
                .contains(search.trim().toLowerCase());
          }).toList();

          return AlertDialog(
            backgroundColor: white,
            surfaceTintColor: Colors.transparent,
            title: const Text(
              'Select Brands',
              style: TextStyle(fontSize: 16, color: dark),
            ),
            content: SizedBox(
              width: 400,
              height: 350,
              child: Column(
                children: [
                  TextField(
                    onChanged: (value) {
                      setDialogState(() => search = value);
                    },
                    decoration: const InputDecoration(
                      hintText: 'Search brands...',
                      prefixIcon: Icon(Icons.search, size: 18),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: filteredBrands.isEmpty
                        ? const Center(child: Text('No brands found'))
                        : ListView.builder(
                      itemCount: filteredBrands.length,
                      itemBuilder: (context, index) {
                        final brand = filteredBrands[index];
                        final id = _value(brand.id);

                        return CheckboxListTile(
                          dense: true,
                          value: selectedIds.contains(id),
                          activeColor: primary,
                          title: Text(
                            _value(brand.brand),
                            style: const TextStyle(
                              fontSize: 12,
                              color: dark,
                            ),
                          ),
                          onChanged: (checked) {
                            setDialogState(() {
                              if (checked == true) {
                                selectedIds.add(id);
                              } else {
                                selectedIds.remove(id);
                              }
                            });
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () {
                  Navigator.pop(
                    dialogContext,
                    controller.brands
                        .where(
                          (brand) =>
                          selectedIds.contains(_value(brand.id)),
                    )
                        .toList(),
                  );
                },
                child: const Text('Apply'),
              ),
            ],
          );
        },
      ),
    );

    if (!mounted || result == null) return;

    setState(() {
      controller.selectedBrands
        ..clear()
        ..addAll(result);
    });
  }

  Widget _brandMultiSelect() {
    final names = controller.selectedBrands
        .map((brand) => _value(brand.brand))
        .where((name) => name.isNotEmpty)
        .toList();

    return _fieldBlock(
      'Brands',
      InkWell(
        onTap: _showBrandPopup,
        borderRadius: BorderRadius.circular(7),
        child: Container(
          constraints: const BoxConstraints(minHeight: 38),
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 9),
          decoration: BoxDecoration(
            color: white,
            borderRadius: BorderRadius.circular(7),
            border: Border.all(color: border),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  names.isEmpty ? 'Select brands' : names.join(', '),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11,
                    color: names.isEmpty ? muted : dark,
                  ),
                ),
              ),
              const Icon(
                Icons.keyboard_arrow_down_rounded,
                size: 19,
                color: muted,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _stateDropdown() => _fieldBlock(
    'State',
    SearchableCustomerDropdown<StateModelItem>(
      key: const ValueKey('party_state_dropdown'),
      value: controller.selectedState,
      height: 38,
      borderColor: border,
      borderRadius: 7,
      items: List<StateModelItem>.from(controller.states),
      onSearch: controller.searchStates,
      displayString: (item) => item.stateName,
      onSelect: (value) async {
        controller.setState(value);
        controller.clearCity();

        if (value != null) {
          await controller.getCityList(value.id.toString(), '');
        }
      },
    ),
  );

  Widget _cityDropdown() => _fieldBlock(
    'City',
    SearchableCustomerDropdown<CityModelItem>(
      key: const ValueKey('party_city_dropdown'),
      value: controller.selectedCity,
      height: 38,
      borderColor: border,
      borderRadius: 7,
      items: List<CityModelItem>.from(controller.cities),
      onSearch: controller.searchCities,
      displayString: (item) => item.cityName,
      onSelect: controller.setCity,
    ),
  );

  Widget _transportDropdown() => _fieldBlock(
    'Transport',
    SearchableCustomerDropdown<TransportModel>(
      key: const ValueKey('party_transport_dropdown'),
      value: controller.selectedTransport,
      height: 38,
      borderColor: border,
      borderRadius: 7,
      items: List<TransportModel>.from(controller.transports),
      onSearch: controller.searchTransports,
      displayString: (item) => item.transport ?? '',
      onSelect: controller.setTransport,
    ),
  );

  Widget _agentDropdown() => _fieldBlock(
    'Agent',
    SearchableCustomerDropdown<Agency>(
      key: const ValueKey('party_agent_dropdown'),
      value: controller.selectedAgent,
      height: 38,
      borderColor: border,
      borderRadius: 7,
      items: List<Agency>.from(controller.agents),
      onSearch: controller.searchAgents,
      displayString: (item) => item.name ?? '',
      onSelect: controller.setAgent,
    ),
  );

  Widget _accountGroupDropdown() => _fieldBlock(
    'Account Group',
    ListenableBuilder(
      listenable: controller,
      builder: (context, child) {
        final search = accountGroupSearch.trim().toLowerCase();

        final filteredGroups = controller.accountGroups.where((item) {
          return item.name.toLowerCase().contains(search);
        }).toList();

        return SearchableCustomerDropdown<AccountGroup>(
          key: const ValueKey('account_group_dropdown'),
          value: controller.selectedAccountGroup,
          height: 38,
          borderColor: border,
          borderRadius: 7,
          items: filteredGroups,
          onSearch: (query) {
            setState(() {
              accountGroupSearch = query ?? '';
            });
          },
          displayString: (item) => item.name,
          onSelect: (value) {
            controller.setSelectedAccountGroup(value);

            // Clear all GST values
            gstType = '';
            gstPercentage = '';
            itcEligibility = '';
            rcmNature = '';

            // Clear selected HSN
            controller.setHsn(null);

            // Clear category margins
            for (final row in _categoryMarginRows) {
              row.dispose();
            }

            _categoryMarginRows.clear();
            _categoryMarginRows.add(_PartyCategoryMarginRow());
            setState(() {
              accountGroupSearch = '';
            });
          },
        );
      },
    ),
  );

  Widget _dealerTypeDropdown() => _fieldBlock(
    'Type of Dealer',
    SearchableCustomerDropdown<String>(
      key: const ValueKey('dealer_type_dropdown'),
      value: dealerType,
      height: 38,
      borderColor: border,
      borderRadius: 7,
      hint: 'Select dealer type',
      items: const [
        'Registered',
        'Unregistered',
        'Composition',
        'Govt. Body',
        'UIN Holder',
      ],
      onSearch: (_) {},
      displayString: (value) => value,
      onSelect: (value) {
        if (value != null) {
          setState(() => dealerType = value);
        }
      },
    ),
  );

  Widget _sectionHeader({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: primary.withValues(alpha: 0.09),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: primary, size: 18),
        ),
        const SizedBox(width: 9),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 13,
                  color: dark,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(fontSize: 10, color: muted),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _sectionCard({required Widget child}) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: white,
      borderRadius: BorderRadius.circular(11),
      border: Border.all(color: border),
    ),
    child: child,
  );

  String? _validatePartyForm() {
    if (controller.selectedAccountGroup == null) {
      return 'Please select an account group.';
    }

    if (companyController.text.trim().isEmpty) {
      return 'Company is required.';
    }

    if (nameController.text.trim().isEmpty) {
      return 'Contact person name is required.';
    }

    if (mobileController.text.trim().isEmpty) {
      return 'Mobile number is required.';
    }

    if (pincodeController.text.trim().isEmpty) {
      return 'Pincode is required.';
    }

    if (controller.selectedState == null) {
      return 'Please select a state.';
    }

    if (controller.selectedCity == null) {
      return 'Please select a city.';
    }

    if (addressController.text.trim().isEmpty) {
      return 'Address is required.';
    }

    return null;
  }

  String extractCountryId(String country) {
    return RegExp(r'\+(\d+)').firstMatch(country)?.group(1) ?? '';
  }

  Future<void> _saveParty() async {
    if (saving || loading) return;

    final validation = _validatePartyForm();

    if (validation != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(validation),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => saving = true);

    try {
      final selectedBrandIds = controller.selectedBrands
          .map((brand) => _value(brand.id))
          .where((id) => id.isNotEmpty)
          .toSet()
          .toList();

      final brandsJson = jsonEncode(
        selectedBrandIds.map(int.parse).toList(),
      );


      final selectedAccountGroup = controller.selectedAccountGroup;

      final showGstDetails = selectedAccountGroup != null &&
          (selectedAccountGroup.id == '8' ||
              selectedAccountGroup.parentGroupId == '8' ||
              selectedAccountGroup.id == '9' ||
              selectedAccountGroup.parentGroupId == '9');

      final gstApplicable = showGstDetails && gstType == 'GST Applicable';

      // Ignore empty category rows. Only selected categories are submitted.
      final categoryMargins = _categoryMarginRows
          .where((row) => row.category != null)
          .map((row) => <String, String>{
        'category_id': _value(row.category!.id),
        'mrp': row.mrp.text.trim().isEmpty ? '0' : row.mrp.text.trim(),
        'wholesale': row.wholesale.text.trim().isEmpty
            ? '0'
            : row.wholesale.text.trim(),
        'retail': row.retail.text.trim().isEmpty
            ? '0'
            : row.retail.text.trim(),
      })
          .toList();
      final categoryMarginsJson = jsonEncode(categoryMargins);

      final data = <String, dynamic>{
        'company': companyController.text.trim(),
        'print_name': printNameController.text.trim(),
        'name': nameController.text.trim(),
        'mobile': mobileController.text.trim(),
        'gst_no': gstController.text.trim(),
        'discount': discountController.text.trim(),
        'address': addressController.text.trim(),
        'pincode': pincodeController.text.trim(),
        'state_id': _value(controller.selectedState?.id),
        'city_id': _value(controller.selectedCity?.id),
        'transport_id': _value(controller.selectedTransport?.id),
        'agency_id': _value(controller.selectedAgent?.id),
        'party_type': _value(selectedAccountGroup?.id),
        'brands': brandsJson,

        'category_margins':categoryMarginsJson,

        'dealer_type': dealerType,
        'country_id': extractCountryId(countryController.text.trim()),
        'whatsapp_no': whatsappController.text.trim(),
        'email': emailController.text.trim(),
        'pan_no': panController.text.trim(),
        'aadhaar_no': aadhaarController.text.trim(),
        'remark': remarkController.text.trim(),
        'credit_days': creditDaysController.text.trim(),
        'credit_limit': creditLimitController.text.trim(),
        'opening_balance': openingBalanceController.text.trim(),
        'opening_type': openingType,
        'username': usernameController.text.trim(),
        'password': passwordController.text,
        'bank_name': bankNameController.text.trim(),
        'bank_account_no': bankAccountController.text.trim(),
        'branch': branchController.text.trim(),
        'ifsc_code': ifscController.text.trim(),

        // GST fields: always included
        'gst_type': showGstDetails ? gstType : '',
        'gst_percentage': gstApplicable ? gstPercentage.replaceAll('%', '') : '0',
        'itc_eligibility': gstApplicable ? itcEligibility : '',
        'rcm_nature': gstApplicable ? rcmNature : '',
        'hsn_code': gstApplicable
            ? (controller.selectedHsn?.hsnCode ?? '')
            : '',
      };

      final bool success;

      if (isCreate) {
        success = await controller.createParty(
          partyType: data['party_type'].toString(),
          company: data['company'].toString(),
          printName: data['print_name'].toString(),
          name: data['name'].toString(),
          mobile: data['mobile'].toString(),
          gstNo: data['gst_no'].toString(),
          discount: data['discount'].toString(),
          address: data['address'].toString(),
          pincode: data['pincode'].toString(),
          stateId: data['state_id'].toString(),
          cityId: data['city_id'].toString(),
          transportId: data['transport_id'].toString(),
          agencyId: data['agency_id'].toString(),
          brands: selectedBrandIds,
          categoryMargins: categoryMargins,
          dealerType: dealerType,
          countryId: data['country_id'].toString(),
          whatsappNo: data['whatsapp_no'].toString(),
          email: data['email'].toString(),
          panNo: data['pan_no'].toString(),
          aadhaarNo: data['aadhaar_no'].toString(),
          remark: data['remark'].toString(),
          creditDays: data['credit_days'].toString(),
          creditLimit: data['credit_limit'].toString(),
          openingBalance: data['opening_balance'].toString(),
          openingType: openingType,
          username: data['username'].toString(),
          password: data['password'].toString(),
          bankName: data['bank_name'].toString(),
          bankAccountNo: data['bank_account_no'].toString(),
          branch: data['branch'].toString(),
          ifscCode: data['ifsc_code'].toString(),

          // GST Details
          gstType: data['gst_type'].toString(),
          gstPercentage: data['gst_percentage'].toString(),
          itcEligibility: data['itc_eligibility'].toString(),
          rcmNature: data['rcm_nature'].toString(),
          hsnCode: data['hsn_code'].toString(),
        );
      } else
      {
        final partyId = _value(widget.party?.id);

        if (partyId.isEmpty) {
          throw Exception('Party ID is missing.');
        }

        data['id'] = partyId;

        success = await controller.updateParty(
          id: partyId,
          company: data['company'].toString(),
          printName: data['print_name'].toString(),
          name: data['name'].toString(),
          mobile: data['mobile'].toString(),
          gstNo: data['gst_no'].toString(),
          discount: data['discount'].toString(),
          partyType: data['party_type'].toString(),
          address: data['address'].toString(),
          pincode: data['pincode'].toString(),
          stateId: data['state_id'].toString(),
          cityId: data['city_id'].toString(),
          transportId: data['transport_id'].toString(),
          agencyId: data['agency_id'].toString(),
          brands: selectedBrandIds,
          categoryMargins: categoryMargins,
          dealerType: dealerType,
          countryId: data['country_id'].toString(),
          whatsappNo: data['whatsapp_no'].toString(),
          email: data['email'].toString(),
          panNo: data['pan_no'].toString(),
          aadhaarNo: data['aadhaar_no'].toString(),
          remark: data['remark'].toString(),
          creditDays: data['credit_days'].toString(),
          creditLimit: data['credit_limit'].toString(),
          openingBalance: data['opening_balance'].toString(),
          openingType: openingType,
          username: data['username'].toString(),
          password: data['password'].toString(),
          bankName: data['bank_name'].toString(),
          bankAccountNo: data['bank_account_no'].toString(),
          branch: data['branch'].toString(),
          ifscCode: data['ifsc_code'].toString(),

          // GST Details
          gstType: data['gst_type'].toString(),
          gstPercentage: data['gst_percentage'].toString(),
          itcEligibility: data['itc_eligibility'].toString(),
          rcmNature: data['rcm_nature'].toString(),
          hsnCode: data['hsn_code'].toString(),
        );
      }

      if (!mounted) return;

      if (!success) {
        final message = controller.updateError.trim();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              message.isNotEmpty
                  ? message
                  : isCreate
                  ? 'Failed to create party.'
                  : 'Failed to update party.',
            ),
            behavior: SnackBarBehavior.floating,
          ),
        );

        return;
      }

      final result = <String, dynamic>{
        ...data,
        if (controller.updatedParty != null) ...controller.updatedParty!,
        'brands': brandsJson,
        'category_margins': _categoryMarginRows
            .where((row) => row.category != null)
            .map((row) => <String, String>{
          'category_id': _value(row.category!.id),
          'mrp': row.mrp.text.trim().isEmpty
              ? '0'
              : row.mrp.text.trim(),
          'wholesale': row.wholesale.text.trim().isEmpty
              ? '0'
              : row.wholesale.text.trim(),
          'retail': row.retail.text.trim().isEmpty
              ? '0'
              : row.retail.text.trim(),
        })
            .toList(),
      };

      if (widget.onUpdate != null) {
        await widget.onUpdate!(result);
      }

      if (!mounted) return;

      if (widget.onSaved != null) {
        widget.onSaved!(result);
      } else {
        Navigator.of(context).pop(result);
      }
    } catch (e, stackTrace) {
      debugPrint('Party save error: $e');
      debugPrintStack(stackTrace: stackTrace);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${isCreate ? 'Create' : 'Update'} failed: $e'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => saving = false);
      }
    }
  }

  @override
  void dispose() {
    for (final textController in [
      companyController,
      printNameController,
      nameController,
      mobileController,
      gstController,
      discountController,
      addressController,
      pincodeController,
      mrpController,
      wholesaleMarginController,
      retailMarginController,
      countryController,
      whatsappController,
      emailController,
      panController,
      aadhaarController,
      remarkController,
      creditDaysController,
      creditLimitController,
      openingBalanceController,
      usernameController,
      passwordController,
      bankNameController,
      bankAccountController,
      branchController,
      ifscController,
    ]) {
      textController.dispose();
    }

    for (final row in _categoryMarginRows) {
      row.dispose();
    }

    controller.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: background,
      child: Column(
        children: [
          _buildHeader(),
          const Divider(height: 1, color: border),
          Expanded(
            child: loading
                ? const Center(
              child: CircularProgressIndicator(
                strokeWidth: 2.2,
                color: primary,
              ),
            )
                : ListenableBuilder(
              listenable: controller,
              builder: (context, _) => _buildFormContent(),
            ),
          ),
          const Divider(height: 1, color: border),
          _buildFooter(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      color: white,
      padding: const EdgeInsets.fromLTRB(16, 10, 18, 10),
      child: Row(
        children: [
          IconButton(
            onPressed: saving ? null : _cancel,
            icon: const Icon(Icons.arrow_back_rounded, color: primary),
            tooltip: 'Back',
          ),
          const SizedBox(width: 8),
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: primary.withValues(alpha: 0.09),
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(
              isCreate ? Icons.person_add_alt_1_rounded : Icons.edit_note,
              color: primary,
              size: 20,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isCreate ? 'Create Party' : 'Update Party',
                  style: const TextStyle(
                    fontSize: 15,
                    color: dark,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  isCreate
                      ? 'Add a new party to your directory'
                      : 'Update party details',
                  style: const TextStyle(fontSize: 10.5, color: muted),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormContent() {
    return LayoutBuilder(
      builder: (context, constraints) {
        const pagePadding = 14.0;
        const cardPadding = 14.0;
        const gap = 12.0;

        final availableWidth =
            constraints.maxWidth - pagePadding * 2 - cardPadding * 2;

        final columns = availableWidth >= 1100
            ? 5
            : availableWidth >= 850
            ? 4
            : availableWidth >= 650
            ? 3
            : availableWidth >= 440
            ? 2
            : 1;

        final fieldWidth =
            (availableWidth - gap * (columns - 1)) / columns;

        Widget fieldRow(List<Widget> fields) => Wrap(
          spacing: gap,
          runSpacing: 14,
          children: fields
              .map(
                (field) => SizedBox(
              width: fieldWidth,
              child: field,
            ),
          )
              .toList(),
        );

        Widget section({
          required IconData icon,
          required String title,
          required String subtitle,
          required List<Widget> fields,
        }) {
          return _sectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _sectionHeader(
                  icon: icon,
                  title: title,
                  subtitle: subtitle,
                ),
                const SizedBox(height: 16),
                fieldRow(fields),
              ],
            ),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(pagePadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              section(
                icon: Icons.business_outlined,
                title: 'Party Information',
                subtitle: 'Company, contact and account details',
                fields: [
                  _editField('Company', companyController),
                  _editField('Print Name', printNameController),
                  _accountGroupDropdown(),
                  _editField('Contact Person', nameController),
                  _editField(
                    'Mobile Number',
                    mobileController,
                    keyboardType: TextInputType.phone,
                  ),

                  if (controller.selectedAccountGroup == null ||
                      !(controller.selectedAccountGroup!.id == '8' ||
                          controller.selectedAccountGroup!.parentGroupId == '8' ||
                          controller.selectedAccountGroup!.id == '9' ||
                          controller.selectedAccountGroup!.parentGroupId == '9'))
                    _dealerTypeDropdown(),


                  if (dealerType == 'Registered' &&
                      !(controller.selectedAccountGroup?.id == '8' ||
                          controller.selectedAccountGroup?.parentGroupId == '8' ||
                          controller.selectedAccountGroup?.id == '9' ||
                          controller.selectedAccountGroup?.parentGroupId == '9'))
                    _editField('GST Number', gstController),
                  _editField(
                    'Discount (%)',
                    discountController,
                    keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                  ),
                  if (controller.selectedAccountGroup != null &&
                      (controller.selectedAccountGroup!.id == '26' ||
                          controller.selectedAccountGroup!.parentGroupId ==
                              '26'))
                    _brandMultiSelect(),
                ],
              ),
              const SizedBox(height: 14),
              if (controller.selectedAccountGroup != null &&
                  (controller.selectedAccountGroup!.id == '8' ||
                      controller.selectedAccountGroup!.parentGroupId == '8' ||
                      controller.selectedAccountGroup!.id == '9' ||
                      controller.selectedAccountGroup!.parentGroupId == '9'
                  ))
                ...[
                  _gstDetailsSection(),
                  const SizedBox(height: 14),
                ],
              section(
                icon: Icons.location_on_outlined,
                title: 'Location & Assignment',
                subtitle: 'Address, state, city and assigned contacts',
                fields: [
                  _editField('Address', addressController, maxLines: 2),
                  _countryDropdown(),
                  _stateDropdown(),
                  _cityDropdown(),
                  _editField(
                    'Pincode',
                    pincodeController,
                    keyboardType: TextInputType.number,
                  ),
                  _transportDropdown(),
                  _agentDropdown(),
                ],
              ),

              const SizedBox(height: 14),
              section(
                icon: Icons.assignment_ind_outlined,
                title: 'Dealer & Identity Details',
                subtitle: 'Dealer type and identity/contact information',
                fields: [
                  _editField(
                    'WhatsApp Number',
                    whatsappController,
                    keyboardType: TextInputType.phone,
                  ),
                  _editField(
                    'Email ID',
                    emailController,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  _editField('PAN', panController),
                  _editField(
                    'Aadhaar',
                    aadhaarController,
                    keyboardType: TextInputType.number,
                  ),
                  _editField('Remark', remarkController, maxLines: 2),
                ],
              ),
              const SizedBox(height: 14),
              section(
                icon: Icons.account_balance_wallet_outlined,
                title: 'Credit & Opening Balance',
                subtitle: 'Credit terms and opening account balance',
                fields: [
                  _editField(
                    'Credit Days',
                    creditDaysController,
                    keyboardType: TextInputType.number,
                  ),
                  _editField(
                    'Credit Limit',
                    creditLimitController,
                    keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                  ),
                  _editField(
                    'Opening Balance',
                    openingBalanceController,
                    keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                  ),
                  _choiceField(
                    label: 'Opening Type',
                    value: openingType,
                    values: const ['Debit', 'Credit'],
                    onChanged: (value) {
                      setState(() => openingType = value);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 14),
              if (controller.selectedAccountGroup != null &&
                  (controller.selectedAccountGroup!.id == '26' ||
                      controller.selectedAccountGroup!.parentGroupId == '26')) ...[
                _sectionCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _sectionHeader(
                        icon: Icons.percent_rounded,
                        title: 'Category & Margin',
                        subtitle: 'Set separate margins for each category',
                      ),
                      const SizedBox(height: 14),
                      ..._categoryMarginRows.asMap().entries.map(
                            (entry) => _categoryMarginEditor(
                          entry.value,
                          entry.key,
                        ),
                      ),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: OutlinedButton.icon(
                          onPressed:
                          saving ? null : _addCategoryMarginRow,
                          icon: const Icon(Icons.add_rounded, size: 18),
                          label: const Text('Add Category'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: primary,
                            visualDensity: VisualDensity.compact,
                            side: const BorderSide(color: primary),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                section(
                  icon: Icons.lock_outline_rounded,
                  title: 'Login Details',
                  subtitle: 'Optional party login credentials',
                  fields: [
                    _editField('User Name', usernameController),
                    _editField(
                      'Password',
                      passwordController,
                      obscureText: true,
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 14),
              section(
                icon: Icons.account_balance_outlined,
                title: 'Bank Details',
                subtitle: 'Bank account and branch information',
                fields: [
                  _editField('Bank Name', bankNameController),
                  _editField(
                    'Bank Account No.',
                    bankAccountController,
                    keyboardType: TextInputType.number,
                  ),
                  _editField('Branch', branchController),
                  _editField('IFSC Code', ifscController),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFooter() {
    return Container(
      color: white,
      padding: const EdgeInsets.fromLTRB(18, 9, 18, 9),
      child: Row(
        children: [
          Expanded(
            child: Text(
              loading
                  ? 'Loading party details...'
                  : isCreate
                  ? 'Enter party details before saving'
                  : 'Review your changes before saving',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 10.5, color: muted),
            ),
          ),
          OutlinedButton(
            onPressed: saving ? null : _cancel,
            child: const Text(
              'Cancel',
              style: TextStyle(fontSize: 12),
            ),
          ),
          const SizedBox(width: 9),
          FilledButton.icon(
            onPressed: loading || saving ? null : _saveParty,
            style: FilledButton.styleFrom(
              backgroundColor: primary,
              foregroundColor: white,
              minimumSize: const Size(140, 38),
            ),
            icon: saving
                ? const SizedBox(
              height: 14,
              width: 14,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: white,
              ),
            )
                : Icon(
              isCreate ? Icons.person_add_alt_1 : Icons.save,
              size: 16,
            ),
            label: Text(
              saving
                  ? (isCreate ? 'Creating...' : 'Saving...')
                  : (isCreate ? 'Create Party' : 'Update Party'),
              style: const TextStyle(fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // GST DETAILS
  // ============================================================

  Widget _gstTypeDropdown() {
    return _fieldBlock(
      'GST Applicability',
      SearchableCustomerDropdown<String>(
        key: const ValueKey('gst_applicability_dropdown'),
        value: gstType,
        height: 38,
        borderColor: border,
        borderRadius: 7,
        hint: 'Select GST Applicability',
        items: const [
          'GST Applicable',
          'GST Not Applicable',
        ],
        onSearch: (_) {},
        displayString: (item) => item,
        onSelect: (value) {
          if (value == null) return;

          setState(() {
            gstType = value;

            if (value == 'GST Not Applicable') {
              gstPercentage = '';
              itcEligibility = '';
              rcmNature = '';
              controller.setHsn(null);

              dealerType = 'Unregistered';
            } else {
              dealerType = 'Registered';
            }
          });
        },
      ),
    );
  }

  Widget _gstPercentageDropdown() {
    const gstPercentages = ['5%', '12%', '18%', '28%'];

    return _fieldBlock(
      'GST %',
      SearchableCustomerDropdown<String>(
        key: const ValueKey('gst_percentage_dropdown'),
        value: gstPercentages.contains(gstPercentage)
            ? gstPercentage
            : null,
        height: 38,
        borderColor: border,
        borderRadius: 7,
        hint: 'Select GST Percentage',
        items: gstPercentages,
        onSearch: (_) {},
        displayString: (item) => item,
        onSelect: (value) {
          if (value != null) {
            setState(() => gstPercentage = value);
          }
        },
      ),
    );
  }

  Widget _itcEligibilityDropdown() {
    const options = [
      'Input Goods',
      'Input Services',
      'Capital Goods',
      'Section 17(5)-ITC None',
      'Section 16(4)-ITC None',
      'ITC Restricted Due To POS Rules',
    ];

    return _fieldBlock(
      'ITC Eligibility',
      SearchableCustomerDropdown<String>(
        key: const ValueKey('gst_itc_dropdown'),
        value: options.contains(itcEligibility) ? itcEligibility : null,
        height: 38,
        borderColor: border,
        borderRadius: 7,
        hint: 'Select ITC Eligibility',
        items: options,
        onSearch: (_) {},
        displayString: (item) => item,
        onSelect: (value) {
          if (value != null) {
            setState(() => itcEligibility = value);
          }
        },
      ),
    );
  }


  Widget _hsnDropdown() {
    return _fieldBlock(
      'HSN / SAC Code',
      SearchableCustomerDropdown<HsnModel>(

        value: controller.selectedHsn,
        items: controller.filteredHsnCodes,
        // focusNode: hsnFocusNode,
        borderColor: const Color(0xffE2E8F0),
        onSearch: controller.searchHsn,
        displayString: (item) => item.hsnCode,
        onSelect: (value) {

          controller.setHsn(value);

          if (value != null) {
            // _openNextDropdown(productNameFocusNode);
          }
        },
      ),
    );
  }

  Widget _rcmNatureDropdown() {
    const options = [
      'Compulsory',
      'Service Import',
      'Based on Daily Limit',
      'Not Applicable',
    ];

    return _fieldBlock(
      'RCM Nature',
      SearchableCustomerDropdown<String>(
        key: const ValueKey('gst_rcm_dropdown'),
        value: options.contains(rcmNature) ? rcmNature : null,
        height: 38,
        borderColor: border,
        borderRadius: 7,
        hint: 'Select RCM Nature',
        items: options,
        onSearch: (_) {},
        displayString: (item) => item,
        onSelect: (value) {
          if (value != null) {
            setState(() => rcmNature = value);
          }
        },
      ),
    );
  }

  Widget _gstDetailsSection() {
    final gstApplicable = gstType == 'GST Applicable';

    return _sectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader(
            icon: Icons.receipt_long_outlined,
            title: 'GST Details',
            subtitle: 'GST registration and tax configuration',
          ),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, constraints) {
              final columns = constraints.maxWidth >= 800
                  ? 3
                  : constraints.maxWidth >= 480
                  ? 2
                  : 1;

              const gap = 12.0;

              final width =
                  (constraints.maxWidth - gap * (columns - 1)) / columns;

              return Wrap(
                spacing: gap,
                runSpacing: 14,
                children: [
                  SizedBox(
                    width: width,
                    child: _gstTypeDropdown(),
                  ),
                  if (gstApplicable) ...[

                    SizedBox(
                      width: width,
                      child: _gstPercentageDropdown(),
                    ),
                    SizedBox(
                      width: width,
                      child: _hsnDropdown(),
                    ),
                    SizedBox(
                      width: width,
                      child: _itcEligibilityDropdown(),
                    ),
                    SizedBox(
                      width: width,
                      child: _rcmNatureDropdown(),
                    ),
                  ],
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
