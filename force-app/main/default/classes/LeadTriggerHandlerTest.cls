/*************************************************************************
@Created By:     Jewelslyn
@Description:    Test class for Lead trigger Handler.
**************************************************************************/

@isTest
public class LeadTriggerHandlerTest {

    public static final String TEST_USER_PROFILE = 'Standard User';
    public static final String TEST_USER_EMAIL_0 = 'testuser@testorg.com.test';
    public static final String TEST_USER_EMAIL_1 = 'testuser1@testorg.com.test';
    public static final String TEST_USER_EMAIL_2 = 'testuser2@testorg.com.test';
    public static final String TEST_USER_EMAIL_3 = 'testuser3@testorg.com.test';
    public static final String TEST_USER_EMAIL_4 = 'testuser4@testorg.com.test';
    
    public static list<User> listUser=new list<user>();
    public static list<contact> listContact=new list<contact>();
    
     @testSetup
    static void setup(){
        map<id,string> mapUserName=new map<id,String>();
        LeadOwnerAssignmentHandler.init();
        List<LeadCountrySettings__c> leadCountrySettings = new list<LeadCountrySettings__c>();
        leadCountrySettings.add(new LeadCountrySettings__c(country_Code__c='TCN', Country__c='Test Country',Name='TestCountry',
                                                          Region__c='EMEA'));
        leadCountrySettings.add(new LeadCountrySettings__c(State_Code__c='TST', State__c='Test State',Name='TestState',
                                                          Region__c='EMEA'));
        leadCountrySettings.add(new LeadCountrySettings__c(State_Code__c='TSN', State__c='Test State1',Name='TestState1',
                                                          Region__c='EMEA'));
        leadCountrySettings.add(new LeadCountrySettings__c(country_Code__c='TCT', Country__c='Test Country1',Name='TestCountry1',
                                                          Region__c='EMEA'));
        //leadCountrySettings.add(new LeadCountrySettings__c(Name='NovaSilva',NovaSilva_Email__c='test@test1.com'));
        insert leadCountrySettings;
        
        Profile p = [SELECT Id FROM Profile WHERE Name = :TEST_USER_PROFILE];
        
        // insert a test user
        
        User u = new User(Alias = 'test', Email = TEST_USER_EMAIL_0, 
            EmailEncodingKey = 'UTF-8', LastName = 'Testing', LanguageLocaleKey = 'en_US', 
            LocaleSidKey = 'en_US', TimeZoneSidKey = 'America/Los_Angeles',
            ProfileId = p.Id, UserName = TEST_USER_EMAIL_0,User_Region__c = 'Greater China',User_Sub_Region__c ='GC MMkt - Taiwan MM');
        listUser.add(u);
        User u2 = new User(Alias = 'test1', Email = TEST_USER_EMAIL_1, 
            EmailEncodingKey = 'UTF-8', LastName = 'Testing', LanguageLocaleKey = 'en_US', 
            LocaleSidKey = 'en_US', TimeZoneSidKey = 'America/Los_Angeles',
            ProfileId = p.Id, UserName = TEST_USER_EMAIL_1,User_Region__c = 'Greater China',User_Sub_Region__c ='GC MMkt - Taiwan MM');
        listUser.add(u2);
        insert listUser;
        
        //parent accnt
        List<account> listparentAcc=new list<Account>();
        account a3=new Account(Name = 'Test Parent Account1', Region__c = 'EMEA',OwnerId=u.Id,customer_category__c='Tier 1',
                                NXP_GID__c='12045',recordTypeId=LeadOwnerAssignmentHandler.PARENT_RECORD_TYPE);
        account a4=new Account(Name = 'Test Parent Account2', Region__c = 'EMEA',OwnerId=u.Id,customer_category__c='Tier 1',
                                NXP_GID__c='12045',recordTypeId=LeadOwnerAssignmentHandler.PARENT_RECORD_TYPE);        
        listparentAcc.add(a3);
        listparentAcc.add(a4);
        insert listparentAcc; 
        
        //child account
        List<account> listChildAcc=new list<Account>();
        account a5=new Account(Name = 'Test Child Account1', Region__c = 'EMEA',OwnerId=u.Id,customer_category__c='Tier 1',
                                NXP_GID__c='12045',parentId= listparentAcc[0].Id);
        account a6=new Account(Name = 'Test Child Account2', Region__c = 'EMEA',OwnerId=u.Id,customer_category__c='Tier 1',
                                NXP_GID__c='12045',parentId= a4.Id);
        listChildAcc.add(a5);
        listChildAcc.add(a6);
        insert listChildAcc;
        
        // Insert  accounts
        List<account> listAcc=new list<Account>();
        listAcc.add(new Account(Name = 'Test Account', Region__c = 'EMEA',OwnerId=u.Id,customer_category__c='Tier 4 - TMMA',
                               NXP_GID__c='12145',country__c='Test Country',state_province__c='Test State'));                
        listAcc.add(new Account(Name = 'Test Account', Region__c = 'EMEA',OwnerId=u.Id,customer_category__c='Tier 4 - ROM',
                                NXP_GID__c='12345',country__c='Test Country',state_province__c='Test State'));                
        listAcc.add(new Account(Name = 'Test Account', Region__c = 'EMEA',OwnerId=u.Id,customer_category__c='Tier 1',
                                NXP_GID__c='12245')); 
        insert listAcc;
        
        //Insert Contact
         contact c1 = new Contact(FirstName='Test',LastName=' child Contact',  Title = 'strTitle',
                                  AccountId=listChildAcc[1].Id,Community_web_country__c = 'testcountry');
         insert c1;
         //contact con2 = new Contact(FirstName='Test2',LastName='Contact2',  Title = 'strTitle',
                                   //accountId = listChildAcc[0].Id,Community_web_country__c = 'India');
         //insert con2;
        // Insert contacts
        
        for(account a:listAcc){
            listContact.add(new Contact(FirstName='Test',LastName='Contact',  Title = 'strTitle',
                                  email = TEST_USER_EMAIL_0,AccountId=a.Id,Community_web_country__c = 'testcountry'));                
            listContact.add(new Contact(FirstName='Test1',LastName='Contact1',  Title = 'strTitle',
                                  email = TEST_USER_EMAIL_1,AccountId=a.Id,Community_web_country__c = 'testcountry'));                
            //listContact.add(new Contact(FirstName='Test2',LastName='Contact2',  Title = 'strTitle',
                                  //email = TEST_USER_EMAIL_2,AccountId=a.Id));
        }                
        insert listContact;
        
        //Insert Leads
        list<lead> listLead=new list<lead>();
        listLead.add(new lead(OwnerId=listUser[0].Id,FirstName='Test',LastName='Lead', Company='Test company',RecordTypeId=LeadOwnerAssignmentHandler.UNCATEGORIZED_RECORD_TYPE, 
                              status='Open',country='TCN', state='TST',email=TEST_USER_EMAIL_3));
        listLead.add(new lead(OwnerId=listUser[1].Id,FirstName='Test',LastName='Lead', Company='Test company',RecordTypeId=LeadOwnerAssignmentHandler.UNCATEGORIZED_RECORD_TYPE, 
                              status='Open',country='TUP', state='TUS',email=TEST_USER_EMAIL_2,
                             distributor_contact__c=listContact[0].Id));
        listLead.add(new lead(OwnerId=listUser[0].Id,FirstName='Test',LastName='Lead', Company='Test company',RecordTypeId=LeadOwnerAssignmentHandler.UNCATEGORIZED_RECORD_TYPE, 
                              status='Accepted by Disti',country='TUP', state='TUS',email=TEST_USER_EMAIL_1,
                             distributor_contact__c=listContact[0].Id));
        listLead.add(new lead(FirstName='Test',LastName='Lead', Company='Test company',RecordTypeId=LeadOwnerAssignmentHandler.UNCATEGORIZED_RECORD_TYPE, 
                              status='Accepted by Disti',country='TUP', state='TUS',email=TEST_USER_EMAIL_4
                             ));
        listLead.add(new lead(FirstName='Test',LastName='Lead', Company='Test company',RecordTypeId=LeadOwnerAssignmentHandler.ROM_LEAD_RECORD_TYPE, 
                              status='open',country='TUP', state='TUS',email=TEST_USER_EMAIL_0));
        //SFDC-3724
        listLead.add(new lead(FirstName='Test',LastName='Lead1', Company='Test company',RecordTypeId=LeadOwnerAssignmentHandler.TMMA_LEAD_RECORD_TYPE, 
                              status='open',country='TUP', state='TUS',email=TEST_USER_EMAIL_0,distributor_contact__c=listContact[0].Id )
                              );
        listLead.add(new lead(FirstName='Test',LastName='Lead2', Company='Test company',RecordTypeId=LeadOwnerAssignmentHandler.TMMA_LEAD_RECORD_TYPE, 
                              status='open',country='TUP', state='TUS',email=TEST_USER_EMAIL_0,distributor_contact__c=listContact[1].Id )
                              ); 
        listLead.add(new lead(FirstName='Test',LastName='Lead3', Company='Test company',RecordTypeId=LeadOwnerAssignmentHandler.TMMA_LEAD_RECORD_TYPE, 
                              status='open',country='TUP', state='TUS',email=TEST_USER_EMAIL_0,distributor_contact__c=c1.Id )
                              );                                           
        insert listLead;
        
        List<Disti_Branches__c> listDistiBranch = new List<Disti_Branches__c>();
        listDistiBranch.add(new Disti_Branches__c(Name = 'Branch1'));
        listDistiBranch.add(new Disti_Branches__c(Name = 'Branch2'));
        insert listDistiBranch;
        
        List<Disti_Branch_Contact_Role__c> listDistiBranchConRole = new List<Disti_Branch_Contact_Role__c>();
        listDistiBranchConRole.add(new Disti_Branch_Contact_Role__c(Contact__c = listContact[0].Id, Contact_Role__c = 'Main Distributor Contact', Disti_Branch__c=listDistiBranch[0].Id));
        listDistiBranchConRole.add(new Disti_Branch_Contact_Role__c(Contact__c = listContact[1].Id, Contact_Role__c = 'Additional Contact', Disti_Branch__c=listDistiBranch[0].Id));
        listDistiBranchConRole.add(new Disti_Branch_Contact_Role__c(Contact__c = listContact[0].Id, Contact_Role__c = 'Additional Contact', Disti_Branch__c=listDistiBranch[1].Id));
        listDistiBranchConRole.add(new Disti_Branch_Contact_Role__c(Contact__c = listContact[1].Id, Contact_Role__c = 'Additional Contact', Disti_Branch__c=listDistiBranch[1].Id));
        insert listDistiBranchConRole;
    }
    @isTest
    static void testCountrymapping(){
        Test.starttest();
        list<lead> countryUpLead=[SELECT id,name,NXP_Global_Customer_Master_ID__c,Email,Status,OwnerId,
                                          RecordTypeId,Description,street,city,country,state,company from Lead
                                          where RecordType.Name='Uncategorized Leads'];
        
        for(lead ld:countryUpLead){
            ld.country='TCT';
        }
        update countryUpLead;
        Test.stopTest();
        
    }
    //added by ranganath As a part of SFDC-2126
    @isTest
    static void testusersubregionupdate(){
        Test.starttest();
        List<user> usersubregion =[select Id,name,User_Sub_Region__c from user where User_Sub_Region__c !=null];
        List<lead> leadtobeupdate=[SELECT id,name,NXP_Global_Customer_Master_ID__c,Email,Status,OwnerId,
                                          RecordTypeId,Description,street,city,country,state,company,User_Sub_Region__c  from Lead
                                          where RecordType.Name='Uncategorized Leads'];
       for(Lead l:leadtobeupdate){
           for(User u:usersubregion ){
              l.ownerId = u.Id;      
              l.User_Sub_Region__c  = u.User_Sub_Region__c;
           } 
       }
       update leadtobeupdate;
       Test.stopTest();
   }
    
