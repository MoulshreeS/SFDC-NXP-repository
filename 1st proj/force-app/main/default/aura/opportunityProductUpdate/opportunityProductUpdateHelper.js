({
	getOpportunityProducts: function(cmp) {
		var action = cmp.get("c.getOpportunityProducts");
        
        action.setParams({ 
            progId: cmp.get("v.recordId") 
        });
        
        action.setCallback(this, function(response) {
            this.hideSpinner(cmp);
            
            var state = response.getState();
            
            if (state === "SUCCESS") {
                cmp.set("v.data", response.getReturnValue());
                cmp.find("datatable").set("v.draftValues", null);
            } else {
                console.log("Failed with state: " + state);
            }
        });
        
        $A.enqueueAction(action);
        
        this.showSpinner(cmp);
	},
	
	updateOpportunityProducts: function(cmp, event) {
		var action = cmp.get("c.updateOpportunityProducts");
		
		action.setParams({ 
            changedValues: JSON.stringify(event.getParam("draftValues"))
        });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            
            if (state === "SUCCESS") {
                this.getOpportunityProducts(cmp);
            } else if (state === "ERROR") {
                var errors = response.getError();
                var message = JSON.parse(errors[0]["message"]);
                
                cmp.set("v.errors", message);
            }
        });
        
        $A.enqueueAction(action);
        
        this.showSpinner(cmp);
	},
    
    showSpinner: function(cmp) {
    	cmp.set("v.done", false);
        $A.util.removeClass(cmp.find("spinner"), "slds-hide"); 
        cmp.find("datatable").set("v.suppressBottomBar", true);
    },
    
    hideSpinner: function(cmp) {
        cmp.set("v.done", true);
        $A.util.addClass(cmp.find("spinner"), "slds-hide");
        cmp.find("datatable").set("v.suppressBottomBar", false);
    },
	
})