public without sharing class OpportunityEvidenceController {
    
    public class FileWrapper {
		@AuraEnabled public String id { get; set; }
		@AuraEnabled public String type { get; set; }
		@AuraEnabled public String title { get; set; }
		@AuraEnabled public String titleUrl { get; set; }
		@AuraEnabled public Datetime lastModifiedDate { get; set; }
	}
	
	@AuraEnabled
    public static List<FileWrapper> getFiles(Id opptyId) {
    	p('getFiles');
    	List<FileWrapper> result = new List<FileWrapper>(); 
    	
    	List<ContentDocumentLink> cdls = new ContentDocumentLinksSelector().selectByOpptyIdWithContentDocument(new Set<Id> {opptyId});
    	                                 
		for (ContentDocumentLink cdl : cdls) {
			FileWrapper fw = new FileWrapper();
			fw.id = cdl.ContentDocumentId;
			fw.type = cdl.ContentDocument.LatestPublishedVersion.Category__c;
			fw.title = cdl.ContentDocument.Title;
			fw.titleUrl = '/' + cdl.ContentDocumentId;
			fw.lastModifiedDate = cdl.ContentDocument.LastModifiedDate;
			result.add(fw);
		}
		
		return result;    	                                   	
    }
    
    @AuraEnabled
    public static void updateFilesAsEvidence(Id opptyId, List<FileWrapper> files) {
    	p('updateFilesAsEvidence');
    	try {
    		Map<Id, String> typesByDocId = new Map<Id, String>();
    		
    		for (FileWrapper fw : files) {
    			typesByDocId.put(fw.id, fw.type);	
    		}
    		
    		OpportunityFileService.updateFilesAsEvidence(new Set<Id> {opptyId}, typesByDocId);
    	} catch (Exception e) {
			String msg = e.getMessage();
			
			if (msg.contains('FIELD_CUSTOM_VALIDATION_EXCEPTION')) {
				msg = msg.substringBetween('FIELD_CUSTOM_VALIDATION_EXCEPTION,', ': []');	
			}
			
			throw new AuraHandledException(msg);
		}
	}
   
	private static void p(String msg) {
		CommonUtils.p(OpportunityEvidenceController.class, '//-c', msg);
	}

}