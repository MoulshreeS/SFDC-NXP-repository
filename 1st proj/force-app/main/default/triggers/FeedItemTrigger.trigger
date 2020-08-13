/*---------------------------------------------------------------------------------------------------
@Modified By :     Gunjan Singh
@Modified Date :   Sep 10,2019
@Description :     updateCaseAfterPostAndComment : Method written as part of SFDC-2691
                   To send mail to project invitees after chatter post or comment has been made
****************************************************************************************************/

trigger FeedItemTrigger on FeedItem (before insert, After Update) {
    Boolean marvellMigration =
            Marvell_Migration__c.getInstance() != null
                    && Marvell_Migration__c.getInstance().isActive__c;
    if (!marvellMigration) {

    if(trigger.isAfter){
        
        FeedItemTriggerCommunityHandler objFeedItemTriggerCommunityHandler = new FeedItemTriggerCommunityHandler();
        if(trigger.isUpdate){  
                objFeedItemTriggerCommunityHandler.onAfterUpdate(Trigger.new, Trigger.oldMap);
        }
            
    } else if(Trigger.isBefore) {
        if(Trigger.isInsert) {
            
            if(UserInfo.getUserType() == 'Standard') { 
                FeedItemTriggerCommunityHandler.updateLastQuestionNetworkId(Trigger.new);  
            } 
            
            //Method written as part of SFDC-2691 and SFD - 3384
            Map<Id, String> errMsg = FeedItemTriggerCommunityHandler.updateCaseAfterPostAndComment(Trigger.New,Null, Null);
            if(errMsg != null){
                for(FeedItem feed:Trigger.New){
                   if(errMsg.containsKey(feed.ParentId)){
                         feed.addError(errMsg.get(feed.ParentId));

                   }
                  
                }    
            }
        }
    }
    }
}