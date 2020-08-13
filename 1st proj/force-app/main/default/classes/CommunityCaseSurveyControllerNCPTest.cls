@isTest
public class CommunityCaseSurveyControllerNCPTest {
     static testmethod void CommunityCaseSurveyControllerTest1()
    {
        // Adding survey questions
        List<Survey_question__c> objSurveyQues= new List<Survey_question__c>();
        Survey_question__c ques1 = new Survey_question__c();
        ques1.Name='Resolved ?';
        ques1.Question__c='How satisfied are you with the answer you received?';
        ques1.Type__c='Picklist';
        ques1.Value__c='1 Very Dissatisfied, 2 Dissatisfied, 3 Satisfied, 4 Very Satisfied';
        objSurveyQues.add(ques1);
        Survey_question__c ques2 = new Survey_question__c();
        ques2.Name='Resolution Time ?';
        ques2.Question__c='How satisfied are you with the request resolution time?';
        ques2.Type__c='Picklist';
        ques2.Value__c='1 Very Dissatisfied, 2 Dissatisfied, 3 Satisfied, 4 Very Satisfied';
        objSurveyQues.add(ques2);
        Survey_question__c ques3 = new Survey_question__c();
        ques3.Name='Support Person ?';
        ques3.Question__c='How satisfied are you with the support person’s ability to answer your question?';
        ques3.Type__c='Picklist';
        ques3.Value__c='1 Very Dissatisfied, 2 Dissatisfied, 3 Satisfied, 4 Very Satisfied';
         objSurveyQues.add(ques3);
        Survey_question__c ques4 = new Survey_question__c();
        ques4.Name='Share with others ?';
        ques4.Question__c='Based on your experience with our support, would you tell others  “You should use it” ?';
        ques4.Type__c='Picklist';
        ques4.Value__c='0,1,2,3,4,5,6,7,8,9,10';
         objSurveyQues.add(ques4);
        Survey_question__c ques5 = new Survey_question__c();
        ques5.Name='Comments';
        ques5.Question__c='Any additional comments you would like to share with us?';
        ques5.Type__c='Picklist';
        ques5.Value__c='Very Satisfied, Satisfied, Dissatisfied, Very Dissatisfied';
         objSurveyQues.add(ques5);
        insert objSurveyQues;
        
        Project__c newProject = CasePortalTestUtil.createTestProject('test Project', 'In Development');
        insert newProject;
        system.assert(newProject.Id != null);
        
         //fetch record type for accounts
        Id parentAccountTypeId = AccountHelper.getParentRecordTypeID();
        Id childAccountTypeId =  AccountHelper.getChildRecordTypeID();
        
        Account parentAccount = new Account(Name = 'Test Parent', RecordTypeId = parentAccountTypeId);
        insert parentAccount;
        system.assert(parentAccount.Id != null);
        
        Account childAccount = new Account(Name = 'Test Child', RecordTypeId = childAccountTypeId, ParentId = parentAccount.Id);
        insert childAccount;
        system.assert(childAccount.Id != null);
        
        Contact testContact1 = new Contact(FirstName = 'test First', LastName = 'test Last', Email = 'test.conatct@abc.com.nxp', 
                                          AccountId = childAccount.Id, Community_web_country__c = 'India');
        insert testContact1;
        system.assert(testContact1.Id != null);
        
        Id agentUserProfileId = CasePortalUtil.INTERNAL_AGENT_PROFILE_ID;
        
        User agentUser = TestUtil.createTestUser('abc.internal.test@nxp.com', 'testExt', agentUserProfileId);
        insert agentUser;
        system.assert(agentUser.id!=null);
        
        test.startTest();
        
        //creating a case 
        Id tscommunityRecordType = Schema.SObjectType.Case.getRecordTypeInfosByName().get('TS Community').getRecordTypeId();
        Case objCase = new Case(RecordTypeID = tscommunityRecordType, contactId = testContact1.Id, Status= 'New', Priority = 'Medium', 
                           Subject = 'test_subject_1', Description = 'test_description_1', Projects__c = newProject.Id); 
        insert objCase;        
        system.assert(objCase.Id != null);    
        
        objCase.Assigned_to__c = agentUser.Id;
        update objCase;
        
        //invoke the method caseSurveyDetailNCP
        List<String> Returnval = CommunityCaseSurveyControllerNCP.caseSurveyDetailNCP(objCase.Id);
        //assert the results
        System.assert(Returnval != null);
        Case eachCase = [SELECT Id,Subject,CaseNumber,Survey_Flag__c FROM Case where Id = : objCase.Id];
        List<String> caseRecString = new List<String>();
        caseRecString.add(eachCase.Subject);
        caseRecString.add(eachCase.CaseNumber);
        caseRecString.add(eachCase.Survey_Flag__c);
        System.assertEquals(caseRecString, Returnval);
        
        String strReturn = CommunityCaseSurveyControllerNCP.submitSurveyToSalesforce('3 Satisfied','3 Satisfied','3 Satisfied','7', objCase.Id,'Test Positive');
        system.assert(strReturn == null);
        List<Survey_Answer__c> lstSurveyAnswers = [Select Id, Case__c From Survey_Answer__c Where Case__c =: objCase.Id];
        system.assert(lstSurveyAnswers.size() == 5);
        
        strReturn = CommunityCaseSurveyControllerNCP.submitSurveyToSalesforce('2 Dissatisfied','2 Dissatisfied','2 Dissatisfied','2', objCase.Id,'Test Negative');
        system.assert(strReturn == null);
        lstSurveyAnswers = [Select Id, Case__c From Survey_Answer__c Where Case__c =: objCase.Id];
        system.assert(lstSurveyAnswers.size() == 10);
        test.stoptest();
    }
}