    @isTest
    static void testRandomNumberGen(){
        Test.starttest();
        lead ranNumGenLead=[SELECT id,name,NXP_Global_Customer_Master_ID__c,Email,Status,OwnerId,
                                          RecordTypeId,Description,street,city,country,state,company from Lead
                                          where name = 'Test Lead3'];
        //List<contact> conList = [select id,name from contact where name = 'Test2 Contact2'];
        List<account> accList = [select id from account where name = 'Test Child Account1'];
        contact con=new Contact(FirstName='Test2',LastName='Contact2',  Title = 'strTitle',
                                  accountId = accList[0].Id,Community_web_country__c = 'India');        
        insert con;
        system.assertEquals(con.LastName,'Contact2');
        system.assertEquals(con.accountId,accList[0].Id);
        ranNumGenLead.distributor_contact__c=con.Id;                    
        update ranNumGenLead;
        Test.stopTest();        
    }
    @isTest
    static void testUpdtDistCon(){
        Test.starttest();
        
        lead updtDistCon=[SELECT id,name,NXP_Global_Customer_Master_ID__c,Email,Status,OwnerId,
                                          RecordTypeId,Description,street,city,country,state,company,
                                          Disti_Feedback_Email_Address__c from Lead                            
                                          where email=:TEST_USER_EMAIL_1];               
        updtDistCon.Disti_Feedback_Email_Address__c=TEST_USER_EMAIL_2;                    
        update updtDistCon;
        Test.stopTest();        
    }
    @isTest
    static void testinsertContactRole(){
        lead ldConvert=[SELECT id,name,NXP_Global_Customer_Master_ID__c,Email,Status,OwnerId,
                                          RecordTypeId,Description,street,city,country,state,company,
                                          Disti_Feedback_Email_Address__c from Lead                            
                                          where email=:TEST_USER_EMAIL_4];
        String convertedStatus = [SELECT MasterLabel FROM LeadStatus WHERE IsConverted = TRUE LIMIT 1].MasterLabel;
        contact con=new Contact(FirstName='Test2',LastName='Contact2',  Title = 'strTitle',
                                  email = TEST_USER_EMAIL_4,Community_web_country__c = 'testcountry');
        System.assertEquals(con.FirstName,'Test2');

        Database.LeadConvert lc = new database.LeadConvert();
        lc.setLeadId(ldConvert.id);
        lc.setContactId(con.Id);
        lc.setDoNotCreateOpportunity(false);
        lc.setConvertedStatus(convertedStatus);

        Database.LeadConvertResult lcr = Database.convertLead(lc);
        System.assert(lcr.isSuccess());
            
    }
     @isTest
    static void testemailToMultipleDistis(){
        Test.starttest();
        lead ldToDistis=[SELECT id,name,NXP_Global_Customer_Master_ID__c,Email,Status,OwnerId,
                                          RecordTypeId,Description,street,city,country,state,company,
                                          Disti_Feedback_Email_Address__c,CC_Address__c,Note_To_Disti__c from Lead                            
                                          where status='open' and RecordTypeId=:LeadOwnerAssignmentHandler.ROM_LEAD_RECORD_TYPE];
        contact con=new Contact(FirstName='Test2',LastName='Contact2',  Title = 'strTitle',
                                  email = TEST_USER_EMAIL_2,Community_web_country__c = 'testcountry');
        insert Con;        
        ldToDistis.Distributor_Contact__c=con.Id;
        ldToDistis.CC_Address__c=TEST_USER_EMAIL_0;
        ldToDistis.Note_To_Disti__c='Test';
        try{
            update ldToDistis;
        }
        catch(exception e){}
        Test.stopTest(); 
    }
    
