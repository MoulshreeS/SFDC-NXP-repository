/**************************************************************************************************
@Created By :    Nisha Agrawal
@Created Date:   Jun 24, 2019
@Description:    Created as part of SFDC-2810 - Queueable class to grant 
				access to projects and related cases When project team member accepts invite                 
**************************************************************************************************/

public without sharing class CPRecordSharingJob implements Queueable 
{
   private Set<Project_Team__c> projectTeamMembers;
   private Boolean doProjectShare;
   private Boolean doCaseShare;
      
    public CPRecordSharingJob(Set<Project_Team__c> projectTeam, Boolean projectShare, Boolean caseShare)
    {
        this.projectTeamMembers = projectTeam;
        this.doProjectShare = projectShare;
        this.doCaseShare = caseShare;
    }
    
    public void execute(QueueableContext context) 
    { 
        CasePortalUtil.shareProjectAccessToTheTeam(projectTeamMembers, doProjectShare, doCaseShare);    
    }
}