/******************************************************************************************************************
@Created By:		Nisha Agrawal
@Created Date:		Aug 30, 2019
@Description:		Test class for CasePortalJITHandler class
******************************************************************************************************************/
@isTest
public class CasePortalJITHandlerTest 
{
    private static Id parentAccountRecordTypeId;
    private static Id childAccountRecordTypeId;
    
    private static final String strFederationId = 'testId'; 
    private static final String strEmail = 'test.newuser@newco.com';
    private static final String strInternalUserEmail = 'test.internal@nxp.com';
    private static final Map<String, String> attributes = new Map<String, String> 
                                                {
                                                    'User.Email' => 'test.newuser@newco.com',
													'User.FirstName' => 'First',
                                                    'User.LastName' => 'Last',
													'User.CompanyName' => 'New Co',
                                                    'User.Country' => 'Germany'
                                                };
    private static final Map<String, String> attributesWithoutCountry = new Map<String, String> 
                                                {
                                                    'User.Email' => 'test.newuser@newco.com',
													'User.FirstName' => 'First',
                                                    'User.LastName' => 'Last',
													'User.CompanyName' => 'New Co'
                                                };
	private static final Map<String, String> attributesInternalUser = new Map<String, String> 
                                                {
                                                    'User.Email' => 'test.internal@nxp.com',
													'User.FirstName' => 'Test',
                                                    'User.LastName' => 'Employee',
													'User.CompanyName' => 'NXP',
                                                    'User.Country' => 'Germany'
                                                };
                                                    
    @testsetup
    static void setupTestData()
    {
        //create account
        //fetch record types for account
        parentAccountRecordTypeId = AccountHelper.getParentRecordTypeID();
        childAccountRecordTypeId = AccountHelper.getChildRecordTypeID();
        //create parent account
        Account parentAccount = new Account(Name = 'Customer Parent 1', RecordTypeId = parentAccountRecordTypeId, Region__c = 'EMEA');
        insert parentAccount;
        system.assert(parentAccount.Id != null);

        //create child account
		Account childAccount = new Account(Name = CasePortalJITHandler.ACCOUNT_NAME, ParentId = parentAccount.Id, RecordTypeId = childAccountRecordTypeId, 
                                         		Region__c = 'EMEA', Country__c = 'Test Country', ZIP_Postal_Code__c = '12345');  
        insert childAccount;
        system.assert(childAccount.Id != null);
        
        /*
        //insert custom setting        
        CasePortalUtil.getCustomerCommunityUserProfile();
        Id profileId = CasePortalUtil.CUSTOMER_COMMUNITY_USER_PROFILE_ID;
        system.assert(profileId != null);
                
		CommunitySettings__c cs = new CommunitySettings__c (Name = 'CommunityUrl');
        cs.CommunityUserProfileId__c = profileId;   		
		insert cs;        
        system.assert(cs.Id != null);
*/
    }
    
    @isTest static void TestCreateUser_UserFoundByFederationId()
    {
        //create a test user with given federation id
        CasePortalUtil.getCustomerCommunityUserProfile();
        Id profileId = CasePortalUtil.CUSTOMER_COMMUNITY_USER_PROFILE_ID;
        system.assert(profileId != null, 'Error Occured : Customer Community User Profile Not found.');
    
        List<Account> lstAccounts = [Select Id, Name From Account Where Name =: CasePortalJITHandler.ACCOUNT_NAME];
        system.assert(lstAccounts.size() > 0);
        
        //create contact for child account
        Contact objContact = new Contact(AccountId = lstAccounts[0].Id, FirstName = 'Test', LastName = 'Customer 1' , Email = strEmail, Community_web_country__c = 'USA' );
    	insert objContact;
        system.assert(objContact.Id != null);
        
        User objUser = TestUtil.createTestUser(strEmail, 'test1234', profileId);
        objUser.FederationIdentifier = strFederationId;
        objUser.ContactId = objContact.Id;
        insert objUser;
        system.assert(objUser.Id != null);
        
        Test.startTest();
        
        CasePortalJITHandler objHandler = new CasePortalJITHandler();
        User returnedUser = objHandler.createUser(null, null, null, strFederationId, attributes, '');
        //assert the results
        system.assert(returnedUser != null);
        system.assert(returnedUser.Id == objUser.Id);
        
        Test.stopTest(); 
    }
    
