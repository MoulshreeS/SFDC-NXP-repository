/******************************************************************************
* Created By: Manikanta
* Created Date : Dec 21,2018
* Description : Created this test class to handle Owner Assignment for Leads.
*******************************************************************************/

@isTest
public class LeadAssignmentBatchTest {
    
    public static final String TEST_USER_PROFILE = 'Standard User';
    public static final String TEST_USER_EMAIL_0 = 'testuser@testorg.com.test';
    public static final String TEST_USER_EMAIL_1 = 'testuser1@testorg.com.test';
    public static final String TEST_USER_EMAIL_2 = 'testuser2@testorg.com.test';
    public static final String TEST_USER_EMAIL_3 = 'testuser3@testorg.com.test';
    public static list<User> listUser=new list<user>();
    
    @testSetup
    static void setup(){
        LeadAssignmentHandler.init();
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
        
        // Insert Exception records
        List<Lead_Assignment_Exception_table__c> listexcep = new List<Lead_Assignment_Exception_table__c>();
        
        listexcep.add(new Lead_Assignment_Exception_table__c(Account_GID__c = '1225',City__c ='Testcity',Country__c = 'USA',
                                                             State__c ='Alaska',
                                                             RecordTypeId = LeadAssignmentHandler.AA_Exception_Record_Type));
        listexcep.add(new Lead_Assignment_Exception_table__c(Account_GID__c = '12145',
                                                             RecordTypeId = LeadAssignmentHandler.TMMA_Exception_Record_Type));
        listexcep.add(new Lead_Assignment_Exception_table__c(Account_GID__c = '151761',City__c ='Testcity',
                                                             Country__c = 'India',State__c ='Andhra Pradesh',
                                                             RecordTypeId = LeadAssignmentHandler.AA_Exception_Record_Type));
        listexcep.add(new Lead_Assignment_Exception_table__c(Account_GID__c = '151498',
                                                             RecordTypeId = LeadAssignmentHandler.TMMA_Exception_Record_Type));
        listexcep.add(new Lead_Assignment_Exception_table__c(Account_GID__c = '183563',
                                                             City__c ='testt',Country__c = 'USA',State__c ='Alabama',
                                                             RecordTypeId = LeadAssignmentHandler.AA_Exception_Record_Type,
                                                             Alternative_Lead_Owner__c = u2.id));
        listexcep.add(new Lead_Assignment_Exception_table__c(Account_GID__c = '345688',City__c ='testt',Country__c = 'USA',
                                                             State__c ='Alabama',
                                                             RecordTypeId = LeadAssignmentHandler.AA_Exception_Record_Type,
                                                             Alternative_Lead_Owner__c = u2.id));
        insert listexcep;
        
        // Insert Lead
        
        list<lead> listLead=new list<lead>();
        DateTime d = System.now().addHours(-3);
        listLead.add(new lead(firstName='Test aa Excep', LastName='Lead', Company='Test Company',RecordTypeId=LeadOwnerAssignmentHandler.UNCATEGORIZED_RECORD_TYPE, 
                              status='Open',country='USA', city='Testcity',state='Alaska',email=TEST_USER_EMAIL_0,NXP_Global_Customer_Master_ID__c = '199345',
                              createdDate=d));
        listLead.add(new lead(firstName='Test ROM', LastName='Lead', Company='Test Company',
                              RecordTypeId=LeadOwnerAssignmentHandler.UNCATEGORIZED_RECORD_TYPE, 
                              status='Open',country='USA', city='Test City',state='Alaska',email=TEST_USER_EMAIL_0,
                              createdDate=d));
         listLead.add(new lead(firstName='Test ROM Zero score', LastName='Lead', Company='Test Company',
                              RecordTypeId=LeadOwnerAssignmentHandler.UNCATEGORIZED_RECORD_TYPE, 
                               NXP_Global_Customer_Master_ID__c = '325436345',
                              status='Open',country='USA', city='Test City',state='Alaska',email=TEST_USER_EMAIL_0,
                              createdDate=d));
        listLead.add(new lead(firstName='Test exactgeoscore', LastName='Lead', Company='Test Company',
                              RecordTypeId=LeadOwnerAssignmentHandler.UNCATEGORIZED_RECORD_TYPE, 
                              status='Open',country='USA', city='Test City',state='Alaska',
                              email=TEST_USER_EMAIL_0,NXP_Global_Customer_Master_ID__c = '101010',
                              createdDate=d));
        listLead.add(new lead(firstName='Test exactgeoscorewithCBG', LastName='Lead', Company='Test Company',
                              RecordTypeId=LeadOwnerAssignmentHandler.UNCATEGORIZED_RECORD_TYPE, 
                              status='Open',country='USA', city='Test City',state='Alaska',
                              email=TEST_USER_EMAIL_0,NXP_Global_Customer_Master_ID__c = '12343245',CBG__c='Automotive',
                              createdDate=d));
        listLead.add(new lead(firstName='Testgeoscore', LastName='Lead', Company='Test Company',
                              RecordTypeId=LeadOwnerAssignmentHandler.UNCATEGORIZED_RECORD_TYPE, 
                              status='Open',country='USA', city='TestCity1',state='Alaska',
                              email=TEST_USER_EMAIL_0,NXP_Global_Customer_Master_ID__c = '888888',
                              createdDate=d));
        listLead.add(new lead(firstName='Test tmma exactscore', LastName='Lead', Company='Test Company',
                              RecordTypeId=LeadOwnerAssignmentHandler.UNCATEGORIZED_RECORD_TYPE, 
                              status='Open',country='China', city='TestCity1',state='Beijing City',
                              email=TEST_USER_EMAIL_0,NXP_Global_Customer_Master_ID__c = '10101010',
                              createdDate=d));
        listLead.add(new lead(firstName='Test Child 6', LastName='Lead', Company='Test Company',
                              RecordTypeId=LeadOwnerAssignmentHandler.UNCATEGORIZED_RECORD_TYPE, 
                              status='Open',country='India', city='TestCity1',state='Andhra Pradesh',
                              email=TEST_USER_EMAIL_0,NXP_Global_Customer_Master_ID__c = '1234567',
                              createdDate=d));
        listLead.add(new lead(firstName='Test Child 10', LastName='Lead', Company='Test Company',
                              RecordTypeId=LeadOwnerAssignmentHandler.UNCATEGORIZED_RECORD_TYPE, 
                              status='Open',country='India', city='TestCity1',state='Andhra Pradesh',
                              email=TEST_USER_EMAIL_0,NXP_Global_Customer_Master_ID__c = '12345627',
                              createdDate=d));
        listLead.add(new lead(firstName='Test Child 8', LastName='Lead', Company='Test Company',
                              RecordTypeId=LeadOwnerAssignmentHandler.UNCATEGORIZED_RECORD_TYPE, 
                              status='Open',country='India', city='TestCity1',state='AP',
                              email=TEST_USER_EMAIL_0,NXP_Global_Customer_Master_ID__c = '8482458',
                              createdDate=d));
        listLead.add(new lead(firstName='Test AA Child 10', LastName='Lead', Company='Test Company',
                              RecordTypeId=LeadOwnerAssignmentHandler.UNCATEGORIZED_RECORD_TYPE, 
                              status='Open',country='India', city='TestCity1',state='Andhra Pradesh',
                              email=TEST_USER_EMAIL_0,NXP_Global_Customer_Master_ID__c = '234456',
                              createdDate=d));
        listLead.add(new lead(firstName='Test AA Child 8', LastName='Lead', Company='Test Company',
                              RecordTypeId=LeadOwnerAssignmentHandler.UNCATEGORIZED_RECORD_TYPE, 
                              status='Open',country='India', city='TestCity1',state='Andhra',
                              email=TEST_USER_EMAIL_0,NXP_Global_Customer_Master_ID__c = '1323545',
                              createdDate=d));
        listLead.add(new lead(firstName='Test AA Child eXCEPTION', LastName='Lead', Company='Test Company',
                              RecordTypeId=LeadOwnerAssignmentHandler.UNCATEGORIZED_RECORD_TYPE, 
                              status='Open',country='India', city='Testcity',state='Andhra Pradesh',
                              email=TEST_USER_EMAIL_0,NXP_Global_Customer_Master_ID__c = '151761',
                              createdDate=d));
        listLead.add(new lead(firstName='Test TMMA Child eXCEPTION', LastName='Lead', Company='Test Company',
                              RecordTypeId=LeadOwnerAssignmentHandler.UNCATEGORIZED_RECORD_TYPE, 
                              status='Open',country='India', city='Testcity',state='Andhra Pradesh',
                              email=TEST_USER_EMAIL_0,NXP_Global_Customer_Master_ID__c = '151498',
                              createdDate=d));
        listLead.add(new lead(firstName='Test  Child ROM', LastName='Lead', Company='Test Company',
                              RecordTypeId=LeadOwnerAssignmentHandler.UNCATEGORIZED_RECORD_TYPE, 
                              status='Open',country='USA', city='testt',state='Alabama',
                              email=TEST_USER_EMAIL_0,NXP_Global_Customer_Master_ID__c = '8456761',
                              createdDate=d));
        listLead.add(new lead(firstName='Test  Inactive Child ROM', LastName='Lead', Company='Test Company',
                              RecordTypeId=LeadOwnerAssignmentHandler.UNCATEGORIZED_RECORD_TYPE, 
                              status='Open',country='USA', city='testt',state='Alabama',
                              email=TEST_USER_EMAIL_0,NXP_Global_Customer_Master_ID__c = '57546754',
                              createdDate=d));
        listLead.add(new lead(firstName='Test  Child Alternative_Lead_Owner', LastName='Lead', 
                              Company='Test Company',RecordTypeId=LeadOwnerAssignmentHandler.UNCATEGORIZED_RECORD_TYPE, 
                              status='Open',country='USA', city='testt',state='Alabama',
                              email=TEST_USER_EMAIL_0,NXP_Global_Customer_Master_ID__c = '183563',
                              createdDate=d));
        listLead.add(new lead(firstName='Test  Parent Alternative_Lead_Owner', LastName='Lead', 
                              Company='Test Company',RecordTypeId=LeadOwnerAssignmentHandler.UNCATEGORIZED_RECORD_TYPE, 
                              status='Open',country='USA', city='testt',state='Alabama',
                              email=TEST_USER_EMAIL_0,NXP_Global_Customer_Master_ID__c = '12356533',
                              createdDate=d));
        
        Insert listlead;
        
        //Insert Account
        
        List<account> listAcc=new list<Account>();
        List<account> listparentAcc=new list<Account>();
        account a3=new Account(Name = 'Test Account', Region__c = 'EMEA',OwnerId=u.Id,customer_category__c='Tier 1',
                               NXP_GID__c='199345',recordTypeId=LeadOwnerAssignmentHandler.PARENT_RECORD_TYPE);
        listparentAcc.add(a3);
        
        account a4=new Account(Name = 'Test exact Account', Region__c = 'EMEA',OwnerId=u.Id,
                               customer_category__c='Tier 1',
                               NXP_GID__c='101010',recordTypeId=LeadOwnerAssignmentHandler.PARENT_RECORD_TYPE);
        
        listparentAcc.add(a4);
        account a5=new Account(Name = 'Test exact Account', Region__c = 'EMEA',OwnerId=u.Id,
                               customer_category__c='Tier 1',
                               NXP_GID__c='888888',recordTypeId=LeadOwnerAssignmentHandler.PARENT_RECORD_TYPE);
        
        listparentAcc.add(a5);
        account a6=new Account(Name = 'Test tmma exact Account', Region__c = 'EMEA',OwnerId=u.Id,
                               customer_category__c='Tier 4 - TMMA',
                               NXP_GID__c='10101010',recordTypeId=LeadOwnerAssignmentHandler.PARENT_RECORD_TYPE);
        
        listparentAcc.add(a6);
        
        account a18=new Account(Name = 'Test tmma exact Account with CBG', Region__c = 'EMEA',OwnerId=u.Id,
                                customer_category__c='Tier 1',
                                NXP_GID__c='12343245',recordTypeId=LeadOwnerAssignmentHandler.PARENT_RECORD_TYPE);
        
        listparentAcc.add(a18);
        
         account a20=new Account(Name = 'Test ROM with Zero Score', Region__c = 'EMEA',OwnerId=u.Id,
                                customer_category__c='Tier 1',
                                NXP_GID__c='325436345',recordTypeId=LeadOwnerAssignmentHandler.PARENT_RECORD_TYPE);
        
        listparentAcc.add(a20);
        
        account a7=new Account(Name = 'Test Child Account', Region__c = 'EMEA',customer_category__c='Tier 4 - TMMA',
                               NXP_GID__c='1234567',recordTypeId=LeadOwnerAssignmentHandler.CHILD_RECORD_TYPE,
                               country__c='India',state_province__c='Andhra Pradesh',City__c = 'Testcity');
        
        listparentAcc.add(a7);
         account a19=new Account(Name = 'Test Inactive Child Account', Region__c = 'EMEA',customer_category__c='Tier 4 - TMMA',
                               NXP_GID__c='57546754',recordTypeId=LeadOwnerAssignmentHandler.CHILD_RECORD_TYPE,
                               country__c='India',state_province__c='Andhra Pradesh',City__c = 'Testcity',IsInactive__c =true);
        
        listparentAcc.add(a19);
        
        account a8=new Account(Name = 'Test Child Account1', Region__c = 'EMEA',customer_category__c='Tier 4 - TMMA',
                               NXP_GID__c='12345627',recordTypeId=LeadOwnerAssignmentHandler.CHILD_RECORD_TYPE,
                               country__c='India',state_province__c='Andhra Pradesh',City__c = 'TestCity1');
        
        listparentAcc.add(a8);
        
        account a9=new Account(Name = 'Test Child Account1', Region__c = 'EMEA',customer_category__c='Tier 4 - TMMA',
                               NXP_GID__c='8482458',recordTypeId=LeadOwnerAssignmentHandler.CHILD_RECORD_TYPE,
                               country__c='India',state_province__c='Andhra Pradesh',City__c = 'TestCity1');
        
        listparentAcc.add(a9);
        account a10 =new Account(Name = 'Test Child Account 10', Region__c = 'EMEA',customer_category__c='Tier 1',
                                 NXP_GID__c='234456',recordTypeId=LeadOwnerAssignmentHandler.CHILD_RECORD_TYPE,
                                 country__c='India',state_province__c='Andhra Pradesh',City__c = 'TestCity1');
        
        listparentAcc.add(a10);
        account a11 =new Account(Name = 'Test Child Account 8', Region__c = 'EMEA',customer_category__c='Tier 1',
                                 NXP_GID__c='1323545',recordTypeId=LeadOwnerAssignmentHandler.CHILD_RECORD_TYPE,
                                 country__c='India',state_province__c='Andhra Pradesh',City__c = 'TestCity1');
        
        listparentAcc.add(a11);
        account a12 =new Account(Name = 'Test AA Child Account Exception', Region__c = 'EMEA',
                                 customer_category__c='Tier 1',
                                 NXP_GID__c='151761',recordTypeId=LeadOwnerAssignmentHandler.CHILD_RECORD_TYPE,
                                 country__c='India',state_province__c='Andhra Pradesh',City__c = 'TestCity1');
        
        listparentAcc.add(a12);
        account a13 =new Account(Name = 'Test TMMA Child Account Exception', Region__c = 'EMEA',
                                 customer_category__c='Tier 4 - TMMA',
                                 NXP_GID__c='151498',recordTypeId=LeadOwnerAssignmentHandler.CHILD_RECORD_TYPE,
                                 country__c='India',state_province__c='Andhra Pradesh',City__c = 'TestCity1');
        
        listparentAcc.add(a13);
        account a14 =new Account(Name = 'Test Child Account ROM', Region__c = 'EMEA',
                                 customer_category__c='Tier 4 - TMMA',
                                 NXP_GID__c='8456761',recordTypeId=LeadOwnerAssignmentHandler.CHILD_RECORD_TYPE,
                                 country__c='India',state_province__c='Andhra Pradesh',City__c = 'TestCity1');
        
        listparentAcc.add(a14);
        
        account a15 =new Account(Name = 'Test Parent Alternative Lead Owner', Region__c = 'EMEA',
                                 customer_category__c='Tier 1',
                                 NXP_GID__c='12356533',recordTypeId=LeadOwnerAssignmentHandler.PARENT_RECORD_TYPE,
                                 country__c='USA',state_province__c='Andhra Pradesh',City__c = 'TestCity1');
        
        listparentAcc.add(a15);
        
        
        
        insert listparentAcc;
        
        listAcc.add(new Account(Name = 'Test Account', Region__c = 'EMEA',OwnerId=u.Id,customer_category__c='Tier 1',
                                ParentId=a3.Id,country__c='USA',state_province__c='Alaska',City__c = 'Testcity',
                                NXP_GID__c = '1225'));
        listAcc.add(new Account(Name = 'Test Account exact', Region__c = 'EMEA',OwnerId=u.Id,customer_category__c='Tier 1',
                                ParentId=a4.Id,country__c='USA',state_province__c='Alaska',City__c = 'Test City',
                                NXP_GID__c = '1226'));
         listAcc.add(new Account(Name = 'Test Account exact', Region__c = 'EMEA',OwnerId=u.Id,customer_category__c='Tier 1',
                                ParentId=a20.Id,country__c='India',state_province__c='Andhra Pradesh',City__c = 'City',
                                NXP_GID__c = '765477'));
        listAcc.add(new Account(Name = 'Test Account exact WITH cbg', Region__c = 'EMEA',OwnerId=u.Id,customer_category__c='Tier 1',
                                ParentId=a18.Id,country__c='USA',state_province__c='Alaska',CMD_Industry_Segment__c='Automotive',
                                City__c = 'Test City',NXP_GID__c = '324634'));
        listAcc.add(new Account(Name = 'Test Account geo', Region__c = 'EMEA',OwnerId=u.Id,customer_category__c='Tier 1',
                                ParentId=a5.Id,country__c='USA',state_province__c='Alaska',City__c = 'Test City',
                                NXP_GID__c = '1227'));
        listAcc.add(new Account(Name = 'Test tmma excep', Region__c = 'EMEA',OwnerId=u.Id,customer_category__c='Tier 4 - TMMA',
                                ParentId=a5.Id,country__c='USA',state_province__c='Alaska',City__c = 'Test City',
                                NXP_GID__c = '12145'));
        listAcc.add(new Account(Name = 'Test tmma exact', Region__c = 'EMEA',OwnerId=u.Id,customer_category__c='Tier 4 - TMMA',
                                ParentId=a6.Id,country__c='China',state_province__c='Beijing City',
                                City__c = 'TestCity1',NXP_GID__c = '123456'));
        listAcc.add(new Account(Name = 'Test Child Alternative Lead Owner', Region__c = 'EMEA',OwnerId=u.Id,
                                customer_category__c='Tier 1',
                                ParentId=a6.Id,country__c='USA',state_province__c='Alabama',
                                City__c = 'testt',NXP_GID__c = '183563'));
        listAcc.add(new Account(Name = 'Test Parent Alternative Lead Owner', Region__c = 'EMEA',OwnerId=u.Id,
                                customer_category__c='Tier 1',
                                ParentId=a15.Id,country__c='USA',state_province__c='Alabama',
                                City__c = 'testt',NXP_GID__c = '345688'));
        Insert listAcc;
        
    }
    
