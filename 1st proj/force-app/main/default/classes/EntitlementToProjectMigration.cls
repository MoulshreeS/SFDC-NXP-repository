/*********************************************************************************************
@Created By :      Saranya Sista
@Created Date :    9th Oct 2019
Description :      
****************************************************************************************************/

global class EntitlementToProjectMigration implements 
    Database.Batchable<sObject>, Database.Stateful {
    
    // instance member to retain state across transactions
    global Integer recordsProcessed = 0;
    global Set<Id> projectsCreated = new Set<Id>(); 
    global final String whereStrg;
    global List<String> errorList = new List<String>();    
    global EntitlementToProjectMigration(String q){
             whereStrg=q;
   }
        
    global Database.QueryLocator start(Database.BatchableContext bc) {
           String query = 'SELECT Id,Additional_Description__c,CasesPerEntitlement,CAS_Project__c,EndDate,StartDate,Status,'+
           'CreatedDate,CurrencyIsoCode,End_Application_Name__c,Entitlement_Sub_Type__c,End_Application_Type__c,'+
           'Entitlement_Pattern__c,LastModifiedById,LastModifiedDate,Name,CreatedById,Project_Annual_Volume__c,'+
           'Project_End_Customer_Name__c,Project_NXP_Design_Registration__c,Priority__c,Project_Stage__c,'+
           'Route_to_Assigned_To__c,Route_To_Case_Owner__c,Total_Number_of_Hours__c,Type,Used_number_of_Hours__c FROM Entitlement WHERE '+''+ whereStrg;
            System.assertNotEquals(null, query, 'The query should return records');
            System.debug('###query');
            return Database.getQueryLocator(query);
       
    }
    global void execute(Database.BatchableContext bc, List<Entitlement> scope){
        // process each batch of records
        List<Project__c> prjList = new List<Project__c>();
        for (Entitlement entlmnt : scope) {
                Project__c eachProject = new Project__c();
                eachProject.Additional_Description__c = entlmnt.Additional_Description__c;
                eachProject.Cases_Per_Project__c = entlmnt.CasesPerEntitlement;
                eachProject.CAS_Customer_Project__c = entlmnt.CAS_Project__c;
                eachProject.Contract_End_Date__c = entlmnt.EndDate;
                eachProject.Contract_Start_Date__c = entlmnt.StartDate;
                /*if(entlmnt.Status == 'Inactive'){
                    eachProject.Contract_Status__c = 'Expired';
                }
                else{
                    eachProject.Contract_Status__c = entlmnt.Status;
                }*/
                eachProject.CreatedById = entlmnt.CreatedById;
                eachProject.CreatedDate = entlmnt.CreatedDate;
                eachProject.CurrencyIsoCode = entlmnt.CurrencyIsoCode;
                eachProject.End_Application_Name__c = entlmnt.End_Application_Name__c;
                eachProject.End_Application_Type__c = entlmnt.End_Application_Type__c;
                eachProject.EntitlementId__c = entlmnt.Id;
                eachProject.Entitlement_Pattern__c = entlmnt.Entitlement_Pattern__c;
                eachProject.LastModifiedById = entlmnt.LastModifiedById;
                eachProject.LastModifiedDate = entlmnt.LastModifiedDate;
                if(entlmnt.Name.length() > 80){
                    eachProject.Name = entlmnt.Name.substring(0,80);
                }else{
                    
                    eachProject.Name = entlmnt.Name;
                }
                eachProject.OwnerId = entlmnt.CreatedById;
                eachProject.Project_Annual_Volume__c = entlmnt.Project_Annual_Volume__c;
                eachProject.Project_End_Customer_Name__c = entlmnt.Project_End_Customer_Name__c;
                eachProject.Project_NXP_Design_Registration__c = entlmnt.Project_NXP_Design_Registration__c;
           //   eachProject.Project_Service_Level__c = entlmnt.Priority__c;
                eachProject.Project_Stage__c = entlmnt.Project_Stage__c;
                eachProject.Route_to_Assigned_To__c = entlmnt.Route_to_Assigned_To__c;
                eachProject.Route_to_Case_Owner__c = entlmnt.Route_To_Case_Owner__c;
                eachProject.Total_Number_of_Hours__c = entlmnt.Total_Number_of_Hours__c;
                eachProject.Used_Number_of_Hours__c = entlmnt.Used_number_of_Hours__c; 
                if(entlmnt.Type == 'Paid'){
                eachProject.Type__c = 'Paid';
                }
                else{
                eachProject.Type__c = 'Free';
                }
                 
                prjList.add(eachProject);  
            }
        if(!prjList.isEmpty()){
            System.debug('###in Loop1'+prjList.size());
            Database.SaveResult[] srList = Database.insert(prjList, false);
            for (Database.SaveResult saveRslt : srList) {
                if (saveRslt.isSuccess()) {
                    System.debug('####Successfully inserted project. Poject ID: ' + saveRslt.getId());
                    projectsCreated.add(saveRslt.getId());
                }
                else{
                    for(Database.Error err : saveRslt.getErrors()) {
                    System.debug('####The following error has occurred.');   
                    System.debug(err.getStatusCode() + ': ' + err.getMessage());
                    System.debug('####Entitlement fields that affected this error: ' + err.getFields());
                    errorList.add(err.getStatusCode() + ': ' + err.getMessage()+':'+err.getFields()+'\n');
                    System.debug('###errorList'+errorList);    
                    }
                }
            }
        }
    }    
    global void finish(Database.BatchableContext bc){
        System.debug('####'+recordsProcessed + ' records processed');
        Set<Id> EntitlmentMigrated = new Set<Id>();
        List<Entitlement> entmntToBeUpdated = new List<Entitlement>();
        List<Project__c> prjsList = new List<Project__c>();
        System.debug(projectsCreated.size()+'no of projects created');
        if(!projectsCreated.isEmpty())
        prjsList = [SELECT Id,EntitlementId__c FROM Project__c WHERE ID IN :projectsCreated];
        System.debug('####'+prjsList + ' records processed');
        if(!prjsList.isEmpty()){
        for(Project__c eachproj : prjsList){
            EntitlmentMigrated.add(eachproj.EntitlementId__c);
        }
        }
        if(!EntitlmentMigrated.isEmpty()){
            List<Entitlement> entmntFetch = [SELECT Id,isMigrated__c FROM Entitlement WHERE isMigrated__c = false AND ID IN:EntitlmentMigrated];
            System.debug(entmntFetch+'###entmntFetch');
            if(!entmntFetch.isEmpty()){
            for(Entitlement eachEnt : entmntFetch){
                eachEnt.isMigrated__c = TRUE;
                entmntToBeUpdated.add(eachEnt);
            }
            update entmntToBeUpdated;
            }
        }
               
        AsyncApexJob job = [SELECT Id, Status, NumberOfErrors, 
            JobItemsProcessed,
            TotalJobItems, CreatedBy.Email
            FROM AsyncApexJob
            WHERE Id = :bc.getJobId()];
        //  sending email
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String[] toAddresses = new String[] {'moulshree.shrivastava@nxp.com'};
        mail.setToAddresses(toAddresses);
        mail.setSubject('Match Merge Batch ' + job.Status);
        mail.setPlainTextBody('records processed :' + job.TotalJobItems +   'with '+ job.NumberOfErrors + ' failures.'+errorList);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });

}
}