/*------------------------------------------------------------------------------------------------------------------
 * Created By   : Baji
 * Created Date : 05 Feb,2019
 * Description  : SFDC-2647 - As CMD Officer, Due to Process Change, I want able to change the SAP CMD Status to "Approved"
 ------------------------------------------------------------------------------------------------------------------*/
trigger PFunctions_Before_Trigger on Partner_Function__c (Before Delete) {
    
     if(trigger.isBefore && trigger.isdelete){
     system.debug('deletedhere');
     SAP_CMD_Partner_Function_Trigger.validationOfPartnerFunOnSAPCMD(trigger.old);
     }
}