({
    getLeadHistorytranscripts : function(component) {
        
        
        var action = component.get("c.getleadhistorydetails");
        
        action.setParams({ 
            
            transid: component.get("v.recordId")
        });
        action.setCallback(this, function(response){
            var state = response.getState();
           
         
            if (state === "SUCCESS"){
                
                var result=response.getReturnValue();
                var records =response.getReturnValue().leadHistoryChanges;
               
                records.forEach(function(record){
                    record.linkName = '/'+ record.LeadId;
                    
                });  
                
                component.set("v.leadHistorytranscripts", records); 
                
            }
        });
        $A.enqueueAction(action);
        
    }
})