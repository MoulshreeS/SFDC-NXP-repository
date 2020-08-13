public with sharing class EVE_ConvertMarvellCaseCommentDatesBatch implements Database.Batchable<SObject>, Database.Stateful {

	private Integer batchNumber ;

	public EVE_ConvertMarvellCaseCommentDatesBatch() {
		this.batchNumber = 1;
	}

	public Database.QueryLocator start(Database.BatchableContext context) {
		return Database.getQueryLocator([
				SELECT Id, CreatedDate_Text__c, CreatedDate__c,
						LastModifiedDate_Text__c, LastModifiedDate__c
				FROM Marvell_CaseComment__c
				WHERE (CreatedDate__c = null AND CreatedDate_Text__c != null)
				OR (LastModifiedDate__c  = null AND LastModifiedDate_Text__c != null)
				ORDER BY Id ASC
		]);
	}

	public void execute(Database.BatchableContext context, List<Object> scope) {
		System.debug(LoggingLevel.Error, 'batch number = ' + batchNumber++);
		Marvell_CaseComment__c[] marvellCaseComments = (Marvell_CaseComment__c[]) scope;
		for (Marvell_CaseComment__c marvellCaseComment : marvellCaseComments) {
			if (marvellCaseComment.CreatedDate__c == null && marvellCaseComment.CreatedDate_Text__c != null) {
				marvellCaseComment.CreatedDate__c = parseDateTime(marvellCaseComment.CreatedDate_Text__c);
			}
			if (marvellCaseComment.LastModifiedDate__c == null && marvellCaseComment.LastModifiedDate_Text__c != null) {
				marvellCaseComment.LastModifiedDate__c = parseDateTime(marvellCaseComment.LastModifiedDate_Text__c);
			}
		}
		
		update marvellCaseComments;
	}

	public void finish(Database.BatchableContext context) {}

	private Datetime parseDateTime(String input) {
		if (String.isBlank(input)) {
			return null;
		}
		List<String> dateAndTime = input.split(' ');
		String aDate = dateAndTime.get(0);
		String aTime = dateAndTime.get(1);
		List<String> monthDayYear = aDate.split('/');
		List<String> hourMinute = aTime.split(':');
		Integer month = Integer.valueOf(monthDayYear.get(0));
		Integer day = Integer.valueOf(monthDayYear.get(1));
		Integer year = Integer.valueOf(monthDayYear.get(2)) + 2000;
		Integer hour = Integer.valueOf(hourMinute.get(0));
		Integer minute = Integer.valueOf(hourMinute.get(1));
		DateTime output = DateTime.newInstanceGmt(year, month, day, hour, minute, 0).addHours(8);
		return output;
	}
}