/*************************************************************************************************
@Created By :    Gunjan Singh
@Created Date:   Jun 24, 2019
@Description:    Created as part of SFDC-2798 - Queueable class to Update User Profile and 
                    assign permission sets When project team member accepts invite
------------------------------------------------------------------------------------
@Modified By :      Nisha Agrawal
@Modified Date :    Jul 24, 2019
@Description :      Included null checks , Mock Responses and Test Context to 
                        cover the code in test classes
***************************************************************************************************/
/***************************************************************************************************
@Modified By :     Gunjan Singh
@Modified Date:    21 Oct 2019
@Description:      SFDC-3380 Refactor Security Model ("virtual Admin Support") for license upgrade from CC to CC+
**********************************************************************************************************/
public without sharing class CPUpgradeProfileJob implements Queueable 
{   
    private Set<User> users;
    private Set<Project_Team__c> projectTeamMembers;   
   
    public CPUpgradeProfileJob(Set<User> userRecords, Set<Project_Team__c> projectTeam) {
        this.users = userRecords;
        this.projectTeamMembers = projectTeam;          
    }
    
    public void execute(QueueableContext context) 
    {       
        CasePortalUtil.UpdateUserProfile(this.users);
        if(this.projectTeamMembers != null && this.projectTeamMembers.size() > 0 && Test.isRunningTest() == false) //queueable job chaining is not allowed in test classes
        {
            system.enqueuejob(new CPRecordSharingJob(this.projectTeamMembers , true , true));       
        }
        
    }
}