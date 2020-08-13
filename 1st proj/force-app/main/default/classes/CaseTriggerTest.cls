/*********************************************************************************************
@Created By :       Prakhar Gupta
@Created Date :     30 Dec 2014
Description :      Test Class for triggers on Case object
********************************************************************************************/

/***************************************************************************************************
@Modified By :      Amrutha R
@Modified Date:     03 Mar 2015
@Description:       Test class for CaseTrigger class.
*******************************************************************************************************/
/***************************************************************************************************
@Modified By :      Avichal Kumar
@Modified Date:     07 Apr 2016
@Description:       Cleanup of case assignment rules
**********************************************************************************************************/
/***************************************************************************************************
@Modified By :      Avichal Kumar
@Modified Date:     27 jul 2016
@Description:       Entitlemet Based Routing
**********************************************************************************************************/
/*
@Modified By :      Gunjan Singh
@Modified Date:     11 Sep 2018
@Description:       SFDC-2078 Web-to-Case form without Login - Enhancement (Creating contact along with case)
Created method createContact() to create Contact, along with Case if contact doesnot exist
***************************************************************************************************
@Modified By :      Saranya
@Description:       As part of SFDC-2961
************************************************************************************************
@Last Modified By :       Baji
@Last Modified Date:      30 Mar 2020
@Description:             SFDC-3720/3721 [To obsolete the usage of unncessary Account fields]
************************************************************************************************
@Last Modified By :       Bhagyashree
@Last Modified Date:      30 Mar 2020
@Description:             SFDC-2681 [Removed the legacy code related to case,project and Product service level AND service level criteria]
*********************************************************************************************************/
@isTest
private class CaseTriggerTest 
{
    
    private final static String CASE_TSCOMMUNITY = 'TS_COMMUNITY'; 
    private final static String CHILD_ACCOUNT = 'Child_Account';
    private final static String PARENT_ACCOUNT = 'Parent_Account';    
    private static final integer RECORD_COUNT = 5; 
    private Static RecordType tsCommunity;
    private Static RecordType childAccount;
    private static RecordType parentAccount;
    Private static Id tscommunityRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('TS Community').getRecordTypeId();
    Private static Id SysAdminProfileId = CasePortalTestUtil.fetchProfileId(CasePortalUtil.SYSTEM_ADMIN_PROFILE);  
    Private static Id communityProfileId = CasePortalTestUtil.fetchProfileId(CasePortalUtil.COMMUNITY_USER_PROFILE); 
    Private static Id InternalAgentProfileId = CasePortalTestUtil.fetchProfileId(CasePortalUtil.INTERNAL_AGENT_PROFILE); 
    //To fetch the record type
    private static void fetchRecordTypes()
    {        
        for(RecordType rt : [Select Id, DeveloperName
                             From RecordType Where IsActive=true and  
                             ((SobjectType = 'Case' and (DeveloperName =: CASE_TSCOMMUNITY)) or
                              (SobjectType = 'Account' and (DeveloperName =: Child_Account or DeveloperName =: Parent_Account))                              
                             ) Limit 3])
            
            if(rt.DeveloperName == CASE_TSCOMMUNITY)
        {
            tsCommunity = rt;
        }
        else if(rt.DeveloperName == CHILD_ACCOUNT)
        {
            childAccount = rt; 
        }
        else if(rt.DeveloperName == PARENT_ACCOUNT)
        {
            parentAccount = rt;
        } 
    }   
    
    //Create user records to assign to account owner
    private Static List<User> createManagerUsers() 
    {
        List<User> lstUsers = new List<User>();
        
        Profile objProfile = [SELECT Id FROM Profile WHERE Name='Standard User' LIMIT 1];
        system.assert(objProfile.Id != null);
        
        User objUser;
        for(integer i=1; i < RECORD_COUNT; i++)
        {
            objUser = new User(alias = 'nUser' + i, email= 'testing' + i +'@test.com', emailencodingkey='UTF-8',firstname='Name'+i, lastname='test'+i,languagelocalekey='en_US', localesidkey='en_US', 
                               profileid = objProfile.Id, timezonesidkey='America/Los_Angeles', username= 'prakhartest' + datetime.now().millisecond() + i +'@test.com');
            lstUsers.add(objUser);                                          
        }
        return lstUsers;
    }
    
    //Method to create a 'NXP Community' Parent Account
    private Static Account objAccount;    
    private static Account createNxpCommunityAccountRecord()
    {
        objAccount = new Account(RecordTypeID= parentAccount.ID,
                                 Name = 'NXP Community', Customer_Category__c= 'Longtail');
        return  objAccount;
    }
    
    //Method to create a 'Other' Parent Account    
    private static Account createOtherAccountRecord()
    {
        objAccount = new Account(RecordTypeID= parentAccount.ID,
                                 Name = 'Other', Customer_Category__c= 'Longtail');
        return  objAccount;
    }
    
    //Method to create a TechService Child Account
    private static Account createTechServiceAccountRecord(ID parentAccountId)
    {
        objAccount = new Account(RecordTypeID= childAccount.ID,ParentId = parentAccountId,  
                                 Name = 'Technical Services', Region__c = 'Japan',
                                 Sales_Area__c = 'Japan ID', 
                                 Country__c = 'Austria');
        return objAccount;    
    }
    
    //Method to create Public Domain object records
    private static List<Public_Domain__c> createPublicDomainRecords()
    {
        List<Public_Domain__c> lstPublicDomains = new List<Public_Domain__c>();
        
        lstPublicDomains.add(new Public_Domain__c(Domain_Name__c='gmail.com'));
        lstPublicDomains.add(new Public_Domain__c(Domain_Name__c='yahoo.com'));
        lstPublicDomains.add(new Public_Domain__c(Domain_Name__c='hotmail.com'));
        
        return lstPublicDomains;
    } 
    
    private static Account createParentAccount()
    {
        RecordType objRecordType = [Select Id, DeveloperName From RecordType Where IsActive=true and  
                                    SobjectType = 'Account' and DeveloperName ='Parent_Account' Limit 1];
        //Method to create a Parent Account
        
        Account objParentAccount = new Account(RecordTypeID= objRecordType.ID,
                                               Name = 'Bosch', Customer_Category__c= 'Longtail');
        return  objParentAccount;
    }
    
    
    
    /***************************************************************************      
Case -Insert Case from WebForm->contact assigned with case is under child account->
Case assigned to account owner
****************************************************************************/
    
    static testmethod void CaseTriggerTest1() 
    {
        //Prepare the test data
        fetchRecordTypes();
        
        List<User> lstUsers =  createManagerUsers();
        if(lstUsers.size() > 0)
        {
            insert lstUsers;        
        }
        
        //assert record ids        
        for(user objUser:lstUsers)
        {
            system.assert(objUser.Id != null);
        }
        
        List<Account> lstParentAccount = new List<Account>();
        //Insert parent account with all Service/Account manager to cover the code
        lstParentAccount.add(new Account(RecordTypeID=parentAccount.Id, ownerId= lstUsers[0].id,Name = 'Parent1',
                                         Customer_Category__c= 'TestCategory', NXP_GID__c = 'TestGID'
                                         ));
        
        lstParentAccount.add(new Account(RecordTypeID=parentAccount.Id,ownerId= lstUsers[0].id, Name = 'Parent2',
                                         Customer_Category__c= 'TestCategory', NXP_GID__c = 'TestGID'
                                         ));
        
        if(lstParentAccount.size() > 0)
        {
            insert lstParentAccount;        
        }
        
        //assert record ids        
        for(Account objParentAcc:lstParentAccount)
        {
            system.assert(objParentAcc.Id != null);
        }
        
        Account objNxpCommunityAccount = createNxpCommunityAccountRecord();
        insert objNxpCommunityAccount;
        System.assert(objNxpCommunityAccount.Id != null);
        
        Account objOtherAccount = createOtherAccountRecord();
        insert objOtherAccount;
        System.assert(objOtherAccount.Id != null);
        
        Account objTechServiceAccount = createTechServiceAccountRecord(objOtherAccount.ID);
        insert objTechServiceAccount;
        System.assert(objTechServiceAccount.Id != null);
        
        List<Account> lstChildAccount = new List<Account>();
        
        for(integer i=1; i<RECORD_COUNT;i++)
        {
            lstChildAccount.add(new Account(RecordTypeID=childAccount.Id, Name = 'Child'+i, ParentID = lstParentAccount.get(0).Id, 
                                            Region__c='TestRegion', Sales_Area__c ='TestArea', 
                                             Country__c = 'TestCountry'));
        }
        
        if(lstChildAccount.size() > 0)
        {
            insert lstChildAccount;        
        }
        
        //assert record ids        
        for(Account objChildAccount1:lstChildAccount)
        {
            system.assert(objChildAccount1.Id != null);
        }
        
        List<Contact> lstContacts = new List<Contact>();
        
        For(integer i=1; i< RECORD_COUNT; i++)
        {
            lstContacts.add(new Contact(AccountID=lstChildAccount.get(i-1).Id, FirstName = 'test1', LastName = 'test', 
                                        Title = 'title', Phone = '8123978919', email = 'test'+i+'@test.com',Community_web_country__c = 'testcountry'));  
        }   
        
        if(lstContacts.size() > 0)
        {
            Insert lstContacts;
        }
        
        //assert record ids        
        for(Contact objContact1:lstContacts)
        {
            system.assert(objContact1.Id != null);
        }
        
        Test.StartTest();
        
        List<Case> lstCases = new List<Case>();
        
        For(integer i=1; i< RECORD_COUNT; i++)
        {
            lstCases.add(new Case(RecordTypeID = tsCommunity.Id,contactId=lstContacts[0].id, Status= 'New', Priority = 'Medium', 
                                  Product_Category__c = 'RF', Product_Sub__c = 'Mixers', 
                                  email__c = 'test'+i+'@test.com', JobTitle__c = 'Other', Facebook__c = 'test_fb',
                                  Company__c = 'test_Company', Linkedin__c = 'test_lnk', Community_Web_Country__c = 'testcountry',
                                  Twitter__c = 'test_twt', State_Province__c = 'test_state', Product_Type_Number__c = 'test',
                                  Subject = 'test_subject', My_Question_is_Related__c = 'test', Description = 'test_subject',
                                  Product_application__c = 'test', Expected_annual_unit_volume__c = 'test',
                                  Project_Stage__c = 'Development',Web_Region__c = 'Test_region',  origin = 'Web',Case_Owner_Name__c='test',Web_First_Name__c='Test',Web_Last_Name__c='Test',SuppliedEmail = 'test@test.com')); 
        }
        
        if(lstCases.size() > 0)
        {
            Insert lstCases;
        }
        
        
        
        
        //assert record ids        
        for(Case objCase:lstCases)
        {
            system.assert(objCase.Id != null);
        }        
        
        lstCases = [Select Id, OwnerID,AccountID From Case];      
        
        //assert Account ids        
        for(integer i =0; i< lstCases.size(); i++)
        {
            System.assertEquals(lstContacts[0].accountId, lstCases.get(i).AccountID);
        }
        Test.StopTest();
        
    } 
    
    
    
