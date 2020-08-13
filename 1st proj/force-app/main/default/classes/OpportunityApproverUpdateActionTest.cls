@isTest
public class OpportunityApproverUpdateActionTest {
	private static final String TEST_USER_PROFILE = 'Standard User';
	private static final String TEST_USER = 't_user_1';
    private static final String TEST_USER_GAM_GENERAL = 'uGamGen';
	private static final String TEST_USER_AUTO = 'userAUTO';
	private static final String TEST_USER_MT2 = 'userMT2';
	private static final String TEST_USER_MAG = 'userMAG';
	private static final String TEST_USER_BL = 'userBL';
	private static final String MAG_SHORT_LIVED;
    private static final String MAG_LIFETIME;
    private static final String BL1 = 'BL01';
    private static final String BL2 = 'BLM1';
    private static final String CCY_CODE_USD = 'USD';
    private static final String CCY_CODE_DEFAULT = CCY_CODE_USD; // @default
    private static final Double EXCH_RATE_USD = 2.0;
    private static final String CBG_AUTOMOTIVE = 'Automotive';
    private static final String CBG_NON_AUTOMOTIVE = 'Non-Automotive';
    private static final String REGION_GC = 'Greater China';
    private static final String REGION_SAP = 'South Asia Pacific';
    private static final Date PRODUCTION_DATE = Date.newInstance(2016, 04, 30);
    private static final Decimal UNIT_PRICE = 2;
    private static final Double COMP_MULT = 5;
    private static final Double TOTAL_OPPTY_SCHED_QTY = 2000000;
    private static final Integer PROD_COUNT = 4;
    private static final Double THRESHOLD_MAG = 100 * 1000;
    private static final Double THRESHOLD_BL = 15 * 1000 * 1000;
    private static final Double THRESHOLD_VP = 10 * 1000 * 1000;
    
    private static ID userIdGamGeneral;
    private static ID userIdAuto;
    private static ID userIdMT2;
    private static ID userIdMAG;
    private static ID userIdBL;
    private static OpportunityLineItem opptyProd;
    private static OpportunityApproverUpdateAction.OpportunityApproverUpdateActionRequest request = new OpportunityApproverUpdateAction.OpportunityApproverUpdateActionRequest();
    private static List<OpportunityApproverUpdateAction.OpportunityApproverUpdateActionRequest> requests;
    private static List<OpportunityApproverUpdateAction.OpportunityApproverUpdateActionResult> results;
    private static List<OpportunityLineItem> opptyProds = new List<OpportunityLineItem>();
	
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
        
        List<User> users = [SELECT Alias, MT_1__c, MT_2__c FROM User WHERE Alias IN (:TEST_USER, :TEST_USER_MAG, :TEST_USER_BL, :TEST_USER_AUTO)];
        
        for (User u : users) {
        	if (u.Alias == TEST_USER) {
        		userIdMT2 = u.MT_2__c;	
        	} else if (u.Alias == TEST_USER_MAG) {
        		userIdMAG = u.Id;
        	} else if (u.Alias == TEST_USER_BL) {
        		userIdBL = u.Id;
            } else if (u.Alias == TEST_USER_GAM_GENERAL) {
        		userIdGamGeneral = u.Id; 
        	} else if (u.Alias == TEST_USER_AUTO) {
        		userIdAuto = u.Id;
        	}
        }
        
        List<OpportunityLineItem> opptyLineItems = [SELECT Id, OpportunityId, PricebookEntry.Product2.MAG__c FROM OpportunityLineItem]; 
        
        for (OpportunityLineItem oli : opptyLineItems) {
        	opptyProds.add(oli);    
        }
        
