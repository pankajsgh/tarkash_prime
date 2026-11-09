part of 'sale_invoice_page.dart';

class CreateCustomerDialog extends StatefulWidget {
  const CreateCustomerDialog({
    super.key,
  });

  @override
  State<CreateCustomerDialog> createState() =>
      _CreateCustomerDialogState();
}

class _CreateCustomerDialogState
    extends State<CreateCustomerDialog> {

  static const Color primary = Color(0xff1557B0);
  static const Color background = Color(0xffF5F7FB);
  static const Color border = Color(0xffE1E6EF);
  static const Color textDark = Color(0xff172033);
  static const Color textGrey = Color(0xff697386);

  final customerNameController = TextEditingController();
  final mobileController = TextEditingController();
  final addressController = TextEditingController();
  final pincodeController = TextEditingController();

  final companyNameController = TextEditingController();
  final gstController = TextEditingController();
  final panController = TextEditingController();
  final aadharController = TextEditingController();

  String customerType = 'B2B';

  String selectedState = 'Uttar Pradesh';
  String selectedCity = 'New Delhi';
  String selectedAgent = 'Select Agent';
  String selectedMembership = 'Silver';

  @override
  void dispose() {
    customerNameController.dispose();
    mobileController.dispose();
    addressController.dispose();
    pincodeController.dispose();

    companyNameController.dispose();
    gstController.dispose();
    panController.dispose();
    aadharController.dispose();



    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(
        horizontal: 45,
        vertical: 30,
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: 1180,
          maxHeight: 850,
        ),
        child: Material(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          clipBehavior: Clip.antiAlias,
          elevation: 18,
          child: Column(
            children: [
              _buildHeader(),

              Expanded(
                child: Container(
                  color: background,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(
                      28,
                      26,
                      28,
                      24,
                    ),
                    child: Column(
                      crossAxisAlignment:
                      CrossAxisAlignment.start,
                      children: [
                        _buildCustomerSection(),

                        const SizedBox(height: 20),

                        _buildCompanySection(),
                      ],
                    ),
                  ),
                ),
              ),

              _buildFooter(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      height: 76,
      padding: const EdgeInsets.symmetric(horizontal: 26),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            primaryAppColor,
            primaryPurpleDark,
          ],
        ),
      ),
      child: Row(
        children: [

          // Icon
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(.13),
              borderRadius: BorderRadius.circular(11),
            ),
            child: const Icon(
              Icons.person_add_alt_1_rounded,
              color: Colors.white,
              size: 23,
            ),
          ),

          const SizedBox(width: 14),

          // Title
          const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Create New Customer',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -.2,
                ),
              ),

              SizedBox(height: 3),

              Text(
                'Add customer and business information',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),

          const Spacer(),

          // Close
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(10),
              onTap: () {
                Navigator.pop(context);
              },
              child: Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(.10),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.close_rounded,
                  color: Colors.white,
                  size: 21,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomerSection() {
    return _sectionCard(
      icon: Icons.person_outline_rounded,
      title: 'Customer Details',
      subtitle: 'Basic information about the customer',
      child: Column(
        children: [

          Row(
            children: [
              const Text(
                'Customer Type',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: textGrey,
                ),
              ),

              const SizedBox(width: 16),

              _buildCustomerTypeSelector(),
            ],
          ),

          const SizedBox(height: 25),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              Expanded(
                child: _buildTextField(
                  label: 'Customer Name',
                  hint: 'Enter customer name',
                  controller: customerNameController,
                  icon: Icons.person_outline_rounded,
                  required: true,
                ),
              ),

              const SizedBox(width: 18),

              Expanded(
                child: _buildTextField(
                  label: 'Mobile Number',
                  hint: 'Enter mobile number',
                  controller: mobileController,
                  icon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                  required: true,
                ),
              ),

              const SizedBox(width: 18),

              Expanded(
                child: _buildTextField(
                  label: 'Address',
                  hint: 'Enter address',
                  controller: addressController,
                  icon: Icons.location_on_outlined,
                ),
              ),
            ],
          ),

          const SizedBox(height: 19),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              Expanded(
                child: _buildDropdown(
                  label: 'Place of Supply',
                  value: selectedState,
                  icon: Icons.map_outlined,
                  items: const [
                    'Uttar Pradesh',
                    'Delhi',
                    'Haryana',
                    'Rajasthan',
                    'Maharashtra',
                    'Gujarat',
                  ],
                  onChanged: (value) {
                    setState(() {
                      selectedState = value!;
                    });
                  },
                ),
              ),

              const SizedBox(width: 18),

              Expanded(
                child: _buildDropdown(
                  label: 'City',
                  value: selectedCity,
                  icon: Icons.location_city_outlined,
                  items: const [
                    'New Delhi',
                    'Noida',
                    'Ghaziabad',
                    'Lucknow',
                    'Kanpur',
                  ],
                  onChanged: (value) {
                    setState(() {
                      selectedCity = value!;
                    });
                  },
                ),
              ),

              const SizedBox(width: 18),

              Expanded(
                child: _buildTextField(
                  label: 'Pincode',
                  hint: 'Enter pincode',
                  controller: pincodeController,
                  icon: Icons.markunread_mailbox_outlined,
                  keyboardType: TextInputType.number,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCompanySection() {
    return _sectionCard(
      icon: Icons.business_outlined,
      title: 'Company Details',
      subtitle: 'Business and registration information',
      child: Column(
        children: [

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              Expanded(
                child: _buildTextField(
                  label: 'Company Name',
                  hint: 'Enter company name',
                  controller: companyNameController,
                  icon: Icons.business_outlined,
                ),
              ),

              const SizedBox(width: 18),

              Expanded(
                child: _buildTextField(
                  label: 'GST Number',
                  hint: 'Enter GST number',
                  controller: gstController,
                  icon: Icons.receipt_long_outlined,
                ),
              ),

              const SizedBox(width: 18),

              Expanded(
                child: _buildTextField(
                  label: 'PAN Number',
                  hint: 'Enter PAN number',
                  controller: panController,
                  icon: Icons.credit_card_outlined,
                ),
              ),
            ],
          ),

          const SizedBox(height: 19),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              Expanded(
                child: _buildTextField(
                  label: 'Aadhaar Number',
                  hint: 'Enter Aadhaar number',
                  controller: aadharController,
                  icon: Icons.badge_outlined,
                  keyboardType: TextInputType.number,
                ),
              ),

              const SizedBox(width: 18),

              Expanded(
                child: _buildDropdown(
                  label: 'Agent',
                  value: selectedAgent,
                  icon: Icons.support_agent_outlined,
                  items: const [
                    'Select Agent',
                    'Agent 1',
                    'Agent 2',
                    'Agent 3',
                  ],
                  onChanged: (value) {
                    setState(() {
                      selectedAgent = value!;
                    });
                  },
                ),
              ),

              const SizedBox(width: 18),

              Expanded(
                child: _buildDropdown(
                  label: 'Membership',
                  value: selectedMembership,
                  icon: Icons.workspace_premium_outlined,
                  items: const [
                    'Silver',
                    'Gold',
                    'Platinum',
                  ],
                  onChanged: (value) {
                    setState(() {
                      selectedMembership = value!;
                    });
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _sectionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(
        22,
        19,
        22,
        22,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(
          color: border,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.025),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          Row(
            children: [

              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: primary.withOpacity(.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  color: primary,
                  size: 20,
                ),
              ),

              const SizedBox(width: 12),

              Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: textDark,
                    ),
                  ),

                  const SizedBox(height: 2),

                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: textGrey,
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 20),

          Container(
            height: 1,
            color: const Color(0xffEEF1F5),
          ),

          const SizedBox(height: 21),

          child,
        ],
      ),
    );
  }

  Widget _buildCustomerTypeSelector() {
    return Container(
      height: 40,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: const Color(0xffF0F3F8),
        borderRadius: BorderRadius.circular(9),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _customerTypeButton(
            'B2C',
            Icons.person_outline,
          ),
          _customerTypeButton(
            'B2B',
            Icons.business_outlined,
          ),
        ],
      ),
    );
  }

  Widget _customerTypeButton(
      String title,
      IconData icon,
      ) {
    final bool selected = customerType == title;

    return GestureDetector(
      onTap: () {
        setState(() {
          customerType = title;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        height: 34,
        padding: const EdgeInsets.symmetric(
          horizontal: 18,
        ),
        decoration: BoxDecoration(
          color: selected
              ? Colors.white
              : Colors.transparent,
          borderRadius: BorderRadius.circular(7),
          boxShadow: selected
              ? [
            BoxShadow(
              color: Colors.black.withOpacity(.07),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ]
              : null,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 16,
              color: selected
                  ? primary
                  : textGrey,
            ),

            const SizedBox(width: 7),

            Text(
              title,
              style: TextStyle(
                fontSize: 13,
                fontWeight: selected
                    ? FontWeight.w700
                    : FontWeight.w500,
                color: selected
                    ? primary
                    : textGrey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required String hint,
    required TextEditingController controller,
    required IconData icon,
    bool required = false,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        _fieldLabel(
          label,
          required: required,
        ),

        const SizedBox(height: 7),

        SizedBox(
          height: 44,
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            style: const TextStyle(
              fontSize: 13.5,
              color: textDark,
              fontWeight: FontWeight.w500,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(
                color: Color(0xffA3ACBB),
                fontSize: 13.5,
                fontWeight: FontWeight.w400,
              ),
              prefixIcon: Icon(
                icon,
                size: 18,
                color: const Color(0xff8A94A6),
              ),
              filled: true,
              fillColor: const Color(0xffFBFCFE),
              contentPadding:
              const EdgeInsets.symmetric(
                horizontal: 12,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(
                  color: border,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(
                  color: primary,
                  width: 1.3,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown({
    required String label,
    required String value,
    required IconData icon,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        _fieldLabel(label),

        const SizedBox(height: 7),

        SizedBox(
          height: 44,
          child: DropdownButtonFormField<String>(
            initialValue: value,
            isExpanded: true,
            icon: const Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 20,
              color: Color(0xff667085),
            ),
            style: const TextStyle(
              fontSize: 13.5,
              color: textDark,
              fontWeight: FontWeight.w500,
            ),
            decoration: InputDecoration(
              prefixIcon: Icon(
                icon,
                size: 18,
                color: const Color(0xff8A94A6),
              ),
              filled: true,
              fillColor: const Color(0xffFBFCFE),
              contentPadding:
              const EdgeInsets.symmetric(
                horizontal: 12,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(
                  color: border,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(
                  color: primary,
                  width: 1.3,
                ),
              ),
            ),
            items: items.map(
                  (item) {
                return DropdownMenuItem<String>(
                  value: item,
                  child: Text(
                    item,
                    overflow: TextOverflow.ellipsis,
                  ),
                );
              },
            ).toList(),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  Widget _fieldLabel(
      String title, {
        bool required = false,
      }) {
    return RichText(
      text: TextSpan(
        text: title,
        style: const TextStyle(
          fontSize: 12.5,
          fontWeight: FontWeight.w600,
          color: textDark,
        ),
        children: required
            ? const [
          TextSpan(
            text: ' *',
            style: TextStyle(
              color: Color(0xffE53935),
            ),
          ),
        ]
            : null,
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      height: 72,
      padding: const EdgeInsets.symmetric(
        horizontal: 28,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(
            color: Color(0xffE8ECF2),
          ),
        ),
      ),
      child: Row(
        children: [

          const Icon(
            Icons.info_outline_rounded,
            size: 17,
            color: Color(0xff8A94A6),
          ),

          const SizedBox(width: 8),

          const Text(
            'Fields marked with * are required',
            style: TextStyle(
              fontSize: 11.5,
              color: textGrey,
            ),
          ),

          const Spacer(),

          // Cancel
          OutlinedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(100, 42),
              side: const BorderSide(
                color: border,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              foregroundColor: textDark,
            ),
            child: const Text(
              'Cancel',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          const SizedBox(width: 10),

          // Create
          ElevatedButton.icon(
            onPressed: _createCustomer,
            icon: const Icon(
              Icons.person_add_alt_1_rounded,
              size: 17,
            ),
            label: const Text(
              'Create Customer',
            ),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(165, 42),
              backgroundColor: primary,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              textStyle: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _createCustomer() {
    if (customerNameController.text.trim().isEmpty) {
      _showError('Please enter customer name');
      return;
    }

    if (mobileController.text.trim().isEmpty) {
      _showError('Please enter mobile number');
      return;
    }

    // Your API / GetX controller call here.

    debugPrint(
      'Creating customer: '
          '${customerNameController.text}',
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
