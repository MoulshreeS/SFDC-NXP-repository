public class LiveChatSurveyAnswerHelper 
{
    @future(callout=true)
    public static void SendEmailtoTSR(set<ID> lcsaID)
    {
        String strSendTo;
        String strTranscriptName;
        String strSendToName;
        String strSubjectSatorverysat;
        String strSubjectdisorverydis;
        string strResolved;
        string strResolutionTime;
        string strSupportPerson ;
        string strSharewithothers ;
        string strComments;
        string strBody;
        ID ChatResolvedID;
        ID ChatResolutionTime;
        ID ChatSupportPerson;
        ID ChatSharewithothers;
        ID ChatComments;
        ID lctID;
        set<ID> LiveTranscriptID= new set<ID>();
        List<Live_Chat_Survey_Answer__c> LiveChatSurveyList= [Select Id, ChatKey__c,  Chat_Survey_Answer__c,  Chat_Survey_Question__c, Live_Chat_Transcript__c From 
                                                              Live_Chat_Survey_Answer__c where ID =:lcsaID];
        system.debug('LiveChatSurveyList'+LiveChatSurveyList);
        
        if(LiveChatSurveyList.size()>0 && !LiveChatSurveyList.isEmpty() && LiveChatSurveyList != null)
        {
            for(Live_Chat_Survey_Answer__c lc:LiveChatSurveyList)
            {
                if(lc.Live_Chat_Transcript__c != null)
                {
                    LiveTranscriptID.add(lc.Live_Chat_Transcript__c);
                }
                
            }
        }
        system.debug('LiveTranscriptID'+LiveTranscriptID);	
        
        List<LiveChatTranscript> lctlist=[select Id,Name,Owner.Email,Owner.Name,ChatKey from LiveChatTranscript where ID=:LiveTranscriptID];
        
        
        
        List<survey_question__c> sqlist=[select Id,Name from survey_question__c where 
                                         (Name='Chat Resolved ?'OR Name='Chat Resolution Time ?'OR Name='Chat Support Person ?'OR Name='Chat Share with others ?'OR Name='Chat Comments')];
        system.debug('****sqlist'+sqlist);
        
        if(sqlist.size()>0 && !sqlist.isEmpty() && sqlist != null)
        {
            for(survey_question__c sq:sqlist)
            {
                if(sq.ID !=null && sq.Name =='Chat Resolved ?')
                {
                    ChatResolvedID=sq.ID;
                }
                if(sq.ID !=null && sq.Name=='Chat Resolution Time ?')
                {
                    ChatResolutionTime=sq.ID;
                }
                if(sq.ID !=null && sq.Name=='Chat Support Person ?')
                {
                    ChatSupportPerson=sq.ID;
                }
                if(sq.ID !=null && sq.Name=='Chat Share with others ?')
                {
                    ChatSharewithothers=sq.ID;
                }
                if(sq.ID !=null && sq.Name=='Chat Comments')
                {
                    ChatComments=sq.ID;
                }
            }
        }
        system.debug('ChatResolvedID'+ChatResolvedID);
        system.debug('ChatResolutionTime'+ChatResolutionTime);
        system.debug('ChatSupportPerson'+ChatSupportPerson);
        system.debug('ChatSharewithothers'+ChatSharewithothers);
        system.debug('ChatComments'+ChatComments);
        
        List<String> updatelist=new List<String>();
        
        if(LiveChatSurveyList.size()>0 && !LiveChatSurveyList.isEmpty() && 
           LiveChatSurveyList != null && lctlist.size()>0 && !lctlist.isEmpty() && lctlist!= null)
        {
            for(LiveChatTranscript lct:lctlist)
            {
                strSendTo=lct.Owner.Email; // TSR Email ID
                strTranscriptName=lct.Name; // chat Transcript Name
                strSendToName=lct.Owner.Name; // TSR Name
                
                for(Live_Chat_Survey_Answer__c lcs:LiveChatSurveyList)
                {
                    system.debug('lcs'+lcs);
                    if(lcs.Live_Chat_Transcript__c == lct.ID)
                    {
                        if(lcs.Chat_Survey_Question__c == ChatResolvedID)
                        {
                            updatelist.add(lcs.Chat_Survey_Answer__c);
                        }
                        if(lcs.Chat_Survey_Question__c == ChatResolutionTime)
                        {
                            updatelist.add(lcs.Chat_Survey_Answer__c);
                        }
                        if(lcs.Chat_Survey_Question__c == ChatSupportPerson)
                        {
                            updatelist.add(lcs.Chat_Survey_Answer__c);
                        }
                        if(lcs.Chat_Survey_Question__c == ChatSharewithothers)
                        {
                            updatelist.add(lcs.Chat_Survey_Answer__c);
                        }
                        if(lcs.Chat_Survey_Question__c == ChatComments)
                        {
                            updatelist.add(lcs.Chat_Survey_Answer__c);
                        }
                    }
                }
            }
        }
        
        //system.debug('updatelist[0]'+updatelist[0]+'updatelist[1]'+updatelist[1]);
        
        if(!updatelist.isEmpty() && updatelist.size()==5 && updatelist != null && (updatelist[0]=='3 Satisfied'||updatelist[0]=='4 Very Satisfied'))
        {
            OrgWideEmailAddress[] owea = [select Id,Address from OrgWideEmailAddress where Address = 'no.reply@nxp.com'];
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
           
            if ( owea.size() > 0 ) {
    mail.setOrgWideEmailAddressId(owea.get(0).Id);
            }



            String[] toAddresses = new String[] {strSendTo};
                strBody='Dear '+ strSendToName + ',\n\n'
                +'We recently received a customer satisfaction survey response from a customer. \n\n'
                + 'The customers answers were: \n'
                + '\t Resolved :\t\t {'+updatelist[0]+'} \n'
                + '\t Resolution Time :\t {'+updatelist[1]+'} \n'
                + '\t Support Person :\t {'+updatelist[2]+'} \n'
                + '\t Share with others :\t {'+updatelist[3]+'} \n'
                + '\t Comments :\t\t {'+updatelist[4]+'} \n\n'
                + 'Please review the customer comments for any additional inputs or recommendations,' 
                + 'and potential follow-ups on our side (fixing root causes, improving documentation etc.)'
                + '\n\nThank You. \n\n';
            mail.setToAddresses(toAddresses);
           // mail.setSenderDisplayName('NXP Technical Support');
            mail.setSubject('Survey received for chat #: {Live Chat Transcript Name: '+strTranscriptName+'}');
            mail.setPlainTextBody(strBody);
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        }
        
        if(!updatelist.isEmpty() && updatelist.size()==5 && updatelist != null && (updatelist[0]=='1 Very Dissatisfied'||updatelist[0]=='2 Dissatisfied'))
        {
            OrgWideEmailAddress[] owea = [select Id,Address from OrgWideEmailAddress where Address = 'no.reply@nxp.com'];
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                        if ( owea.size() > 0 ) {
    mail.setOrgWideEmailAddressId(owea.get(0).Id);
            }
            String[] toAddresses = new String[] {strSendTo};
                strBody='Dear '+ strSendToName + ',\n\n'
                +'We recently received a customer satisfaction survey response from a customer. \n\n'
                + 'The customers answers were: \n'
                + '\t Resolved :\t\t {'+updatelist[0]+'} \n' 
                + '\t Resolution Time :\t {'+updatelist[1]+'} \n'
                + '\t Support Person :\t {'+updatelist[2]+'} \n'
                + '\t Share with others :\t {'+updatelist[3]+'} \n'
                + '\t Comments :\t\t {'+updatelist[4]+'} \n\n'
                + 'In most cases it is appropriate and expected to follow-up to the customer feedback.\n'
                + 'Please review the case details and customer comments and contact the customer.\n\n'
                + 'When contacting the customer by phone - please remember these things:\n'
                + 'Do\'s and Don\'ts \n'
                + '+ Thank the customers. Tell them how valuable they are and how much we appreciate their feedback.\n'
                + '+ Listen to their concerns, check for understanding, and tell them you are preparing a document to be escalated to the appropriate group or team.\n'
                + '+ Thank them again. This is truly a sincere thank you for their help to improve our products and service.\n'
                + '+ Do stay cool and always thank them for their time.\n'
                + '- Don\'t get defensive. Don\'t argue.\n'
                + '- Don\'t interrupt them when they are talking about the issue.\n'
                + '- Don\'t demand they answer all of your questions.\n'
                + '- Don\'t let their negative attitude affect the way you respond to them.\n'
                + '\n\nThank You. \n\n';
            mail.setToAddresses(toAddresses);
            //mail.setSenderDisplayName('NXP Technical Support');
            mail.setSubject('Dissatisfied Survey received for chat #: {Live Chat Transcript Name: '+strTranscriptName+'}');
            mail.setPlainTextBody(strBody);
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        }
    }
}