//**********************************************************************
//Updates the branch name on lead when branch name changes in Disti Branch object. SFDC 3796
//**********************************************************************

trigger DistiBranchTrigger on Disti_Branches__c (after update) {
   
    DistiBranchTriggerHandler.updateBranchNameInLead(trigger.new, trigger.oldmap);

}