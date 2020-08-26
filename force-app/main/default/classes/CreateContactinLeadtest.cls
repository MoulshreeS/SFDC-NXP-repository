/*************************************************************************
@Created By:     Manikanta
@Description:    Test class for CreateContactinLead
**************************************************************************/

@istest
public class CreateContactinLeadtest {
    
     public static final String TEST_USER_PROFILE = 'Standard User';
    public static final String TEST_USER_EMAIL_0 = 'testuser1@testorg.com.test';
    public static final String TEST_USER_EMAIL_1 = 'testuser2@testorg.com.test';
    public static final String TEST_USER_EMAIL_2 = 'testuser3@testorg.com.test';
    public static final String TEST_USER_EMAIL_3 = 'testuser4@testorg.com.test';
    
    
    @testSetup
    static void setup(){
        Profile p = [SELECT Id FROM Profile WHERE Name = :TEST_USER_PROFILE];
        
        // insert a test user
        
        User u = new User(Alias = 'test', Email = TEST_USER_EMAIL_0, 
            EmailEncodingKey = 'UTF-8', LastName = 'Testing', LanguageLocaleKey = 'en_US', 
            LocaleSidKey = 'en_US', TimeZoneSidKey = 'America/Los_Angeles',
            ProfileId = p.Id, UserName = TEST_USER_EMAIL_0);
        insert u;
        
        //Insert Accounts
        Account a = new Account(Name = 'Test Account', Region__c = 'EMEA',OwnerId=u.Id,customer_category__c='Tier 4 - TMMA',
                               NXP_GID__c='12145',country__c='Austria',state_province__c='Test State',Role__c='Distributor');        
        insert a;
        
               //Insert Contact   
        Contact con3 = new Contact(FirstName='Test',LastName='Contact', Title = 'strTitle',
                                  email = TEST_USER_EMAIL_2,AccountId=a.Id,Community_web_country__c = 'testcountry');        
        insert con3;
        
          Lead leadrec = new Lead( LastName = 'TestLead', 
                                company= 'Testcompany', 
                                Job_Description__c = 'Director', Normalized_Title__c ='Consultant',
                                Industry = 'TestIndustry',email = TEST_USER_EMAIL_3,Phone = '12345',HasOptedOutOfEmail = false,DoNotCall =false,city = 'testcity',
                                state='teststate',street='teststreet',PostalCode = '12345',NXP_Global_Customer_Master_ID__c = '12145',RecordTypeId=LeadOwnerAssignmentHandler.AA_LEAD_RECORD_TYPE,Country ='India',Rating = '5',Status = 'Open');  
        insert leadrec;
        
        
    }
    
         @istest
    static  void testgetLeadDetails(){
        Test.startTest();
        Lead l = [select id from Lead limit 1];
        CreateContactinLead.getLeadDetails(l.id);
         Test.stopTest();
    }
    
             @istest
    static  void testgetrecordtype(){
        Test.startTest();
        Lead l = [select id from Lead limit 1];
        CreateContactinLead.getrecordtype(l.id);
         Test.stopTest();
    }
    
       @istest
    static  void testfetchAccountlist(){
     Test.startTest();
        String searchKeyWord = 'Test';
          CreateContactinLead.fetchAccountlist(searchKeyWord);
         Test.stopTest();
    }
    
                 @istest
    static  void testfetchAccountrectype(){
        Test.startTest();
        Lead l = [select id from Lead limit 1];
        CreateContactinLead.fetchAccountrectype(l.id);
         Test.stopTest();
    }
   
                     @istest
    static  void testfetchAccounts(){
        Test.startTest();
       
        CreateContactinLead.fetchAccounts();
         Test.stopTest();
    }
    
            @istest
    static  void testgetcontactemail(){
        Test.startTest();
        Lead l = [select id from Lead limit 1];
        CreateContactinLead.getcontactemail(l.id);
         Test.stopTest();
    }

    
            @istest
    static  void testcreatecontact(){
        Test.startTest();
        Account a = [select id from Account limit 1];
        Lead l = [select ID,firstname,lastname,recordtype.Name,ownerId,Owner.Name,Title,Company,country,state,phone,
                       email,Street,City from Lead];
       
         CreateContactinLead.createcontact(l.FirstName,l.LastName,l.Email,l.Title,
                                          a.Id,l.Country,l.State,l.City,l.Street,l.Country,l.State,l.Phone
                                         );
        
        Contact c = [select id,FirstName,LastName,Email from contact where Email =: l.Email];
        System.assertEquals(l.FirstName, c.FirstName);
        System.assertEquals(l.LastName, c.LastName);
        System.assertEquals(l.Email, c.Email);
       
         Test.stopTest();
        
        
    }
    
          

}