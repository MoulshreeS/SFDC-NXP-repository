/************************************************************************
@Created By :    Gunjan Singh
@Created Date:   19 Jun 2019
@Description:    Created as part of SFDC-2798 - Helper class to handle the functionality related to Invite Rights and 
                 Upgradation of License.
                 Calling assignPermissionSetToUser,getUserDetailsBasedOnEmail and UpdateUserProfile from CasePortalUtil Class
                 
****************************************************************************/
/***************************************************************************************************
@Modified By :     Gunjan Singh
@Created Date:     23 July 2019
@Description:      SFDC-3125 Comment the Code Related to Email CC Functionality for NCP
**********************************************************************************************************/
/***************************************************************************************************
@Modified By :     Gunjan Singh
@Modified Date:    21 Oct 2019
@Description:      SFDC-3380 Refactor Security Model ("virtual Admin Support") for license upgrade from CC to CC+
**********************************************************************************************************/

public without sharing class ProjectTeamTriggerHelper
{
    // Method to upgrade the license of user whenever he accepted the invitation and to assign permission set as part of SFDC-2798
    public static void updateUserPermissionsAndGrantSharing(List<Project_Team__c> lstProjectTeamNew, Map<Id,Project_Team__c> oldProjectTeamMap)
    {
        Set<String> lstEmailsToUpdateProfile = new Set<String>();
        Set<Id> projectIds = new Set<Id>(); //set to collect project ids to get owners
        Set<Project_Team__c> teamMembersSetForSharing = new Set<Project_Team__c>();//to grant access to project and related cases
                
        for(Project_Team__c objProjTeam : lstProjectTeamNew)
        {
            Project_Team__c oldTeamMember =  oldProjectTeamMap.get(objProjTeam.Id); 
            if(oldTeamMember != null)
            {
                // status changed to accepted
                if(objProjTeam.Status__c != oldTeamMember.Status__c && objProjTeam.Status__c.equalsIgnoreCase(CasePortalUtil.PROJECT_TEAM_STATUS_ACCEPTED))
                {
                    projectIds.add(objProjTeam.Project__c);
                    teamMembersSetForSharing.add(objProjTeam);
                }
            }
        }
        
        if(projectIds.size() > 0)
        {
            for(Project_Team__c objProjTeam : [Select Email_Address__c, Project__c, Role__c From Project_Team__c 
                                               Where Project__c in : projectIds And Role__c = : CasePortalUtil.PROJECT_TEAM_ROLE_OWNER]){
                lstEmailsToUpdateProfile.add(objProjTeam.Email_Address__c);
                // To give sharing to owner for cases created by participants.                                  
                teamMembersSetForSharing.add(objProjTeam);
            } 
        }                
        
        if(lstEmailsToUpdateProfile.size() > 0)
        {
            Set<User> lstUsertoUpdateProfile = CasePortalUtil.getUserDetailsBasedOnEmail(lstEmailsToUpdateProfile);          
            if(teamMembersSetForSharing.size() > 0)
            {
               system.enqueuejob(new CPUpgradeProfileJob(lstUsertoUpdateProfile, teamMembersSetForSharing));
            }  
        }        
    }   
     
    //added by saranya as part of sfdc-2943
    public static void preventOwnerRecDel(List<Project_Team__c> recClickedForDel,Map<Id,Project_Team__c> ownerProjectTeam){
        for(Project_Team__c eachProjTeam : recClickedForDel){
            if(eachProjTeam.Role__c.equalsIgnoreCase(CasePortalUtil.PROJECT_TEAM_ROLE_OWNER)){
                eachProjTeam.addError('You do not have the access to delete the Owners detail Record');
            }
        }
    }
    
    //added by saranya as part of sfdc-3062
    public static void preventDuplicateInvitee(List<Project_Team__c> ProjTeamInsertList){
        //system.assert(false,'entered');
        set<id> projId = new Set<id>();//To store the Project Id's for which invitee is sent.
        for(Project_Team__c eachProjTeam : ProjTeamInsertList) {
            projId.add(eachProjTeam.Project__c);
        } 

        //"projectList" is created to store the project teams associated with the Project. 
        List<Project_Team__c> projectList = [Select Id,Email_Address__c,project__c,Status__c,Has_Invitation_Rights__c,Role__c from Project_Team__c where project__c IN: projId];       
        
        Map<Id, Map<String,String>> projToProjTeam = new Map<Id, Map<String,String>>();
        Map<Id,Map<String,Boolean>> mapProjectAndProjInviteeRights = new Map<Id,Map<String,Boolean>>();
        
        if(!projectList.isEmpty()){
            for(Project_Team__c eachProjTeam : projectList) {
                
                if(projToProjTeam.containsKey(eachProjTeam.project__c)) {
                    Map<String,String> emailAndStatus = projToProjTeam.get(eachProjTeam.project__c);
                    emailAndStatus.put(eachProjTeam.Email_Address__c, eachProjTeam.Status__c);
                    projToProjTeam.put(eachProjTeam.project__c, emailAndStatus);
                } else {
                    Map<String,String> emailStatusMap = new Map<String,String>();
                    emailStatusMap.put(eachProjTeam.Email_Address__c,eachProjTeam.Status__c );
                    projToProjTeam.put(eachProjTeam.project__c, emailStatusMap);
                }
                
                // Added the code as part of SFDC-3125 so that only user having Invite Rights will be able to Invite Others. 
                if(mapProjectAndProjInviteeRights.containsKey(eachProjTeam.project__c)) {
                    Map<String,Boolean> mapEmailAndInviteRights = mapProjectAndProjInviteeRights.get(eachProjTeam.project__c);
                    mapEmailAndInviteRights.put(eachProjTeam.Email_Address__c, eachProjTeam.Has_Invitation_Rights__c );
                    mapProjectAndProjInviteeRights.put(eachProjTeam.project__c, mapEmailAndInviteRights);
                } else {
                    Map<String,Boolean> mapEmailAndInviteRight = new Map<String,Boolean>();
                    mapEmailAndInviteRight.put(eachProjTeam.Email_Address__c,eachProjTeam.Has_Invitation_Rights__c );
                    mapProjectAndProjInviteeRights.put(eachProjTeam.project__c, mapEmailAndInviteRight);
                }                
            }
        }       
       
        for(Project_Team__c eachProjTeam : ProjTeamInsertList) {             
            if(projToProjTeam.containsKey(eachProjTeam.project__c)){
                if(projToProjTeam.get(eachProjTeam.project__c).containsKey(eachProjTeam.Email_Address__c) && ( (projToProjTeam.get(eachProjTeam.project__c).get(eachProjTeam.Email_Address__c).contains(CasePortalUtil.PROJECT_TEAM_STATUS_INVITED)) || (projToProjTeam.get(eachProjTeam.project__c).get(eachProjTeam.Email_Address__c).contains(CasePortalUtil.PROJECT_TEAM_STATUS_ACCEPTED)))){
                    eachProjTeam.addError('You have already invited this user');
                }
            }  
        }
        
        // Added the code as part of SFDC-3125 so that only user having Invite Rights will be able to Invite Others.
        Id profileId=userinfo.getProfileId();
        String profileName=[Select Id,Name from Profile where Id=:profileId].Name;
        
        if(profileName != CasePortalUtil.INTERNAL_AGENT_PROFILE && profileName != CasePortalUtil.SYSTEM_ADMIN_PROFILE){
            for(Project_Team__c objProjTeam : ProjTeamInsertList){
                if(mapProjectAndProjInviteeRights.containsKey(objProjTeam.project__c)){
                    if(mapProjectAndProjInviteeRights.get(objProjTeam.project__c).containsKey(UserInfo.getUserEmail()) && mapProjectAndProjInviteeRights.get(objProjTeam.project__c).get(UserInfo.getUserEmail()) == FALSE ){
                        objProjTeam.addError('You dont have rights to invite others to collaborate on this Project');
                    }   
                }
            }        
        }                
    }
    
    // SFDC-3380 : Method to upgrade user License to Customer Community Plus On Invite
    public static void upgradeUserLicenseOnInvite(List<Project_Team__c> lstNewProjectTeam){
    
        Set<String> lstEmailsToUpdateProfile = new Set<String>();
        
        for(Project_Team__c objProjTeam : lstNewProjectTeam)
        {
            if(objProjTeam.Role__c == CasePortalUtil.PROJECT_TEAM_ROLE_PARTICIPANT && objProjTeam.Status__c==CasePortalUtil.PROJECT_TEAM_STATUS_INVITED)
            lstEmailsToUpdateProfile.add(objProjTeam.Email_Address__c);
        }
        
        if(lstEmailsToUpdateProfile.size() > 0)
        {
            Set<User> lstUsertoUpdateProfile = CasePortalUtil.getUserDetailsBasedOnEmail(lstEmailsToUpdateProfile);          
            if(lstUsertoUpdateProfile.size() > 0)
            {
               system.enqueuejob(new CPUpgradeProfileJob(lstUsertoUpdateProfile, null));
            }  
        }  
    
    }
}