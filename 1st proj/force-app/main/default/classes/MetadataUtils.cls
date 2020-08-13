public class MetadataUtils {
	
	public class MetadataUtilsException extends Exception {}
	
	public class PicklistItem implements Comparable {
        public String label { get; private set; }
        public String value { get; private set; }
        public Boolean active { get; set; }
        
        public PicklistItem(String label, String value) {
        	this.label = label;
        	this.value = value;
        	this.active = true;
        }
        
        public Boolean equals(Object o) {
        	if (o === this) return true;
        	
        	if (!(o instanceof PicklistItem)) return false;
			
			PicklistItem pi = (PicklistItem)o;
			
			return pi.label == label && pi.value == value;
		}
		
		public Integer hashCode() {
			Integer result = label.hashCode();
			result = 31 * result + value.hashCode();
			
			return result;
		}
		
		public Integer compareTo(Object compareTo) {
			return label.compareTo(((PicklistItem)compareTo).label);
		}
    }
    
    public static void createPicklistField(Schema.SObjectType objectType, String fieldLabel, String fieldName, Set<PicklistItem> items, Schema.SObjectField ctrlField) {
    	MetadataService.MetadataPort service = createService();
        
        MetadataService.CustomField customField = new MetadataService.CustomField();
        customField.fullName = objectType + '.' + fieldName + '__c';
        customField.label = fieldLabel;
        customField.type_x = 'Picklist';
        
        Metadataservice.ValueSet valueSet = new Metadataservice.ValueSet();
        MetadataService.ValueSetValuesDefinition valueSetDefinition = new MetadataService.ValueSetValuesDefinition();
        List<MetadataService.CustomValue> values = new List<MetadataService.CustomValue>();
        
        for (PicklistItem item : items) {
        	MetadataService.CustomValue value = new MetadataService.CustomValue();
			value.fullName = item.value; 
			value.default_x = false;
			value.isActive = item.active;
			value.label = item.label;
			values.add(value);	
        }
        
        valueSetDefinition.value = values;
		valueSetDefinition.sorted = true;
		
		valueSet.controllingField = ctrlField != null ? String.valueOf(ctrlField) : null;
		valueSet.valueSetDefinition = valueSetDefinition;
		
		customField.valueSet = valueSet;
        
        List<MetadataService.SaveResult> results = service.createMetadata(new MetadataService.Metadata[] {customField});
        
        handleSaveResults(results[0]);	
    }
   
    public static void createPicklistField(Schema.SObjectField srcField, Schema.SObjectType destObjectType, String destFieldLabel, String destFieldName, Schema.SObjectField destCtrlField) {
        MetadataService.MetadataPort service = createService();
        
        MetadataService.CustomField customField = new MetadataService.CustomField();
        customField.fullName = destObjectType + '.' + destFieldName + '__c';
        customField.label = destFieldLabel;
        customField.type_x = 'Picklist';
        
        Metadataservice.ValueSet valueSet = new Metadataservice.ValueSet();
        MetadataService.ValueSetValuesDefinition valueSetDefinition = new MetadataService.ValueSetValuesDefinition();
        List<MetadataService.CustomValue> values = new List<MetadataService.CustomValue>();
        
        for (Schema.PicklistEntry entry : srcField.getDescribe().getPicklistValues()) {
        	MetadataService.CustomValue value = new MetadataService.CustomValue();
			value.fullName = entry.getValue(); 
			value.default_x = entry.isDefaultValue();
			value.isActive = entry.isActive();
			value.label = entry.getLabel();
			values.add(value);	
        }
        
        valueSetDefinition.value = values;
		valueSetDefinition.sorted = false;
		
		valueSet.controllingField = destCtrlField != null ? String.valueOf(destCtrlField) : null;
		valueSet.valueSetDefinition = valueSetDefinition;
		
		customField.valueSet = valueSet;
        
        List<MetadataService.SaveResult> results = service.createMetadata(new MetadataService.Metadata[] {customField});
        
        handleSaveResults(results[0]);
    }
    
    public static void updatePicklistField(Schema.SObjectType objectType, Schema.SObjectField field, Set<PicklistItem> items, Schema.SObjectField ctrlField) {
        MetadataService.MetadataPort service = createService();
        
        MetadataService.CustomField customField = new MetadataService.CustomField();
        customField.fullName = objectType + '.' + field;
        customField.label = field.getDescribe().getLabel();
        customField.type_x = 'Picklist';
        
        Metadataservice.ValueSet valueSet = new Metadataservice.ValueSet();
        MetadataService.ValueSetValuesDefinition valueSetDefinition = new MetadataService.ValueSetValuesDefinition();
        List<MetadataService.CustomValue> values = new List<MetadataService.CustomValue>();
        
        for (PicklistItem item : items) {
        	MetadataService.CustomValue value = new MetadataService.CustomValue();
			value.fullName = item.value; 
			value.default_x = false;
			value.isActive = item.active;
			value.label = item.active ? item.label : '(Old) ' + item.label;
			values.add(value);	
        }
        
        valueSetDefinition.value = values;
		valueSetDefinition.sorted = true;
		
		valueSet.controllingField = ctrlField != null ? String.valueOf(ctrlField) : null;
		valueSet.valueSetDefinition = valueSetDefinition;
		
		customField.valueSet = valueSet;
        
        List<MetadataService.SaveResult> results = service.updateMetadata(new MetadataService.Metadata[] {customField});
        
        handleSaveResults(results[0]);
    }
    
    public static void deactivatePicklistFieldValues(Schema.SObjectType objectType, Schema.SObjectField field, Schema.SObjectField ctrlField) {
    	Set<PicklistItem> items = new Set<PicklistItem>();  
    	
    	for (Schema.PicklistEntry entry : field.getDescribe().getPicklistValues()) {
    		PicklistItem item = new PicklistItem(entry.getLabel(), entry.getValue());
        	item.active = false;
			items.add(item);	
        }
        
        updatePicklistField(objectType, field, items, ctrlField);
    }
    
    public static void updateDependentPicklistField(Schema.SObjectType srcObjectType, Schema.SObjectField srcCtrlField, Schema.SObjectField srcDepdField, Schema.SObjectType destObjectType, Schema.SObjectField destCtrlField, Schema.SObjectField destDepdField) {
    	updateDependentPicklistField(destObjectType, destCtrlField, destDepdField, getDependentPicklistItems(srcObjectType, srcCtrlField, srcDepdField));
    }
    
    public static void updateDependentPicklistField(Schema.SObjectType objectType, Schema.SObjectField ctrlField, Schema.SObjectField depdField, Map<PicklistItem, Set<PicklistItem>> depdItemsByCtrlItem) {
        MetadataService.MetadataPort service = createService();
        
        MetadataService.CustomField customField = new MetadataService.CustomField();
        customField.fullName = objectType + '.' + depdField;
        customField.label = depdField.getDescribe().getLabel();
        customField.type_x = 'Picklist';
        
        Metadataservice.ValueSet valueSet = new Metadataservice.ValueSet();
        MetadataService.ValueSetValuesDefinition valueSetDefinition = new MetadataService.ValueSetValuesDefinition();
        List<MetadataService.CustomValue> values = new List<MetadataService.CustomValue>();
        List<MetadataService.ValueSettings> valueSettings = new List<MetadataService.ValueSettings>();
        
		Set<PicklistItem> depdItems = new Set<PicklistItem>();
		
		for (Set<PicklistItem> items : depdItemsByCtrlItem.values()) {
			for (PicklistItem item : items) {
				depdItems.add(item);	
			}	
		}
		
		for (PicklistItem item : depdItems) {
        	MetadataService.CustomValue value = new MetadataService.CustomValue();
			value.fullName = item.value; 
			value.default_x = false;
			value.isActive = item.active;
			value.label = item.label;
			values.add(value);
			
			MetadataService.ValueSettings valueSetting = new MetadataService.ValueSettings(); 
			List<String> controllingFieldValue = new List<String>(); 
			
			for (PicklistItem ctrlItem : depdItemsByCtrlItem.keySet()) {
				if (depdItemsByCtrlItem.get(ctrlItem).contains(item)) {
					controllingFieldValue.add(ctrlItem.value);	
				}  		
			}
			
			valueSetting.controllingFieldValue = controllingFieldValue;
			valueSetting.valueName = item.value;
			valueSettings.add(valueSetting);	
        }
		
		valueSetDefinition.value = values;
		valueSetDefinition.sorted = true;
		
		valueSet.controllingField = String.valueOf(ctrlField);
		valueSet.valueSetDefinition = valueSetDefinition;
		valueSet.valueSettings = valueSettings;
		
		customField.valueSet = valueSet;
        
        List<MetadataService.SaveResult> results = service.updateMetadata(new MetadataService.Metadata[] {customField});
        
        handleSaveResults(results[0]);
    }
    
    public static Map<String, List<String>> getDependentPicklistLabels(Schema.SObjectType objectType, Schema.SObjectField controllingField, Schema.SObjectField dependentField) {
    	Map<String, List<String>> result = new Map<String, List<String>>();
        
        Map<PicklistItem, Set<PicklistItem>> depdItemsByCtrlItem = getDependentPicklistItems(objectType, controllingField, dependentField);
        
        for (PicklistItem ctrlItem : depdItemsByCtrlItem.keySet()) {
        	List<String> depdLabels = new List<String>();
        	
        	for (PicklistItem depdItem : depdItemsByCtrlItem.get(ctrlItem)) {
        		depdLabels.add(depdItem.label);		
        	}
        	
        	result.put(ctrlItem.label, depdLabels);
        }
        
        return result;
    }
    
    public static Map<String, List<String>> getDependentPicklistValues(Schema.SObjectType objectType, Schema.SObjectField controllingField, Schema.SObjectField dependentField) {
    	Map<String, List<String>> result = new Map<String, List<String>>();
        
        Map<PicklistItem, Set<PicklistItem>> depdItemsByCtrlItem = getDependentPicklistItems(objectType, controllingField, dependentField);
        
        for (PicklistItem ctrlItem : depdItemsByCtrlItem.keySet()) {
        	List<String> depdValues = new List<String>();
        	
        	for (PicklistItem depdItem : depdItemsByCtrlItem.get(ctrlItem)) {
        		depdValues.add(depdItem.value);		
        	}
        	
        	result.put(ctrlItem.value, depdValues);
        }
        
        return result;
    }
    
    public static Map<PicklistItem, Set<PicklistItem>> getDependentPicklistItems(Schema.SObjectType objectType, Schema.SObjectField controllingField, Schema.SObjectField dependentField) {
    	Map<PicklistItem, Set<PicklistItem>> result = new Map<PicklistItem, Set<PicklistItem>>();
    	
    	MetadataService.MetadataPort service = createService();

		MetadataService.CustomField ctrlField = (MetadataService.CustomField)service.readMetadata('CustomField', new String[] {objectType + '.' + controllingField}).getRecords()[0];
        MetadataService.CustomField depdField = (MetadataService.CustomField)service.readMetadata('CustomField', new String[] {objectType + '.' + dependentField}).getRecords()[0];
        
        Map<String, MetadataService.ValueSettings> depdFieldValueSettingsByValueName = new Map<String, MetadataService.ValueSettings>();
        
        for (MetadataService.ValueSettings valueSetting : depdField.valueSet.valueSettings) {
        	depdFieldValueSettingsByValueName.put(valueSetting.valueName, valueSetting);	
        }

        for (MetadataService.CustomValue controllingValue : ctrlField.valueSet.valueSetDefinition.value) {
        	if (!result.containsKey(new PicklistItem(controllingValue.label, controllingValue.fullName))) {
        		result.put(new PicklistItem(controllingValue.label, controllingValue.fullName), new Set<PicklistItem>());	
        	}
        	
        	for (Schema.PicklistEntry entry : dependentField.getDescribe().getPicklistValues()) { // To get the correct order of picklist values
        		MetadataService.ValueSettings valueSetting = depdFieldValueSettingsByValueName.get(entry.getValue());
        		
        		if (valueSetting.controllingFieldValue.contains(controllingValue.fullName)) {
                	result.get(new PicklistItem(controllingValue.label, controllingValue.fullName)).add(new PicklistItem(entry.getLabel(), entry.getValue()));
            	}
        	}
        }
        
        return result;
    }
    
    public static MetadataService.MetadataPort createService() {
        MetadataService.MetadataPort service = new MetadataService.MetadataPort();
        service.SessionHeader = new MetadataService.SessionHeader_element();
        service.SessionHeader.sessionId = UserInfo.getSessionId();
        
        return service;
    }
    
    public static void handleSaveResults(MetadataService.SaveResult saveResult) {
        if (saveResult == null || saveResult.success) return;
        
        if (saveResult.errors != null) {
            List<String> messages = new List<String>();
            
            messages.add((saveResult.errors.size() == 1 ? 'Error ' : 'Errors ') + 'occured processing component ' + saveResult.fullName + '.');
            
            for (MetadataService.Error error : saveResult.errors) {
            	messages.add(error.message + ' (' + error.statusCode + ').' + (error.fields != null && error.fields.size() > 0 ? ' Fields ' + String.join(error.fields, ',') + '.' : ''));	
            }
                
            if (messages.size() > 0) throw new MetadataUtilsException(String.join(messages, ' '));
        }
        
        if (!saveResult.success) throw new MetadataUtilsException('Request failed with no specified error.');
    }

}