/******************************************************************************
* Created By: Moulshree
* Created Date : Mar 24,2020
* Description : Test class for distiBranchNameUpdate batch class
*******************************************************************************/

@isTest
public class distiBranchNameUpdateTest {
    
    public static final String TEST_USER_PROFILE = 'Standard User';
    public static final String TEST_USER_EMAIL_0 = 'testuser@testorg.com.test';
    public static final String TEST_USER_EMAIL_1 = 'testuser1@testorg.com.test';
    public static final String TEST_USER_EMAIL_2 = 'testuser2@testorg.com.test';
    public static final String TEST_USER_EMAIL_3 = 'testuser3@testorg.com.test';
    public static list<User> listUser=new list<user>();
    public static list<contact> listContact=new list<contact>();
    @testSetup
    static void setup(){
        
        Profile p = [SELECT Id FROM Profile WHERE Name = :TEST_USER_PROFILE];
        
        User u = new User(Alias = 'test', Email = TEST_USER_EMAIL_0, 
                          EmailEncodingKey = 'UTF-8', LastName = 'Testing', LanguageLocaleKey = 'en_US', 
                          LocaleSidKey = 'en_US', TimeZoneSidKey = 'America/Los_Angeles',
                          ProfileId = p.Id, UserName = TEST_USER_EMAIL_0);
        listUser.add(u);
        
        User u2 = new User(Alias = 'test1', Email = TEST_USER_EMAIL_1, 
                           EmailEncodingKey = 'UTF-8', LastName = 'Testing', LanguageLocaleKey = 'en_US', 
                           LocaleSidKey = 'en_US', TimeZoneSidKey = 'America/Los_Angeles',
                           ProfileId = p.Id, UserName = TEST_USER_EMAIL_1);
        listUser.add(u2);
        
        insert listUser;
        
        // Insert  accounts
        List<account> listAcc=new list<Account>();
        listAcc.add(new Account(Name = 'Test Account', Region__c = 'EMEA',OwnerId=u.Id,customer_category__c='Tier 4 - TMMA',
                               NXP_GID__c='12145',country__c='Test Country',state_province__c='Test State'));                
        insert listAcc;
        
        // Insert contacts
         
        listContact.add(new Contact(FirstName='Test',LastName='Contact',  Title = 'strTitle',
                                  email = TEST_USER_EMAIL_0,AccountId=listAcc[0].Id,Community_web_country__c = 'testcountry'));                
        listContact.add(new Contact(FirstName='Test1',LastName='Contact1',  Title = 'strTitle',
                                  email = TEST_USER_EMAIL_1,AccountId=listAcc[0].Id,Community_web_country__c = 'testcountry'));                
        listContact.add(new Contact(FirstName='Test1',LastName='Contact2',  Title = 'strTitle',
                                  email = TEST_USER_EMAIL_2,AccountId=listAcc[0].Id,Community_web_country__c = 'testcountry'));       
        insert listContact;  
              
        // Insert Lead
        
        list<lead> listLead=new list<lead>();
        DateTime d = System.now().addHours(-3);
        for(Integer i = 0; i < 100; i++){
        listLead.add(new lead(firstName='Test ' + i, LastName='Lead', Company='Test Company',RecordTypeId=LeadOwnerAssignmentHandler.ROM_LEAD_RECORD_TYPE, 
                              status='Open',country='USA', city='Testcity',state='Alaska',email=TEST_USER_EMAIL_0,NXP_Global_Customer_Master_ID__c = '199345',
                              createdDate=d,distributor_contact__c = listContact[0].Id ));
        listLead.add(new lead(firstName='Test Rom ' + i, LastName='Lead', Company='Test Company',
                              RecordTypeId=LeadOwnerAssignmentHandler.ROM_LEAD_RECORD_TYPE, 
                              status='Open',country='USA', city='Test City',state='Alaska',email=TEST_USER_EMAIL_0,
                              createdDate=d,distributor_contact__c = listContact[0].Id));
        listLead.add(new lead(firstName='Test T ROM ' + i, LastName='Lead', Company='Test Company',
                              RecordTypeId=LeadOwnerAssignmentHandler.ROM_LEAD_RECORD_TYPE, 
                               NXP_Global_Customer_Master_ID__c = '325436345',
                              status='Open',country='USA', city='Test City',state='Alaska',email=TEST_USER_EMAIL_0,
                              createdDate=d,distributor_contact__c = listContact[1].Id));
        
        } 
        Insert listlead;
        
        // Insert Disti Branches
        List<Disti_Branches__c> listDistiBranch = new List<Disti_Branches__c>();
        listDistiBranch.add(new Disti_Branches__c(Name = 'Branch1'));
        listDistiBranch.add(new Disti_Branches__c(Name = 'Branch2'));
        listDistiBranch.add(new Disti_Branches__c(Name = 'Branch3'));
        insert listDistiBranch;
        
        // Insert Distributor Branch Contact Roles
        List<Disti_Branch_Contact_Role__c> listDistiBranchConRole = new List<Disti_Branch_Contact_Role__c>();
        listDistiBranchConRole.add(new Disti_Branch_Contact_Role__c(Contact__c = listContact[0].Id, Contact_Role__c = 'Main Distributor Contact', Disti_Branch__c=listDistiBranch[0].Id));
        //listDistiBranchConRole.add(new Disti_Branch_Contact_Role__c(Contact__c = listContact[1].Id, Contact_Role__c = 'Additional Contact', Disti_Branch__c=listDistiBranch[0].Id));
        listDistiBranchConRole.add(new Disti_Branch_Contact_Role__c(Contact__c = listContact[0].Id, Contact_Role__c = 'Additional Contact', Disti_Branch__c=listDistiBranch[1].Id));
        listDistiBranchConRole.add(new Disti_Branch_Contact_Role__c(Contact__c = listContact[1].Id, Contact_Role__c = 'Additional Contact', Disti_Branch__c=listDistiBranch[1].Id));
        insert listDistiBranchConRole;
        
    }
    
    static testMethod void testInsertConactRole()
    {
        Test.startTest();
        distiBranchNameUpdate.recordNumber = 1;
        List<Disti_Branch_Contact_Role__c> listDBCR = [Select Contact__c, Contact_Role__c from Disti_Branch_Contact_Role__c where  Disti_Branch__r.name = 'Branch1'];
        listDBCR[0].Contact_Role__c = 'Additional Contact';
        update listDBCR;
        distiBranchNameUpdate a = new distiBranchNameUpdate();
        DataBase.executeBatch(a);
        
        Test.stopTest();
      
    }
    
        static testMethod void testNegativeCase()
    {
        Test.startTest();
        distiBranchNameUpdate.recordNumber = 0;
        List<Disti_Branch_Contact_Role__c> listDBCR = [Select Contact__c, Contact_Role__c from Disti_Branch_Contact_Role__c where  Disti_Branch__r.name = 'Branch1'];
        listDBCR[0].Contact_Role__c = 'Additional Contact';
        update listDBCR;
        distiBranchNameUpdate a = new distiBranchNameUpdate();
        DataBase.executeBatch(a);
        
        Test.stopTest();
      
    }
}