public with sharing class EVE_ConvertMarvellCasesBatch implements Database.Batchable<SObject>, Database.Stateful {

	private Integer batchNumber ;
	private EVE_ConversionResultDTO totals;
	private Datetime startBatchDatetime;

	public EVE_ConvertMarvellCasesBatch() {
		this.batchNumber = 1;
		this.totals = new EVE_ConversionResultDTO(0,0,0);
		this.startBatchDatetime = System.now();
	}

	public Database.QueryLocator start(Database.BatchableContext context) {
		Entitlement[] convertedEntitlements = [
			SELECT Id, Marvell_Id__c
			FROM Entitlement
			WHERE Marvell_Id__c != null
		];
		Set<Id> convertProjectsIds = new Set<Id>();
		for (Entitlement entitlement : convertedEntitlements) {
			convertProjectsIds.add(entitlement.Marvell_Id__c);
		}
		System.debug(LoggingLevel.Error, 'convertProjectsIds.size() = ' + convertProjectsIds.size());

		totals.expected = [SELECT Count()
			FROM Marvell_Case__c
			WHERE ProjectId__c IN :convertProjectsIds
			AND ExcludeStats__c != true];
		return Database.getQueryLocator([
			SELECT ID
			FROM Marvell_Case__c
			WHERE ProjectId__c IN :convertProjectsIds
			AND ExcludeStats__c != true
		]);
	}

	public void execute(Database.BatchableContext context, List<Object> scope) {
		Marvell_Case__c[] marvellCases = (Marvell_Case__c[]) scope;
		Set<Id> marvellCaseIds = (new Map<Id, Marvell_Case__c>(marvellCases)).keySet();
		EVE_ConversionResultDTO result = EVE_MarvellConvert.convertMarvellCases(marvellCaseIds);
		totals = totals.add(result);
	}

	public void finish(Database.BatchableContext context) {
		Log__c log  = new Log__c(
			Timestamp__c = Datetime.now(),
			Source__c = EVE_MarvellConvert.LOG_SOURCE_CASE,
			Message__c = totals.toString());
		System.debug(LoggingLevel.Error, 'log = ' + JSON.serializePretty(log));
		insert log;
	}
}