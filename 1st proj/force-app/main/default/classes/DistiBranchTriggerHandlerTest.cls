@isTest
public class DistiBranchTriggerHandlerTest {
    
    @testSetup
    static void setup(){
        List<Disti_Branches__c> brancheslist = new List<Disti_Branches__c>();
        brancheslist.add(new Disti_Branches__c(Name = 'Test Branch 1'));
        insert brancheslist;
        
        List<Contact> lstContacts = new List<Contact>();
        lstContacts.add(new Contact(LastName = 'Disti Contact 1',Community_web_country__c = 'India',Email = 'test0062@nxp.com'));
        Insert lstContacts;
        
        
    }
    static testMethod void testDistiBranchTrigger()
    {
        Test.startTest();
        Contact c1 = [select id from contact where lastname = 'Disti Contact 1'];
        Disti_Branches__c d1 = [select id from Disti_Branches__c where Name = 'Test Branch 1'];
        List<Disti_Branch_Contact_Role__c> dblist = new List<Disti_Branch_Contact_Role__c>();
        dblist.add(new Disti_Branch_Contact_Role__c(contact__c = c1.id, Disti_Branch__c = d1.id,contact_Role__c = 'Main Distributor Contact'));
        
        Insert dblist;
        
        Lead l = new Lead();
        l.lastname = 'tes lead';
        l.Distributor_Contact__c = c1.id;
        l.Company = 'test company';
        insert l;
        
        Disti_Branches__c distB =[select id from Disti_Branches__c where name =: 'Test Branch 1'];
        distB.name = 'Test Branch4';
        update distB;
          
        Test.stopTest();
        System.assertEquals(distB.name, 'Test Branch4');
        Lead le = [select Disti_Branch_Name__c from lead where lastname = 'tes lead'];
        System.assertEquals(le.Disti_Branch_Name__c, distB.name);
    }
    
    
}