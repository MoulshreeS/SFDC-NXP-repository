/*---------------------------------------------------------------------------------------------------
@Modified By :     Gunjan Singh
@Modified Date :   Sep 10,2019
@Description :     updateCaseAfterPostAndComment : Method written as part of SFDC-2691
To send mail to project invitees after chatter post or comment has been made
-----------------------------------------------------------------------------------------------------
@Modified By :     Bhagyashree Bali
@Modified Date :   Sep 27,2019
@Description :     removed hardCoded EmailTemplate in class updateCaseAfterPostAndComment
****************************************************************************************************/


public class FeedItemTriggerCommunityHandler {
    
    public void onAfterUpdate(List<FeedItem> lstFeedItemNew, Map<Id,FeedItem> mapFeedItemOld){
        
        System.debug('Limit queries onAfterUpdate Handler 1 *>'+System.limits.getQueries());
        
        updateCase(lstFeedItemNew, mapFeedItemOld);
        // addFileOnUpdate(lstFeedItemNew);
        
        System.debug('Limit queries onAfterUpdate Handler 11 *>'+System.limits.getQueries());
        
        addFileOnUpdate(lstFeedItemNew);
        // updateCase(lstFeedItemNew, mapFeedItemOld);
    }
    
    private void addFileOnUpdate(List<FeedItem> lstFeedItemNew) {
        
        Id caseId;
        Boolean isNewFileHolder = false;
        FeedItem objFileHolder;
        FeedItem objQuestionFeedItem = lstFeedItemNew[0];
        Set<Id> setExistingRecordId = new Set<Id>();
        List<FeedAttachment> lstFAToInsert = new List<FeedAttachment>();
        
        System.debug('Limit queries addFileOnUpdate Handler 2 *>'+System.limits.getQueries());
        
        For(Case objCase : [SELECT Id 
                            FROM Case 
                            WHERE FeedItemId =: objQuestionFeedItem.Id 
                            LIMIT 1]) {
                                
                                caseId = objCase.Id;
                            }
        
        System.debug('Limit queries addFileOnUpdate Handler 3 *>'+System.limits.getQueries());
        
        if(caseId == null) return;
        
        System.debug('Limit queries addFileOnUpdate Handler 4 *>'+System.limits.getQueries());
        
        for(FeedItem objFeed : [SELECT Id, ParentId 
                                FROM FeedItem 
                                WHERE Title = 'File Holder' 
                                AND ParentId =: caseId
                                LIMIT 1]){    
                                    objFileHolder = objFeed;
                                }
        
        System.debug('Limit queries addFileOnUpdate Handler 5 *>'+System.limits.getQueries());
        
        if(objFileHolder == null) {
            objFileHolder = new FeedItem(Title = 'File Holder', Body='File Holder', ParentId = caseId, Visibility = 'AllUsers');
            isNewFileHolder = true;
            insert objFileHolder;
        }
        
        if(!isNewFileHolder) {
            
            System.debug('Limit queries addFileOnUpdate Handler 6 *>'+System.limits.getQueries());
            
            for(FeedAttachment objFeedAttach : [SELECT RecordId
                                                FROM FeedAttachment
                                                WHERE FeedEntityId =: objFileHolder.Id
                                                AND RecordId != NULL ] ){
                                                    
                                                    setExistingRecordId.add(objFeedAttach.RecordId);
                                                }
            
            System.debug('Limit queries addFileOnUpdate Handler 7 *>'+System.limits.getQueries());
        }
        
        System.debug('Limit queries addFileOnUpdate Handler 8 *>'+System.limits.getQueries());
        
        for(FeedAttachment objFeedAttach : [SELECT Id,RecordId,FeedEntityId,Title,Type,Value
                                            FROM FeedAttachment
                                            WHERE FeedEntityId =: objQuestionFeedItem.Id
                                            AND RecordId != NULL
                                            AND RecordId NOT IN: setExistingRecordId] ){
                                                
                                                FeedAttachment objFeedAttachment = new FeedAttachment(FeedEntityId =  objFileHolder.Id, RecordId = objFeedAttach.RecordId, Type = 'CONTENT');
                                                lstFAToInsert.add(objFeedAttachment);
                                            }
        
        System.debug('Limit queries addFileOnUpdate Handler 9 *>'+System.limits.getQueries());
        
        Datetime sysTime = System.now().addSeconds( 30 );      
        String chronExpression = '' + sysTime.second() + ' ' + sysTime.minute() + ' ' + sysTime.hour() + ' ' + sysTime.day() + ' ' + sysTime.month() + ' ? ' + sysTime.year();
        if(!Test.isRunningTest()){
            
            System.schedule( 'SelfScheduleForFileAttchment' + sysTime, chronExpression, new AddFileOnQuestionUpdateScheduler(lstFAToInsert)); 
        }
        
        System.debug('Limit queries addFileOnUpdate Handler 10 *>'+System.limits.getQueries());
    }
    
