@istest
public class leadhistorytranscriptstest {
    
     static  testmethod void testgetleadhistorydetails() {
        
        Test.startTest();
         
       
        
            Account acc = new Account(Name='test Account');
        insert acc;
        
        Contact contact1 = new Contact(FirstName='Test',LastName='1',AccountId= acc.id,Email='testsfdc1211@nxp.com',Community_web_country__c = 'testcountry');
        insert contact1;
      
          LiveChatVisitor visitor = new LiveChatVisitor();
        insert visitor;
        
        LiveChatTranscript lct=new LiveChatTranscript();
        lct.LiveChatVisitorId=visitor.id;
        lct.Email__c = 'testsfdc1211@nxp.com';
         insert lct;
        
        
        Lead lead1 = new Lead(Company = 'NXP', LastName = 'Test', Status = 'Open',
                              Email='testsfdc1211@nxp.com', Distributor_Contact__c= contact1.Id);
        insert lead1;
        
        leadhistorytranscripts.LeadHistoryWrapper lhw = leadhistorytranscripts.getleadhistorydetails(lct.Id);
        
        Test.stopTest();
        
        
        
    }

}