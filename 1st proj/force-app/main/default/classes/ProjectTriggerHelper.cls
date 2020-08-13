/***************************************************************************************************
@Created By :      Gunjan Singh
@Created Date:     06 June 2019
@Description:      SFDC-2798 Provisioning of License - Upgrade the license
@Description:      To assign assignGrantAccessToProjectTeamPermissionSet to Owner of project if project get 
converted into Paid Calling assignGrantAccessToProjectTeamPermissionSet and 
getUserDetailsBasedOnEmail methods of CasePortalUtil Class               
--------------------------------------------------------------------------------------
@Modified By :      Bhagyashree
@Modified Date:     10 July 2019
@Description:       This is used to update project pattern field of Project object. 
--------------------------------------------------------------------------------------------
@Modified By :     Gunjan Singh
@Created Date:     23 July 2019
@Description:      SFDC-3125 Comment the Code Related to Email CC Functionality for NCP
-------------------------------------------------------------------------------------------
@Modified By :     Nisha Agrawal
@Created Date:     Sep 16, 2019
@Description:      Added method to grant access to new project owners and revoke access from previous owner
--------------------------------------------------------------------------------------------
@Modified By :      Saranya Sista
@Modified Date:     Oct 16, 2019
@Description:       To Add method(restrictProjectDeletion) to restrict users deleting the project.
*******************************************************************************************************/

public without sharing class ProjectTriggerHelper 
{
    public static void UpdateProjectPattern(list<Project__c> lstProjects)
    {
        for(Project__c objProject : lstProjects)
        {
            objProject.Project_Pattern__c = generateProjectPattern();
        }        
    }
    
    public static String generateProjectPattern()
    {
        Integer intRandom = Math.abs(Crypto.getRandomInteger());
        String strRandom = String.valueof(intRandom).left(8);
        
        List<Project__c> lstProjects = [Select Id From Project__c Where Project_Pattern__c = :strRandom];
        if(lstProjects.size() > 0)
        {
            generateProjectPattern();            
        }        
        return strRandom;
    }
    
    //method added by Nisha Agrawal on Sep 16th, 2019
    public static void grantSharingToNewOwners(List<Project__c> lstProjectsNew, Map<Id, Project__c> oldProjectsMap)
    {
        if(lstProjectsNew != null && oldProjectsMap != null)
        {
            Map<Id, Id> mapProjectToOldOwners = new Map<Id, Id>();
            Set<Id> newOwnerIds = new Set<Id>();
            Set<Id> newOwnersForCases = new Set<Id>();
            
            //check if project owner is changed
            for(Project__c objProject : lstProjectsNew)
            {
                Project__c oldProject =  oldProjectsMap.get(objProject.Id);
                
                if(oldProject != null && objProject.OwnerId != oldProject.OwnerId) //check if owner is changed
                {
                    mapProjectToOldOwners.put(objProject.Id, oldProject.OwnerId);
                    newOwnerIds.add(objProject.OwnerId);
                    if(objProject.Cases_Per_Project__c > 0)
                    {
                        newOwnersForCases.add(objProject.OwnerId);    
                    }                    
                }                
            }
            
            if(mapProjectToOldOwners.size() > 0)
            {
                CasePortalUtil.shareProjectAccessToNewOwner(lstProjectsNew, mapProjectToOldOwners);                
                List<User> lstUsersToUpdate = [Select Id, HasCreatedProjects__c, HasCreatedCases__c From User 
                                                Where Id in : newOwnerIds and (HasCreatedProjects__c = false or HasCreatedCases__c = false)];
                for(User objOwner : lstUsersToUpdate)
                {
                    if(objOwner.HasCreatedProjects__c == false)
                    {
                        objOwner.HasCreatedProjects__c = true;
                    }
                    
                    if(objOwner.HasCreatedCases__c == false && newOwnersForCases.contains(objOwner.Id))
                    {
                        objOwner.HasCreatedCases__c = true;
                    }
                }                
                if(lstUsersToUpdate.size() > 0)
                {
                    MixedDMLOps.up(lstUsersToUpdate);
                }
            }            
        } 
    }
    
    //method added by Saranya as Part of SFDC-3398
    public static void restrictProjectDeletion(List<Project__c> lstProjects){
        Id profileId=userinfo.getProfileId();
        String profileName=[Select Id,Name from Profile where Id=:profileId].Name;
        if(profileName != CasePortalUtil.SYSTEM_ADMIN_PROFILE){
            for(Project__c eachProj : lstProjects){
                eachProj.addError('You do not have the access to delete the Project Record');
            }
        }
    }
    
     //Method to Avoid Duplicate Owners in Project Team
     public static void preventdupPTeamOnOwnerChange(List<Project__c> lstProjectsNew, Map<Id, Project__c> oldProjectsMap){
        Set<Id> prjId = new Set<Id>();
        Set<Id> ownerIds = new Set<Id>();
                
        for(Project__c objProject : lstProjectsNew){
            Project__c oldProject =  oldProjectsMap.get(objProject.Id);
            if(oldProject != null && objProject.OwnerId != oldProject.OwnerId){ //check if owner is changed
                prjId.add(objProject.Id);
                ownerIds.add(objProject.OwnerId);
            }
        }        
         
		if(ownerIds != null)
        {
            Map<Id,String> userEmailMap = new Map<Id,String>();
           	for(user eachusr : [Select Id,Email FROM user where Id IN : ownerIds]){
                userEmailMap.put(eachusr.Id,eachusr.Email);
            } 
            Map<Id,List<String>> mapProjectToTeamMemberEmails = new Map<Id,List<String>>();
            if(prjId != null)
            {                
                for(Project__c eachprj : [SELECT Id,(SELECT Id,Email_Address__c,Project__c FROM Project_Teams__r),OwnerId 
                                          FROM Project__c WHERE ID IN : prjId]){
                    for(Project_Team__c prjTeam : eachprj.Project_Teams__r){
                        if(mapProjectToTeamMemberEmails.containsKey(prjTeam.Project__c)){
                            mapProjectToTeamMemberEmails.get(prjTeam.Project__c).add(prjTeam.Email_Address__c);
                        }
                        else{
                            mapProjectToTeamMemberEmails.put(prjTeam.Project__c, new List<String>{prjTeam.Email_Address__c} );
                        }
                    }
                }
            }
            for(Project__c prj : lstProjectsNew){
                Project__c oldProject = oldProjectsMap.get(prj.Id);
                if(oldProject != null && prj.OwnerId != oldProject.OwnerId){ //check if owner is changed
                    if(mapProjectToTeamMemberEmails.get(prj.Id) != null && userEmailMap.get(prj.OwnerId) != null){
                        if(mapProjectToTeamMemberEmails.get(prj.Id).contains(userEmailMap.get(prj.OwnerId))){
                            prj.addError('You have already invited this user in participants');
                        } 
                    }
                }
            }
        }
    }    
}