@isTest
private class OpportunityEvidenceFileStatusActionTest {
    private static final String TEST_USER_PROFILE = 'Standard User';
	private static final String TEST_USER = 't_user_1';
    private static final String TEST_OPPTY_NAME = 'Test Oppty';
    private static final String CCY_CODE_USD = 'USD';
    private static final String CCY_CODE_DEFAULT = CCY_CODE_USD; // @default
    private static final String CBG_AUTOMOTIVE = 'Automotive';
    private static final Double EXCH_RATE_USD = 2.0;
    private static final Date PRODUCTION_DATE = Date.newInstance(2016, 04, 30);
    private static final List<String> TEST_EVIDENCE_TYPES = new List<String>{'DW Evidence', 'Compliance Risk Assessment', 'Project Report', 'Tender Spec', 'Background Check', 'Customer Meeting'};
    
    private static OpportunityEvidenceFileStatusAction.OpportunityEvidenceFileStatusActionRequest request = new OpportunityEvidenceFileStatusAction.OpportunityEvidenceFileStatusActionRequest();
    private static List<OpportunityEvidenceFileStatusAction.OpportunityEvidenceFileStatusActionRequest> requests;
    private static List<OpportunityEvidenceFileStatusAction.OpportunityEvidenceFileStatusActionResult> results;
	
    @testSetup
    static void setup() {
    	Profile p = [SELECT Id FROM Profile WHERE Name = :TEST_USER_PROFILE];
    	
    	User u = createUser(TEST_USER, TEST_USER, p.Id);
        
        // insert FX Rates
        // There is a workflow which sets Opportunity.Locked_Exchange_Rate__c to 
        // Opportunity.Currency__r.Exchange_Rate__c, which refers to FX_Rates__c.Exchange_Rate__c
        List<FX_Rates__c> fxrs = new List<FX_Rates__c>();
        fxrs.add(new FX_Rates__c(Name = CCY_CODE_USD, Currency_Code__c = CCY_CODE_USD, CurrencyIsoCode = CCY_CODE_USD, Exchange_Rate__c = EXCH_RATE_USD));
        insert fxrs;
        
        Map<String, FX_Rates__c> fxRates = new Map<String, FX_Rates__c>();
        fxRates.put(CCY_CODE_USD, fxrs.get(0));
        
        // Insert accounts
        Account parentGeneral = createAccount('Parent Account - General', AccountsSelector.getParentRecordTypeID(), null, null);
        Account a = createAccount('Test Account', AccountsSelector.getChildRecordTypeID(), parentGeneral.Id, CBG_AUTOMOTIVE);
        
        // Insert an opportunity
        Opportunity o = new Opportunity(Name = TEST_OPPTY_NAME, OwnerId = u.Id, AccountId = a.Id, StageName = 'Initial Engagement');
        o.Production_Date__c = PRODUCTION_DATE;
        o.CloseDate = PRODUCTION_DATE - 60;
        o.Currency__c = fxRates.get(CCY_CODE_DEFAULT).Id; // Locked_Exchange_Rate__c will be set to this by workflow.
        o.CurrencyIsoCode = CCY_CODE_DEFAULT; // CurrencyIsoCode and Currency__c are correlated.
        o.Bypass_Validation_Sched_Start_Date__c = true;
        insert o;
        
        // Create 1 DW evidence file and 5 compliance risk files
        List<ContentVersion> cvs = new List<ContentVersion>();

        for (String evidenceType : TEST_EVIDENCE_TYPES) {
            cvs.add(new ContentVersion(
                Title = 'TestContentVersion_'+evidenceType,
                PathOnClient = 'Test.doc',
                VersionData = Blob.valueOf('Test Data'),
                IsMajorVersion = true,
                Category__c = evidenceType
            ));
        }

        insert cvs;

        // Link these 6 files to the Opportunity record
		cvs = new ContentVersionsSelector().selectById((new map<Id, sObject>(cvs)).keySet());
        List<ContentDocumentLink> cdls = new List<ContentDocumentLink>();

        for (ContentVersion cv : cvs) {
            cdls.add(new ContentDocumentLink(
                LinkedEntityId = o.Id,
                ContentDocumentId = cv.ContentDocumentId,
                ShareType = 'V'
            ));
        }
        
        insert cdls;
    }
   
