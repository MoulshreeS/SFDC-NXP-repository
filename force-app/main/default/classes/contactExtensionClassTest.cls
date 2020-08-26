@isTest
private class contactExtensionClassTest
{
       static testMethod void check()
       {
                   
            Account parentAcc = new Account(Name = 'Parent Account', RecordTypeId = '01220000000E4Ja');
            insert parentAcc;
            Account childAcc = new Account(Name = 'Child Account', RecordTypeId = '01220000000E4JY', parentId= parentAcc.Id,Region__c ='Americas');
            insert childAcc;
            Contact con = new Contact(FirstName = 'Test' , LastName ='Conatct', AccountId = childAcc.Id, Community_web_country__c = 'India');
            insert con;
            Test.StartTest();
            system.debug('test ob1j1' +con);
            PageReference pageRef = Page.pilotPage;
            pageRef.getParameters().put('id', string.valueOf(con.id));
            Test.setCurrentPage(pageRef);
            ApexPages.Standardcontroller sc = new ApexPages.Standardcontroller(con);
            system.debug('test ob1j' +sc);
            contactExtensionClass obj = new contactExtensionClass(sc);
            system.debug('test obj' +obj);
            System.assertNotEquals(null,obj.backToContact());

           // System.assertEquals (con.id,pageRef);
            Test.StopTest();

        }
}