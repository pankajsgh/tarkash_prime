part of 'sale_invoice_page.dart';

extension _SaleInvoicePageHeader on _SaleInvoicePageState {

Widget _buildHeader() {
    return this._card(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: const Color(0xffEAF2FF),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: const Icon(
                  Icons.receipt_long_rounded,
                  color: _SaleInvoicePageState.primaryBlue,
                  size: 20,
                ),
              ),

              const SizedBox(width: 11),

              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Sale Invoice',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: _SaleInvoicePageState.textDark,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Create and manage your sales invoice',
                      style: TextStyle(
                        fontSize: 10,
                        color: _SaleInvoicePageState.textMedium,
                      ),
                    ),
                  ],
                ),
              ),

              this._smallHeaderButton(
                icon: Icons.refresh_rounded,
                label: 'Reset',
                onTap: this._resetForm,
              ),

              const SizedBox(width: 8),

              this._smallHeaderButton(
                icon: Icons.folder_open_outlined,
                label: 'Hold Drafts',
                onTap: () {
                  _showDraftListPopup(context);
                },
              ),

              const SizedBox(width: 8),

              this._smallHeaderButton(
                icon: Icons.save_outlined,
                label: 'Save Draft',
                onTap: () {
                  _showSaveDraftDialog(context);
                },
              ),
            ],
          ),

          const SizedBox(height: 16),

          Container(
            height: 1,
            color: const Color(0xffEEF2F6),
          ),

          const SizedBox(height: 15),

          this._buildInvoiceFields(),
          const SizedBox(height: 15),
          this._buildCustomerSection()
        ],
      ),
    );
  }

