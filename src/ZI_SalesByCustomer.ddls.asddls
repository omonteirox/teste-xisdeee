@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Sales aggregation by customer'
@ObjectModel.usageType: {
  serviceQuality: #D,
  sizeCategory:   #L,
  dataClass:      #TRANSACTIONAL
}

// Helper view: aggregates billing document amounts by sold-to customer.
// Source view: I_BILLINGDOCUMENT (#A).
// Excludes cancelled billing documents (BillingDocumentIsCancelled = '').
// Date range and company code are mandatory parameters — must be supplied by caller.
define view entity ZI_SalesByCustomer
  with parameters
    P_CompanyCode : abap.char( 4 ),
    P_DateFrom    : abap.dats,
    P_DateTo      : abap.dats

  as select from I_BILLINGDOCUMENT as Bill

  where
        Bill.CompanyCode               =  $parameters.P_CompanyCode
    and Bill.BillingDocumentDate       >= $parameters.P_DateFrom
    and Bill.BillingDocumentDate       <= $parameters.P_DateTo
    and Bill.BillingDocumentIsCancelled = ''

{
  key Bill.SoldToParty                               as Customer,
  key Bill.CompanyCode,
  key Bill.TransactionCurrency                       as SalesCurrency,

      @Semantics.amount.currencyCode: 'SalesCurrency'
      @Aggregation.default: #SUM
      sum( Bill.TotalNetAmount )                     as TotalSalesAmount,

      @Aggregation.default: #SUM
      count( * )                                     as TotalBillingDocuments
}
group by
  Bill.SoldToParty,
  Bill.CompanyCode,
  Bill.TransactionCurrency
