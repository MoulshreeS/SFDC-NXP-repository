global with sharing class distiBranchNameUpdate implements Database.Batchable<sObject>,Database.Stateful{
    
    global Datetime date1 = System.now().addMinutes(-1);
    global string log ='';
    global integer totalNumberOfRecords=0;
    global integer recordsunUpdated=0;
    @TestVisible private static Integer recordNumber;

    //Start
    global Database.QueryLocator start(Database.BatchableContext BC) 
    { 
        //string query = ''
        return Database.getQueryLocator([SELECT Contact_Role__c,Contact__c,Disti_Branch__r.name,Id FROM Disti_Branch_Contact_Role__c where lastModifieddate>:date1]);
    }
    //Execute
    global void execute(Database.BatchableContext BC, list<Disti_Branch_Contact_Role__c> ListDBCR) 
    {    
        Map<Id,String> mainDistiConMap = new Map<Id,String>();
        Map<Id,String> otherRolesMap = new Map<Id,String>();
        set<Id> contactIdSet = new set<Id>();
        String distiBranchName = '';
        for(Disti_Branch_Contact_Role__c distiC: ListDBCR){
            contactIdSet.add(distiC.contact__c);
        }
       
        List<Disti_Branch_Contact_Role__c> distiConRoleList = [SELECT Contact_Role__c,Contact__c,Disti_Branch__r.name,Id FROM Disti_Branch_Contact_Role__c where Contact__c in :contactIdSet];
        system.debug('distiConRoleList' +distiConRoleList);
        for(Disti_Branch_Contact_Role__c distiC: distiConRoleList)
        {
            system.debug('distiC.Contact_Role__c' +distiC.Contact_Role__c);
            if(distiC.Contact_Role__c == 'Main Distributor Contact'){
                  MainDistiConMap.put(distiC.contact__c,distiC.Disti_Branch__r.Name);
             }
             if(distiC.Contact_Role__c != 'Main Distributor Contact'){
                  if(!otherRolesMap.containsKey(distiC.contact__c)){
                      otherRolesMap.put(distiC.contact__c,distiC.Disti_Branch__r.Name);
                  }
                  else if(otherRolesMap.containsKey(distiC.contact__c)){
                      distiBranchName = otherRolesMap.get(distiC.contact__c) + ';' + distiC.Disti_Branch__r.Name ;
                      otherRolesMap.put(distiC.contact__c,distiBranchName);
                  }  
              }    
        //MainDistiConMap.get(distiC.contact__c);
        system.debug('otherRolesMap' +otherRolesMap);
        }
        system.debug('MainDistiConMap' +MainDistiConMap);
        system.debug('otherRolesMap' +otherRolesMap);
        List<lead> leadList = [SELECT name,Distributor_Contact__c, Disti_Branch_Name__c from Lead where Distributor_Contact__c in :contactIdSet];
        totalNumberOfRecords = leadList.size();
        for(Lead ld: leadList)
        {
             if(mainDistiConMap.containskey(ld.Distributor_Contact__c)){
                 ld.Disti_Branch_Name__c = mainDistiConMap.get(ld.Distributor_Contact__c);
                 system.debug('inside 1'); 
             }
             else if(otherRolesMap.containskey(ld.Distributor_Contact__c)){
                 ld.Disti_Branch_Name__c = otherRolesMap.get(ld.Distributor_Contact__c);
                 system.debug('inside 2'); 
             }
        } 
        if(Test.isRunningTest() && recordNumber == 0){ //do something 
            for(Lead ld: leadList){
                ld.id = null;
            }
        }
        Database.SaveResult[] srList = Database.update(leadList,false);
        for (Integer i = 0; i < srList.size(); i++){
            if (!srList[i].isSuccess()){
                this.log += '<br/> Error in Update: ' + leadList[i].name + '. Error msg=' + srList[i].getErrors()[0].getMessage();
                recordsUnUpdated++;
            }    
        }   
              
    }
    
    //Finish
    global void finish(Database.BatchableContext BC){
    
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
        string[] toMail = new string[] {'moulshree.shrivastava@nxp.com'};
        if((log != '' && log != null)){
            system.debug('inside finish');
            //mail to developers
            List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setToAddresses(toMail);
            mail.setSubject('Disti Branch Name Update Status');
            mail.setHtmlBody('Hello All <br/><br/> Please find the status of Disti Branch Name Update Batch Job - records processed - ' + totalNumberOfRecords +
           ' with '+ recordsunUpdated + ' failures <br/> Error Message : ' + log );
           emails.add(mail);
           if (emails != NULL && emails.size() > 0)
           {
               Messaging.sendEmail(emails);
           
           }
           //mail to business owners
            List<Messaging.SingleEmailMessage> emailsOw = new List<Messaging.SingleEmailMessage>();
            Messaging.SingleEmailMessage mailOw = new Messaging.SingleEmailMessage();
            mailOw.setToAddresses(toMail);
            mailOw.setSubject('Disti Branch Name Update Status');
            mailOw.setHtmlBody('Hello All <br/><br/> Please find the status of Disti Branch Name Update Batch Job - records processed - ' + totalNumberOfRecords +
           ' with '+ recordsunUpdated + ' failures');
           emailsOw.add(mailOw);
           if (emailsOw != NULL && emailsOw.size() > 0)
           {
               Messaging.sendEmail(emailsOw);
           
           }
           
        }
    }
}