@isTest(SeeAllData = false)
public with sharing class EVE_MarvellConvertTest {

    private static Integer fakeIdCounter = 1;

    @TestSetup
    public static void setupMarvellData() {
        Id projectId = getFakeId(Schema.Marvell_Project__c.SObjectType);
        Marvell_Project__c marvellProject = setupMarvellProjects(projectId);
        insert marvellProject;

        Id accountId = getFakeId(Schema.Account.SObjectType);
        Id contactId = getFakeId(Schema.Marvell_Contact__c.SObjectType);
        Marvell_Contact__c marvellContact = setupMarvellContact(accountId, contactId);
        insert  marvellContact;

        Id marvellCaseId = getFakeId(Schema.Marvell_Case__c.SObjectType);
        Marvell_Case__c marvellCase = setupMarvellCase(marvellCaseId, projectId);
        insert  marvellCase;

        Id marvellCaseTeamId = getFakeId(Schema.Marvell_Case_Team__c.SObjectType);
        Marvell_Case_Team__c marvellCaseTeam = setupMarvellCaseTeam(marvellCaseTeamId, marvellCaseId);
        insert marvellCaseTeam;

        Marvell_CaseComment__c marvellInternalCaseComment = setupInternalCaseComment(marvellCaseId);
        insert marvellInternalCaseComment;

        Marvell_CaseComment__c marvellCustomerCaseComment = setupCustomerCaseComment(marvellCaseId);
        insert marvellCustomerCaseComment;

        Marvell_Attachment__c marvellAttachment = setupMarvellAttachemnt(marvellCaseId);
        insert marvellAttachment;
    }

    private static String getFakeId(Schema.SObjectType type) {
        String result = String.valueOf(fakeIdCounter++);
        return type.getDescribe().getKeyPrefix() + '0'.repeat(12 - result.length()) + result;
    }

    public static Marvell_Attachment__c setupMarvellAttachemnt(Id marvellCaseId) {
        Marvell_Attachment__c marvellAttachment = new Marvell_Attachment__c();
        marvellAttachment.ParentId__c = marvellCaseId;
        marvellAttachment.ID__c = getFakeId(Schema.Marvell_Attachment__c.SObjectType);
        marvellAttachment.CreatedDateText__c = '2019-04-21 13:46:16';
        marvellAttachment.OwnerId__c = UserInfo.getUserId();
        return marvellAttachment;
    }

    public static Marvell_CaseComment__c setupInternalCaseComment(Id marvellCaseId) {
        Marvell_CaseComment__c marvellCaseComment = new Marvell_CaseComment__c();
        marvellCaseComment.InternalCustomer__c = 'Internal';
        marvellCaseComment.Comments__c = 'TEST Comment';
        marvellCaseComment.CreatedByName__c = 'Test Name';
        marvellCaseComment.MarvellCaseId__c = marvellCaseId;
        marvellCaseComment.Marvell_Id__c = getFakeId(Schema.Marvell_CaseComment__c.SObjectType);
        return marvellCaseComment;
    }

    public static Marvell_CaseComment__c setupCustomerCaseComment(Id marvellCaseId) {
        Marvell_CaseComment__c marvellCaseComment = new Marvell_CaseComment__c();
        marvellCaseComment.InternalCustomer__c = 'Customer';
        marvellCaseComment.Comments__c = 'TEST Comment';
        marvellCaseComment.CreatedByName__c = 'Test Name';
        marvellCaseComment.MarvellCaseId__c = marvellCaseId;
        marvellCaseComment.Marvell_Id__c = getFakeId(Schema.Marvell_CaseComment__c.SObjectType);
        return marvellCaseComment;
    }

    public static Marvell_Case_Team__c setupMarvellCaseTeam(Id marvellCaseTeamId, Id marvellCaseId) {
        Marvell_Case_Team__c marvellCaseTeam = new Marvell_Case_Team__c();
        marvellCaseTeam.Marvell_Id__c = marvellCaseTeamId;
        marvellCaseTeam.TeamRoleName__c = 'Internal';
        marvellCaseTeam.ParentId__c = marvellCaseId;
        marvellCaseTeam.MemberEmail__c = 'test@ema.il';
        return marvellCaseTeam;
    }

    public static Marvell_Project__c setupMarvellProjects(Id projectId) {
        Marvell_Project__c marvellProject = new Marvell_Project__c();
        marvellProject.Name = 'Marvell Project Test Name';
        marvellProject.CreatedDate__c = System.now().addDays(-60);
        marvellProject.ProjectId__c = projectId;
        return marvellProject;
    }

    public static Marvell_Case__c setupMarvellCase(Id marvellCaseId, Id projectId) {
        Marvell_Case__c marvellCase = new Marvell_Case__c();
        marvellCase.Status__c = 'In Progress';
        marvellCase.CreatedDate__c = System.now().addDays(-60);
        marvellCase.ProjectId__c = projectId;
        marvellCase.External_Id__c = marvellCaseId;
        marvellCase.ExcludeStats__c = false;
        marvellCase.Priority__c = 'Critical';
        marvellCase.AccountName__c = 'Test Account Name';
        marvellCase.ContactEmail__c = 'test@ema.il';
        marvellCase.OwnerEmail__c = 'owner@ema.il';
        marvellCase.Description__c = 'Description';
        marvellCase.ServicesPartNumberName__c = 'TEST123';
        marvellCase.Region__c = 'Canada';
        marvellCase.Subject__c = 'Subject';
        marvellCase.CaseNumber__c = 1234;
        return marvellCase;
    }

    public static Marvell_Contact__c setupMarvellContact(Id accountId, Id contactId) {
        Marvell_Contact__c marvellContact = new Marvell_Contact__c();
        marvellContact.AccountId__c = accountId;
        marvellContact.AccountName__c = 'Test Account Name';
        marvellContact.Email__c = 'test@ema.il';
        marvellContact.Region__c = 'Canada';
        marvellContact.AssistantName__c = 'Test Assistant';
        marvellContact.AssistantPhone__c = '123';
        marvellContact.Birthdate__c = System.today().addYears(-30).addMonths(-2).addDays(-10);
        marvellContact.Fax__c = '321';
        marvellContact.Phone__c = '123456789';
        marvellContact.HomePhone__c = '555555';
        marvellContact.MobilePhone__c = '666666';
        marvellContact.MailingStreet__c = 'Mailing Street Name';
        marvellContact.MailingCity__c = 'Mailing City Name';
        marvellContact.MailingState__c = 'STate';
        marvellContact.MailingPostalCode__c = 'EE1122';
        marvellContact.MailingCountry__c = 'Canada';
        marvellContact.OtherStreet__c = 'Other Street Name';
        marvellContact.OtherCity__c = 'Other City Name';
        marvellContact.OtherState__c = 'STate';
        marvellContact.OtherPostalCode__c = 'EE1122';
        marvellContact.OtherCountry__c = 'Canada';
        marvellContact.Salutation__c = 'Mr.';
        marvellContact.FirstName__c = 'TestFirst';
        marvellContact.LastName__c ='TestLast';
        marvellContact.Title__c = 'Doc';
        marvellContact.Description__c = 'Description';
        marvellContact.ContactRole__c = 'Engineer';
        marvellContact.Marvell_Id__c = contactId;
        return marvellContact;
    }

    @isTest
    public static void testProjectConvert() {
        EVE_MarvellConvert.setupMarvellCustomSetting();
        EVE_MarvellConvert.convertMarvellProjects();
        Entitlement[] entitlements = [SELECT Id, Name, Marvell_Id__c FROM Entitlement];
        System.assertEquals(1, entitlements.size(), 'expected 1 converted');
        EVE_MarvellConvert.disableMarvellCustomSetting();
    }

    @isTest
    public static void testContactConvert() {
        EVE_MarvellConvert.setupMarvellCustomSetting();
        EVE_MarvellConvert.convertMarvellContacts();
        Contact[] contacts = [SELECT ID FROM Contact WHERE Legacy_Id__c != null];
        System.assertEquals(1, contacts.size(), 'expected 1 converted');
        EVE_MarvellConvert.disableMarvellCustomSetting();
    }

    @isTest
    public static void testCaseConvert() {
        EVE_MarvellConvert.setupMarvellCustomSetting();
        Contact testcontact = new Contact();
        testcontact.LastName = 'test';
        testcontact.email='test@ema.il';
        testcontact.Community_web_country__c = 'testcountry';
        insert testcontact;
        EVE_MarvellConvert.convertMarvellProjects();
        Test.startTest();
        EVE_MarvellConvert.convertMarvellCases();
        Test.stopTest();
        Case[] cases = [SELECT ID FROM Case WHERE RelatedToId__c != null];
        System.assertEquals(1, cases.size(), 'expected 1 converted');
        EVE_MarvellConvert.disableMarvellCustomSetting();
    }

    @isTest
    public static void testCaseTeamConvert() {
        EVE_MarvellConvert.setupMarvellCustomSetting();
        EVE_MarvellConvert.convertMarvellContacts();
        EVE_MarvellConvert.convertMarvellProjects();
        Test.startTest();
        EVE_MarvellConvert.convertMarvellCases();
        EVE_MarvellConvert.createEntitlementContactsForAllEntitlements();
        EVE_MarvellConvert.convertMarvellCaseTeams();
        Test.stopTest();
        Entitlement_Contact__c[] entitlementContacts = [SELECT ID FROM Entitlement_Contact__c];
        System.assertEquals(1, entitlementContacts.size(), 'expected 1 converted');
        EVE_MarvellConvert.disableMarvellCustomSetting();
    }

    @isTest
    public static void testInternalCaseCommentConvert() {
        EVE_MarvellConvert.setupMarvellCustomSetting();
        EVE_MarvellConvert.convertMarvellContacts();
        EVE_MarvellConvert.convertMarvellProjects();
        Test.startTest();
        EVE_MarvellConvert.convertMarvellCases();
        EVE_MarvellConvert.convertMarvellInternalCaseComments();
        Test.stopTest();
        FeedItem[] feedItems = [SELECT ID, Type, Title FROM FeedItem WHERE Type = 'TextPost'];
        System.assertEquals(1, feedItems.size(), 'expected 1 converted');
        EVE_MarvellConvert.disableMarvellCustomSetting();
    }

    @isTest
    public static void testCustomerCaseCommentConvert() {
        EVE_MarvellConvert.setupMarvellCustomSetting();
        EVE_MarvellConvert.convertMarvellContacts();
        EVE_MarvellConvert.convertMarvellProjects();
        Test.startTest();
        EVE_MarvellConvert.convertMarvellCases();
        EVE_MarvellConvert.convertMarvellCustomerCaseComments();
        Test.stopTest();
        EmailMessage[] emailMessages = [SELECT ID FROM EmailMessage WHERE Marvell_Id__c != null];
        System.assertEquals(1, emailMessages.size(), 'expected 1 converted');
        EVE_MarvellConvert.disableMarvellCustomSetting();
    }

    @isTest
    public static void testDeleteFeedItemBatch() {
        EVE_MarvellConvert.setupMarvellCustomSetting();
        Contact testcontact = new Contact();
        testcontact.LastName = 'test';
        testcontact.email='test@ema.il';
        testcontact.Community_web_country__c = 'testcountry';
        insert testcontact;
        Case theCase = new Case(Subject = 'test', ContactId = testcontact.Id);
        insert theCase;
        insert new FeedItem(ParentId = theCase.Id, Type = 'EmailMessageEvent');
        Test.startTest();
        Id batchId = Database.executeBatch(new EVE_DeleteFeedItemsBatch('EmailMessageEvent'));
        Test.stopTest();
        FeedItem[] feedItems = [SELECT ID, ParentId, Parent.Type, Type FROM FeedItem];
        System.assertEquals(1, feedItems.size(), 'expected 1 feedItems');
        EVE_MarvellConvert.disableMarvellCustomSetting();
    }

}