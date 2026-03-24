@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Fornecedores com Pedidos de Compra'
@Metadata.allowExtensions: true
define view entity ZC_SupplierWithPO
  as projection on ZI_SupplierWithPO
{
      *
}