    /***************************************************************************
Case -Insert Case from WebForm->Contact assigned to case is under nxp community-> 
Case assigned to 1st Line Support
****************************************************************************/
    
    static testmethod void CaseTriggerTest2() 
    {
        
        fetchRecordTypes();
        
        List<User> lstUsers =  createManagerUsers();
        if(lstUsers.size() > 0)
        {
            insert lstUsers;        
        }
        
        for(user objUser:lstUsers)
        {
            system.assert(objUser.Id != null);
        } 
        
        Group objGroup = new Group(Name='TS L1 Inbox', type='Queue');
        insert objGroup;
        System.assert(objGroup.Id != null);
        
        QueueSobject objQueueMapping = new QueueSobject(QueueId = objGroup.Id, SobjectType = 'Case');
        System.runAs(new User(Id = UserInfo.getUserId()))
        {
            insert objQueueMapping;
        }
        System.assert(objQueueMapping.Id != null);
        
        Account objNxpCommunityAccount = createNxpCommunityAccountRecord();
        insert objNxpCommunityAccount;
        System.assert(objNxpCommunityAccount.Id != null);
        
        Account objOtherAccount = createOtherAccountRecord();
        insert objOtherAccount;
        System.assert(objOtherAccount.Id != null);
        
        Account objTechServiceAccount = createTechServiceAccountRecord(objOtherAccount.ID);
        insert objTechServiceAccount;
        System.assert(objTechServiceAccount.Id != null);
        
        List<Account> lstParentAccount = new List<Account>();
        
        for(integer i=0; i<5; i++)
        {
            lstParentAccount.add(new Account(RecordTypeID=parentAccount.Id, Name = 'Parent'+i,
                                             Customer_Category__c= 'TestCategory', NXP_GID__c = 'TestGID'));
        }
        
        if(lstParentAccount.size() > 0)
        {
            insert lstParentAccount;        
        }
        
        for(Account objParntAccount:lstParentAccount)
        {
            system.assert(objParntAccount.Id != null);
        }
        
        List<Account> lstChildAccount = new List<Account>();
        
        for(integer i=1; i<5; i++)
        {
            lstChildAccount.add(new Account(RecordTypeID=childAccount.Id, Name = 'Child'+i, ParentID = lstParentAccount.get(i-1).Id, 
                                            Region__c='TestRegion', Sales_Area__c ='TestArea', 
                                            Country__c = 'TestCountry'));
        }
        
        if(lstChildAccount.size() > 0)
        {
            insert lstChildAccount;        
        }
        
        for(Account objChldAccount:lstChildAccount)
        {
            system.assert(objChldAccount.Id != null);
        }
        
        List<Contact> lstContacts = new List<Contact>();
        
        For(Integer i =1; i<5; i++)
        {
            lstContacts.add(new Contact(AccountID=objNxpCommunityAccount.Id, FirstName = 'test'+i, LastName = 'test', 
                                        Title = 'title', Phone = '8123978919', email = 'test'+i+'@test.com',Community_web_country__c = 'testcountry'));
        }
        
        if(lstContacts.size() > 0)
        {
            insert lstContacts;        
        }
        
        for(Contact objContact:lstContacts)
        {
            system.assert(objContact.Id != null);
        }
        
        Test.StartTest();
        
        List<Case> lstCases = new List<Case>();
        
        For(Integer i=1; i< 5; i++)
        {
            lstCases.add(new Case(RecordTypeID = tsCommunity.Id, contactId=lstContacts[0].id, Status= 'New', Priority = 'Medium', 
                                  Product_Category__c = 'RF', Product_Sub__c = 'Mixers', 
                                  email__c = 'test'+i+'@test.com', JobTitle__c = 'Other', Facebook__c = 'test_fb',
                                  Company__c = 'test_Company', Linkedin__c = 'test_lnk', Community_Web_Country__c = 'testcountry',
                                  Twitter__c = 'test_twt', State_Province__c = 'test_state', Product_Type_Number__c = 'test',
                                  Subject = 'test_subject', My_Question_is_Related__c = 'test', Description = 'test_subject',
                                  Product_application__c = 'test', Web_First_Name__c='Test',Web_Last_Name__c='Test', Expected_annual_unit_volume__c = 'test',
                                  Project_Stage__c = 'Development', Web_Region__c = 'Test_region', origin = 'Self Service Portal'));
        }
        
        if(lstCases.size() > 0)
        {
            Insert lstCases;
        }
        
        for(Case objCase:lstCases)
        {
            system.assert(objCase.Id != null);
        }
        
        
        lstCases = [Select Id, OwnerID, AccountID From Case];
        
        for(integer i =0; i< lstCases.size(); i++)
        {
            System.assertEquals(lstContacts[0].accountId, lstCases.get(i).AccountID);
        }
        
        Test.StopTest();
    }  
    
    /***************************************************************************
Case -Insert Case from WebForm->contact assigned to case is under technical services -> 
Case assigned to first line support
****************************************************************************/
    
