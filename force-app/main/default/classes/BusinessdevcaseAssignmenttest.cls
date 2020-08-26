/*************************************************************************
@Created By:     Manikanta
@Description:    Test class to  Assign owners for  Business Development Cases.
**************************************************************************/

@istest
public class BusinessdevcaseAssignmenttest {
    public final static String CASE_BUSINESSDEVELOPMENT = 'Business Development';
    public static final String TEST_USER_PROFILE = 'Standard User';
    public static final String TEST_USER_EMAIL_0 = 'testuser@testorg.com.test';
    public static final String TEST_USER_EMAIL_1 = 'testuser1@testorg.com.test';
    public static list<User> listUser=new list<user>();
     @testSetup
    static void setup(){
        test.startTest();
        
         Profile p = [SELECT Id FROM Profile WHERE Name = :TEST_USER_PROFILE];
        
        User u = new User(Alias = 'BD', Email = TEST_USER_EMAIL_0, 
                          EmailEncodingKey = 'UTF-8', LastName = 'Testing', LanguageLocaleKey = 'en_US', 
                          LocaleSidKey = 'en_US', TimeZoneSidKey = 'America/Los_Angeles',
                          ProfileId = p.Id, UserName = TEST_USER_EMAIL_0);
        listUser.add(u);
        
        User u2 = new User(Alias = 'test1', Email = TEST_USER_EMAIL_1, 
                           EmailEncodingKey = 'UTF-8', LastName = 'Testing', LanguageLocaleKey = 'en_US', 
                           LocaleSidKey = 'en_US', TimeZoneSidKey = 'America/Los_Angeles',
                           ProfileId = p.Id, UserName = TEST_USER_EMAIL_1);
        listUser.add(u2);
        insert listuser;
              //Insert Accounts
        Account a = new Account(Name = 'Test Account', Region__c = 'EMEA',customer_category__c='Tier 4 - TMMA',
                               country__c='Austria',state_province__c='Test State',Role__c='Distributor');        
        insert a;
        
        	Group g1 = new Group(Name='Business Development', type='Queue');
            insert g1;
        QueuesObject q1;
        System.runAs(new User(Id=UserInfo.getUserId()))
{
        
             q1 = new QueueSObject(QueueID = g1.id, SobjectType = 'Case');
            insert q1;
}
        
        Id bdid =Schema.SObjectType.Case.getRecordTypeInfosByName().get('Business Development').getRecordTypeId();
       // group bdgroup = [select id from group where Name='Business Development'];
        
        case c = new case();
        c.Subject = '{USERID:'+ u2.id + '}' + 'UserID not exists in Business development queue';
        c.Description ='UserID not exists in Business development queue';
        c.Community_Web_Country__c = 'India';
        c.RecordTypeId = bdid;
        c.OwnerId = g1.id;
         insert c;
        
        case cqueue = new case();
        cqueue.Subject = '{QUEUEID:'+ g1.id + '}' + 'UserID not exists in Business development queue';
        cqueue.Description ='Assign to QueueiD given in subject';
        cqueue.Community_Web_Country__c = 'USA';
        cqueue.RecordTypeId = bdid;
        cqueue.OwnerId = g1.id;
         insert cqueue;
          test.stopTest();
        
    }
    
    @istest
    static  void businessdevtest(){ 
        BusinessdevcaseAssignment c = new BusinessdevcaseAssignment();
		database.executeBatch(c);
       // Case cas = [select id,ownerId from case where Community_Web_Country__c = 'USA'];
        //group use =[select id from group where Name='Business Development' limit 1];
       // system.assertEquals(cas.OwnerId, use.id);
    }
        

}