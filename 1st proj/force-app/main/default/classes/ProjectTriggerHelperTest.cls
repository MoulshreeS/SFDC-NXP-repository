@isTest
public class ProjectTriggerHelperTest 
{
    //method to cover exception class
    @isTest static void dummyTestMethod()
    {
        CasePortalUtil.CasePortalException dummyException = new CasePortalUtil.CasePortalException('throw dummy exception to cover the class');
    }
    
    //need to create the project
    @isTest public static void testProjectTrigger()
    {
        Profile p = [SELECT Id FROM Profile WHERE Name LIKE '%System Administrator%' limit 1];
        User userRecord = new User ();
        userRecord.Email = 'ProjectTeamMember1@nxp.com';
        userRecord.userName = 'ProjectTeamMember1@nxp.com';
        userRecord.firstName='New';
        userRecord.LastName='Testing1';
        userRecord.EmailEncodingKey='UTF-8';
        userRecord.LanguageLocaleKey='en_US';  
        userRecord.LocaleSidKey='en_US'; 
        userRecord.TimeZoneSidKey='America/Los_Angeles';
        userRecord.ProfileId = p.Id;
        userRecord.Alias = 'standt';
        userRecord.HasCreatedProjects__c = FALSE;
        insert userRecord; 
        
        System.runAs(userRecord){
        Test.startTest();
        List<Project__c> newProj = CasePortalTestUtil.createTestProjects(3); 
        insert newProj;
        Project__c newProj1 = CasePortalTestUtil.createTestProject('TestProject', 'In Development');
        insert newProj1;
        
        Test.stopTest();
       }
    }

    //added by saranya 
    @isTest public static void testrestrictProjectDeletion(){
        
        List<user> lstUsers = new List<user>();
        Id techSupportUserProfileId = CasePortalUtil.INTERNAL_AGENT_PROFILE_ID;
        Id sysAdminProfileId = CasePortalUtil.SYSTEM_ADMIN_PROFILE_Id;
        System.assert(techSupportUserProfileId != null);
        System.assert(sysAdminProfileId != null);
        User agentUser = TestUtil.createTestUser('internal.user@test.com.nxp', 'internal', techSupportUserProfileId);
        User adminUser = TestUtil.createTestUser('system.adminuser@test.com.nxp', 'Admin', sysAdminProfileId);
        lstUsers.add(agentUser);
        insert lstUsers;
        System.assert(lstUsers != null);
        
        List<Project__c> prjlst =  CasePortalTestUtil.createTestProjects(2);
        insert  prjlst;
        List<Project_Team__c> prjTeamLst = CasePortalTestUtil.createTestProjectTeams(prjlst,1); //added to cover preventdupPTeamOnOwnerChange
        insert prjTeamLst;
        Project_Team__c ProjT = new Project_Team__c(First_Name__c = 'Test FirstName1' , Last_Name__c='Test LastName1',
                                                          Email_Address__c=prjTeamLst[0].Email_Address__c , Status__c = 'Invited' , Project__c = prjTeamLst[0].Project__c);
        try{
            insert ProjT;
        }    
        catch(exception e){
        }
        System.runAs(agentUser){
           try{
            delete prjlst[0];
        }
        catch(exception e){
        }  
        }
        System.runAs(adminUser){
            delete prjlst[0]; 
        }
    }   

