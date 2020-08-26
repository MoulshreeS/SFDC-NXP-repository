({    
	handleForwardToDisti : function(component, event, helper) 
    {
        var leadId = component.get("v.recordId");
        var objContact = component.get("v.Contact");
        
        var contactId;
        if(objContact != null && objContact.contactId != null)
        {
            contactId = objContact.contactId;
            component.set("v.message",null);
			var action = component.get("c.forwardLeadWithinDisti");
        	action.setParams({
                leadId:leadId,
                contactId : contactId
            });
            action.setCallback(this,function(a){
                this.handleResponse(a,component,helper);    
            });        
            $A.enqueueAction(action);
			component.set("v.IsProcessing", true); 
        }
        else
        {
            component.set("v.messagetype",'error');
            component.set("v.message",['Please select the contact before forwarding.']);
        }		
	},
    handleResponse : function(response, component, helper) 
    {
        console.log("---response received : " + response.getState());
        component.set("v.IsProcessing", false); 
		
        if(response.getState()==='SUCCESS')
        {
			// show success notification
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": "Success!",
                "message": "Lead has been forwarded successfully."
            });
            toastEvent.fire();
            $A.get("e.force:closeQuickAction").fire();
            $A.get('e.force:refreshView').fire();
        }
        else if(response.getState() == 'ERROR')
        {
 			var errors = response.getError();
            var errMessages = ['Error Occured'];
            component.set("v.messagetype", 'error' );
            
            if(errors)
            {
            	if (errors[0] && errors[0].message)
                {
                	errMessages.push(errors[0].message);
            	}    
            }
            component.set("v.message", errMessages );           
        }		
	},
    handleCancel : function(component, event, helper) 
    {
		var dismissActionPanel = $A.get("e.force:closeQuickAction");
        if(dismissActionPanel)
        {
        	dismissActionPanel.fire();    
        }
	},
    handleToNextStep : function(component, event, helper) 
    {
        component.set("v.IsDefaultView", false );
        component.set("v.message", null );        
	},
    
    handleBack: function(component, event, helper) 
    {
		component.set("v.IsDefaultView", true );
        component.set("v.inputEmail", null );
        component.set("v.contactFound", null);
        component.set("v.ShowSearchResults", false);
        component.set("v.createNewContact", false);
	},    
    handleSearchContactByEmail: function(component, event, helper) 
    {
        component.set("v.message",null);
        component.set("v.contactFound", null);
        component.set("v.ShowSearchResults", false);
        
        component.set("v.createNewContact", false);
       
        var strEmail =  component.get("v.inputEmail");
        if(strEmail)
        {
        	var action = component.get("c.findContactByEmail");
            action.setParams({
                email: strEmail
            });        
            action.setCallback(this,function(resp){
                this.handleResponseSearchContactByEmail(resp, component, helper);    
            });        
            $A.enqueueAction(action);
            component.set("v.IsProcessing", true);     
        }
        else
        {
            component.set("v.messagetype",'error');
            component.set("v.message",['Please provide Email address before searching.']);
        }
    },    
    handleResponseSearchContactByEmail : function(response, component, helper) 
    {
        component.set("v.IsProcessing", false); 
        component.set("v.ShowSearchResults", true);
        if(response.getState()==='SUCCESS') 
        {
            var contact = response.getReturnValue();
            if(contact) 
            {
                component.set("v.contactFound", contact);
            }
        } 
        else if(response.getState() == 'ERROR') 
        {
 			var errors = response.getError();
            var errMessages = ['Error Occured'];
            component.set("v.messagetype", 'error');
            
            if(errors) 
            {
            	if (errors[0] && errors[0].message) 
                {
                	errMessages.push(errors[0].message);
            	}    
            }            
            component.set("v.message", errMessages );           
        }		
	},    
    handleAddContact: function(component, event, helper) 
    {
        component.set("v.message",null);
        var contactFound = component.get("v.contactFound");
                
        if(contactFound.Id != null)
        {
        	var action = component.get("c.moveContactToForwardeeAccount");
            action.setParams({
                contactId: contactFound.Id
            });        
            action.setCallback(this,function(resp){
                this.handleResponseAddContact(resp, component, helper);    
            });        
            $A.enqueueAction(action);
            component.set("v.IsProcessing", true);     
        }
        else
        {
            component.set("v.messagetype",'error');
            component.set("v.message",['Please search the contact before adding.']);
        }
    },
	handleResponseAddContact : function(response, component, helper) 
    {
        component.set("v.IsProcessing", false); 
        
        if(response.getState()==='SUCCESS') 
        {
            var contactFound = component.get("v.contactFound");
            var contactWrapper = {
                contactId : contactFound.Id,
                contactName : contactFound.Name,
                emailId : contactFound.Email,
                customerName : contactFound.Account.Name,
                itemText : contactFound.Name+'('+contactFound.Email+')'+contactFound.Account.Name
            };        
            component.set("v.IsDefaultView", true );
            component.set("v.ShowSearchResults", false);
            component.set("v.Contact", contactWrapper);
            component.set("v.inputEmail", null );
            component.set("v.contactFound", null);
        } 
        else if(response.getState() == 'ERROR') 
        {
 			var errors = response.getError();
            var errMessages = ['Error Occured'];
            component.set("v.messagetype", 'error');
            
            if(errors) 
            {
            	if (errors[0] && errors[0].message) 
                {
                	errMessages.push(errors[0].message);
            	}    
            }            
            component.set("v.message", errMessages );           
        }		
	},     
    handleCreateNewContact: function(component, event, helper) 
    {
        var action = component.get("c.getAccountIdAndCountryFromCurrentCommunityUser");
        action.setCallback(this,function(resp){
                this.handleResponseCreateNewContact(resp, component, helper);    
            });        
        
        $A.enqueueAction(action);
        component.set("v.IsProcessing", true); 
    },
	handleResponseCreateNewContact: function(response, component, helper) 
    {
        component.set("v.IsProcessing", false); 
        component.set("v.createNewContact", true);
        
        if(response.getState()==='SUCCESS') 
        {
            var returnedUser = response.getReturnValue();            
            component.set("v.communityUserAccountId", returnedUser.Contact.AccountId);
			component.set("v.communityUserCountry", returnedUser.Contact.Community_web_country__c);            
        } 
        else if(response.getState() == 'ERROR') 
        {
 			var errors = response.getError();
            var errMessages = ['Error Occured'];
            component.set("v.messagetype", 'error');
            
            if(errors) 
            {
            	if (errors[0] && errors[0].message) 
                {
                	errMessages.push(errors[0].message);
            	}    
            }            
            component.set("v.message", errMessages );           
        }		
	},    
    handleSaveNewContact: function(component, event, helper) {
        event.preventDefault();
        var fields = event.getParam("fields");
        fields["Email"] = component.get("v.inputEmail");
        fields["AccountId"] = component.get("v.communityUserAccountId");
        fields["Community_web_country__c"] = component.get("v.communityUserCountry");
        component.find('newContactEditForm').submit(fields);
    },    
    handleSaveNewContactSuccess: function(component, event, helper) {
        var payload = event.getParams().response;
        var jsonResponse = JSON.parse(JSON.stringify(payload));
        var contactName = jsonResponse["fields"]["FirstName"]["value"] + " " + jsonResponse["fields"]["LastName"]["value"];
        var contactEmail = jsonResponse["fields"]["Email"]["value"];
        var accountName = jsonResponse["fields"]["Account"]["displayValue"];
        var contactWrapper = {
            contactId : jsonResponse["id"],
            contactName : contactName,
            emailId : contactEmail,
            customerName : accountName,
            itemText : contactName+'('+contactEmail+')'+accountName
        };
        
        component.set("v.Contact", contactWrapper);
        component.set("v.IsDefaultView", true );
        component.set("v.inputEmail", null );
        component.set("v.contactFound", null);
        component.set("v.ShowSearchResults", false);
    },
})