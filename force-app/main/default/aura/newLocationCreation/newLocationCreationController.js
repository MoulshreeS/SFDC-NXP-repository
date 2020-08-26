({

    createRecord : function (cmp, event, helper) {
        var recordTypeId = $A.get("$Label.c.Customer_Recordtype_Loc");
        var createRecordEvent = $A.get("e.force:createRecord");
        createRecordEvent.setParams({
            "entityApiName": "Customer__c",
            "recordTypeId": recordTypeId,
             "defaultFieldValues": {
                 'Account_Name__c': cmp.get("v.record.Account_Name__c"),
                 'Legal_Name__c': cmp.get("v.record.Legal_Name__c"),
                 'Sales_Area__c' : cmp.get("v.record.Sales_Area__c"),
                 'Global_Enterprise__c' : cmp.get("v.record.Parent_Account_in_CRM__c"),
                 'House_Number__c': cmp.get("v.record.House_Number__c"),
                 'DUNS__c': cmp.get("v.record.DUNS_Number__c"),
				 'Street__c': cmp.get("v.record.Street__c"),
				 'Street_2__c': cmp.get("v.record.Street_2__c"),
				 'Street_3__c': cmp.get("v.record.Street_3__c"),
                 'City__c': cmp.get("v.record.City__c"),
				 'State__c': cmp.get("v.record.State__c"),
                 'Country__c': cmp.get("v.record.Country__c"),
                 'ZIP__c': cmp.get("v.record.Postal_Code__c"),
                 'Website__c': cmp.get("v.record.Website__c"),
                 'EMail__c':cmp.get("v.record.EMail__c"),
                 'Telephone__c':cmp.get("v.record.Telephone__c"),
                 'Fax__c':cmp.get("v.record.Fax__c"),
                 'Fulfillment_Channel__c':cmp.get("v.record.Fulfillment_Channel__c"),
                 'GSM_Classification__c':cmp.get("v.record.Customer_Category__c"), 
                 'Role__c':cmp.get("v.record.Role__c"),
                 'Type__c':cmp.get("v.record.Type__c"),
                 'Industry_Segment__c':cmp.get("v.record.Industry_Segment__c"), 
                 'Industry_Sub_Segment__c':cmp.get("v.record.Industry_Sub_Segment__c"),
                 'SIC_Code__c' :cmp.get("v.record.SIC_Code__c"),
                 'NAICS_Code__c':cmp.get("v.record.NAICS_Code__c"),
                 'CMD_Request_Id__c': cmp.get("v.recordId")
       }
	});
		createRecordEvent.fire();
	},
})