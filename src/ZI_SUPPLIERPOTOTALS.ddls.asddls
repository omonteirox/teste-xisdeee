@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Supplier PO Purchase Totals - Helper'
@ObjectModel.usageType: {
  serviceQuality: #A,
  sizeCategory: #L,
  dataClass: #TRANSACTIONAL
}
define view entity ZI_SupplierPOTotals
  as select from I_PURCHASEORDERITEMAPI01 as item
    inner join I_PURCHASEORDERAPI01       as po
      on po.PurchaseOrder = item.PurchaseOrder
{
  key po.Supplier,
  key po.CompanyCode,
  key po.PurchasingOrganization,
  key po.DocumentCurrency,
  key po.PurchaseOrderDate,

      @Semantics.amount.currencyCode: 'DocumentCurrency'
      sum( item.GrossAmount )              as TotalGrossAmount,

      @Semantics.amount.currencyCode: 'DocumentCurrency'
      sum( item.NetAmount )                as TotalNetAmount,

      count( distinct item.PurchaseOrder ) as NumberOfPurchaseOrders
}
group by
  po.Supplier,
  po.CompanyCode,
  po.PurchasingOrganization,
  po.DocumentCurrency,
  po.PurchaseOrderDate