    @isTest
    static void insertleadtoopty()
    {
        Account pa=new Account();
       pa.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Parent Account').getRecordTypeId(); 
       pa.Name = 'Test Parent Account';
        
       insert pa;
       
       Account ac=new Account();
       ac.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Child Account').getRecordTypeId();
       ac.Name = 'Test Child Account';
       ac.Region__c = 'Americas';
       ac.ParentId = pa.Id;
       ac.country__c='Akrotiri And Dhekelia';
        
       insert ac;
       
       Opportunity op= new Opportunity();
       op.Name='Test 2785';
       op.AccountId=ac.Id;
       op.StageName='Initial Engagement';
       op.Industry_Segment__c='Automotive';
       op.CloseDate=System.today();
       op.Sub_Segment__c='Body & Convenience';
       op.Application__c='';
       op.Channel__c = 'Direct';
       op.Executive_Summary__c='Test Summary 2785';
        
       insert op;
        
       Lead le=new Lead();
       le.RecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Assigned Account Leads').getRecordTypeId();
       le.LastName='Test';
       le.Company='Test Company';
       le.Status='Accepted by Disti';
       le.Email='arosan.kumas@gmail.com';
        
       
       insert le;
        
       Contact co=new Contact();
       co.LastName='Test Contact';
       co.AccountID=ac.Id;
       co.Email='arosan.kumas@gmail.com';
       co.Community_web_country__c='Azerbaijan';
       co.Contact_Service_Level__c='A1_Test';
       
       insert co;        

        String convertedStatus = [SELECT MasterLabel FROM LeadStatus WHERE IsConverted = TRUE LIMIT 1].MasterLabel;
        
        Database.LeadConvert lc = new database.LeadConvert();
        lc.setLeadId(le.id);
        lc.setContactId(co.Id);
        lc.setOpportunityId(op.Id);
        lc.setAccountId(ac.Id);
        lc.setConvertedStatus(convertedStatus);

        Database.LeadConvertResult lcr = Database.convertLead(lc);
        System.assert(lcr.isSuccess());
    }
    //SFDC-3724, update disti contact of lead
    @isTest
    static void testDistiConUpdateMainToAdditional(){
        Test.starttest();
        List<lead> leadList=[SELECT distributor_contact__c from Lead
                                          where LastName ='Lead1'];
        List<contact> conList = [Select id from contact where LastName = 'Contact1'];
        for(lead ld: leadList){
            ld.distributor_contact__c= conList[0].Id;
        }
        update leadList;
        system.debug('leadList[0].Disti_Branch_Name__c'+leadList[0].Disti_Branch_Name__c);
        List<lead> listDistiBranch = [select Disti_Branch_Name__c from lead where name = 'Test Lead1'];
        system.assertEquals(listDistiBranch[0].Disti_Branch_Name__c , 'Branch1; Branch2');
        Test.stopTest();
    }
    //SFDC-3724, update disti contact of lead
    @isTest
    static void testDistiConUpdateAdditionalToMain(){
        Test.starttest();
        List<lead> leadList=[SELECT distributor_contact__c from Lead
                                          where LastName ='Lead2'];
        List<contact> conList = [Select id from contact where LastName = 'Contact'];
        for(lead ld: leadList){
            ld.distributor_contact__c= conList[0].Id;
        }
        update leadList;
       // List<Disti_Branch_Contact_Role__c> listDistiBranchConRole = [select Disti_Branch__r.name from Disti_Branch_Contact_Role__c where contact__r.name = 'Test Contact' and Contact_Role__c = 'Main Distributor Contact'];
        List<lead> listDistiBranch = [select Disti_Branch_Name__c from lead where name = 'Test Lead2'];
        system.assertequals(listDistiBranch[0].Disti_Branch_Name__c,'Branch1');
        Test.stopTest();
        
    }    
}