    @isTest public static void testDuplicateProjectOwnerInProjectTeam()
    {
        //set up test data
        String strOwnerEmail = 'test.owner@abc.com.nxp';
        
        Account testAccount = new Account(Name = 'Test Parent');
        insert testAccount;
        system.assert(testAccount.Id != null);
        
        Contact testContact = new Contact(FirstName = 'test First', LastName = 'test Last', Email = strOwnerEmail, 
                                          AccountId = testAccount.Id, Community_web_country__c = 'India');
        insert testContact;
        system.assert(testContact.Id != null);
        
        Id communityUserProfileId = CasePortalUtil.CUSTOMER_COMMUNITY_PLUS_PROFILE_Id;
        User testOwnerUser = TestUtil.createTestUser(strOwnerEmail, 'testExt', communityUserProfileId);
        testOwnerUser.ContactId = testContact.Id;
        insert testOwnerUser;
        system.assert(testOwnerUser.Id != null);
        
        Project__c testProject = CasePortalTestUtil.createTestProject('test project', 'In Development');
        insert testProject;
        system.assert(testProject.Id != null);  
        
        Project_Team__c testMember = CasePortalTestUtil.createTestProjectTeam(testProject.Id, strOwnerEmail, 'Invited');
        insert testMember;
        system.assert(testMember.Id != null);  
        
        try
        {
        	testProject.OwnerId = testOwnerUser.Id;
        	update testProject;    
        }
        catch(Exception ex)
        {
            String strException = ex.getMessage();
          	system.assert(strException.containsIgnoreCase('You have already invited this user in participants')); 
        }
        
        //assert the result
        List<Project__c> lstProjects = [Select Id, OwnerId From Project__c Where Id =: testProject.Id ];
        system.assert(lstProjects.size() == 1);
        system.assert(lstProjects[0].OwnerId == userInfo.getUserId());
    }
    //added by Nisha Agrawal for scenario when project owner is changed 
    @isTest public static void testChangeProjectOwner()
    {
        //set up test data
        String strCurrentOwnerEmail = 'current.owner@abc.com.nxp';
        String strNewOwnerEmail = 'new.owner@abc.com.nxp';
		String strMemberEmail = 'test.member@nxp.com.abc';
        
        //fetch record type for accounts
        Id parentAccountTypeId = AccountHelper.getParentRecordTypeID();
        Id childAccountTypeId =  AccountHelper.getChildRecordTypeID();
        
        Account parentAccount = new Account(Name = 'Test Parent', RecordTypeId = parentAccountTypeId);
        insert parentAccount;
        system.assert(parentAccount.Id != null);
        
        Account childAccount = new Account(Name = 'Test Child', RecordTypeId = childAccountTypeId, ParentId = parentAccount.Id);
        insert childAccount;
        system.assert(childAccount.Id != null);

        Contact currentOwnerContact = new Contact(FirstName = 'test First', LastName = 'test Last', Email = strCurrentOwnerEmail, 
                                          AccountId = childAccount.Id, Community_web_country__c = 'India');
        
        Contact newOwnerContact = new Contact(FirstName = 'other First', LastName = 'other Last', Email = strNewOwnerEmail, 
                                            AccountId = childAccount.Id, Community_web_country__c = 'India');
        
        Contact memberContact = new Contact(FirstName = 'member First', LastName = 'member Last', Email = strMemberEmail, 
                                            AccountId = childAccount.Id, Community_web_country__c = 'India');
        
        List<Contact> lstContacts = new List<Contact>();
        lstContacts.add(currentOwnerContact);
        lstContacts.add(newOwnerContact);
        lstContacts.add(memberContact);
        insert lstContacts;
        
        system.assert(lstContacts[0].Id != null);
        system.assert(lstContacts[1].Id != null);
		system.assert(lstContacts[2].Id != null);
        
        Id communityUserProfileId;
        Id techSupportUserProfileId;
        
       for(Profile objProfile : [Select Id, Name From Profile Where Name = : CasePortalUtil.COMMUNITY_PLUS_USER_PROFILE OR 
                                  		Name = : CasePortalUtil.INTERNAL_AGENT_PROFILE])
        {
            if(objProfile.Name == CasePortalUtil.COMMUNITY_PLUS_USER_PROFILE)
            {
                communityUserProfileId = objProfile.Id;
            }
            else if(objProfile.Name == CasePortalUtil.INTERNAL_AGENT_PROFILE)
            {
                techSupportUserProfileId = objProfile.Id;
            }
		}        
        
        system.assert(communityUserProfileId != null);
        system.assert(techSupportUserProfileId != null);
        
        List<User> lstUsers = new List<User>();
        User currentOwner = TestUtil.createTestUser(strCurrentOwnerEmail, 'testExt', communityUserProfileId);
        currentOwner.ContactId = currentOwnerContact.Id;
        lstUsers.add(currentOwner);

        User newOwner = TestUtil.createTestUser(strNewOwnerEmail, 'testExt', communityUserProfileId);
        newOwner.ContactId = newOwnerContact.Id;
        lstUsers.add(newOwner);
        
        User memberUser = TestUtil.createTestUser(strMemberEmail, 'testExt', communityUserProfileId);
        memberUser.ContactId = memberContact.Id;
        lstUsers.add(memberUser);
        
        User agentUser = TestUtil.createTestUser('internal.user@test.com.nxp', 'internal', techSupportUserProfileId);
        lstUsers.add(agentUser);
        
        insert lstUsers;
        system.assert(lstUsers[0].Id != null);
        system.assert(lstUsers[1].Id != null);
		system.assert(lstUsers[2].Id != null);       
        system.assert(lstUsers[3].Id != null);       
        
        Project__c testProject;
        Project_Team__c teamMember;
        Case objCase;
        
        test.startTest();
        Id tscommunityRecordType = Schema.SObjectType.Case.getRecordTypeInfosByName().get('TS Community').getRecordTypeId();
        
        system.runAs(currentOwner)
        {
        	testProject = CasePortalTestUtil.createTestProject('TestProject', 'In Development');
            insert testProject;        
            system.assert(testProject.Id != null);
            //since sharing on project record is given through chained queueable jobs and that does not work in test context
            //so project sharing record has to be created explicitly here and we can create team member in accepted status directly. 
            teamMember = CasePortalTestUtil.createTestProjectTeam(testProject.Id, strMemberEmail, CasePortalUtil.PROJECT_TEAM_STATUS_ACCEPTED);
            insert teamMember;
            system.assert(teamMember.Id != null);
        }

        //invoke CasePortalUtil method to grant project sharing explicitly
        CasePortalUtil.shareProjectAccessToTheTeam( new Set<Project_Team__c>{teamMember} , true, false); 
        
		//create new case by member user
		objCase = new Case(RecordTypeID = tscommunityRecordType, contactId = memberContact.Id, Status= 'New', Priority = 'Medium', 
                                  Subject = 'test_subject_1', Description = 'test_description_1', Projects__c = testProject.Id); 
        insert objCase;        
        system.assert(objCase.Id != null);
        
		//agent user gets access to the cases through criteria based sharing rule on account which does not work in test 
        //class context so running as sys admin user
        
        //system.runAs(agentUser)
        {
            testProject.OwnerId = newOwner.Id;
            update testProject;
        }
        test.stopTest();
        
        //assert the result
        List<Project__c> lstProjects = [Select Id, OwnerId From Project__c Where Id =: testProject.Id ];
        system.assert(lstProjects.size() == 1);
        system.assert(lstProjects[0].OwnerId == newOwner.Id);
    }  
}