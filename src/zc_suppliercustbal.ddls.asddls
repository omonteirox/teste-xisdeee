@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Supplier-Customer Balance - Fiori'
@ObjectModel.usageType: {
  serviceQuality: #X,
  sizeCategory:   #L,
  dataClass:      #MIXED
}
@Metadata.allowExtensions: true

// Consumption view for Fiori Elements List Report.
// Exposes all parameters as filterable filter bar fields.
// UI annotations are defined in ZME_SupplierCustBal.ddlx.
define view entity ZC_SUPPLIERCUSTBAL
  with parameters
    @Consumption.filter: {
      selectionType:      #SINGLE,
      multipleSelections: false,
      mandatory:          true
    }
    @EndUserText.label: 'Company Code'
    P_CompanyCode   : abap.char( 4 ),

    @Consumption.filter: {
      selectionType:      #RANGE,
      multipleSelections: false,
      mandatory:          true
    }
    @EndUserText.label: 'PO Date From'
    P_PurchDateFrom : abap.dats,

    @Consumption.filter: {
      selectionType:      #RANGE,
      multipleSelections: false,
      mandatory:          true
    }
    @EndUserText.label: 'PO Date To'
    P_PurchDateTo   : abap.dats,

    @Consumption.filter: {
      selectionType:      #RANGE,
      multipleSelections: false,
      mandatory:          true
    }
    @EndUserText.label: 'Billing Date From'
    P_BillDateFrom  : abap.dats,

    @Consumption.filter: {
      selectionType:      #RANGE,
      multipleSelections: false,
      mandatory:          true
    }
    @EndUserText.label: 'Billing Date To'
    P_BillDateTo    : abap.dats

  as projection on ZI_SupplierCustBal(
    P_CompanyCode:   $parameters.P_CompanyCode,
    P_PurchDateFrom: $parameters.P_PurchDateFrom,
    P_PurchDateTo:   $parameters.P_PurchDateTo,
    P_BillDateFrom:  $parameters.P_BillDateFrom,
    P_BillDateTo:    $parameters.P_BillDateTo
  )

{
  key Supplier,
  key PurchaseCurrency,
  key SalesCurrency,
      SupplierFullName,
      Customer,
      CompanyCode,
      TotalPurchaseAmount,
      TotalPurchaseOrders,
      TotalSalesAmount,
      TotalBillingDocuments,
      Balance,
      BalanceCriticality,
      BalanceStatus
}
