/*------------------------------------------------------------------------------------------------------------------
 * Created By   : Baji
 * Created Date : 05 Feb,2019
 * Description  : SFDC-2260 - To SAP Edit Funloc Request for Fiscal team's approval on tax classification change.
 ------------------------------------------------------------------------------------------------------------------*/
 
trigger Taxes_After_Trigger on Tax_Classification__c (After Insert, After Update, After Delete) {

    if((Trigger.isAfter) && (Trigger.isInsert || Trigger.isUpdate)){
         CMD_Request_Taxes_Trigger.fiscalApprovalForTaxChange(trigger.new);
       }
       
    if((Trigger.isAfter) && (Trigger.isDelete)){
         CMD_Request_Taxes_Trigger.fiscalApprovalForTaxChange(trigger.old);
      }

}