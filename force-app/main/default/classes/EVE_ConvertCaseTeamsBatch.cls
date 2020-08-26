public without sharing class EVE_ConvertCaseTeamsBatch implements Database.Batchable<SObject>, Database.Stateful {
	private Integer batchNumber ;
	private EVE_ConversionResultDTO totals;

	public EVE_ConvertCaseTeamsBatch() {
		this.batchNumber = 1;
		this.totals = new EVE_ConversionResultDTO(0,0,0);
	}

	public Database.QueryLocator start(Database.BatchableContext context) {
		totals.expected = [SELECT Count()
			FROM Marvell_Case_Team__c
			WHERE NOT MemberEmail__c LIKE '%@marvell.com'];
		return Database.getQueryLocator([
			SELECT ID
			FROM Marvell_Case_Team__c
			WHERE NOT MemberEmail__c LIKE '%@marvell.com'
		]);
	}

	public void execute(Database.BatchableContext context, List<Object> scope) {
		System.debug(LoggingLevel.Error, 'batch number = ' + batchNumber++);
		Marvell_Case_Team__c[] marvellCaseTeams = (Marvell_Case_Team__c[]) scope;
		Set<Id> marvellCaseTeamIds = (new Map<Id, Marvell_Case_Team__c>(marvellCaseTeams)).keySet();
		EVE_ConversionResultDTO result = EVE_MarvellConvert.convertMarvellCaseTeams(marvellCaseTeamIds);
		totals = totals.add(result);
	}

	public void finish(Database.BatchableContext context) {
		Log__c log  = new Log__c(
			Timestamp__c = Datetime.now(),
			Source__c = EVE_MarvellConvert.LOG_SOURCE_CASE_TEAM,
			Message__c = totals.toString());
		System.debug(LoggingLevel.Error, 'log = ' + JSON.serializePretty(log));
		insert log;
		EVE_MarvellConvert.disableMarvellCustomSetting();

	}
}