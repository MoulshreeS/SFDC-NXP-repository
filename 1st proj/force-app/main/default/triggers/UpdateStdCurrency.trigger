/*********************************************************************************
Name           :    UpdateStdCurrency
Author         :    Naveen
Date           :    23 June 2019
Description    :   SBE Team report have Rebate Actual Payout Current Issues            
**********************************************************************************/

trigger UpdateStdCurrency on eRebate_Payout_Line_Item__c (before Insert) 
{ 
    List<Id> PayoutIds = new List<Id>();
    For(eRebate_Payout_Line_Item__c Lineitems : Trigger.new)
    {
        PayoutIds.add(Lineitems.eRebate_Payout__c);
    }
    Map<Id,eRebate_Payout__c> erebmap = new Map<Id,eRebate_Payout__c>([select id,CurrencyIsoCode from eRebate_Payout__c where id in: PayoutIds]);
    for(eRebate_Payout_Line_Item__c eRebline : Trigger.new)
    {
        eRebate_Payout__c eReb = erebmap.get(eRebline.eRebate_Payout__c);
        eRebline.CurrencyIsoCode = eReb.CurrencyIsoCode;           
    }
    
}