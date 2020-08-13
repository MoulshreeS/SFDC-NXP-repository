@isTest
public class LiveChatSurveyAnswerHelperTest 
{
    public static final String TEST_USER_PROFILE = 'System Administrator';
    public static final String TEST_USER_EMAIL_0 = 'kumaresh.mohan@nxp.com';
    public static final String TEST_USER_EMAIL_1 = 'kumareshtest.mohan@nxp.com';
    
    public static testmethod void SendEmailtoTSR()
    {
        Profile p = [SELECT Id FROM Profile WHERE Name = :TEST_USER_PROFILE];
        
        User u = new User(Alias = 'test', Email = TEST_USER_EMAIL_0, 
                          EmailEncodingKey = 'UTF-8', LastName = 'Testing', LanguageLocaleKey = 'en_US', 
                          LocaleSidKey = 'en_US', TimeZoneSidKey = 'America/Los_Angeles',
                          ProfileId = p.Id, UserName = TEST_USER_EMAIL_1);
        insert u;
        
        Survey_Question__c sq=new Survey_Question__c();
        sq.Name='Chat Resolved ?';
        insert sq;
        Survey_Question__c sq1=new Survey_Question__c();
        sq1.Name='Chat Resolution Time ?';
        insert sq1;
        Survey_Question__c sq2=new Survey_Question__c();
        sq2.Name='Chat Support Person ?';
        insert sq2;
        Survey_Question__c sq3=new Survey_Question__c();
        sq3.Name='Chat Share with others ?';
        insert sq3;
        Survey_Question__c sq4=new Survey_Question__c();
        sq4.Name='Chat Comments';
        insert sq4;
        
        LiveChatVisitor visitor = new LiveChatVisitor();
        insert visitor;
        
        LiveChatTranscript lct=new LiveChatTranscript();
        lct.LiveChatVisitorId=visitor.id;
        lct.OwnerId=u.id;
        insert lct;
        
        LiveChatTranscript lct1=new LiveChatTranscript();
        lct1.LiveChatVisitorId=visitor.id;
        lct1.OwnerId=u.id;
        insert lct1;
        
        
        LiveChatTranscript l=[select Id,Name,Owner.Email from LiveChatTranscript where id=:lct1.Id];
        string strSendTo=l.owner.email;
        
        List<Live_Chat_Survey_Answer__c> lcs=new  List<Live_Chat_Survey_Answer__c>();
        lcs.add(new Live_Chat_Survey_Answer__c(
            ChatKey__c='fc8e2970-4aa3-413e-afea-bf57f1028f64',
            Chat_Survey_Answer__c='3 Satisfied', 
            Chat_Survey_Question__c=sq.Id));
        lcs.add(new Live_Chat_Survey_Answer__c(
            ChatKey__c='fc8e2970-4aa3-413e-afea-bf57f1028f64',
            Chat_Survey_Answer__c='3 Satisfied', 
            Chat_Survey_Question__c=sq1.Id));
        lcs.add(new Live_Chat_Survey_Answer__c(
            ChatKey__c='fc8e2970-4aa3-413e-afea-bf57f1028f64',
            Chat_Survey_Answer__c='3 Satisfied', 
            Chat_Survey_Question__c=sq2.Id));
        lcs.add(new Live_Chat_Survey_Answer__c(
            ChatKey__c='fc8e2970-4aa3-413e-afea-bf57f1028f64',
            Chat_Survey_Answer__c='3 Satisfied', 
            Chat_Survey_Question__c=sq3.Id));
        lcs.add(new Live_Chat_Survey_Answer__c(
            ChatKey__c='fc8e2970-4aa3-413e-afea-bf57f1028f64',
            Chat_Survey_Answer__c='3 Satisfied', 
            Chat_Survey_Question__c=sq4.Id));
        insert lcs;
        
        List<Live_Chat_Survey_Answer__c> lccs=new  List<Live_Chat_Survey_Answer__c>();
        
        for(Live_Chat_Survey_Answer__c l1:lcs)
        {
            if(l1.Chat_Survey_Question__c==sq.Id)
            {
                l1.Live_Chat_Transcript__c=lct.id;
            }
            else if(l1.Chat_Survey_Question__c==sq1.Id)
            {
                l1.Live_Chat_Transcript__c=lct.id;
            }
            else if(l1.Chat_Survey_Question__c==sq2.Id)
            {
                l1.Live_Chat_Transcript__c=lct.id;
            }
            else if(l1.Chat_Survey_Question__c==sq3.Id)
            {
                l1.Live_Chat_Transcript__c=lct.id;
            }
            else if(l1.Chat_Survey_Question__c==sq4.Id)
            {
                l1.Live_Chat_Transcript__c=lct.id;
            }
            lccs.add(l1);
        }
        update lccs;
        
        List<Live_Chat_Survey_Answer__c> lcs1=new  List<Live_Chat_Survey_Answer__c>();
        lcs1.add(new Live_Chat_Survey_Answer__c(
            ChatKey__c='fc8e2970-4aa3-413e-afea-bf57f1028f89',
            Chat_Survey_Answer__c='1 Very Dissatisfied', 
            Chat_Survey_Question__c=sq.Id));
        lcs1.add(new Live_Chat_Survey_Answer__c(
            ChatKey__c='fc8e2970-4aa3-413e-afea-bf57f1028f89',
            Chat_Survey_Answer__c='1 Very Dissatisfied', 
            Chat_Survey_Question__c=sq1.Id));
        lcs1.add(new Live_Chat_Survey_Answer__c(
            ChatKey__c='fc8e2970-4aa3-413e-afea-bf57f1028f89',
            Chat_Survey_Answer__c='1 Very Dissatisfied', 
            Chat_Survey_Question__c=sq2.Id));
        lcs1.add(new Live_Chat_Survey_Answer__c(
            ChatKey__c='fc8e2970-4aa3-413e-afea-bf57f1028f89',
            Chat_Survey_Answer__c='1 Very Dissatisfied', 
            Chat_Survey_Question__c=sq3.Id));
        lcs1.add(new Live_Chat_Survey_Answer__c(
            ChatKey__c='fc8e2970-4aa3-413e-afea-bf57f1028f89',
            Chat_Survey_Answer__c='1 Very Dissatisfied', 
            Chat_Survey_Question__c=sq4.Id));
        insert lcs1;
        
        List<Live_Chat_Survey_Answer__c> lccs1=new  List<Live_Chat_Survey_Answer__c>();
        
        for(Live_Chat_Survey_Answer__c l2:lcs1)
        {
            if(l2.Chat_Survey_Question__c==sq.Id)
            {
                l2.Live_Chat_Transcript__c=lct1.id;
            }
            else if(l2.Chat_Survey_Question__c==sq1.Id)
            {
                l2.Live_Chat_Transcript__c=lct1.id;
            }
            else if(l2.Chat_Survey_Question__c==sq2.Id)
            {
                l2.Live_Chat_Transcript__c=lct1.id;
            }
            else if(l2.Chat_Survey_Question__c==sq3.Id)
            {
                l2.Live_Chat_Transcript__c=lct1.id;
            }
            else if(l2.Chat_Survey_Question__c==sq4.Id)
            {
                l2.Live_Chat_Transcript__c=lct1.id;
            }
            lccs1.add(l2);
        }
        update lccs1;
        
        set<id> tcid=new set<ID>();
        set<id> tcid1=new set<ID>();
        for(Live_Chat_Survey_Answer__c lc:lccs)
        {
            tcid.add(lc.id);
        }
        for(Live_Chat_Survey_Answer__c lc1:lccs1)
        {
            tcid1.add(lc1.id);
        }
        
        
        test.starttest();
        LiveChatSurveyAnswerHelper.SendEmailtoTSR(tcid);
        LiveChatSurveyAnswerHelper.SendEmailtoTSR(tcid1);
        test.stoptest();
        
        system.assertEquals('kumaresh.mohan@nxp.com',strSendTo); 
    }
}