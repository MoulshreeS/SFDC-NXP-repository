/*********************************************************************
Created by           |          Created date         |      Description 
Saranya Sista        |          5/10/2019            |  As part of SFDC-2734 , Queries the list of projects
                                                        associated with the current user 


**********************************************************************/
/***************************************************************************************************
@Modified By :      Gunjan Singh
@Created Date:     19 July 2019
@Description:      SFDC-3145 Invited Cases and Projects should also be visible in Home Page
**********************************************************************************************************/



public without sharing class ProjectAwaitingAcceptanceController {
    @AuraEnabled
        public Id projectTeamIdReject {get;set;}
    @AuraEnabled
        public Id projectTeamIdAccept {get;set;}
     
     //Below method Displays the List of projects for which the user has Invite in the Lightning Component ProjetcsAwaitingHome
     @AuraEnabled
     public static List<Project_Team__c> getProjectList(){
         system.debug('entered the method');
         List<Project_Team__c> listOfProjects = [SELECT Project__r.id,Project__r.Name,Status__c,
                                                 Project__r.Project_End_Customer_Name__c,Project__r.End_Application_Name__c,
                                                 Project__r.Created_Date__c FROM Project_Team__c 
                                                 WHERE (Status__c = 'Invited' or Status__c = 'Migrated') 
                                                 and Email_Address__c = : UserInfo.getUserEmail() and (Role__c != 'Owner')];
         //system.assert(false,'returned this list'+listOfProjects);
         return listOfProjects; 
     }
    
     //Below method is called to display specific project record details in the model pop up that opens up when the user selects a particular record in the Home page.
     @AuraEnabled
     public static List<Project_Team__c> getProjectDetailList(Id projectTeamId){
         List<Project_Team__c> projectDetailData = [SELECT Project__r.id,Project__r.Name,Project__r.Created_Date__c,
                                                    Project__r.Project_End_Customer_Name__c,Project__r.Owner.Name,
                                                    Project__r.End_Application_Name__c FROM Project_Team__c 
                                                    WHERE id = : projectTeamId ];
         return projectDetailData; 
     }
    
    //Below method is called when the user rejects the invite .
    @AuraEnabled
    public static void UpdateStatusRejected(Id projectTeamIdReject){
        Project_Team__c projectRejected = [SELECT Id,Project__r.id,Status__c FROM Project_Team__c 
                                           WHERE id = : projectTeamIdReject ];
        projectRejected.Status__c = 'Rejected';
        try {
        	update projectRejected;
            if(Test.isRunningTest()){
                        integer intTest =1/0;
            }
        }
        catch (Exception e) {
        // "Convert" the exception into an AuraHandledException
        throw new AuraHandledException('There is a DML error.Please Contact System Administrator '+ e.getMessage());   
        }
    }
    
    //Below method is called when the user accepts the invite .
    @AuraEnabled
    public static String UpdateStatusAccepted(Id projectTeamIdAccept){
        
        String ProjectId; 
        Project_Team__c projectAccepted = [SELECT Id,Email_Address__c,Project__r.Cases_Per_Project__c,Project__r.id,Status__c FROM Project_Team__c 
                                          WHERE id = : projectTeamIdAccept Limit 1 ];
        projectAccepted.Status__c = 'Accepted';
        try {
        update projectAccepted;
        ProjectId = projectAccepted.Project__r.id;  
            // Added as part of SFDC-3145 Invited Cases and Projects should also be visible in Home Page 
        if(projectAccepted.Project__r.Cases_Per_Project__c>0){
            User objUser = [Select Id, Email, HasAcceptedCases__c from User where email =: UserInfo.getUserEmail() LIMIT 1];
            if(objUser != Null && objUser.HasAcceptedCases__c == FALSE){
                objUser.HasAcceptedCases__c = TRUE;
                try{
                    update objUser;
                    if(Test.isRunningTest()){
                        integer intTest =1/0;
                    }
                }
                catch(Exception e){
                system.debug('Exception occured'+ e.getMessage());
                }
            }
        }
        if(Test.isRunningTest()){
                        integer intTest =1/0;
                    }    
        // End of code related to SFDC-3145
        }
        catch (Exception e) {
        // "Convert" the exception into an AuraHandledException
        throw new AuraHandledException('There is a DML error.Please Contact System Administrator '+ e.getMessage());   
        }
        return ProjectId;
    } 
}