    static testmethod void CaseTriggerTest3() 
    {
        //Prepare the test data
        fetchRecordTypes();
        
        List<User> lstUsers =  createManagerUsers();
        if(lstUsers.size() > 0)
        {
            insert lstUsers;        
        }
        
        //assert record ids        
        for(user objUser:lstUsers)
        {
            system.assert(objUser.Id != null);
        } 
        
        Group objGroup = new Group(Name='TS L1 inbox', type='Queue');
        insert objGroup;
        System.assert(objGroup.Id != null);
        
        QueueSobject objQueueMapping = new QueueSobject(QueueId = objGroup.Id, SobjectType = 'Case');
        System.runAs(new User(Id = UserInfo.getUserId()))
        {
            insert objQueueMapping;
        }
        System.assert(objQueueMapping.Id != null);
        
        Account objNxpCommunityAccount = createNxpCommunityAccountRecord();
        insert objNxpCommunityAccount;
        System.assert(objNxpCommunityAccount.Id != null);
        
        Account objOtherAccount = createOtherAccountRecord();
        insert objOtherAccount;
        System.assert(objOtherAccount.Id != null);
        
        Account objTechServiceAccount = createTechServiceAccountRecord(objOtherAccount.ID);
        insert objTechServiceAccount;
        System.assert(objTechServiceAccount.Id != null);
        
        List<Account> lstParentAccount = new List<Account>();
        
        for(integer i =1; i< RECORD_COUNT; i++)
        {
            lstParentAccount.add(new Account(RecordTypeID=parentAccount.Id, Name = 'Parent'+i,
                                             Customer_Category__c= 'TestCategory', NXP_GID__c = 'TestGID'
                                             ));
        }
        if(lstParentAccount.size() > 0)
        {
            insert lstParentAccount;        
        }
        
        //assert record ids        
        for(Account objParntAccount:lstParentAccount)
        {
            system.assert(objParntAccount.Id != null);
        }
        
        List<Account> lstChildAccount = new List<Account>();
        
        for(integer i=1; i<5; i++)
        {
            lstChildAccount.add(new Account(RecordTypeID=childAccount.Id, Name = 'Child'+i, ParentID = lstParentAccount.get(i-1).Id, 
                                            Region__c='TestRegion', Sales_Area__c ='TestArea',  
                                            Country__c = 'TestCountry'));
        }
        
        if(lstChildAccount.size() > 0)
        {
            insert lstChildAccount;        
        }
        
        //assert record ids        
        for(Account objChldAccount:lstChildAccount)
        {
            system.assert(objChldAccount.Id != null);
        }
        
        List<Contact> lstContacts = new List<Contact>();
        
        For(Integer i =1; i<5; i++)
        {
            lstContacts.add(new Contact(AccountID=objTechServiceAccount.Id, FirstName = 'test'+i, LastName = 'test', 
                                        Title = 'title', Phone = '8123978919', email = 'test'+i+'@test.com',Community_web_country__c = 'testcountry'));
        }
        
        if(lstContacts.size() > 0)
        {
            insert lstContacts;        
        }
        
        for(Contact objContact:lstContacts)
        {
            system.assert(objContact.Id != null);
        }
        Test.StartTest();
        
        List<Case> lstCases = new List<Case>();
        
        For(integer i=1; i< RECORD_COUNT; i++)
        {
            lstCases.add(new Case(RecordTypeID = tsCommunity.Id, contactId=lstContacts[0].id,Status= 'New', Priority = 'Medium', 
                                  Product_Category__c = 'RF', Product_Sub__c = 'Mixers', 
                                  email__c = 'test@test.com', JobTitle__c = 'Other', Facebook__c = 'test_fb',
                                  Company__c = 'Parent'+i, Linkedin__c = 'test_lnk', Community_Web_Country__c = 'testcountry',
                                  Twitter__c = 'test_twt', State_Province__c = 'test_state', Product_Type_Number__c = 'test',
                                  Subject = 'test_subject', My_Question_is_Related__c = 'test', Description = 'test_subject',
                                  Product_application__c = 'test', Expected_annual_unit_volume__c = 'test', Web_First_Name__c='Test', Web_Last_Name__c='Test',
                                  Project_Stage__c = 'Development', Web_Region__c = 'Test_region', origin = 'Web',SuppliedEmail = 'test@test.com'));
        }
        
        if(lstCases.size() > 0)
        {
            Insert lstCases;
        }
        
        Set<Id> caseIds = new Set<Id>();
        
        //assert record ids        
        for(Case objCase:lstCases)
        {
            system.assert(objCase.Id != null);
            caseIds.add(objCase.Id);
        }
        
        lstCases = [Select Id, OwnerID, AccountID From Case Where Id IN : caseIds];
        
        //assert Account ids        
        for(integer i =0; i< lstCases.size(); i++)
        {
            System.assertEquals(lstContacts[0].accountId, lstCases.get(i).AccountID);
        }
        
        Test.StopTest();
    } 
    
    
    /***************************************************************************
Case -Populate product values based on the product type number
****************************************************************************/
    
    @isTest(SeeAllData=true)
    static void CaseTriggerTest4()
    {
        //Prepare the test data
        fetchRecordTypes(); 
        
        List<User> lstUsers =  createManagerUsers();
        if(lstUsers.size() > 0)
        {
            insert lstUsers;        
        }
        
        //assert record ids        
        for(user objUser:lstUsers)
        {
            system.assert(objUser.Id != null);
        } 
        
        Account objNxpCommunityAccount = createNxpCommunityAccountRecord();
        insert objNxpCommunityAccount;
        //assert record id
        System.assert(objNxpCommunityAccount.Id != null);
        
        Account objOtherAccount = createOtherAccountRecord();
        insert objOtherAccount;
        //assert record id
        System.assert(objOtherAccount.Id != null);
        
        Account objTechServiceAccount = createTechServiceAccountRecord(objOtherAccount.ID);
        insert objTechServiceAccount;
        //assert record id
        System.assert(objTechServiceAccount.Id != null);
        
        Group objGroup = new Group(Name='1st Line Support', type='Queue');
        insert objGroup;
        //assert record id
        System.assert(objGroup.Id != null);
        
        QueueSobject objQueueMapping = new QueueSobject(QueueId = objGroup.Id, SobjectType = 'Case');
        System.runAs(new User(Id = UserInfo.getUserId()))
        {
            insert objQueueMapping;
        }
        //assert record id
        System.assert(objGroup.Id != null);
        
        List<Product2> lstProduct = new List<Product2>();
        
        for(integer i=1; i<6; i++)
        {
            lstProduct.add(new Product2(Name = 'Product'+i, Basic_Type__c='Type'+i, BL_Description__c = 'Description'+i, 
                                        BU__c='BU'+i, BU_Description__c='BU_Desc'+i, MAG__c= 'MAG'+i, BL__c='BL'+i,
                                        MAG_Description__c='MAG_Desc'+i, Thrust_Indicator__c = true,
                                        Product_Type__c='Type'+i, Sales_Item_Market_Segment__c = 'Segment'+i, IsActive = true));
        }
        
        if(lstProduct.size() > 0)
        {
            Insert lstProduct;
        }
        
        //assert record ids        
        for(Product2 objProduct:lstProduct)
        {
            system.assert(objProduct.Id != null);
        }
        List<Contact> lstContacts = new List<Contact>();
        
        For(Integer i =1; i<5; i++)
        {
            lstContacts.add(new Contact(AccountID=objTechServiceAccount.Id, FirstName = 'test'+i, LastName = 'test', 
                                        Title = 'title', Phone = '8123978919', email = 'testemail'+i+'@test.com',Community_web_country__c = 'testcountry'));
        }
        
        if(lstContacts.size() > 0)
        {
            insert lstContacts;        
        }
        
        for(Contact objContact:lstContacts)
        {
            system.assert(objContact.Id != null);
        }
        Test.StartTest();
        
        List<Case> lstCases = new List<Case>();
        
        For(Integer i=1; i< 6; i++)
        {
            lstCases.add(new Case(RecordTypeID = tsCommunity.Id,  Status= 'New', Priority = 'Medium', contactid=lstContacts[0].id,
                                  Product_Category__c = 'RF', Product_Sub__c = 'Mixers',Product_Name__c=lstProduct[0].id,
                                  email__c = 'test'+i+'@prakhartest'+i+'.com', JobTitle__c = 'Other', Facebook__c = 'test_fb',
                                  Company__c = 'test_Company', Linkedin__c = 'test_lnk', Community_Web_Country__c = 'testcountry',
                                  Twitter__c = 'test_twt', State_Province__c = 'test_state', Product_Type_Number__c = 'Type'+i,
                                  Subject = 'test_subject', My_Question_is_Related__c = 'test', Description = 'test_subject',Web_First_Name__c='Test', Web_Last_Name__c='Test',
                                  Product_application__c = 'test', Expected_annual_unit_volume__c = 'test', Web_Country__c = 'America',
                                  Project_Stage__c = 'Development', Web_Region__c = 'Test_region'+i, origin = 'Self Service Portal',MAG__c = 'MAG1'));
        }
        
        if(lstCases.size() > 0)
        {
            Insert lstCases;
        }
        
        //assert record ids        
        for(Case objCase:lstCases)
        {
            system.assert(objCase.Id != null);
        }
        
        lstCases = [Select Id, OwnerID, AccountID, BL__c, BL_Description__c,Product_Mag_Description__c,Basic_Type__c,
                    BU__c, BU_Description__c, MAG__c, MAG_Description__c, Basic_Type_Description__c
                    From Case Where Email__c Like '%@prakhartest%'];
        
        lstProduct=[Select Id, Basic_Type__c,BL_Description__c, Basic_Type_Description__c,BL__c,
                    BU__c,BU_Description__c,MAG__c, MAG_Description__c,Product_Type__c From Product2
                    Where Product_Type__c Like 'Type%' ];        
        
        
        
        Test.StopTest();
    } 
    