    @isTest static void TestCreateUser_UserFoundByEmail()
    {
        //create a test user with given Email
        CasePortalUtil.getCustomerCommunityUserProfile();
        Id profileId = CasePortalUtil.CUSTOMER_COMMUNITY_USER_PROFILE_ID;
        system.assert(profileId != null, 'Error Occured : Customer Community User Profile Not found.');
    
        List<Account> lstAccounts = [Select Id, Name From Account Where Name =: CasePortalJITHandler.ACCOUNT_NAME];
        system.assert(lstAccounts.size() > 0);
        
        //create contact for child account
        Contact objContact = new Contact(AccountId = lstAccounts[0].Id, FirstName = 'Test', LastName = 'Customer 1' , Email = strEmail, Community_web_country__c = 'USA' );
    	insert objContact;
        system.assert(objContact.Id != null);
        
        User objUser = TestUtil.createTestUser(strEmail, 'test1234', profileId);
        objUser.ContactId = objContact.Id;
        insert objUser;
        system.assert(objUser.Id != null);
        
        Test.startTest();
        
        CasePortalJITHandler objHandler = new CasePortalJITHandler();
        User returnedUser = objHandler.createUser(null, null, null, strFederationId, attributes, '');
        //assert the results
        system.assert(returnedUser != null);
        system.assert(returnedUser.Id == objUser.Id);
    }
    
    @isTest
    static void TestCreateUser_ContactExists()
    {
        List<Account> lstAccounts = [Select Id, Name From Account Where Name =: CasePortalJITHandler.ACCOUNT_NAME];
        system.assert(lstAccounts.size() > 0);
        
        //create contact for child account
        Contact objContact = new Contact(AccountId = lstAccounts[0].Id, FirstName = 'Test', LastName = 'Customer 1' , Email = strEmail, Community_web_country__c = 'USA' );
    	insert objContact;
        system.assert(objContact.Id != null);
        
        Test.StartTest();
        
        CasePortalJITHandler objHandler = new CasePortalJITHandler();
        User returnedUser = objHandler.createUser(null, null, null, strFederationId, attributes, '');
        //assert the results
        system.assert(returnedUser != null);
        system.assert(returnedUser.Email == strEmail);
                
        Test.StopTest();
    }
    
    @isTest static void TestCreateUser_ContactNotExists()
    {
        Test.StartTest();
        
        CasePortalJITHandler objHandler = new CasePortalJITHandler();
        User returnedUser = objHandler.createUser(null, null, null, strFederationId, attributesWithoutCountry, '');
        //assert the results
        system.assert(returnedUser != null);
        system.assert(returnedUser.Email == strEmail);
        CasePortalUtil.getCustomerCommunityUserProfile();
        system.assert(returnedUser.ProfileId == CasePortalUtil.CUSTOMER_COMMUNITY_USER_PROFILE_ID);
        
        Test.StopTest();
    }
    
    @isTest static void TestCreateUser_CCPlusLicenseUser()
    {
        //create a project
        Project__c testProject = CasePortalTestUtil.createTestProject('TestProject', 'In Development');
        insert testProject;        
        system.assert(testProject.Id != null);
        
        //create a project team record 
        Project_Team__c testMember = CasePortalTestUtil.createTestProjectTeam(testProject.Id, strEmail, CasePortalUtil.PROJECT_TEAM_STATUS_INVITED );
        insert testMember;
        system.assert(testMember.Id != null);        
        
        Test.StartTest();
        
        CasePortalJITHandler objHandler = new CasePortalJITHandler();
        User returnedUser = objHandler.createUser(null, null, null, strFederationId, attributesWithoutCountry, '');
        //assert the results
        system.assert(returnedUser != null);
        system.assert(returnedUser.Email == strEmail);
        system.assert(returnedUser.ProfileId == CasePortalUtil.CUSTOMER_COMMUNITY_PLUS_PROFILE_Id);
        Test.StopTest();
    }
    
    @isTest static void TestCreateUser_InternalUserFoundByFederationId()
    {
        List<Profile> lstProfiles = [SELECT Id FROM Profile WHERE Name='Standard User' LIMIT 1];
        system.assert(lstProfiles.size() > 0);
        Id profileId = lstProfiles[0].Id;
        
		User objUser = TestUtil.createTestUser(strInternalUserEmail, 'test1234', profileId);
        objUser.FederationIdentifier = strFederationId;
        insert objUser;
        system.assert(objUser.Id != null);
        
        Test.StartTest();
        
        CasePortalJITHandler objHandler = new CasePortalJITHandler();
        User returnedUser = objHandler.createUser(null, null, null, strFederationId, attributesInternalUser, '');    
        //assert the results
        system.assert(returnedUser != null);
        system.assert(returnedUser.Email == strInternalUserEmail);
        
        Test.StopTest();
    } 
    
