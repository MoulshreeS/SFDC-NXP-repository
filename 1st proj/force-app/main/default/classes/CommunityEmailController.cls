/*********************************************************************************************
@Created By :      Amit Rajan
@CreatedDate :     6 May 2016
Description :      Class for Email Customized related list on the case detail page
****************************************************************************************************/
public with sharing class CommunityEmailController {
 
    public Boolean hasEmailMessages      {set;get;}  //To check whether email messages are present or not
    
    case caseContactRecord = new case();                                     //To populate the contact Id as part of the To Address
    String fromAddress=' ';                               //To default the from Address to Technical Support
    Case caseRecord;
    EmailTemplate template;                           //To default the selected template
    String additionalTo;                              
    Map<Id, EmailMessage> emailMessages = new Map<Id, EmailMessage>();
    String ccInviteEmailAddresses=' ';
    String bccSilentObservers ='';
    public CommunityEmailController (ApexPages.StandardController controller) {
        
           System.debug('In CommunityEmailController');
        /*
        
                    p3_lkid – Related To
            retURL – Return URL if cancel is pressed
            p2_lkid – To (Contact or Lead ID)
            p4 – CC
            p5 – BCC
            p6 – Subject
            p23- Email Body
            p24 – Additional To
            template_id – Salesforce Email Template ID
            p3 - Related to 

        */
        caseRecord = (case)controller.getRecord();
        
        //Get the contactId
        caseContactRecord = [SELECT ContactId, Projects__c, Contact.Email from Case where id = :caseRecord.id LIMIT 1];
        
         
        if(!String.isBlank(caseContactRecord.Projects__c)){
            getInvitees(caseContactRecord.Projects__c,caseContactRecord.Contact.Email);
        }
        
        //Get the email template id
        template = [SELECT id from EmailTemplate wHERE DeveloperName=:Label.CommunityEmailTemplateName LIMIT 1];
        
        //Query the org wide email address
        List<OrgWideEmailAddress> defaultOrgAddress = [select id, Address, DisplayName from OrgWideEmailAddress WHERE displayName=:Label.CommunityDefaultOrgName];
        
        if(!defaultOrgAddress.isEmpty()){
        
               //From Address format - Org wide Id : Org wide address : Display Name
               fromAddress = defaultOrgAddress[0].id+':'+defaultOrgAddress[0].Address+':'+defaultOrgAddress[0].DisplayName.replaceAll(' ','%20');
        }
        
        List<EmailMessage> messages= new List<EmailMessage>();
        
        messages = [SELECT id from EmailMessage where parentId = :caseRecord.id ORDER BY MessageDate DESC];
        
        if(messages.size() > 0){
            hasEmailMessages  = true;
        }
        else{
            hasEmailMessages  = false;
        }
    }
    
     /*
    * @name         : getInvitees
    * @description  : to add all the invitees in the cc while reply, sendAnEmail and replyAll
    * @ Input param : Id entitlementId
    * @ return type : Void
    */
    private void getInvitees(Id ProjectId,String contactEmail){
        
        //Query all entitlement contacts against this entitlement
        for(Project_Team__c eContact: [SELECT First_Name__c,Project__c,Email_Address__c,Project__r.CreatedBy.Email from Project_Team__c where status__c = :CommunityConstantsUtility.ACCEPTED_STATUS and Project__c = :ProjectId ]){               
               //if it is blank just copy
              if(contactEmail==null ||(contactEmail!=null && !contactEmail.contains(eContact.Email_Address__c))){
               if(String.isBlank(ccInviteEmailAddresses) ){
                   ccInviteEmailAddresses = eContact.Email_Address__c;
                   
                  /* if(!ccInviteEmailAddresses.contains(eContact.Project__r.CreatedBy.Email)){
                       ccInviteEmailAddresses =ccInviteEmailAddresses +';'+eContact.Project__r.CreatedBy.Email;
                   }*/
               }else{
                   //otherwise separated by semicolon
                   ccInviteEmailAddresses  = ccInviteEmailAddresses +';'+ eContact.Email_Address__c;
                }
                }
        }
        
        
      /*  for(Entitlement_Contact__c eContact: [SELECT Contact__r.Email from Entitlement_Contact__c where type__c = :CommunityConstantsUtility.ENTITLEMENTCONTACT_SILENT and Entitlement__c = :entitlementId]){
            if(String.isBlank(bccSilentObservers)){
                bccSilentObservers = eContact.Contact__r.Email;
            }else{
                
                bccSilentObservers = bccSilentObservers+';'+eContact.Contact__r.Email;
            }}*/
    }
    
    /*
    * @name         : getSortedEmails
    * @description  : to get the emails from the case record
    * @ Input param : Null
    * @ return type : pageReference 
    */
    public List<EmailMessage> getSortedEmails(){
    
        List <EmailMessage> sortedEmails = new List<EmailMessage>();
        sortedEmails = [SELECT Id, FromAddress, ToAddress, BCCAddress,Status, HTMLBody, MessageDate, Subject, HasAttachment, Incoming, TextBody, CreatedBy.Name //, (Select Id, Name from Attachments) --> attachments are not needed at the separate emails  
                from EmailMessage where ParentId =: caseRecord.Id 
                order by MessageDate DESC ];
                emailMessages  = new Map<Id,EmailMessage>( sortedEmails );
        return sortedEmails;
  
  }
    
    /*
    * @name         : sendAnEmail
    * @description  : to generate url
    * @ Input param : Null
    * @ return type : pageReference 
    */
    public pageReference sendAnEmail(){
        system.debug('In Send an email');
        
        String url ='/_ui/core/email/author/EmailAuthor?p3_lkid='+String.valueOf(caseRecord.id).substring(0,15)+
        '&p4='+ccInviteEmailAddresses+
        '&p5='+bccSilentObservers+
        '&p2_lkid='+caseContactRecord.ContactId+'&p26_lkid='+caseContactRecord.ContactId+
        '&p26='+fromAddress +'&template_id='+template.id+'&retURL=%2F'+String.valueOf(caseRecord.id).substring(0,15);
        
        PageReference pg = new PageReference(url);
        pg.setRedirect(true);
        return pg;
    }
    
 
   /*
    * @name         : replyEmail
    * @description  : to gener
    * @ Input param : Null
    * @ return type : pageReference 
    */
    public PageReference replyEmail(){
    
        Id emailMessageId = ApexPages.currentPage().getParameters().get('emailId');
        
        String url = '/_ui/core/email/author/EmailAuthor?email_id='+
        emailMessageId;
        url = url+'&replyToAll=0&retURL=%2F'+caseRecord.id+'&p2_lkid='+caseContactRecord.ContactId+'&p26='+fromAddress +'&template_id='+template.id ;
        url = url+'&p4='+ccInviteEmailAddresses;
        url =  url+'&p5='+bccSilentObservers;
        if(caseContactRecord.Contact.Email != emailMessages.get(emailMessageId).FromAddress){
        
        
        url = url+'&p24=';
            if( emailMessages.get(emailMessageId).FromAddress.contains( Label.CommunityTechSupport)){
                emailMessages.get(emailMessageId).FromAddress = emailMessages.get(emailMessageId).FromAddress.replace(Label.CommunityTechSupport, '');
                
            }
            if( emailMessages.get(emailMessageId).FromAddress.contains('no.reply@nxp.com')){
                emailMessages.get(emailMessageId).FromAddress= emailMessages.get(emailMessageId).FromAddress.replace('no.reply@nxp.com', '');
            }
            url = url+ emailMessages.get(emailMessageId).FromAddress;
            
                if( emailMessages.get(emailMessageId).ToAddress.contains( Label.CommunityTechSupport)){
                emailMessages.get(emailMessageId).ToAddress = emailMessages.get(emailMessageId).ToAddress.replace(Label.CommunityTechSupport, '');
                
            }
            if( emailMessages.get(emailMessageId).ToAddress.contains('no.reply@nxp.com')){
                emailMessages.get(emailMessageId).ToAddress= emailMessages.get(emailMessageId).ToAddress.replace('no.reply@nxp.com', '');
            }
            
          //  if( emailMessages.get(emailMessageId).ToAddress != Label.CommunityTechSupport && emailMessages.get(emailMessageId).ToAddress!='no.reply@nxp.com')           
            url= url+emailMessages.get(emailMessageId).ToAddress+';';
            
            if(caseContactRecord.Contact.Email != null && (!emailMessages.get(emailMessageId).ToAddress.contains(caseContactRecord.Contact.Email) && !emailMessages.get(emailMessageId).FromAddress.contains(caseContactRecord.Contact.Email)) )
            url= url+caseContactRecord.Contact.Email;
        }
        
         
        
        return new PageReference(url);
    }
    
    /*
    * @name         : replyAllEmail
    * @description  : to gener
    * @ Input param : Null
    * @ return type : pageReference 
    */
    public PageReference replyAllEmail(){
        Id emailMessageId = ApexPages.currentPage().getParameters().get('emailId');
        
        String url = 
        '/_ui/core/email/author/EmailAuthor?email_id='+
        emailMessageId+'&replyToAll=1&retURL=%2F'+caseRecord.id+'&p4='+ccInviteEmailAddresses+
        '&p5='+bccSilentObservers+
        '&p26='+fromAddress+'&template_id='+template.id;
        return new PageReference(url);
    }
    /*
    * @name         : deleteEmail
    * @description  : to gener
    * @ Input param : Null
    * @ return type : pageReference 
    */
    public PageReference deleteEmail(){
        Id emailMessageId = ApexPages.currentPage().getParameters().get('emailId');
        EmailMessage message = new EmailMessage(Id = emailMessageId);
        delete message;
        return new PageReference('/'+caseRecord.id);
        
    }
 }