    public static void createCustomSetting()
    {
        list<base_value_for_case_priority_calculation__c> listCustomerCategorySetting=new list<base_value_for_case_priority_calculation__c>(); //Custom Setting for Contact Fields
        listCustomerCategorySetting.add(new base_value_for_case_priority_calculation__c(Name='Base',Base_Value__c=6000));
        
        listCustomerCategorySetting.add(new base_value_for_case_priority_calculation__c(Name='Negative_Zero_Score_Hours',Base_Value__c=336));
        
        
        insert listCustomerCategorySetting;
    }
   /* public static list<Case_Service_Level_Criteria__c> createCaseServiceLevelCriteria()
    {
        list<Case_Service_Level_Criteria__c> listCaseSLC=new list<Case_Service_Level_Criteria__c>();
        listCaseSLC.add(new Case_Service_Level_Criteria__c(Contact_Service_Level__c='B2-OtherCompany',Case_Service_Level__c='10'));
        listCaseSLC.add(new Case_Service_Level_Criteria__c(Contact_Service_Level__c='B2-OtherCompany',Product_Service_Level__c='2',Project_Service_Level__c='4',Case_Service_Level__c='20'));
        listCaseSLC.add(new Case_Service_Level_Criteria__c(Contact_Service_Level__c='B2-OtherCompany',Project_Service_Level__c='4',Case_Service_Level__c='30'));
        // listCaseSLC.add(new Case_Service_Level_Criteria__c(Contact_Service_Level__c='B2-OtherCompany',Product_Service_Level__c='2',Case_Service_Level__c='40'));
        listCaseSLC.add(new Case_Service_Level_Criteria__c(Product_Service_Level__c='2',Project_Service_Level__c='4',Case_Service_Level__c='50'));
        // listCaseSLC.add(new Case_Service_Level_Criteria__c(Project_Service_Level__c='4',Case_Service_Level__c='60'));
        // listCaseSLC.add(new Case_Service_Level_Criteria__c(Product_Service_Level__c='2',Case_Service_Level__c='50'));
        insert listCaseSLC;
        return listCaseSLC;
        
    }
    public static list<Product_Service_Level_Criteria__c> createProductServiceLevelCriteria()
    {
        list<Product_Service_Level_Criteria__c> listPSLC=new list<Product_Service_Level_Criteria__c>();
        listPSLC.add(new Product_Service_Level_Criteria__c(Product__c='Audio and Media Processing',Product_Category__c='Data converters',Product_Sub__c='Audio converters',Product_Service_Level__c='3'));
        listPSLC.add(new Product_Service_Level_Criteria__c(Product__c='Audio and Media Processing',Product_Category__c='Media processors',Product_Sub__c='CD-DVD processors',Product_Service_Level__c='5'));
        listPSLC.add(new Product_Service_Level_Criteria__c(Product__c='Audio and Media Processing',Product_Category__c='Media processors',Product_Sub__c='',Product_Service_Level__c='2'));
        listPSLC.add(new Product_Service_Level_Criteria__c(Product__c='Audio and Media Processing',Product_Category__c='',Product_Sub__c='',Product_Service_Level__c='1'));
        
        insert listPSLC;
        return listPSLC;
        
    }
    public static list<Project_Service_Level_Criteria__c> createProjectServiceLevelCriteria()
    {
        list<Project_Service_Level_Criteria__c> listProjectSLC=new list<Project_Service_Level_Criteria__c>();
        listProjectSLC.add(new Project_Service_Level_Criteria__c(Priority__c='high',Project_Service_Level__c='10',Sub_Type__c=null,Type__c='paid'));
        listProjectSLC.add(new Project_Service_Level_Criteria__c(Priority__c='critical',Project_Service_Level__c='3',Sub_Type__c='development project',Type__c='Free'));
        listProjectSLC.add(new Project_Service_Level_Criteria__c(Priority__c=null,Project_Service_Level__c='4',Sub_Type__c='development project',Type__c='Free'));
        listProjectSLC.add(new Project_Service_Level_Criteria__c(Priority__c=null,Project_Service_Level__c='5',Sub_Type__c=null,Type__c='Free'));
        listProjectSLC.add(new Project_Service_Level_Criteria__c(Priority__c='high',Project_Service_Level__c='6',Sub_Type__c=null,Type__c='Free'));
        
        insert listProjectSLC;
        return listProjectSLC;
        
    }  */
    
    
    
