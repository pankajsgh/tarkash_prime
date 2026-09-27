import 'package:flutter/material.dart';

import 'package:calculation_panel/core/database/local_store_manager.dart';
import 'package:calculation_panel/core/theme/colors.dart';
import 'package:calculation_panel/core/vars/global_vars.dart';
import 'package:calculation_panel/features/dashboard/presentaion/erp_top_header.dart';
import 'package:calculation_panel/features/purchase_challan/controller/purchase_controller.dart';
import 'package:calculation_panel/features/purchase_challan/model/product_model.dart';
import 'package:calculation_panel/features/purchase_challan/representaion/extra_charge/extra_charge_view.dart';
import 'package:calculation_panel/features/purchase_challan/representaion/product_selection_section/product_selection_section.dart';
import 'package:calculation_panel/features/purchase_challan/representaion/supplier_header/model/supplier_model.dart';
import 'package:calculation_panel/features/purchase_challan/representaion/supplier_header/supplier_header.dart';

import '../../components/custome_dropdown_widget.dart';

class PurchasePage extends StatefulWidget {
  const PurchasePage({super.key});

  @override
  State<PurchasePage> createState() => _PurchasePageState();
}

class _PurchasePageState extends State<PurchasePage>
    with WidgetsBindingObserver {
  late final PurchaseController purchaseController;

  bool _isSavingOnClose = false;

  @override
  void initState() {
    super.initState();

    GlobalVars.globalRoutes = "/purchasePage";

    purchaseController = PurchaseController();
    purchaseController.getAgentList('');

    // Add first empty item.
    if (purchaseController.items.isEmpty) {
      purchaseController.addItem();
    }

    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.detached) {
      onAppClose();
    }
  }

  Future<void> onAppClose() async {
    if (_isSavingOnClose) {
      return;
    }

    final supplier = purchaseController.selectSupplier;

    if (supplier == null) {
      return;
    }

    if (purchaseController.items.isEmpty) {
      return;
    }

    _isSavingOnClose = true;

    try {
      final data = purchaseController.toDataMap();

      await ChallanCartStorage.save(
        data,
        supplier.id,
      );
    } catch (e) {
      debugPrint('Purchase auto-save error: $e');
    } finally {
      _isSavingOnClose = false;
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    purchaseController.dispose();
    super.dispose();
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5F7FB),
      body: SafeArea(
        child: _buildWorkspace(),
      ),
    );
  }

  // ============================================================
  // WORKSPACE
  // ============================================================

  Widget _buildWorkspace() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 12,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPageHeader(),

          const SizedBox(height: 12),

          ListenableBuilder(
            listenable: purchaseController,
            builder: (context, _) {
              return SupplierHeader(
                purchaseController: purchaseController,
              );
            },
          ),

          const SizedBox(height: 16),

          ProductSelectionSection(
            controller: purchaseController,
          ),

          const SizedBox(height: 16),

          ListenableBuilder(
            listenable: purchaseController,
            builder: (context, _) {
              return _buildBottomCards();
            },
          ),
        ],
      ),
    );
  }

  // ============================================================
  // PAGE HEADER
  // ============================================================

  Widget _buildPageHeader() {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 850) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Expanded(
                    child: _PageBreadcrumb(),
                  ),
                  _statusBadge(),
                ],
              ),

              const SizedBox(height: 10),

              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _saveDraftBadge(),
                    const SizedBox(width: 8),
                    _getDraftList(),
                    const SizedBox(width: 8),
                    _resetButton(),
                  ],
                ),
              ),
            ],
          );
        }

        return Row(
          children: [
            const _PageBreadcrumb(),

            const SizedBox(width: 10),

            _statusBadge(),

            const Spacer(),

            _saveDraftBadge(),

            const SizedBox(width: 8),

            _getDraftList(),

            const SizedBox(width: 10),

            _resetButton(),
          ],
        );
      },
    );
  }

  // ============================================================
  // RESET BUTTON
  // ============================================================

  Widget _resetButton() {
    return OutlinedButton.icon(
      onPressed: () {
        purchaseController.clearAll();
      },
      icon: const Icon(
        Icons.refresh_rounded,
        size: 16,
      ),
      label: const Text(
        'Reset',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
      style: OutlinedButton.styleFrom(
        foregroundColor: const Color(0xff475569),
        side: const BorderSide(
          color: Color(0xffD7DEE8),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 7,
        ),
        minimumSize: const Size(0, 34),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        visualDensity: VisualDensity.compact,
      ),
    );
  }

  // ============================================================
  // STATUS
  // ============================================================

  Widget _statusBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 11,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: const Color(0xffFFF7ED),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xffFED7AA),
        ),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.circle,
            size: 7,
            color: Color(0xffF97316),
          ),
          SizedBox(width: 6),
          Text(
            'Draft',
            style: TextStyle(
              color: Color(0xffC2410C),
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // SAVE DRAFT VALIDATION
  // ============================================================

  bool _validateBeforeDraft() {
    if (purchaseController.selectSupplier == null) {
      _showSnackBar(
        'Please select a supplier',
        isError: true,
      );
      return false;
    }

    if (purchaseController.items.isEmpty) {
      _showSnackBar(
        'No product added',
        isError: true,
      );
      return false;
    }

    final hasProduct = purchaseController.items.any(
          (item) => item.product != null,
    );

    if (!hasProduct) {
      _showSnackBar(
        'No product added',
        isError: true,
      );
      return false;
    }

    return true;
  }

  // ============================================================
  // SAVE DRAFT BADGE
  // ============================================================

  Widget _saveDraftBadge() {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () {
        if (!_validateBeforeDraft()) {
          return;
        }

        showDateNamePopup(context);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 5,
        ),
        decoration: BoxDecoration(
          color: const Color(0xffF0FDF4),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: const Color(0xffBBF7D0),
          ),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.circle,
              size: 8,
              color: Color(0xff46B657),
            ),
            SizedBox(width: 7),
            Text(
              'Save as hold',
              style: TextStyle(
                color: Color(0xff46B657),
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // SAVE DRAFT POPUP
  // ============================================================

  Future<void> showDateNamePopup(BuildContext context) async {
    final supplier = purchaseController.selectSupplier;

    if (supplier == null) {
      _showSnackBar(
        'Please select a supplier',
        isError: true,
      );
      return;
    }

    DraftModel? draftList;

    try {
      draftList = await ChallanCartStorage.getDraft(
        supplier.id,
      );
    } catch (e) {
      debugPrint('Get draft error: $e');
    }

    final List<String> previousDraftNames = List<String>.from(
      draftList?.draftName ?? <String>[],
    );

    if (!context.mounted) {
      return;
    }

    await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return _SaveDraftDialog(
          existingDraftNames: previousDraftNames,
          onSave: (draftName) async {
            final trimmedName = draftName.trim();

            if (trimmedName.isEmpty) {
              return false;
            }

            try {
              final alreadyExists =
              previousDraftNames.contains(trimmedName);

              final updatedDraftNames =
              List<String>.from(previousDraftNames);

              if (!alreadyExists) {
                updatedDraftNames.add(trimmedName);
              }

              final draftData = DraftModel(
                partyId: supplier.id,
                draftName: updatedDraftNames,
              );

              // Save draft names.
              await ChallanCartStorage.saveDraft(
                draftData,
              );

              // Save actual purchase data.
              await ChallanCartStorage.save(
                purchaseController.toDataMap(),
                '${supplier.id}_$trimmedName',
              );

              return true;
            } catch (e) {
              debugPrint('Save draft error: $e');
              return false;
            }
          },
        );
      },
    );
  }

  // ============================================================
  // DRAFT LIST POPUP
  // ============================================================

  Future<String?> showDraftPopup(BuildContext context) async {
    final supplier = purchaseController.selectSupplier;

    if (supplier == null) {
      _showSnackBar(
        'Please select a supplier',
        isError: true,
      );
      return null;
    }

    DraftModel? draftList;

    try {
      draftList = await ChallanCartStorage.getDraft(
        supplier.id,
      );
    } catch (e) {
      debugPrint('Get draft list error: $e');
    }

    if (!context.mounted) {
      return null;
    }

    final List<String> draftNames = List<String>.from(
      draftList?.draftName ?? <String>[],
    );

    if (draftNames.isEmpty) {
      _showSnackBar(
        'No saved drafts found',
        isError: true,
      );
      return null;
    }

    return showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return _DraftListDialog(
          draftNames: draftNames,
          onSelect: (draftName) {
            purchaseController.getDraftData(
              draftName,
            );
          },
          onDelete: (draftName) async {
            try {
              await purchaseController.deleteDraftItem(
                partyId: supplier.id,
                draftId: draftName,
              );

              return true;
            } catch (e) {
              debugPrint('Delete draft error: $e');
              return false;
            }
          },
        );
      },
    );
  }

  // ============================================================
  // HOLD DRAFT BUTTON
  // ============================================================

  Widget _getDraftList() {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () {
        if (purchaseController.selectSupplier == null) {
          _showSnackBar(
            'Please select a supplier first',
            isError: true,
          );
          return;
        }

        showDraftPopup(context);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 5,
        ),
        decoration: BoxDecoration(
          color: const Color(0xffFFF7ED),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: const Color(0xffFED7AA),
          ),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Hold drafts',
              style: TextStyle(
                color: Color(0xffB66D46),
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(width: 5),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 15,
              color: Color(0xffB66D46),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // BOTTOM CARDS
  // ============================================================

  Widget _buildBottomCards() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;

        // --------------------------------------------------------
        // MOBILE
        // --------------------------------------------------------

        if (width < 600) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildDetailsCard(),

              const SizedBox(height: 12),

              _buildLogisticsCard(),

              const SizedBox(height: 12),

              ExtraChargeView(
                purchaseController: purchaseController,
              ),

              const SizedBox(height: 12),

              _buildSummaryCard(),
            ],
          );
        }

        // --------------------------------------------------------
        // TABLET / SMALL DESKTOP
        // --------------------------------------------------------

        if (width < 1200) {
          return Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _buildLogisticsCard(),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildDetailsCard(),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 6,
                    child: ExtraChargeView(
                      purchaseController: purchaseController,
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    flex: 3,
                    child: _buildSummaryCard(),
                  ),
                ],
              ),
            ],
          );
        }

        // --------------------------------------------------------
        // LARGE DESKTOP
        // --------------------------------------------------------

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: _buildLogisticsCard(),
            ),

            const SizedBox(width: 12),

            Expanded(
              flex: 3,
              child: _buildDetailsCard(),
            ),

            const SizedBox(width: 12),

            Expanded(
              flex: 7,
              child: ExtraChargeView(
                purchaseController: purchaseController,
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              flex: 3,
              child: _buildSummaryCard(),
            ),
          ],
        );
      },
    );
  }

  // ============================================================
  // DETAILS CARD
  // ============================================================

  Widget _buildDetailsCard() {
    return _card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionTitle(
              Icons.notes_rounded,
              'Additional Details',
            ),

            const SizedBox(height: 10),

            const Text(
              'Remark',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Color(0xff475569),
              ),
            ),

            const SizedBox(height: 6),

            TextField(
              controller: purchaseController.remarkController,
              maxLines: 2,
              minLines: 2,
              style: const TextStyle(
                fontSize: 12,
                color: textDark,
              ),
              decoration: _inputDecoration(
                'Add a remark...',
              ),
            ),

            const SizedBox(height: 12),

            Row(
              children: [
                const Icon(
                  Icons.attach_file_rounded,
                  size: 17,
                  color: Color(0xff64748B),
                ),

                const SizedBox(width: 7),

                const Text(
                  'Attachment',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Color(0xff475569),
                  ),
                ),

                const Spacer(),

                OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(
                    Icons.upload_file_rounded,
                    size: 14,
                  ),
                  label: const Text(
                    'Choose File',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: blue,
                    minimumSize: const Size(100, 30),
                    fixedSize: const Size(100, 30),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                    ),
                    side: const BorderSide(
                      color: Color(0xffBFDBFE),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                    tapTargetSize:
                    MaterialTapTargetSize.shrinkWrap,
                    visualDensity: VisualDensity.compact,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // LOGISTICS CARD
  // ============================================================

  Widget _buildLogisticsCard() {
    return _card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionTitle(
              Icons.local_shipping_outlined,
              'Logistics',
            ),

            const SizedBox(height: 10),

            _fieldBlock(
              'Agent',
              _buildAgentDropdown(),
            ),

            const SizedBox(height: 10),

            Row(
              children: [
                Expanded(
                  child: _fieldBlock(
                    'LR Number',
                    _textField(
                      purchaseController.lrNoController,
                      hint: 'LR No',
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: _fieldBlock(
                    'LR Date',
                    _dateField(
                      controller:
                      purchaseController.lrDateController,
                      onTap: () {
                        purchaseController.selectLrDate(
                          context,
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // AGENT DROPDOWN
  // ============================================================

  Widget _buildAgentDropdown() {

    return SearchableCustomerDropdown<Agency>(
      value: purchaseController.selectedAgent,
      height: 36,
      borderColor: Colors.grey.shade300,
      borderRadius: 8,
      items: purchaseController.agents,
      onSearch: (value) {},
      displayString: (item) {
        return item.name ?? '';
      },
      onSelect: (value) {
        purchaseController.setAgent(value);
      },
    );
  }

  // ============================================================
  // SUMMARY CARD
  // ============================================================

  Widget _buildSummaryCard() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xff172B4D),
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(
            color: Color(0x18000000),
            blurRadius: 18,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: ListenableBuilder(
        listenable: purchaseController.updateSummery,
        builder: (context, _) {
          final supplier = purchaseController.selectSupplier;

          final bool isInterState =
              supplier != null &&
                  supplier.state.id != GlobalVars.placeOfSupplyId;

          return Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --------------------------------------------------
                // TITLE
                // --------------------------------------------------

                Row(
                  children: [
                    const Icon(
                      Icons.receipt_long_rounded,
                      color: Colors.white,
                      size: 19,
                    ),

                    const SizedBox(width: 8),

                    const Text(
                      'Bill Summary',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                    ),

                    const Spacer(),

                    Text(
                      'Qty: ${purchaseController.totalQuantity}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 13),

                // --------------------------------------------------
                // VALUES
                // --------------------------------------------------

                _summaryRow(
                  'Value of Goods',
                  purchaseController.getTotalGoodsValue,
                ),

                _summaryRow(
                  'Additional Discount',
                  purchaseController.additionalDiscountTotal ?? 0,
                ),

                _summaryRow(
                  'Taxable Amount',
                  purchaseController.valueOfTaxableGoods(),
                ),

                if (isInterState) ...[
                  _summaryRow(
                    'IGST',
                    purchaseController.igst,
                  ),
                ] else ...[
                  _summaryRow(
                    'SGST',
                    purchaseController.sgst,
                  ),

                  _summaryRow(
                    'CGST',
                    purchaseController.cgst,
                  ),
                ],

                _summaryRow(
                  'Additional Charges',
                  purchaseController.additionalCharge,
                ),

                if (purchaseController.finalDiscount > 0)
                  _summaryRow(
                    'Final Discount',
                    purchaseController.finalDiscount,
                  ),

                const Padding(
                  padding: EdgeInsets.symmetric(
                    vertical: 4,
                  ),
                  child: Divider(
                    color: Color(0x33FFFFFF),
                    height: 1,
                  ),
                ),

                // --------------------------------------------------
                // GRAND TOTAL
                // --------------------------------------------------

                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Grand Total',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ),

                    Text(
                      '₹ ${purchaseController.grandTotal.toStringAsFixed(2)}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 13),

                // --------------------------------------------------
                // GENERATE CHALLAN
                // --------------------------------------------------

                SizedBox(
                  width: double.infinity,
                  height: 42,
                  child: ElevatedButton.icon(
                    onPressed: purchaseController.isSubmitting
                        ? null
                        : _submitChallan,
                    icon: purchaseController.isSubmitting
                        ? const SizedBox(
                      width: 17,
                      height: 17,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                        : const Icon(
                      Icons.check_circle_outline_rounded,
                      size: 18,
                    ),
                    label: Text(
                      purchaseController.isSubmitting
                          ? 'Generating...'
                          : 'Generate Challan',
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                      const Color(0xff3B82F6),
                      disabledBackgroundColor:
                      const Color(0xff3B82F6),
                      foregroundColor: Colors.white,
                      disabledForegroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // ============================================================
  // SUBMIT CHALLAN
  // ============================================================

  void _submitChallan() {
    if (purchaseController.isSubmitting) {
      return;
    }

    // ----------------------------------------------------------
    // SUPPLIER
    // ----------------------------------------------------------

    if (purchaseController.selectSupplier == null) {
      _showSnackBar(
        'Please select a supplier',
        isError: true,
      );
      return;
    }

    if (purchaseController.challanNo.trim().isEmpty) {
      _showSnackBar(
        'Please Enter challan No',
        isError: true,
      );
      return;
    }

    if (purchaseController.selectedData.trim().isEmpty) {
      _showSnackBar(
        'Please Select date',
        isError: true,
      );
      return;
    }

    // ----------------------------------------------------------
    // ITEMS
    // ----------------------------------------------------------

    if (purchaseController.items.isEmpty) {
      _showSnackBar(
        'No product added',
        isError: true,
      );
      return;
    }

    // ----------------------------------------------------------
    // VALIDATE EVERY PRODUCT
    // ----------------------------------------------------------

    for (int index = 0;
    index < purchaseController.items.length;
    index++) {
      final item = purchaseController.items[index];

      if (item.product == null) {
        _showSnackBar(
          'Please select product for item ${index + 1}',
          isError: true,
        );
        return;
      }

      if (item.product!.color == null) {
        _showSnackBar(
          'Please select color for item ${index + 1}',
          isError: true,
        );
        return;
      }

      if (item.product!.size == null) {
        _showSnackBar(
          'Please select size for item ${index + 1}',
          isError: true,
        );
        return;
      }

      if (item.productPrice == null ||
          item.productPrice! <= 0) {
        _showSnackBar(
          'Please enter amount for item ${index + 1}',
          isError: true,
        );
        return;
      }
    }

    purchaseController.submitChallan();
  }

  // ============================================================
  // SUMMARY ROW
  // ============================================================

  Widget _summaryRow(
      String title,
      double value,
      ) {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: 5,
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 11,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),

          const SizedBox(width: 10),

          Text(
            '₹ ${value.toStringAsFixed(2)}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // SECTION TITLE
  // ============================================================

  Widget _sectionTitle(
      IconData icon,
      String title,
      ) {
    return Row(
      children: [
        Container(
          height: 26,
          width: 26,
          decoration: BoxDecoration(
            color: const Color(0xffEAF2FF),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 14,
            color: blue,
          ),
        ),

        const SizedBox(width: 9),

        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xff1E293B),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // CARD
  // ============================================================

  Widget _card({
    required Widget child,
  }) {
    return Container(
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
      child: child,
    );
  }

  // ============================================================
  // FIELD BLOCK
  // ============================================================

  Widget _fieldBlock(
      String label,
      Widget field,
      ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: Color(0xff475569),
          ),
        ),

        const SizedBox(height: 5),

        field,
      ],
    );
  }

  // ============================================================
  // TEXT FIELD
  // ============================================================

  Widget _textField(
      TextEditingController textController, {
        String? hint,
        IconData? prefix,
      }) {
    return SizedBox(
      height: 34,
      child: TextField(
        controller: textController,
        decoration: _inputDecoration(
          hint,
          prefix: prefix,
        ),
        style: const TextStyle(
          fontSize: 12,
          color: textDark,
        ),
      ),
    );
  }

  // ============================================================
  // DATE FIELD
  // ============================================================

  Widget _dateField({
    required TextEditingController controller,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      height: 34,
      child: TextField(
        controller: controller,
        readOnly: true,
        onTap: onTap,
        decoration: _inputDecoration(
          'Select date',
          prefix: Icons.calendar_today_outlined,
        ),
        style: const TextStyle(
          fontSize: 12,
          color: textDark,
        ),
      ),
    );
  }

  // ============================================================
  // DROPDOWN
  // ============================================================

  Widget _dropdown({
    required String? value,
    required String hint,
    required List<String> items,
    required ValueChanged<String?> onChanged,
    IconData? prefix,
  }) {
    final uniqueItems = items.toSet().toList();

    final selectedValue =
    uniqueItems.contains(value) ? value : null;

    return SizedBox(
      height: 39,
      child: DropdownButtonFormField<String>(
        initialValue: selectedValue,
        isExpanded: true,
        icon: const Icon(
          Icons.keyboard_arrow_down_rounded,
          size: 18,
          color: textLight,
        ),
        decoration: _inputDecoration(
          hint,
          prefix: prefix,
        ),
        style: const TextStyle(
          fontSize: 12,
          color: textDark,
        ),
        dropdownColor: Colors.white,
        borderRadius: BorderRadius.circular(10),
        items: uniqueItems.map(
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
    );
  }

  // ============================================================
  // INPUT DECORATION
  // ============================================================

  InputDecoration _inputDecoration(
      String? hint, {
        IconData? prefix,
      }) {
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
        size: 16,
        color: textLight,
      ),
      prefixIconConstraints: prefix == null
          ? null
          : const BoxConstraints(
        minWidth: 36,
        minHeight: 36,
      ),
      filled: true,
      fillColor: const Color(0xffF8FAFC),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 8,
      ),
      isDense: true,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(
          color: borderColor,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(
          color: borderColor,
        ),
      ),
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
  // SNACKBAR
  // ============================================================

  void _showSnackBar(
      String message, {
        bool isError = false,
      }) {
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          backgroundColor:
          isError ? Colors.red : Colors.green,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          duration: const Duration(
            seconds: 2,
          ),
          content: Text(
            message,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      );
  }
}

// ============================================================================
// PAGE BREADCRUMB
// ============================================================================

class _PageBreadcrumb extends StatelessWidget {
  const _PageBreadcrumb();

  @override
  Widget build(BuildContext context) {
    return const Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Purchase',
          style: TextStyle(
            fontSize: 13,
            color: textMedium,
          ),
        ),

        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: 7,
          ),
          child: Icon(
            Icons.chevron_right_rounded,
            size: 16,
            color: textLight,
          ),
        ),

        Text(
          'Create Challan',
          style: TextStyle(
            fontSize: 13,
            color: textDark,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

// ============================================================================
// SAVE DRAFT DIALOG
// ============================================================================

class _SaveDraftDialog extends StatefulWidget {
  final List<String> existingDraftNames;

  final Future<bool> Function(
      String draftName,
      ) onSave;

  const _SaveDraftDialog({
    required this.existingDraftNames,
    required this.onSave,
  });

  @override
  State<_SaveDraftDialog> createState() =>
      _SaveDraftDialogState();
}

class _SaveDraftDialogState
    extends State<_SaveDraftDialog> {
  late final TextEditingController _controller;

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _controller.removeListener(_onTextChanged);
    _controller.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  bool get _isExist {
    final name = _controller.text.trim();

    if (name.isEmpty) {
      return false;
    }

    return widget.existingDraftNames.contains(name);
  }

  Future<void> _save() async {
    if (_isSaving) {
      return;
    }

    final name = _controller.text.trim();

    if (name.isEmpty) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    final success = await widget.onSave(name);

    if (!mounted) {
      return;
    }

    if (success) {
      Navigator.of(context).pop(true);
      return;
    }

    setState(() {
      _isSaving = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        backgroundColor: Colors.red,
        content: Text(
          'Unable to save draft',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(20),
      child: Container(
        width: 420,
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment:
          CrossAxisAlignment.start,
          children: [
            // ------------------------------------------------------
            // TITLE
            // ------------------------------------------------------

            const Row(
              children: [
                Icon(
                  Icons.save_outlined,
                  size: 21,
                  color: Color(0xff2563EB),
                ),
                SizedBox(width: 9),
                Text(
                  'Save Draft',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 7),

            const Text(
              'Enter a name for this draft.',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),

            const SizedBox(height: 18),

            // ------------------------------------------------------
            // TEXT FIELD
            // ------------------------------------------------------

            TextField(
              controller: _controller,
              autofocus: true,
              enabled: !_isSaving,
              textInputAction:
              TextInputAction.done,
              onSubmitted: (_) => _save(),
              style: const TextStyle(
                fontSize: 13,
              ),
              decoration: InputDecoration(
                hintText: 'Example: Supplier March Order',
                hintStyle: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
                prefixIcon: const Icon(
                  Icons.description_outlined,
                  size: 18,
                ),
                filled: true,
                fillColor: const Color(0xffF8FAFC),
                contentPadding:
                const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
                border: OutlineInputBorder(
                  borderRadius:
                  BorderRadius.circular(9),
                  borderSide: BorderSide(
                    color: Colors.grey.shade300,
                  ),
                ),
                enabledBorder:
                OutlineInputBorder(
                  borderRadius:
                  BorderRadius.circular(9),
                  borderSide: BorderSide(
                    color: Colors.grey.shade300,
                  ),
                ),
                focusedBorder:
                OutlineInputBorder(
                  borderRadius:
                  BorderRadius.circular(9),
                  borderSide: const BorderSide(
                    color: Color(0xff3B82F6),
                    width: 1.3,
                  ),
                ),
              ),
            ),

            // ------------------------------------------------------
            // EXISTING MESSAGE
            // ------------------------------------------------------

            AnimatedSwitcher(
              duration: const Duration(
                milliseconds: 180,
              ),
              child: _isExist
                  ? const Padding(
                key: ValueKey('exists'),
                padding: EdgeInsets.only(
                  top: 8,
                ),
                child: Row(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 15,
                      color: Colors.orange,
                    ),
                    SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'This draft already exists. Saving will overwrite its data.',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.orange,
                          fontWeight:
                          FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              )
                  : const SizedBox(
                key: ValueKey('not_exists'),
                height: 8,
              ),
            ),

            const SizedBox(height: 12),

            // ------------------------------------------------------
            // BUTTONS
            // ------------------------------------------------------

            Row(
              mainAxisAlignment:
              MainAxisAlignment.end,
              children: [
                OutlinedButton(
                  onPressed: _isSaving
                      ? null
                      : () {
                    Navigator.of(context)
                        .pop(false);
                  },
                  style: OutlinedButton.styleFrom(
                    minimumSize:
                    const Size(80, 36),
                  ),
                  child: const Text(
                    'Cancel',
                  ),
                ),

                const SizedBox(width: 8),

                ElevatedButton(
                  onPressed:
                  _isSaving || _controller.text.trim().isEmpty
                      ? null
                      : _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                    const Color(0xff2563EB),
                    foregroundColor: Colors.white,
                    minimumSize:
                    const Size(90, 36),
                  ),
                  child: _isSaving
                      ? const SizedBox(
                    width: 17,
                    height: 17,
                    child:
                    CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                      : Text(
                    _isExist
                        ? 'Overwrite'
                        : 'Save',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// DRAFT LIST DIALOG
// ============================================================================

class _DraftListDialog extends StatefulWidget {
  final List<String> draftNames;

  final void Function(String draftName) onSelect;

  final Future<bool> Function(
      String draftName,
      ) onDelete;

  const _DraftListDialog({
    required this.draftNames,
    required this.onSelect,
    required this.onDelete,
  });

  @override
  State<_DraftListDialog> createState() =>
      _DraftListDialogState();
}

class _DraftListDialogState
    extends State<_DraftListDialog> {
  late List<String> _draftNames;

  String? _deletingDraft;

  @override
  void initState() {
    super.initState();

    _draftNames = List<String>.from(
      widget.draftNames,
    );
  }

  Future<void> _deleteDraft(
      String draftName,
      ) async {
    if (_deletingDraft != null) {
      return;
    }

    setState(() {
      _deletingDraft = draftName;
    });

    final success = await widget.onDelete(
      draftName,
    );

    if (!mounted) {
      return;
    }

    if (success) {
      setState(() {
        _draftNames.remove(draftName);
        _deletingDraft = null;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.green,
          content: Text(
            'Draft deleted',
          ),
          duration: Duration(
            seconds: 1,
          ),
        ),
      );

      if (_draftNames.isEmpty) {
        Navigator.of(context).pop();
      }

      return;
    }

    setState(() {
      _deletingDraft = null;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        backgroundColor: Colors.red,
        content: Text(
          'Unable to delete draft',
        ),
      ),
    );
  }

  Future<void> _confirmDelete(
      String draftName,
      ) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Delete Draft?',
          ),
          content: Text(
            'Delete "$draftName"? This cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: const Text(
                'Cancel',
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text(
                'Delete',
              ),
            ),
          ],
        );
      },
    );

    if (result == true) {
      await _deleteDraft(draftName);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(20),
      child: Container(
        width: 440,
        constraints: const BoxConstraints(
          maxHeight: 520,
        ),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment:
          CrossAxisAlignment.start,
          children: [
            // ------------------------------------------------------
            // HEADER
            // ------------------------------------------------------

            Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: const Color(0xffFFF7ED),
                    borderRadius:
                    BorderRadius.circular(9),
                  ),
                  child: const Icon(
                    Icons.folder_open_outlined,
                    size: 18,
                    color: Color(0xffC2410C),
                  ),
                ),

                const SizedBox(width: 10),

                const Expanded(
                  child: Text(
                    'Hold Drafts',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),

                Container(
                  padding:
                  const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xffF1F5F9),
                    borderRadius:
                    BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${_draftNames.length}',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Color(0xff475569),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // ------------------------------------------------------
            // LIST
            // ------------------------------------------------------

            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: _draftNames.length,
                separatorBuilder: (_, __) =>
                const SizedBox(height: 7),
                itemBuilder: (context, index) {
                  final draftName =
                  _draftNames[index];

                  final isDeleting =
                      _deletingDraft == draftName;

                  return Container(
                    decoration: BoxDecoration(
                      color: const Color(0xffF8FAFC),
                      borderRadius:
                      BorderRadius.circular(9),
                      border: Border.all(
                        color: const Color(0xffE2E8F0),
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            borderRadius:
                            BorderRadius.circular(9),
                            onTap: isDeleting
                                ? null
                                : () {
                              widget.onSelect(
                                draftName,
                              );

                              Navigator.of(context)
                                  .pop(
                                draftName,
                              );
                            },
                            child: Padding(
                              padding:
                              const EdgeInsets
                                  .symmetric(
                                horizontal: 12,
                                vertical: 11,
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 30,
                                    height: 30,
                                    decoration:
                                    BoxDecoration(
                                      color:
                                      Colors.white,
                                      borderRadius:
                                      BorderRadius
                                          .circular(
                                        7,
                                      ),
                                    ),
                                    child: const Icon(
                                      Icons
                                          .description_outlined,
                                      size: 17,
                                      color: Color(
                                        0xff64748B,
                                      ),
                                    ),
                                  ),

                                  const SizedBox(
                                    width: 10,
                                  ),

                                  Expanded(
                                    child: Text(
                                      draftName,
                                      maxLines: 1,
                                      overflow:
                                      TextOverflow
                                          .ellipsis,
                                      style:
                                      const TextStyle(
                                        fontSize: 13,
                                        fontWeight:
                                        FontWeight
                                            .w600,
                                        color: Color(
                                          0xff1E293B,
                                        ),
                                      ),
                                    ),
                                  ),

                                  const SizedBox(
                                    width: 5,
                                  ),

                                  const Icon(
                                    Icons
                                        .chevron_right_rounded,
                                    size: 19,
                                    color: Color(
                                      0xff94A3B8,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                        Container(
                          height: 26,
                          width: 1,
                          color:
                          const Color(0xffE2E8F0),
                        ),

                        SizedBox(
                          width: 42,
                          child: IconButton(
                            onPressed: isDeleting
                                ? null
                                : () {
                              _confirmDelete(
                                draftName,
                              );
                            },
                            padding: EdgeInsets.zero,
                            tooltip:
                            'Delete draft',
                            icon: isDeleting
                                ? const SizedBox(
                              width: 16,
                              height: 16,
                              child:
                              CircularProgressIndicator(
                                strokeWidth: 2,
                              ),
                            )
                                : const Icon(
                              Icons
                                  .delete_outline_rounded,
                              size: 18,
                              color: Colors
                                  .redAccent,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 14),

            // ------------------------------------------------------
            // FOOTER
            // ------------------------------------------------------

            Align(
              alignment: Alignment.centerRight,
              child: OutlinedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                style: OutlinedButton.styleFrom(
                  minimumSize:
                  const Size(80, 36),
                ),
                child: const Text(
                  'Close',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}