Widget  _buildInvoiceFields() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;

        if (width >= 1100) {
          return Row(
            crossAxisAlignment: .end,
            children: [
              Expanded(
                flex: 1,
                child: SeriesField(
                  seriesId: '1',
                  controller: seriesController,
                  onSelected: (series){
                    dateFocus.requestFocus();
                    _dateFieldKey.currentState?.openDatePicker();
                  },
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                flex: 1,
                child: this._field(
                  label: 'Invoice No',
                  controller: invoiceController,
                  isReadOnly: true,
                  suffix: const Icon(
                    Icons.info_outline,
                    size: 15,
                    color: Colors.transparent,
                  ),
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                flex: 1,
                child: DateField(
                  key: _dateFieldKey,
                  controller: dateController,
                  focusNode: dateFocus,
                  hintText: 'Select Date',
                  onSelected: (){
                    storeKey.currentState?.focusAndOpen();
                  },
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                flex: 1,
                child: StoreField(
                  key: storeKey,
                  controller: storeController,
                  focusNode: storeFocus,
                  onSelected: (store){
                    saleInvoiceController.setStore(store);
                    rateTypeKey.currentState?.focusAndOpen();
                  },
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                flex: 1,
                child: RateTypeField(
                  key: rateTypeKey,
                  controller: rateTypeController,
                  focusNode: rateFocus,
                  onSelected: (rateType){
                    if(rateType!=null){
                      teamKey.currentState?.focusAndOpen();
                      saleInvoiceController.applyRateType(rateType);
                    }
                  },
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                flex: 1,
                child: TeamField(
                  key: teamKey,
                  focusNode: teamFocus,
                  controller: teamController,
                  onSelected: (team){
                    customerKey.currentState?.focusAndOpen();
                  },
                ),
              ),



              const SizedBox(width: 12),

              Padding(
                padding: const EdgeInsets.only(bottom: 3.0),
                child: SizedBox(
                  width: 72,
                  height: 35.0,
                  child: this._filledButton(
                    label: 'Clear',
                    color: const Color(0xffEF4444),
                    onPressed: this._resetForm,
                  ),
                ),
              ),
            ],
          );
        }

        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            SizedBox(
              width: width > 700 ? 310 : width,
              child: this._field(
                label: 'Invoice No',
                controller: invoiceController,
                isReadOnly: true,
                suffix: const Icon(
                  Icons.info_outline,
                  size: 15,
                  color: Colors.transparent,
                ),
              ),
            ),

            SizedBox(
              width: width > 700 ? 210 : width,
              child: DateField(
                controller: dateController,
                focusNode: dateFocus,
                hintText: 'Select Date',
                onSelected: (){

                },
              ),
            ),

            SizedBox(
              width: width > 700 ? 190 : width,
              child: StoreField(
                controller: storeController,
                focusNode: storeFocus,
                onSelected: (store){
                  saleInvoiceController.setStore(store);
                }
              ),
            ),

            SizedBox(
              width: width > 700 ? 220 : width,
              child: this._dropdownField(
                label: 'Salesman',
                value: salesman,
                hint: 'Select Salesman',
                items: const [
                  'Salesman 1',
                  'Salesman 2',
                  'Salesman 3',
                ],
                onChanged: (v) {
                  setState(() => salesman = v);
                },
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: this._dropdownField(
                label: 'Backman',
                value: backman,
                hint: 'Select',
                items: const [
                  'Backman 1',
                  'Backman 2',
                  'Backman 3',
                ],
                onChanged: (v) {
                  setState(() => backman = v);
                },
              ),
            ),

            SizedBox(
              width: width > 700 ? 190 : width,
              child: RateTypeField(
                controller: rateTypeController,
                focusNode: rateFocus,
                onSelected: (rateType){
                  if (rateType != null) {
                    saleInvoiceController.applyRateType(rateType);
                  }
                },
              ),
            ),

            Padding(
              padding: const EdgeInsets.only(bottom: 20.0),
              child: this._filledButton(
                label: 'Clear',
                color: const Color(0xffEF4444),
                onPressed: this._resetForm,
              ),
            ),
          ],
        );
      },
    );
  }

Widget _buildCustomerSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;

            if (width >= 1100) {
              return Row(
                children: [
                  Expanded(
                    child: SupplierField(
                      controller: customerController,
                      key: customerKey,
                      type: '2',
                      onSelected: (customer){
                        if(customer!=null){
                          saleInvoiceController.setSupplier(customer);
                          nameController.text = customer.company;
                          gstController.text = customer.gstNo;
                        }
                      },
                    )
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: this._field(
                      label: 'Customer Name',
                      isReadOnly: true,
                      controller: nameController,
                      hint: 'Enter customer name',
                      suffix: const Icon(
                        Icons.add_circle_outline,
                        color: Colors.transparent,
                        size: 17,
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: this._field(
                      label: 'GST Number',
                      controller: gstController,
                      hint: 'Enter GST number',
                      isReadOnly: true,
                      suffix: const Icon(
                        Icons.add_circle_outline,
                        color: Colors.transparent,
                        size: 17,
                      ),
                    ),
                  ),



                  const SizedBox(width: 12),
                  Expanded(
                    flex: 4,
                    child: const SizedBox(),
                  ),


                ],
              );
            }

            return Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                SizedBox(
                  width: width > 700 ? 300 : width,
                  child: SupplierField(
                    controller: customerController,
                    key: customerKey,
                    type: '2',
                    onSelected: (customer){
                      if(customer!=null){
                        saleInvoiceController.setSupplier(customer);
                        nameController.text = customer.company;
                        gstController.text = customer.gstNo;
                      }
                    },
                  ),
                ),

                SizedBox(
                  width: width > 700 ? 300 : width,
                  child: this._field(
                    label: 'Customer Name',
                    controller: nameController,
                    isReadOnly: true,
                    hint: 'Enter customer name',
                  ),
                ),

                SizedBox(
                  width: width > 700 ? 250 : width,
                  child: this._field(
                    label: 'GST Number',
                    controller: gstController,
                    isReadOnly: true,
                    hint: 'Enter GST number',
                  ),
                ),

                SizedBox(
                  width: width > 700 ? 200 : width,
                  child: this._dropdownField(
                    label: 'Backman',
                    value: backman,
                    hint: 'Select',
                    items: const [
                      'Backman 1',
                      'Backman 2',
                      'Backman 3',
                    ],
                    onChanged: (v) {
                      setState(() => backman = v);
                    },
                  ),
                ),

                SizedBox(
                  width: width > 700 ? 200 : width,
                  child: this._field(
                    label: 'Bill Discount',
                    controller: discountController,
                    hint: '0.00 %',
                  ),
                ),

                SizedBox(
                  width: width > 700 ? 68 : width,
                  child: this._filledButton(
                    label: 'Apply',
                    color: _SaleInvoicePageState.darkBlue,
                    onPressed: () {
                      if (discountController.text.isNotEmpty) {
                        saleInvoiceController.applyDiscountController.text = discountController.text;
                        saleInvoiceController.applyDiscountAll();
                      }
                    },
                  ),
                ),
              ],
            );
          },
        ),

        const SizedBox(height: 14),

        Container(
          height: 1,
          color: const Color(0xffEEF2F6),
        ),

      ],
    );
  }

}
