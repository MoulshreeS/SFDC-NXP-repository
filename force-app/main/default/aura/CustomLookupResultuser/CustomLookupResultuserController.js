({
	 selectDistiPrd : function(component, event, helper){      
    // get the selected Opportunity from list  
      var getDistiPrd = component.get("v.oAccount"); 
      
         
    // call the event   
      var compEvent = component.getEvent("UserSObjectRecordEvent");         
    // set the Selected Opportunity to the event attribute.  
         compEvent.setParams({"UserRecordByEvent" : getDistiPrd});                                                                  
    // fire the event  
         compEvent.fire();
    },
})