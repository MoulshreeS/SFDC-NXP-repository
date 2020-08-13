({
	doInit : function(component, event, helper) {
        
        var action = component.get("c.autoCreateContactForInternalUser");
        	action.setCallback(this,function(a){
                //this.handleResponse(a,component,helper);    
            });        
            $A.enqueueAction(action);		
	},
    
    handleResponse : function(response, component, helper) 
    {
	}
})