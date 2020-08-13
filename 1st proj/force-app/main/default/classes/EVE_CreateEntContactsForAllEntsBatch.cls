public without sharing class EVE_CreateEntContactsForAllEntsBatch implements Database.Batchable<SObject>, Database.Stateful {
	private Integer batchNumber ;
	private EVE_ConversionResultDTO totals;

	public EVE_CreateEntContactsForAllEntsBatch() {
		this.batchNumber = 1;
		this.totals = new EVE_ConversionResultDTO(0,0,0);
	}

	public Database.QueryLocator start(Database.BatchableContext context) {
		totals.expected = [
			SELECT COUNT()
			FROM Entitlement
			WHERE Marvell_Id__c != null];
		return Database.getQueryLocator([
			SELECT Id
			FROM Entitlement
			WHERE Marvell_Id__c != null
		]);
	}

	public void execute(Database.BatchableContext context, List<Object> scope) {
		System.debug(LoggingLevel.Error, 'batch number = ' + batchNumber++);
		Entitlement[] entitlements = (Entitlement[]) scope;
		Set<Id> entitlementIds = (new Map<Id, Entitlement>(entitlements)).keySet();
		System.debug(LoggingLevel.Error, 'entitlementIds.size() = ' + entitlementIds.size());
		EVE_ConversionResultDTO result = EVE_MarvellConvert.createEntitlementContactsForAllEntitlements(entitlementIds);
		totals = totals.add(result);
	}

	public void finish(Database.BatchableContext context) {
		Log__c log  = new Log__c(
				Timestamp__c = Datetime.now(),
				Source__c = EVE_MarvellConvert.LOG_SOURCE_ENTITLEMENT_CONTACT,
				Message__c = 'For ' + totals.expected + ' entitlements: ' + totals.converted + ' entitlement contacts created, ' + totals.skipped + ' skipped, ' + totals.failed + ' falied');
		System.debug(LoggingLevel.Error, 'log = ' + JSON.serializePretty(log));
		insert log;
		EVE_MarvellConvert.disableMarvellCustomSetting();

	}
}