    private void updateCase(List<FeedItem> lstFeedItemNew, Map<Id,FeedItem> mapFeedItemOld){
        
        //map of feedid to feedBody
        Map<String,FeedItem> mapFeedIdToFeedItem = new Map<String,FeedItem>();
        //list of cases to be updated
        List<Case> lstCaseToUpdate = new List<Case>();
        
        for(FeedItem objFeedItem : lstFeedItemNew){
            
            // system.debug('obj Body ->'+objFeedItem);
            FeedItem objFeedItemOld = mapFeedItemOld.get(objFeedItem.Id);
            
            if(objFeedItemOld.Type == 'QuestionPost') {
                
                if(objFeedItemOld.Body != objFeedItem.Body || objFeedItemOld.Title != objFeedItem.Title){
                    
                    //populate map
                    mapFeedIdToFeedItem.put(objFeedItem.Id,objFeedItem);
                }
            }   
        }
        
        System.debug('Limit queries updateCase Handler 2 *>'+System.limits.getQueries());
        
        //case query loop  with WHERE feeditemId IN map.keyset()
        for(Case objCase : [SELECT FeedItemId,Subject,Description 
                            FROM Case 
                            WHERE FeedItemId IN: mapFeedIdToFeedItem.keyset()]){
                                
                                //map.get(feedItemId) --> desc new  != case.desc
                                String feedBody = mapFeedIdToFeedItem.get(objCase.feedItemId).body;
                                
                                objCase.Subject = mapFeedIdToFeedItem.get(objCase.feedItemId).Title;
                                
                                if(feedBody != objCase.Description){
                                    
                                    feedBody = feedBody.replaceAll('<p>', '');                
                                    feedBody = feedBody.replaceAll('<p>','--n--');
                                    feedBody = feedBody.replaceAll('</p>','--n--');
                                    feedBody = feedBody.replaceAll('<code>','\t');
                                    feedBody = feedBody.replaceAll('</code>','');
                                    feedBody = feedBody.stripHtmlTags();
                                    feedBody  = String.join(feedBody.split('--n--'),' \n ');
                                    
                                    objCase.Description = feedBody;
                                    lstCaseToUpdate.add(objCase);
                                }
                            }
        
        System.debug('Limit queries updateCase Handler 3 *>'+System.limits.getQueries());
        
        Update lstCaseToUpdate;
        
        System.debug('Limit queries aftr updateCase Handler 4*>'+System.limits.getQueries());
    }
    
    public static void updateLastQuestionNetworkId(List<FeedItem> lstFeedItemNew) {
        
        for(FeedItem objFeedItem : lstFeedItemNew) {
            
            if(objFeedItem.Type == 'QuestionPost') {
                
                update new User(Id = UserInfo.getUserId(),
                                Last_Question_Posted_Network__c = objFeedItem.NetworkScope);
                
                break;
            }
        }
    }
    
// Method written as part of SFDC-2691 and 3384
    
