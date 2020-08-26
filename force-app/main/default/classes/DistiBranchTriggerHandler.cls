//**********************************************************************
//Handler class for Distibranchtrigger. Updates the branch name on lead when branch name changes in Disti Branch object. SFDC 3796
//**********************************************************************


public class DistiBranchTriggerHandler {
    
    Public static void updateBranchNameInLead(List<Disti_Branches__c> distiBranchList, Map<id, Disti_Branches__c> oldMapDistiBranch){
        List<Id> distiBranchesId = new List<Id>();
        for(Disti_Branches__c db : distiBranchList){
            if(db.Name != oldMapDistiBranch.get(db.id).Name){
                distiBranchesId.add(db.id);
            }
        }
        
        List<Disti_Branch_Contact_Role__c> disBranchConRoleList = [select id,Contact__c,Disti_branch__c from Disti_Branch_Contact_Role__c where Disti_branch__c in: distiBranchesId];
        List<Id> listContactId = new List<Id>();
        for(Disti_Branch_Contact_Role__c dbc : disBranchConRoleList){
            listContactId.add(dbc.contact__c);
            
        }
       Disticontactroles.updateleadbranchnames(listContactId);
        
    }
    
}