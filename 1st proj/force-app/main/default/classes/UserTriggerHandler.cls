/**************************************************************************************
@Created By :    Nisha Agrawal
@Created Date:   Jun 22, 2018
@Description:    Class for all User Trigger Methods
---------------------------------------------------------------------
@Modified By :    Nisha Agrawal
@Modified Date:   Jul 31, 2018
@Description:     (CDLP-140)Modified shareLeadRecordsToLPUsers method to include User 
                    update scenario for Role promotion
-----------------------------------------------------------------------------------------
@Modified By :    Nisha Agrawal
@Modified Date:   Nov 21, 2018
@Description:     (CDLP-201)Modified to include new method to assign custmer community related 
                    permissions when user is promoted from Customer Community User (NXP Community) 
                    to Partner Community User(LeadPortal) via SSO
-----------------------------------------------------------------------------------------
@Modified By :    Nisha Agrawal
@Modified Date:   Jan 16, 2019
@Description:     Modified shareLeadRecordsToLPUsers method to include User 
                    update scenario when user is promoted from Customer Community User (NXP Community) 
                    to Partner Community User(LeadPortal)
******************************************************************************************/

public class UserTriggerHandler 
{
    public static boolean IsFirstRun_LP  = true;
        
    public static void assignPermissionSetToUsers(Set<Id> userIds)
    {
        if(userIds != null && userIds.size() > 0)
        {
            List<PermissionSetAssignment> lstAssignments = new List<PermissionSetAssignment>();
            
            List<PermissionSet> permissions = [Select Id, Name From PermissionSet Where Name =: JITHandlerLib.CUSTOMER_COMMUNITY_PERMISSIONS ];
            if(permissions.size() > 0)
            {
                for(Id userId : userIds)
                {
                    lstAssignments.add(New PermissionSetAssignment(PermissionSetId = permissions[0].Id, AssigneeId = userId));
                }                
                List<Database.SaveResult> lstResults = MixedDMLOps.ins(lstAssignments);
                for(Database.SaveResult objResult : lstResults)
                {
                    if(!objResult.isSuccess())
                    {
                        throw new JITHandlerLib.JitException('Error Occured while assigning permissions : ' + objResult.getErrors()[0].getMessage());   
                    }
                }
            }
            else
            {
                throw new JITHandlerLib.JitException('Error Occured : Customer Community Permissions not found.');   
            }    
        }
    }
    
 /*   public static void assignlightningcomponentpermission(List<User> userslist)
    {
        if(userslist != null){
            
            Permissionset objpermission = [SELECT Id,Name FROM PermissionSet where name = 'Aura_Apex_Class_Permissions' limit 1];
            if(objpermission  != null){
            set<Id> userids = new set<Id>();
            for(User objusers: userslist){
            userids.add(objusers.id);
            }
            
                
            
            List<PermissionSetAssignment> permissionSetList = new List<PermissionSetAssignment>();
            List<PermissionSetAssignment> getusers = [SELECT Id, PermissionSetId,AssigneeId FROM PermissionSetAssignment where PermissionSetId  =: objpermission.Id and Assigneeid in : userids ];
            
            set<id> userwithpermission = new set<Id>();
            for(PermissionSetAssignment pp : getusers){
                userwithpermission.add(pp.AssigneeId);
            }
               
            
            for(User objuser : userslist){
                if(!userwithpermission.contains(objuser.id) && objuser.Isactive == true){
                    PermissionSetAssignment psa = new PermissionSetAssignment();
                    psa.AssigneeId = objuser.id;
                    psa.PermissionSetId = objpermission .id;
                    permissionSetList.add(psa);
                    
                }
                
            }
            
            List<Database.SaveResult> lstResults = MixedDMLOps.ins(permissionSetList);
            for(Database.SaveResult objResult : lstResults)
            {
                if(!objResult.isSuccess())
                {
                    throw new JITHandlerLib.JitException('Error Occured while assigning permissions : ' + objResult.getErrors()[0].getMessage());   
                }
            }
        }
            
        }
    } */
    
