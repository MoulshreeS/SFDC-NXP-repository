/*------------------------------------------------------------------------------------------------------------------
 * Created By   : Baji
 * Created Date : 05 Feb,2019
 * Description  : SFDC-2260 - To validate tax changes on SAP Edit Funloc Request.
 ------------------------------------------------------------------------------------------------------------------*/

trigger Taxes_Before_Trigger on Tax_Classification__c (Before insert,Before update,Before Delete){
  
     if(trigger.isBefore && (trigger.isInsert || trigger.isUpdate))  {
         CMD_Request_Taxes_Trigger.validationOfCTCTableonCMDRequest(trigger.new);
      }
    
    if(trigger.isBefore && trigger.isdelete){
        system.debug('deletedhere');
        CMD_Request_Taxes_Trigger.validationOfCTCTableonCMDRequest(trigger.old);
        CMD_Request_Taxes_Trigger.validationOfCTCTableonSAPCMD(trigger.old);
        CMD_Request_Taxes_Trigger.validationOfTaxClsonSAPCMD(trigger.old);
     }
  
 }