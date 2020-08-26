@isTest
private class CustomerProjectsTest {
    private static final String TEST_USER_PROFILE = 'Standard User';
    private static final String TEST_USER = 't_user_1';
    private static final String CCY_CODE_USD = 'USD';
    private static final String CCY_CODE_EUR = 'EUR';
    private static final String CCY_CODE_DEFAULT = CCY_CODE_USD; 
    private static final Double EXCH_RATE_USD = 2.0;
    private static final Double EXCH_RATE_EUR = 0.9;
    private static final Date PRODUCTION_DATE = Date.newInstance(2019, 09, 17);
    private static final String PARENT_ACCOUNT_STAR = 'STAR';
    private static final String PARENT_ACCOUNT_SAMSUNG = 'Samsung';
    private static final String CBG_AUTOMOTIVE = 'Automotive';
    
    @testSetup
    static void setup() {
        Profile p = [select Id from Profile where Name = :TEST_USER_PROFILE];
        // insert a test user
        User u = createUser(TEST_USER, TEST_USER, p.Id, false);
        // Insert accounts
        createAccount(PARENT_ACCOUNT_STAR, AccountsSelector.getParentRecordTypeID(), null, null);
        createAccount(PARENT_ACCOUNT_SAMSUNG, AccountsSelector.getParentRecordTypeID(), null, null);
        Account parentGeneral = createAccount('Parent Account - General', AccountsSelector.getParentRecordTypeID(), null, null);
        Account a = createAccount('Test Account', AccountsSelector.getChildRecordTypeID(), parentGeneral.Id, CBG_AUTOMOTIVE);
        // Insert an opportunity
        Opportunity o = new Opportunity(Name = 'Test Oppty', OwnerId = u.Id, AccountId = a.Id, StageName = 'Initial Engagement');
        o.Production_Date__c = PRODUCTION_DATE;
        o.CloseDate = PRODUCTION_DATE - 60;
        insert o;
    }
    
    @isTest
    static void testOpptyWithMultipleCustomerProject() {
        Opportunity o = (Opportunity)new OpportunitiesSelector().selectWhere('Opportunity.Name = \'' +'Test Oppty' + '\'').get(0);
        
        try {
            Customer_Project__c cp = new Customer_Project__c(Name = 'Test CAS', Opportunity__c = o.Id);
            insert cp;
            Customer_Project__c cp2 = new Customer_Project__c(Name = 'Test CAS 2', Opportunity__c = o.Id);
            insert cp2;
        }catch (Exception e) {
            Boolean isExpectedException =  e.getMessage().contains('This Opportunity has an existing Customer Project.') ? true : false;
            System.AssertEquals(isExpectedException, true);
         }
    }
    
    static User createUser(String alias, String lastName, ID profileID, Boolean signedARIA) {
        User user = newUser(alias, lastName, profileID, signedARIA); 
        insert user;
        
        return user;    
    }
    
    static User newUser(String alias, String lastName, ID profileID, Boolean signedARIA) {
        String email = CommonUtils.generateGUID() + '@nxp.com.test123';
        User user = new User(EmailEncodingKey = 'UTF-8', LanguageLocaleKey = 'en_US', LocaleSidKey = 'en_US', TimeZoneSidKey = 'America/Los_Angeles');
        user.Alias = alias;
        user.LastName = lastName;
        user.ProfileId = profileID;
        user.Email = email;
        user.UserName = email;
        user.Signed_ARIA__c = signedARIA;
                
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
}