    static testMethod void updateNoOfCases(){
        Id tscommunityRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('TS Community').getRecordTypeId();
        
        
        User SAUser = TestUtil.createTestUser('testCT@gmail.com','CTMpass',SysAdminProfileId);
        SAUser.FirstName = 'NXPfirst';
        SAUser.LastName ='NXPlast';
        insert SAUser;
        
        Group grp = new Group(Name = 'DEFAULT_QUEUE');
        insert grp;
        
        
        Group grp1 = new Group(Name = 'NXPfirst NXPlast',Type = 'Queue');
        insert grp1;
        
        Project__c newProjectTest = CasePortalTestUtil.createTestProject('Projecttest','General Interest & Research');
        newProjectTest.Contract_End_Date__c = system.today().AddDays(1);
       // newProjectTest.Contract_Status__c = 'Active'; 
        newProjectTest.Route_To_Case_Owner__c = 'NXPfirst NXPlast';
        newProjectTest.Route_to_Assigned_to__c = SAUser.Id;
        newProjectTest.Project_Service_Level__c = 'High';
        newProjectTest.Type__c='Paid';
        newProjectTest.Project_Service_Level__c = 'Medium';
        newProjectTest.Total_Number_of_Hours__c = 50;
        
        try{
            List<Case> caselst = CasePortalTestUtil.createCaseObject(1,tscommunityRecordTypeId,newProjectTest.Id);
            caselst[0].Hours_spent_by_Support_person__c = 4;
            insert caselst;
        }
        catch(Exception e){
        }
        
        //to cover assignGsasCases
        Id tsGSASRTId= Schema.SObjectType.Case.getRecordTypeInfosByName().get('GSAS Issues').getRecordTypeId();
        List<Case_Priority_Criteria__c> lstConsol = new List<Case_Priority_Criteria__c>();
        //cpc for project
        Case_Priority_Criteria__c CPcriteriap = CasePortalTestUtil.createTestCasePriorityCriteria('Project__C','Type','Paid',11);
        lstConsol.add(CPcriteriap);
        
        //cpc for project
        Case_Priority_Criteria__c CPcriteriap1 = CasePortalTestUtil.createTestCasePriorityCriteria('Project__C','Ent-Priority','Medium',12);
        lstConsol.add(CPcriteriap1);
        
        // to test when Origin is factor for calculating score
        Case_Priority_Criteria__c CPcriteria = CasePortalTestUtil.createTestCasePriorityCriteria('Case','Origin','Forum',1);
        lstConsol.add(CPcriteria);
        
        // to test when standard priority is a factor
        Case_Priority_Criteria__c CPcriteria1 = CasePortalTestUtil.createTestCasePriorityCriteria('Case','Priority','Low',1);
        lstConsol.add(CPcriteria1);
        
        // to test when Internal priority is a factor
        Case_Priority_Criteria__c CPcriteria2 = CasePortalTestUtil.createTestCasePriorityCriteria('Case','Internal Priority','Critical',2);
        lstConsol.add(CPcriteria2);
        
        // to test when product is a factor for Product Lvl 1
        Case_Priority_Criteria__c CPcriteria3 = CasePortalTestUtil.createTestCasePriorityCriteria('Case','Product Lvl 1','Sensors',2);
        lstConsol.add(CPcriteria3);
        
        // to test when product is a factor for Product Lvl 2
        Case_Priority_Criteria__c CPcriteria4 = CasePortalTestUtil.createTestCasePriorityCriteria('Case','Product Lvl 2','Automotive',2);
        lstConsol.add(CPcriteria4);
        
        // to test when product is a factor for Product Lvl 3
        Case_Priority_Criteria__c CPcriteria5 = CasePortalTestUtil.createTestCasePriorityCriteria('Case','Product Lvl 3','AC-DC Controllers',2);
        lstConsol.add(CPcriteria5);
        insert lstConsol;
        test.startTest();
        
        //test data to test contact service level
        List<Account> acc = CasePortalTestUtil.createTestParentAccount(1);
        insert acc;
        String email = 'testnxp.cls@gmail.com';
        String LastName= 'tst Last';
        List<Contact> con = CasePortalTestUtil.createTestContact(1,acc[0].Id,email,LastName);
        con[0].Contact_Service_Level__c = 'Medium';
        insert con;
        //Contact_Service_Level__c as factor
        Case_Priority_Criteria__c CPcriteria6 = CasePortalTestUtil.createTestCasePriorityCriteria('Case','Contact Service Level','Medium',2);
        insert CPcriteria6;
        test.stopTest();
       /* Project_Service_Level_Criteria__c pSLCriteria = new Project_Service_Level_Criteria__c();
        pSLCriteria.Type__c = 'Paid';
        insert pSLCriteria;*/
        
        List<Case> caselst = CasePortalTestUtil.createCaseObject(1,tsGSASRTId,newProjectTest.Id);
        caselst[0].Hours_spent_by_Support_person__c = 11;
        caselst[0].Web_Country__c ='United States of America';
        caselst[0].origin ='Forum';
        caselst[0].Priority = 'Low';
        caselst[0].description = 'Test before update';
        //caselst[0].Internal_Priority__c = 'Critical';
        caselst[0].Product__c = 'Sensors';
        caselst[0].Product_Category__c = 'Automotive';
        caselst[0].Product_Sub__c = 'AC-DC Controllers';
        insert caselst;
        caselst[0].description = 'Test after Update';
        caselst[0].Hours_spent_by_Support_person__c = 18;
        caselst[0].My_Question_is_Related__c = 'test';
        update caselst[0];
        
    }
  /*  static testMethod void rcaRouting(){
        test.startTest();
        User SAUser = TestUtil.createTestUser('testCT@gmail.com','CTMpass',SysAdminProfileId);
        SAUser.FirstName = 'NXPfirst';
        SAUser.LastName ='NXPlast';
        insert SAUser;
        
        Group grp = new Group(Name = 'DEFAULT_QUEUE');
        insert grp;
        Project_Service_Level_Criteria__c pSLCriteria = new Project_Service_Level_Criteria__c();
        pSLCriteria.Type__c = 'Free';
        pSLCriteria.Sub_Type__c = 'Development Project';
        pSLCriteria.Priority__c = 'Medium';
        insert pSLCriteria;
        //Route_To_Case_Owner__c is null and Route_to_Assigned_to__c is not null
                

        Project__c newProjectTest2 = CasePortalTestUtil.createTestProject('Projecttest','In Development');
        newProjectTest2.Contract_End_Date__c = system.today().AddDays(1);
        newProjectTest2.Type__c='Free';
        newProjectTest2.Contract_Status__c = 'Active'; 
        newProjectTest2.Route_to_Assigned_to__c = SAUser.Id;
        newProjectTest2.Route_To_Case_Owner__c = 'NXPfirst NXPlast';
        newProjectTest2.Total_Number_of_Hours__c = 50;
        newProjectTest2.Project_Service_Level__c = 'Medium';
        newProjectTest2.Used_number_of_Hours__c = 1;
        insert newProjectTest2;
        List<Case> caselst = CasePortalTestUtil.createCaseObject(1,tscommunityRecordTypeId,newProjectTest2.Id);
        caselst[0].Hours_spent_by_Support_person__c = 2;
        insert caselst;
        caselst[0].Hours_spent_by_Support_person__c = 14;
        update caselst;
        Project_Service_Level_Criteria__c pSLCriteria1 = new Project_Service_Level_Criteria__c();
        pSLCriteria1.Type__c = 'Paid';
        insert pSLCriteria1;
        //Route_To_Case_Owner__c is null and Route_to_Assigned_to__c is null
        Project__c newProjectTest3 = CasePortalTestUtil.createTestProject('Projecttest','In Development');
        newProjectTest3.Contract_End_Date__c = system.today().AddDays(1);
        newProjectTest3.Type__c='Paid';
        newProjectTest3.Total_Number_of_Hours__c = 50;
        newProjectTest3.Used_number_of_Hours__c = 0;
        newProjectTest3.Contract_Status__c = 'Active'; 
        newProjectTest3.Project_Service_Level__c = 'Medium';
        insert newProjectTest3;
        List<Case> caselst1 = CasePortalTestUtil.createCaseObject(1,tscommunityRecordTypeId,newProjectTest3.Id);
        caselst1[0].Hours_spent_by_Support_person__c = 0;
        insert caselst1;
        
        caselst1[0].Hours_spent_by_Support_person__c = 4;
        update caselst1;
        test.stopTest();
    }*/
    /*static testMethod void PslCalcalculation(){
        
        Id parentAccountTypeId = AccountHelper.getParentRecordTypeID();
        Id childAccountTypeId =  AccountHelper.getChildRecordTypeID();
        
        Account parentAccount = new Account(Name = 'Test Parent', RecordTypeId = parentAccountTypeId);
        insert parentAccount;
        system.assert(parentAccount.Id != null);
        
        Account childAccount = new Account(Name = 'Test Child', RecordTypeId = childAccountTypeId, ParentId = parentAccount.Id);
        insert childAccount;
        system.assert(childAccount.Id != null);
        
        Contact testContact = new Contact(FirstName = 'test First', LastName = 'test Last', Email = 'test.ncpcontact@mailinator.com', 
                                                  AccountId = childAccount.Id, Community_web_country__c = 'India');
        insert testContact;
        System.assert(testContact.Id != null);
        
        Project__c ProjectT = CasePortalTestUtil.createTestProject('Projecttest','In Development');
        insert ProjectT;
        
        //inserting psl records
        List<product_service_level_criteria__c> prdtestLst = new List<product_service_level_criteria__c>();
        //case 1 - no null value 
        product_service_level_criteria__c prdtest = new product_service_level_criteria__c();
        prdtest.Product_Category__c = 'Power Architecture';
        prdtest.Product_Sub__c = 'MPC56xx MCUs';
        prdtest.Product_Service_Level__c = 'Test Service Level';
        prdtest.Product__c = 'Microcontrollers and Processors';
        prdtestLst.add(prdtest);        
        insert prdtestLst;
        test.startTest();
        System.assert(prdtestLst != null);
        List<Case> caselst1 = CasePortalTestUtil.createCaseObject(1,tscommunityRecordTypeId,ProjectT.Id);
        caselst1[0].Product__c  = 'Microcontrollers and Processors';
        caselst1[0].Product_Category__c = 'Power Architecture';
        caselst1[0].Product_Sub__c = 'MPC56xx MCUs';
        caselst1[0].ContactId = testContact.Id;
        
        System.Assert(caselst1[0].Product_Service_Level__c == null);
        insert caselst1;
        system.assert(caselst1 != null);
        test.stopTest();        
    }
*/    
  /*  static testMethod void PslCalcalculation1(){
        Id parentAccountTypeId = AccountHelper.getParentRecordTypeID();
        Id childAccountTypeId =  AccountHelper.getChildRecordTypeID();
        
        Account parentAccount = new Account(Name = 'Test Parent', RecordTypeId = parentAccountTypeId);
        insert parentAccount;
        system.assert(parentAccount.Id != null);
        
        Account childAccount = new Account(Name = 'Test Child', RecordTypeId = childAccountTypeId, ParentId = parentAccount.Id);
        insert childAccount;
        system.assert(childAccount.Id != null);
        
        Contact testContact = new Contact(FirstName = 'test First', LastName = 'test Last', Email = 'test.ncpcontact@mailinator.com', 
                                                  AccountId = childAccount.Id, Community_web_country__c = 'India');
        insert testContact;
        System.assert(testContact.Id != null);
        
        Project__c ProjectT2 = CasePortalTestUtil.createTestProject('Projecttest','In Development');
        insert ProjectT2;
        //inserting psl records
        List<product_service_level_criteria__c> prdtestLst1 = new List<product_service_level_criteria__c>();
        //case 2 - product sub is null
        product_service_level_criteria__c prdtest1 = new product_service_level_criteria__c();
        prdtest1.Product_Category__c = 'Power Architecture';
        prdtest1.Product_Service_Level__c = 'Test Service Level1';
        prdtest1.Product__c = 'Microcontrollers and Processors';
        System.Assert(prdtest1.Product_Sub__c == null);
        prdtestLst1.add(prdtest1);
        //case 3 - product sub and product category are null
        product_service_level_criteria__c prdtest2 = new product_service_level_criteria__c();
        prdtest2.Product_Service_Level__c = 'Test Service Level2';
        prdtest2.Product_Sub__c = 'MPC56xx MCUs';
        prdtestLst1.add(prdtest2);
        insert prdtestLst1;
        
        System.assert(prdtestLst1 != null);
        test.startTest();
        List<Case> caselst2 = CasePortalTestUtil.createCaseObject(1,tscommunityRecordTypeId,ProjectT2.Id);
        caselst2[0].Product__c  = 'Microcontrollers and Processors';
        caselst2[0].Product_Category__c = 'Power Architecture';
        caselst2[0].Product_Sub__c = 'MPC56xx MCUs';
        caselst2[0].ContactId = testContact.Id;
        
        System.Assert(caselst2[0].Product_Service_Level__c == null);
        insert caselst2;
        system.assert(caselst2 != null);
        test.stopTest();
    }  */
 /*   static testMethod void cslcalculation(){
        test.startTest();
        //fetch record type for accounts
        Id parentAccountTypeId = AccountHelper.getParentRecordTypeID();
        Id childAccountTypeId =  AccountHelper.getChildRecordTypeID();
        Account nxpAccount = new Account(Name = 'NXP Community', RecordTypeId = parentAccountTypeId);
        insert nxpAccount;
        system.assert(nxpAccount.Id != null);
        Account parentAccount = new Account(Name = 'Test Parent', RecordTypeId = parentAccountTypeId);
        insert parentAccount;
        system.assert(parentAccount.Id != null);
        
        Account childAccount = new Account(Name = 'Test Child', RecordTypeId = childAccountTypeId, ParentId = parentAccount.Id);
        insert childAccount;
        system.assert(childAccount.Id != null);
        
        Contact testContact1 = new Contact(FirstName = 'test First', LastName = 'test Last', Email = 'Test.email@mailinator.com', 
                                           AccountId = childAccount.Id, Community_web_country__c = 'India',contact_service_level__c='A1');
        insert testContact1;
        Project__c ProjectforCSL = CasePortalTestUtil.createTestProject('Projecttest','In Development');
        insert ProjectforCSL;
        
        
        List<Case_Service_Level_Criteria__c> cslcriteriaLst = new List<Case_Service_Level_Criteria__c>();
        Case_Service_Level_Criteria__c  clcriteria = new Case_Service_Level_Criteria__c();
        clcriteria.Contact_Service_Level__c = 'B2-OtherCompany';
        clcriteria.Product_Service_Level__c = 'A2';
        clcriteria.Project_Service_Level__c = 'A3';
        cslcriteriaLst.add(clcriteria);
        //case 2
        Case_Service_Level_Criteria__c  clcriteria2 = new Case_Service_Level_Criteria__c();
        clcriteria.Contact_Service_Level__c = 'B2-OtherCompany';
        clcriteria2.Product_Service_Level__c = 'A2';
        cslcriteriaLst.add(clcriteria2);
        //case 3
        Case_Service_Level_Criteria__c  clcriteria3 = new Case_Service_Level_Criteria__c();
        clcriteria.Contact_Service_Level__c = 'B2-OtherCompany';
        clcriteria2.Project_Service_Level__c = 'A3';
        cslcriteriaLst.add(clcriteria3);
        //case 4
        Case_Service_Level_Criteria__c  clcriteria4 = new Case_Service_Level_Criteria__c();
        clcriteria4.Contact_Service_Level__c = 'B2-OtherCompany';

        cslcriteriaLst.add(clcriteria4);
        insert cslcriteriaLst;
        List<Case> caselstforCSL = CasePortalTestUtil.createCaseObject(3,tscommunityRecordTypeId,ProjectforCSL.Id);
        caselstforCSL[0].Project_Service_Level__c = 'A3';
        caselstforCSL[0].contactId = testContact1.Id;
        caselstforCSL[0].SuppliedEmail = 'Test123.email@mailinator.com';
        caselstforCSL[0].Origin = 'Email';
        caselstforCSL[1].contactId = testContact1.Id;
        caselstforCSL[1].Project_Service_Level__c = 'A3';
        caselstforCSL[1].Product_Service_Level__c = 'A2';
        caselstforCSL[1].SuppliedEmail = 'Test12.email@mailinator.com';
        caselstforCSL[1].Web_First_Name__c = 'TestName1';
        caselstforCSL[1].Web_Last_Name__c = 'Last ';
        caselstforCSL[1].Community_web_country__c = 'Algeria';
        caselstforCSL[2].SuppliedEmail = 'Test12.email@mailinator.com';
        caselstforCSL[2].contactId = testContact1.Id;
        caselstforCSL[2].Web_First_Name__c = 'TestName';
        caselstforCSL[2].Web_Last_Name__c = 'Last ';
        insert caselstforCSL;
        System.assert(caselstforCSL != null);
        test.stopTest();        
    }*/
    
