public without sharing class OpportunityFileService {
	
	public enum Category {DW_EVIDENCE, COMPLIANCE_RISK_ASSESSMENT, PROJECT_REPORT, TENDER_SPEC, BACKGROUND_CHECK, CUSTOMER_MEETING}
	
	public static final Map<Category, String> CATEGORIES = new Map<Category, String> {
		Category.DW_EVIDENCE => 'DW Evidence',
		Category.COMPLIANCE_RISK_ASSESSMENT => 'Compliance Risk Assessment',
		Category.PROJECT_REPORT => 'Project Report',
		Category.TENDER_SPEC => 'Tender Spec',
		Category.BACKGROUND_CHECK => 'Background Check',
		Category.CUSTOMER_MEETING => 'Customer Meeting'
	};
	
	public static final String DW_EVIDENCE = CATEGORIES.get(Category.DW_EVIDENCE);
	
	public static final Set<String> CP_EVIDENCES = new Set<String> {
		CATEGORIES.get(Category.COMPLIANCE_RISK_ASSESSMENT),
		CATEGORIES.get(Category.PROJECT_REPORT),
		CATEGORIES.get(Category.TENDER_SPEC),
		CATEGORIES.get(Category.BACKGROUND_CHECK),
		CATEGORIES.get(Category.CUSTOMER_MEETING)
	};
	
	private class OpportunityComplianceWrapper {
		public Id id { get; set; }
		public String name { get; set; }
		public String closeDate { get; set; }
		public String stage { get; set; }
		public String createdDate { get; set; }
		public String owner { get; set; }
		public String complianceRisk { get; set; }
		public Boolean steeringBoardChecked { get; set; }
		public Boolean complianceRiskAssessmentUploaded { get; set; }
		public String complianceRiskAssessmentLastModifiedDate { get; set; }
		public Boolean projectReportUploaded { get; set; }
		public String projectReportLastModifiedDate { get; set; }
		public Boolean tenderSpecUploaded { get; set; }
		public String tenderSpecLastModifiedDate { get; set; }
		public Boolean backgroundCheckUploaded { get; set; }
		public String backgroundCheckLastModifiedDate { get; set; }
		public Boolean customerMeetingUploaded { get; set; }
		public String customerMeetingLastModifiedDate { get; set; }
	}
	
	public static void updateFilesAsEvidence(Set<Id> opptyIds, Map<Id, String> typesByDocId) {
		p('updateFilesAsEvidence');
		List<ContentDocumentLink> cdls = new ContentDocumentLinksSelector().selectByOpptyIdWithContentDocument(opptyIds);
    	
		List<ContentVersion> cvs = new List<ContentVersion>();
		
		for (ContentDocumentLink cdl : cdls) {
			if (typesByDocId.containsKey(cdl.ContentDocumentId)) {
				ContentVersion cv = new ContentVersion();
				cv.Id = cdl.ContentDocument.LatestPublishedVersionId;
				cv.Category__c = typesByDocId.get(cdl.ContentDocumentId); 
				cvs.add(cv);	
			}
		} 
		
		if (!cvs.isEmpty()) {
			update cvs;		
		}
	}
	
	public static void changeEvidenceFileOwnersToDataAdmin(Set<Id> opptyIds) {
		p('changeEvidenceFileOwnersToDataAdmin');
		Map<Id, Id> ownerIdsByOpptyId = new Map<Id, Id>();
		
		for (Id oid : opptyIds) {
			ownerIdsByOpptyId.put(oid, CommonUtils.getDataAdminUserId());	
		}
		
		List<ContentDocument> cds = changeEvidenceFileOwners(ownerIdsByOpptyId);
        
        List<ContentDocumentLink> cdls = new ContentDocumentLinksSelector().selectByContentDocumentId(new Set<Id>(Collection.of(cds).pluckIds(ContentDocument.Id)));
		
		List<ContentDocumentLink> cdlsUpdated = new List<ContentDocumentLink>(); 
	
    	for (ContentDocumentLink cdl : cdls) {
    		if (cdl.ShareType == 'C') {
    			cdl.ShareType = 'V';
    			cdlsUpdated.add(cdl);		
    		}	
    	}
    	
    	if (!cdlsUpdated.isEmpty()) {
    		update cdlsUpdated;	
    	}	
    }
	
	public static void changeEvidenceFileOwnersToOpptyOwners(Set<Id> opptyIds) {
		p('changeEvidenceFileOwnersToOpptyOwners');
		Map<Id, Id> ownerIdsByOpptyId = new Map<Id, Id>();
		
		List<Opportunity> oppties = new OpportunitiesSelector().selectById(opptyIds);
        
        for (Opportunity o : oppties) {
            ownerIdsByOpptyId.put(o.Id, o.OwnerId);   
        }
		
		changeEvidenceFileOwners(ownerIdsByOpptyId);
	}
	
	private static List<ContentDocument> changeEvidenceFileOwners(Map<Id, Id> ownerIdsByOpptyId) {
    	p('changeEvidenceFileOwners');
    	List<ContentDocumentLink> cdls = new ContentDocumentLinksSelector().selectByOpptyIdWithContentDocument(ownerIdsByOpptyId.keySet());
        
        List<ContentDocument> cds = new List<ContentDocument>();
    	
    	for (ContentDocumentLink cdl : cdls) {
    		if (CATEGORIES.values().contains(cdl.ContentDocument.LatestPublishedVersion.Category__c)) {
    			ContentDocument cd = new ContentDocument();
				cd.Id = cdl.ContentDocumentId;
				cd.OwnerId = ownerIdsByOpptyId.get(cdl.LinkedEntityId);
				cds.add(cd);
			}	
    	}
    	
    	if (!cds.isEmpty()) {
    		update cds;	
    	}
    	
    	return cds;
    }
    
    public static void generateComplianceEvidenceReport(Set<Id> opptyIds) {
    	p('generateComplianceEvidenceReport');
    	List<ContentDocumentLink> cdls = new ContentDocumentLinksSelector().selectByOpptyIdWithContentDocument(opptyIds);
    	Map<Id, Map<String, Datetime>> evidenceTypesByOpptyId = new Map<Id, Map<String, Datetime>>();
    	
    	for (ContentDocumentLink cdl : cdls) {
    		String type = cdl.ContentDocument.LatestPublishedVersion.Category__c;
    		 
    		if (String.isNotBlank(type) && type != DW_EVIDENCE) {
	    		if (evidenceTypesByOpptyId.containsKey(cdl.LinkedEntityId)) {
	    			evidenceTypesByOpptyId.get(cdl.LinkedEntityId).put(type, cdl.ContentDocument.LastModifiedDate);	
	    		} else {
	    			evidenceTypesByOpptyId.put(cdl.LinkedEntityId, new Map<String, Datetime> {type => cdl.ContentDocument.LastModifiedDate});	
	    		}
    		}
    	}
    	
    	List<Opportunity> oppties = new OpportunitiesSelector().selectByIdWithAccountAndOwner(opptyIds);
    	List<OpportunityComplianceWrapper> ocws = new List<OpportunityComplianceWrapper>(); 
    	
    	for (Opportunity o : oppties) {
    		if (evidenceTypesByOpptyId.containsKey(o.Id)) {
	    		OpportunityComplianceWrapper ocw = new OpportunityComplianceWrapper();
	    		ocw.id = o.Id;
	    		ocw.name = o.Name;
	    		ocw.closeDate = o.CloseDate.format();
	    		ocw.stage = o.StageName;
	    		ocw.createdDate = o.CreatedDate.date().format();
	    		ocw.owner = o.Owner.Name;
	    		ocw.complianceRisk = o.Compliance_Risk__c;
	    		ocw.steeringBoardChecked = o.Tender_Steering_Board_Checked__c;
	    		ocw.complianceRiskAssessmentUploaded = evidenceTypesByOpptyId.get(o.Id).containsKey(CATEGORIES.get(Category.COMPLIANCE_RISK_ASSESSMENT));
	    		ocw.complianceRiskAssessmentLastModifiedDate = ocw.complianceRiskAssessmentUploaded ? evidenceTypesByOpptyId.get(o.Id).get(CATEGORIES.get(Category.COMPLIANCE_RISK_ASSESSMENT)).date().format() : '';
	    		ocw.projectReportUploaded = evidenceTypesByOpptyId.get(o.Id).containsKey(CATEGORIES.get(Category.PROJECT_REPORT));
	    		ocw.projectReportLastModifiedDate = ocw.projectReportUploaded ? evidenceTypesByOpptyId.get(o.Id).get(CATEGORIES.get(Category.PROJECT_REPORT)).date().format() : '';
	    		ocw.tenderSpecUploaded = evidenceTypesByOpptyId.get(o.Id).containsKey(CATEGORIES.get(Category.TENDER_SPEC));
	    		ocw.tenderSpecLastModifiedDate = ocw.tenderSpecUploaded ? evidenceTypesByOpptyId.get(o.Id).get(CATEGORIES.get(Category.TENDER_SPEC)).date().format() : '';
	    		ocw.backgroundCheckUploaded = evidenceTypesByOpptyId.get(o.Id).containsKey(CATEGORIES.get(Category.BACKGROUND_CHECK));
	    		ocw.backgroundCheckLastModifiedDate = ocw.backgroundCheckUploaded ? evidenceTypesByOpptyId.get(o.Id).get(CATEGORIES.get(Category.BACKGROUND_CHECK)).date().format() : '';
	    		ocw.customerMeetingUploaded = evidenceTypesByOpptyId.get(o.Id).containsKey(CATEGORIES.get(Category.CUSTOMER_MEETING));
	    		ocw.customerMeetingLastModifiedDate = ocw.customerMeetingUploaded ? evidenceTypesByOpptyId.get(o.Id).get(CATEGORIES.get(Category.CUSTOMER_MEETING)).date().format() : '';
	    		ocws.add(ocw);
    		}
    	} 
    	
    	String csv = 'Opportunity Id, Opportunity Name, Expected Close Date, Stage, Created Date, Opportunity Owner, Compliance Risk, Tender Steering Board Checked, '+ 
    				 'Compliance Risk Assessment Uploaded, Compliance Risk Assessment Last Modified Date, Project Report Uploaded, Project Report Last Modified Date, Tender Spec Uploaded, Tender Specification Last Modified Date, Background Check Uploaded, Background Check Last Modified Date, Customer Meeting Uploaded, Customer Meeting Last Modified Date\n';
		
		if (ocws.isEmpty()) {
			csv += 'No results found with the criteria:\n' +
			       'Compliance Risk = Medium or High\n' +
			       'MAG = RC4\n' +
			       'Expected Close Date = Current Year';	
		} else {
			for (OpportunityComplianceWrapper ocw : ocws) {
				csv += ocw.id + ',' + ocw.Name.escapeCsv() + ',' + ocw.closeDate + ',' + ocw.stage.escapeCsv() + ',' + ocw.createdDate + ',' + ocw.owner.escapeCsv() + ',' + 
					   ocw.complianceRisk.escapeCsv() + ',' + ocw.steeringBoardChecked + ',' +
					   ocw.complianceRiskAssessmentUploaded + ',' + ocw.complianceRiskAssessmentLastModifiedDate + ',' +
					   ocw.projectReportUploaded + ',' + ocw.projectReportLastModifiedDate + ',' +
					   ocw.tenderSpecUploaded + ',' + ocw.tenderSpecLastModifiedDate + ',' +
					   ocw.backgroundCheckUploaded + ',' + ocw.backgroundCheckLastModifiedDate + ',' +
					   ocw.customerMeetingUploaded + ',' + ocw.customerMeetingLastModifiedDate + '\n';
			}	
		}
		
		ContentVersion cv = new ContentVersion();
		cv.Title = 'Compliance Evidence Report ' + Datetime.now().format();
		cv.PathOnClient = 'Compliance Evidence Report.csv';
		cv.VersionData = Blob.valueOf(csv);
		
		insert cv;
		
		cv = new ContentVersionsSelector().selectById(new Set<Id> {cv.Id}).get(0);
		CollaborationGroup cg = [SELECT Id FROM CollaborationGroup WHERE Name = 'Opportunity Compliance'];
		
		ContentDocumentLink cdl = new ContentDocumentLink();
		cdl.ContentDocumentId = cv.ContentDocumentId;
		cdl.LinkedEntityId = cg.Id;
		cdl.ShareType = 'V';
		
		insert cdl;
	}
    
    private static void p(String msg) {
		CommonUtils.p(OpportunityFileService.class, '//-v', msg);
	}

}