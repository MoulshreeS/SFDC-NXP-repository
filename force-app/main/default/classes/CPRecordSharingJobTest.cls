/************************************************************************
@Created By :      Nisha Agrawal
@Created Date:     Jul 25, 2019
@Description:      Test Class for CPRecordSharingJob class
**************************************************************************/
@isTest
public class CPRecordSharingJobTest 
{
    @isTest static void testRecordSharingJob()
    {
        String strProjectOwnerEmail = 'test.project.owner@abc.com.nxp';
        String strTeamMemberEmail = 'test.team.member@abc.com.nxp';
        
        //fetch record type for accounts
        Id parentAccountTypeId = AccountHelper.getParentRecordTypeID();
        Id childAccountTypeId =  AccountHelper.getChildRecordTypeID();
        
        Account parentAccount = new Account(Name = 'Test Parent', RecordTypeId = parentAccountTypeId);
        insert parentAccount;
        system.assert(parentAccount.Id != null);
        
        Account childAccount = new Account(Name = 'Test Child', RecordTypeId = childAccountTypeId, ParentId = parentAccount.Id);
        insert childAccount;
        system.assert(childAccount.Id != null);
        
        Contact testOwnerContact = new Contact(FirstName = 'test First', LastName = 'test Last', Email = strProjectOwnerEmail, 
                                          AccountId = childAccount.Id, Community_web_country__c = 'India');
        Contact testMemberContact = new Contact(FirstName = 'test First', LastName = 'test Last', Email = strTeamMemberEmail, 
                                          AccountId = childAccount.Id, Community_web_country__c = 'India');        
        
        List<Contact> lstContacts = new List<Contact>();
        lstContacts.add(testOwnerContact);
        lstContacts.add(testMemberContact);
        
        insert lstContacts;
        system.assert(lstContacts[0].Id != null);
        system.assert(lstContacts[1].Id != null);
        
        //create external user for this email address for project team member
        Id communityUserProfileId = CasePortalTestUtil.fetchProfileId(CasePortalUtil.COMMUNITY_PLUS_USER_PROFILE);
        User ownerUser = TestUtil.createTestUser(strProjectOwnerEmail, 'pOwner', communityUserProfileId);
        ownerUser.ContactId = testOwnerContact.Id;
        
        User memberUser = TestUtil.createTestUser(strTeamMemberEmail, 'testExt', communityUserProfileId);
        memberUser.ContactId = testMemberContact.Id;
        
        List<User> lstUsers = new List<User>();
        lstUsers.add(ownerUser);
        lstUsers.add(memberUser);
        insert lstUsers;
        
        system.assert(lstUsers[0].Id != null); 
        system.assert(lstUsers[1].Id != null); 
        
        Project__c testProject;        
        system.runAs(ownerUser)
        {
            testProject = CasePortalTestUtil.createTestProject('TestProject', 'In Development');
            insert testProject;        
            system.assert(testProject.Id != null);
        }       
        
        Id tscommunityRecordType = Schema.SObjectType.Case.getRecordTypeInfosByName().get('TS Community').getRecordTypeId();        
        List<Case> lstCases = new List<Case>();
        lstCases.add(new Case(RecordTypeID = tscommunityRecordType, ContactId = testOwnerContact.Id, Status= 'New', Priority = 'Medium', 
                              Subject = 'test_subject_1', Description = 'test_description_1', Projects__c = testProject.Id));
        lstCases.add(new Case(RecordTypeID = tscommunityRecordType, ContactId = testOwnerContact.Id, Status= 'New', Priority = 'Medium', 
                              Subject = 'test_subject_2', Description = 'test_description_2', Projects__c = testProject.Id));
        
        insert lstCases;        
        system.assert(lstCases[0].Id != null);
        system.assert(lstCases[1].Id != null);
        
        Project_Team__c testMember = CasePortalTestUtil.createTestProjectTeam(testProject.Id, strTeamMemberEmail, 'Accepted' );
        insert testMember;
        system.assert(testMember.Id != null);
                
        Test.startTest();
        CPRecordSharingJob recordShareJob = new CPRecordSharingJob(new Set<Project_Team__c>{testMember},true,true); 
        Id jobId = System.enqueueJob(recordShareJob);
        system.assert(jobId != null);
        Test.stopTest();
        
        //assert the results
        List<Project__Share> lstProjectShares = [Select Id, UserOrGroupId, AccessLevel From Project__Share Where ParentId =: testProject.Id 
                                                 and RowCause =: Schema.Project__Share.RowCause.ShareToTeam__c ];
        system.assert(lstProjectShares.size() > 0);
        system.assert(lstProjectShares[0].UserOrGroupId == memberUser.Id);
        system.assert(lstProjectShares[0].AccessLevel == 'Edit');
        
        List<CaseShare> lstCaseShares = [Select Id, UserOrGroupId, CaseAccessLevel From CaseShare Where CaseId =: lstCases[0].Id 
                                         and RowCause =: CasePortalUtil.SHARING_REASON and UserOrGroupId =: memberUser.Id ];
        system.assert(lstCaseShares.size() > 0);
        system.assert(lstCaseShares[0].CaseAccessLevel == 'Edit');
    }
}