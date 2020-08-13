@IsTest
public class leadhistoryincontacttest {
    
    @IsTest
    static void testgetleadhistorydetails() {
        
        Test.startTest();
        Account acc = new Account(Name='test Account');
        insert acc;
        
        Contact contact1 = new Contact(FirstName='Test',LastName='1',AccountId= acc.id,Email='testsfdc1111@nxp.com',Community_web_country__c = 'testcountry');
        insert contact1;
        
        Lead lead1 = new Lead(Company = 'NXP', LastName = 'Test', Status = 'Open',
                              Email='testsfdc1111@nxp.com', Distributor_Contact__c= contact1.Id);
        insert lead1;
        
        leadhistorycontact.LeadHistoryWrapper lhw = leadhistorycontact.getleadhistorydetails(contact1.Id);
        
        Test.stopTest();
        
        
        
    }
    
}