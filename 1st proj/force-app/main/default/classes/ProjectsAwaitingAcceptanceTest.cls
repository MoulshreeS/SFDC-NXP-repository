/*********************************************************************
Created by           |          Created date         |      Description 
Saranya Sista        |          5/30/2019            |  As part of SFDC-2734 ,Test Class for ProjectsAwaitingAcceptance

@Modified By :     Gunjan Singh/Nisha Agarwal
@Modified Date:    Oct 18, 2019
@Description:      Modified this class as part of SFDC-3380 Refactor Security Model for license upgrade from CC to CC+
**********************************************************************************************************/

@isTest
public class ProjectsAwaitingAcceptanceTest {
  
    static testMethod void getProjectList() 
    {
    	//set up test data
    	Id childAccountTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Child Account').getRecordTypeId();        
        Id tscommunityRecordType = Schema.SObjectType.Case.getRecordTypeInfosByName().get('TS Community').getRecordTypeId();
        
        Account childAccount = new Account(Name = 'Test Child', RecordTypeId = childAccountTypeId); 
        insert childAccount;
        system.assert(childAccount.Id != null);
        
        Contact testContact = new Contact(FirstName = 'test First', LastName = 'test Last', Email = 'test.contact@abc.nxp.com', 
                                           AccountId = childAccount.Id, Community_web_country__c = 'India');
        insert testContact;
        system.assert(testContact.Id != null);
        
        //Insert Project        
        Project__c testProject = CasePortalTestUtil.createTestProject('test Project', 'In Development');
        insert testProject;        
        system.assert(testProject.Id != null);
        
        List<Project_Team__c> result = ProjectAwaitingAcceptanceController.getProjectList();
        System.assertEquals(0, result.size());
        
        //Insert case
        Case objCase = new Case(Subject = 'testing', Priority = 'Low', Status = ' New',
                    Description= 'testing cases', Projects__c = testProject.Id, ContactId = testContact.Id, RecordTypeID = tscommunityRecordType);
        insert objCase;
        
        //Inserting a new project Team associated with the above project
        Project_Team__c projectTeam = CasePortalTestUtil.createTestProjectTeam(testProject.Id, 'test32345678910@nxp.com', 'Invited' );
        insert projectTeam;
        system.assert(projectTeam.Id != null);
        
        List<Project_Team__c> result1 = ProjectAwaitingAcceptanceController.getProjectDetailList(projectTeam.Id);
        system.assertEquals(1, result1.size());
        
        Test.startTest();
        try{
            ProjectAwaitingAcceptanceController.UpdateStatusRejected(projectTeam.Id);
        }
        catch(exception e)
        {            
        }        
        Test.stopTest();
    }
    
    static testMethod void acceptScenario()
    {
        //set up test data
    	Id childAccountTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Child Account').getRecordTypeId();        
        Id tscommunityRecordType = Schema.SObjectType.Case.getRecordTypeInfosByName().get('TS Community').getRecordTypeId();
        
        Account childAccount = new Account(Name = 'Test Child', RecordTypeId = childAccountTypeId); 
        insert childAccount;
        system.assert(childAccount.Id != null);
        
        Contact testContact = new Contact(FirstName = 'test First', LastName = 'test Last', Email = 'test.contact@abc.nxp.com', 
                                           AccountId = childAccount.Id, Community_web_country__c = 'India');
        insert testContact;
        system.assert(testContact.Id != null);
        
        ProjectAwaitingAcceptanceController testCover = new ProjectAwaitingAcceptanceController();
        
        //create an account and contact 
        List<Account> acc = CasePortalTestUtil.createTestParentAccount(1);
        insert acc;
        String email = 'testnxp.cls@gmail.com';
        String LastName= 'tst Last';
        List<Contact> con = CasePortalTestUtil.createTestContact(1,acc[0].Id,email,LastName);
        insert con;
        Id SysAdminProfileId = CasePortalTestUtil.fetchProfileId(CasePortalUtil.SYSTEM_ADMIN_PROFILE);
        //create one external user for this email address and run the code as that user to accept the invite        
        User SAUser = TestUtil.createTestUser('test.comusr@abc.com.nxp', 'tnxpExt', SysAdminProfileId);
        insert SAUser;
        Project__c newProjectTest = CasePortalTestUtil.createTestProject('Project1','General Interest & Research');
        insert newProjectTest;
        Project_Team__c ProjTeamTst = CasePortalTestUtil.createTestProjectTeam(newProjectTest.Id,'test.comusr@abc.com.nxp',CasePortalUtil.PROJECT_TEAM_STATUS_INVITED);
        insert ProjTeamTst;
        
        Test.startTest();
        Case testCase = new Case(Projects__c = newProjectTest.Id ,subject = 'testing',
                    priority = 'Low', Status = ' New',
                    Description= 'testing cases' , ContactId = testContact.Id, RecordTypeID = tscommunityRecordType);
        insert testCase;
        system.assert(SAUser.Id != null); 
        system.runAs(SAUser){
            try{
                   ProjectAwaitingAcceptanceController.UpdateStatusAccepted(ProjTeamTst.Id);
            }
            catch(exception e)
            {
            }
        }
        
        Test.stopTest();
    }
}