    static testMethod void testassignLeadOwners()
    {
        
        DateTime d = System.now().addHours(-2);
        list<Lead> listLeadUncategorized=[SELECT id,name,NXP_Global_Customer_Master_ID__c,Email,Status,OwnerId,
                                          RecordTypeId,Description,street,city,country,state,company,Industry from Lead
                                          where RecordType.Name='Uncategorized Leads'And createdDate <=:d];
        // LeadAssignmentHandler.assignLeadOwners(listLeadUncategorized);
        
        Test.startTest();
        LeadAssignmentBatch a = new LeadAssignmentBatch();
        DataBase.executeBatch(a);
        
        String CRON_EXP = '0 0 0 3 9 ? 2022';
        String jobId = System.schedule('testBasicScheduledApex', CRON_EXP, new LeadAssignmentBatch());
        Test.stopTest();
        
        Lead tmmachildexceplead  =  [select id,Recordtype.Name,Lead_Owner_Assignment__c from Lead 
                                     where firstName = 'Test TMMA Child eXCEPTION'];
        Account tmmachildaccount  = [select id from Account where Name = 'Test TMMA Child Account Exception'];
        String tmmaLeadownerassg = tmmachildexceplead.Lead_Owner_Assignment__c;
        System.assertEquals(tmmaLeadownerassg, 'Owner is Assigned based on TMMA Exception Table - Account Id : ' + tmmachildaccount.id);
        
        Lead AAchildexceplead  =  [select id,Recordtype.Name,Lead_Owner_Assignment__c from Lead 
                                   where firstName = 'Test AA Child eXCEPTION'];
        Account aachildaccount  = [select id from Account where Name = 'Test AA Child Account Exception'];
        String aaLeadownerassg = AAchildexceplead.Lead_Owner_Assignment__c;
        System.assertEquals(aaLeadownerassg, 'Owner is Assigned based on AA Exception Table - Account Id : ' + aachildaccount.id);
        
    }
}