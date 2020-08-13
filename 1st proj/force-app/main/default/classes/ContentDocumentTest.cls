/*
Name:ContentDocumentTest
Developed by:Sonal Gupta
Functionality:For testing the restriction of upload and delete of files on some criteria
Ticket number:SFC-2688,2684
-----------------------------------------------------------------------------------
Modified By :   Nisha Agrawal
Modified Date:  Jan 28, 2020
Description :   Updated to resolve issues on exception received in test classes 
***********************************************************************************************/

@istest
public class ContentDocumentTest 
{
    //to test with assigned to user
    @istest static void contentDocumentTestMethod()
    {
        Id childAccountTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Child Account').getRecordTypeId();        
        Account childAccount = new Account(Name = 'Test Child', RecordTypeId = childAccountTypeId); 
        insert childAccount;
        system.assert(childAccount.Id != null);
        
        String strContactEmail1 = 'test.contact1@abc.nxp.com';
        String strContactEmail2 = 'test.contact2@abc.nxp.com';
        
        Contact testContact1 = new Contact(FirstName = 'test First', LastName = 'test Last', Email = strContactEmail1, 
                                           AccountId = childAccount.Id, Community_web_country__c = 'India');
        Contact testContact2 = new Contact(FirstName = 'test First', LastName = 'test Last', Email = strContactEmail2, 
                                           AccountId = childAccount.Id, Community_web_country__c = 'India');
        
        List<Contact> lstContacts = new List<Contact>();
        lstContacts.add(testContact1);
        lstContacts.add(testContact2);        
        insert lstContacts;
     
        List<Case> lstCases = new List<Case>();
        Id tscommunityRecordType = Schema.SObjectType.Case.getRecordTypeInfosByName().get('TS Community').getRecordTypeId();
        Case objCase1 = new Case(RecordTypeID = tscommunityRecordType, contactId = testContact1.Id, Status= 'New', Priority = 'Medium', 
                                    Subject = 'test_subject_1', Description = 'test_description_1'); 
        Case objCase2 = new Case(RecordTypeID = tscommunityRecordType, contactId = testContact2.Id, Status= 'New', Priority = 'Medium', 
                                    Subject = 'test_subject_2', Description = 'test_description_2'); 
        lstCases.add(objCase1);
        lstCases.add(objCase2);
        
        insert lstCases;
        
        //create test internal user
        User objUser = TestUtil.createTestUser('test.internal@ncp.nxp.com', 'inter', CasePortalUtil.INTERNAL_AGENT_PROFILE_ID);
        insert objUser;
        system.assert(objUser.Id != null);

        Test.startTest();
        system.runAs(objUser)
        {
            List<ContentVersion> lstContentVersion = new List<ContentVersion>();        
            ContentVersion objContentVersion1 = new ContentVersion(Title = 'Penguins', PathOnClient = 'Penguins.jpg', VersionData = Blob.valueOf('Test Content'),
                                                                   IsMajorVersion = true);
            ContentVersion objContentVersion2 = new ContentVersion(Title = 'Penguins', PathOnClient = 'Penguins.jpg', VersionData = Blob.valueOf('Test Content'),
                                                                   IsMajorVersion = true);            
            lstContentVersion.add(objContentVersion1);
            lstContentVersion.add(objContentVersion2);        
            insert lstContentVersion;
            
            Set<Id> versionIds = new Set<Id>();
            versionIds.add(objContentVersion1.Id);
            versionIds.add(objContentVersion2.Id);
            
            List<ContentDocument> lstDocuments = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument Where LatestPublishedVersionId in : versionIds];
            system.assert(lstDocuments.size() == 2);
            
            List<ContentDocumentLink> lstDocumentLinks = new List<ContentDocumentLink>();
            ContentDocumentLink objCDLink1 = new ContentDocumentLink(ContentDocumentId=lstDocuments[0].Id, LinkedEntityId = objCase1.Id, ShareType= 'I');
            ContentDocumentLink objCDLink2 = new ContentDocumentLink(ContentDocumentId=lstDocuments[1].Id, LinkedEntityId = objCase2.Id, ShareType= 'I');
            
            lstDocumentLinks.add(objCDLink1);
            lstDocumentLinks.add(objCDLink2);            
            insert lstDocumentLinks;            
            
            //to cover delete method
            delete objCDLink1;            
        }
        test.stopTest();
    }
}