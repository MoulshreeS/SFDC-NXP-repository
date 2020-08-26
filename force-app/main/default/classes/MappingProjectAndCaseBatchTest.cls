@isTest    
private class MappingProjectAndCaseBatchTest{

       @testSetup 
    static void setup(){
        
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
             
              Entitlement entRecord = new Entitlement();
              entRecord.Name = 'development';
              entRecord.accountId = testaccount.id;
              entRecord.Additional_Description__c = 'test';
              entRecord.Type = 'Free';
              insert entRecord; 
              
              Entitlement Ent = [Select Id from Entitlement Where Name= 'development'];
              
              Project__c testproject  = new project__c();
            testproject.Name = 'development'; 
            testproject.Type__c = 'Free';  
            testproject.Additional_Description__c = 'test'; 
            testproject.EntitlementId__c = Ent.Id;
            
            insert testproject;
            Contact testcontact = new Contact();
            testcontact.LastName = 'CNR';
            testcontact.email='test@CN.BOSCH.COM';
            testcontact.Community_web_country__c = 'testcountry';            
            insert testcontact;
            
             RecordType  caseRecordTypeId = [SELECT Id FROM RecordType WHERE Name = 'TS Community'];
            
           case cse= new Case(Priority = 'Low', contactid = testContact.Id, Description = 'Test Case',Status = 'New',EntitlementId = Ent.Id,
                                   RecordTypeId = caseRecordTypeId.Id ,Subject = 'Test',Topics__c = 'Documentation');
                                   Insert cse;
            }
            
         static testmethod void test() {  
         Test.startTest();
         MappingProjectAndCaseBatch MPCB = new MappingProjectAndCaseBatch ('EntitlementId__c != null');
         Id batchId = Database.executeBatch(MPCB);     
         Test.stopTest(); 
         
         }
      }