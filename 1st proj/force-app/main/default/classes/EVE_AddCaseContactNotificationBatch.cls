public with sharing class EVE_AddCaseContactNotificationBatch implements Database.Batchable<SObject>, Database.Stateful {
	private Integer batchNumber ;
	private Id templateId;

	public EVE_AddCaseContactNotificationBatch(Id templateId) {
		this.batchNumber = 1;
		this.templateId = templateId;
	}

	public Database.QueryLocator start(Database.BatchableContext context) {
		return Database.getQueryLocator([
				SELECT Id, RelatedToId__c, ContactId
				FROM Case
				WHERE RelatedToId__c LIKE 'Marvell-%'
				AND Status != 'Close'
				AND ContactId != null
		]);
	}

	public void execute(Database.BatchableContext context, List<Object> scope) {
		System.debug(LoggingLevel.Error, 'batch number = ' + batchNumber++);
		Case[] cases = (Case[]) scope;
		Set<Id> caseId = (new Map<Id, Case>(cases)).keySet();
		EVE_AdditionalNotifications.notifyCaseContacts(caseId, templateId);
	}

	public void finish(Database.BatchableContext context) {}
}