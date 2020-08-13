@isTest    
private class EntitlementToProjectMigrationTest{
       @testSetup 
    static void setup() {
    
    Account accRecord = new Account();
    accRecord.Name = 'NXP Community';
    insert accRecord;       
    
    Entitlement entRecord = new Entitlement();
    entRecord.Name = 'development';
    entRecord.accountId = accRecord.id;
    entRecord.Additional_Description__c = 'test';
    entRecord.Type = 'Free';
    insert entRecord;
    
    }
    static testmethod void test() {  
         Test.startTest();
         EntitlementToProjectMigration etp = new EntitlementToProjectMigration('isMigrated__c = false');
         Id batchId = Database.executeBatch(etp);     
         Test.stopTest(); 
       }
    
}