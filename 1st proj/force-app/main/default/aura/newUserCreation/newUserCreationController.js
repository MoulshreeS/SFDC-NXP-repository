({

    createRecord : function (cmp, event, helper) {
        
        var createRecordEvent = $A.get("e.force:createRecord");
        createRecordEvent.setParams({
            "entityApiName": "User",
            "defaultFieldValues": {
                 'FirstName': cmp.get("v.record.First_Name__c"),
				 'LastName': cmp.get("v.record.Last_Name__c"),
				 'Email': cmp.get("v.record.Email_Address__c"),
				 'Username': cmp.get("v.record.Email_Address__c"),
                 'User_Region__c': cmp.get("v.record.Region__c"),
                 'Title': cmp.get("v.record.Job_Title__c"),
                 'Phone': cmp.get("v.record.Phone_Number__c"),
                 'Manager': cmp.get("v.record.Manager_Name__c"),
                 'SAML_Deployment_Wave__c':cmp.get("v.record.SAML_Deployment_Wave__c"),
                 'CommunityNickname': cmp.get("v.record.First_Name__c") +"."+ cmp.get("v.record.Last_Name__c"),
				 'Alias': cmp.get("v.record.First_Name__c").substring(0, 1) + cmp.get("v.record.Last_Name__c").substring(0, 4),
				 'ProfileId': '00e57000001PqlnAAC',
                 'UserRoleId': '00E57000001j3vgEAA',
                 'User_License__c': '10020000000MvnM',
				 'New_User_Registration_ID__c': cmp.get("v.recordId")
       }
	});
		createRecordEvent.fire();
	},
})