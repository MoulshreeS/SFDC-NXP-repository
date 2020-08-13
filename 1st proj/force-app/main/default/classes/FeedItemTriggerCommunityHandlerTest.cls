/*---------------------------------------------------------------------------------------------------
@Modified By :     Gunjan Singh
@Modified Date :   Sep 10,2019
@Description :     updateCaseAfterPostAndCommentTest : Method written as part of SFDC-2691 to Cover updateCaseAfterPostAndComment
                   To send mail to project invitees after chatter post or comment has been made
****************************************************************************************************/

@isTest
private class FeedItemTriggerCommunityHandlerTest {

    static User objUser;
    static User portalUser;
    static Account portalAccount;
    static Contact portalContact;
    
    static list<CollaborationGroup > lstCG = new  list<CollaborationGroup>();
    static list<Topic> lstTopic = new  list<Topic>();
    static list<FeedItem> lstFeedItem = new  list<FeedItem >();
    static list<FeedItem> lstFeedItem1 = new  list<FeedItem >();
    static list<Case_Routing_Mapping__c> lstCaseRoutingMap = new list<Case_Routing_Mapping__c>();
    
    
    private static testMethod void test() {
        
        createData();
        
        System.runAs(objUser){
            
            System.debug('Limit queries aftr createdata *>'+System.limits.getQueries());
            
            lstCG  = new List<CollaborationGroup>{new CollaborationGroup(Name='TestCollGroup' + String.valueOf(System.now()), CollaborationType='public' ), 
                                                  new CollaborationGroup(Name='TestCollGroup-02' + String.valueOf(System.now()), CollaborationType='public')};
            Test.startTest();
            Insert lstCG;
             
            System.debug('Limit queries aftr collaborationGroup *>'+System.limits.getQueries());
            
            lstTopic = new List<Topic>{new Topic(Name = 'Test Topic-01')};
            Insert lstTopic;
            
            System.debug('Limit queries aftr Topic *>'+System.limits.getQueries());
            
            lstCaseRoutingMap = new List<Case_Routing_Mapping__c>{new Case_Routing_Mapping__c(Name = 'TestTopic', Related_To_Id__c= lstTopic[0].Id, CaseOwner__c= objUser.Id, CaseAdmin__c = objUser.Id ),
                                                        new Case_Routing_Mapping__c(Name = 'TestGroup-01', Related_To_Id__c= lstCG[0].Id, CaseOwner__c= objUser.Id, CaseAdmin__c = objUser.Id),
                                                        new Case_Routing_Mapping__c(Name = 'Default', Related_To_Id__c= objUser.Id, CaseOwner__c= objUser.Id,CaseAdmin__c = objUser.Id)};
            Insert lstCaseRoutingMap;
            
            System.debug('Limit queries aftr CRM *>'+System.limits.getQueries());
            
            lstFeedItem = new List<FeedItem>{new FeedItem(ParentId = lstCG[0].Id, Type = 'QuestionPost',Body='Test-01', Title = 'Test', CreatedById = portalUser.Id),
                                             new FeedItem(ParentId = lstTopic[0].Id,Type = 'QuestionPost', Body='Test-02', Title = 'Test2', CreatedById = portalUser.Id),
                                             new FeedItem(ParentId = lstCG[1].Id,Type = 'QuestionPost', Body='Test-03', Title = 'Test3', CreatedById = portalUser.Id)};
            
            System.debug('Limit queries b4 feedinsert *>'+System.limits.getQueries());
            
            Insert lstFeedItem;
            
            System.debug('Limit queries aftr feedinsert *>'+System.limits.getQueries());
            
            //Insert Case
            Id RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('TS Community').getRecordTypeId();
            List<Case> lstCase = CasePortalTestUtil.createCaseObject(2,RecordTypeId,null);
            lstCase[0].ContactId = portalContact.Id;
            lstCase[1].ContactId = portalContact.Id;
            lstCase[0].FeedItemId = lstFeedItem[0].Id;
            insert lstCase;
            Test.stopTest();
            lstFeedItem1 = new List<FeedItem>{new FeedItem(ParentId = lstCase[0].Id, Type = 'QuestionPost',Body='Test-01', Title = 'Test', CreatedById = portalUser.Id),
                                             new FeedItem(ParentId = lstCase[0].Id,Type = 'QuestionPost', Body='Test-02', Title = 'Test2', CreatedById = portalUser.Id),
                                             new FeedItem(ParentId = lstCase[0].Id,Type = 'QuestionPost', Body='Test-03', Title = 'Test3', CreatedById = portalUser.Id)};
            
            System.debug('Limit queries b4 feedinsert *>'+System.limits.getQueries());
            insert lstFeedItem1;
             
            lstFeedItem[0].body = lstFeedItem[0].body+'Update';
            lstFeedItem[0].Title = lstFeedItem[0].Title+'Update Title';
            
            System.debug('Limit queries b4 feedUpdate *>'+System.limits.getQueries());
            Update lstFeedItem[0];
            
            lstFeedItem[1].body = lstFeedItem[1].body+'Update';
            lstFeedItem[1].Title = lstFeedItem[1].Title+'Update Title';
            Update lstFeedItem[1];
            
            System.debug('Limit queries aftr feedUpdate *>'+System.limits.getQueries());
            
            List<FeedAttachment> lstFAToInsert = new List<FeedAttachment>();
            
            ContentVersion objCV = new ContentVersion(Title = 'dummy', VersionData = blob.valueOf('text Dummy file'), PathOnClient = 'dummy.txt');
            Insert objCV;
            
            FeedAttachment objFeedAttach = new FeedAttachment(FeedEntityId = lstFeedItem[0].Id, RecordId = objCV.Id, Type = 'Content');
            Insert objFeedAttach;
            
            lstFAToInsert.add(new FeedAttachment(FeedEntityId = lstFeedItem[0].Id, RecordId = objCV.Id, Type = 'Content'));
            
            List<Case> objCase = [SELECT Id,Subject,Description,FeedItemId FROM Case WHERE FeedItemId =: lstFeedItem[0].Id];
           
            
            System.debug('Limit queries aftr caseQuery *>'+System.limits.getQueries());
            If (objCase.size() > 0){
            
            system.assert(objCase[0].id != null);
            
           
            FeedItem objFeed = lstFeedItem[0];
            
            system.assert(objFeed.Id != NULL);
            system.assertEquals(objFeed.Body, objCase[0].Description);
            system.assertEquals(objFeed.Title, objCase[0].Subject);
            
            }
            Datetime sysTime = System.now().addSeconds( 30 );      
            String chronExpression = '' + sysTime.second() + ' ' + sysTime.minute() + ' ' + sysTime.hour() + ' ' + sysTime.day() + ' ' + sysTime.month() + ' ? ' + sysTime.year();
            System.schedule( 'SelfScheduleForFileAttchmentTest' + sysTime, chronExpression, new AddFileOnQuestionUpdateScheduler(lstFAToInsert)); 
            
            
        }

    }
    
