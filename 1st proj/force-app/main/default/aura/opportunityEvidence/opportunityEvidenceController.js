({
	init: function(cmp, event, helper) {
        cmp.set("v.columns", helper.getColumnDefinitions(cmp, true));
        
        $A.util.addClass(cmp.find("nodata"), "slds-hide");
        
        helper.getFiles(cmp);
    },
    
    handleRecordUpdated: function(cmp, event, helper) {
        helper.checkEditMode(cmp);
    },
    
    handleUploadFinished: function(cmp, event, helper) {
        helper.getFiles(cmp);
    },
    
    handleRowAction: function(cmp, event, helper) {
        var action = event.getParam("action");
        var row = event.getParam("row");
        
        helper.updateType(cmp, row, action);
    },
    
    save: function(cmp, event, helper) {
    	helper.save(cmp);    	
	},
})