    //negative test
    @isTest static void TestCreateUser_InternalUserNotExists()
    {
        Test.StartTest();
        
        CasePortalJITHandler objHandler = new CasePortalJITHandler();
        User returnedUser;
        try
        {
        	returnedUser = objHandler.createUser(null, null, null, strFederationId, attributesInternalUser, '');    
        }
        catch(Exception ex)
        {
            system.assert(ex.getMessage() == CasePortalJITHandler.ERROR_INTERNAL_USER_NOT_EXISTS);
        }
        
        //assert the results
        system.assert(returnedUser == null);
        //system.assert(returnedUser.Email == strEmail);
        
        Test.StopTest();
    }
    
    @isTest static void TestUpdateUser()
    {
        //create a test user with given Email
        CasePortalUtil.getCustomerCommunityUserProfile();
        Id profileId = CasePortalUtil.CUSTOMER_COMMUNITY_USER_PROFILE_ID;
        system.assert(profileId != null, 'Error Occured : Customer Community User Profile Not found.');
    
        List<Account> lstAccounts = [Select Id, Name From Account Where Name =: CasePortalJITHandler.ACCOUNT_NAME];
        system.assert(lstAccounts.size() > 0);
        
        //create contact for child account
        Contact objContact = new Contact(AccountId = lstAccounts[0].Id, FirstName = 'Test', LastName = 'Customer 1' , Email = strEmail, Community_web_country__c = 'USA' );
    	insert objContact;
        system.assert(objContact.Id != null);
        
        User objUser = TestUtil.createTestUser(strEmail, 'test1234', profileId);
        objUser.ContactId = objContact.Id;
        insert objUser;
        system.assert(objUser.Id != null);
        
        Test.startTest();
        
        CasePortalJITHandler objHandler = new CasePortalJITHandler();
        objHandler.updateUser(objUser.Id, null, null, null, strFederationId, attributes, '');
        
        Test.stopTest();
        
        //assert the results        
        List<User> lstUsers = [Select Id, FirstName, LastName From User Where Id =: objUser.Id limit 1];
        system.assert(lstUsers.size() > 0);
        
        objUser = lstUsers[0];
        system.assert(objUser.FirstName == 'First');
        system.assert(objUser.LastName == 'Last');
    }
    
    @isTest static void TestUpdateUser_FromPartnerCommunityToCustomerCommunity()
    {
        //create a test user with given Email
        CasePortalUtil.getCustomerCommunityUserProfile();
        Id profileId = CasePortalUtil.CUSTOMER_COMMUNITY_USER_PROFILE_ID;
        system.assert(profileId != null, 'Error Occured : Customer Community User Profile Not found.');
    
        List<Account> lstAccounts = [Select Id, Name From Account Where Name =: CasePortalJITHandler.ACCOUNT_NAME];
        system.assert(lstAccounts.size() > 0);
        
        //create contact for child account
        Contact objContact = new Contact(AccountId = lstAccounts[0].Id, FirstName = 'Test', LastName = 'Customer 1' , Email = strEmail, Community_web_country__c = 'USA' );
    	insert objContact;
        system.assert(objContact.Id != null);
        
        LeadPortalLib.getExternalUserProfile();
        Id partnerProfileId = LeadPortalLib.LP_EXTERNAL_PROFILE_Id;
        system.assert(partnerProfileId != null, 'Error Occured : Partner Profile Not found.');
        
        User objUser = TestUtil.createTestUser(strEmail, 'test1234', partnerProfileId);
        objUser.ContactId = objContact.Id;
        objUser.Disti_Lead_Portal_User_Role__c = 'User';
        insert objUser;
        system.assert(objUser.Id != null);
        
        Test.startTest();
        
        CasePortalJITHandler objHandler = new CasePortalJITHandler();
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
        system.assert(objContact.Community_web_country__c == 'Germany');        
        
        List<PermissionSetAssignment> lstPermissions = [Select PermissionSetId,AssigneeId From PermissionSetAssignment 
                                                         	Where PermissionSet.Name=:JITHandlerLib.CUSTOMER_COMMUNITY_PERMISSIONS and AssigneeId =:objUser.Id];
        system.assert(lstPermissions.size() > 0);        
    }

}