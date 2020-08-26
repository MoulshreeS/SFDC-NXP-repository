/*********************************************************************************************
@Modified By :  Bhagyashree Bali
@Modified Date: 17th Sep 2019
Description :   Modifying/ Replacing Entitlement and Entitlement Contacts with Project and Project Invitee objects for SFDC-2685
**********************************************************************************************/

@isTest(SeeAllData=false)
public class TestCaseEmailQuickActionHandlers {
    private final static String CASE_TSCOMMUNITY = 'TS_COMMUNITY'; 
    private final static String PARENT_ACCOUNT = 'Parent_Account';
    private Static RecordType tsCommunity;
    private static RecordType parentAccount;
    public Case caseRecord{get;set;}
    
    @isTest
    private static void testEntitlementEmailQuickAction(){
        
        Case caseRecord;
        
        //Getting record types for cases
        fetchRecordTypes();
       
        //Insert Account
        List<Account> newAccount=CasePortalTestUtil.createTestParentAccount(1);
        insert newAccount;
        System.assert(newAccount[0].id!=Null);
        
        //Insert Contact 
        List<Contact> contactList=CasePortalTestUtil.createTestContact(1,newAccount[0].id,'case.contact@customer.com','lstNameTest');
        insert contactList[0];
        System.assert(contactList[0].id!=Null);

        // Insert project 
        Project__c objProject = CasePortalTestUtil.createTestProject('test','General Interest & Research');
        insert objProject;
        System.assert(objProject.id!=Null);
        
        //Insert Project Invitees
        for(Integer i=0;i<3;i++){
            Project_Team__c objPrjInvitee =CasePortalTestUtil.createTestProjectTeam(objProject.id,'test'+i+'@tcs.com','Accepted');
            insert objPrjInvitee;
            System.assert(objPrjInvitee.id!=Null);
        }
        
        test.startTest();
        
        //Insert Case
        List<Case> Cases=CasePortalTestUtil.createCaseObject(1,tsCommunity.Id,objProject.Id);
        Cases[0].ContactId =contactList[0].id;
        insert Cases[0];
        System.assert(Cases[0].id!=Null);
        caseRecord =  Cases[0];
      
          
        CaseEmailQuickActionHandler ce = new CaseEmailQuickActionHandler();
        ce.onInitDefaults(new QuickAction.QuickActionDefaults[]{Test.newSendEmailQuickActionDefaults(caseRecord.id, null)});
        System.assert(ce.ccInviteEmailAddresses.contains('test1@tcs.com'));
        System.assert(ce.ccInviteEmailAddresses.contains('test2@tcs.com'));
        System.assert(ce.ccInviteEmailAddresses.contains('test4@tcs.com')==false); 

        test.stopTest();
        
       
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