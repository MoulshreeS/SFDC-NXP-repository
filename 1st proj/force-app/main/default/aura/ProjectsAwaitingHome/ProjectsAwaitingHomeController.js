({
	openModel: function(component, event, helper) {
      // for Display Model,set the "isOpen" attribute to "true"
        component.set("v.isOpen", true);
        var Id = event.getSource().get("v.value");
      	component.set("v.projectTeamId",Id);
        var action = component.get("c.getProjectDetailList");
        action.setParams({ "projectTeamId" : component.get("v.projectTeamId") });
        action.setCallback(this,function(a){
        if (a.getState() === "SUCCESS") {
        	component.set("v.projectDetail",a.getReturnValue());
		} 
        else if (a.getState() === "ERROR") {
		   $A.log("Errors", a.getError());
           alert('There is an unknown error.Please contact your system administrator for further details'); 
		}
        });
    	$A.enqueueAction(action);        
        
   },
 
   closeModel: function(component, event, helper) {
      // for Hide/Close Model,set the "isOpen" attribute to "False"  
      	component.set("v.isOpen", false);
   },
    closeModel1 :function(component, event, helper) {
      // for Hide/Close Model,set the "SuccessBox" attribute to "False"  
     	component.set("v.SuccessBox", false);
        window.location.reload();
   },
    RejectionConfirmed : function(component, event, helper) {
   		helper.OnReject(component, event);
   },
    closeModelReject : function(component, event, helper) {
        component.set("v.confirmOnReject", false);
   },
    OnReject: function(component, event, helper) {
   		component.set("v.confirmOnReject", true);
        component.set("v.isOpen", false);
   },
    OnAccept : function(component, event, helper) {
   		helper.OnAccept(component, event);
   },
     toggleSection : function(component, event, helper) {
        // dynamically get aura:id name from 'data-auraId' attribute
        var sectionAuraId = event.target.getAttribute("data-auraId");
        // get section Div element using aura:id
        var sectionDiv = component.find(sectionAuraId).getElement();
        /* The search() method searches for 'slds-is-open' class, and returns the position of the match.
         * This method returns -1 if no match is found.
        */
        var sectionState = sectionDiv.getAttribute('class').search('slds-is-open'); 
        
        // -1 if 'slds-is-open' class is missing...then set 'slds-is-open' class else set slds-is-close class to element
        if(sectionState == -1){
            sectionDiv.setAttribute('class' , 'slds-section slds-is-open slds-size_1-of-1');
        }else{
            sectionDiv.setAttribute('class' , 'slds-section slds-is-close slds-size_1-of-1');
        }
    },
    getProjects : function(component, event, helper) {
        helper.getProjects(component, event);//get data from the helper
    },
    goToRec : function(component, event, helper) {
        var projectId = component.get("v.projectId");
        var navLink = component.find("navLink");
        var pageRef = {
            type: 'standard__recordPage',
            attributes: {
                actionName: 'view',
                objectApiName: 'Project__c',
                recordId : projectId // record id. 
            },
        };
        navLink.navigate(pageRef, true);
    },
})