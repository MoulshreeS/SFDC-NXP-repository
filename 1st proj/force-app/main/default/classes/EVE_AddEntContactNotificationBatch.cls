public with sharing class EVE_AddEntContactNotificationBatch implements Database.Batchable<SObject>, Database.Stateful {
	private Integer batchNumber ;
	private Id templateId;

	public EVE_AddEntContactNotificationBatch(Id templateId) {
		this.batchNumber = 1;
		this.templateId = templateId;
	}

	public Database.QueryLocator start(Database.BatchableContext context) {
		return Database.getQueryLocator([
				SELECT Id, Name
				FROM Entitlement
				WHERE Marvell_Id__c != null
		]);
	}

	public void execute(Database.BatchableContext context, List<Object> scope) {
		System.debug(LoggingLevel.Error, 'batch number = ' + batchNumber++);
		Entitlement[] entitlements = (Entitlement[]) scope;
		Set<Id> entIds = (new Map<Id, Entitlement>(entitlements)).keySet();
		EVE_AdditionalNotifications.sendNotificationForEntitlements(entIds, templateId);
	}

	public void finish(Database.BatchableContext context) {}
}