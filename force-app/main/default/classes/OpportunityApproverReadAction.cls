/************************************************************************************************************************
@Modified by: Sid Lin
@Date: 09/27/2019
@Description: SFDC-3230, Code refactoring to align with the Action component in Flow
***************************************************************************************************************************/

global class OpportunityApproverReadAction {
    @InvocableMethod
    global static List<OpportunityApproverReadActionResult> invoke(List<OpportunityApproverReadActionRequest> requests) {
        String opptyId = requests.get(0).opptyId;
        
        OpportunityApproverReadActionResult result = new OpportunityApproverReadActionResult();
        
        try {
            List<OpportunityService.DesignWinApprover> allApprovers = OpportunityService.getDesignWinApprovers(new Set<Id>{opptyId}).get(opptyId);
            
            for (OpportunityService.DesignWinApprover dwa : allApprovers) {
                
                if (dwa.label == Opportunity.Sales_Director_Approver__c.getDescribe().getLabel()) {
                    result.salesDirectorApprover = dwa.Name;
                } else if (dwa.label == Opportunity.Regional_VP_Approver__c.getDescribe().getLabel()) {
                    result.regionalVPApprover = dwa.Name;
                } else if (dwa.label == Opportunity.VP_Approver_2__c.getDescribe().getLabel()) {
                    result.vpApprover2 = dwa.Name;
                } else if (dwa.label == Opportunity.Global_Key_Account_Manager__c.getDescribe().getLabel()) {
                    result.globalKeyAccountManager = dwa.Name;
                } else if (dwa.label == Opportunity.MAG_Approver_1__c.getDescribe().getLabel()) {
                    result.magApprover1 = dwa.Name;
                } else if (dwa.label == Opportunity.MAG_Approver_2__c.getDescribe().getLabel()) {
                    result.magApprover2 = dwa.Name;
                } else if (dwa.label == Opportunity.MAG_Approver_3__c.getDescribe().getLabel()) {
                    result.magApprover3 = dwa.Name;
                } else if (dwa.label == Opportunity.MAG_Approver_4__c.getDescribe().getLabel()) {
                    result.magApprover4 = dwa.Name;
                } else if (dwa.label == Opportunity.MAG_Approver_5__c.getDescribe().getLabel()) {
                    result.magApprover5 = dwa.Name;
                } else if (dwa.label == Opportunity.MAG_Approver_6__c.getDescribe().getLabel()) {
                    result.magApprover6 = dwa.Name;
                } else if (dwa.label == Opportunity.MAG_Approver_7__c.getDescribe().getLabel()) {
                    result.magApprover7 = dwa.Name;
                } else if (dwa.label == Opportunity.MAG_Approver_8__c.getDescribe().getLabel()) {
                    result.magApprover8 = dwa.Name;
                } else if (dwa.label == Opportunity.MAG_Approver_9__c.getDescribe().getLabel()) {
                    result.magApprover9 = dwa.Name;
                } else if (dwa.label == Opportunity.MAG_Approver_10__c.getDescribe().getLabel()) {
                    result.magApprover10 = dwa.Name;
                } else if (dwa.label == Opportunity.BL_Approver_1__c.getDescribe().getLabel()) {
                    result.blApprover1 = dwa.Name;
                } else if (dwa.label == Opportunity.BL_Approver_2__c.getDescribe().getLabel()) {
                    result.blApprover2 = dwa.Name;
                } else if (dwa.label == Opportunity.BL_Approver_3__c.getDescribe().getLabel()) {
                    result.blApprover3 = dwa.Name;
                } else if (dwa.label == Opportunity.BL_Approver_4__c.getDescribe().getLabel()) {
                    result.blApprover4 = dwa.Name;
                } else if (dwa.label == Opportunity.BL_Approver_5__c.getDescribe().getLabel()) {
                    result.blApprover5 = dwa.Name;
                }

                result.message = 'Success';
            }          
        } catch (Exception e) {
            String errMsg = 'Failed to retrieve Opportunity approver(s):\n';

            if (result.salesDirectorApprover == null) {
                errMsg += 'Sales Director Approver cannot be found.\n';
            }
            
            if (result.magApprover1 == null) {
                errMsg += 'MAG Approver cannot be found.\n';
            }

            if (result.regionalVPApprover == null) {
                errMsg += 'VP Approver cannot be found.\n';
            }
            errMsg += '\nDetailed Message:\n';
            e.setMessage(errMsg + e.getMessage() + e.getStackTraceString());
            
            throw e;
        }
        
        return new List<OpportunityApproverReadActionResult>{result};
    }
    
    global class OpportunityApproverReadActionRequest {
        @InvocableVariable global String opptyId;
    }
    
    global class OpportunityApproverReadActionResult {
        @InvocableVariable global String salesDirectorApprover;
        @InvocableVariable global String regionalVPApprover;
        @InvocableVariable global String vpApprover2;
        @InvocableVariable global String globalKeyAccountManager;
        @InvocableVariable global String magApprover1;
        @InvocableVariable global String magApprover2;
        @InvocableVariable global String magApprover3;
        @InvocableVariable global String magApprover4;
        @InvocableVariable global String magApprover5;
        @InvocableVariable global String magApprover6;
        @InvocableVariable global String magApprover7;
        @InvocableVariable global String magApprover8;
        @InvocableVariable global String magApprover9;
        @InvocableVariable global String magApprover10;
        @InvocableVariable global String message;
        @InvocableVariable global String blApprover1;
        @InvocableVariable global String blApprover2;
        @InvocableVariable global String blApprover3;
        @InvocableVariable global String blApprover4;
        @InvocableVariable global String blApprover5;
    }
}