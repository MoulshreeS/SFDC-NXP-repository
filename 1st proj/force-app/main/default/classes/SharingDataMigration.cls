global class SharingDataMigration implements 
    Database.Batchable<sObject>, Database.Stateful {
    
    
    // instance member to retain state across transactions
    global Integer recordsProcessed = 0;
    global List<String> errorList = new List<String>(); 
    global final String whereStrg;        
    global SharingDataMigration (String q){
        whereStrg=q;  
        }    
               
             global Database.QueryLocator start(Database.BatchableContext bc) {
           String query = 'SELECT Id,Status__c,Role__c,Email_Address__c,Project__c FROM Project_Team__c '+' '+ whereStrg;
            System.assertNotEquals(null, query, 'The query should return records');
            System.debug('###query');
            return Database.getQueryLocator(query);
       
    }
    
    global void execute(Database.BatchableContext bc, List<Project_Team__c> scope){   
    
     If (scope != null){
         
    Set<Project_Team__c> PrjInvSet= new set<Project_Team__c>();
    
        for (Project_Team__c Prjteam : scope) {
       PrjInvSet.add (Prjteam);
       }
       
      CasePortalUtil.shareProjectAccessToTheTeam(PrjInvSet, true, true);  
        
      }
      
    }
    
    global void finish(Database.BatchableContext bc){
    
    
        
               
       
     }
   }