    /*
    static testMethod void ownerAssignment1(){
        //case 1 :Route To case owner is not null and Route To Assigned is not null  
        List<Group> tslGrp = new List<Group>();
        User eachuser;
        Group grp = new Group(Name = 'TS L1 Inbox');
        tslGrp.add(grp);
        Group grp2 = new Group(Name = 'Deora test',Type = 'Queue');
        tslGrp.add(grp2);
        insert tslGrp;
        system.assert(tslGrp != null);
        
        String strEmail1 = 'test.thursdaycontact.member@abc.com.nxp';
        
        //fetch record type for accounts
        Id parentAccountTypeId = AccountHelper.getParentRecordTypeID();
        Id childAccountTypeId =  AccountHelper.getChildRecordTypeID();
        
        Account parentAccount = new Account(Name = 'Test Parent', RecordTypeId = parentAccountTypeId);
        insert parentAccount;
        system.assert(parentAccount.Id != null);
        
        Account childAccount = new Account(Name = 'Test Child', RecordTypeId = childAccountTypeId, ParentId = parentAccount.Id);
        insert childAccount;
        system.assert(childAccount.Id != null);
        
        Contact testNxpContact1 = new Contact(FirstName = 'test First', LastName = 'test Last', Email = strEmail1, 
                                           AccountId = childAccount.Id, Community_web_country__c = 'India',contact_service_level__c='A1');
        
        insert testNxpContact1;
        User Extuser = TestUtil.createTestUser('testCT1@gmail.com','CTMpass1',communityProfileId);
        Extuser.FirstName = 'NXPfirstCOA';
        Extuser.LastName ='NXPlastCOA';
        Extuser.ContactId = testNxpContact1.Id;
        insert Extuser;
        system.assert(Extuser != null);
        User Intuser = TestUtil.createTestUser('testCOA.intNxp@gmail.com','CaseOA',InternalAgentProfileId);
        Intuser.FirstName = 'InternalCOA';
        Intuser.LastName = 'TestuserCOA';
        insert Intuser;
        system.assert(Intuser.Id != null);
        eachuser = [SELECT Id,Name from user where Id = : Intuser.Id limit 1];
        String usrName = eachuser.Name;
        System.assert(usrName != null);
        system.assert(eachuser != null);
        Project__c newProject = new Project__c();
        system.runAs(Extuser){
        //case owner assignment when RCA and RTA is not null
        newProject = CasePortalTestUtil.createTestProject('Projecttest','In Development');
        newProject.Route_To_Case_Owner__c = eachuser.Name;
        newProject.Route_to_Assigned_to__c = eachuser.Id;
        newProject.Contract_End_Date__c = system.today().AddDays(1);
        insert newProject;
        System.assert(newProject.Route_To_Case_Owner__c != null);   
        System.assert(newProject.Route_to_Assigned_to__c != null);
        system.assert(newProject.Id != null);
            System.debug('###type'+newProject.Type__c);
        system.debug('####newProject.Id'+newProject.Id);
        }
        system.runAs(Intuser){
            newProject.Type__c = 'Paid';
            update newProject;
            system.assertEquals(newProject.Type__c, 'Paid');
        }
        case Case1;
        //create a case 
        test.startTest();
         system.runAs(Extuser){
             system.assert(Extuser.ContactId != null);
        Case1 = new Case(RecordTypeID = tscommunityRecordTypeId, Status= 'New', Priority = 'Medium', 
                                Subject = 'test_subject_1', Description = 'test_description_1', Projects__c = newProject.Id);
        insert Case1; 
        system.assert(Case1.Id != null);             
        }
        test.stopTest();
        Case eachcase = [SELECT Id,OwnerId,Assigned_to__c FROM case WHERE Id = : Case1.Id]; 
        system.assertEquals(eachuser.Id, eachcase.OwnerId);
        //system.assertEquals(newProject.Route_to_Assigned_to__c, eachcase.Assigned_to__c);
       
    }
      static testMethod void ownerAssignment2(){
        //case 2 :Route To case owner is null and Route To Assigned is null  
        List<Group> tslGrp = new List<Group>();
        Group grp = new Group(Name = 'TS L1 Inbox');
        tslGrp.add(grp);
        insert tslGrp;
        system.assert(tslGrp != null);
        
        String strEmail1 = 'test.thursdaycontact.member@abc.com.nxp';
        
        //fetch record type for accounts
        Id parentAccountTypeId = AccountHelper.getParentRecordTypeID();
        Id childAccountTypeId =  AccountHelper.getChildRecordTypeID();
        
        Account parentAccount = new Account(Name = 'Test Parent', RecordTypeId = parentAccountTypeId);
        insert parentAccount;
        system.assert(parentAccount.Id != null);
        
        Account childAccount = new Account(Name = 'Test Child', RecordTypeId = childAccountTypeId, ParentId = parentAccount.Id);
        insert childAccount;
        system.assert(childAccount.Id != null);
        
        Contact testNxpContact1 = new Contact(FirstName = 'test First', LastName = 'test Last', Email = strEmail1, 
                                           AccountId = childAccount.Id, Community_web_country__c = 'India',contact_service_level__c='A1');
        
        insert testNxpContact1;
        //create external user  
        User Extuser = TestUtil.createTestUser('testCT1@gmail.com','CTMpass1',communityProfileId);
        Extuser.FirstName = 'NXPfirstCOA';
        Extuser.LastName ='NXPlastCOA';
        Extuser.ContactId = testNxpContact1.Id;
        insert Extuser;
        system.assert(Extuser != null);
        //create internal user  
        User Intuser = TestUtil.createTestUser('testCOA.intNxp@gmail.com','CaseOA',InternalAgentProfileId);
        Intuser.FirstName = 'InternalCOA';
        Intuser.LastName = 'TestuserCOA';
        insert Intuser;
        system.assert(Intuser.Id != null);
       
        Project__c newProject = new Project__c();
        system.runAs(Extuser){
        //case owner assignment when RCA and RTA are null
        newProject = CasePortalTestUtil.createTestProject('Projecttest','In Development');
        newProject.Contract_End_Date__c = system.today().AddDays(1);
        insert newProject;
        System.assert(newProject.Route_To_Case_Owner__c == null);   
        System.assert(newProject.Route_to_Assigned_to__c == null);
        system.assert(newProject.Id != null);
        }
        system.runAs(Intuser){
            newProject.Type__c = 'Paid';
            update newProject;
            system.assertEquals(newProject.Type__c, 'Paid');
        }
        //create a case
        case Case1; 
        test.startTest();
         system.runAs(Extuser){
             system.assert(Extuser.ContactId != null);
        Case1 = new Case(RecordTypeID = tscommunityRecordTypeId, Status= 'New', Priority = 'Medium', 
                                Subject = 'test_subject_1', Description = 'test_description_1', Projects__c = newProject.Id);
        insert Case1; 
        system.assert(Case1.Id != null);    
        }
        test.stopTest();
        Case eachcase = [SELECT Id,OwnerId,Assigned_to__c FROM case WHERE Id = : Case1.Id];     
        system.assert(eachcase.OwnerId != null);
        system.assertEquals(null, eachcase.Assigned_to__c);
       
    }
    static testMethod void ownerAssignment3(){
        //case 1 :Route To case owner is not null and Route To Assigned is null  
        List<Group> tslGrp = new List<Group>();
        User eachuser = new User();
        Group grp = new Group(Name = 'TS L1 Inbox');
        tslGrp.add(grp);
        Group grp2 = new Group(Name = 'Deora test',Type = 'Queue');
        tslGrp.add(grp2);
        insert tslGrp;
        system.assert(tslGrp != null);
        
        String strEmail1 = 'test1.thursdaycontact.member@abc.com.nxp';
        
        //fetch record type for accounts
        Id parentAccountTypeId = AccountHelper.getParentRecordTypeID();
        Id childAccountTypeId =  AccountHelper.getChildRecordTypeID();
        
        Account parentAccount = new Account(Name = 'Test Parent', RecordTypeId = parentAccountTypeId);
        insert parentAccount;
        system.assert(parentAccount.Id != null);
        
        Account childAccount = new Account(Name = 'Test Child', RecordTypeId = childAccountTypeId, ParentId = parentAccount.Id);
        insert childAccount;
        system.assert(childAccount.Id != null);
        
        Contact testNxpContact1 = new Contact(FirstName = 'test First', LastName = 'test Last', Email = strEmail1, 
                                           AccountId = childAccount.Id, Community_web_country__c = 'India',contact_service_level__c='A1');
        
        insert testNxpContact1;
        User Extuser = TestUtil.createTestUser('testCT13@gmail.com','CTMpass1',communityProfileId);
        Extuser.FirstName = 'NXPfirstCOA';
        Extuser.LastName ='NXPlastCOA';
        Extuser.ContactId = testNxpContact1.Id;
        insert Extuser;
        system.assert(Extuser != null);
        User Intuser3 = TestUtil.createTestUser('testCOA3.intNxp@gmail.com','CaseOA',InternalAgentProfileId);
        Intuser3.FirstName = 'Int';
        Intuser3.LastName = 'TeCOA';
        insert Intuser3;
        system.assert(Intuser3.Id != null);
        eachuser = [SELECT Id,Name from user where Id = : Intuser3.Id limit 1];
        String usrName = eachuser.Name;
        System.assert(usrName != null);
        system.assert(eachuser != null);
        Project__c newProject = new Project__c();
        system.runAs(Extuser){
        //case owner assignment when RCA and RTA is not null
        newProject = CasePortalTestUtil.createTestProject('Projecttest','In Development');
        newProject.Route_To_Case_Owner__c = usrName;
        newProject.Contract_End_Date__c = system.today().AddDays(1);
        insert newProject;
        System.assert(newProject.Route_To_Case_Owner__c != null);   
        System.assert(newProject.Route_to_Assigned_to__c == null);
        system.assert(newProject.Id != null);
            System.debug('###type'+newProject.Type__c);
        system.debug('####newProject.Id'+newProject.Id);
        }
        system.runAs(Intuser3){
            newProject.Type__c = 'Paid';
            update newProject;
            system.assertEquals(newProject.Type__c, 'Paid');
        }
        //create a case 
        case Case1;
        test.startTest();
         system.runAs(Extuser){
             system.assert(Extuser.ContactId != null);
        Case1 = new Case(RecordTypeID = tscommunityRecordTypeId, Status= 'New', Priority = 'Medium', 
                                Subject = 'test_subject_1', Description = 'test_description_1', Projects__c = newProject.Id);
        insert Case1; 
        system.assert(Case1.Id != null);     
        }
        test.stopTest();
        Case eachcase = [SELECT Id,OwnerId,Assigned_to__c FROM case WHERE Id = : Case1.Id];     
        system.assertEquals(eachuser.Id, eachcase.OwnerId);
        system.assertEquals(null, eachcase.Assigned_to__c);
       
    }
     static testMethod void ownerAssignment4(){
        //case 1 :Route To case owner is null and Route To Assigned is not null  
        List<Group> tslGrp = new List<Group>();
        User eachuser;
        Group grp = new Group(Name = 'TS L1 Inbox');
        tslGrp.add(grp);
        Group grp2 = new Group(Name = 'Deora test',Type = 'Queue');
        tslGrp.add(grp2);
        insert tslGrp;
        system.assert(tslGrp != null);
        String strEmail1 = 'test4.thursdaycontact.member@abc.com.nxp';
        
        //fetch record type for accounts
        Id parentAccountTypeId = AccountHelper.getParentRecordTypeID();
        Id childAccountTypeId =  AccountHelper.getChildRecordTypeID();
        
        Account parentAccount = new Account(Name = 'Test Parent', RecordTypeId = parentAccountTypeId);
        insert parentAccount;
        system.assert(parentAccount.Id != null);
        
        Account childAccount = new Account(Name = 'Test Child', RecordTypeId = childAccountTypeId, ParentId = parentAccount.Id);
        insert childAccount;
        system.assert(childAccount.Id != null);
        
        Contact testNxpContact1 = new Contact(FirstName = 'test First', LastName = 'test Last', Email = strEmail1, 
                                           AccountId = childAccount.Id, Community_web_country__c = 'India',contact_service_level__c='A1');
        
        insert testNxpContact1;
        User Extuser = TestUtil.createTestUser('testCT14@gmail.com','CTMpass1',communityProfileId);
        Extuser.FirstName = 'NXPfirstCOA';
        Extuser.LastName ='NXPlastCOA';
        Extuser.ContactId = testNxpContact1.Id;
        insert Extuser;
        system.assert(Extuser != null);
        User Intuser = TestUtil.createTestUser('testCOA4.intNxp@gmail.com','CaseOA',InternalAgentProfileId);
        Intuser.FirstName = 'IntCOA4';
        Intuser.LastName = 'TesCOA4';
        insert Intuser;
        system.assert(Intuser.Id != null);
        eachuser = [SELECT Id,Name from user where Id = : Intuser.Id limit 1];
        system.assert(eachuser != null);
        Project__c newProject = new Project__c();
        system.runAs(Extuser){
        //case owner assignment when RCA and RTA is not null
        newProject = CasePortalTestUtil.createTestProject('Projecttest','In Development');
        newProject.Route_to_Assigned_to__c = Intuser.Id;
        newProject.Contract_End_Date__c = system.today().AddDays(1);
        insert newProject;
        System.assert(newProject.Route_To_Case_Owner__c == null);   
        System.assert(newProject.Route_to_Assigned_to__c != null);
        system.assert(newProject.Id != null);
            System.debug('###type'+newProject.Type__c);
        system.debug('####newProject.Id'+newProject.Id);
        }
        system.runAs(Intuser){
            newProject.Type__c = 'Paid';
            update newProject;
            system.assertEquals(newProject.Type__c, 'Paid');
        }
        case Case4;
        //create a case 
        test.startTest();
         system.runAs(Extuser){
             system.assert(Extuser.ContactId != null);
        Case4 = new Case(RecordTypeID = tscommunityRecordTypeId, Status= 'New', Priority = 'Medium', 
                                Subject = 'test_subject_1', Description = 'test_description_1', Projects__c = newProject.Id);
        insert Case4; 
        system.assert(Case4.Id != null);             
        }
        test.stopTest();
        Case eachcase4 = [SELECT Id,OwnerId, Assigned_to__c FROM case WHERE Id = : Case4.Id];
        system.assert(eachcase4.OwnerId != null);
       
    }*/
    
