/************************************************************************************************************************
@Modified by: Sid Lin
@Date: 09/27/2019
@Description: SFDC-3230, Code refactoring to align with the Action component in Flow
***************************************************************************************************************************/

global class OpportunityApproverUpdateAction {

    @InvocableMethod
    global static List<OpportunityApproverUpdateActionResult> invoke(List<OpportunityApproverUpdateActionRequest> requests) {
        String opptyId = requests.get(0).opptyId;
        String errMsgToUser = 'There is an error when updating the approvers of this Opportunity.\n';
        
        OpportunityApproverUpdateActionResult result = new OpportunityApproverUpdateActionResult();
        
        try {
            OpportunityService.updateDesignWinApprovers(new Set<Id>{opptyId});
            
            result.message = 'Success';
        } catch (Exception e) {
            String errMsg = 'Failed to update Opportunity approver(s):\n\nDetailed Message:\n';
            e.setMessage(errMsg + e.getMessage() + e.getStackTraceString());
            
            throw e;
        }
            
        return new List<OpportunityApproverUpdateActionResult>{result};
    }
    
    global class OpportunityApproverUpdateActionRequest {
        @InvocableVariable global String opptyId;
    }
    
    global class OpportunityApproverUpdateActionResult {
        @InvocableVariable global String message;
    }
}