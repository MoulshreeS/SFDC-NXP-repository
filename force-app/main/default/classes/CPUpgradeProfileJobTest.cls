/************************************************************************
@Created By :      Nisha Agrawal
@Created Date:     Jul 23, 2019
@Description:      Test class for CPUpgradeProfileJob class
**************************************************************************/
/***************************************************************************************************
@Modified By :     Gunjan Singh
@Modified Date:    21 Oct 2019
@Description:      SFDC-3380 Refactor Security Model ("virtual Admin Support") for license upgrade from CC to CC+
**********************************************************************************************************/
@isTest
public class CPUpgradeProfileJobTest 
{    
    @isTest static void testUpdateProfileJob()
    {
        //create test data        
        Project__c testProject = CasePortalTestUtil.createTestProject('TestProject', 'In Development');
        insert testProject;        
        system.assert(testProject.Id != null);
        
        Project_Team__c testMember = CasePortalTestUtil.createTestProjectTeam(testProject.Id, 'test.member@abc.com.nxp', 'Invited' );
        insert testMember;
        system.assert(testMember.Id != null);
        
        Test.startTest();
        testMember.Status__c = CasePortalUtil.PROJECT_TEAM_STATUS_ACCEPTED;
        update testMember;
        Test.stopTest();
        
        //assert the result
        List<Project_team__c> lstTeam = [Select Id , Status__c From Project_Team__c Where Id =: testMember.Id];
        system.assert(lstTeam.size() > 0);
        system.assert(lstTeam[0].Status__c == CasePortalUtil.PROJECT_TEAM_STATUS_ACCEPTED);
    }
}