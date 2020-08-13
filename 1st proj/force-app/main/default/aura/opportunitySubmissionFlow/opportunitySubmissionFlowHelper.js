({
	showSpinner: function(cmp) {
    	cmp.set("v.done", false);
        $A.util.removeClass(cmp.find("spinner"), "slds-hide");    
    },
    
    hideSpinner: function(cmp) {
        cmp.set("v.done", true);
        $A.util.addClass(cmp.find("spinner"), "slds-hide");    
    },
    
    showToast: function(msg) {
        var toastEvent = $A.get("e.force:showToast");
        
        var params = {
            mode: "dismissible",
            type: "error",
            message: msg
        }
        
        toastEvent.setParams(params);
        toastEvent.fire();
    },
})