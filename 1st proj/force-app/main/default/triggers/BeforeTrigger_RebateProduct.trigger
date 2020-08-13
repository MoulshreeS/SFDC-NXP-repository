trigger BeforeTrigger_RebateProduct on eRebate_Product__c (before insert, before update, before delete) 
{
    if(Trigger.isInsert)
    {
        RebateTrigger.updateRebateProductStdCurrency(Trigger.New);
    }
    

}