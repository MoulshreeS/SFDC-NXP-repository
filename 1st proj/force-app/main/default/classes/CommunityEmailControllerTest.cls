/*********************************************************************************************
@Created By  :     Amit Rajan
@CreatedDate :     06 May 2016
Description  :     Test Class for Email custom related list
----------------------------------------------------------------------------------------------
@Modified By :     Bhagyashree Bali
@Modified Date :   17th Sep 2019
Description  :     Changed Entitlement reference to project.
**********************************************************************************************/
@isTest(seeAllData = false)
Public class CommunityEmailControllerTest{
    
    static Case caseRecord;
    private final static String CASE_TSCOMMUNITY = 'TS_COMMUNITY'; 
    private final static String PARENT_ACCOUNT = 'Parent_Account';
    private Static RecordType tsCommunity;
    private static RecordType parentAccount;
    
    /*
* @name         : saveRecord
* @description  : saves the Case record with updated owner
* @ Input param : Null
* @ return type : Null
*/
    public static testmethod void caseTest(){
        fetchRecordTypes(); 
        loadData();
        System.runAs(new User (Id = UserInfo.getUserId())){
            CommunityEmailController controller = new CommunityEmailController(new ApexPages.standardController(caseRecord));
            controller.sendAnEmail();
            EmailMessage message = new EmailMessage();
            message.fromAddress ='avs@ts.com';
            message.Toaddress = 'hg@fjj.com';
            message.subject ='Test';
            message.parentId = caseRecord.id;
            insert message;
            System.assert( message.id != null);
            controller = new CommunityEmailController(new ApexPages.standardController(caseRecord));
            ApexPages.currentPage().getParameters().put('emailId', [SELECT id from EmailMessage LIMIT 1].id);
            controller.getSortedEmails();
            controller.sendAnEmail();
            controller.deleteEmail();
            controller.replyEmail();
            controller.replyAllEmail();    
        }
        Test.stopTest();
    } 
    static void loadData(){
        
        System.runAs(new User(Id = UserInfo.getUserId())){
            
            //Insert Account
            List<Account> newAccount=CasePortalTestUtil.createTestParentAccount(1);
            insert newAccount;
            System.assert(newAccount[0].Id!=Null);
            
            //Insert Contact 
            List<Contact> contactList=CasePortalTestUtil.createTestContact(1,newAccount[0].Id,'case.contact@customer.com','lstNameTest');
            insert contactList;
            System.assert(contactList[0].Id!=Null);
            
            // Insert project 
            Project__c objProject = CasePortalTestUtil.createTestProject('test','General Interest & Research');
            insert objProject;
            System.assert(objProject.Id != Null);
            
            //Insert project team
            Project_Team__c objPrjInvitee =CasePortalTestUtil.createTestProjectTeam(objProject.Id,'test'+1+'@email.com','Accepted');
            insert objPrjInvitee;
            System.assert(objPrjInvitee.Id != Null);
            Test.startTest();
            //Create case
            List<Case> lstCases=CasePortalTestUtil.createCaseObject(1,tsCommunity.Id,objProject.Id);
            lstCases[0].ContactId = contactList[0].Id;
            insert lstCases;
            System.assert(lstCases[0].Id != Null);
            caseRecord=lstCases[0];
        }
    }
    
    //To fetch the record type
    private static void fetchRecordTypes()
    {        
        for(RecordType rt : [Select Id, DeveloperName
                             From RecordType Where IsActive=true and  
                             ((SobjectType = 'Case' and (DeveloperName =: CASE_TSCOMMUNITY)) or
                              (SobjectType = 'Account' and (DeveloperName =: Parent_Account))                              
                             ) Limit 3])
            
            if(rt.DeveloperName == CASE_TSCOMMUNITY) {
                tsCommunity = rt;
            }
        else if(rt.DeveloperName == PARENT_ACCOUNT){
            parentAccount = rt;
        } 
    }   
}