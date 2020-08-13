/***************************************************************************************************
@Modified by : Ankita
@Modified Date : 19 Nov 2019
@Dewscription: SFDC-3464 : Optimize the trigger on Funloc Object, that is, separated the logic from trigger to a handler class

*******************************************************************************************************/
trigger Funloc_BeforeTrigger on FunLoc__c (before insert, before update) {
    if(Trigger.isInsert && Trigger.isBefore)
            {
        Funloc_trigger_handler.getFunlocRange(Trigger.new);
         }
         else if(Trigger.isUpdate && Trigger.isBefore)
             {
        Funloc_trigger_handler.UpdtFunlocRange(Trigger.new);
         }
}