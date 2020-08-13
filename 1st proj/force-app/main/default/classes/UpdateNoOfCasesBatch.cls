/*********************************************************************************************
@Created By :      Saranya Sista
@Created Date :    28th Oct 2019
Description :      
****************************************************************************************************/

global class UpdateNoOfCasesBatch implements 
Database.Batchable<sObject>, Database.Stateful  {
    
    global final String whereStrg;
    global List<String> errorList = new List<String>();    
    global UpdateNoOfCasesBatch(String q){
        whereStrg=q;
    }
    global Database.QueryLocator start(Database.BatchableContext bc) {
        String query = 'SELECT Id, Last_Case_Created_Date_Time__c, Cases_Per_Project__c,(Select Id,CreatedDate FROM Cases__r) FROM Project__c'+' '+ whereStrg;
        
        System.assertNotEquals(null, query, 'The query should return records');
        System.debug('###query'+query);
        System.debug('##returnquery'+Database.getQueryLocator(query));
        return Database.getQueryLocator(query);
        
    }
    global void execute(Database.BatchableContext bc, List<Project__c> scope){
        List<Project__c> prjToUpdate = new List<Project__c>();
        for(Project__c eachPrj : scope){
            Integer count = 0;
            Datetime lastcasecreated = null;
            for(case eachcase : eachPrj.Cases__r){
                 count = count + 1;
                if(lastcasecreated == null || lastcasecreated < eachcase.CreatedDate){
                    lastcasecreated = eachcase.CreatedDate;
                }
            }
            eachPrj.Cases_Per_Project__c = count;
            eachPrj.Last_Case_Created_Date_Time__c = lastcasecreated;
            prjToUpdate.add(eachPrj);
        }
        if(!prjToUpdate.isEmpty()){
            System.debug('###in Loop1'+prjToUpdate.size());
            Database.SaveResult[] srList = Database.update(prjToUpdate, false);
            for (Database.SaveResult saveRslt : srList) {
                if (saveRslt.isSuccess()) {
                    System.debug('####Successfully updated project. project ID: ' + saveRslt.getId());
                }
                else{
                    for(Database.Error err : saveRslt.getErrors()) {
                    System.debug('####The following error has occurred.');   
                    System.debug(err.getStatusCode() + ': ' + err.getMessage());
                    System.debug('#### fields that affected this error: ' + err.getFields());
                    errorList.add(err.getStatusCode() + ': ' + err.getMessage()+':'+err.getFields()+'\n');
                    System.debug('###errorList'+errorList);    
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
        String[] toAddresses = new String[] {'moulshree.shrivastava@nxp.com'};
        mail.setToAddresses(toAddresses);
        mail.setSubject('Match Merge Batch ' + job.Status);
        mail.setPlainTextBody('records processed :' + job.TotalJobItems +   'with '+ job.NumberOfErrors + ' failures.'+errorList);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }
}