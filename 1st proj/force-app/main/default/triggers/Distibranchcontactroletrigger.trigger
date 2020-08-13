trigger Distibranchcontactroletrigger on Disti_Branch_Contact_Role__c (before insert,after insert,before update,after update,after delete) {
    
    if(Trigger.Isinsert && Trigger.Isbefore){
       // For checking if any Main contact in any other branch 
        Disticontactroles.Checkmaincontactroleinotherbranches(Trigger.New);
        // Check if duplicate executive or primary contact roles in a branch 
        Disticontactroles.contactrolevalidations(Trigger.New);
        // Check any duplicate contacts in a branch
        Disticontactroles.duplicatecontactperbranch(Trigger.New);
    }
    if(Trigger.Isupdate && Trigger.Isbefore){
        // Checks if there is any change in contact or contact role or branch
        List<Disti_Branch_Contact_Role__c> ChangedDistibranchroles = new List<Disti_Branch_Contact_Role__c>();
        List<Disti_Branch_Contact_Role__c> Distibranchduplicatecontact = new List<Disti_Branch_Contact_Role__c>();
        List<Disti_Branch_Contact_Role__c> ChangedDistibranchprimary = new List<Disti_Branch_Contact_Role__c>();
        for(Disti_Branch_Contact_Role__c dbcr : Trigger.new){
            if((dbcr.Contact__c != Trigger.oldmap.get(dbcr.id).contact__c) || (dbcr.Contact_Role__c != Trigger.oldmap.get(dbcr.id).contact_Role__c)){
                ChangedDistibranchprimary.add(dbcr);
            }
            if((dbcr.Contact_Role__c != Trigger.oldmap.get(dbcr.id).contact_Role__c) || (dbcr.disti_branch__c != Trigger.oldmap.get(dbcr.id).disti_branch__c)){
                ChangedDistibranchroles.add(dbcr);
            }
            
            if((dbcr.Contact__c != Trigger.oldmap.get(dbcr.id).contact__c) || (dbcr.disti_branch__c != Trigger.oldmap.get(dbcr.id).disti_branch__c)){
                Distibranchduplicatecontact.add(dbcr);
            }
        }
         // For checking if any Main contact in any other branch 
        Disticontactroles.Checkmaincontactroleinotherbranches(ChangedDistibranchprimary);
        // Check if duplicate executive or primary contact roles in a branch 
        Disticontactroles.contactrolevalidations(ChangedDistibranchroles);
        // Check any duplicate contacts in a branch
        Disticontactroles.duplicatecontactperbranch(Distibranchduplicatecontact);

    }
    List<Id> ChangedDistibranchroleIds = new List<Id>();
    If(Trigger.Isupdate && Trigger.Isafter){
        // List<Id> ChangedDistibranchroleIds = new List<Id>();
        
        for(Disti_Branch_Contact_Role__c dbcr : Trigger.New ) {
            
            if((dbcr.Contact__c != Trigger.oldmap.get(dbcr.id).contact__c) || (dbcr.disti_branch__c != Trigger.oldmap.get(dbcr.id).disti_branch__c) || (dbcr.Contact_Role__c != Trigger.oldmap.get(dbcr.id).contact_Role__c)){
                ChangedDistibranchroleIds.add(dbcr.Contact__c);   
            }
            if(dbcr.Contact__c != Trigger.oldmap.get(dbcr.id).contact__c){
                ChangedDistibranchroleIds.add(Trigger.oldmap.get(dbcr.id).contact__c);
            }
        } 
        
    }
    
    if(Trigger.Isdelete && Trigger.Isafter){
        for(Disti_Branch_Contact_Role__c dbcr : Trigger.Old) {
            ChangedDistibranchroleIds.add(dbcr.Contact__c);  
            
        }
    }
    
    if(Trigger.IsInsert && Trigger.Isafter){
        for(Disti_Branch_Contact_Role__c dbcr : Trigger.new) {
            ChangedDistibranchroleIds.add(dbcr.Contact__c);
        }
    }
    
    if(ChangedDistibranchroleIds != null){
          Disticontactroles.updateleadbranchnames(ChangedDistibranchroleIds);
    }
    
}