/************************************************************************
@Created By :    Gunjan Singh
@Created Date:   19 Jun 2019
@Description:    Created as part of SFDC-2798 - Util Class to upgrade the license and to assign the permission sets
                 according to the Role and Contact Service Level of User.
----------------------------------------------------------------------------------------
@Modified By :      Gunjan Singh
@Created Date:     19 July 2019
@Description:      SFDC-3145 Invited Cases and Projects should also be visible in Home Page
------------------------------------------------------------------------------------------
@Modified By :     Gunjan Singh
@Created Date:     23 July 2019
@Description:      SFDC-3125 Comment the Code Related to Email CC Functionality for NCP
---------------------------------------------------------------------------------------
@Modified By :     Nisha Agrawal
@Created Date:     Sep 16, 2019
@Description:      To Add code related to sharing on project owner update and refactor other sharing related code
----------------------------------------------------------------------------------------------------------------
@Modified By :     Nisha Agrawal
@Created Date:     Oct 04, 2019
@Description:      To fix the issue where exception occurs if case was shared with case creator user
---------------------------------------------------------------------------------------------------------------
@Modified By :     Gunjan Singh/Nisha Agarwal
@Modified Date:    Oct 18, 2019
@Description:      Modified this class as part of SFDC-3380 Refactor Security Model for license upgrade from CC to CC+
**********************************************************************************************************/
/************************************************************************
@Modified By :    Gunjan Singh
@Modified Date:   11 Nov 2019
@Description:    Modified as part of SFDC-3465 to add getTSCommunityCases method to get TS Record Type Cases
----------------------------------------------------------------------------------------*/

