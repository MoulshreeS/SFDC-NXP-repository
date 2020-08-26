global class OpportunityComplianceEvidenceJob implements Schedulable {
    
    global OpportunityComplianceEvidenceJob() {} // Added no-argument constructor for the Job Scheduler to see this class
    
    global void execute(SchedulableContext sc) {
    	String condition = 'RecordTypeId = \'' + OpportunitiesSelector.getSfdcRecordTypeId() + '\' AND ' + 
    					   'Compliance_Risk__c IN (\'Medium\', \'High\') AND ' + 
    					   'MAG__c LIKE \'%RC4%\' AND ' +
    					   'CloseDate = THIS_YEAR';
    					   
    	List<Opportunity> oppties = (List<Opportunity>)new OpportunitiesSelector().selectWhere(condition);
    	
    	OpportunityFileService.generateComplianceEvidenceReport(new Set<Id>(Collection.of(oppties).pluckIds()));  
    }

}