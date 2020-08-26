trigger LiveChatSurveyAnswerTrigger on Live_Chat_Survey_Answer__c (after Update) 
{
    if(trigger.isAfter && trigger.isUpdate)
    {
        set<ID> lcsaID= new set<ID>();
        system.debug('Trigger.new'+Trigger.new+'Trigger.new.size()'+Trigger.new.size());
        
        for(Live_Chat_Survey_Answer__c lcsa:trigger.new)
        {
            Live_Chat_Survey_Answer__c lcsaold=Trigger.oldmap.get(lcsa.ID);
            if(lcsa.Live_Chat_Transcript__c !=lcsaold.Live_Chat_Transcript__c || lcsa.ChatKey__c != lcsaold.ChatKey__c || 
              lcsa.Live_Chat_Transcript__c !=null)
            {
                lcsaID.add(lcsa.ID);
            } 
        }
        LiveChatSurveyAnswerHelper.SendEmailtoTSR(lcsaID);
        
        system.debug('lcsaID'+lcsaID);
    }
}