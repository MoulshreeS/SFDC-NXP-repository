@IsTest
public class leadhistorycasestest {
    
  
    static  testmethod void testgetleadhistorydetails() {
        
        Test.startTest();
        
            Account acc = new Account(Name='test Account');
        insert acc;
        
        Contact contact1 = new Contact(FirstName='Test',LastName='1',AccountId= acc.id,Email='testsfdc1211@nxp.com',Community_web_country__c = 'testcountry');
        insert contact1;
      
        Case Casenew = new case(Status= 'New', Priority = 'Medium',  Subject = 'test_subject', Description = 'test_subject',
                                SuppliedEmail ='testsfdc1211@nxp.com',contactId=contact1.id);
        insert Casenew;
        
        Lead lead1 = new Lead(Company = 'NXP', LastName = 'Test', Status = 'Open',
                              Email='testsfdc1211@nxp.com', Distributor_Contact__c= contact1.Id);
        insert lead1;
        
        LeadHistorycases.LeadHistoryWrapper lhw = LeadHistorycases.getleadhistorydetails(Casenew.Id);
        
        Test.stopTest();
        
        
        
    }

}