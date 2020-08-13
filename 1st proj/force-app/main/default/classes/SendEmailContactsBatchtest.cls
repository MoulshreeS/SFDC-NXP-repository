@isTest
public class SendEmailContactsBatchtest {
    
         @testSetup
   
    static  void setup(){
        
        Contact con = new Contact(FirstName='Test',LastName='Contact',  Title = 'strTitle',email='test@nxp.com',Community_web_country__c = 'India');
        insert con;
        Contact con1 = new Contact(FirstName='Test1',LastName='Contact1',  Title = 'strTitle1',email='test1@nxp.com',Community_web_country__c = 'India');
        insert con1;
        Lead l = new Lead(lastname='Test',Status = 'Open',Company = 'test',Distributor_Contact__c=con.id
                          ,Disti_Feedback_Email_Address__c = 'test1@nxp.com');
        insert l;
                Lead ll = new Lead(lastname='Test2',Status = 'Open',Company = 'test2',Distributor_Contact__c=con.id
                          ,Disti_Feedback_Email_Address__c = 'test2@nxp.com');
        
        insert ll;
  
    }
    
            @istest
    static  void testmethod1(){ 
        Test.startTest();
            SendEmailContactsBatch  a = new SendEmailContactsBatch();
        	DataBase.executeBatch(a);
        String CRON_EXP = '0 0 0 3 9 ? 2022';
        String jobId = System.schedule('testBasicScheduledApex', CRON_EXP, new SendEmailContactsBatch());
        Test.stopTest();
        
    }

}