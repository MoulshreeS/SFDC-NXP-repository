/*************************************************************************
@Created By:     Manikanta
@Description:    Test class for Countofactivities Trigger
**************************************************************************/
@isTest
public class CountofActivitiestest {
    
           @istest
    static  void testmethod1(){ 
        
        Lead leadrec = new Lead( LastName = 'TestLead', 
                                company= 'Testcompany', 
                                Job_Description__c = 'Director', Normalized_Title__c ='Consultant',
                                Industry = 'TestIndustry',email = 'test@nxp.com',Country ='India',status = 'Open');  
        insert leadrec;
        
                Lead_activity__c leadact =new Lead_activity__c(Action__c ='Ordered',Object__c='TestObject',Specific_Interest__c='Test',related_to_lead__c = leadrec.id);    
   insert leadact;
    
   delete leadact;
    }
    
    

}