    public static void assignCustomerCommunityPermissionsToLPUsers(List<User> newUserList, Map<Id, User> oldUserMap)
    {
        if(newUserList != null && newUserList.size() > 0 && oldUserMap != null && oldUserMap.size() > 0)
        {
            //ensure that we have profile id value
            if(LeadPortalLib.LP_EXTERNAL_PROFILE_Id == null)
            {
                LeadPortalLib.getExternalUserProfile();
            }
            
            CasePortalUtil.getCustomerCommunityUserProfile();
            
            User oldUser;
            Set<Id> upgradedUsers = new Set<Id>();
            for(User objUser : newUserList)
            {
                if(objUser.IsActive == true && objUser.ProfileId == LeadPortalLib.LP_EXTERNAL_PROFILE_Id )
                {
                    if(CasePortalUtil.CUSTOMER_COMMUNITY_USER_PROFILE_ID == null || CasePortalUtil.CUSTOMER_COMMUNITY_PLUS_PROFILE_Id == null)
                    {
                        throw new JITHandlerLib.JitException('Error Occured : Customer Community Profiles not found.');
                    }
                    
                    oldUser = (oldUserMap != null ? oldUserMap.get(objUser.Id): null) ;
                
                    //check if profile is changed from Customer Community User to Partner Community User
                    if(oldUser != null && (oldUser.ProfileId == CasePortalUtil.CUSTOMER_COMMUNITY_USER_PROFILE_ID  || 
                                           oldUser.ProfileId == CasePortalUtil.CUSTOMER_COMMUNITY_PLUS_PROFILE_Id))
                    {
                        upgradedUsers.add(objUser.Id);
                    }
                }
            }
            //assign the permission set
            assignPermissionSetToUsers(upgradedUsers);
        }
    }
    
    
    public static void shareLeadRecordsToLPUsers(List<User> newUserList, Map<Id, User> oldUserMap)
    {
        if(IsFirstRun_LP)
        {
            //ensure that we have profile id value
            if(LeadPortalLib.LP_EXTERNAL_PROFILE_Id == null)
            {
                LeadPortalLib.getExternalUserProfile();
            }
            
            CasePortalUtil.getCustomerCommunityUserProfile();
            
            //make a map of contacts linked to user
            Map<Id, Id> mapUserToLinkedContact = new Map<Id, Id>();
            Map<Id, String> mapUserToDistiUserRole = new Map<Id, String>();
            Map<Id, Boolean> mapUserActive = new Map<Id, Boolean>();
            Set<Id> promotedUsers = new Set<Id>();
            Set<Id> portalUpgradedUsers = new Set<Id>();
            User oldUser;
                        
            for(User objUser : newUserList)
            {
                //check if active Lead Portal User
                if(objUser.IsActive == true && objUser.ProfileId == LeadPortalLib.LP_EXTERNAL_PROFILE_Id && 
                   objUser.Disti_Lead_Portal_User_Role__c != null) 
                {          
                    //check if any existing user
                    oldUser = (oldUserMap != null ? oldUserMap.get(objUser.Id): null) ;
                    if(oldUser != null)
                    {
                        //check if role changed
                        if(oldUser.Disti_Lead_Portal_User_Role__c != null && oldUser.Disti_Lead_Portal_User_Role__c != objUser.Disti_Lead_Portal_User_Role__c ) 
                        {
                            if(oldUser.Disti_Lead_Portal_User_Role__c == LeadPortalLib.PORTAL_ROLE_USER && 
                                objUser.Disti_Lead_Portal_User_Role__c == LeadPortalLib.PORTAL_ROLE_REGIONAL) //User got promoted from User to Regional Role
                            {
                                promotedUsers.add(objUser.Id);
                            }
                        }
                        if(oldUser.ProfileId != objUser.ProfileId ) //check if profile changed from customer community to lead portal
                        {
                            portalUpgradedUsers.add(objUser.Id);
                        }
                    }
                    
                    mapUserToLinkedContact.put(objUser.Id, objUser.ContactId);
                    mapUserToDistiUserRole.put(objUser.Id, objUser.Disti_Lead_Portal_User_Role__c);
                    mapUserActive.put(objUser.Id, objUser.isActive);
                }
            }
            system.debug('mapUserActive' +mapUserActive);
            if(mapUserToLinkedContact.size() > 0)
            {
                //fetch the contact details like accountid , User Region etc
                //To get the leads assigned to other contacts in that region for that disti               
                Map<Id, Id> mapContactToAccountId = new Map<Id, Id>();
                Map<Id, String> mapContactToRegion = new Map<Id, String>();
                
                for(Contact objContact : [Select Id, AccountId, User_Region__c From Contact Where Id in: mapUserToLinkedContact.values()])
                {
                    mapContactToAccountId.put(objContact.Id, objContact.AccountId);
                    mapContactToRegion.put(objContact.Id , objContact.User_Region__c);
                }
                //fetch all the contacts for those distis regardless of regions
                //and create a map of account to contacts
                Map<Id, Set<Id>> mapAccountToContacts = new Map<Id, Set<Id>>();
                
                for(Contact objContact : [Select Id, AccountId From Contact Where AccountId in :mapContactToAccountId.values()])
                {
                    if(mapAccountToContacts.containsKey(objContact.AccountId))
                    {
                        mapAccountToContacts.get(objContact.AccountId).add(objContact.Id);
                    }
                    else
                    {
                        mapAccountToContacts.put(objContact.AccountId, new Set<Id>{objContact.Id});
                    }
                }
                
                //map of Users to set of contact Ids for other contacts in that User region from that disti
                Map<Id , Set<Id>> mapUserToOtherContacts = new Map<Id, Set<Id>>();
                Set<Id> contactIdsToFetchLeads = new Set<Id>();
                Id accountLinkedToUser;
                            
                for(Id userId : mapUserToLinkedContact.keySet())
                {
                    Id contactLinkedToUser = mapUserToLinkedContact.get(userId);
                    accountLinkedToUser = mapContactToAccountId.get(contactLinkedToUser);
                    
                    if(mapAccountToContacts.containsKey(accountLinkedToUser))
                    {
                        Set<Id> otherContacts = mapAccountToContacts.get(accountLinkedToUser);                    
                        //remove contact linked to user from otherContacts set
                        otherContacts.remove(contactLinkedToUser);
                        
                        contactIdsToFetchLeads.addAll(otherContacts);
                        mapUserToOtherContacts.put(userId, otherContacts);
                    }
                }
            
                //create a combined set of contact Ids for which we have to fecth leads              
                contactIdsToFetchLeads.addAll(mapUserToLinkedContact.values());
                system.debug('contactIdsToFetchLeads' +contactIdsToFetchLeads);
                //fetch all leads for the selecetd distributor contacts
                //create a map of contact to set of leads
                Map<Id, Set<Lead>> mapContactToLeads = new Map<Id, Set<Lead>>();
                
                for(Lead objLead : [Select Id, Distributor_Contact__c, Region__c From Lead Where Distributor_Contact__c  in : contactIdsToFetchLeads])
                {
                    if(mapContactToLeads.containsKey(objLead.Distributor_Contact__c))
                    {
                        mapContactToLeads.get(objLead.Distributor_Contact__c).add(objLead);
                    }
                    else
                    {
                        mapContactToLeads.put(objLead.Distributor_Contact__c, new Set<Lead>{objLead});
                    }
                }
                
                List<LeadPortalLib.CustomLeadShare> lstShares = new List<LeadPortalLib.CustomLeadShare>();
                Id linkedContactId;
                    
                //scenario 1-  User is assigned as Disti Contact to Leads
                for(Id userId : mapUserToLinkedContact.keySet())
                {
                    system.debug('mapUserToLinkedContact' +mapUserToLinkedContact);
                    if(oldUserMap != null && oldUserMap.containsKey(userId) && !(portalUpgradedUsers.contains(userId)) && oldUserMap.get(userId).isActive == mapUserActive.get(userId)) //  no change in sharing if user record changed or existing disti user only changed
                    {
                        continue;
                    }
                    else
                    {
                        system.debug('Hiiiiiiiii');
                        linkedContactId = mapUserToLinkedContact.get(userId);
                        
                        //check if any lead exists
                        if(mapContactToLeads.containsKey(linkedContactId))
                        {
                            for(Lead objLead : mapContactToLeads.get(linkedContactId))
                            {
                                lstShares.add(new LeadPortalLib.CustomLeadShare(objLead.Id, userId, LeadPortalLib.ACCESS_TYPE.Edit)); 
                            }
                        }    
                    }
                }
                
                String strUserRole;
                String strUserRegion;
                
                //scenario 2- Leads assigned to other contacts from linked disti for the same lead region
                for(Id userId : mapUserToOtherContacts.keySet())
                {
                    //create sharing records if either new user or user got promoted to regional role
                    if( (oldUserMap == null) || ( oldUserMap != null && oldUserMap.containsKey(userId) && (promotedUsers.contains(userId) ||  portalUpgradedUsers.contains(userId))))
                    {
                        strUserRole = mapUserToDistiUserRole.get(userId);
                        strUserRegion = mapContactToRegion.get(mapUserToLinkedContact.get(userId));                    
                        
                        for(Id otherContactId : mapUserToOtherContacts.get(userId))
                        {
                            //check if any lead exists for this contact
                            if(mapContactToLeads.containsKey(otherContactId))
                            {
                                for(Lead objLead : mapContactToLeads.get(otherContactId))
                                {
                                    //check if lead region is same as user region
                                    if(objLead.Region__c != null && strUserRegion != null && objLead.Region__c.toLowerCase() == strUserRegion.toLowerCase())
                                    {
                                         LeadPortalLib.ACCESS_TYPE leadAccess = (strUserRole == LeadPortalLib.PORTAL_ROLE_REGIONAL ?
                                                                             LeadPortalLib.ACCESS_TYPE.Edit :  LeadPortalLib.ACCESS_TYPE.Read);
                                         lstShares.add(new LeadPortalLib.CustomLeadShare(objLead.Id, userId, leadAccess));
                                    }
                                }
                            }
                        }
                    }
                }
                
                //TODO : Error Handling part
                //create sharing records
                if(lstShares.size() > 0)
                {
                    //Call future method only to avoid mixed DML issue
                    String strShareAsJSON = JSON.serialize(lstShares);
                    LeadPortalLib.shareLeadAccessToUsers(strShareAsJSON); 
                }                
            }
            IsFirstRun_LP = false;   
        }
    }
    
