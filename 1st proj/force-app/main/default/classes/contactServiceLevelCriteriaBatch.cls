/*
created by: Shridevi Badiger
Created Date:24-May-2017
Description:As part of SIR SFDC-207-To calculate the case priority.
*/
/*
created by: Harish Gowda N
Created Date:3-October-2018
Description:As part of SIR SFDC-1757-Job for CSL seems to be not executed .
*/

global with sharing class contactServiceLevelCriteriaBatch implements Database.Batchable<sObject>,Database.Stateful{
    
    global Datetime date1 = System.today().adddays(-7);
    global Datetime  date2= (System.today().adddays(1));
    //SFDC-2308
    global integer totalNumberOfRecords=0;
    global integer recordsUpdated=0;
    global integer recordsunUpdated=0;
    //global RecordType tsRecordType=[Select Id,name from recordtype where name='TS Community' LIMIT 1];
    //global RecordType techRecordType=[Select Id,name from recordtype where name='Tech Support' LIMIT 1];
    //global 
    //Start
    global Database.QueryLocator start(Database.BatchableContext BC) 
    { 
        return Database.getQueryLocator([SELECT id,Contact_service_Level__c,Criteria_Field_Value__c from Contact_Service_Level_Criteria__c where  (CreatedDate>:date1 and createdDate<:date2 ) or (lastModifieddate>:date1 and lastModifieddate<:date2)]);
    }
    //Execute
    global void execute(Database.BatchableContext BC, list<sObject> ListCSLC) 
    {    
        
        list<contact> listContact=new list<contact>();
        list<string> listEmail=new list<string>();
        list<Contact_Service_Level_Criteria__c> listCSLC1=new list<Contact_Service_Level_Criteria__c>();
        //SFDC-2308
        totalNumberOfRecords+=ListCSLC.size();
        for(Sobject CSLCRec:listCSLC)
        {
            listCSLC1.add((Contact_Service_Level_Criteria__c)CSLCRec);
            // listEmail.add((string)CSLCRec.Criteria_Field_Value__c);
        }
        for(Contact_Service_Level_Criteria__c CSLCRec:listCSLC1)
        {
            
            listEmail.add('%'+((string)CSLCRec.Criteria_Field_Value__c)+'%');
        } 
        for(Contact ConRec:listContact)
        {
            
            
        } 
        System.debug(listEmail);
        if(listEmail!=null && listEmail.size()!=null)
        {
            listContact=[select id,contact_service_level__c,email from contact where email like:listEmail];
            System.debug(listContact);
            if(listContact.size()!=0 && listContact!=null)
                
                For(Contact recCon : listContact){
                    if(recCon .Contact_Service_Level__c != ''){
                        recCon.Contact_Service_Level__c = '' ;
                    }
                }
            ContactClass.CSLIdentification(listContact) ;
            // update listContact;
            //SFDC-2308
            system.debug('Contacts to update for CSL job' + listContact);
            Database.SaveResult[] srList = Database.update(listContact,false);
            // Iterate through each returned result
            for (Database.SaveResult sr : srList) {
                if (sr.isSuccess()){
                    recordsUpdated++;
                }
                
                else 
                {
                    for(Database.Error err : sr.getErrors()) 
                    {
                        System.debug(err.getStatusCode() + 'CSL Job: ' + err.getMessage());
                        System.debug('CSL Job Fields that affected this error: ' + err.getFields());
                        recordsunUpdated++;
                    }
                    
                }
            }     
        }
        
        //system.debug(listContact);
        system.debug('Number of contacts updated sucessfully for CSL job' + recordsUpdated);
    }
    
    //Finish
    global void finish(Database.BatchableContext BC)
    {
       // AsyncApexJob a = [Select Id, Status, NumberOfErrors, JobItemsProcessed,TotalJobItems, CreatedBy.Email, ExtendedStatus from AsyncApexJob LIMIT 1];
        List<User> users= [SELECT Email FROM User WHERE Id IN (SELECT UserOrGroupId FROM GroupMember WHERE Group.DeveloperName ='ContactServiceLevelCriteriaBatchGroup')];
        Set<String> emailIds = new Set<String>();
        for(User u:users){
            emailIds.add(u.email);    
        }
        List<String> finalemailId = new List<String>();
        finalemailId.addAll(emailIds);
        System.debug('The job completed successfully.There were '+totalNumberOfRecords+' records found and '+recordsUpdated+' records were updated with wrapup codes  ');
        if(!finalemailId.isEmpty() /**a.Status=='Completed'**/){
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setToAddresses(finalemailId);
            mail.setSaveAsActivity(false);
            mail.setSubject('CSL Batch Job Status');
            if(recordsUpdated>0)
            {
            mail.setPlainTextBody(' The CSL job completed successfully. There were '+totalNumberOfRecords+' records found and '+recordsUpdated+' records were updated with Contact Service Level ');
            }
            else if(recordsUpdated==0){
                mail.setPlainTextBody(' The CSL job completed successfully. None of the Contact records were updated. ');
            }
            else if(recordsunUpdated>0)
            {
             mail.setPlainTextBody('The CSL job was Not completed. There were '+recordsunUpdated+' errors found.');   
            }
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });    
        }
        /**else if(!finalemailId.isEmpty() && /**a.Status=='Failed' recordsunUpdated>0 )    
        /**{ 
            Messaging.SingleEmailMessage mail1 = new Messaging.SingleEmailMessage();
            mail1.setToAddresses(finalemailId);
            mail1.setSaveAsActivity(false);
            mail1.setSubject('CSL Batch Job Status');
            mail1.setPlainTextBody('The CSL job was Not completed. There were errors found.');
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail1 });
        }**/
        // mail.setPlainTextBody(' The CSL job completed successfully. There were '+totalNumberOfRecords+' records found and '+recordsUpdated+'records were updated with Contact Service Level ');
        //2308  if([SELECT IsSandbox FROM Organization LIMIT 1].IsSandbox==false){
        //}    
        
    }
}