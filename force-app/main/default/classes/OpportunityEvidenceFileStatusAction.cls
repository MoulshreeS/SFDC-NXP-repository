global with sharing class OpportunityEvidenceFileStatusAction {
    @InvocableMethod
    global static List<OpportunityEvidenceFileStatusActionResult> invoke(List<OpportunityEvidenceFileStatusActionRequest> requests) {
        String opptyId = requests.get(0).opptyId;
        Boolean cpEvidenceFileStatus = false;
        Boolean dwEvidenceFileStatus = false;
		Set<String> cpEvidences = new Set<String>();
		OpportunityEvidenceFileStatusActionResult result = new OpportunityEvidenceFileStatusActionResult();
        
        try {
            List<ContentDocumentLink> cdls = new ContentDocumentLinksSelector().selectByOpptyIdWithContentDocument(new Set<Id> {opptyId});
            
            for (ContentDocumentLink cdl : cdls) {
            	if (cdl.ContentDocument.LatestPublishedVersion.Category__c == OpportunityFileService.DW_EVIDENCE) {
            		dwEvidenceFileStatus = true;
            	} else if (OpportunityFileService.CP_EVIDENCES.contains(cdl.ContentDocument.LatestPublishedVersion.Category__c)) {
            		cpEvidences.add(cdl.ContentDocument.LatestPublishedVersion.Category__c);
            	}
            }
            
            cpEvidenceFileStatus = cpEvidences.equals(OpportunityFileService.CP_EVIDENCES);
                    
            result.message = 'Success';
        } catch (Exception e) {
            String errMsg = 'Failed to check evidence type(s):\n\nDetailed Message:\n';
            e.setMessage(errMsg + e.getMessage() + e.getStackTraceString());
            
            throw e;
        } finally {
            result.cpEvidenceFileStatus = cpEvidenceFileStatus;
            result.dwEvidenceFileStatus = dwEvidenceFileStatus;
        }
        
        return new List<OpportunityEvidenceFileStatusActionResult>{result};
    }
    
    global class OpportunityEvidenceFileStatusActionRequest {
        @InvocableVariable global String opptyId;
    }
    
    global class OpportunityEvidenceFileStatusActionResult {
        @InvocableVariable global String message;
        @InvocableVariable global Boolean dwEvidenceFileStatus;
        @InvocableVariable global Boolean cpEvidenceFileStatus;
    }
}