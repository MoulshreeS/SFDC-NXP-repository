/************************************************************************************************************************
@Modified by: Sid Lin
@Date: 09/27/2019
@Description: SFDC-3230, Code refactoring to align with the Action component in Flow
***************************************************************************************************************************/

global class OpportunityLineItemAction {
    @InvocableMethod
    global static List<OpportunityLineItemActionResult> invoke(List<OpportunityLineItemActionRequest> requests) {
        String opptyId = requests.get(0).opptyId;
        Boolean totalProductStatus = true;
		OpportunityLineItemActionResult result = new OpportunityLineItemActionResult();
        
        try {
            List<OpportunityLineItem> opptyProds = new OpportunityLineItemsSelector().selectByOpptyIdWithProduct(new Set<Id>{opptyId}, null);
            
            if (opptyProds == null || opptyProds.size() == 0) {
                totalProductStatus = false;
            }
            
            for (OpportunityLineItem item : opptyProds) {
            	if (!item.Product2.isActive) totalProductStatus = false;
            }
                    
            result.message = 'Success';
        } catch (Exception e) {
            String errMsg = 'Failed to retrieve the Opportunity Product(s):\n\nDetailed Message:\n';
            e.setMessage(errMsg + e.getMessage() + e.getStackTraceString());

            throw e;
        } finally {
            result.totalProductStatus = totalProductStatus;
        }
        
        return new List<OpportunityLineItemActionResult>{result};
    }
    
    global class OpportunityLineItemActionRequest {
        @InvocableVariable global String opptyId;
    }
    
    global class OpportunityLineItemActionResult {
        @InvocableVariable global String message;
        @InvocableVariable global Boolean totalProductStatus;
    }
}