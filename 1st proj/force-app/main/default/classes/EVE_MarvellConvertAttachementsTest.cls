@IsTest
private class EVE_MarvellConvertAttachementsTest {

    private static Integer fakeIdCounter = 1;
    private static Id currentUserId = UserInfo.getUserId();

    @TestSetup
    public static void setupMarvellData() {
        setupMarvellCustomSetting();
        Id projectId = getFakeId(Schema.Marvell_Project__c.SObjectType);

        Id marvellCaseId = getFakeId(Schema.Case.SObjectType);
        Marvell_Case__c marvellCase = setupMarvellCase(marvellCaseId, projectId);
        insert  marvellCase;

        Id marvellCaseCommentId = 'a0A000000000003AAA';
        Marvell_CaseComment__c marvellInternalCaseComment = setupInternalCaseComment(marvellCaseId, marvellCaseCommentId);
        insert marvellInternalCaseComment;
        
        Contact testcontact = new Contact();
        testcontact.LastName = 'test';
        testcontact.email='test@test.ts';
        testcontact.Community_web_country__c = 'testcountry';
        insert testcontact;

        Case nxpCase = new Case();
        nxpCase.RelatedToId__c = 'Marvell-' + marvellCaseId;
        nxpCase.ContactId = testContact.Id;
        insert nxpCase;

        Marvell_Attachment__c marvellCaseAttachment = setupMarvellAttachemnt(marvellCaseId);
        Marvell_Attachment__c marvellCaseCommentAttachment = setupMarvellAttachemnt(marvellCaseCommentId);
        insert new Marvell_Attachment__c[]{marvellCaseAttachment, marvellCaseCommentAttachment};
    }

    private static String getFakeId(Schema.SObjectType type) {
        String result = String.valueOf(fakeIdCounter++);
        return type.getDescribe().getKeyPrefix() + '0'.repeat(12 - result.length()) + result;
    }

    private static void setupMarvellCustomSetting(){
        Marvell_Migration__c userCustomSetting = Marvell_Migration__c.getInstance(currentUserId);
        if (userCustomSetting == null) {
            userCustomSetting = new Marvell_Migration__c(SetupOwnerId = currentUserId);
        }
        userCustomSetting.IsActive__c = true;
        upsert userCustomSetting;
    }

    private static void disableMarvellCustomSetting(){
        Marvell_Migration__c userCustomSetting = Marvell_Migration__c.getInstance(currentUserId);
        if (userCustomSetting != null) {
            userCustomSetting.IsActive__c = false;
            update userCustomSetting;
        }
    }

    public static Marvell_Case__c setupMarvellCase(Id marvellCaseId, Id projectId) {
        Marvell_Case__c marvellCase = new Marvell_Case__c();
        marvellCase.Status__c = 'In Progress';
        marvellCase.CreatedDate__c = System.now().addDays(-60);
        marvellCase.ProjectId__c = projectId;
        marvellCase.External_Id__c = marvellCaseId;
        return marvellCase;
    }

    public static Marvell_CaseComment__c setupInternalCaseComment(Id marvellCaseId, Id marvellCaseCommentId) {
        Marvell_CaseComment__c marvellCaseComment = new Marvell_CaseComment__c();
        marvellCaseComment.InternalCustomer__c = 'Internal';
        marvellCaseComment.Comments__c = 'TEST Comment';
        marvellCaseComment.CreatedByName__c = 'Test Name';
        marvellCaseComment.MarvellCaseId__c = marvellCaseId;
        marvellCaseComment.Marvell_Id__c = marvellCaseCommentId;
        return marvellCaseComment;
    }

    public static Marvell_Attachment__c setupMarvellAttachemnt(Id marvellCaseId) {
        Marvell_Attachment__c marvellAttachment = new Marvell_Attachment__c();
        marvellAttachment.ParentId__c = marvellCaseId;
        marvellAttachment.ID__c = getFakeId(Schema.Marvell_Attachment__c.SObjectType);
        marvellAttachment.CreatedDateText__c = '2019-04-21 13:46:16';
        marvellAttachment.LastModifiedDateText__c = '2019-04-21 13:46:16';
        marvellAttachment.OwnerId__c = UserInfo.getUserId();
        return marvellAttachment;
    }

    @isTest
    public static void testUpdateMarvellAttachment() {
        Test.startTest();
        EVE_MarvellConvertAttachements.updateMarvellAttachments();
        Test.stopTest();
        Marvell_Attachment__c[] marvellAttachments = [SELECT ID, CaseID__c, Body__c, CreatedDate__c FROM Marvell_Attachment__c];
        System.assertEquals(2, marvellAttachments.size(), 'expected 1 converted');
        System.assertNotEquals(null, marvellAttachments[0].CaseID__c, 'expected not null');
        System.assertNotEquals(null, marvellAttachments[1].CaseID__c, 'expected not null');
        System.assertNotEquals(null, marvellAttachments[0].Body__c, 'expected not null');
        System.assertNotEquals(null, marvellAttachments[1].Body__c, 'expected not null');
        System.assertNotEquals(null, marvellAttachments[0].CreatedDate__c, 'expected not null');
        System.assertNotEquals(null, marvellAttachments[1].CreatedDate__c, 'expected not null');
        disableMarvellCustomSetting();
    }
}