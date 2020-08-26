/*********************************************************************************************
@Created By :      Saranya Sista
@Created Date :    14th Oct 2019
Description :      
****************************************************************************************************/


global class MappingProjectAndCaseBatch implements 
    Database.Batchable<sObject>, Database.Stateful{
    
    global final String whereStrg;
    global List<String> errorList = new List<String>();    

    global MappingProjectAndCaseBatch(String q){
             whereStrg = q;
    }
    global Database.QueryLocator start(Database.BatchableContext bc) {
           String query = 'SELECT Id,EntitlementId__c FROM Project__c WHERE '+''+ whereStrg;
            System.assertNotEquals(null, query, 'The query should return records');
            System.debug('###query');
            return Database.getQueryLocator(query);
       
    }
     global void execute(Database.BatchableContext bc, List<Project__c> scope){
         Map<Id,Id> prjEntlMap = new Map<Id,Id>();
         List<Case> updateCaseList = new List<Case>();
         Set<Id> EntitlementId = new Set<Id>();
         for(Project__c eachprj : scope){
             prjEntlMap.put(eachprj.EntitlementId__c,eachprj.Id);
             EntitlementId.add(eachprj.EntitlementId__c);
         }
         List<Case> caseLst = [SELECT Id,Projects__c,EntitlementId FROM Case where EntitlementId IN :EntitlementId and Projects__c = ''];
         System.debug('####caseLst'+caseLst);
         if(!caseLst.isEmpty()){
             for(Case eachCase : caseLst){
                 if(!prjEntlMap.isEmpty()){
                     eachCase.Projects__c = prjEntlMap.get(eachCase.EntitlementId);
                    System.debug('##prj'+eachCase.Projects__c+'***'+prjEntlMap.get(eachCase.EntitlementId));
                    updateCaseList.add(eachCase);
                 }
             }
             if(!updateCaseList.isEmpty()){
                 Database.SaveResult[] srList = Database.update(updateCaseList, false);
             for (Database.SaveResult saveRslt : srList) {
                if (saveRslt.isSuccess()) {
                    System.debug('####Successfully inserted ' + saveRslt.getId());
                }
                else{
                    for(Database.Error err : saveRslt.getErrors()) {
                    System.debug('####The following error has occurred.');   
                    System.debug(err.getStatusCode() + ': ' + err.getMessage());
                    System.debug('####fields that affected this error: ' + err.getFields());
                    errorList.add(err.getStatusCode() + ': ' + err.getMessage()+':'+err.getFields()+'\n');
                    System.debug('###errorList'+errorList);    
                    }
                }
            }
             }
         }
     }
    global void finish(Database.BatchableContext bc){
          AsyncApexJob job = [SELECT Id, Status, NumberOfErrors, 
            JobItemsProcessed,
            TotalJobItems, CreatedBy.Email
            FROM AsyncApexJob
            WHERE Id = :bc.getJobId()];
        //  sending email
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String[] toAddresses = new String[] {'niraj.kumar_1@nxp.com'};
        mail.setToAddresses(toAddresses);
        mail.setSubject('Match Merge Batch ' + job.Status);
        mail.setPlainTextBody('records processed :' + job.TotalJobItems +   'with '+ job.NumberOfErrors + ' failures.'+errorList);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });

    }
}