        if (opptyProds.size() > 0) {
        	opptyProd = opptyProds.get(0);
        }
    }

    @testSetup
    static void setup() {
    	Profile p = [SELECT Id FROM Profile WHERE Name = :TEST_USER_PROFILE];
    	
    	// insert test users
    	List<User> users = new List<User>();
    	users.add(newUser(TEST_USER_AUTO, TEST_USER_AUTO, p.Id));
    	users.add(newUser(TEST_USER_MT2, TEST_USER_MT2, p.Id));
    	users.add(newUser(TEST_USER_MAG, TEST_USER_MAG, p.Id));
    	users.add(newUser(TEST_USER_BL, TEST_USER_BL, p.Id));
    	users.add(newUser(TEST_USER_GAM_GENERAL, TEST_USER_GAM_GENERAL, p.Id));//SFDC-954
    	insert users;
    	
    	User userAuto = users.get(0);
    	User userMT2 = users.get(1);
    	User userMAG = users.get(2);
    	User userBL = users.get(3);
        User userGamGeneral = users.get(4);
    	
    	User u = createUser(TEST_USER, TEST_USER, p.Id);
        u.MT_2__c = userMT2.Id;
        update u;
        
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
         
        // insert approvers
        List<Approvers_Matrix__c> ams = new List<Approvers_Matrix__c>();
        ams.add(newApproverMatrix('MAG Approver', MAG_SHORT_LIVED, null, THRESHOLD_MAG, userMAG.Id, null));
        ams.add(newApproverMatrix('MAG Approver', MAG_LIFETIME, null, THRESHOLD_MAG, userMAG.Id, null));
        ams.add(newApproverMatrix('BL Approver', BL1, null, THRESHOLD_BL, userBL.Id, null));
        ams.add(newApproverMatrix('BL Approver', BL2, null, THRESHOLD_BL, userBL.Id, null));
        ams.add(newApproverMatrix('Segment VP', 'Automotive', null, THRESHOLD_VP, userAuto.Id, null));
        ams.add(newApproverMatrix('GSM Sales Director', null, null, 0, u.Id, null));
        ams.add(newApproverMatrix('GSM VP 1', null, null, THRESHOLD_VP, u.Id, null));
        ams.add(newApproverMatrix('GSM VP 2', 'Automotive', 'Greater China', THRESHOLD_VP, u.Id, null));
        ams.add(newApproverMatrix('GSM VP 2', 'Automotive', 'South Asia Pacific', THRESHOLD_VP, u.Id, null));
        ams.add(newApproverMatrix('GAM', 'General Account', null, 0, userGamGeneral.Id, parentGeneral.Id));
        insert ams;
        
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
        Opportunity o = new Opportunity(Name = 'Test Oppty', OwnerId = u.Id, AccountId = a.Id, StageName = 'Initial Engagement');
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
    
    static Approvers_Matrix__c newApproverMatrix(String type, String criteria1, String criteria2, Double threshold1, ID approverID, ID accountID) {//SFDC-954, Add Account ID
    	Approvers_Matrix__c approverMatrix = new Approvers_Matrix__c();
    	approverMatrix.RecordTypeId = new ApproverMatrixesSelector().getRecordTypeId(ApproverMatrixesSelector.RecordType.DIRECT_OPPTY);
    	approverMatrix.Type__c = type;
    	approverMatrix.Criteria_1__c = criteria1;
    	approverMatrix.Criteria_2__c = criteria2;
    	approverMatrix.Threshold_1__c = threshold1;
    	approverMatrix.Approver__c = approverID;
    	approverMatrix.Account__c = accountID;
    	    	
    	return approverMatrix;
    }
    
    static Opportunity getOpportunity(ID opptyID) {
        return [SELECT LT_Value_USD__c, Sales_Director_Approver__c, Regional_VP_Approver__c, VP_Approver_2__c, 
        			   MAG_Approver_1__c, MAG_Approver_2__c, BL_Approver_1__c, BL_Approver_2__c,  
        			   Account.ParentId, Owner.MT_2__c 
        		  FROM Opportunity 
        		 WHERE Id = :opptyID];    
    }
    
    @isTest
    static void testInvoke() {
        Opportunity oppty = getOpportunity(opptyProd.OpportunityId);
        
        request.opptyId = oppty.Id;
        requests = new List<OpportunityApproverUpdateAction.OpportunityApproverUpdateActionRequest>{request};
        results = OpportunityApproverUpdateAction.invoke(requests);
        Opportunity updatedOppty = [SELECT Regional_VP_Approver__r.Name, BL_Approver_1__r.Name, Global_Key_Account_Manager__r.Name, MAG_Approver_1__r.Name, Owner.MT_2__r.Name
                                      FROM Opportunity
                                     WHERE Id = :oppty.Id];
        
        System.assertEquals(TEST_USER_AUTO, updatedOppty.Regional_VP_Approver__r.Name, 'Error in regionalVPApprover');
        System.assertEquals(TEST_USER_BL, updatedOppty.BL_Approver_1__r.Name, 'Error in blApprover1');
        System.assertEquals(TEST_USER_GAM_GENERAL, updatedOppty.Global_Key_Account_Manager__r.Name, 'Error in globalKeyAccountManager');
        System.assertEquals(TEST_USER_MAG, updatedOppty.MAG_Approver_1__r.Name,'Error in magApprover1');
        System.assertEquals(TEST_USER_MT2, updatedOppty.Owner.MT_2__r.Name,'Error in salesDirectorApprover');
    }
    
    @isTest
    static void testInvokeException() {
        Opportunity oppty = getOpportunity(opptyProd.OpportunityId);
        
        request.opptyId = oppty.Id;
        requests = new List<OpportunityApproverUpdateAction.OpportunityApproverUpdateActionRequest>{request};
        
        delete [SELECT Id FROM Approvers_Matrix__c WHERE Type__c = 'GSM Sales Director'];

        try {
            List<OpportunityApproverUpdateAction.OpportunityApproverUpdateActionResult> results = OpportunityApproverUpdateAction.invoke(requests);
        } catch(Exception e) {
            System.assertNotEquals('Success', e.getMessage());
        }
    }
}