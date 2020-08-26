//Created by ranganath as a part of SFDC-1607 
@isTest
private class Permissions_Tests_oppty_Contact_object {
    @TestSetup
    static void testSetup(){
        list<User> users = new list<User>();
        Map<String,ID> profiles = new Map<String,ID>();
        List<Profile> ps = [select id, name from Profile where name ='NXP Customer Community Login User' or name = 'NXP Distributor User'];
        
        Account portalAccount1 = new Account(Name = 'TestAccount');
        insert portalAccount1;
        
        list<Contact> cont = new list<Contact>();
        Contact c1 = new Contact(LastName='ABCD',AccountId = portalAccount1.Id,Community_web_country__c = 'India');
        Contact c2 = new Contact(LastName='FEVG',AccountId = portalAccount1.Id,Community_web_country__c = 'India');
         Contact c3 = new Contact(LastName='TEST',Community_web_country__c = 'India');
         Contact c4 = new Contact(LastName='TEST1',Community_web_country__c = 'India');
        cont.add(c1);
        cont.add(c2);  
        cont.add(c3); 
        cont.add(c4);
        insert cont;       
        
        for(Profile p : ps){
            profiles.put(p.name, p.id);
        }
        User U1 = new User(alias = 'standt1', 
                           email='standarduser1235@testorg.com', 
                           emailencodingkey='UTF-8', 
                           lastname='Testing', languagelocalekey='en_US', 
                           localesidkey='en_US', 
                           profileid = profiles.get('NXP Customer Community Login User'), 
                           timezonesidkey='America/Los_Angeles', 
                           username='standarduser1235@testorg.com',
                           ContactId = c1.Id,
                           isactive = true);
        users.add(U1);
        
        User U2 = new User(alias = 'standt', 
                           email='standarduser14878@testorg.com', 
                           emailencodingkey='UTF-8', 
                           lastname='Testing', languagelocalekey='en_US', 
                           localesidkey='en_US', 
                           profileid = profiles.get('NXP Distributor User'), 
                           timezonesidkey='America/Los_Angeles', 
                           username='standarduser14878@testorg.com',
                           ContactId = c2.Id,
                           isactive = true);
        
        users.add(U2);
        
        insert users;
        
        Opportunity opp = new Opportunity(name='ABCD',StageName='Lost',CloseDate=System.now().date());
        insert opp;
    }
    @isTest 
    static void PermissionSetTest_Negative() {
        
        User user1 = [SELECT Id FROM user where alias = 'standt1'];
        User user2 = [SELECT Id FROM user where alias = 'standt'];
        
        System.runAs(user1){
            Opportunity[] oppty;
            oppty = [SELECT Id FROM Opportunity];
            system.assert(oppty.size() == 0, 'a user without the permission set not see any records');
            
            Contact[] cont1;
            cont1 = [SELECT Id,Community_web_country__c FROM Contact WHERE LastName='TEST'];
            system.assert(cont1.size() == 0, 'a user without the permission set not see any records');
        }
        
        System.runAs(user2){
            Opportunity[] oppty;
            oppty = [SELECT Id FROM Opportunity];
            system.assert(oppty.size() == 0, 'a user without the permission set not see any records');
            
             Contact[] cont2;
            cont2 = [SELECT Id FROM Contact WHERE LastName='TEST1'];
            system.assert(cont2.size() == 0, 'a user without the permission set not see any records');
        }
    }
}