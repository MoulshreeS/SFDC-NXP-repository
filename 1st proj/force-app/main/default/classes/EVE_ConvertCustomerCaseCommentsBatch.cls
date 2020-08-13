public without sharing class EVE_ConvertCustomerCaseCommentsBatch implements Database.Batchable<SObject>, Database.Stateful {

	private Integer batchNumber ;
	private EVE_ConversionResultDTO totals;
	private Datetime startBatchDatetime;
	private Boolean verbose;

	public EVE_ConvertCustomerCaseCommentsBatch() {
		this(false);
	}

	public EVE_ConvertCustomerCaseCommentsBatch(Boolean verboseFlag) {
		this.batchNumber = 1;
		this.totals = new EVE_ConversionResultDTO(0,0,0);
		this.startBatchDatetime = System.now();
		this.verbose = verboseFlag;
	}


	public Database.QueryLocator start(Database.BatchableContext context) {
//		totals.expected = [SELECT COUNT()
//			FROM Marvell_CaseComment__c
//			WHERE InternalCustomer__c = :EVE_MarvellConvert.MARVELL_CASE_COMMENT_CUSTOMER];
//		if (verbose) {
//			System.debug(LoggingLevel.Error, 'totals.expected = ' + totals.expected);
//		}
		return Database.getQueryLocator([
			SELECT Id
			FROM Marvell_CaseComment__c
			WHERE InternalCustomer__c = :EVE_MarvellConvert.MARVELL_CASE_COMMENT_CUSTOMER
		]);
	}

	public void execute(Database.BatchableContext context, List<Object> scope) {
		if (verbose) {
			System.debug(LoggingLevel.Error, 'batch number = ' + batchNumber++);
		}
		Marvell_CaseComment__c[] customerCaseComments = (Marvell_CaseComment__c[]) scope;
		Set<Id> customerCaseCommentsIds = (new Map<Id, Marvell_CaseComment__c>(customerCaseComments)).keySet();
		if (verbose) {
			System.debug(LoggingLevel.Error, 'customerCaseCommentsIds = ' + JSON.serializePretty(customerCaseCommentsIds));
		}
		EVE_ConversionResultDTO result = EVE_MarvellConvert.convertMarvellCustomerCaseComments(customerCaseCommentsIds, verbose);
		totals = totals.add(result);
	}

	public void finish(Database.BatchableContext context) {
		Log__c log  = new Log__c(
			Timestamp__c = Datetime.now(),
			Source__c = EVE_MarvellConvert.LOG_SOURCE_CUSTOMER_CASE_COMMENTS,
			Message__c = totals.toString());
		System.debug(LoggingLevel.Error, 'log = ' + JSON.serializePretty(log));
		insert log;
	}
}