/***************************************************************************************************
@Created By :      Gunjan Singh
@Created Date:     06 June 2019
@Description:      SFDC-2798 Provisioning of License - Upgrade the license
@Description:      SFDC-2833 To update user record to check if user has created cases and projects or not.
@Description:      SFDC-3125 Comment the Code Related to Email CC Functionality for NCP                    
---------------------------------------------------------------------------------------
@Modified By :      Bhagyashree
@Modified Date:     10 July 2019
@Description:      This trigger is used to update project pattern field of Project object. 
--------------------------------------------------------------------------------------------
@Modified By :      Nisha Agrawal
@Modified Date:     Sep 23, 2019
@Description:      	To Add method call for granting access on project owner change.
--------------------------------------------------------------------------------------------
@Modified By :      Saranya Sista
@Modified Date:     Oct 16, 2019
@Description:       To Add method to restrict users deleting the project.
*******************************************************************************************************/

trigger ProjectTrigger on Project__c (after update,after insert,before insert, before update, before delete) 
{
    //Implemented this as part of SFDC-2962
    if(trigger.isBefore){
        if(trigger.isInsert)
        {   
           ProjectTriggerHelper.UpdateProjectPattern(Trigger.new);
        }
        if(trigger.isUpdate){
            ProjectTriggerHelper.preventdupPTeamOnOwnerChange(Trigger.New, Trigger.OldMap);
        }  
        if(trigger.isDelete){
            ProjectTriggerHelper.restrictProjectDeletion(Trigger.Old);
        }
    }    
    if(trigger.isAfter){
        if(trigger.isInsert){ 
            // Implemented this as part of SFDC-2833
            User objUser = [Select id, HasCreatedCases__c,HasCreatedProjects__c FROM User where id =: UserInfo.getUserId()];
            if(objUser.HasCreatedProjects__c == FALSE){
                objUser.HasCreatedProjects__c = TRUE;
                update objUser;      
            }
        }
        else if(trigger.isUpdate)
        {
            ProjectTriggerHelper.grantSharingToNewOwners(Trigger.New, Trigger.OldMap);
        }
    }   
}