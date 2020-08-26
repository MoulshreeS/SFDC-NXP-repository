public class ProductCostStagesSelector extends ApplicationSelector {
	
	public override Schema.SObjectType getSObjectType() {
		return ProductCostStage__c.SObjectType;
	}
	
	public List<Schema.SObjectField> getSObjectFieldList() {
		return new List<Schema.SObjectField> {
			ProductCostStage__c.Id,
			ProductCostStage__c.CreatedDate,
			ProductCostStage__c.Name,
			ProductCostStage__c.Batch_Job_ID__c,
			ProductCostStage__c.Message__c,
			ProductCostStage__c.Product_Cost__c,
			ProductCostStage__c.Sales_Item__c,
			ProductCostStage__c.Sched_Job_ID__c,
			ProductCostStage__c.Status__c,
			ProductCostStage__c.Unit_Cost__c
		};
	}
	
	public override String getOrderBy() {
		return 'Name, CreatedDate';
	}
	
	public List<ProductCostStage__c> selectById(Set<Id> ids) {
		p('selectById');
		return (List<ProductCostStage__c>)selectSObjectsById(ids);
	}
	
	public List<ProductCostStage__c> selectByStatus(Set<String> statuses) {
		p('selectByStatus(statuses)');
		return selectByStatus(statuses, null);
	}
	
	public List<ProductCostStage__c> selectByStatus(Set<String> statuses, Integer limitCount) {
		p('selectByStatus(statuses, limitCount)');
		return (List<ProductCostStage__c>)Database.query(newQueryFactory().setCondition('Status__c in :statuses').setLimit(limitCount).toSOQL());
	}
	
	public Database.QueryLocator selectByStatusQueryLocator(Set<String> statuses) {
		p('selectByStatusQueryLocator(statuses)');
		return selectByStatusQueryLocator(statuses, null);
	}
	
	public Database.QueryLocator selectByStatusQueryLocator(Set<String> statuses, Integer limitCount) {
		p('selectByStatusQueryLocator(statuses, limitCount)');
		return Database.getQueryLocator(newQueryFactory().setCondition('Status__c in :statuses').setLimit(limitCount).toSOQL());
	}

}