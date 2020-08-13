({
    getLeadHistoryChanges : function(component) {
        
    
        var action = component.get("c.getleadhistorydetails");
        
        action.setParams({ 
            
            caseid: component.get("v.recordId")
        });
        action.setCallback(this, function(response){
            var state = response.getState();
           
            
            if (state === "SUCCESS"){
                
                var result=response.getReturnValue();
                var records =response.getReturnValue().leadHistoryChanges;
               
                records.forEach(function(record){
                    record.linkName = '/'+ record.LeadId;
                    
                });  
                
                component.set("v.leadHistoryCases", records); 
                
            }
        });
        $A.enqueueAction(action);
        
    }
})