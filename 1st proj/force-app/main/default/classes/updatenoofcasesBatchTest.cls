@isTest
public class updatenoofcasesBatchTest {
    Private static Id tscommunityRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('TS Community').getRecordTypeId();

    
    static testmethod void test() {  
         
         //Insert Account
            List<Account> newAccount=CasePortalTestUtil.createTestParentAccount(1);
            insert newAccount;
            System.assert(newAccount[0].Id!=Null);
            
         //Insert Contact 
         List<Contact> contactList=CasePortalTestUtil.createTestContact(1,newAccount[0].Id,'case.contact@customer.com','lstNameTest');
         insert contactList;
         System.assert(contactList[0].Id!=Null);
    
         Project__c Projectest = CasePortalTestUtil.createTestProject('Projecttest1','In Development');
         insert Projectest;
         
          Test.startTest();
       
         List<Case> caselst = CasePortalTestUtil.createCaseObject(1,tscommunityRecordTypeId,Projectest.Id);
         caselst[0].ContactId = contactList[0].Id;
         insert caselst;
        
         
         
         String que = ' '+' Limit 1';
         UpdateNoOfCasesBatch etp = new UpdateNoOfCasesBatch(que);
         Id batchId = Database.executeBatch(etp);  
         //if(caselst.size()>0){
            //System.assert(Projectest.Cases_Per_Project__c == caselst.size());
         //}
         Test.stopTest(); 
       }
}