/***************************************************************************************************
@Created By :       Nisha Agrawal
@Created Date:      10 Apr 2013
@Description:       1. Trigger to Copy Parent Account's Manager to Account Manager Prechild field
                    2. Trigger to Copy D&B data to account fields when D&B data Accepted
***************************************************************************************************
@Modified By :      Baji
Modified Date:      28 Aug 2019
@Description:       1. Obsoleted the above features(Copy Parent Account's Manager & D7B Data) after getting confirmation from Andy 
                       that these features are invalid now.
                    2. Added logic to update account owner for inactive child accounts [SFDC-3176]
*******************************************************************************************************/

trigger BeforeTrigger_Account on Account (before update) 
{
    if(Trigger.isUpdate)
     {
        accountTrigger.updateOwnerForInactiveChildAccounts(trigger.new);
     }
    
 }