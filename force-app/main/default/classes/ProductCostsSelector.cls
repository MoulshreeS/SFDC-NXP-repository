public class ProductCostsSelector extends ApplicationSelector {
	
	public override Schema.SObjectType getSObjectType() {
		return ProductCost__c.SObjectType;
	}
	
	public List<Schema.SObjectField> getSObjectFieldList() {
		return new List<Schema.SObjectField> {
			ProductCost__c.Id,
			ProductCost__c.Product__c,
			ProductCost__c.Sales_Item__c,
			ProductCost__c.Unit_Cost__c
		};
	}
	
	public Map<Id, ProductCost__c> selectByProdId(Set<Id> prodIds) {
		p('selectByProdId');
		Map<Id, ProductCost__c> result = new Map<Id, ProductCost__c>();
		
		List<ProductCost__c> prodCosts = (List<ProductCost__c>)Database.query(newQueryFactory().setCondition('Product__c in :prodIds').toSOQL());
		
		for (ProductCost__c pc : prodCosts) {
			result.put(pc.Product__c, pc);
		}
		
		return result;
	}
	
	public List<ProductCost__c> selectBySalesItem(Set<String> salesItems) {
		p('selectBySalesItem');
		return (List<ProductCost__c>)Database.query(newQueryFactory().setCondition('Sales_Item__c in :salesItems').toSOQL()); 	
	}
	
}