      static testMethod void ownerAssignment5(){
          //case 1 :Route To case owner is not null(group) Route To Assigned is not null 
        User eachuser;
        Group grp2 = new Group(Name = 'Deora test',Type = 'Queue');
        insert grp2;
        system.assert(grp2 != null);
        
        QueueSobject caseQueue = new QueueSObject(QueueID = grp2.id, SobjectType = 'Case');
        MixedDMLOps.ins(new List<QueueSobject>{caseQueue}) ;
          
        String strEmail1 = 'test5.thursdaycontact.member@abc.com.nxp';
        
        //fetch record type for accounts
        Id parentAccountTypeId = AccountHelper.getParentRecordTypeID();
        Id childAccountTypeId =  AccountHelper.getChildRecordTypeID();
        
        Account parentAccount = new Account(Name = 'Test Parent', RecordTypeId = parentAccountTypeId);
        insert parentAccount;
        system.assert(parentAccount.Id != null);
        
        Account childAccount = new Account(Name = 'Test Child', RecordTypeId = childAccountTypeId, ParentId = parentAccount.Id);
        insert childAccount;
        system.assert(childAccount.Id != null);
        
        Contact testNxpContact1 = new Contact(FirstName = 'test First', LastName = 'test Last', Email = strEmail1, 
                                           AccountId = childAccount.Id, Community_web_country__c = 'India',contact_service_level__c='A1');
        
        insert testNxpContact1;
        User Extuser = TestUtil.createTestUser('testCT15@gmail.com','CTMpass1',communityProfileId);
        Extuser.FirstName = 'NXPfirstCOA';
        Extuser.LastName ='NXPlastCOA';
        Extuser.ContactId = testNxpContact1.Id;
        insert Extuser;
        system.assert(Extuser != null);
        User Intuser = TestUtil.createTestUser('testCOA5.intNxp@gmail.com','CaseOA',InternalAgentProfileId);
        Intuser.FirstName = 'IntCOA5';
        Intuser.LastName = 'TesCOA5';
        insert Intuser;
        system.assert(Intuser.Id != null);
        eachuser = [SELECT Id,Name from user where Id = : Intuser.Id limit 1];
        system.assert(eachuser != null);
        Project__c newProject = new Project__c();
        system.runAs(Extuser){
        //case owner assignment when RCA and RTA is not null
        newProject = CasePortalTestUtil.createTestProject('Projecttest','In Development');
        newProject.Route_To_Case_Owner__c = 'Deora test';
        newProject.Route_to_Assigned_to__c = Intuser.Id;
        newProject.Contract_End_Date__c = system.today().AddDays(1);
        insert newProject;
        System.assert(newProject.Route_To_Case_Owner__c != null);   
        System.assert(newProject.Route_to_Assigned_to__c != null);
        system.assert(newProject.Id != null);
            System.debug('###type'+newProject.Type__c);
        system.debug('####newProject.Id'+newProject.Id);
        }
          
        system.runAs(Intuser)
        {
            newProject.Type__c = 'Paid';
            update newProject;
            system.assertEquals(newProject.Type__c, 'Paid');
        }
        case Case6;
        //create a case 
        test.startTest();
         system.runAs(Extuser){
             system.assert(Extuser.ContactId != null);
        Case6 = new Case(RecordTypeID = tscommunityRecordTypeId, Status= 'New', Priority = 'Medium', 
                                Subject = 'test_subject_1', Description = 'test_description_1', Projects__c = newProject.Id);
        insert Case6; 
        system.assert(Case6.Id != null);             
        }
        test.stopTest();
        case eachcase61;  
        eachcase61 = [SELECT Id,OwnerId, Assigned_to__c FROM case WHERE Id = : Case6.Id];
        system.assert(eachcase61.OwnerId != null);
       
    }

    
  
    
    @isTest static void testpopulateContactIdToCase(){
        //fetch record type for accounts
        Id parentAccountTypeId = AccountHelper.getParentRecordTypeID();
        Id childAccountTypeId =  AccountHelper.getChildRecordTypeID();
        
        Account parentAccount = new Account(Name = 'Test Parent', RecordTypeId = parentAccountTypeId);
        insert parentAccount;
        system.assert(parentAccount.Id != null);
        
        Account childAccount = new Account(Name = 'Test Child', RecordTypeId = childAccountTypeId, ParentId = parentAccount.Id);
        insert childAccount;
        system.assert(childAccount.Id != null);
        
        Contact currentOwnerContact = new Contact(FirstName = 'test First', LastName = 'test Last', Email = 'test.ncpcontact@mailinator.com', 
                                                  AccountId = childAccount.Id, Community_web_country__c = 'India');
        insert currentOwnerContact;
        System.assert(currentOwnerContact.Id != null);
        User currentOwner = TestUtil.createTestUser('test.ncpcontact@mailinator.com', 'testExt', communityProfileId);
        currentOwner.ContactId = currentOwnerContact.Id;
        insert currentOwner;
        System.assert(currentOwner.Id != null);
        System.assert(currentOwner.ContactId != null);
        List<case> eachCase = new List<case>();
        System.runAs(currentOwner){
            Project__c newProject = CasePortalTestUtil.createTestProject('Projecttest','In Development');
            insert newProject;
            System.assert(newProject.Id != null);    
            eachCase = CasePortalTestUtil.createCaseObject(1,tscommunityRecordTypeId,newProject.Id);
            insert eachCase;  
            System.assert(eachCase[0] != null);
        }
        Id caseId = eachCase[0].Id;
        System.assert(caseId != null);
        List<Case> newcase = [SELECT Id,ContactId FROM case WHERE Id =: caseId];
        System.assert(newcase[0].Id != null);
        System.assertEquals(currentOwnerContact.Id, newcase[0].ContactId);
    }
 
