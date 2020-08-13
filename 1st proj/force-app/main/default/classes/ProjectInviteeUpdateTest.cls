@isTest    
private class ProjectInviteeUpdateTest{
       @testSetup 
    static void setup() {
        
            Account accRecord = new Account();
            accRecord.Name = 'NCP Community';
            insert accRecord;
            
            Account ACCId = [ Select Id From Account Where Name = 'NCP Community'];
            
            Contact testcontact = new Contact();
            testcontact.LastName = 'CNR';
            testcontact.Email='test@test.com';
            testcontact.Community_web_country__c = 'testcountry';
            testcontact.AccountId = ACCId.Id;          
            insert testcontact;
            
            Contact Con = [ Select Id From Contact where Email ='test@test.com' Limit 1];
    
           profile profileId = [SELECT Id FROM Profile WHERE Name = 'NXP Customer Community Login User' LIMIT 1]; 
     
             User usr = new User(LastName = 'CN',
                           FirstName='rang',
                           Alias = 'ran',
                           Email = 'test@test.com',
                           Username = 'test@CN.BOSCH.COM',
                           ProfileId = profileId.Id,
                           TimeZoneSidKey = 'GMT',
                           LanguageLocaleKey = 'en_US',
                           EmailEncodingKey = 'UTF-8',
                           ContactId = Con.Id,
                           LocaleSidKey = 'en_US'
                           );
                           insert usr; 
                           
                           
                           
                          Project__c newProjectTest = new Project__c ();
        newProjectTest.Name = 'development';    
        newProjectTest.Contract_End_Date__c = system.today().AddDays(10);
        //newProjectTest.Contract_Status__c = 'Active'; 
        //newProjectTest.Project_Service_Level__c = 'High';
        newProjectTest.Type__c='Free';
       // newProjectTest.Project_Service_Level__c = 'Medium';
        newProjectTest.Total_Number_of_Hours__c = 50;
        newProjectTest.End_Application_Type__c = 'Banking';
        newProjectTest.Project_Stage__c ='In Development';
        newProjectTest.Project_Annual_Volume__c = 'Unknown';
        newProjectTest.End_Application_Name__c = 'tcs';
                
        Insert newProjectTest;        
                        
                           Project__c Project = [ Select id From Project__c Where Name = 'development'];
                           
                           Project_Team__c PrjTeam = New Project_Team__c ();
                            PrjTeam.Project__c = Project.Id;
                            PrjTeam.Email_Address__c = 'test@test.com';
                            PrjTeam.First_Name__c = 'Ajit';
                            PrjTeam.Last_Name__c = ' Singh';
                            PrjTeam.Company__c = 'Tcs';
                            PrjTeam.Role__c = 'Participant';
                            PrjTeam.Status__c = 'Accepted';
                            
                            Insert PrjTeam;
                            
                            }
                            
                            static testmethod void test() {  
         Test.startTest();
         ProjectInviteeUpdate PriU = new ProjectInviteeUpdate();
         Id batchId = Database.executeBatch(PriU );     
         Test.stopTest(); 
         
        

       }
      }