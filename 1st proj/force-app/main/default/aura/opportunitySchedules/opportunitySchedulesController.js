({
	init: function(cmp, event, helper) {
        helper.disableProdView(cmp);
        helper.disableGridEdit(cmp);
        helper.checkPageReference(cmp);
        helper.getOpportunitySchedules(cmp);
    },
    
    onRender: function(cmp, event, helper) {
        helper.validateDates(cmp);    
    },
  
    add: function(cmp, event, helper) {
    	helper.add(cmp);    
    },
    
    remove: function(cmp, event, helper) {
    	helper.remove(cmp, 1, false);
    },
    
    reestablish: function(cmp, event, helper) {
        helper.remove(cmp, cmp.get("v.data").length - 1, true);
        helper.checkReestablish(cmp);
    },
    
    handleSave: function(cmp, event, helper) {
        if (helper.isMassUpdate(cmp)) {
        	cmp.set('v.showConfirmDialog', true);
            $A.util.removeClass(cmp.find("confirm"), "slds-hide");
        } else {
        	helper.updateOpportunitySchedules(cmp);    
        }
    },
    
    handleCancel: function(cmp, event, helper) {
        helper.reset(cmp);
    },
    
    handleSave2: function(cmp, event, helper) {
    	helper.updateOpportunityProductSchedules(cmp);
    },
    
    handleCancel2: function(cmp, event, helper) {
        helper.reset2(cmp);
    },
    
    handleChange: function(cmp, event, helper) {
    	switch (event.getSource().get("v.name")) {
        	case "toggle":
                helper.handleViewChange(cmp);
                break;
            case "closeDate":
                helper.handleCloseDateChange(cmp);
                break;
            case "prodDate":
                helper.handleProdDateChange(cmp);
                break;
            case "prodList":
                helper.handleProdListChange(cmp);
                break;
        }	
    },
    
    handleRecordUpdated2: function(cmp, event, helper) {
        helper.handleRecordUpdated2(cmp);    
    },
    
    handleConfirmDialogYes : function(cmp, event, helper) {
        cmp.set('v.showConfirmDialog', false);
        $A.util.addClass(cmp.find("confirm"), "slds-hide");
        helper.updateOpportunitySchedules(cmp);
    },
     
    handleConfirmDialogNo : function(cmp, event, helper) {
        cmp.set('v.showConfirmDialog', false);
        $A.util.addClass(cmp.find("confirm"), "slds-hide");
    },
    
})