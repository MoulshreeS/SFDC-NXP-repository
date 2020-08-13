/******************************************************************************
 * Created By: Manikanta
 * Created Date : Dec 21,2018
 * Description : Created this Batch to handle Owner Assignment for Leads.
*******************************************************************************/

global class LeadAssignmentBatch implements Database.Batchable<Lead>,Schedulable {
       global Iterable<Lead> start(Database.BatchableContext BC) {
        DateTime dt = System.now().addHours(-2);
        List<Lead> lds = new List<Lead>([select id,name,NXP_Global_Customer_Master_ID__c,Email,Status,OwnerId,Industry,Geo_Score__c,
                                         RecordTypeId,CBG__c,Account_Id__c,Description,street,city,country,state,company,PostalCode
                                         from lead where recordtype.name ='Uncategorized Leads' and status='Open' 
                                          and createddate <= :dt]);
           //System.debug('lds' + lds);
                                         
        return lds;
                                             
    } 
    
        global void execute(SchedulableContext sc){
            Database.executeBatch(this);
        }
    
    global void execute(Database.BatchableContext BC, list<Lead> scope){
         list<Lead> listUnCategorizedLeads= (list<Lead>)scope;
         //LeadAssignmentHandler.leadGIdBasedAssgnmt(listUnCategorizedLeads); 
        LeadAssignmentHandler.assignLeadOwners(listUnCategorizedLeads);

    }
    
        global void finish(Database.BatchableContext BC){
            database.executebatch(new LeadOwnerAssignmentROMBatch());
                                User u = [select Id,Name, username from User where Id = :UserInfo.getUserId()];
                                    
        AsyncApexJob a = [Select Id, Status,ExtendedStatus,NumberOfErrors,JobItemsProcessed,
        TotalJobItems, CreatedBy.Email
        from AsyncApexJob where Id =:BC.getJobId()];
            
            List<String> idList = new List<String>();
    List<String> mailToAddresses = new List<String>(); 
     
    List<Group> gp = [SELECT (SELECT UserOrGroupId FROM GroupMembers) FROM Group WHERE Name = 'Lead Assignment Error Notifications'];
            if(gp != null){
                           for(Group grp : gp){
               for (GroupMember gm : grp.GroupMembers) {
        idList.add(gm.UserOrGroupId);
    }   
            }   
            }  
 
  
    List<User> userList = [SELECT Email FROM User WHERE Id IN :idList];
            if(userList != null ){
                   for(User groupuser : userList) {
        mailToAddresses.add(groupuser.email);
    } 
            }       
 
            
            if(a.ExtendedStatus != null){
            List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setToAddresses(mailToAddresses);
            mail.setSubject('Lead Assignment Batch Job ' + a.Status);
            mail.setHtmlBody('Hello All <br/><br/> Please find the status of Lead Assignment Batch Job - records processed - ' + a.TotalJobItems +
           ' with '+ a.NumberOfErrors + ' failures <br/> Error Message : ' + a.ExtendedStatus + '<br/> <br/> Regards<br/>' + u.name);
            emails.add(mail);
                          if (emails != NULL && emails.size() > 0)
        {
               Messaging.sendEmail(emails);
           
        }
                
                
                
                //Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
                
            }

       //database.executebatch(new LeadOwnerAssignmentBatch());
    }
    

}