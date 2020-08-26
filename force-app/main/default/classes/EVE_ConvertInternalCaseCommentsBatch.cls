public with sharing class EVE_ConvertInternalCaseCommentsBatch implements Database.Batchable<SObject>, Database.Stateful {

	private Integer batchNumber ;
	private EVE_ConversionResultDTO totals;

	public EVE_ConvertInternalCaseCommentsBatch() {
		this.batchNumber = 1;
		this.totals = new EVE_ConversionResultDTO(0,0,0);
	}

	public Database.QueryLocator start(Database.BatchableContext context) {
		//totals.expected = [SELECT Count() FROM Marvell_CaseComment__c
		//	WHERE InternalCustomer__c = :EVE_MarvellConvert.MARVELL_CASE_COMMENT_INTERNAL];
		return Database.getQueryLocator([
			SELECT Id
			FROM Marvell_CaseComment__c
			WHERE InternalCustomer__c = :EVE_MarvellConvert.MARVELL_CASE_COMMENT_INTERNAL
		]);
	}

	public void execute(Database.BatchableContext context, List<Object> scope) {
		System.debug(LoggingLevel.Error, 'batch number = ' + batchNumber++);
		Marvell_CaseComment__c[] internalCaseComments = (Marvell_CaseComment__c[]) scope;
		Set<Id> internalCaseCommentsIds = (new Map<Id, Marvell_CaseComment__c>(internalCaseComments)).keySet();
		EVE_ConversionResultDTO result = EVE_MarvellConvert.convertMarvellInternalCaseComments(internalCaseCommentsIds);
		totals = totals.add(result);
	}

	public void finish(Database.BatchableContext context) {
		Log__c log  = new Log__c(
				Timestamp__c = Datetime.now(),
				Source__c = EVE_MarvellConvert.LOG_SOURCE_INTERNAL_CASE_COMMENTS,
				Message__c = totals.toString());
		System.debug(LoggingLevel.Error, 'log = ' + JSON.serializePretty(log));
		insert log;

		//EVE_MarvellConvert.disableMarvellCustomSetting();
	}
}