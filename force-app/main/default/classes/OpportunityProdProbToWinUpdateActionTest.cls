@isTest
public class OpportunityProdProbToWinUpdateActionTest {
    private static final String PROBABILITY_TO_WIN_80_100 = '80% - 100%';
    private static final String TEST_USER_PROFILE = 'Standard User';
	private static final String TEST_USER = 't_user_1';
    private static final String TEST_OPPTY_NAME = 'Test Oppty';
    private static final String MAG_LIFETIME;
    private static final String MAG_SHORT_LIVED;
    private static final String BL1 = 'BL01';
    private static final String BL2 = 'BLM1';
    private static final String CCY_CODE_USD = 'USD';
    private static final String CCY_CODE_DEFAULT = CCY_CODE_USD; // @default
    private static final String CBG_AUTOMOTIVE = 'Automotive';
    private static final Double EXCH_RATE_USD = 2.0;
    private static final Double TOTAL_OPPTY_SCHED_QTY = 2000000;
    private static final Date PRODUCTION_DATE = Date.newInstance(2016, 04, 30);
    private static final Decimal UNIT_PRICE = 2;
    private static final Double COMP_MULT = 5;
    private static final Integer PROD_COUNT = 4;
    private static final List<String> TEST_EVIDENCE_TYPES = new List<String>{'DW Evidence', 'Compliance Risk Assessment', 'Project Report', 'Tender Spec', 'Background Check', 'Customer Meeting'};

    
    private static OpportunityProdProbToWinUpdateAction.OpportunityProdProbToWinUpdateActionRequest request = new OpportunityProdProbToWinUpdateAction.OpportunityProdProbToWinUpdateActionRequest();
    private static List<OpportunityProdProbToWinUpdateAction.OpportunityProdProbToWinUpdateActionRequest> requests;
    private static List<OpportunityProdProbToWinUpdateAction.OpportunityProdProbToWinUpdateActionResult> results;

    static {
		Opportunity_Claim_Value_MAG_Setting__mdt claimValueMagSetting = 
            [SELECT MAG__c 
               FROM Opportunity_Claim_Value_MAG_Setting__mdt 
              WHERE Claim_Value_Quarters__c != 'Lifetime'
                AND IsActive__c = true
              LIMIT 1];
        
        MAG_SHORT_LIVED = claimValueMagSetting.MAG__c;
               
        claimValueMagSetting = 
            [SELECT MAG__c 
               FROM Opportunity_Claim_Value_MAG_Setting__mdt 
              WHERE Claim_Value_Quarters__c = 'Lifetime'
                AND IsActive__c = true
              LIMIT 1];
        
        MAG_LIFETIME = claimValueMagSetting.MAG__c;
    }

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
         
               
        // Insert products
        List<Product2> prods = new List<Product2>();
        
        for (Integer i = 0; i < PROD_COUNT; i++) {
            Integer rem = Math.mod(i, 2);
            
            if (rem == 0) {
                prods.add(new Product2(Name = 'Test Product' + i, MAG__c = MAG_SHORT_LIVED, BL__c = BL1, IsActive = true));
            } else {
                prods.add(new Product2(Name = 'Test Product' + i, MAG__c = MAG_LIFETIME, BL__c = BL2, IsActive = true));
            }            
        }
        
        insert prods;
        
        // Insert an opportunity
        Opportunity o = new Opportunity(Name = TEST_OPPTY_NAME, OwnerId = u.Id, AccountId = a.Id, StageName = 'Initial Engagement');
        o.Production_Date__c = PRODUCTION_DATE;
        o.CloseDate = PRODUCTION_DATE - 60;
        o.Currency__c = fxRates.get(CCY_CODE_DEFAULT).Id; // Locked_Exchange_Rate__c will be set to this by workflow.
        o.CurrencyIsoCode = CCY_CODE_DEFAULT; // CurrencyIsoCode and Currency__c are correlated.
        o.Bypass_Validation_Sched_Start_Date__c = true;
        insert o;
        
        createOpportunitySchedules(o.Id, TOTAL_OPPTY_SCHED_QTY); 
        
        List<PricebookEntry> pbes = [SELECT Id FROM PricebookEntry WHERE Product2Id IN :prods and CurrencyIsoCode = :CCY_CODE_DEFAULT];
        
        // Insert opportunity products
        List<OpportunityLineItem> olis = new List<OpportunityLineItem>();
        
        for (PricebookEntry pbe : pbes) {
            OpportunityLineItem oli = new OpportunityLineItem(OpportunityId = o.Id, PricebookEntryId = pbe.Id);
            oli.UnitPrice = UNIT_PRICE;
            oli.Component_Multiplier__c = COMP_MULT;
            olis.add(oli);
        }
        
        insert olis;    
    }
    
    static void createOpportunitySchedules(ID opptyID, Double totalQty) {
    	List<OpportunitySchedule__c> opptyScheds = new List<OpportunitySchedule__c>();
    	Double qty = totalQty / 4;
    	
    	OpportunitySchedule__c opptySched;
		opptySched = new OpportunitySchedule__c(Opportunity__c = opptyID, Sched_Date__c = Date.newInstance(2016, 01, 01), Oppty_Sched_Qty__c = qty, Frozen_Oppty_Sched_Qty__c = qty);
		opptyScheds.add(opptySched);
		opptySched = new OpportunitySchedule__c(Opportunity__c = opptyID, Sched_Date__c = Date.newInstance(2016, 04, 01), Oppty_Sched_Qty__c = qty, Frozen_Oppty_Sched_Qty__c = qty);
		opptyScheds.add(opptySched);
		opptySched = new OpportunitySchedule__c(Opportunity__c = opptyID, Sched_Date__c = Date.newInstance(2016, 07, 01), Oppty_Sched_Qty__c = qty, Frozen_Oppty_Sched_Qty__c = qty);
		opptyScheds.add(opptySched);
		opptySched = new OpportunitySchedule__c(Opportunity__c = opptyID, Sched_Date__c = Date.newInstance(2016, 10, 01), Oppty_Sched_Qty__c = qty, Frozen_Oppty_Sched_Qty__c = qty);
		opptyScheds.add(opptySched);	
    	
    	insert opptyScheds;
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
    static void testInvoke() {
        Opportunity oppty = [SELECT Id FROM Opportunity WHERE Name = :TEST_OPPTY_NAME];
        request.opptyId = oppty.Id;
        requests = new List<OpportunityProdProbToWinUpdateAction.OpportunityProdProbToWinUpdateActionRequest>{request};

        Test.startTest();
        
        results = OpportunityProdProbToWinUpdateAction.invoke(requests);

        Test.stopTest();

        List<OpportunityLineItem> opptyLineItems = (List<OpportunityLineItem>)new OpportunityLineItemsSelector().selectByOpptyId(new Set<Id> {oppty.Id});
        
        for (OpportunityLineItem ol : opptyLineItems) {
            System.assertEquals(PROBABILITY_TO_WIN_80_100, ol.Probability_to_Win__c);
        }
    }

    @isTest
    static void testInvokeException() {
        request.opptyId = 'invalid id';
        requests = new List<OpportunityProdProbToWinUpdateAction.OpportunityProdProbToWinUpdateActionRequest>{request};

        try {
            results = OpportunityProdProbToWinUpdateAction.invoke(requests);
        } catch(Exception e) {
            System.assertNotEquals('Success', e.getMessage());
        }
    }
}