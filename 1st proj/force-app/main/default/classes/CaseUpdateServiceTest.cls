/*------------------------------------------------------------------------------------------------------------------------------------
 * Created By   : Gunjan
 * Created Date : 24 Aug,2018
 * Description  : Test class to update some fields on case using webservice for SFDC-1971 and SFDC-2198
 ------------------------------------------------------------------------------------------------------------------------------------*/
@isTest(seeAllData = false)
private class CaseUpdateServiceTest {
  static User userRecord;
  
  static testMethod void testCaseUpdateService(){
    test.starttest();
    loadUserData();
    Account accRecord = new Account();
    accRecord.Name = 'NXP Community';
    insert accRecord;
            
    Contact conRecord = new Contact();
    conRecord.accountId = accRecord.id;
    conRecord.LastName = 'T';
    conRecord.Email = 'testuser@nxptest.com';
    conRecord.Community_web_country__c = 'testcountry';
    insert conRecord;
    
    Entitlement entRecord = new Entitlement();
    entRecord.Name = 'development';
    entRecord.accountId = accRecord.id;
    insert entRecord;
              
    Entitlement_Contact__c entconRecord = new Entitlement_Contact__c();
    entconRecord.Entitlement__c= entRecord.id;
    entconRecord.Contact__c=conRecord.id;
    insert entconRecord;
    
    List<Case> lstCase = new List<Case>();
    Case cse = new Case();
    cse.subject ='test';
    cse.Status = 'Close';
    cse.Assigned_to__c = userRecord.Id;
    cse.contactid=conRecord.id;
    cse.EntitlementId=entRecord.id;
    cse.FeedItemId = NULL;
    lstCase.add(cse);
    
    
    Case cse1 = new Case();
    cse1.subject ='test';
    cse1.Status = 'Close';
    cse1.Assigned_to__c = userRecord.Id;
    cse1.contactid=conRecord.id;
    cse1.EntitlementId=entRecord.id;
    cse1.FeedItemId = NULL;
    lstCase.add(cse1);
    Insert lstCase;
    test.stoptest();
    
    Case caseObj = new Case();
    caseObj = [select id, casenumber from case where id = : lstCase[0].id];
    System.debug('case number' + caseObj.casenumber);  
      
   CaseUpdateService.CaseInputDetails con = new CaseUpdateService.CaseInputDetails();
   con.CaseID =lstCase[0].Id;
   con.CaseNumber = lstCase[0].CaseNumber;
   con.CaseStatus = 'Close';
   con.Priority = 'Low';
   con.FeedMessage='Update the feed message';
   con.CaseOwner='TS L1 Inbox';
   con.CaseAssignedTo='sudhish.nair@nxp.com';
   con.Topic='Documentation';
   con.LastContactToCustomer= system.now();
   con.CommunityGroupName='test';
   con.CommunityTopicName='test';
   con.CommunityOriginID='test';
   con.CommunityQuestionURL='test';
   con.QuestionResolutionCode=132;
   
   CaseUpdateService.CaseInputDetails con1 = new CaseUpdateService.CaseInputDetails();
   con1.CaseNumber=caseObj.casenumber;
   con1.CaseStatus = 'Closed Fully';
   con1.Priority = 'Low';
   con1.FeedMessage='Update the feed message';
   con1.CaseOwner='TS L1 Inbox';
   con1.CaseAssignedTo='sudhish.nair@nxp.com';
   con1.Topic='Documentation';
   con1.LastContactToCustomer= system.now();
   con1.CommunityGroupName='test';
   con1.CommunityTopicName='test';
   con1.CommunityOriginID='test';
   con1.CommunityQuestionURL='test';
   con1.QuestionResolutionCode=123;
   
   CaseUpdateService.CaseInputDetails con2 = new CaseUpdateService.CaseInputDetails();
   con2.CaseStatus = 'Closed';
   con2.Priority = 'Low';
   con2.FeedMessage='Update the feed message';
   con2.CaseOwner='TS L1 Inbox';
   con2.CaseAssignedTo='sudhish.nair@nxp.com';
   con2.Topic='Documentation';
   con2.LastContactToCustomer= system.now();
   con2.CommunityGroupName='test';
   con2.CommunityTopicName='test';
   con2.CommunityOriginID='test';
   con2.CommunityQuestionURL='test';
   con2.QuestionResolutionCode=123;
   
   
    RestRequest request = new RestRequest();
    request.requestUri ='/services/apexrest/CaseUpdateService/';
    request.httpMethod = 'PATCH';
    RestContext.request = request;      
    CaseUpdateService.OutputMessage results = CaseUpdateService.updateCase(con);
    CaseUpdateService.OutputMessage results1 = CaseUpdateService.updateCase(con1);
    CaseUpdateService.OutputMessage results2 = CaseUpdateService.updateCase(con2);
 
  }
  
  
   static void loadUserData(){
   
    Profile p = [SELECT Id FROM Profile WHERE Name LIKE '%System Administrator%' limit 1]; 
 
    userRecord = new User ();
    //userRecord.Email = 'gunjan.singh1@nxp.com';
    userRecord.Email = CommonUtils.generateGUID() + '@nxp.com.test123';
    userRecord.userName = CommonUtils.generateGUID() + '@nxp.com.test123';
    //userRecord.userName = 'gunjan.singh1@nxp.com';
    userRecord.firstName='New';
    userRecord.LastName='Testing';
    userRecord.EmailEncodingKey='UTF-8';
    userRecord.LanguageLocaleKey='en_US';  
    userRecord.LocaleSidKey='en_US'; 
    userRecord.TimeZoneSidKey='America/Los_Angeles';
    userRecord.ProfileId = p.Id;
    userRecord.Alias = 'standt';
    insert userRecord;
   
   }
  
}