global  class  Forwardtodisti {
    
    webservice static void updatelead(Id Leadid){
        
        Lead l = [select id,CC_Address__c,Disti_Feedback_Email_Address__c,
                  Distributor_Contact__r.email,Original_Assignee__c,Distributor_Contact__c,Previous_Assignee__c
                  from lead where id =: Leadid];
        if(l.Disti_Feedback_Email_Address__c != l.Distributor_Contact__r.email){
            
            List<Contact> c = [select id from contact where email =: l.Disti_Feedback_Email_Address__c];
            
            
            l.Previous_Assignee__c = l.Distributor_Contact__c;
                            if(l.Original_Assignee__c == null)
                {
                    l.Original_Assignee__c = l.Distributor_Contact__c;
                }
            if(c != null){
                  l.Distributor_Contact__c = c[0].Id;
            }
              
        }
        
      
        Update l;
       
    }

}