public without sharing class EVE_DeleteFeedItemsBatch implements Database.Batchable<SObject>, Database.Stateful {

	private Integer batchNumber ;
	private String feedItemType;

	public EVE_DeleteFeedItemsBatch(String feedItemType) {
		EVE_MarvellConvert.setupMarvellCustomSetting();
		this.batchNumber = 1;
		this.feedItemType = feedItemType;
	}

	public Database.QueryLocator start(Database.BatchableContext context) {
		Case[] convertedCases = [
			SELECT Id, RelatedToId__c
			FROM Case
			WHERE RelatedToId__c LIKE 'Marvell-%'];
		Set<Id> convertedCasesIds = (new Map<Id, Case>(convertedCases)).keySet();
		return Database.getQueryLocator([
			SELECT Id
			FROM FeedItem
			WHERE Type = :feedItemType
			AND ParentId IN :convertedCasesIds
		]);
	}

	public void execute(Database.BatchableContext context, List<Object> scope) {
		FeedItem[] feedItems = (FeedItem[]) scope;
		delete feedItems;
	}

	public void finish(Database.BatchableContext context) {
		EVE_MarvellConvert.disableMarvellCustomSetting();
	}

}