public without sharing Class CasePortalUtil 
{
    public class CasePortalException extends Exception{}
    
    //License Variables
    public static String CUSTOMER_COMMUNITY_LICENSE = 'Customer Community Login';
    
    //PermissionSet Variables
    public static String RECORD_TYPE_PERMISSIONSET = 'CP_ProjectRecordType_Permission';
    public static String CASE_PROJANDPROJTEAM_PERMISSIONSET = 'CP_CaseProjAndProjTeam_Permission';
    
    //Profile Variables
    public static String INTERNAL_FAE_PROFILE = 'NXP Sales Cloud User';
    public static String SYSTEM_ADMIN_PROFILE = 'System Administrator';
    public static String INTERNAL_AGENT_PROFILE='NXP Tech Support';
    public static String COMMUNITY_USER_PROFILE = 'NXP Customer Community Login User';    
    public static String COMMUNITY_PLUS_USER_PROFILE='NXP Customer Community Plus Login User';
    public static Set<String> PROFILES_WITH_FULL_ACCESS_TO_CASES = new Set<String>{SYSTEM_ADMIN_PROFILE, INTERNAL_FAE_PROFILE, INTERNAL_AGENT_PROFILE };        
        
    //CSL Variables for DFAE's
    public static String DFAE_SERVICE_LEVEL1 = 'A2_Certified_DFAE';
    public static String DFAE_SERVICE_LEVEL2 = 'A2_Partner';
    public static String DFAE_SERVICE_LEVEL3 = 'A2_Champion_DFAE';
    
    //Project Team Role Variables
    public static String PROJECT_TEAM_ROLE_OWNER = 'Owner';
    public static String PROJECT_TEAM_ROLE_PARTICIPANT = 'Participant';
    
    //Project Team Status Variable
    public static String PROJECT_TEAM_STATUS_ACCEPTED = 'Accepted';
    public static String PROJECT_TEAM_STATUS_INVITED = 'Invited';

    //Record Sharing Variables
    public static string SHARING_REASON = 'Manual';
    
    // Profile Id Variable
    public static Id CUSTOMER_COMMUNITY_PLUS_PROFILE_Id;
    public static Id CUSTOMER_COMMUNITY_USER_PROFILE_ID;
    public static Id INTERNAL_AGENT_PROFILE_ID;
    public static Id SYSTEM_ADMIN_PROFILE_Id;
    
    public static integer FILE_UPLOAD_ALLOWED_DAYS = 30 ; //in days
    public static String CASE_STATUS_CANCEL = 'CANCEL';
    public static String CASE_STATUS_CLOSE = 'CLOSE';
    public static String CASE_STATUS_RECEIVEDREPLY = 'Received Reply';
    
    public static List<OrgWideEmailAddress> lstOrgWideEmails;
    static
    {
        CUSTOMER_COMMUNITY_PLUS_PROFILE_Id = getUserProfileId(COMMUNITY_PLUS_USER_PROFILE);
    }
    static//added by saranya on Sep 05, 2019
    {
        SYSTEM_ADMIN_PROFILE_Id = getSysAdminUserProfileId(SYSTEM_ADMIN_PROFILE);
    }
    static{
        INTERNAL_AGENT_PROFILE_ID = getInternalUserProfileId();
    }
    
    public static final String ACCOUNT_NAME = 'NXP Community';
    public static Id NXP_COMMUNITY_ACCOUNT_ID ;
    
    static{
        if(NXP_COMMUNITY_ACCOUNT_ID == null){
            List<Account> lstAccounts = [SELECT Id FROM Account WHERE Name =: ACCOUNT_NAME ];
            if(lstAccounts.size() > 0)
            {
                NXP_COMMUNITY_ACCOUNT_ID = lstAccounts[0].Id;    
            }
        }
    }
    
    //Method to return OrgWideEmail Addresses
    public static List<OrgWideEmailAddress> getOrgWideEmailAddress()
    {
        if(lstOrgWideEmails == null)
        {
           lstOrgWideEmails = [Select Id, Address, DisplayName From OrgWideEmailAddress];
        }
        return lstOrgWideEmails;
    }
    
    //Method to return profileId based on profileName
    public static Id getInternalUserProfileId()
    {
        if(INTERNAL_AGENT_PROFILE_ID == null){
            List<Profile> lstProfiles = [Select Id, Name from Profile Where Name =: INTERNAL_AGENT_PROFILE limit 1];
            if(lstProfiles.size() > 0)
            {
                 INTERNAL_AGENT_PROFILE_ID = lstProfiles[0].Id;
            }
            else{
                throw new CasePortalException('Error Occured :' + INTERNAL_AGENT_PROFILE + 'Profile not found.');
            } 
        }
        return INTERNAL_AGENT_PROFILE_ID;              
    }
    
    // Method to be called from login flow at the time of user login, Permission sets to be assigned based on CSL
    @InvocableMethod(label='InvokeApexFromFlow')
    public static void getUserInfo(List<User> lstUser) 
    {    
        List<User> lstUsers = [Select Id,Contact.Contact_Service_Level__c,Profile.Name
                               FROM User WHERE Id = :lstUser[0].Id];
        assignPerSetAePerCSL(lstUsers);
    }
    
    //method added by Nisha Agrawal on Nov 22 to create contact for internal users from portal
    @AuraEnabled
    public static void autoCreateContactForInternalUser()
    {
        Id currentUserId = UserInfo.getUserId();
        List<User> lstUsers = [SELECT Id, FirstName, LastName, Email, ContactId, Contact_Id__c FROM User WHERE Id = :currentUserId];
        if(lstUsers.size() > 0 )
        {
            User objUser = lstUsers[0];
            if(objUser.ContactId == null) //to filter out external users (for extra safety)
            {
                if(String.isBlank(objUser.Contact_Id__c)) //check if value in custom field is blank
                {
                    List<Contact> lstContacts = [Select Id From Contact Where Email=: objUser.Email limit 1];
                    if(lstContacts.size() > 0 )
                    {   
                        //update the User and Contact records                    
                        objUser.Contact_Id__c = lstContacts[0].Id;
                    }
                    else
                    {
                        Contact userContact = new Contact( FirstName = objUser.FirstName,LastName = objUser.LastName,
                                                          Email = objUser.Email, AccountId = NXP_COMMUNITY_ACCOUNT_ID, Community_Web_Country__c = 'Unknown');
                        insert userContact ;
                        
                        objUser.Contact_Id__c = userContact.Id;
                    }
                    
                    update objUser;
                }
            }            
        }        
    }
    
    // Method to return the thread id of case to be used in email templates.
    public static String getCaseThreadId(Id caseId)
    {
        String strThreadId;
        if(caseId != null)
        {
            String strCaseId = String.valueOf(caseId);
            strThreadId = '[ ref:_' + UserInfo.getOrganizationId().left(5) + UserInfo.getOrganizationId().mid(11,4) + '._'
                           + strCaseId.left(5) + strCaseId.mid(10,5) + ':ref ]'; 
        }
        return strThreadId;
    }
    
    // Method to identify conditions for Case Status Update to Recieved Reply
    public static BOOLEAN canUpdateCaseStatusToRecievedReply(Case objCase){
        if(objCase.Status != CASE_STATUS_CLOSE && objCase.Status != CASE_STATUS_CANCEL){
            return TRUE;
        }
        if(objCase.Status.equalsIgnoreCase(CASE_STATUS_CLOSE) && objCase.ClosedDate  >= DateTime.Now()- FILE_UPLOAD_ALLOWED_DAYS ){
            return TRUE;
        }
        if((objCase.Status.equalsIgnoreCase(CASE_STATUS_CLOSE) && objCase.ClosedDate  <= DateTime.Now()- FILE_UPLOAD_ALLOWED_DAYS) || objCase.Status.equalsIgnoreCase(CASE_STATUS_CANCEL) ){
            return FALSE;
        }
        return FALSE;
    }
    
    //Method to assign permission set
    @future
    public static void assignPermissionSetToUserFuture(String strUserPermiJSON,String perSetName ) 
    {
        //deserilize JSON to object list        
        List<User> lstUsers = (List<User>)JSON.deserialize(strUserPermiJSON , List<User>.Class);
        assignPermissionSetToUser(lstUsers,perSetName);
    }    
     
    //Method to assign permission set according to CSL
    public static void assignPerSetAePerCSL(List<User> lstUsers) 
    {   
        List<User> lstUserDFAE = new List<User>();
        List<User> lstUserInternalFAE = new List<User>();
        Set<Id> setUserId = new Set<Id>();
        for(User objUser : lstUsers){
            if(objUser.Contact != null && objUser.Contact.Contact_Service_Level__c!= null)
            {
                // Condition for DFAE's
                if(objuser.Contact.Contact_Service_Level__c.startswith('A') && (objuser.Contact.Contact_Service_Level__c.equalsIgnoreCase(DFAE_SERVICE_LEVEL1) || objuser.Contact.Contact_Service_Level__c.equalsIgnoreCase(DFAE_SERVICE_LEVEL2) || objuser.Contact.Contact_Service_Level__c.equalsIgnoreCase(DFAE_SERVICE_LEVEL3))){
                    lstUserDFAE.add(objuser);  
                }
                
                // Condition for Degraded DFAE's
                if((!objuser.Contact.Contact_Service_Level__c.equalsIgnoreCase(DFAE_SERVICE_LEVEL1) && !objuser.Contact.Contact_Service_Level__c.equalsIgnoreCase(DFAE_SERVICE_LEVEL2) && !objuser.Contact.Contact_Service_Level__c.equalsIgnoreCase(DFAE_SERVICE_LEVEL3))){
                    lstUserDFAE.add(objuser);
                    if(lstUserDFAE.size()>0){
                        for(User objectUser: lstUserDFAE){
                            setUserId.add(objectUser.Id);
                        }
                    }
                }
            }
            
            // For internal FAE's checking the profile name and assigning the permission set 
            if(objuser.Profile.Name.equalsIgnoreCase(INTERNAL_FAE_PROFILE)){
                lstUserInternalFAE.add(objUser);
            }
        }
        
        if(lstUserInternalFAE.size()>0){
            assignPermissionSetToUser(lstUserInternalFAE,CASE_PROJANDPROJTEAM_PERMISSIONSET);
        }
        if(lstUserDFAE.size()>0){
            assignPermissionSetToUser(lstUserDFAE,RECORD_TYPE_PERMISSIONSET);
        }
        if(setUserId.size()>0){
            deletePermissionSet(setUserId,RECORD_TYPE_PERMISSIONSET);
        }
    }
    
    //Method to assign permission set to user
    public static void assignPermissionSetToUser(List<User> lstUsers, String perSetName){
   
        Set<Id> setUserId = new Set<Id>();
        
        for(User objUser: lstUsers){
            setUserId.add(objUser.Id);
        }
        
        Set<Id> lstUserIdHavingPerSet = new Set<Id>();
        List<PermissionSetAssignment> lstPermSetAssign = new List<PermissionSetAssignment>();
        List<PermissionSetAssignment> lstAssignments = new List<PermissionSetAssignment>();
        lstPermSetAssign = [SELECT AssigneeId FROM PermissionSetAssignment WHERE PermissionSet.Name = :perSetName AND AssigneeId In :setUserId];
        
        for(PermissionSetAssignment objperSet : lstPermSetAssign)
        {
            lstUserIdHavingPerSet.add(objperSet.AssigneeId);    
        }
        if(lstUserIdHavingPerSet.size()>0){
            setUserId.removeAll(lstUserIdHavingPerSet);
        }   
            
        if(setUserId != null && setUserId.size() > 0)
        {
           List<PermissionSet> permissions = [Select Id, Name From PermissionSet Where Name = :perSetName];
           if(permissions.size() > 0)
           { 
                for(Id userId : setUserId)
                {
                    lstAssignments.add(New PermissionSetAssignment(PermissionSetId = permissions[0].Id, AssigneeId = userId ));                    
                } 
                               
                List<Database.SaveResult> lstResults = MixedDMLOps.ins(lstAssignments);
                for(Database.SaveResult objResult : lstResults)
                {
                    if(!objResult.isSuccess())
                    {
                        throw new CasePortalException('Error Occured while assigning permissions : ' + objResult.getErrors()[0].getMessage());   
                    }
                }
           }
           else
           {
                throw new CasePortalException('Error Occured : '+ perSetName +' Permission Set not found.');   
           }
           
        }    
    }
    
    //Method to delete permission set of User
    public static void deletePermissionSet(Set<Id> setUserId, String permiSetName)
    {   
        Set<Id> setUserIdToDeletePerSet = new Set<Id>();    
        Set<Id> lstUserIdHavingPerSet = new Set<Id>();
        List<PermissionSetAssignment> lstPermSetAssign = new List<PermissionSetAssignment>();
        
        List<PermissionSet> permEmail = [Select Id, Name From PermissionSet Where Name = :permiSetName];
        
        lstPermSetAssign = [SELECT AssigneeId FROM PermissionSetAssignment WHERE PermissionSet.Name = :permiSetName AND AssigneeId In :setUserId ];
        
        for(PermissionSetAssignment objperSet : lstPermSetAssign)
        {
            lstUserIdHavingPerSet.add(objperSet.AssigneeId);    
        }
        if(permEmail.size() > 0)
        {
            for(Id userId : lstUserIdHavingPerSet)
            {
                setUserIdToDeletePerSet.add(userId);
                
            }
            if(setUserIdToDeletePerSet.size()>0){
                try{
                    delete [SELECT Id from PermissionSetAssignment WHERE PermissionSetId = : permEmail[0].id AND AssigneeId IN : setUserIdToDeletePerSet];
                }
                catch(Exception e){
                    System.debug('The following exception has occurred: ' + e.getMessage());
                }
            }
        }
        else
        {
            throw new CasePortalException('Error Occured :'+ permiSetName + 'Permission Set not found.');   
        }
    }
    
    //Method to return Map of TS Community Cases based on set of CaseIds
    //@Description:    Created as part of SFDC-3465 File Upload as per conditions.
    public static Map<Id,Case> getTSCommunityCases(Set<Id> setCaseId) {
        
        Id tscommunityRecordType = Schema.SObjectType.Case.getRecordTypeInfosByName().get('TS Community').getRecordTypeId();
        //Query to find the cases related to TS Community Record Type
        return new Map<Id, Case>([Select Id, Status, ClosedDate                                                                
                                   From Case Where Id IN: setCaseId and Case.RecordTypeId = : tscommunityRecordType]);
        
    } 
    
    // Method to return users based on email addresses
    public static Set<User> getUserDetailsBasedOnEmail(Set<String> userEmails){
        return new Set<User>([Select Id,Name,ContactId, email,ProfileId,Contact.Contact_Service_Level__c,User_License__c,Profile.Name from User where email in: userEmails AND IsActive = true]);
    }
    
    //code block added by Nisha Agrawal on Sep 03, 2019
    public static void getCustomerCommunityUserProfile()
    {
        if(CUSTOMER_COMMUNITY_USER_PROFILE_ID == null)
        {
            List<Profile> lstProfiles = [Select Id, Name from Profile Where Name =: COMMUNITY_USER_PROFILE  limit 1];
            if(lstProfiles.size() > 0)
            {
                CUSTOMER_COMMUNITY_USER_PROFILE_ID = lstProfiles[0].Id;
            }
        }
    }
    
    //Method to return profileId based on profileName
    public static Id getUserProfileId(String profileName)
    {
        if(CUSTOMER_COMMUNITY_PLUS_PROFILE_Id == null){
            List<Profile> lstProfiles = [Select Id, Name from Profile Where Name =: COMMUNITY_PLUS_USER_PROFILE limit 1];
            if(lstProfiles.size() > 0)
            {
                 CUSTOMER_COMMUNITY_PLUS_PROFILE_Id = lstProfiles[0].Id;
            }
            else{
                throw new CasePortalException('Error Occured :' + profileName + 'Profile not found.');
            } 
        }
        return CUSTOMER_COMMUNITY_PLUS_PROFILE_Id;              
    }
    
    //Method to return profileId based on profileName
    public static Id getSysAdminUserProfileId(String profileName)
    { 
        if(SYSTEM_ADMIN_PROFILE_Id == null){
            List<Profile> lstSysAdminProfiles = [Select Id, Name from Profile Where Name =: SYSTEM_ADMIN_PROFILE limit 1];
            if(lstSysAdminProfiles.size() > 0)
            {
                 SYSTEM_ADMIN_PROFILE_Id = lstSysAdminProfiles[0].Id;
            }
            else{
                throw new CasePortalException('Error Occured :' + profileName + 'Profile not found.');
            } 
        }
        return SYSTEM_ADMIN_PROFILE_Id;              
    }
    
    //Method to update Profile of User
    public static void UpdateUserProfile(Set<User> lstUsers){
        List<User> listUpdatedUser = new List<User>();
        for(User objUser: lstUsers){
            if(objUser.User_License__c == CUSTOMER_COMMUNITY_LICENSE ){
                objUser.ProfileId = CUSTOMER_COMMUNITY_PLUS_PROFILE_Id;
                objUser.HasAcceptedProjects__c = TRUE; // Added as part of SFDC-3145 Invited Cases and Projects should also be visible in Home Page 
                listUpdatedUser.add(objUser);
            }
        }
        if(listUpdatedUser.size()>0){
             try
             {
                 //updated by Nisha Agrawal on Jul 29, 2019 to call method from MixedDMLOps class to avoid mixed DML issue in test class context
                 MixedDMLOps.up(listUpdatedUser);
                 assignPerSetAePerCSL(listUpdatedUser);
             }
             catch(Exception e){
                 System.debug('The following exception has occurred: ' + e.getMessage());
             }
         }
    }
     
    /*** code block by Nisha Agrawal ***/
    private static void createProjectShareRecords(List<Project__Share> lstProjectShares)
    {
        if(lstProjectShares != null && lstProjectShares.size() > 0)
        {
            //calling method from MixedDMLOps class to avoid mixed DML issue in test class context
            List<Database.SaveResult> lstResults = MixedDMLOps.ins(lstProjectShares);                   
            for(Database.SaveResult objResult : lstResults)
            {
                if(!objResult.isSuccess())
                {                 
                    // Get first save result error.
                    Database.Error err = objResult.getErrors()[0];
                    
                    // Check if the error is related to trival access level. Access level must be more permissive than 
                    // the object's default. These sharing records are not required and thus an insert exception is acceptable. 
                    if(err.getStatusCode() == StatusCode.FIELD_FILTER_VALIDATION_EXCEPTION  &&  
                       err.getMessage().contains('AccessLevel'))
                    {
                        continue;
                    }
                    else
                    {
                        //TODO : exception handling
                        system.debug('==error, failed to create project share record : ' + err.getMessage());                            
                    }
                }
            }   
        }
    }
    
    private static void createCaseShareRecords(List<CaseShare> lstCaseShares)
    {
        if(lstCaseShares != null && lstCaseShares.size() > 0)
        {
            //calling method from MixedDMLOps class to avoid mixed DML issue in test class context
            List<Database.SaveResult> lstResults = MixedDMLOps.ins(lstCaseShares);
            
            for(Database.SaveResult objResult : lstResults)
            {
                if(!objResult.isSuccess())
                {                 
                    // Get first save result error.
                    Database.Error err = objResult.getErrors()[0];
                    
                    // Check if the error is related to trival access level. Access level must be more permissive than 
                    // the object's default. These sharing records are not required and thus an insert exception is acceptable. 
                    if(err.getStatusCode() == StatusCode.FIELD_FILTER_VALIDATION_EXCEPTION  &&  
                       err.getMessage().contains('AccessLevel'))
                    {
                        continue;
                    }
                    else
                    {
                        //TODO : exception handling                       
                        system.debug('==error, failed to create case share record : ' + err.getMessage());                            
                    }
                }
            }   
        }
    }
    
    public static void shareProjectAccessToNewOwner(List<Project__c> lstProjects, Map<Id, Id> mapProjectToOldOwners)
    {
        if(lstProjects != null && mapProjectToOldOwners != null )
        {
            //give case access to new owners                           
            Map<Id, Set<Case>> mapProjectToCases = new Map<Id, Set<Case>>();
            Set<Id> caseIds = new Set <Id>(); //to keep track of all case ids
            
            for(Case objCase : [Select Id, Projects__c, ContactId from Case Where Projects__c in : mapProjectToOldOwners.keySet()])
            {
                caseIds.add(objCase.Id);
                if(mapProjectToCases.containsKey(objCase.Projects__c))
                {
                    mapProjectToCases.get(objCase.Projects__c).add(objCase);
                }
                else
                {
                    mapProjectToCases.put(objCase.Projects__c, new Set<Case>{objCase});
                }
            }
            
            //fetch all project owner user's detail (ContactId)
            Set<Id> projectOwnerIds = new Set<Id>();
            for(Project__c objProject : lstProjects)
            {
                projectOwnerIds.add(objProject.OwnerId);
            }
            //project owner user record 
            Map<Id, User> mapUserIdToUser = new Map<Id, User>([Select Id, ContactId, Profile.Name From User 
                                                               Where Id in : projectOwnerIds and IsActive = true]); 
            
            List<CaseShare> lstCaseShares = new List<CaseShare>();            
            
            for(Project__c objProject : lstProjects)
            {
                if(mapProjectToCases.containsKey(objProject.Id))
                {
                    for(Case objCase : mapProjectToCases.get(objProject.Id))
                    {
                        //dont add sharing if team member already have access to this case 
                        //if team member user profile is sys admin/internal agent/internal FAE or team member is case contact
                        User ownerUser = mapUserIdToUser.get(objProject.OwnerId);
                        if(ownerUser != null && !(PROFILES_WITH_FULL_ACCESS_TO_CASES.contains(ownerUser.Profile.Name) 
                                                      || objCase.ContactId == ownerUser.ContactId))
                        {
                            lstCaseShares.add(new CaseShare(CaseId = objCase.Id , UserOrGroupId = objProject.OwnerId , 
                                                            CaseAccessLevel = 'Edit', RowCause = SHARING_REASON));      
                        }
                    }
                }
            }
            
            if(lstCaseShares.size() > 0)
            {
                createCaseShareRecords(lstCaseShares);  
            }
            
            //now remove access for old owners
            if(mapProjectToOldOwners.size() > 0)
            {
                List<CaseShare> lstShares = [Select Id, CaseId, UserOrGroupId From CaseShare 
                                                Where CaseId in : caseIds and UserOrGroupId in : mapProjectToOldOwners.values() 
                                                    and RowCause =: SHARING_REASON ];
                
                List<CaseShare> shareRecordsToDelete = new List<CaseShare>();                
                for(Id projectId : mapProjectToCases.keySet()) 
                {
                    Id ownerId = mapProjectToOldOwners.get(projectId);
                                        
                    for(CaseShare objShare : lstShares)
                    {
                        if(objShare.UserOrGroupId == ownerId) //filter sharerecords for intended users only
                        {
                            for(Case objCase : mapProjectToCases.get(projectId))
                            {
                                if(objShare.CaseId == objCase.Id) //filter sharerecords for intended cases only
                                {
                                    shareRecordsToDelete.add(objShare); 
                                }
                            }    
                        }
                    }
                }
                
                if(shareRecordsToDelete.size() > 0)
                {
                    try
                    {
                        delete shareRecordsToDelete;    
                    }
                    catch(Exception ex)
                    {
                        system.debug('=== exception while deleting old sharing records : ' + ex.getMessage());
                    }                    
                }
            }
        }
    }
    
    //Method to grant access to the project team to project and cases
    public static void shareProjectAccessToTheTeam(Set<Project_Team__c> teamMembers, boolean shareProjectAccess, boolean shareCaseAccess)
    {
        if(teamMembers != null && (shareProjectAccess == true || shareCaseAccess == true))
        {
            Set<String> userEmails = new Set<String>();
            for(Project_Team__c eachTeamMember : teamMembers)
            {
                userEmails.add(eachTeamMember.Email_Address__c);
            }
            
            Map<String, User> mapEmailToUser = new Map<String, User>(); 
            Map<String, Id> mapEmailToUserId = new Map<String, Id>();
            
            for(User objUser : getUserDetailsBasedOnEmail(userEmails))
            {
                mapEmailToUser.put(objUser.Email, objUser);
                mapEmailToUserId.put(objUser.Email, objUser.Id);
            }
            
            if(shareProjectAccess)                        
            {
                List<Project__Share> lstProjectShares = new List<Project__Share>();
                for(Project_Team__c eachTeamMember : teamMembers)
                {  
                    if(eachTeamMember.Role__c.equalsIgnoreCase(PROJECT_TEAM_ROLE_PARTICIPANT) && mapEmailToUserId.containsKey(eachTeamMember.Email_Address__c))
                   
                    {
                        lstProjectShares.add(new Project__Share(ParentId = eachTeamMember.Project__c , UserOrGroupId = mapEmailToUserId.get(eachTeamMember.Email_Address__c), 
                                                                AccessLevel = 'Edit', RowCause = Schema.Project__Share.RowCause.ShareToTeam__c));                        
                    }                    
                }
                createProjectShareRecords(lstProjectShares);                
            }
            
            if(shareCaseAccess)
            {
                Set<Id> projectIds = new Set<Id>();                
                for(Project_Team__c eachTeamMember : teamMembers)
                {
                    projectIds.add(eachTeamMember.Project__c);
                }
                
                
                Map<Id, Set<Case>> mapProjectToCases = new Map<Id, Set<Case>>();                
                for(Case objCase : [Select Id, Projects__c, ContactId From Case Where Projects__c in : projectIds])
                {
                    if(mapProjectToCases.containsKey(objCase.Projects__c))
                    {
                       mapProjectToCases.get(objCase.Projects__c).add(objCase);
                    }
                    else
                    {
                        mapProjectToCases.put(objCase.Projects__c, new Set<Case>{objCase});
                    }
                }
                
                List<CaseShare> lstCaseShares = new List<CaseShare>();
                for(Project_Team__c eachTeamMember : teamMembers)
                {
                    if(mapProjectToCases.containsKey(eachTeamMember.Project__c))
                    { 
                        for(Case objCase : mapProjectToCases.get(eachTeamMember.Project__c))
                        {
                            //dont add sharing if team member already have access to this case 
                            //if team member user profile is sys admin/internal agent/internal FAE or team member is case contact
                            User memberUser = mapEmailToUser.get(eachTeamMember.Email_Address__c);
                            
                            if(memberUser != null && !(PROFILES_WITH_FULL_ACCESS_TO_CASES.contains(memberUser.Profile.Name) 
                                                      || objCase.ContactId == memberUser.ContactId))
                            {
                                lstCaseShares.add(new CaseShare(CaseId = objCase.Id , UserOrGroupId = memberUser.Id , 
                                                           CaseAccessLevel = 'Edit', RowCause = SHARING_REASON));      
                            }
                        }
                    }
                }               
                if(lstCaseShares.size() > 0)
                { 
                    createCaseShareRecords(lstCaseShares);  
                }
            }
        }
    }
    
    //Method to grant access to the cases when case is created/updated
    public static void shareCaseAccesstoTheTeam(List<Case> lstCases, Map<Id, Case> oldCasesMap)
    {
        if(lstCases != null)
        {
            Map<Case, Id> mapCaseToProject = new Map<Case, Id>();
            Map<Case, Id> mapCaseToOldProject = new Map<Case, Id>();    
            
            for(Case objCase : lstCases ) // When case is created or updated for projects
            {
                Case oldCase;
                if(oldCasesMap != null)
                {
                    oldCase = oldCasesMap.get(objCase.Id);    
                }              
                
                if(oldCase == null && objCase.Projects__c != null) // new case is created
                {
                    mapCaseToProject.put(objCase, objCase.Projects__c);
                }
                
                if(oldCase != null && objCase.Projects__c != null && oldCase.OwnerId != objCase.OwnerId) //owner is changed
                {
                    mapCaseToProject.put(objCase, objCase.Projects__c);
                }
                
                if(oldCase != null && oldCase.Projects__c != objCase.Projects__c ) //project is changed
                {
                    mapCaseToProject.put(objCase, objCase.Projects__c);
                    mapCaseToOldProject.put(objCase, oldCase.Projects__c);
                }                
            }
            
            if(mapCaseToProject.size() > 0)
            {
                Set<Id> projectIds = new Set<Id>();
                projectIds.addAll(mapCaseToProject.values());
                projectIds.addAll(mapCaseToOldProject.values());
                
                //get all the team members and project owner from these project who should get access to the case or access should be removed                
                List<Project_Team__c> lstMembers = [Select Id, Project__c, Email_Address__c, Role__c From Project_Team__c 
                                                        Where Status__c =: PROJECT_TEAM_STATUS_ACCEPTED and Project__c in :projectIds];
                
                Map<Id, Set<String>> mapProjectToMemberEmails = new Map<Id, Set<String>>();
                Set<String> userEmails = new Set<String>();
                
                for(Project_Team__c objMember : lstMembers)
                {
                    userEmails.add(objMember.Email_Address__c);
                    if(mapProjectToMemberEmails.containsKey(objMember.Project__c))
                    {
                        mapProjectToMemberEmails.get(objMember.Project__c).add(objMember.Email_Address__c);
                    }
                    else
                    {
                        mapProjectToMemberEmails.put(objMember.Project__c, new Set<String>{objMember.Email_Address__c});
                    }
                }            
                
                Map<String, User> mapEmailToUser = new Map<String, User>(); 
                Map<String, Id> mapEmailToUserId = new Map<String, Id>();
                
                for(User objUser : getUserDetailsBasedOnEmail(userEmails))
                {
                    mapEmailToUser.put(objUser.Email, objUser);
                    mapEmailToUserId.put(objUser.Email, objUser.Id);
                }
                
                List<CaseShare> lstCaseShares = new List<CaseShare>();
                
                //create CaseShare records to create new sharings            
                for(Case objCase : mapCaseToProject.keySet())
                {
                    Id projectId = mapCaseToProject.get(objCase);
                    
                    if(mapProjectToMemberEmails.containsKey(projectId))
                    {
                        for(String strEmail : mapProjectToMemberEmails.get(projectId))
                        {
                            User memberUser = mapEmailToUser.get(strEmail);
                            //dont add sharing if team member already have access to this case 
                            //if team member user profile is sys admin/internal agent/internal FAE or team member is case contact 
                            if(memberUser != null && !(PROFILES_WITH_FULL_ACCESS_TO_CASES.contains(memberUser.Profile.Name) 
                                                      || objCase.ContactId == memberUser.ContactId))
                            {
                                lstCaseShares.add(new CaseShare(CaseId = objCase.Id , UserOrGroupId = memberUser.Id , 
                                                           CaseAccessLevel = 'Edit', RowCause = SHARING_REASON));     
                            }
                        }
                    }
                }
                
                if(lstCaseShares.size() > 0)
                {   
                    createCaseShareRecords(lstCaseShares);  
                }
                //delete the sharing records for old project
                if(mapCaseToOldProject.size() > 0)
                {
                    //delete old share records
                    List<CaseShare> lstShares = [Select Id, CaseId, UserOrGroupId From CaseShare 
                                                    Where CaseId in : mapCaseToOldProject.keySet() and UserOrGroupId in : mapEmailToUserId.values() 
                                                        and RowCause =: SHARING_REASON ];
                    
                    List<CaseShare> shareRecordsToDelete = new List<CaseShare>();
                    for(Case objCase : mapCaseToOldProject.keySet()) 
                    {
                        for(CaseShare objShare : lstShares)
                        {
                            if(objShare.CaseId == objCase.Id) //filter sharerecords for intended cases only
                            {
                                Id projectId = mapCaseToOldProject.get(objCase);
                                Id newProjId = mapCaseToProject.get(objCase);
                                if(mapProjectToMemberEmails.containsKey(projectId))
                                {
                                    for(String strEmail : mapProjectToMemberEmails.get(projectId))
                                    {   // If project invitee exist in new project as well then don't delete from caseShare object. For SFDC-3769
                                        if((mapProjectToMemberEmails.containsKey(newProjId)) && !mapProjectToMemberEmails.get(newProjId).contains(strEmail)) {      
                                        
                                            Id memberId = mapEmailToUserId.get(strEmail);
                                            
                                            if(memberId != null && objShare.UserOrGroupId == memberId )//filter sharerecords for intended users only
                                            {
                                                shareRecordsToDelete.add(objShare);            
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                    
                    if(shareRecordsToDelete.size() > 0)
                    {
                        delete shareRecordsToDelete;
                    }
                }
            }                   
        }
    }    
}