({
    getFiles: function(cmp) {
        this.showSpinner(cmp);
        
		var action = cmp.get("c.getFiles");
        
        action.setParams({ 
            opptyId: cmp.get("v.recordId") 
        });
        
        action.setCallback(this, function(response) {
            this.hideSpinner(cmp);
            
            var state = response.getState();
            
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                
                cmp.set("v.data", result);
                
                if (result && result.length > 0) {
                    $A.util.removeClass(cmp.find("data"), "slds-hide");
                	$A.util.addClass(cmp.find("nodata"), "slds-hide");  
                } else {
                    $A.util.addClass(cmp.find("data"), "slds-hide");
                	$A.util.removeClass(cmp.find("nodata"), "slds-hide");    
                }
            } else {
                console.log("Failed with state: " + state);
            }
        });
        
        $A.enqueueAction(action);	
	},
    
    save: function(cmp) {
        if (cmp.get("v.data").length == 0) {
            return;
        }
        
        this.showSpinner(cmp);
        
        var action = cmp.get("c.updateFilesAsEvidence");
		
		action.setParams({
            opptyId: cmp.get("v.recordId"),
            files: cmp.get("v.updatedRows")
        });
        
        action.setCallback(this, function(response) {
            this.hideSpinner(cmp);
            
            var state = response.getState();
            
            if (state === "SUCCESS") {
                var resultsToast = $A.get("e.force:showToast");
                
                resultsToast.setParams({
                    "type": "success",
                    "message": "Saved Successfully"
                });
                
                resultsToast.fire();
                
                this.clearError(cmp);
            } else if (state === "ERROR") {
                var errors = response.getError();
                this.showError(cmp, errors[0].message);
            }
        });
        
        $A.enqueueAction(action);	
	},
    
    updateType: function(cmp, row, action) {
    	var data = cmp.get('v.data');
        var rowIndex = data.indexOf(row);
		data[rowIndex].type = action.name;
        
        cmp.set("v.data", data);
        
        var updatedRows = cmp.get('v.updatedRows'); 
        updatedRows.push(row);
        cmp.set("v.updatedRows", updatedRows);
        
        this.save(cmp);
    },
    
    showSpinner: function(cmp) {
    	cmp.set("v.done", false);
        $A.util.removeClass(cmp.find("spinner"), "slds-hide");    
    },
    
    hideSpinner: function(cmp) {
    	cmp.set("v.done", true);
        $A.util.addClass(cmp.find("spinner"), "slds-hide");    
    },
    
    clearError: function(cmp) {
    	cmp.set("v.showError", false);
        cmp.set("v.errorMessage", "");    
    },
    
    showError: function(cmp, msg) {
    	cmp.set("v.showError", true);
        cmp.set("v.errorMessage", msg);    
    },
    
    checkEditMode: function(cmp) {
        var status = cmp.get("v.opptyRecord.Design_Win_Approval_Process__c"); 
   
        if (status == "Pending" || status == "Approved") {
            this.disableEdit(cmp);    
        } else {
            this.enableEdit(cmp);
        }
    },
    
    disableEdit: function(cmp) {
        cmp.set("v.columns", this.getColumnDefinitions(cmp, false));
        $A.util.addClass(cmp.find("header"), "slds-hide");
        $A.util.addClass(cmp.find("fileUpload"), "slds-hide");
        //$A.util.addClass(cmp.find("save"), "slds-hide");
    },
    
    enableEdit: function(cmp) {
        cmp.set("v.columns", this.getColumnDefinitions(cmp, true));
    	$A.util.removeClass(cmp.find("header"), "slds-hide");
        $A.util.removeClass(cmp.find("fileUpload"), "slds-hide");
        //$A.util.removeClass(cmp.find("save"), "slds-hide");
    },
    
    getColumnDefinitions: function(cmp, editable) {
        var actions = [
        	{label: "<Blank>", name: ""},
            {label: "DW Evidence", name: "DW Evidence"},
            {label: "Compliance Risk Assessment", name: "Compliance Risk Assessment"},
            {label: "Project Report", name: "Project Report"},
            {label: "Tender Spec", name: "Tender Spec"},
            {label: "Background Check", name: "Background Check"},
            {label: "Customer Meeting", name: "Customer Meeting"}
        ];
            
        var columns = [
            {label: "Evidence Type", fieldName: "type", type: "text"},
            {label: "Title", fieldName: "titleUrl", type: "url", typeAttributes: {label: {fieldName: "title"}, tooltip: {fieldName: "title"}, target: "_blank"}},
            {label: "Last Modified Date", fieldName: "lastModifiedDate", type: "date", typeAttributes: {year: "numeric", month: "numeric", day: "numeric", hour: "2-digit", minute: "2-digit", hour12: "true"}}
        ];
        
        if (editable) {
            columns.unshift({type: "action", typeAttributes: {rowActions: actions, menuAlignment: "auto"}});
        }
        
    	return columns;
    },
})