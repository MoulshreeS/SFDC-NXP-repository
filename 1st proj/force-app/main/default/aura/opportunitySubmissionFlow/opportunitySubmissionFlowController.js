({				
    init: function(cmp, event, helper) {
        helper.showSpinner(cmp);
    },
    
    handleRecordUpdated: function(cmp, event, helper) {
        helper.hideSpinner(cmp);
        
        var opptyId = cmp.get("v.recordId");
        
        if (cmp.get("v.opptyRecord.Design_Win_Approval_Process__c") == 'Open') {
            var urlEvent = $A.get("e.force:navigateToURL");
            
            urlEvent.setParams({
                "url": "/flow/OpptySubmissionFlow?OpptyId=" + opptyId + "&retURL=" + opptyId
            });
            
            urlEvent.fire(); 					       					
        } else {
            helper.showToast("Only Open Opportunity can Submit for Approval.");
            $A.get("e.force:closeQuickAction").fire();
        }  
    },
})