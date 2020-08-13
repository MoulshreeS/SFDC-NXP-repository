@isTest
public with sharing class EVE_ConvertCaseCommentDatesBatchTest {

	@testSetup
	private static void setup() {
		Marvell_CaseComment__c marvellCaseComment = setupMarvellCaseComment();
		insert marvellCaseComment;
	}

	private static Marvell_CaseComment__c setupMarvellCaseComment() {
		Marvell_CaseComment__c record = new Marvell_CaseComment__c();
		record.InternalCustomer__c = 'Customer';
		record.Comments__c = 'TEST Comment';
		record.CreatedByName__c = 'Test Name';
		record.CreatedDate_Text__c = '5/25/17 1:02';
		record.LastModifiedDate_Text__c = '5/25/17 1:02';
		String idPrefix = Schema.Marvell_CaseComment__c.SObjectType.getDescribe().getKeyPrefix();
		record.Marvell_Id__c = idPrefix + '000000000001';
		return record;
	}

	@isTest
	public static void testBatch() {
		Test.startTest();
		EVE_ConvertMarvellCaseCommentDatesBatch batch = new EVE_ConvertMarvellCaseCommentDatesBatch();
		Id batchId = Database.executeBatch(batch);
		Test.stopTest();
		Marvell_CaseComment__c[] marvellCaseComments = [
			SELECT CreatedDate__c, LastModifiedDate__c
			FROM Marvell_CaseComment__c
		];
		System.assertEquals(1, marvellCaseComments.size(), 'wrong case comments number');
		Marvell_CaseComment__c caseComment = marvellCaseComments[0];
		System.assertNotEquals(null, caseComment.CreatedDate__c, 'Created Date should not be empty');
		System.assertNotEquals(null, caseComment.LastModifiedDate__c, 'Last Modified Date should not be empty');
	}
}