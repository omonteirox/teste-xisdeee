@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Supplier-Customer Balance Report'
@ObjectModel.usageType: {
  serviceQuality: #D,
  sizeCategory:   #L,
  dataClass:      #MIXED
}

// Main interface view: Supplier-Customer Balance Report.
// Shows only Business Partners that act simultaneously as Supplier and Customer
// (identified by I_Supplier.Customer != '').
//
// Purchase side:  ZI_PurchBySupplier — aggregated by (Supplier, CompanyCode, Currency)
// Sales side:     ZI_SalesByCustomer — aggregated by (Customer, CompanyCode, Currency)
// Link:           I_Supplier.Customer is the Customer number of the same BP.
//
// CURRENCY NOTE: Balance is comparable only when PurchaseCurrency = SalesCurrency.
// When currencies differ, multiple rows appear per supplier (one per currency combination).
// A currency conversion layer (via I_ExchangeRate) is a planned Phase 2 enhancement.
define view entity ZI_SupplierCustBal
  with parameters
    P_CompanyCode    : abap.char( 4 ),
    P_PurchDateFrom  : abap.dats,
    P_PurchDateTo    : abap.dats,
    P_BillDateFrom   : abap.dats,
    P_BillDateTo     : abap.dats

  as select from I_Supplier as Supp
    left outer join ZI_PurchBySupplier(
      P_CompanyCode: $parameters.P_CompanyCode,
      P_DateFrom:    $parameters.P_PurchDateFrom,
      P_DateTo:      $parameters.P_PurchDateTo
    ) as Purch
      on  Purch.Supplier    = Supp.Supplier
      and Purch.CompanyCode = $parameters.P_CompanyCode

    left outer join ZI_SalesByCustomer(
      P_CompanyCode: $parameters.P_CompanyCode,
      P_DateFrom:    $parameters.P_BillDateFrom,
      P_DateTo:      $parameters.P_BillDateTo
    ) as Sales
      on  Sales.Customer    = Supp.Customer
      and Sales.CompanyCode = $parameters.P_CompanyCode

  where Supp.Customer <> ''

{
  // ─── Keys ───────────────────────────────────────────────────────────
  key Supp.Supplier,
  key coalesce( Purch.PurchaseCurrency, '' )            as PurchaseCurrency,
  key coalesce( Sales.SalesCurrency, '' )               as SalesCurrency,

  // ─── Supplier master ────────────────────────────────────────────────
      Supp.SupplierFullName,
      Supp.Customer,

  // ─── Company (from parameter — same for all rows in query) ──────────
      cast( $parameters.P_CompanyCode as abap.char( 4 ) ) as CompanyCode,

  // ─── Purchase aggregates ────────────────────────────────────────────
      @Semantics.amount.currencyCode: 'PurchaseCurrency'
      coalesce( Purch.TotalPurchaseAmount, 0 )          as TotalPurchaseAmount,

      coalesce( cast( Purch.TotalPurchaseOrders as abap.int8 ), 0 ) as TotalPurchaseOrders,

  // ─── Sales aggregates ───────────────────────────────────────────────
      @Semantics.amount.currencyCode: 'SalesCurrency'
      coalesce( Sales.TotalSalesAmount, 0 )             as TotalSalesAmount,

      coalesce( cast( Sales.TotalBillingDocuments as abap.int8 ), 0 ) as TotalBillingDocuments,

  // ─── Balance (Vendas − Compras) ─────────────────────────────────────
  // Meaningful only when PurchaseCurrency = SalesCurrency.
      @Semantics.amount.currencyCode: 'SalesCurrency'
      coalesce( Sales.TotalSalesAmount, 0 )
        - coalesce( Purch.TotalPurchaseAmount, 0 )      as Balance,

  // ─── Semantic coloring: 3=green(selling more), 1=red(buying more), 2=yellow(even) ──
      case
        when coalesce( Sales.TotalSalesAmount, 0 )
               > coalesce( Purch.TotalPurchaseAmount, 0 ) then 3
        when coalesce( Purch.TotalPurchaseAmount, 0 )
               > coalesce( Sales.TotalSalesAmount, 0 )   then 1
        else 2
      end                                               as BalanceCriticality,

  // ─── Status text ────────────────────────────────────────────────────
      case
        when coalesce( Sales.TotalSalesAmount, 0 )
               > coalesce( Purch.TotalPurchaseAmount, 0 ) then 'SELLING'
        when coalesce( Purch.TotalPurchaseAmount, 0 )
               > coalesce( Sales.TotalSalesAmount, 0 )   then 'BUYING'
        else 'BALANCED'
      end                                               as BalanceStatus
}