    //Method written as part of SFDC-2691 to Cover updateCaseAfterPostAndComment
    @istest static void updateCaseAfterPostAndCommentTest(){
    
        //Create User Data
        createData();
        
        System.runAs(portalUser){
            //Insert Project
            List<Project__c> lstProject= new list<Project__c>();
            lstProject= CasePortalTestUtil.createTestProjects(2);
            insert lstProject; 
            
            //Insert Project Team
            List<Project_Team__c> lstTeamMemmbers = new List<Project_Team__c>();
            Project_Team__c ProjT = new Project_Team__c(First_Name__c = 'Test FirstName' , Last_Name__c='Test LastName',
                                                          Email_Address__c='test'+'email@gmail.com' , Status__c = 'Accepted' , Project__c = lstProject[0].Id);
            lstTeamMemmbers.add(ProjT);
            insert lstTeamMemmbers;
           
            //Insert Case
            Id RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('TS Community').getRecordTypeId();
            List<Case> lstCase = CasePortalTestUtil.createCaseObject(2,RecordTypeId,lstProject[0].Id);
            lstCase[0].ContactId = portalContact.Id;
            lstCase[1].ContactId = portalContact.Id;
            insert lstCase;
               
            Test.startTest();
            
            //Insert FeedItem
            FeedItem objFeedItem =new FeedItem();
            objFeedItem.parentid=lstCase[0].id;
            objFeedItem.Body = 'test chatter';
            insert objFeedItem;
            
            //Insert FeedComment
            FeedComment objFeedComment =new FeedComment();
            objFeedComment.FeedItemId =objFeedItem.id;
            objFeedComment.CommentBody = 'test chatter';
            insert objFeedComment;
            
            
            Test.stopTest();  
        }
       
    }
    
    private static void createData(){
        
        portalAccount = new Account(name = 'portalAccount');
        Insert portalAccount;
        
        portalContact = new contact(LastName = 'portalContact', AccountId = portalAccount.Id, MailingState = 'United States', Title = 'Test Title',Community_web_country__c = 'testcountry'); //create a portal contact//MailingCountry = 'UK',
        Insert portalContact;
        
        List<Profile> lstProfiles = [SELECT Id,Name FROM Profile WHERE Name = 'System Administrator' OR Name = 'NXP Customer Community Login User' limit 2];
        //Id PortalUserId = [SELECT Id FROM Profile WHERE Name = 'NXP Customer Community Login User' limit 1].Id;
        
        for(Profile objUserProfile : lstProfiles){
            
            if(objUserProfile.Name == 'NXP Customer Community Login User'){ 
                
                portalUser = new User(  email='testmail.test123@gmail.com',
                                        profileid = objUserProfile.Id, 
                                        UserName='testuser.test59@gmail.com', 
                                        Alias = 'GDS',
                                        TimeZoneSidKey='America/New_York',
                                        EmailEncodingKey='ISO-8859-1',
                                        LocaleSidKey='en_US', 
                                        LanguageLocaleKey='en_US',
                                        ContactId = portalContact.Id,
                                        PortalRole = 'Manager',
                                        FirstName = 'Genelia',
                                        LastName = 'Dsouza');
                
            }else if(objUserProfile.Name == 'System Administrator'){
                
                objUser = new User(alias = 'UTest', email='unit.test@test.com', emailencodingkey='UTF-8', lastname='test', languagelocalekey='en_US', localesidkey='en_US', 
                                     profileid = objUserProfile.Id, timezonesidkey='America/Los_Angeles', username= 'unit.test@test123.com');
            }
        }
        Insert portalUser;
        Insert objUser;
        
    } 

}