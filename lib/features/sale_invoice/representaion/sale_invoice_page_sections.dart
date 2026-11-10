part of 'sale_invoice_page.dart';

extension _SaleInvoicePageSections on _SaleInvoicePageState {

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

              ExtraChargeSales(
                saleInvoiceController: saleInvoiceController,
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
                    child: this._buildLogisticsCard(),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: this._buildDetailsCard(),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 6,
                    child: ExtraChargeSales(
                      saleInvoiceController: saleInvoiceController,
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    flex: 3,
                    child: this._buildSummaryCard(),
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
              child: this._buildLogisticsCard(),
            ),

            const SizedBox(width: 12),

            Expanded(
              flex: 3,
              child: this._buildDetailsCard(),
            ),

            const SizedBox(width: 12),

            Expanded(
              flex: 7,
              child: ExtraChargeSales(
                saleInvoiceController: saleInvoiceController,
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              flex: 3,
              child: this._buildSummaryCard(),
            ),
          ],
        );
      },
    );
  }

Widget _buildDetailsCard() {
    return this._card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            this._sectionTitle(
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
              controller: saleInvoiceController.remarkController,
              maxLines: 2,
              minLines: 2,
              style: const TextStyle(
                fontSize: 12,
                color: _SaleInvoicePageState.textDark,
              ),
              decoration: this._inputDecoration(
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

Widget _buildLogisticsCard() {
    return this._card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            this._sectionTitle(
              Icons.local_shipping_outlined,
              'Logistics',
            ),

            const SizedBox(height: 10),
            CountryField(controller: countryController),
            const SizedBox(height: 10),
            StateField(controller: stateController),
            const SizedBox(height: 10),
            LeadSourceField(controller: leadSourceController),
            const SizedBox(height: 10),

            TransportField(
              controller: transportController,
              onSelected: (transport){
                saleInvoiceController.setTransport(transport);
              },
            ),

            const SizedBox(height: 10),

            Row(
              children: [
                Expanded(
                  child: this._fieldBlock(
                    'LR Number',
                    this._textField(
                      saleInvoiceController.lrNoController,
                      hint: 'LR No',
                      prefix: Icons.eighteen_mp
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: DateField(
                    controller: lrDateController,
                    focusNode: lrDateFocus,
                    hintText: 'Select LR Date',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

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
        listenable: saleInvoiceController.updateSummery,
        builder: (context, _) {
          final supplier = saleInvoiceController.selectSupplier;

          final bool isInterState = supplier!= null &&  supplier.state!=null && supplier.state!.id != GlobalVars.placeOfSupplyId;

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
                      'Qty: ${saleInvoiceController.totalQuantity}',
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

                this._summaryRow(
                  'Value of Goods',
                  saleInvoiceController.getTotalGoodsValue,
                ),

                this._summaryRow(
                  'Additional Discount',
                  saleInvoiceController.additionalDiscountTotal ?? 0,
                ),

                this._summaryRow(
                  'Taxable Amount',
                  saleInvoiceController.valueOfTaxableGoods(),
                ),

                if (isInterState) ...[
                  this._summaryRow(
                    'IGST',
                    saleInvoiceController.igst,
                  ),
                ] else ...[
                  this._summaryRow(
                    'SGST',
                    saleInvoiceController.sgst,
                  ),

                  this._summaryRow(
                    'CGST',
                    saleInvoiceController.cgst,
                  ),
                ],

                this._summaryRow(
                  'Additional Charges',
                  saleInvoiceController.additionalCharge,
                ),

                if (saleInvoiceController.finalDiscount > 0)
                  this._summaryRow(
                    'Final Discount',
                    saleInvoiceController.finalDiscount,
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
                      '₹ ${saleInvoiceController.grandTotal.toStringAsFixed(2)}',
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
                _isEditMode?
                  SizedBox(
                  width: double.infinity,
                  height: 42,
                  child: ElevatedButton.icon(
                    onPressed: saleInvoiceController.isSubmitting
                        ? null
                        : (){
                      this._submitSaleInvoice(true);
                    },
                    icon: saleInvoiceController.isSubmitting
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
                      saleInvoiceController.isSubmitting
                          ? 'Updating...'
                          : 'Update Challan',
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
                ):
                  SizedBox(
                  width: double.infinity,
                  height: 42,
                  child: ElevatedButton.icon(
                    onPressed: saleInvoiceController.isSubmitting
                        ? null
                        : (){this._submitSaleInvoice(false);},
                    icon: saleInvoiceController.isSubmitting
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
                      saleInvoiceController.isSubmitting
                          ? 'Generating...'
                          : 'Generate Sale Invoice',
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

}
