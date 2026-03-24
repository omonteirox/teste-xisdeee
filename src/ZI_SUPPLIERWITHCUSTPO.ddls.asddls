@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Supplier with Customer Cross-Ref and PO Totals'
@ObjectModel.usageType: {
  serviceQuality: #A,
  sizeCategory: #M,
  dataClass: #MIXED
}
define view entity ZI_SupplierWithCustPO
  as select from ZI_SupplierPOTotals as totals
    left outer join I_SUPPLIER        as supp
      on supp.Supplier = totals.Supplier
    left outer join I_CUSTOMER        as cust
      on cust.Customer = supp.Customer
{
  // Keys — from aggregation base
  key totals.Supplier,
  key totals.CompanyCode,
  key totals.PurchasingOrganization,
  key totals.DocumentCurrency,
  key totals.PurchaseOrderDate,

  // Supplier master data
      supp.SupplierFullName,
      supp.SupplierAccountGroup,
      supp.Country,
      supp.Region,
      supp.CityName,
      supp.PostalCode,
      supp.StreetName,
      supp.VATRegistration,
      supp.TaxNumber1,
      supp.TaxNumber2,
      supp.PhoneNumber1,
      supp.Industry,
      supp.SupplierCorporateGroup,
      supp.PurchasingIsBlocked,
      supp.DeletionIndicator,
      supp.Customer,

  // Calculated: is supplier also a customer?
      case when supp.Customer is not initial
           then abap_true
           else abap_false
      end                            as IsAlsoCustomer,

  // Criticality helpers for semantic coloring
      case when supp.Customer is not initial
           then 3  // green — is customer
           else 0  // neutral — not a customer
      end                            as IsAlsoCustCriticality,

      case when supp.PurchasingIsBlocked = abap_true
           then 1  // red — blocked
           else 3  // green — active
      end                            as PurBlockedCriticality,

  // Customer cross-reference
      cust.CustomerFullName,
      cust.CustomerAccountGroup,

  // PO purchase totals
      @Semantics.amount.currencyCode: 'DocumentCurrency'
      totals.TotalGrossAmount,

      @Semantics.amount.currencyCode: 'DocumentCurrency'
      totals.TotalNetAmount,

      totals.NumberOfPurchaseOrders
}
