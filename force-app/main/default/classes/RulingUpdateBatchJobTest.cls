@isTest
public class RulingUpdateBatchJobTest {
     
     @testSetup
   
    static  void setup(){
      /* 
         List<Ruling_Table__c> rulelist= new List<Ruling_Table__c>();
	        for(Integer i=0 ;i<100;i++){
            Ruling_Table__c rule = new Ruling_Table__c();
            rule.Name ='Test';
            rule.Object_Name__c = 'Lead';
            rule.Field_Name__c='Name';
            rule.Field_Value__c = 'Test';
            rule.Query__c = 'where id != null';
            rule.Active__c = true;
            rulelist.add(rule);
        }
        Insert rulelist;
*/
        
                 //Insert Accounts
        Account a = new Account(Name = 'Test Account', Region__c = 'EMEA',customer_category__c='Tier 4 - TMMA',
                               NXP_GID__c='12145',country__c='Austria',state_province__c='Test State',Role__c='Distributor');        
        insert a;
 
    }
        @istest
    static  void testmethod1(){ 
        Test.startTest();
     
        RulingUpdateBatchJob a = new RulingUpdateBatchJob();
        
		DataBase.executeBatch(a);
       datetime dt = System.now().addMinutes(-500);
       
        Updateobject u =new Updateobject('where id != null','Account','Name','Test',dt);
        DataBase.executeBatch(u);
       
        String CRON_EXP = '0 0 0 3 9 ? 2022';
        String jobId = System.schedule('testBasicScheduledApex', CRON_EXP, new RulingUpdateBatchJob());

           Test.stopTest();
}
}