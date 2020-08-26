/***************************************************************************************************
@Created By :      Bhagyashree B
@Created Date:     Jan 9 2020
@Description:      apex class called to fetch the logged in profile name for wizard
**********************************************************************************************************/

@isTest 
private class GetUserProfileNameFrmUserIdTest {
    @isTest static void validateGetUserProfileNameFrmUserId(){
        List<User> userList=new List<User>();
        Id communityUserProfileId= CasePortalUtil.CUSTOMER_COMMUNITY_PLUS_PROFILE_Id;
       
        Id accountTypeId =  AccountHelper.getChildRecordTypeID();  
        Account account = new Account(Name = 'Test BMB Child', RecordTypeId = accountTypeId);
        insert account;
        system.assert(account.Id != null);
        
        Contact testContact1 = new Contact(FirstName = 'test BMB First', LastName = 'test BMB Last', Email = 'duplicateusertest1@nxp.com', 
                                          AccountId = account.Id, Community_web_country__c = 'India',contact_service_level__c='A1');
        
        insert testContact1 ;
        system.assert(testContact1.Id != null);
        
       // User user1= new User(alias = 'bmb', email='getuserprofilrname@test.com', emailencodingkey='UTF-8', lastname='test', languagelocalekey='en_US', localesidkey='en_US', 
       //                          profileid = communityUserProfileId, timezonesidkey='America/Los_Angeles', username= 'getuserprofilrname@test.com');
            
        User user1=TestUtil.createTestUser('duplicateusertest@nxp.com', 'BMB', communityUserProfileId);
        user1.ContactId=testContact1.Id;
        
        UserList.add(user1);
		insert UserList;
        
 		system.debug('profile name UserList'+UserList);
        system.assert(userList[0].Id != null);
        system.debug('profile name'+userList[0].Profile.Name);
       //	system.assertEquals('NXP Customer Community Plus Login User', userList[0].Profile.Name);
        
        Test.startTest();
		List<string> returnValue=GetUserProfileNameFrmUserId.getUserInfo(userList);
        system.assert(returnValue.size()>0);
 		Test.stopTest();
    }
}