/*********************************************************************************************
@Created By :      Amrutha R
@Created Date :    25 Apr 2016
Description :      Community notify case owner if customer replies by email.
----------------------------------------------------------------------------------------------
@Modified By :      Venkateshwar G
@Created Date :    14 Jun 2016
Description :      Community notify case owner if customer replies by email.
Moving the logic in the "CommunityEmailNotificationController" class.
----------------------------------------------------------------------------------------------
@Modified By :     Anil Somani
@Modified Date :   22 Mar 2018
Description :      Processing case related outbound emails as part of SFDC-1327
----------------------------------------------------------------------------------------------
@Modified By :     Bhagyashree Bali
@Modified Date :   Aug 2019
Description :      As per the jira task SFDC-2685
***********************************************************************************************/

trigger CommunityEmailMessage_AfterTrigger on EmailMessage (After insert,Before insert) 
{
    Public List<String> lstCaseIds= new List<String>();
    Public List<String> lstEmailMsgIds= new List<String>();
    //  new list for outgoing mails and their cases
    Public List<String> lstoutgoingCaseIds= new List<String>();  
    List<String> lstFromAddress=new List<String>();
    
    Boolean marvellMigration =
            Marvell_Migration__c.getInstance() != null
            && Marvell_Migration__c.getInstance().isActive__c;
    if (!marvellMigration) {
    
    if(Trigger.isBefore){
        if(Trigger.isInsert){
            for(EmailMessage objEmailMsg: trigger.new){   
                objEmailMsg.IsExternallyVisible=true;
                if( (objEmailMsg.FromAddress != 'no.reply@nxp.com') && (objEmailMsg.FromAddress != 'tech.support@nxp.com' )){
                
                    lstFromAddress.add(objEmailMsg.FromAddress);
                }
            } 
            if(lstFromAddress.size() > 0){
                Map<Id, String> errMsg = FeedItemTriggerCommunityHandler.updateCaseAfterPostAndComment(Null,Null,Trigger.New);
                if(errMsg != null){
                    for(EmailMessage mail:Trigger.New){
                        if(errMsg.containsKey(mail.ParentId)){
                            mail.addError(errMsg.get(mail.ParentId));
                        }
                        
                    }    
                } 
            }
        }
    }
    if(Trigger.isAfter)
    { 
        if(Trigger.isInsert){
            for(EmailMessage objEmailMsg: trigger.new)
            {   
                if(objEmailMsg.Incoming==true){   
                    lstCaseIds.add(objEmailMsg.parentid);
                    lstEmailMsgIds.add(objEmailMsg.Id);
                }
                //collect all outgoing(incoming==false) email details
                else{
                    lstoutgoingCaseIds.add(objEmailMsg.parentid);
                }
            }
            if(lstCaseIds.size()>0 && lstCaseIds!= null){   
                //method to send email to case owner/assigned when customer replies by email
                System.debug('list of cases 111'+lstCaseIds);
                CommunityEmailNotificationController.sendNotificationToOwner(lstCaseIds,lstEmailMsgIds);
            }
            /*****************************Processing case related outbound emails***************************/
            if(lstoutgoingCaseIds.size()>0 && lstoutgoingCaseIds!= null){   
                CommunityEmailNotificationController.updateCaseLatestOutboundEmail(lstoutgoingCaseIds);  
            }
            
        }
    }
    }
}