    static User createUser(String alias, String lastName, ID profileID) {
    	User user = newUser(alias, lastName, profileID); 
    	insert user;
        
        return user;	
    }
    
    static User newUser(String alias, String lastName, ID profileID) {
    	String email = CommonUtils.generateGUID() + '@nxp.com.test123';
    	
    	User user = new User(EmailEncodingKey = 'UTF-8', LanguageLocaleKey = 'en_US', LocaleSidKey = 'en_US', TimeZoneSidKey = 'America/Los_Angeles');
		user.Alias = alias;
		user.LastName = lastName;
		user.ProfileId = profileID;
		user.Email = email;
		user.UserName = email;
        user.Signed_ARIA__c = true;
		        
        return user;	
    }
    
    static Account createAccount(String name, ID recordTypeID, ID parentID, String cbg) {
    	Account account = new Account(Region__c = 'EMEA');
    	account.Name = name;
    	account.RecordTypeId = recordTypeID;
    	account.ParentId = parentID;
    	account.CMD_Industry_Segment__c = cbg;
    	insert account;
    	
    	return account;
    }
       
    @isTest
    static void testPositiveInvoke() {
        Opportunity oppty = [SELECT Id FROM Opportunity WHERE Name = :TEST_OPPTY_NAME];

        Test.startTest();

        OpportunityEvidenceFileStatusAction.OpportunityEvidenceFileStatusActionRequest request = new OpportunityEvidenceFileStatusAction.OpportunityEvidenceFileStatusActionRequest();
        request.opptyId = oppty.Id;
        List<OpportunityEvidenceFileStatusAction.OpportunityEvidenceFileStatusActionRequest> requests = new List<OpportunityEvidenceFileStatusAction.OpportunityEvidenceFileStatusActionRequest>{request};
        List<OpportunityEvidenceFileStatusAction.OpportunityEvidenceFileStatusActionResult> results = OpportunityEvidenceFileStatusAction.invoke(requests);

        Test.stopTest();

        System.assertEquals(true, results.get(0).dwEvidenceFileStatus, 'dwEvidenceFileStatus should be true');
        System.assertEquals(true, results.get(0).cpEvidenceFileStatus, 'cpEvidenceFileStatus should be true');
    }

    @isTest
    static void testNegativeInvoke() {
        Opportunity oppty = [SELECT Id FROM Opportunity WHERE Name = :TEST_OPPTY_NAME];
        List<ContentDocumentLink> cdls = new ContentDocumentLinksSelector().selectByOpptyIdWithContentDocument(new Set<Id> {oppty.Id});
        delete cdls;

        Test.startTest();
        
        request.opptyId = oppty.Id;
        requests = new List<OpportunityEvidenceFileStatusAction.OpportunityEvidenceFileStatusActionRequest>{request};
        results = OpportunityEvidenceFileStatusAction.invoke(requests);

        Test.stopTest();

        System.assertEquals(false, results.get(0).dwEvidenceFileStatus, 'dwEvidenceFileStatus should be false');
        System.assertEquals(false, results.get(0).cpEvidenceFileStatus, 'cpEvidenceFileStatus should be false');
    }
   
    @isTest
    static void testInvokeException() {
        // Use an Opportunity which is not existing as the input
        request.opptyId = 'invalid id';
        requests = new List<OpportunityEvidenceFileStatusAction.OpportunityEvidenceFileStatusActionRequest>{request};

         try {
            results = OpportunityEvidenceFileStatusAction.invoke(requests);
         } catch(Exception e) {
            System.assertNotEquals('Success', e.getMessage());
        }
    }
}