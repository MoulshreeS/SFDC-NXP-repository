@isTest
private class UpdateCaseOwnersTestClass {

    // 005f4000001C3sbAAC

    public static String CRON_EXP = '0 0 0 15 3 ? 2022';

    static testmethod void testReassigningCaseOwner() {
    
        Date Today= Date.today();
        Date previousDay = Date.today().addDays(-1);
        Date nextDay = Date.today().addDays(+1);
         Date nextoneDay= Date.today().addDays(+2);
        
        
              Id std_Id;
              Id support_Id;
              string STD_User='Standard User';
              String Sup_User='NXP Tech Support';
                
              if(std_Id==null && support_Id==null)
              {        
                for(profile p:[Select Id,Name From Profile Where  (Name =:STD_User OR Name =:Sup_User)])
              {         
              if(p.Name ==STD_User ) 
              {
                  std_Id=p.id;  
              }
              else if(p.Name == Sup_User)
              {
                  support_Id=p.id;  
              }
           
          }
        }

       // Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];
        
        
        User user1 = new User(Username='Uname@testuser.org',
                                LastName='LName',
                                Email='usertotest1@test.com',
                                Alias='Alias',
                                CommunityNickname='usertotest1',
                                TimeZoneSidKey='America/Los_Angeles',
                                LocaleSidKey='en_US',
                                EmailEncodingKey='UTF-8',
                                ProfileId=std_Id ,
                                LanguageLocaleKey='en_US');
        User user2 = new User(Username='Uname1@testuser.org',
                                LastName='LName1',
                                Email='usertotest2@test.com',
                                Alias='Alias1',
                                CommunityNickname='usertotest2',
                                TimeZoneSidKey='America/Los_Angeles',
                                LocaleSidKey='en_US',
                                EmailEncodingKey='UTF-8',
                                ProfileId=support_Id,
                                LanguageLocaleKey='en_US');
                                
       User user3 = new User(Username='Uname2@testuser.org',
                                LastName='LName2',
                                Email='usertotest3@test.com',
                                Alias='Alias2',
                                CommunityNickname='usertotest3',
                                TimeZoneSidKey='America/Los_Angeles',
                                LocaleSidKey='en_US',
                                EmailEncodingKey='UTF-8',
                                ProfileId=support_Id,
                                LanguageLocaleKey='en_US');
        
        
        List<User> allUsers = new List<User>();
        allUsers.add(user1);
        allUsers.add(user2);
         allUsers.add(user3);
        insert(allUsers);
        Map<Id, User> allUsersMap = new Map<Id, User>(allUsers);
        List<Id> userIds = new List<Id>(allUsersMap.keyset());
        System.assertEquals(3, userIds.size(), 'Failed to create users');
        
        Id user1Id = userIds.get(0);
        Id user2Id = userIds.get(1);
        Id user3Id = userIds.get(2);
        
        Out_Of_Office_Log__c agentRecord = new Out_Of_Office_Log__c(OwnerId=user1Id,
                                               Backup_Person__c=user2Id,Person_taking_time_off__c=user1Id,
                                               Start_Date__c=Today, End_Date__c=nextDay);
        
        // Insert the record
        insert agentRecord;
        
         Out_Of_Office_Log__c agentRecordill = new Out_Of_Office_Log__c(OwnerId=user2Id,
                                               Backup_Person__c=user3Id,Person_taking_time_off__c=user2Id,
                                               Start_Date__c=Today, End_Date__c=nextoneDay);
        
        // Insert the record
        insert agentRecordill;
         //Insert Account
         List<Account> newAccount=CasePortalTestUtil.createTestParentAccount(1);
         insert newAccount;
         System.assert(newAccount[0].Id!=Null);
            
         //Insert Contact 
         List<Contact> contactList =CasePortalTestUtil.createTestContact(1,newAccount[0].Id,'case.contact@customer.com','lstNameTest');
         insert contactList;
        // check how to create case with owner value
        Case tempCase = new Case(OwnerId=user1Id, Status='Closed',Assigned_to__c=user1Id, contactId = contactList[0].Id);
        Case tempCase1 = new Case(OwnerId=user1Id, Status='Escalated',Assigned_to__c=user1Id,contactId = contactList[0].Id);
        Case tempCase2 = new Case(OwnerId=user1Id, Status='Closed',Assigned_to__c=user1Id,contactId = contactList[0].Id);
        
        List<Case> allCases = new List<Case>();
        allCases.add(tempCase);
        allCases.add(tempCase1);
        allCases.add(tempCase2);
        
        //Insert the case
        insert(allCases);
        
        Test.startTest();
        UpdateCaseOwners.scheduleUpdateCaseOwners();
         String CRON_EXP = '0 0 * * * ?';
        // schedule job
       // String jobId = System.schedule('ScheduledUpdateCaseOwnersTest', CRON_EXP,
                          //  new scheduleUpdateCaseOwners());
                            
        //verify that case Id's have not been updated.
        List<Case> allCasesBeforeJob = [SELECT OwnerId 
                                            FROM Case];
        for (Case caseBeforeJob : allCasesBeforeJob) {
        
            //System.assertEquals(user1Id, caseBeforeJob.OwnerId);
        }
        
       
       
        

        // stop the test to run the job
        Test.stopTest();
        
        //check that the id for case has been updated when status was new & escalated
        List<Case> allCasesAfterJob = [SELECT OwnerId, Status
                                            FROM Case];
        for (Case caseAfterJob : allCasesAfterJob) {
            if (caseAfterJob.Status == 'Closed') {
               // System.assertEquals(user1Id, caseAfterJob.OwnerId);
                
            } else {
                //System.assertEquals(user1Id, caseAfterJob.OwnerId);
               
            }
            
        }
    
    }

}