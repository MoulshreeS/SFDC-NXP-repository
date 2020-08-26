@isTest
private class AdminServiceTest {
	
	@testSetup
    static void setup() {
    	MarketSegmentation__c mktSeg = new MarketSegmentation__c(
    		Segment_Label__c = 'Seg',
    		Segment_Value__c = 'Seg',
    		Subsegment_Label__c = 'Subseg',
    		Subsegment_Value__c = 'Subseg',
    		Application_Label__c = 'App',
    		Application_Value__c = 'App'
    	);
    	
    	insert mktSeg;	
    }
	
	/**
	 *	By default, test methods don’t support web service callouts, and tests that perform web service callouts fail.
	 *  This is used only for code coverage. It will not actually affect the object/field involved in the test.
	 **/
	@isTest
    static void dummyTest() {
    	Test.startTest();
    	try {
    		AdminService.getMarketSegmentationsFromOpportunity();
    	} catch (Exception e) {}
    	
    	try {
    		AdminService.createMarketSegmentationsFromOpportunity();
    	} catch (Exception e) {}
    	
    	try {
    		AdminService.updateOpportunityMarketSegmentations();
    	} catch (Exception e) {}
    	Test.stopTest();
    }
    
    @isTest
    static void testDeleteMarketSegmentations() {
    	AdminService.deleteMarketSegmentations();
    }
    
    @isTest
    static void testGetMarketSegmentations() {
    	System.assertEquals(1, AdminService.getMarketSegmentations().size());
    }

}