global class ProjectInviteeUpdate implements Database.Batchable<sObject>
{
    
    global Database.QueryLocator start(Database.BatchableContext bc) {
        String query = 'SELECT Email_Address__c,Id,Role__c,Status__c FROM Project_Team__c';
        
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext bc, List<Project_Team__c> scope){
        if(scope != null){
            List<String> ptemails = new List<String>();    
            for(Project_Team__c pt : scope){
                ptemails.add(pt.Email_Address__c);
            }
            Map<String,Contact> mapcon = new map<String,Contact>();
            
            List<Contact> c = [select id,FirstName,LastName,Email,company__c From Contact where email in:ptemails];
            for(contact cc : c){
                mapcon.put(cc.email,cc);
                
            }
            List<Project_Team__c> updpt =new List<Project_Team__c>();
            for(Project_Team__c pt : scope){
                if(mapcon.containskey(pt.Email_Address__c)){
                    Contact con = mapcon.get(pt.Email_Address__c);
                    pt.First_Name__c =con.FirstName;
                    pt.Last_Name__c = con.lastname;
                    pt.Company__c = con.company__c;
                    updpt.add(pt);
                }
            }
            Database.Update(updpt,false);
            // Database.(list, Allornone)
            
        }
    }
    
    global void finish(Database.BatchableContext bc){
        
    }
    
    
}