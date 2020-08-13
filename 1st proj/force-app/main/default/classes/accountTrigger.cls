/***************************************************************************************************
@Created By :       Baji
@Created Date:      28 Aug 2019
@Description:       SFDC-3176 [Added logic to update account owner for inactive child accounts]
*******************************************************************************************************/

 public class accountTrigger{

        final static String CHILD_ACCOUNT = 'Child_Account';
        final static String USER_NAME = 'Data Admin';
        

   public static void updateOwnerForInactiveChildAccounts(List<Account> lstAccounts){
        
        RecordType childAccount;
        
        //get the record type
        for(RecordType rt : [Select Id, DeveloperName
                           From RecordType
                           Where SobjectType = 'Account' and DeveloperName =: CHILD_ACCOUNT and IsActive=true
                           Limit 1])
            {
                if(rt.DeveloperName == CHILD_ACCOUNT)
                    {
                        childAccount = rt;
                    }
            }
       //get Data Admin UserId
       String userId = [select Id, Name from User where Name=: USER_NAME limit 1].id;
       
        for(Account acc : lstAccounts)
         { 
           if(acc.RecordTypeId == childAccount.Id && acc.IsInactive__c == true)         //check if record type is Pre Child
            {
                 if( acc.OwnerId != userId )
                  {
                    if( acc.OwnerId_Original__c == null )
                        {
                           acc.OwnerId_Original__c = acc.OwnerId;
                        }
                
                    acc.OwnerId = userId ; 
                  }
              }
         }
    }
 }