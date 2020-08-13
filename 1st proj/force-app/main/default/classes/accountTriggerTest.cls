@isTest
private class accountTriggerTest {

    private static final String PARENT_ACCOUNT_STAR = 'STAR';
    private static final String PARENT_ACCOUNT_SAMSUNG = 'Samsung';
    private static final String CBG_AUTOMOTIVE = 'Automotive';
    public  static list<Account> lstAccountstobeUpdated = new list<Account>();

  static testMethod void updateOwnerforInactiveChildActs(){

        // Insert accounts
        createAccount(PARENT_ACCOUNT_STAR, AccountsSelector.getParentRecordTypeID(), null, null);
        createAccount(PARENT_ACCOUNT_SAMSUNG, AccountsSelector.getParentRecordTypeID(), null, null);
        Account parentGeneral = createAccount('Parent Account - General', AccountsSelector.getParentRecordTypeID(), null, null);
        Account childAccount = createAccount('Test Account', AccountsSelector.getChildRecordTypeID(), parentGeneral.Id, CBG_AUTOMOTIVE);
        
        list<Account> lstAccounts = [select id,name,IsInactive__c from Account where id=:childAccount.id];
        
        //start the Test       
        Test.startTest();
        
        for(Account objAcc : lstAccounts){
             objAcc.IsInactive__c = true;
             lstAccountstobeUpdated.add(objAcc);
           }
           
        update lstAccountstobeUpdated;
        
        //get updated child account details
        childAccount = [select id,name,IsInactive__c,owner.name,ownerid,OwnerId_Original__c from Account where id=:childAccount.id];
        
        //get Data Admin UserId
        Id userId = [select Id, Name from User where Name= 'Data Admin' limit 1].id;
        
        
        System.assert(childAccount.ownerid == userId);
        
        
        //Stop the Test
        Test.stopTest();

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