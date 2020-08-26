global class RulingUpdateBatchJob implements Database.Batchable<sObject>,Database.Stateful,Schedulable
{
    global List<Lead_Rules__mdt> listrule;
    global static boolean recursive = false;
    global Database.QueryLocator start(Database.BatchableContext BC)
    {
        String query = 'Select id,filter__c,Object_Name__c,Field_Name__c,Field_Value__c,Active__c from Lead_Rules__mdt';
        
        return Database.getQueryLocator(query);
    }
  
    global void execute(SchedulableContext sc){
            Database.executeBatch(this);
        }
     
    
    global void execute(Database.BatchableContext BC, List<Lead_Rules__mdt> scope)
    {
        if(scope != null){
        listrule = scope;  
      
            }

            }
    global void finish(Database.BatchableContext BC) {
   
 list<AsyncApexJob> jobcompdate = [SELECT CompletedDate FROM AsyncApexJob WHERE JobType = 'BatchApex' 
                             AND Status = 'Completed' and ApexClass.NAME='Updateobject' order by CompletedDate desc limit 1];
    if(jobcompdate.size() > 0){
        Datetime dt = jobcompdate[0].CompletedDate;
        
        if(listrule != null){ 
         if(!recursive) {
        recursive = true;
        for(Lead_Rules__mdt r : listrule) {
            if(r.Active__c){
            Updateobject upd = new Updateobject(r.filter__c,r.Object_Name__c,r.Field_Name__c,r.Field_Value__c,dt);
            Database.executeBatch(upd,50);
            }
        }
         }
            }
        
       }
        else{
            Updateobject upd = new Updateobject('where id= null','Lead','Next_Action__c','test',System.now());
            Database.executeBatch(upd,50);
            
        }
    }
}