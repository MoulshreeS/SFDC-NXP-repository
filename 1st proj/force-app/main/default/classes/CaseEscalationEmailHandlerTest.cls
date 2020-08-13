@istest
public class CaseEscalationEmailHandlerTest {
    
   static testMethod void TestinBoundEmail()
   
   {
       //Insert Account
         List<Account> newAccount=CasePortalTestUtil.createTestParentAccount(1);
         insert newAccount;
         System.assert(newAccount[0].Id!=Null);
            
         //Insert Contact 
         List<Contact> contactList =CasePortalTestUtil.createTestContact(1,newAccount[0].Id,'case.contact@customer.com','lstNameTest');
         insert contactList;           
       
       Case objCase = new Case();
       objCase= new Case(Status= 'New',Subject='Test Case',Description='Test case description',contactId = contactList[0].Id ); 
       Insert objCase;   
       List<Case> cases = [select id,casenumber from case ];
       String casenumber=cases.get(0).casenumber;   
       String caseId = cases.get(0).id;
       Messaging.InboundEmail caseEscalationEmail = new Messaging.InboundEmail() ;
       Messaging.Inboundenvelope envelope = new Messaging.Inboundenvelope();
     
       caseEscalationEmail.plainTextBody = 'Case Got escalated';
       caseEscalationEmail.subject = casenumber;
      
       CaseEscalationEmailHandler  testInbound=new CaseEscalationEmailHandler ();
       testInbound.handleInboundEmail(caseEscalationEmail , envelope);
       
       List<FeedItem> caseFeedItems = [SELECT ID, Body from FeedItem where ParentId= :caseId];
       String feedBody = caseFeedItems.get(0).Body;
       System.debug('caseFeedItems --'+feedBody);
       System.assert(feedBody=='Case Escalated :Case Got escalated');
       
   }
}