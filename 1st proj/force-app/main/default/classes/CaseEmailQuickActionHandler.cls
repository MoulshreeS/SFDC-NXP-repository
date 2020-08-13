/*****************************************************************************
@Modified By :  Gunjan Singh
@Modified Date: 30th July 2018
Description :   Showing email template in feed on click of Reply All Button for SFDC-1584
******************************************************************************/
/*****************************************************************************
@Modified By :  Gunjan Singh
@Modified Date: 26th Nov 2018
Description :   Content of email notifications to be shorten to the latest reply and case URL only for SFDC-2032
******************************************************************************/

    global class CaseEmailQuickActionHandler implements QuickAction.QuickActionDefaultsHandler {
    // Empty constructor
    global CaseEmailQuickActionHandler() {
    }
    public String ccInviteEmailAddresses {get;set;}
    public String bccSilentObservers {get;set;}
    // The main interface method
    global void onInitDefaults(QuickAction.QuickActionDefaults[] defaults) {
        
           System.debug('In CommunityEmailController');
        QuickAction.SendEmailQuickActionDefaults sendEmailDefaults = null;
    
        // Check if the quick action is the standard Case Feed send email actionare y
        for (Integer j = 0; j < defaults.size(); j++) {
            if (defaults.get(j) instanceof QuickAction.SendEmailQuickActionDefaults && 
               defaults.get(j).getTargetSObject().getSObjectType() == 
                   EmailMessage.sObjectType && 
               defaults.get(j).getActionName().equals('Case.Email') && 
               defaults.get(j).getActionType().equals('Email')) {
                   sendEmailDefaults = (QuickAction.SendEmailQuickActionDefaults)defaults.get(j);
                   break;
            }
        }
        System.debug('defaults '+sendEmailDefaults);
        if (sendEmailDefaults != null) {
            Case c = [SELECT Status,subject, Reason,ContactEmail,Projects__c FROM Case WHERE Id=:sendEmailDefaults.getContextId()];

            EmailMessage emailMessage = (EmailMessage)sendEmailDefaults.getTargetSObject();    
            // Set to address to make sure each email goes for audit
            ccInviteEmailAddresses = '';
            bccSilentObservers = '';
            if(c.Projects__c != null){
                getInvitees(c.Projects__c,c.ContactEmail);
            }           
            emailMessage.ToAddress = c.ContactEmail;
            emailMessage.Subject = c.Subject;
            emailMessage.CcAddress = ccInviteEmailAddresses;
            emailMessage.BccAddress = bccSilentObservers;
            emailMessage.FromName = 'NXP Technical Support';
            emailMessage.ValidatedFromAddress = 'tech.support@nxp.com';
            emailMessage.FromAddress = 'tech.support@nxp.com'; //UserInfo.getUserEmail();
           
          /*  LIST<String> fromList = sendEmailDefaults.getFromAddressList();
            if(fromList != null){
                for(Integer i = fromList.size() - 1; i >= 0; i--){
                        if(!fromList.get(i).equals(emailMessage.FromName)){
                            fromList.remove(i);
                        }
                }
            }*/
            
            /* 
            Set Template related fields 
            When the In Reply To Id field is null we know the interface 
            is called on page load. Here we check if 
            there are any previous emails attached to the case and load 
            the 'New_Case_Created' or 'Automatic_Response' template.
            When the In Reply To Id field is not null we know that 
            the interface is called on click of reply/reply all 
            of an email and we load the 'Default_reply_template' template
            */
            
            //Added as part of SFDC-1584
            sendEmailDefaults.setTemplateId(getTemplateIdHelper(Label.CommunityEmailTemplateName));
            sendEmailDefaults.setInsertTemplateBody(false);
            sendEmailDefaults.setIgnoreTemplateSubject(false);
            
           // Commented as part of SFDC-1584
           /* if (sendEmailDefaults.getInReplyToId() == null) {
                sendEmailDefaults.setTemplateId(getTemplateIdHelper(Label.CommunityEmailTemplateName));
                sendEmailDefaults.setInsertTemplateBody(true);
                sendEmailDefaults.setIgnoreTemplateSubject(false);
            } else {
                sendEmailDefaults.setInsertTemplateBody(false);
                sendEmailDefaults.setIgnoreTemplateSubject(true);
            } */
        }
   
    }
    
    private Id getTemplateIdHelper(String templateApiName) {
        Id templateId = null;
        try {
            templateId = [select id, name from EmailTemplate 
                          where developername = : templateApiName].id;   
        } catch (Exception e) {
            system.debug('Unble to locate EmailTemplate using name: ' + 
                templateApiName + ' refer to Setup | Communications Templates ' 
                    + templateApiName);
        }
        return templateId;
    }

    private void getInvitees(Id ProjectId,String contactEmail){
        //Query all entitlement contacts against this entitlement
        for(Project_Team__c eContact: [SELECT First_Name__c,Project__c,Email_Address__c,Project__r.CreatedBy.Email from Project_Team__c where status__c = :CommunityConstantsUtility.ACCEPTED_STATUS and Project__c = :ProjectId ]){               
               //if it is blank just copy
              if(contactEmail==null ||(contactEmail!=null && !contactEmail.contains(eContact.Email_Address__c))){
               if(String.isBlank(ccInviteEmailAddresses) ){
                   ccInviteEmailAddresses = eContact.Email_Address__c;
                   
                 /*  if(!ccInviteeEmailAddresses.contains(eContact.Project__r.CreatedBy.Email)){
                       ccInviteeEmailAddresses =ccInviteeEmailAddresses +';'+eContact.Project__r.CreatedBy.Email;
                   }*/
               }else{
                   //otherwise separated by semicolon
                   ccInviteEmailAddresses  = ccInviteEmailAddresses +';'+ eContact.Email_Address__c;
                }
                }
        }
       /* for(Entitlement_Contact__c eContact: [SELECT Contact__r.Email from Entitlement_Contact__c where type__c = :CommunityConstantsUtility.ENTITLEMENTCONTACT_SILENT and Entitlement__c = :entitlementId]){
            if(String.isBlank(bccSilentObservers)){
                bccSilentObservers = eContact.Contact__r.Email;
            }
            else{
                bccSilentObservers = bccSilentObservers+';'+eContact.Contact__r.Email;
            }
        } */
    }
    
}