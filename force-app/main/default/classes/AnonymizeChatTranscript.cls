/**
* @Created By : Sudhis Nair
* @Created Date : 24-June-2019
* Bathc Class to anonymize chat transcripts
*/
global class AnonymizeChatTranscript implements Database.Batchable<SObject>,Database.Stateful,Schedulable {
	public static String ANONYMIZATION_CONSTANT='ANONYMOUS';
	public static String ANONYMIZATION_CONSTANT_EMAIL='blank@anonymous.invalid';
	public static String NOTIFICATION_QUEUE='CTI_Admins';
	global integer totalNumberOfRecords=0;
    global integer recordsUpdated=0;
	global AnonymizeChatTranscript() {
		
	}
    global void execute(SchedulableContext sc){
        Database.executeBatch(this);
    }	
	/**
	 * @description gets invoked when the batch job starts
	 * @param context contains the job ID
	 * @returns the record set as a QueryLocator object that will be batched for execution
	 */ 
	global Database.QueryLocator start(Database.BatchableContext context) {
		return Database.getQueryLocator('SELECT Id, Name FROM LiveChatTranscript where Email__c<>\''+ANONYMIZATION_CONSTANT_EMAIL+'\' AND  Don_t_Anonymize__c=false AND ((Consent_To_Store_Data__c =false AND RequestTime<LAST_N_DAYS:30) OR (Consent_To_Store_Data__c =true AND RequestTime<LAST_N_DAYS:180))');
	}

	/**
	 * @description gets invoked when the batch job executes and operates on one batch of records. Contains or calls the main execution logic for the batch job.
	 * @param context contains the job ID
	 * @param scope contains the batch of records to process.
	 */ 
   	global void execute(Database.BatchableContext context, List<LiveChatTranscript> scope) {
		for(LiveChatTranscript lct : scope){
			lct.First_Name__c	= ANONYMIZATION_CONSTANT;
			lct.Last_Name__c = ANONYMIZATION_CONSTANT;	
			lct.Body='';
            lct.SupervisorTranscriptBody='';
			lct.Email__c=ANONYMIZATION_CONSTANT_EMAIL;
			lct.Company__c=ANONYMIZATION_CONSTANT;
			lct.Country__c=ANONYMIZATION_CONSTANT;
			lct.ContactId = null;	
			lct.Location='';
			lct.IpAddress='';
			lct.UserAgent='';
			lct.Browser='';
			lct.BrowserLanguage='';
			lct.Platform='';
			lct.ReferrerUri='';
			lct.ScreenResolution='';
			lct.CaseId=null;
			totalNumberOfRecords++;
		}
		Database.SaveResult[] srList = Database.update(scope,false);
		// Iterate through each returned result
        for (Database.SaveResult sr : srList) {
            if (sr.isSuccess())
                recordsUpdated++;
        }  
	}
	
	/**
	 * @description gets invoked when the batch job finishes. Place any clean up code in this method.
	 * @param context contains the job ID
	 */ 
	global void finish(Database.BatchableContext bc){
                List<User> users= [SELECT Email FROM User WHERE Id IN (SELECT UserOrGroupId FROM GroupMember WHERE Group.DeveloperName ='CTI_Admins')];
                Set<String> emailIds = new Set<String>();
                for(User u:users){
                    emailIds.add(u.email);    
                }
                List<String> finalemailId = new List<String>();
                finalemailId.addAll(emailIds);
            	System.debug('The job completed successfully.There were '+totalNumberOfRecords+' chat transcripts found and '+recordsUpdated+' transcripts were anonymized  ');
                if(!finalemailId.isEmpty()){
                    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                    mail.setToAddresses(finalemailId);
                    mail.setSaveAsActivity(false);
                    mail.setSubject('Chat transcript anonymization job');
                    mail.setPlainTextBody('The job completed successfully.There were '+totalNumberOfRecords+' chat transcripts found and '+recordsUpdated+' transcripts were anonymized  ');
                    if([SELECT IsSandbox FROM Organization LIMIT 1].IsSandbox==false){
                    	Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
                    }    
                }                
	    }
}