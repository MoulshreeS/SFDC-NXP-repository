({
	getOpportunities: function(cmp) {
		var action = cmp.get("c.getOpportunities");
        
        action.setParams({ 
            progId: cmp.get("v.recordId") 
        });
        
        action.setCallback(this, function(response) {
            this.hideSpinner(cmp);
            
            var state = response.getState();
            
            if (state === "SUCCESS") {
                cmp.set("v.data", response.getReturnValue());
            } else {
                console.log("Failed with state: " + state);
            }
        });
        
        $A.enqueueAction(action);
        
        this.showSpinner(cmp);
	},
    
    showSpinner: function(cmp) {
    	cmp.set("v.done", false);
        $A.util.removeClass(cmp.find("spinner"), "slds-hide");    
    },
    
    hideSpinner: function(cmp) {
        cmp.set("v.done", true);
        $A.util.addClass(cmp.find("spinner"), "slds-hide");    
    },
})