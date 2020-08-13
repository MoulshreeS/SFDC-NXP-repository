trigger Countofactivities on Lead_Activity__c (after Insert,after delete,after update,after undelete) {
    set<id> Leadactivityset = new set<id>();
    if(Trigger.Isinsert || Trigger.Isupdate || Trigger.Isundelete){
        for(Lead_Activity__c la : Trigger.new){
            
            if(Trigger.Isinsert || Trigger.Isundelete || la.Related_to_Lead__c != Trigger.oldmap.get(la.id).Related_to_Lead__c){ 
                Leadactivityset.add(la.Related_to_Lead__c);
                
            }
            
        }
    }
    
    if(Trigger.Isupdate || Trigger.Isdelete){
        for(Lead_Activity__c lac: Trigger.Old ){
            
            if(Trigger.Isdelete || (lac.Related_to_Lead__c != Trigger.newmap.get(lac.id).Related_to_Lead__c)){
                Leadactivityset.add(lac.Related_to_Lead__c);
                
            }
        }
    }
    
    if(!Leadactivityset.Isempty()){
        List<Lead> ld = [select id,(Select id from Lead_Activities__r) from Lead where id in: Leadactivityset];
        for(Lead ldd : ld){
            ldd.Count_of_Activities__c = ldd.Lead_Activities__r.size();
        }
        Update ld;
    }
    
    
    
}