    //Chatter Auto-follow
    Public static string GROUP_USER_HELP_SUPPORT = 'User Help & Support';
    Public static string GROUP_BEST_PRACTICES = 'Best Practices';
    
    
@future
     Public static void addToGroups(Set<Id> userIds)
      {

             List<User> users=[select id, Username from User where id in :userIds];
 
  
            // set up the groups that the user should be added to
            //  List<String> groups=new List<String>{'0F9D00000004DMQKA2','0F9D00000004y9KKAQ'};
  
             List<CollaborationGroup> chatterGroups=[select id, Name from CollaborationGroup 
                                                     where Name=:GROUP_USER_HELP_SUPPORT OR Name=:GROUP_BEST_PRACTICES limit 2];
 
            List<CollaborationGroupMember> chatterGroupMembers=new List<CollaborationGroupMember>();
            if(chatterGroups != null){
             // loop the users that have been created
             for (User user : users)
              {
               // loop the groups
                  for (CollaborationGroup chatterGroup : chatterGroups)
                   {
                   // add the user to the group
                       CollaborationGroupMember colGrpMem =  new CollaborationGroupMember(CollaborationGroupId=chatterGroup.id,
                                                                                     MemberId = user.Id);
                       chatterGroupMembers.add(colGrpMem);
                      
                   }
               }
            }
          insert chatterGroupMembers;
  
     }
 
