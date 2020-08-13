@isTest 
private class TestAnonymizeChatTranscript {
	
	@TestSetup static void createChatTranscripts(){
        Profile objProfile= [SELECT Id FROM Profile WHERE name='System Administrator' Limit 1];
        User objUser = new User(alias = 'admin',email='testadmin@nxp.com',emailencodingkey='UTF-8',
        lastname='Testing', languagelocalekey='en_US',localesidkey='en_US',profileid = objProfile.id,
        timezonesidkey='America/Los_Angeles',username='testadmin@nxp.com');
        insert objUser;
		 system.runAs(objUser)
        {
            //create a new Chat Visitor
            LiveChatVisitor visitor = new LiveChatVisitor();
            insert visitor;
            //create a Live Chat Transcript
            LiveChatTranscript trans = new LiveChatTranscript(LiveChatVisitorId = visitor.Id,
                                                            Email__c = 'test@test.com',
                                                            First_Name__c = 'Customer',
                                                            Last_Name__c = 'User',
                                                            Country__c  = 'INDIA',
                                                            Company__c  = 'No Company',
															RequestTime=Date.today().addDays(-32),
															Don_t_Anonymize__c=false,
															Consent_To_Store_Data__c=false
                                                            );
			insert trans;			
		}
	
	}

	@isTest
	private static void testGDPRObfuscation() {
		AnonymizeChatTranscript ac= new AnonymizeChatTranscript();
		List<LiveChatTranscript> lcts = [SELECT Id, First_Name__c,Email__c,Last_Name__c, Name FROM LiveChatTranscript where Don_t_Anonymize__c=false AND Email__c<> :AnonymizeChatTranscript.ANONYMIZATION_CONSTANT_EMAIL AND ((Consent_To_Store_Data__c =false AND RequestTime<LAST_N_DAYS:30) OR (Consent_To_Store_Data__c =true AND RequestTime<LAST_N_DAYS:180))];
		Database.QueryLocator ql = ac.start(null);
		ac.execute(null,lcts);
		ac.finish(null);
		lcts = [SELECT Id, First_Name__c,Email__c,Last_Name__c, Name FROM LiveChatTranscript where Don_t_Anonymize__c=false AND ((Consent_To_Store_Data__c =false AND RequestTime<LAST_N_DAYS:30) OR (Consent_To_Store_Data__c =true AND RequestTime<LAST_N_DAYS:180))];
		for(LiveChatTranscript lct : lcts){
			System.assertEquals(lct.Email__c,AnonymizeChatTranscript.ANONYMIZATION_CONSTANT_EMAIL);
		}
		
		
	}
}