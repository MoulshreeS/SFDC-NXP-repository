@isTest
public class TestPreChatCheckController {
    @testsetup
    static void createData(){
        Account accDef = new Account(Name='NXP Community');
        Account accNorm = new Account(Name='Some Test Company');
        List<Account> testAccs = new List<Account>{accDef,accNorm};
        insert testAccs;
        accNorm = [SELECT Id,Name from Account where Name='Some Test Company'];
        Contact cont = new Contact(FirstName='Test',LastName='Name',Email='test.name@somecompany.com',Community_web_country__c='India',AccountId=accNorm.Id);
        insert cont;        
    }
    
    @isTest
    public static void checkForExistingContact(){
        String conid= PreChatCheckController.findOrCreateContactForLoggedInUser('test.name@somecompany.com','Test','Name','India','Company');
        System.assert(conid!=null);
    }
    
    @isTest
    public static void createNewContactNoCountry(){
        String conid= PreChatCheckController.findOrCreateContactForLoggedInUser('test.name@no-one.com','Test','Name',null,'Company');
        System.assert(conid!=null);
    }
    
    @isTest
    public static void createNewContactWithCountry(){
        String conid= PreChatCheckController.findOrCreateContactForLoggedInUser('test.name@no-one.com','Test','Name','India','Company');
        System.assert(conid!=null);
    }
}