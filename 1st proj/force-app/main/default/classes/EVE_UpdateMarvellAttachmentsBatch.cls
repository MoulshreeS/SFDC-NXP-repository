public with sharing class EVE_UpdateMarvellAttachmentsBatch implements Database.Batchable<SObject>, Database.Stateful {

	private Integer batchNumber ;
	private EVE_ConversionResultDTO totals;

	public EVE_UpdateMarvellAttachmentsBatch() {
		this.batchNumber = 1;
		this.totals = new EVE_ConversionResultDTO(0,0,0);
	}

	public Database.QueryLocator start(Database.BatchableContext context) {
		totals.expected = [SELECT Count()
			FROM Marvell_Attachment__c];
		return Database.getQueryLocator([
			SELECT Id
			FROM Marvell_Attachment__c
		]);
	}

	public void execute(Database.BatchableContext context, List<Object> scope) {
		System.debug(LoggingLevel.Error, 'batch number = ' + batchNumber++);
		Marvell_Attachment__c[] marvellAttachments = (Marvell_Attachment__c[]) scope;
		Set<Id> marvellAttachmentIds = (new Map<Id, Marvell_Attachment__c>(marvellAttachments)).keySet();
		EVE_ConversionResultDTO result = EVE_MarvellConvertAttachements.updateMarvellAttachments(marvellAttachmentIds);
		totals = totals.add(result);
	}

	public void finish(Database.BatchableContext context) {
		Log__c log  = new Log__c(
			Timestamp__c = Datetime.now(),
			Source__c = 'Marvell Attachment Update',
			Message__c = totals.toString());
		System.debug(LoggingLevel.Error, 'log = ' + JSON.serializePretty(log));
		insert log;
	}

}