@isTest    
private class SharingDataMigrationTest1{
       @testSetup 
    static void setup() {
    
    
        Project__c newProjectTest = new Project__c ();
        newProjectTest.Name = 'testproject';    
        newProjectTest.Contract_End_Date__c = system.today().AddDays(10);
        //newProjectTest.Contract_Status__c = 'Active'; 
        newProjectTest.Route_To_Case_Owner__c = 'NXPfirst NXPlast';
    //    newProjectTest.Project_Service_Level__c = 'High';
        newProjectTest.Type__c='Paid';
       // newProjectTest.Project_Service_Level__c = 'Medium';
        newProjectTest.Total_Number_of_Hours__c = 50;
        newProjectTest.End_Application_Type__c = 'Banking';
        newProjectTest.Project_Stage__c ='In Development';
        newProjectTest.Project_Annual_Volume__c = 'Unknown';
        newProjectTest.End_Application_Name__c = 'tcs';
                
        Insert newProjectTest;        
        Project__c Projecttest = [Select id from Project__c where Name = 'testproject'];      
       
    Project_Team__c projectTeam = new Project_Team__c ();
    projectTeam.First_Name__c = 'test';
    projectTeam.Last_Name__c = 'test name';
    projectTeam.Email_Address__c = 'test@test.com';
    projectTeam.Role__c = 'Participant';
    projectTeam.Status__c ='Accepted';
    projectTeam.Project__c = Projecttest.id;   
    Insert projectTeam;
    
    }
    
      static testmethod void test() {  
         Test.startTest();
         SharingDataMigration1 SDM = new SharingDataMigration1('Limit 1');
         Id batchId = Database.executeBatch(SDM);     
         Test.stopTest(); 
       }
    
    
  }