/******************************************************************************************************************
@Created By:		Nisha Agrawal
@Created Date:		Oct 22, 2018
@Description:		Test class for LeadPortalJITHandler class 
--------------------------------------------------------------------
@Modified By:		Nisha Agrawal
@Modified Date:		Oct 06, 2018
@Description:		Modified to include test scenario when user already exists as customer community user 
					and need access to Lead Portal
******************************************************************************************************************/

@isTest
private class LeadPortalJITHandlerTest 
{
    private static Id parentAccountRecordTypeId;
    private static Id childAccountRecordTypeId;
    
	private static final String strFederationId = 'testId'; 
	private static final Map<String, String> attributes = new Map<String, String> 
                                                {
                                                    'User.Email' => 'test.newuser@disti.com',
													'User.FirstName' => 'First',
                                                    'User.LastName' => 'Last',
													'User.CompanyName' => 'Disti',
                                                    'User.Country' => 'Germany'
                                                };
	private static final String strEmail = 'test.newuser@disti.com';
	private static final String strAccountName = 'Disti Child 1'; 
        
    @testsetup
    static void setupTestData()
    {
        //create account
        //fetch record types for account
        parentAccountRecordTypeId = AccountHelper.getParentRecordTypeID();
        childAccountRecordTypeId = AccountHelper.getChildRecordTypeID();
        //create parent account
        Account parentAccount = new Account(Name = 'Disti Parent 1', RecordTypeId = parentAccountRecordTypeId, Region__c = 'EMEA');
        insert parentAccount;
        system.assert(parentAccount.Id != null);

        //create child account
		Account childAccount = new Account(Name = strAccountName, ParentId = parentAccount.Id, RecordTypeId = childAccountRecordTypeId, 
                                         		Region__c = 'EMEA', Country__c = 'Test Country', ZIP_Postal_Code__c = '12345');  
        insert childAccount;
        system.assert(childAccount.Id != null);
        
        //insert custom setting
        
        List<Profile> lstProfiles = [Select Id, Name from Profile Where Name = 'NXP Customer Community Login User' Limit 1];
        system.assert(lstProfiles.size() > 0);
                
		CommunitySettings__c cs = new CommunitySettings__c (Name = 'CommunityUrl');
        cs.CommunityUserProfileId__c = lstProfiles[0].Id;   		
		insert cs;        
        system.assert(cs.Id != null);
    }
  
    @isTest
    static void TestCreateUser_UserFoundByFederationId()
    {
        //create a test user with given federation id
        LeadPortalLib.getExternalUserProfile();
        Id profileId = LeadPortalLib.LP_EXTERNAL_PROFILE_Id;
        system.assert(profileId != null, 'Error Occured : Profile Not found.');
    
        List<Account> lstAccounts = [Select Id, Name From Account Where Name =: strAccountName];
        system.assert(lstAccounts.size() > 0);
        
        //create contact for child account
        Contact objContact = new Contact(AccountId = lstAccounts[0].Id, FirstName = 'Test', LastName = 'Disti 1' , Email = strEmail, Community_web_country__c = 'USA' );
    	insert objContact;
        system.assert(objContact.Id != null);
        
        User objUser = TestUtil.createTestUser(strEmail, 'test1234', profileId);
        objUser.FederationIdentifier = strFederationId;
        objUser.ContactId = objContact.Id;
        insert objUser;
        system.assert(objUser.Id != null);
        
        Test.startTest();
        
        LeadPortalJITHandler objHandler = new LeadPortalJITHandler();
        User returnedUser = objHandler.createUser(null, null, null, strFederationId, attributes, '');
        //assert the results
        system.assert(returnedUser != null);
        system.assert(returnedUser.Id == objUser.Id);
        
        Test.stopTest(); 
    }
    
    @isTest
    static void TestCreateUser_UserFoundByEmail()
    {
        //create a test user with given Email
        LeadPortalLib.getExternalUserProfile();
        Id profileId = LeadPortalLib.LP_EXTERNAL_PROFILE_Id;
        system.assert(profileId != null, 'Error Occured : Profile Not found.');
    
        List<Account> lstAccounts = [Select Id, Name From Account Where Name =: strAccountName];
        system.assert(lstAccounts.size() > 0);
        
        //create contact for child account
        Contact objContact = new Contact(AccountId = lstAccounts[0].Id, FirstName = 'Test', LastName = 'Disti 1' , Email = strEmail, Community_web_country__c = 'USA' );
    	insert objContact;
        system.assert(objContact.Id != null);
        
        User objUser = TestUtil.createTestUser(strEmail, 'test1234', profileId);
        objUser.ContactId = objContact.Id;
        insert objUser;
        system.assert(objUser.Id != null);
        
        Test.startTest();
        
        LeadPortalJITHandler objHandler = new LeadPortalJITHandler();
        User returnedUser = objHandler.createUser(null, null, null, strFederationId, attributes, '');
        //assert the results
        system.assert(returnedUser != null);
        system.assert(returnedUser.Id == objUser.Id);
    }    
    
