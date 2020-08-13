/**
* Author: Marcus Ericsson - mericsson@salesforce.com
*/

/*---------------------------------------------------------------------------------------------------
@Modified By :     Gunjan Singh
@Modified Date :   Sep 10,2019
@Description :     updateCaseAfterPostAndComment : Method written as part of SFDC-2691 and SFDC- 3384
                   To send mail to project invitees and change the status of case after chatter post or comment has been made
****************************************************************************************************/
trigger DisableFeedCommentDeletes on FeedComment (before delete,before insert) 
{
    if(trigger.isBefore){
        if(trigger.isDelete){
            if (!DisableChatterDeleteDelegate.allowDelete()) {
                for(FeedComment f : Trigger.old){
                    f.addError('Your administrator has disabled feed post and comment deletions.'); 
                }
            }
        }
        if(trigger.isInsert){
            //Method written as part of SFDC-2691 and SFDC -3384
            if(CasePortalUtil.SYSTEM_ADMIN_PROFILE_Id != null && userinfo.getProfileId() != CasePortalUtil.SYSTEM_ADMIN_PROFILE_Id)
              {
                    Map<Id, String> errMsg= FeedItemTriggerCommunityHandler.updateCaseAfterPostAndComment(Null,Trigger.New, Null);
                    if(errMsg != null){
                        for(FeedComment feed:Trigger.New){
                           if(errMsg.containsKey(feed.ParentId)){
                                 feed.addError(errMsg.get(feed.ParentId));
    
                           }
                          
                        }    
                    }
                }
        }
    }
}