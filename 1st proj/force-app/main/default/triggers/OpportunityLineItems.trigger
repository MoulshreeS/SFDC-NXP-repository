trigger OpportunityLineItems on OpportunityLineItem (after delete, after insert, after update, before delete, before insert, before update) {
	fflib_SObjectDomain.triggerHandler(OpportunityLineItems.class);    
}