 //Group Auto-Follow
 
   public static string GROUP_NAME = 'All Internal NXP Users'; //added by Nisha Agrawal on Aug 21, 2017 to expose it in test class
   Public static void EnrollNXPUser(Set<Id> userIds)
     {
           List<User> userList =[Select Id from User where Id in :userIds] ;
           string groupId; 
            //checking the focus group exists or not. if doesn't create the group and attach the user
           //List<Group> groupList =[Select Id from Group where name ='All Internal NXP Users']; //commented by Nisha Agrawal on Aug 21,2017
           List<Group> groupList =[Select Id from Group where name =: GROUP_NAME]; //added by Nisha Agrawal on Aug 21,2017
            if(!groupList.isEmpty())
            {
                groupId = groupList[0].Id;
            }
            else
            {
                //Group g = new Group(Name='All Internal NXP Users'); //commented by Nisha Agrawal on Aug 21,2017
                  Group g = new Group(Name = GROUP_NAME); //added by Nisha Agrawal on Aug 21,2017
                  insert g;
                  groupId = g.Id; 
            }

            List<GroupMember> gMemberList = new List<GroupMember>();
        
            for(User u :userList)
            {
               GroupMember gMember = new GroupMember();
               gMember.UserOrGroupId = u.Id;
               gMember.GroupId = groupId;
               gMemberList.add(gMember);
            }

            if(!gMemberList.isEmpty()) 
          //  insert gMemberList;
                MixedDMLOps.ins( gMemberList );
        
    }
    
     @Future(callout=true)
        Public static void updateStatus(Set<String> ids){
        
        List<New_User_Registration__c> newUserList = [Select id,name,status__c from New_User_Registration__c where id in: ids];
        if(newUserList.size()>0){
            for(New_User_Registration__c newUsr: newUserList){
                newUsr.status__c = 'User A/c Created';
            }
            update newUserList;
        } 
  }
    
    
}