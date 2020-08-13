({
    getLeadHistoryChanges : function(component) {
        
        
        var action = component.get("c.getleadhistorydetails");
        
        action.setParams({ 
            
            contactid: component.get("v.recordId")
        });
        action.setCallback(this, function(response){
            var state = response.getState();
           
            
            if (state === "SUCCESS"){
                
                var result=response.getReturnValue();
                var records =response.getReturnValue().leadHistoryChanges;
               
                records.forEach(function(record){
                    record.linkName = '/'+ record.LeadId;
                    
                });  
                
                component.set("v.leadHistoryChanges", records); 
                
            }
        });
        $A.enqueueAction(action);
        
    }
})