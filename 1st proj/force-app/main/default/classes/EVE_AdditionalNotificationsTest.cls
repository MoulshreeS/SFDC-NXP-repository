@IsTest
private class EVE_AdditionalNotificationsTest {
	@TestSetup
	static void testSetup() {
		Account anAccount = new Account(Name = 'testAccount');
		insert anAccount;
		Contact aContact = new Contact(FirstName = 'First', LastName = 'Last', Email = 'test@test.tst', Community_web_country__c = 'Peru');
		insert aContact;
		Entitlement anEntitlement = new Entitlement(AccountId = anAccount.Id, Name = 'Test Ent Name', Marvell_Id__c = 'test');
		insert anEntitlement;
		Case aCase = new Case(EntitlementId = anEntitlement.Id, ContactId = aContact.Id, RelatedToId__c = 'Marvell-123');
		insert aCase;
		Entitlement_Contact__c anEntitlementContact = new Entitlement_Contact__c(Entitlement__c = anEntitlement.Id, Contact__c = aContact.Id);
		insert anEntitlementContact;
	}

	@IsTest
	static void testNotifyCaseContacts() {
		Contact[] contacts = [SELECT Id FROM Contact];
		Case[] cases = [SELECT Id FROM Case];
		EVE_AdditionalNotifications.notifyCaseContacts();
	}

	@IsTest
	static void testNotifyEntitlementContacts() {
		Entitlement[] entitlements = [SELECT Id FROM Entitlement];
		Entitlement_Contact__c[] entitlementContacts = [SELECT Id FROM Entitlement_Contact__c];
		EVE_AdditionalNotifications.notifyEntitlementContacts();
	}

	@IsTest
	static void testNotifyCaseContactsBatch() {
		Test.startTest();
		EVE_AdditionalNotifications.notifyCaseContactsBatchRun();
		Test.stopTest();
	}

	@IsTest
	static void testNotifyEntContactsBatch() {
		Test.startTest();
		EVE_AdditionalNotifications.notifyEntitlementContactsBatchRun();
		Test.stopTest();
	}
}