    @isTest
    static void TestCreateUser_ContactExists()
    {
        List<Account> lstAccounts = [Select Id, Name From Account Where Name =: strAccountName];
        system.assert(lstAccounts.size() > 0);
        
        //create contact for child account
        Contact objContact = new Contact(AccountId = lstAccounts[0].Id, FirstName = 'Test', LastName = 'Disti 1' , Email = strEmail, Community_web_country__c = 'USA' );
    	insert objContact;
        system.assert(objContact.Id != null);
        
        Test.StartTest();
        
        LeadPortalJITHandler objHandler = new LeadPortalJITHandler();
        User returnedUser = objHandler.createUser(null, null, null, strFederationId, attributes, '');
        //assert the results
        system.assert(returnedUser != null);
        system.assert(returnedUser.Email == strEmail);
                
        Test.StopTest();
    }
    
    //Negative Test
    @isTest
    static void TestCreateUser_ContactNotExists()
    {
        Test.StartTest();
        
        LeadPortalJITHandler objHandler = new LeadPortalJITHandler();
        User returnedUser = objHandler.createUser(null, null, null, strFederationId, attributes, '');
        //assert the results
        system.assert(returnedUser == null);
                       
        Test.StopTest();
    }
    
    @isTest
    static void TestUpdateUser()
    {
        //create a test user with given Email
        LeadPortalLib.getExternalUserProfile();
        Id profileId = LeadPortalLib.LP_EXTERNAL_PROFILE_Id;
        system.assert(profileId != null, 'Error Occured : Profile Not found.');
    
        List<Account> lstAccounts = [Select Id, Name From Account Where Name =: strAccountName];
        system.assert(lstAccounts.size() > 0);
        
        //create contact for child account
        Contact objContact = new Contact(AccountId = lstAccounts[0].Id, FirstName = 'Test', LastName = 'Disti 1' , Email = strEmail, Community_web_country__c = 'USA' );
    	insert objContact;
        system.assert(objContact.Id != null);
        
        User objUser = TestUtil.createTestUser(strEmail, 'test1234', profileId);
        objUser.ContactId = objContact.Id;
        insert objUser;
        system.assert(objUser.Id != null);
        
        Test.startTest();
        
        LeadPortalJITHandler objHandler = new LeadPortalJITHandler();
        objHandler.updateUser(objUser.Id, null, null, null, strFederationId, attributes, '');
        
        Test.stopTest();
        
        //assert the results        
        List<User> lstUsers = [Select Id, FirstName, LastName, Disti_Lead_Portal_User_Role__c From User Where Id =: objUser.Id limit 1];
        system.assert(lstUsers.size() > 0);
        
        objUser = lstUsers[0];
        system.assert(objUser.FirstName == 'First');
        system.assert(objUser.LastName == 'Last');
    }
    
    @isTest
    static void TestUpdateUser_FromCustomerCommunityToPartnerCommunity()
    {
        //create a test user with given Email
        LeadPortalLib.getExternalUserProfile();
        Id profileId = LeadPortalLib.LP_EXTERNAL_PROFILE_Id;
        system.assert(profileId != null, 'Error Occured : Profile Not found.');
    
        List<Account> lstAccounts = [Select Id, Name From Account Where Name =: strAccountName];
        system.assert(lstAccounts.size() > 0);
        
        //create contact for child account
        Contact objContact = new Contact(AccountId = lstAccounts[0].Id, FirstName = 'Test', LastName = 'Disti 1' , Email = strEmail, Community_web_country__c = 'USA' );
    	insert objContact;
        system.assert(objContact.Id != null);
        
        CasePortalUtil.getCustomerCommunityUserProfile();
        Id customerProfileId = CasePortalUtil.CUSTOMER_COMMUNITY_USER_PROFILE_ID;
        
        User objUser = TestUtil.createTestUser(strEmail, 'test1234', customerProfileId);
        objUser.ContactId = objContact.Id;
        insert objUser;
        system.assert(objUser.Id != null);
        
        Test.startTest();
        
        LeadPortalJITHandler objHandler = new LeadPortalJITHandler();
        objHandler.updateUser(objUser.Id, null, null, null, strFederationId, attributes, '');

        Test.stopTest();
		//assert the results        
        List<User> lstUsers = [Select Id, FirstName, LastName, Disti_Lead_Portal_User_Role__c From User Where Id =: objUser.Id limit 1];
        system.assert(lstUsers.size() > 0);
        
        objUser = lstUsers[0];
        system.assert(objUser.Disti_Lead_Portal_User_Role__c == 'User');
        system.assert(objUser.FirstName == 'First');
        system.assert(objUser.LastName == 'Last');
        
        List<Contact> lstContacts = [Select Id, FirstName, LastName,Company__c, Community_web_country__c From Contact Where Id =: objContact.Id Limit 1];
        system.assert(lstContacts.size() > 0);
        
        objContact = lstContacts[0];
        system.assert(objContact.FirstName == 'First');
        system.assert(objContact.LastName == 'Last');
        system.assert(objContact.Company__c == 'Disti');
        system.assert(objContact.Community_web_country__c == 'Germany');        
    }
}