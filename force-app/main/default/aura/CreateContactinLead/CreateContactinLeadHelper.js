({
    fetchLeadVal : function(component) {
        
        var action = component.get("c.getLeadDetails");
        
        
        action.setParams({ 
            
            Leadid: component.get("v.recordId")
        });
        
        action.setCallback(this, function(response){
            var state = response.getState();
            
            
            if (state === "SUCCESS"){
                component.set("v.toggleSpinner", false);
                
                var result=response.getReturnValue();
                
                component.set("v.Lead", result); 
            }
        });
        $A.enqueueAction(action);
    },
    
    checkduplicatecontactemail : function(component) {
        
        var action = component.get("c.getcontactemail");
        
        
        action.setParams({ 
            
            Leadid: component.get("v.recordId")
        });
        
        action.setCallback(this, function(response){
            var state = response.getState();
            
            
            if (state === "SUCCESS"){
                
                var result=response.getReturnValue();
                
                component.set("v.dupContactexists", result);
                /* 
                if(result != null){
                    
                    component.set("v.dupContactexists", true);
                    
                }
                else{
                    component.set("v.dupContactexists", false);
                }
                */
                
                
            }
        });
         $A.enqueueAction(action);
     },
    
    
    
    fetchrecordtype : function(component) {
        
        
        var action = component.get("c.getrecordtype");
        
        
        action.setParams({ 
            
            Leadid: component.get("v.recordId")
        });
        
        action.setCallback(this, function(response){
            var state = response.getState();
            
            if (state === "SUCCESS"){
                
                var result=response.getReturnValue();
                
                component.set("v.recordtypeexixts", result);
                
            }
            
        });
        $A.enqueueAction(action);
        
    },
    
    fetchrecordtypeval : function(component) {
        
        var action1 = component.get("c.fetchAccountrectype");
        
        action1.setParams({ 
            
            Leadid: component.get("v.recordId")
        });
        
        action1.setCallback(this, function(response){
            var state = response.getState();
            
            if (state === "SUCCESS"){
                
                var result=response.getReturnValue();
                
                if(result != null || result != ""){
                    component.set("v.selectedRecord", result); 
                    
                }
                else{
                    // component.set("v.recordtypeexixts", false); 
                    component.set("v.selectedRecord", ""); 
                    
                    
                }
                
                
                
            }
            
            if (state === "ERROR"){
                
                component.set("v.selectedRecord", ""); 
            }
            
            
            
        });
        
        $A.enqueueAction(action1);
        
        
        
    },
    
    
    searchHelper : function(component,event,getInputkeyWord) {
        // call the apex class method 
        var action = component.get("c.fetchAccountlist"); 
        
        // set param to method        
        action.setParams({
            'searchKeyWord': getInputkeyWord            
        });                         
        // set a callBack    
        action.setCallback(this, function(response) {
            var state = response.getState();
            
            if (state === "SUCCESS") {
                var storeResponse = response.getReturnValue();
                
                // if storeResponse size is equal 0 ,display No Result Found... message on screen.
                
                if (storeResponse.length == 0) {
                    component.set("v.Message", 'No Result Found...');
                }                	
                else {
                    component.set("v.Message", 'Search Result...');
                }  
                
                // set searchResult list with return value from server.
                component.set("v.listOfSearchRecords", storeResponse);
            }
            
        });
        
        // enqueue the Action  
        $A.enqueueAction(action);    
    },
    
    
});