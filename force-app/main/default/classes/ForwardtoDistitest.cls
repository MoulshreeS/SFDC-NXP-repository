@isTest
public class ForwardtoDistitest {
    
     @testSetup
    static void setup(){
        
        Contact con = new Contact(FirstName='Test',LastName='Contact',  Title = 'strTitle',email='test@nxp.com',Community_web_country__c = 'India');
        insert con;
        Contact con1 = new Contact(FirstName='Test',LastName='Contact',  Title = 'strTitle',email='test1@nxp.com',Community_web_country__c = 'India');
        insert con1;
        Lead l = new Lead(lastname='Test',Status = 'Open',Company = 'test',Distributor_Contact__c=con.id
                          ,Disti_Feedback_Email_Address__c = 'test1@nxp.com');
        insert l;
    
    }
    
        @isTest
    static void testupdatelead(){
        
        Test.startTest();
     		Lead l = [select id,Disti_Feedback_Email_Address__c from Lead];
        Forwardtodisti.updatelead(l.id);
        
        Contact c = [select id,email from contact where email = 'test1@nxp.com'];
        system.assertEquals(c.email, l.Disti_Feedback_Email_Address__c);
        Test.stopTest();
    }

}