    public static Map<Id, String> updateCaseAfterPostAndComment(List<FeedItem> lstNewFeedItem, List<FeedComment> lstNewFeedComment, List<EmailMessage> lstNewEmailMessage){
        Map<Id, String> errMsgMap = new Map<Id, String>();
        Set<Id> setCaseId = new Set<Id>(); 
        
       
        //check if method is executed for feeditem
        if(lstNewFeedComment == null && lstNewFeedItem != null && lstNewEmailMessage == null){
            for (FeedItem lstFeedItem: lstNewFeedItem){  
                if (lstFeedItem.ParentId.getSObjectType() == Case.SObjectType){
                    setCaseId.add(lstFeedItem.ParentId); 
                  
                }
            }
        }
        //check if method is executed for feedcomments
        if(lstNewFeedComment != null && lstNewFeedItem == null && lstNewEmailMessage == null){
            for (FeedComment lstFeedComment: lstNewFeedComment){  
                if (lstFeedComment.ParentId.getSObjectType() == Case.SObjectType){
                    setCaseId.add(lstFeedComment.ParentId);   
                  
                }
            }
        }
        
        //check if method is executed for Email Messages
        if(lstNewFeedComment == null && lstNewFeedItem == null && lstNewEmailMessage != null){
            for (EmailMessage lstEmailMessage: lstNewEmailMessage){  
                if(lstEmailMessage.ParentId != null){//-- add due to null point exception -saranya
                    if (lstEmailMessage.ParentId.getSObjectType() == Case.SObjectType){
                        setCaseId.add(lstEmailMessage.ParentId);
                    }
                }
            }
        }
        
        if(setCaseId.size() > 0){
            Map<Id,Id> mapCaseAndProject = new Map<Id,Id>();
            Map<Id,List<String>> mapProjectAndTeam = new Map<Id,List<String>>();
            List<Case> lstUpdatedCase = new List<Case>();
            Map<Id,String> mapCaseIdAndEmail = new Map<Id,String>();     
            
            List<Case> lstCase =[select ID,Contact.Id,Status,CaseNumber,Assigned_To__r.Email,Projects__c,Projects__r.Name,CreatedDate,Subject,ClosedDate,Due_Date__c,FeedItem.Body  from case where id IN:setCaseId AND RecordType.Name = 'TS Community'];
            
            Set<Id> setProjId = new Set<Id>();
            for(Case objCase:lstCase){   
                setProjId.add(objCase.Projects__c);
                mapCaseAndProject.put(objCase.Id,objCase.Projects__c);
                mapCaseIdAndEmail.put(objCase.Id,objCase.Assigned_To__r.Email);
            }
            
            if(setProjId.size()>0)
            {
                for(Project_Team__c objProTeam : [Select ID,Project__c,Email_Address__c From Project_Team__c 
                                                      Where Project__c IN :setProjId AND Status__c =:  CasePortalUtil.PROJECT_TEAM_STATUS_ACCEPTED]){
                    if(mapProjectAndTeam.containsKey(objProTeam.Project__c)) {
                        List<String> lstEmailId = mapProjectAndTeam.get(objProTeam.Project__c);
                        lstEmailId.add(objProTeam.Email_Address__c );
                        mapProjectAndTeam.put(objProTeam.Project__c, lstEmailId);
                    } else {
                        mapProjectAndTeam.put(objProTeam.Project__c, new List<String> {objProTeam.Email_Address__c});
                    }
                }
            }        
            
            EmailTemplate participantEmailTemplate;
            EmailTemplate agentEmailTemplate;
            List<EmailTemplate> lstEmailTemplate =[select Id, Subject, DeveloperName, Body from EmailTemplate where DeveloperName = 'CP_CasePostAndComment_EmailTemplate' OR DeveloperName = 'Notification_to_the_Agent_on_an_online_message_on_the_Case'];
            for(EmailTemplate objEmailTemp : lstEmailTemplate){
                 if(objEmailTemp.DeveloperName == 'CP_CasePostAndComment_EmailTemplate')
                     participantEmailTemplate = objEmailTemp;
                 if(objEmailTemp.DeveloperName == 'Notification_to_the_Agent_on_an_online_message_on_the_Case')
                     agentEmailTemplate = objEmailTemp;   
            }
            
            Id techSupportEmailAddressId ;
            for(OrgWideEmailAddress owa : CasePortalUtil.getOrgWideEmailAddress()) {
                if(owa.Address.contains('tech.support@nxp.com')) 
                    techSupportEmailAddressId = owa.Id; 
            }
            
            List<Messaging.SingleEmailMessage> lstEmailMessages = new List<Messaging.SingleEmailMessage>();

            for(Case objCase:lstCase)
            {
                if(mapCaseAndProject.containsKey(objCase.Id) && mapProjectAndTeam.containsKey(mapCaseAndProject.get(objCase.Id))){
                    if(mapProjectAndTeam.get(mapCaseAndProject.get(objCase.Id)).contains(UserInfo.getUserEmail()) && objCase.Status !='Received Reply')
                    {                       
                        if(objCase.Status != CasePortalUtil.CASE_STATUS_CLOSE && objCase.Status != CasePortalUtil.CASE_STATUS_CANCEL){
                            objCase.Status = CasePortalUtil.CASE_STATUS_RECEIVEDREPLY;
                        }
                        if(objCase.Status.equalsIgnoreCase(CasePortalUtil.CASE_STATUS_CLOSE) && objCase.Due_Date__c  >= DateTime.Now()- CasePortalUtil.FILE_UPLOAD_ALLOWED_DAYS ){
                            objCase.Status = CasePortalUtil.CASE_STATUS_RECEIVEDREPLY;
                        }
                        //objCase.ClosedDate<= DateTime.Now().addMinutes(-5))
                        //objCase.due_date__c <= DateTime.Now()-CasePortalUtil.FILE_UPLOAD_ALLOWED_DAYS
                        if((objCase.Status.equalsIgnoreCase(CasePortalUtil.CASE_STATUS_CLOSE) && objCase.Due_Date__c  <= DateTime.Now()- CasePortalUtil.FILE_UPLOAD_ALLOWED_DAYS) || objCase.Status.equalsIgnoreCase(CasePortalUtil.CASE_STATUS_CANCEL) ){
                            errMsgMap.put(objCase.Id, 'You cannot post online message as Case is Closed for more than 30 days');
                            return errMsgMap;
                        }
                        lstUpdatedCase.add(objCase);              
                    }
                }
                system.debug('Value of lstUpdatedCase'+lstUpdatedCase);
                if(lstNewFeedComment != null || lstNewFeedItem != null){
                    if(participantEmailTemplate!=null && participantEmailTemplate.DeveloperName == 'CP_CasePostAndComment_EmailTemplate'){                    
                        system.debug('Inside participant Block');
                        String Subject=participantEmailTemplate.Subject;
                        String PlainBody=participantEmailTemplate.Body;
                        string createdDate = string.valueOfGmt(objcase.CreatedDate);
                        if(objcase.CaseNumber!=null){
                            String currentUserName = UserInfo.getName();
                            //String emailThreadId = CasePortalUtil.getCaseThreadId(objCase.Id);
                            String emailThreadId = CaseTrigger.getThreadId(objCase.Id);
                            Subject=Subject.replace('{!Case.CaseNumber}', objcase.CaseNumber);
                            Subject=Subject.replace('{!Case.Subject}', objcase.Subject);
                            PlainBody=PlainBody.replace('{!Case.CaseNumber}', objcase.CaseNumber);
                            PlainBody=PlainBody.replace('{!Case.CreatedDate}', createdDate );
                            PlainBody=PlainBody.replace('{!Case.Subject}', objcase.Subject);
                            PlainBody=PlainBody.replace('{!User.Name}', currentUserName);
                            PlainBody=PlainBody.replace('{!Case.Id}', objCase.Id);
                            PlainBody=PlainBody.replace('{!Case.Thread_Id}', emailThreadId);
                         
                            if(objcase.Projects__r.Name!=null){
                                PlainBody=PlainBody.replace('{!Case.Projects__c}', objcase.Projects__r.Name);
                            }
                        }
                        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                        List<String> toAddresses = new List<String>();
                        if(mapProjectAndTeam.get(mapCaseAndProject.get(objCase.Id)) != Null){
                            toAddresses = (mapProjectAndTeam.get(mapCaseAndProject.get(objCase.Id)));
                        }                    
                        mail.setToAddresses(toAddresses);
                        mail.setPlainTextBody(PlainBody);
                        mail.setSubject(Subject);
                        if(techSupportEmailAddressId != null)
                        {
                            mail.setOrgWideEmailAddressId(techSupportEmailAddressId); 
                        }
                        if(toAddresses!=Null && toAddresses.size()>0){
                            lstEmailMessages.add(mail);
                        }
                    }
                    
                    if(agentEmailTemplate!=Null && agentEmailTemplate.DeveloperName == 'Notification_to_the_Agent_on_an_online_message_on_the_Case'){
                        List<String> toAddressesofAgent = new List<String>();
                        if(mapCaseIdAndEmail.containsKey(objCase.Id) && mapCaseIdAndEmail.get(objCase.Id) != Null && mapCaseIdAndEmail.get(objCase.Id) != UserInfo.getUserEmail()){
                                toAddressesofAgent.add(mapCaseIdAndEmail.get(objCase.Id));
                        }
                        Messaging.SingleEmailMessage objMail = new Messaging.SingleEmailMessage();
                        objMail.setTemplateId(agentEmailTemplate.Id);
                        objMail.setToAddresses(toAddressesofAgent);
                        objMail.setTargetObjectId(objCase.Contact.Id);
                        objMail.setWhatId(objCase.Id);
                        objMail.setSaveAsActivity(false);
                        objMail.setUseSignature(false);
                        objMail.setTreatTargetObjectAsRecipient(false);
                         if(techSupportEmailAddressId != null)
                        {
                            objMail.setOrgWideEmailAddressId(techSupportEmailAddressId); 
                        }
                        if(toAddressesofAgent!=Null && toAddressesofAgent.size()>0){
                            lstEmailMessages.add(objMail);
                        }
                    }
                }
            }
            system.debug('Value of lstEmailMessages'+lstEmailMessages);
            if(lstEmailMessages.size() > 0)
            {
                Messaging.sendEmail(lstEmailMessages);   
            }
            
            if(lstUpdatedCase.size()>0){
                try{
                    update lstUpdatedCase;
                }
                catch(Exception e){
                    System.debug('The following exception has occurred: ' + e.getMessage());
                }
            }
        }         
        return errMsgMap; 
    }
       
}