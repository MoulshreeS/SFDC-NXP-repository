/************************************************************************
@Created By :    Saranya Sista
@Created Date:   
@Description:    Controller class Case Survey Lightning Component
****************************************************************************************/

public  without sharing class CommunityCaseSurveyControllerNCP {
    @AuraEnabled
    public static List<String> caseSurveyDetailNCP(Id caseIdcurrent){
        List<String> caseRecString = new List<String>();
        List<case> caseRec = [select id,CaseNumber,Subject,Survey_Flag__c from case where id=: caseIdcurrent];
        system.debug('case details are:'+caseRec);
        caseRecString.add(caseRec[0].Subject);
        caseRecString.add(caseRec[0].CaseNumber);
        caseRecString.add(caseRec[0].Survey_Flag__c);
        return caseRecString;
        
    }
    @AuraEnabled
    public static String submitSurveyToSalesforce(String option1,String option2,String option3,String option4,Id caseId,String comments){
        String errormessage;
        List<Survey_answer__c> lstSurveyAns = new List<Survey_answer__c>();
        List<survey_question__c> lstSurveyQues = new List<survey_question__c>();
        Map<string,Id> NameQuestionMap = new Map<string,Id>();
        
        lstSurveyQues= [Select id, name, question__c,type__c,value__c from survey_question__c 
                        where name='Resolved ?' or name='Resolution Time ?' or name='Support Person ?' or name='Share with others ?' or name='Comments'];        
        if(!lstSurveyQues.isEmpty()){
            for(survey_question__c surveyq : lstSurveyQues){
                NameQuestionMap.put(surveyq.name,surveyq.Id);
            }
        }
        
        List<Case> lstCase= [Select id,casenumber,email__c,ownerid,assigned_to__r.id,Subject,Survey_Flag__c,
                             assigned_to__c, assigned_to__r.name,owner.name,owner.email,assigned_to__r.email
                             from case where id =: caseId];
        
        if(!NameQuestionMap.isEmpty()){
            Survey_answer__c objAns= new Survey_answer__c();
            objAns.Case__c = lstCase[0].Id;
            objAns.Survey_Question__c = NameQuestionMap.get('Resolved ?');
            objAns.Answer__c = option1;
            lstSurveyAns.add(objAns);
            
            Survey_answer__c objAns2= new Survey_answer__c();
            objAns2.Case__c = lstCase[0].Id;
            objAns2.Survey_Question__c = NameQuestionMap.get('Resolution Time ?');
            objAns2.Answer__c = option2;
            lstSurveyAns.add(objAns2);
            
            Survey_answer__c objAns3= new Survey_answer__c();
            objAns3.Case__c = lstCase[0].Id;
            objAns3.Survey_Question__c = NameQuestionMap.get('Support Person ?');
            objAns3.Answer__c = option3;
            lstSurveyAns.add(objAns3);
            
            Survey_answer__c objAns4= new Survey_answer__c();
            objAns4.Case__c = lstCase[0].Id;
            objAns4.Survey_Question__c = NameQuestionMap.get('Share with others ?');
            objAns4.Answer__c = option4;
            lstSurveyAns.add(objAns4);
            
            Survey_answer__c objAns5= new Survey_answer__c();
            objAns5.Case__c = lstCase[0].Id;
            objAns5.Survey_Question__c = NameQuestionMap.get('Comments');
            objAns5.Answer__c = comments;
            lstSurveyAns.add(objAns5);
        }
        try 
        {
            if(!lstSurveyAns.isEmpty()){
                insert lstSurveyAns;
                lstCase[0].Survey_Flag__c='False';
                update lstCase; 
                sendSurveyFeedbackEmail(lstCase,lstSurveyAns);
            }
        }
        catch (DMLException e) 
        {
            errormessage = 'Error in submitting survey feedback';
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Error in submitting survey feedback'));            
        }
        return errormessage;
    }
    
    //method to send email to case owner/assigned to based on survey feedback
    public static void sendSurveyFeedbackEmail(List<case> lstCase,List<Survey_answer__c> lstSurveyAns)
    {
        system.debug('send email'+lstCase+lstSurveyAns);
        String strSendTo;
        String strSendId;
        String strSendToName;
        String strSubject='';
        String strBody='';
        if(lstCase[0].assigned_to__c!=null)
        {
            strSendId= lstCase[0].assigned_to__r.id;
            strSendTo= lstCase[0].assigned_to__r.email;
            strSendToName= lstCase[0].assigned_to__r.name;
        }
        else
        {
            strSendId =lstCase[0].ownerId;
            strSendTo= lstCase[0].owner.email;
            strSendToName= lstCase[0].owner.name;
        }
        if(string.valueOf(strSendId).startsWith('005'))
        {
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            EmailTemplate positiveFeedBack=[select Id, Subject, Body from EmailTemplate where DeveloperName = 'Notification_to_Agent_about_the_received_Satisfaction_Survey_positive'];
            EmailTemplate negativeFeedBack=[select Id, Subject, Body from EmailTemplate where DeveloperName = 'Notification_to_Agent_about_the_received_Satisfaction_Survey_Negative'];
            String[] toAddresses = new String[] {strSendTo};
                
                // String strSubject='';
                if(lstSurveyAns[0].answer__c.trim().equalsignorecase('4 Very Satisfied') || 
                   lstSurveyAns[0].answer__c.trim().equalsignorecase('3 Satisfied'))
            {
                strBody=positiveFeedBack.Body;
                strSubject=positiveFeedBack.Subject;
            }
            else {
                strBody=negativeFeedBack.Body;
                strSubject=negativeFeedBack.Subject;
            }
            strSubject=strSubject.replace('{!Case.CaseNumber}', lstCase[0].casenumber);
            strSubject=strSubject.replace('{!Case.Subject}', lstCase[0].subject);
            System.debug('strSendToName' + strSendToName);
            
            
            strBody=strBody.replace('{!AssignedToAgent}', strSendToName);            
            strBody=strBody.replace('{!Case.CaseNumber}', lstCase[0].casenumber);
            strBody=strBody.replace('{!Resolved}', lstSurveyAns[0].answer__c.trim());
            strBody=strBody.replace('{!ResolutionTime}', lstSurveyAns[1].answer__c.trim());
            strBody=strBody.replace('{!SupportPerson}', lstSurveyAns[2].answer__c.trim());
            strBody=strBody.replace('{!Recommendus}', lstSurveyAns[3].answer__c.trim());
            
            String additionalComments = lstSurveyAns[4].answer__c;
            additionalComments =additionalComments.replace('<p>','');
            additionalComments =additionalComments.replace('</p>','');
            System.debug('strSendToName' + additionalComments );
            if(additionalComments != null) 
                strBody=strBody.replace('{!AdditionalComment}', additionalComments.trim());                
            else
              strBody=strBody.replace('{!AdditionalComment}', ' ');
            
            mail.setToAddresses(toAddresses);
            mail.setSenderDisplayName('No Reply');
            mail.setSubject(strSubject);
            mail.setPlainTextBody(strBody);
            try
            {
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
            }
            catch(System.EmailException ex)
            {
                system.debug('could not send mail');
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Sorry, some problem occured.'));     
            }
        }
    }
}