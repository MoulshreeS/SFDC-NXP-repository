trigger ProductCostStages on ProductCostStage__c (before insert) {
	fflib_SObjectDomain.triggerHandler(ProductCostStages.class);
}