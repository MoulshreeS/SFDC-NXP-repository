/***************************************************************************************************
@Created By :       Nisha Agrawal
@Created Date:      11 Jun 2013
@Description:       To sync Customer from Customer Hub to SF-CRM Account object.
***************************************************************************************************
@last modified By :       Baji
@last modified Date:      22 Nov 2019
@Description:       Merged code from another aftertrigger on Customer object to maintain single trigger on same object
*******************************************************************************************************/

trigger AfterTrigger_Customer on Customer__c (after insert, after update) 
{
    if(Trigger.isInsert)
    {
        CustomerTrigger.syncCustomerToSfCrm(Trigger.new); 
        CustomerTrigger_SAP_CMD_Request.syncGidBackToRequests(Trigger.new);
    }
    else if(Trigger.isUpdate)
    {
        //if (CustomerTrigger.IsFirstRun_AfterUpdate)
        //{
            CustomerTrigger.syncCustomerOnUpdateToSfCrm(Trigger.new, Trigger.oldMap); 
        //}
    }
}