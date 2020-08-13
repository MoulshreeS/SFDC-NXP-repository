public class ProductsSelector extends ApplicationSelector {
	
	public override Schema.SObjectType getSObjectType() {
		return Product2.SObjectType;
	}
	
	public List<Schema.SObjectField> getSObjectFieldList() {
		return new List<Schema.SObjectField> {
			Product2.Id,
			Product2.IsActive,
			Product2.Basic_Type__c,
			Product2.BL__c,
			Product2.BL_Description__c,
			Product2.BU__c,
			Product2.BU_Description__c,
			Product2.Legacy_Id__c,
			Product2.MAG__c,
			Product2.MAG_Description__c,
			Product2.Sales_Item__c,
			Product2.SalesItem_CSI__c,
			Product2.SalesItem_ProductState__c,
			Product2.SalesItem_OrderablePartNumber__c,
			Product2.X9NC__c
		};
	}
	
	public List<Product2> selectBySalesItem(Set<String> salesItems) {
		p('selectBySalesItem');
		return (List<Product2>)Database.query(newQueryFactory().setCondition('Sales_Item__c in :salesItems').toSOQL()); 	
	}
    
}