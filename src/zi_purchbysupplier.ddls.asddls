@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Purchase aggregation by supplier'
@ObjectModel.usageType: {
  serviceQuality: #D,
  sizeCategory:   #L,
  dataClass:      #TRANSACTIONAL
}

// Helper view: aggregates purchase order amounts by supplier.
// Source views: I_PURCHASEORDERAPI01 (#A) and I_PURCHASEORDERITEMAPI01 (#A).
// Excludes deleted PO items (PurchasingDocumentDeletionCode = '').
// Date range and company code are mandatory parameters — must be supplied by caller.
define view entity ZI_PurchBySupplier
  with parameters
    P_CompanyCode : abap.char( 4 ),
    P_DateFrom    : abap.dats,
    P_DateTo      : abap.dats

  as select from I_PURCHASEORDERITEMAPI01 as PoItem
    inner join   I_PURCHASEORDERAPI01     as PoHdr
      on PoHdr.PurchaseOrder = PoItem.PurchaseOrder

  where
        PoHdr.CompanyCode                     =  $parameters.P_CompanyCode
    and PoHdr.PurchaseOrderDate               >= $parameters.P_DateFrom
    and PoHdr.PurchaseOrderDate               <= $parameters.P_DateTo
    and PoItem.PurchasingDocumentDeletionCode =  ''

{
  key PoHdr.Supplier,
  key PoHdr.CompanyCode,
  key PoItem.DocumentCurrency                          as PurchaseCurrency,

      @Semantics.amount.currencyCode: 'PurchaseCurrency'
      @Aggregation.default: #SUM
      sum( PoItem.GrossAmount )                        as TotalPurchaseAmount,

      @Aggregation.default: #SUM
      count( distinct PoHdr.PurchaseOrder )            as TotalPurchaseOrders
}
group by
  PoHdr.Supplier,
  PoHdr.CompanyCode,
  PoItem.DocumentCurrency
