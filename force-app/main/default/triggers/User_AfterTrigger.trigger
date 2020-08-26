/***************************************************************************************************************************
@Created By :   Nisha Agrawal
@Created Date:  Jun 20, 2018
@Description:   Trigger on User object to 
                1. Provide Read/Edit access to Lead records to Disti Lead Portal users when new user onboarded
------------------------------------------------------------------------------------------------------------------------
@Modified By :      Nisha Agrawal
@Modified Date :    Jul 30, 2018
@Description :      Modified to Provide Edit access to Lead records to Disti Lead Portal users when promoted to Regional User role
-------------------------------------------------------------------------------------------------------------------------------
@Modified By :      Nisha Agrawal
@Modified Date :    Nov 21, 2018
@Description :      Modified to assign custmer community related permissions when user is promoted from Customer Community User 
                    (NXP Community) to Partner Community User(LeadPortal) via SSO
-------------------------------------------------------------------------------------------------------------------------------
@Modified By :      Baji
@Modified Date :    Feb 04, 2020
@Description :      Modified to merge the code from another trigger as there are two triggers on the same event
*****************************************************************************************************************************/

trigger User_AfterTrigger on User (after insert, after update) 
{
    Public static string SALESFORCE_LICENSE = 'Salesforce';
    Public static string SALESFORCE_PLATFORM_LICENSE = 'Salesforce Platform';
    
    if(trigger.IsAfter && trigger.IsInsert)
    {
        Set<String> setNewUserRegIds = new Set<String>();
        List<New_User_Registration__c> newUserList = new List<New_User_Registration__c>();
            for(User objUser:Trigger.new){
                if(objUser.New_User_Registration_ID__c != Null && objUser.New_User_Registration_ID__c.trim().length() > 0){
                    setNewUserRegIds.add(objUser.New_User_Registration_ID__c);            
                }
             }
        if(setNewUserRegIds.size()>0){
            UserTriggerHandler.updateStatus(setNewUserRegIds);
          }
     
        //Add to group, add users with SFDC license to public group
        Set<ID> setNXPuserIds = new Set<ID>();
        Set<ID> setNXPUserSFDCLicenseIds = new Set<ID>();//1608 SIR 1159 - Add by Scarlett, collect User Ids with SFDC License
        Set<ID> setProfileIds = new Set<ID>();
        Map<ID,Profile> mapProfiles;
        
  
    
        for(User objUser1: Trigger.New){
            setProfileIds.add(objUser1.ProfileId);
        }
        mapProfiles = new Map<ID,Profile>
        ([
            SELECT Id, Name, UserLicense.LicenseDefinitionKey, UserLicense.Name
            FROM profile 
            WHERE UserLicense.LicenseDefinitionKey!='PID_Customer_Community_Login' 
            AND Id in :setProfileIds
        ]);
    
        For(User objUser: Trigger.New){
            Profile pf = mapProfiles.get(objUser.ProfileId);
            if(pf != null){
            System.Debug('@@@Profile is '+pf.Name);
            if(
                pf.Name.left(3) != 'TS ' 
                && pf.Name.left(4) != 'NER ' 
            ){
                setNXPuserIds.add(objUser.id);
            }
            /***1608 SIR 1159 - Added by Scarlett***/            
            if(pf.UserLicense.Name == SALESFORCE_LICENSE || pf.UserLicense.Name == SALESFORCE_PLATFORM_LICENSE){
                setNXPUserSFDCLicenseIds.add(objUser.Id);
            }
                    
        }
    }
    
        UserTriggerHandler.addToGroups(setNXPuserIds);
        UserTriggerHandler.EnrollNXPUser(setNXPUserSFDCLicenseIds);
        
        UserTriggerHandler.IsFirstRun_LP = true;        
        UserTriggerHandler.shareLeadRecordsToLPUsers(trigger.new, trigger.oldMap);
      //  UserTriggerHandler.assignlightningcomponentpermission(Trigger.New);        
    }
    
    else if(trigger.IsAfter && trigger.IsUpdate)
    {
        UserTriggerHandler.assignCustomerCommunityPermissionsToLPUsers(trigger.new, trigger.oldMap);
        UserTriggerHandler.shareLeadRecordsToLPUsers(trigger.new, trigger.oldMap);  
      //  UserTriggerHandler.assignlightningcomponentpermission(Trigger.New);      
    }
}