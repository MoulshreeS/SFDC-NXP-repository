/**
 * Applicaiton specific Domain base class. Customize fflib_SObjectDomain and add common behaviour.
 **/
public abstract class ApplicationDomain extends fflib_SObjectDomain {
    
    /**
     * Constructor required for Test.createStub
     **/
    public ApplicationDomain() {
        super();
    }
    
    public ApplicationDomain(List<SObject> records) {
        super(records);
        // Disable the base class CRUD checking in preference to explicit checking elsewhere
        Configuration.disableTriggerCRUDSecurity();
    }
    
    public String getSObjectName() {
    	return getSObjectType().getDescribe().getName();
    }
    
    protected void bypassValidation(Map<Id, SObject> existingRecords) {
		Map<String, Schema.SObjectField> fields = fflib_SObjectDescribe.getDescribe(this.getSObjectType()).getFieldsMap();
		List<Schema.SObjectField> bypassFields = BypassValidationFieldsSelector.selectBySObject(this.getSObjectType());
		
		for (SObject newObj : this.records) {
			newObj.put('Bypass_Validation__c', false);
			Boolean bypassFieldsChanged = false;
			Boolean otherFieldsChanged = false;
			
			SObject oldObj = existingRecords.get(newObj.Id);
			
			for (Schema.SObjectField f : bypassFields) {
				bypassFieldsChanged |= (newObj.get(f) != oldObj.get(f));	
			}
			
			if (bypassFieldsChanged) {
				for (Schema.SObjectField field : fields.values()) {
					if (!bypassFields.contains(field) && field != fields.get('Bypass_Validation__c') && field.getDescribe().isUpdateable()) {
						String fieldName = field.getDescribe().getName();
						
						if (newObj.get(fieldName) != oldObj.get(fieldName)) {
							otherFieldsChanged = true;
							break;
						}	
					}
				}
				
				if (!otherFieldsChanged) {
					newObj.put('Bypass_Validation__c', true);
				}		
			}
		}
	}
    
    protected void p(String msg) {
    	CommonUtils.p(this, '//-d', msg);
    }
        
}