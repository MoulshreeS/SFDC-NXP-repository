/************************************************************************************************************************
@Modified by: Sid Lin
@Date: 09/27/2019
@Description: SFDC-3230, Code refactoring to align with the Action component in Flow
***************************************************************************************************************************/

global class OpportunityEvidenceFileOwnerAction {

    @InvocableMethod
    global static List<OpportunityEvidenceFileOwnerActionResult> invoke(List<OpportunityEvidenceFileOwnerActionRequest> requests) {
        String opptyId = requests.get(0).opptyId;
        String errMsgToUser = 'There is an error when updating the owner of the files in this Opportunity.\n';
        
        OpportunityEvidenceFileOwnerActionResult result = new OpportunityEvidenceFileOwnerActionResult();
        
        try {
            OpportunityFileService.changeEvidenceFileOwnersToDataAdmin(new Set<Id>{opptyId});
            
            result.message = 'Success';
        } catch (Exception e) {
            String errMsg = 'Failed to change evidence owner to Data Admin:\n\nDetailed Message:\n';
            e.setMessage(errMsg + e.getMessage() + e.getStackTraceString());
            
            throw e;
        }
            
        return new List<OpportunityEvidenceFileOwnerActionResult>{result};
    }
    
    global class OpportunityEvidenceFileOwnerActionRequest {
        @InvocableVariable global String opptyId;
    }
    
    global class OpportunityEvidenceFileOwnerActionResult {
        @InvocableVariable global String message;
    }
}