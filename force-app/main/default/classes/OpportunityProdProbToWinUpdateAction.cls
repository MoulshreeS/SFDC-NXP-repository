/************************************************************************************************************************
@Modified by: Sid Lin
@Date: 09/27/2019
@Description: SFDC-3230, Code refactoring to align with the Action component in Flow
***************************************************************************************************************************/

global class OpportunityProdProbToWinUpdateAction {
    @InvocableMethod
    global static List<OpportunityProdProbToWinUpdateActionResult> invoke(List<OpportunityProdProbToWinUpdateActionRequest> requests) {
        String opptyId = requests.get(0).opptyId;
        
        OpportunityProdProbToWinUpdateActionResult result = new OpportunityProdProbToWinUpdateActionResult();
        
        try {
            OpportunityService.updateProbabilityToWin(new Set<Id>{opptyId});
            result.message = 'Success';
         } catch (Exception e) {
            String errMsg = 'Failed to update Probability to Win:\n\nDetailed Message:\n';
            e.setMessage(errMsg + e.getMessage() + e.getStackTraceString());
            
            throw e;
        }
        
        return new List<OpportunityProdProbToWinUpdateActionResult>{result};
    }
    
      
    global class OpportunityProdProbToWinUpdateActionRequest {
        @InvocableVariable global String opptyId;
    }
    
    global class OpportunityProdProbToWinUpdateActionResult {
        @InvocableVariable global String message;
    }
}