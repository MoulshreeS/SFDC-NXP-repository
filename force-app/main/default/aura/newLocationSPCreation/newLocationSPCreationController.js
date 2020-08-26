({

    createRecord : function (cmp, event, helper) {
        var recordTypeId = $A.get("$Label.c.Customer_Recordtype_Loc");
        var createRecordEvent = $A.get("e.force:createRecord");
        createRecordEvent.setParams({
            "entityApiName": "Customer__c",
            "recordTypeId": recordTypeId,
             "defaultFieldValues": {
                 'Legal_Name__c': cmp.get("v.record.SP_Name__c"),
                 'Account_Name__c': cmp.get("v.record.SP_Name__c").substring(0, 30),
                 'Street__c': cmp.get("v.record.SP_Street__c"),
                 'City__c': cmp.get("v.record.SP_City__c"),
                 'State__c':cmp.get("v.record.SP_State__c"),
                 'ZIP__c': cmp.get("v.record.SP_Postal_Code__c"),
                 'Country__c': cmp.get("v.record.SP_Country__c"),
                 'EMail__c' : cmp.get("v.record.SP_Email__c"),
                 'Telephone__c' : cmp.get("v.record.SP_Telephone__c"),
                 'Fax__c' : cmp.get("v.record.SP_Fax__c"),
                 'CMD_Request_Id__c': cmp.get("v.recordId")
       }
	});
		createRecordEvent.fire();
	},
})