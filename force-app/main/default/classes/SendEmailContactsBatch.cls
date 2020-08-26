global class SendEmailContactsBatch implements Database.Batchable<Lead>,Database.Stateful,Schedulable
{
   global static  Datetime dt;
    global List<Lead> leadss;
 global Iterable<Lead> start(Database.BatchableContext bc) {
 
      List<AsyncApexJob> jobcompdate = [SELECT CompletedDate FROM AsyncApexJob WHERE JobType = 'BatchApex' 
                             AND Status = 'Completed' and ApexClass.NAME='SendEmailContactsBatch' order by CompletedDate desc limit 1];
 	
     if(jobcompdate.size() > 0 ){
        dt = jobcompdate[0].CompletedDate; 
     }
     else{
        // dt = System.Now().AddDays(-1);
         dt = System.Now().Addhours(-24);
     }
 
        List<Lead> lds = new List<Lead>([select id,Name,status,Distributor_Tracking_Number__c,Distributor_Contact__r.email,Disti_Feedback_Email_Address__c,Distributor_contact__r.Community_web_country__c,owner.Name,
                                         Distributor_Contact__r.AccountId,Region__c,Distributor_Contact__r.Account.Name,Distributor_contact__r.firstname,
                                         Distributor_contact__r.lastname,Distributor_contact__r.User_Region__c,Distributor_Contact__r.name
                                         from lead where Disti_Feedback_Email_Address__c != null and Disti_Feedback_Email_Address__c != 'melissa.arosemena@nxp.com' and Systemmodstamp >: dt]);
                                         
    	return lds;
                                             
    }
    
        global void execute(SchedulableContext sc){
            Database.executeBatch(this);
        }
    
    
    global void execute(Database.BatchableContext BC, List<Lead> scope){
        //list<Lead> leads = (list<Lead>)scope; 

        if(scope != null){
           leadss = scope; 
        }
       
    }
    
    
    global void finish(Database.BatchableContext BC) {
        if(leadss != null){
           sendEmailContacts.sendemail(leadss);   
        }
    	 
    }

}