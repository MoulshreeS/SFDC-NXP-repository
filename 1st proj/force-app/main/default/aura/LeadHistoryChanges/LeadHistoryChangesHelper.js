({
    getLeadHistoryChanges: function(component, page, recordToDisplay, leadId) {
        var action = component.get("c.queryLeadHistoryRecords");
		
        action.setParams({
            "pageNumber": page,
            "recordToDisplay": recordToDisplay,
            "leadId": leadId
        });
 
        action.setCallback(this, function(a) {
            var result = a.getReturnValue();
            console.log('result ---->' + JSON.stringify(result)); 
            component.set("v.leadHistoryChanges", result.leadHistoryChanges);
            component.set("v.page", result.page);
            component.set("v.total", result.total);
            
            var pg = component.get("v.page");
         
             var num = Math.ceil(result.total/recordToDisplay) ;

            if(result.leadHistoryChanges == '' ||  pg == num){
				             
                component.set("v.pages", pg);
            }
            else{
            
               component.set("v.pages", 0); 
    
            }
            component.set("v.isSpinner", false);
        });
        component.set("v.isSpinner", true);
        $A.enqueueAction(action);
        
    }
    })