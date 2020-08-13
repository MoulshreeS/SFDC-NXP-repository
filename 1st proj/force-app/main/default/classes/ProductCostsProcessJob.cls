global class ProductCostsProcessJob implements Schedulable, Database.Batchable<SObject> {
	
	private static final String STATUS_QUEUED = ProductCostStages.STATUS_QUEUED;
	private static final String STATUS_PROCESSING = ProductCostStages.STATUS_PROCESSING;
	private static final String STATUS_FAILED = ProductCostStages.STATUS_FAILED;
	private static final String MAIL_REPLY_TO = 'no.reply@nxp.com';
	private static final String MAIL_SENDER_NAME = ProductCostsProcessJob.class.getName();
	private static final String MAIL_SUBJECT = MAIL_SENDER_NAME + ' Failed';
	private static final Integer RECORD_COUNT_LIMIT = 10000;
		
	private Id schedJobId;
	
	global ProductCostsProcessJob() {} // Added no-argument constructor for the Job Scheduler to see this class
	
	global ProductCostsProcessJob(Id schedJobId) {
		this.schedJobId = schedJobId;
	}
	
	global void execute(SchedulableContext sc) {
		p('execute(schedule)');
		Database.executeBatch(new ProductCostsProcessJob(sc.getTriggerId()));
	}
	
	global Database.QueryLocator start(Database.BatchableContext bc) {
		p('start');
		if (!Test.isRunningTest() && !CommonUtils.isDataAdminUser()) throw new SecurityException('Only Data Admin is allowed to execute ProductCostsProcessJob.');
		
		if (isJobActive(bc.getJobId())) return new ProductCostStagesSelector().selectByStatusQueryLocator(new Set<String> {null}); // Skip processing 
		
		Database.QueryLocator result = new ProductCostStagesSelector().selectByStatusQueryLocator(new Set<String> {STATUS_QUEUED}, RECORD_COUNT_LIMIT);
		
		List<ProductCostStage__c> prodCostStages = new List<ProductCostStage__c>(); 
		
		for (Database.QueryLocatorIterator it = result.iterator(); it.hasNext();) {
			ProductCostStage__c prodCostStage = (ProductCostStage__c)it.next();	
			prodCostStage.Status__c = STATUS_PROCESSING;
			prodCostStage.Message__c = null;
			prodCostStage.Product_Cost__c = null;
			prodCostStage.Sched_Job_ID__c = this.schedJobId;
			prodCostStage.Batch_Job_ID__c = bc.getJobId();
			prodCostStages.add(prodCostStage);
		} 
		
		update prodCostStages;
		
		return result;
	}
	
	global void execute(Database.BatchableContext bc, List<ProductCostStage__c> scope) {
		p('execute(batch)');
		try {
			ProductCostStages.newInstance(new ProductCostStagesSelector().selectById(new Map<Id, ProductCostStage__c>(scope).keySet())).processData();
		} catch (Exception e) {
			String message = 'Scheduled Job Id: ' + this.schedJobId + '<br><br>' +
							 'Exception type caught: ' + e.getTypeName() + '<br>' +
			                 'Message: ' + e.getMessage() + '<br>' +
			                 'Cause: ' + e.getCause() + '<br>' +
			                 'Line number: ' + e.getLineNumber() + '<br>' +
			                 'Stack trace: ' + e.getStackTraceString();
			                 
			CommonUtils.notify(new List<String> {'globalsales.appsupport@nxp.com'}, MAIL_REPLY_TO, MAIL_SENDER_NAME, MAIL_SUBJECT, message);
		}	
	}
	
	global void finish(Database.BatchableContext bc) {
		p('finish');
		AsyncApexJob apexJob = new AsyncApexJobsSelector().selectByIdWithCreatedBy(new Set<Id> {bc.getJobId()}).get(0);
		
		if (apexJob.Status != 'Completed' || apexJob.NumberOfErrors > 0) {
			updateStatus(bc.getJobId(), apexJob.ExtendedStatus);
			
			String message = 'Scheduled Job Id: ' + this.schedJobId + ', Batch Job Id: ' + bc.getJobId() + '<br><br>' +
		                 	 'Total Batches: ' + apexJob.TotalJobItems + ', Batches Processed: ' + apexJob.JobItemsProcessed + ', Failures: ' + apexJob.NumberOfErrors + '<br><br>' +
		                 	 'Message:<br><br>' + apexJob.ExtendedStatus;
		
			CommonUtils.notify(new List<String> {apexJob.CreatedBy.Email}, MAIL_REPLY_TO, MAIL_SENDER_NAME, MAIL_SUBJECT, message);		
		}	
	}
	
	private Boolean isJobActive(Id jobId) {
		p('isJobActive');
		String condition = 'Id != \'' + jobId + '\' and ParentJobId != \'' + jobId + '\' and JobType = \'BatchApex\' and ApexClass.Name = \'' + ProductCostsProcessJob.class + '\' and ' +
		                   'Status in (\'Holding\', \'Queued\', \'Preparing\')'; // Parallel Mode 
		
		return new AsyncApexJobsSelector().selectWhere(condition).size() > 0;	
	}
	
	@TestVisible 
	private void updateStatus(Id jobId, String message) {
		p('updateStatus');
		List<ProductCostStage__c> prodCostStages = new ProductCostStagesSelector().selectByStatus(new Set<String> {STATUS_PROCESSING});
		List<ProductCostStage__c> prodCostStagesUpdated = new List<ProductCostStage__c>(); 
		
		for (ProductCostStage__c pcs : prodCostStages) {
			if (pcs.Batch_Job_ID__c == jobId) {
				pcs.Status__c = STATUS_FAILED;
				pcs.Message__c = message;
				prodCostStagesUpdated.add(pcs);
			}	
		}
		
		update prodCostStagesUpdated;
	}
	
	private static void p(String msg) {
		CommonUtils.p(ProductCostsProcessJob.class, '//-c', msg);
   	}

}