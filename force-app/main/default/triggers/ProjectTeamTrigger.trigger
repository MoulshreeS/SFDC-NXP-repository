/************************************************************************
@Created By :    Gunjan Singh
@Created Date:   19 Jun 2019
@Description:    Created as part of SFDC-2798 - Helper class to handle the functionality related to 
                 Invite Rights and Upgradation of License
----------------------------------------------------------------------------------------------------
@Modified By :     Gunjan Singh
@Created Date:     23 July 2019
@Description:      SFDC-3125 Deleted the Code Related to Email CC Functionality for NCP
**********************************************************************************************************/
/***************************************************************************************************
@Modified By :     Gunjan Singh
@Modified Date:    21 Oct 2019
@Description:      SFDC-3380 Refactor Security Model ("virtual Admin Support") for license upgrade from CC to CC+
**********************************************************************************************************/

trigger ProjectTeamTrigger on Project_Team__c (after update,after insert,before delete,before insert) {
    
    if(Trigger.isBefore){
        if(Trigger.isDelete){
            ProjectTeamTriggerHelper.preventOwnerRecDel(Trigger.Old, Trigger.oldMap); 
        }
        if(Trigger.isInsert){
            ProjectTeamTriggerHelper.preventDuplicateInvitee(Trigger.New);            
        }
    }
    
    if(Trigger.isafter)
    {
        if(Trigger.isInsert)
        {
            //Added as part of SFDC-3380
            ProjectTeamTriggerHelper.upgradeUserLicenseOnInvite(Trigger.New); 
        }
        if(Trigger.isUpdate)
        {
            ProjectTeamTriggerHelper.updateUserPermissionsAndGrantSharing(Trigger.New,Trigger.OldMap); 
        }  
    }
}