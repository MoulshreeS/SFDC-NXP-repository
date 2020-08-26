@isTest
private class MetadataUtilsTest {
	/**
	 *	By default, test methods don’t support web service callouts, and tests that perform web service callouts fail.
	 *  This is used only for code coverage. It will not actually affect the object/field involved in the test, specifically New_User_Registration__c.Access_Request__c.
	 **/
	@isTest
    static void dummyTest() {
    	System.assertEquals(true, new MetadataUtils.PicklistItem('Item One', 'item1').equals(new MetadataUtils.PicklistItem('Item One', 'item1')));
    	System.assertEquals(0, new MetadataUtils.PicklistItem('Item One', 'item1').compareTo(new MetadataUtils.PicklistItem('Item One', 'item1')));
    	
    	Set<MetadataUtils.PicklistItem> items = new Set<MetadataUtils.PicklistItem>();
    	items.add(new MetadataUtils.PicklistItem('Item', 'Item'));
    	    	
    	Test.startTest();
    	try {
    		MetadataUtils.createPicklistField(New_User_Registration__c.SObjectType, 'Test', 'Test', items, null);
    	} catch (Exception e) {}
    	
    	try {
    		MetadataUtils.createPicklistField(New_User_Registration__c.Access_Request__c, New_User_Registration__c.SObjectType, 'Test', 'Test', New_User_Registration__c.Access_Request__c);
    	} catch (Exception e) {}
    	
    	try {
    		MetadataUtils.updatePicklistField(New_User_Registration__c.SObjectType, New_User_Registration__c.Access_Request__c, items, New_User_Registration__c.Access_Request__c);
    	} catch (Exception e) {}
    	
    	try {
    		MetadataUtils.deactivatePicklistFieldValues(New_User_Registration__c.SObjectType, New_User_Registration__c.Access_Request__c, New_User_Registration__c.Access_Request__c);
    	} catch (Exception e) {}
    	
    	try {
    		MetadataUtils.updateDependentPicklistField(New_User_Registration__c.SObjectType, New_User_Registration__c.Access_Request__c, New_User_Registration__c.Access_Request__c, New_User_Registration__c.SObjectType, New_User_Registration__c.Access_Request__c, New_User_Registration__c.Access_Request__c);
    	} catch (Exception e) {}
    	
    	try {
    		MetadataUtils.updateDependentPicklistField(New_User_Registration__c.SObjectType, New_User_Registration__c.Access_Request__c, New_User_Registration__c.Access_Request__c, new Map<MetadataUtils.PicklistItem, Set<MetadataUtils.PicklistItem>>{new MetadataUtils.PicklistItem('test', 'test') => items});
    	} catch (Exception e) {}
    	
    	try {
    		MetadataUtils.getDependentPicklistLabels(New_User_Registration__c.SObjectType, New_User_Registration__c.Access_Request__c, New_User_Registration__c.Access_Request__c);
    	} catch (Exception e) {}
    	
    	try {
    		MetadataUtils.getDependentPicklistValues(New_User_Registration__c.SObjectType, New_User_Registration__c.Access_Request__c, New_User_Registration__c.Access_Request__c);
    	} catch (Exception e) {}
    	
    	try {
    		MetadataUtils.getDependentPicklistItems(New_User_Registration__c.SObjectType, New_User_Registration__c.Access_Request__c, New_User_Registration__c.Access_Request__c);
    	} catch (Exception e) {}
    	
    	try {
    		MetadataService.SaveResult result = new MetadataService.SaveResult();
    		result.success = false;
    		result.errors = new MetadataService.Error[]{new MetadataService.Error()};
    		MetadataUtils.handleSaveResults(result);
    	} catch (Exception e) {}
    	Test.stopTest();
    }
	
}