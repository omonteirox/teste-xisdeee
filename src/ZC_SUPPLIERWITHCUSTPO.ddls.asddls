@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Supplier Report - Consumption View'
@ObjectModel.usageType: {
  serviceQuality: #A,
  sizeCategory: #M,
  dataClass: #MIXED
}
@Search.searchable: true
define view entity ZC_SupplierWithCustPO
  provider contract transactional_query
  as projection on ZI_SupplierWithCustPO
{
  key Supplier,
  key CompanyCode,
  key PurchasingOrganization,
  key DocumentCurrency,
  key PurchaseOrderDate,

      SupplierFullName,
      SupplierAccountGroup,
      Country,
      Region,
      CityName,
      PostalCode,
      StreetName,
      VATRegistration,
      TaxNumber1,
      TaxNumber2,
      PhoneNumber1,
      Industry,
      SupplierCorporateGroup,
      PurchasingIsBlocked,
      DeletionIndicator,
      Customer,
      IsAlsoCustomer,
      IsAlsoCustCriticality,
      PurBlockedCriticality,

      CustomerFullName,
      CustomerAccountGroup,

      TotalGrossAmount,
      TotalNetAmount,
      NumberOfPurchaseOrders
}
