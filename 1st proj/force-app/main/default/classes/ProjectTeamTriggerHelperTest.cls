/***************************************************************************************************
@Created By :      Saranya Sista
@Created Date:     Jul 25, 2019
@Description:      Test Class for ProjectTeamTriggerHelper apex class and trigger
**********************************************************************************************************/
/***************************************************************************************************
@Modified By :     Gunjan Singh
@Created Date:     Jul 25, 2019
@Description:      Test Method to cover assignPermissionSet method of CasePortalUtil Class
                   Test Method to cover upgradeUserLicenseOnInvite method of CasePortalUtil Class                  
**********************************************************************************************************/

@isTest
public class ProjectTeamTriggerHelperTest 
{    
    //methods added by saranya
    @isTest
    static void preventDuplicateInvitee()
    {
        List<Project__c> newProj = CasePortalTestUtil.createTestProjects(1);
        insert newProj;
        List<project_Team__c> newProjTeam = CasePortalTestUtil.createTestProjectTeams(newProj, 1); 
        insert newProjTeam;
        Project_Team__c dupProjTeam = new Project_Team__c();
        dupProjTeam.First_Name__c='Test';
        dupProjTeam.Last_Name__c='Name';
        dupProjTeam.Email_Address__c=newProjTeam[0].Email_Address__c;
        dupProjTeam.Project__c=newProj[0].Id;
        try{
            insert dupProjTeam;
        }
        catch(exception e){
            System.debug(e.getMessage()+ 'You have already invited this user');
        }
    }
     
    @isTest
    static void preventOwnerRecordDeletions()
    {
        List<Project__c> newProj1 = CasePortalTestUtil.createTestProjects(1);
        insert newProj1;
        
        List<project_Team__c> newProjTeam1 = CasePortalTestUtil.createTestProjectTeams(newProj1, 2);
        insert newProjTeam1;
        newProjTeam1[0].Role__c = CasePortalUtil.PROJECT_TEAM_ROLE_OWNER;
        newProjTeam1[1].Status__c= CasePortalUtil.PROJECT_TEAM_STATUS_ACCEPTED;
        update newProjTeam1;
        
        
        try{
            delete newProjTeam1;
        }
        catch(exception e){
            System.debug(e.getMessage()+ 'You do not have the access to delete the Owners detail Record');
        }
    }
    

