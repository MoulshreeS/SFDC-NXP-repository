/***************************************************************************************************
@Created By :      Ranganath C N
@Created Date:     18 May 2018
@Description:      SFDC-1601-Webservice to get CaseDetails 
*******************************************************************************************************/
/***************************************************************************************************
@Modified By :     Gunjan Singh
@Created Date:     16 Oct 2018
@Description:      SFDC-2237-Modify Test Class for Webservice GetCaseInformation
*******************************************************************************************************/

@isTest   
private class CaseServiceTest {

  static testMethod void testDoGet() {
  
             Profile profileId = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
  
             User usr = new User(LastName = 'CN',
                           FirstName='rang',
                           Alias = 'ran',
                           Email = 'test1234@CN.BOSCH.COM',
                           Username = 'test@CN.BOSCH.COM',
                           ProfileId = profileId.Id,
                           TimeZoneSidKey = 'GMT',
                           LanguageLocaleKey = 'en_US',
                           EmailEncodingKey = 'UTF-8',
                           LocaleSidKey = 'en_US'
                           );
                           insert usr;
         
            Account testaccount = new Account();
            testaccount.Name='john';
            insert testaccount;
            
            Contact testcontact = new Contact();
            testcontact.LastName = 'CNR';
            testcontact.email='test@CN.BOSCH.COM';
            testcontact.Community_web_country__c = 'testcountry';            
            insert testcontact;
            
            Product2 testproduct = new Product2();
            testproduct.Name='john';
            insert testproduct ;
         
    
            Case cont = new Case(       
                                    Case_Owner_Name__c = 'Ranganath CN',
                                    contactId = testContact.Id,
                                    Assigned_To__c = usr.Id,
                                    subject = 'testing',
                                    priority = 'Low',
                                    status = ' New',
                                    description= 'testing cases',
                                    origin= 'Phone',
                                    My_Question_is_Related__c= 'Web',
                                    email__c = 'test@CN.BOSCH.COM',
                                    Company__c= 'uyiuyi ',
                                    Community_Web_Country__c= 'yiiuyi',
                                    Product_Category__c = 'RF',
                                    Product_Sub__c = 'Mixers',
                                    JobTitle__c = 'Other',
                                    Facebook__c = 'test_fb',
                                    Twitter__c = 'test_twt',
                                    State_Province__c = 'test_state',
                                    Product_Type_Number__c = 'test',
                                    Product_application__c = 'test', 
                                    Expected_annual_unit_volume__c = 'test',
                                    Project_Stage__c = 'Development',
                                    Web_Region__c = 'Test_region'
                                   );
            insert cont;
         
            RestContext.request = new RestRequest();
            RestContext.request.params.put('CaseIdOrEmail', 'test1234@CN.BOSCH.COM');
            RestContext.request.params.put('StatusFilter', 'New,In Progress');
            RestContext.request.params.put('OriginFilter', 'Phone'); 
            RestContext.request.httpMethod = 'GET';
            List<CaseService.CaseDetailsToBeSent> results = CaseService.getCaseInformation();
            
            RestContext.request = new RestRequest();
            RestContext.request.params.put('StatusFilter', 'New,In Progress');
            RestContext.request.params.put('OriginFilter', 'Phone'); 
            RestContext.request.httpMethod = 'GET';
            List<CaseService.CaseDetailsToBeSent> results1 = CaseService.getCaseInformation();
            
            RestContext.request = new RestRequest();
            RestContext.request.params.put('CaseIdOrEmail', cont.Id);
            RestContext.request.params.put('StatusFilter', 'New,In Progress');
            RestContext.request.params.put('OriginFilter', 'Phone'); 
            RestContext.request.httpMethod = 'GET';
            List<CaseService.CaseDetailsToBeSent> results2 = CaseService.getCaseInformation();

  } 

}