    @isTest static void testCaseSharingForProjectMovement()
    {
        //putting test.startTest and test.stopTest at random places not where actually it should be to solve 'too many soql query issue'
        
        Id childAccountTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Child Account').getRecordTypeId();        
        
        Account childAccount = new Account(Name = 'Test Child', RecordTypeId = childAccountTypeId); 
        insert childAccount;
        system.assert(childAccount.Id != null);
        
        String strOwnerEmail1 = 'test.owner@abc.nxp.com';
        String strOwnerEmail2 = 'other.owner@abc.nxp.com';
        String strMemberEmail1 = 'test.member@abc.com.nxp';
        String strMemberEmail2 = 'other.member@abc.com.nxp';
        
        Contact testOwnerContact1 = new Contact(FirstName = 'test First', LastName = 'test Last', Email = strOwnerEmail1, 
                                           AccountId = childAccount.Id, Community_web_country__c = 'India');
        Contact testOwnerContact2 = new Contact(FirstName = 'test First', LastName = 'test Last', Email = strOwnerEmail2, 
                                           AccountId = childAccount.Id, Community_web_country__c = 'India');
        
        Contact testMemberContact1 = new Contact(FirstName = 'test First', LastName = 'test Last', Email = strMemberEmail1, 
                                           AccountId = childAccount.Id, Community_web_country__c = 'India');        
        Contact testMemberContact2 = new Contact(FirstName = 'other First', LastName = 'other Last', Email = strMemberEmail2, 
                                           AccountId = childAccount.Id, Community_web_country__c = 'India');
        
        List<Contact> lstContacts = new List<Contact>();
        lstContacts.add(testOwnerContact1);
        lstContacts.add(testOwnerContact2);
        lstContacts.add(testMemberContact1);
        lstContacts.add(testMemberContact2);
        
        insert lstContacts;
        
        system.assert(lstContacts[0].Id != null);
        system.assert(lstContacts[1].Id != null);
        system.assert(lstContacts[2].Id != null);
        system.assert(lstContacts[3].Id != null);
        
        Id communityUserProfileId = CasePortalTestUtil.fetchProfileId(CasePortalUtil.COMMUNITY_PLUS_USER_PROFILE);
        
        List<User> lstUsers = new List<User>();
        User ownerUser1 = TestUtil.createTestUser(strOwnerEmail1, 'testExt', communityUserProfileId);
        ownerUser1.ContactId = testOwnerContact1.Id;
        lstUsers.add(ownerUser1);
        
        User memberUser1 = TestUtil.createTestUser(strMemberEmail1, 'testExt', communityUserProfileId);
        memberUser1.ContactId = testMemberContact1.Id;
        lstUsers.add(memberUser1);
        
        User ownerUser2 = TestUtil.createTestUser(strOwnerEmail2, 'testExt', communityUserProfileId);
        ownerUser2.ContactId = testOwnerContact2.Id;
        lstUsers.add(ownerUser2);
        
        User memberUser2 = TestUtil.createTestUser(strMemberEmail2, 'testExt', communityUserProfileId);
        memberUser2.ContactId = testMemberContact2.Id;
        lstUsers.add(memberUser2);
        
        test.startTest();
        insert lstUsers;       
        system.assert(lstUsers[0].Id != null);
        system.assert(lstUsers[1].Id != null);
        system.assert(lstUsers[2].Id != null);
        system.assert(lstUsers[3].Id != null);
        
        Project__c testProject1;
        Project__c testProject2;
        
        Project_Team__c testMember1;
        Project_Team__c testMember2;
        
        Case objCase;        
        
        system.runAs(ownerUser1)
        {
            testProject1 = CasePortalTestUtil.createTestProject('TestProject', 'In Development');
            insert testProject1;        
            system.assert(testProject1.Id != null);
            
            testMember1 = CasePortalTestUtil.createTestProjectTeam(testProject1.Id, strMemberEmail1, CasePortalUtil.PROJECT_TEAM_STATUS_INVITED );
            insert testMember1;
            system.assert(testMember1.Id != null);
    
            Id tscommunityRecordType = Schema.SObjectType.Case.getRecordTypeInfosByName().get('TS Community').getRecordTypeId();
            objCase = new Case(RecordTypeID = tscommunityRecordType, contactId = testOwnerContact1.Id, Status= 'New', Priority = 'Medium', 
                                    Subject = 'test_subject_1', Description = 'test_description_1', Projects__c = testProject1.Id); 
            insert objCase;        
            system.assert(objCase.Id != null);    
        }
        
        test.StopTest();
        
        testMember1.Status__c = CasePortalUtil.PROJECT_TEAM_STATUS_ACCEPTED;
        update testMember1;
        //since sharing on project record is given through chained queueable jobs and that does not work in test context
        // so invoke CasePortalUtil method to grant project/case sharing explicitly
        CasePortalUtil.shareProjectAccessToTheTeam( new Set<Project_Team__c>{testMember1} , true, true); 
        
        //create another project for movement        
        system.runAs(ownerUser2)
        {
            testProject2 = CasePortalTestUtil.createTestProject('TestProject2', 'In Development');
            insert testProject2;        
            system.assert(testProject2.Id != null);
            
            testMember2 = CasePortalTestUtil.createTestProjectTeam(testProject2.Id, strMemberEmail2, CasePortalUtil.PROJECT_TEAM_STATUS_INVITED );
            insert testMember2;
            system.assert(testMember2.Id != null);
        }
        
        testMember2.Status__c = CasePortalUtil.PROJECT_TEAM_STATUS_ACCEPTED;
        update testMember2;
       
        //change the project for the case
        objCase.Projects__c = testProject2.Id;
        update objCase;
       
        //assert the results
        List<CaseShare> lstCaseShares = [Select Id, UserOrGroupId, CaseAccessLevel From CaseShare Where CaseId =: objCase.Id 
                                         and RowCause =: CasePortalUtil.SHARING_REASON];
        //system.assert(lstCaseShares.size() == 2);
        
        Set<Id> expectedUserIds = new Set<Id>();
        expectedUserIds.add(ownerUser2.Id);
        expectedUserIds.add(memberUser2.Id);
        
        for(CaseShare objShare : lstCaseShares)
        {
            system.assert(objShare.CaseAccessLevel == 'Edit');
            system.assert(expectedUserIds.contains(objShare.UserOrGroupId));  
        }
    }    
    
}