     @isTest static void testAssignPermissionSet()
    {
        String strEmail1 = 'test.member@abc.com.nxp';
        String strEmail2 = 'other.member@abc.com.nxp';
        String strEmail3 = 'internaltest.member@abc.com.nxp';

        //fetch record type for accounts
        Id parentAccountTypeId = AccountHelper.getParentRecordTypeID();
        Id childAccountTypeId =  AccountHelper.getChildRecordTypeID();
        
        Account parentAccount = new Account(Name = 'Test Parent', RecordTypeId = parentAccountTypeId);
        insert parentAccount;
        system.assert(parentAccount.Id != null);
        
        Account childAccount = new Account(Name = 'Test Child', RecordTypeId = childAccountTypeId, ParentId = parentAccount.Id);
        insert childAccount;
        system.assert(childAccount.Id != null);

        Contact testContact1 = new Contact(FirstName = 'test First', LastName = 'test Last', Email = strEmail1, 
                                          AccountId = childAccount.Id, Community_web_country__c = 'India',contact_service_level__c='A1');
        
        Contact testContact2 = new Contact(FirstName = 'other First', LastName = 'other Last', Email = strEmail2, 
                                            AccountId = childAccount.Id, Community_web_country__c = 'India',contact_service_level__c='A2_Certified_DFAE');
        List<Contact> lstContacts = new List<Contact>();
        lstContacts.add(testContact1);
        lstContacts.add(testContact2);
        insert lstContacts;
         
        system.assert(lstContacts[0].Id != null);
        system.assert(lstContacts[1].Id != null);

        Id communityUserProfileId = CasePortalTestUtil.fetchProfileId(CasePortalUtil.COMMUNITY_PLUS_USER_PROFILE);
        Id internalFAEUserProfileId = CasePortalTestUtil.fetchProfileId(CasePortalUtil.INTERNAL_FAE_PROFILE);
        
        List<User> lstUsers = new List<User>();
        List<User> lstInternalUsers = new List<User>();
        User customerUser1 = TestUtil.createTestUser(strEmail1, 'testExt', communityUserProfileId);
        customerUser1.ContactId = testContact1.Id;
        lstUsers.add(customerUser1);

        User customerUser2 = TestUtil.createTestUser(strEmail2, 'testExt', communityUserProfileId);
        customerUser2.ContactId = testContact2.Id;
        lstUsers.add(customerUser2);
        
        insert lstUsers;
        
        User internalUser = TestUtil.createTestUser(strEmail3, 'testExt', internalFAEUserProfileId);
        lstInternalUsers.add(internalUser);
        insert lstInternalUsers;
        
         system.runAs(lstInternalUsers[0]){
            CasePortalUtil.autoCreateContactForInternalUser();
        }
        
        system.assert(lstUsers[0].Id != null);
        system.assert(lstUsers[1].Id != null);
        system.assert(lstInternalUsers[0].Id != null);
        
        testContact1.contact_service_level__c='A2_Certified_DFAE';
        testContact2.contact_service_level__c='A';
        List<Contact> updatedContact = new List<Contact>();
        updatedContact.add(testContact1);
        updatedContact.add(testContact2);
        update updatedContact;
        
        CasePortalUtil.getUserInfo(lstUsers);
        CasePortalUtil.getUserInfo(lstInternalUsers);
        
        //Insert Test Data for Project
        List<Project__c> newProj = CasePortalTestUtil.createTestProjects(1);
        insert newProj;
        system.assert(newProj[0].Id != null);
        
        //Insert Test Data for Project Team related to Project 
        List<project_Team__c> newProjTeam = CasePortalTestUtil.createTestProjectTeams(newProj, 1); 
        insert newProjTeam;
        system.assert(newProjTeam[0].Id != null);
    }
    
    // Method added as part of SFDC-3380
    @isTest
    static void upgradeUserLicenseOnInviteTest()
    {   
        String strEmail1 = 'test.member@abc.com.nxp';
        Id customerUserProfileId = CasePortalTestUtil.fetchProfileId(CasePortalUtil.COMMUNITY_USER_PROFILE);
        
        Id parentAccountTypeId = AccountHelper.getParentRecordTypeID();
        Id childAccountTypeId =  AccountHelper.getChildRecordTypeID();
        
        Account parentAccount = new Account(Name = 'Test Parent', RecordTypeId = parentAccountTypeId);
        insert parentAccount;
        system.assert(parentAccount.Id != null);
        
        Account childAccount = new Account(Name = 'Test Child', RecordTypeId = childAccountTypeId, ParentId = parentAccount.Id);
        insert childAccount;
        system.assert(childAccount.Id != null);

        Contact testContact1 = new Contact(FirstName = 'test First', LastName = 'test Last', Email = strEmail1, 
                                          AccountId = childAccount.Id, Community_web_country__c = 'India',contact_service_level__c='A1');
        
        insert testContact1 ;
                                         
        User customerUser1 = TestUtil.createTestUser(strEmail1, 'testExt', customerUserProfileId);
        customerUser1.ContactId = testContact1.Id;
        insert customerUser1;
        
        //Insert Test Data for Project
        List<Project__c> newProj = CasePortalTestUtil.createTestProjects(1);
        insert newProj;
        system.assert(newProj[0].Id != null);
        
        //Insert Test Data for Project Team related to Project 
        Project_Team__c ProjT = new Project_Team__c(First_Name__c = 'Test FirstName', Last_Name__c='Test LastName',
                                                          Email_Address__c= strEmail1 , Status__c = 'Invited' , Project__c = newProj[0].Id);
         insert ProjT;                                                 
        
        
        
    }
}