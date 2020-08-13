@isTest
private class ProductCostsProcessJobTest {
	
	private static final String STATUS_QUEUED = ProductCostStages.STATUS_QUEUED;
	private static final String STATUS_PROCESSING = ProductCostStages.STATUS_PROCESSING;
	private static final String STATUS_COMPLETED = ProductCostStages.STATUS_COMPLETED;
	private static final String STATUS_INVALID = ProductCostStages.STATUS_INVALID;
	private static final String STATUS_DUPLICATED = ProductCostStages.STATUS_DUPLICATED;
	private static final String STATUS_FAILED = ProductCostStages.STATUS_FAILED;
	private static final String SALES_ITEM = '123456789000';
	private static final String SALES_ITEM_CLONE = '123456789001';
	
	private static ProductCostStage__c prodCostStage;
	
	static {
		List<ProductCostStage__c> prodCostStages = (List<ProductCostStage__c>)new ProductCostStagesSelector().selectAll();
		
		if (prodCostStages.size() > 0) {
			prodCostStage = prodCostStages.get(0); 	
		}	
	} 
	
	@testSetup
    static void setup() {
    	List<Product2> prods = new List<Product2>(); 
    	
    	for (Integer i = 0; i < 2; i++) {
    		Product2 p = new Product2(Name = 'Test Product ' + i, Sales_Item__c = '12345678900' + i);
    		prods.add(p);	
    	}
    	
    	
    	insert prods;
    	
    	ProductCostStage__c prodCostStage = new ProductCostStage__c();
    	prodCostStage.Sales_Item__c = SALES_ITEM;
    	prodCostStage.Unit_Cost__c = 0.15;
    	
    	insert prodCostStage;
    	
    	List<ProductCostStage__c> prodCostStages = (List<ProductCostStage__c>)new ProductCostStagesSelector().selectAll();
    	
		System.assertEquals(STATUS_QUEUED, prodCostStages.get(0).Status__c);
    	
    	processData();
    }
    
    @isTest
    static void testSetup() {
    	List<Product2> prods = (List<Product2>)new ProductsSelector().selectAll();
		
		System.assertEquals(2, prods.size());
		
		List<ProductCost__c> prodCosts = new ProductCostsSelector().selectBySalesItem(new Set<String> {SALES_ITEM});
		
		System.assertEquals(1, prodCosts.size());
		
		System.assertEquals(STATUS_COMPLETED, prodCostStage.Status__c);
    }
    
    @isTest
    static void testBatch() {
    	clone();
    	
    	Test.startTest();
    	runBatch();
    	Test.stopTest();
    	
    	List<ProductCost__c> prodCosts = new ProductCostsSelector().selectBySalesItem(new Set<String> {SALES_ITEM_CLONE});
    	System.assertEquals(1, prodCosts.size());
    }
    
    @isTest
    static void testUpdateStatus() {
    	String jobId = '7070E00000MlbZUQAZ';
    	String message = 'some error';
    	
    	prodCostStage.Status__c = STATUS_PROCESSING;	
    	prodCostStage.Batch_Job_ID__c = jobId;
    	
    	update prodCostStage;
    	
    	new ProductCostsProcessJob().updateStatus(jobId, message);
    	
    	ProductCostStage__c pcs = new ProductCostStagesSelector().selectById(new Set<Id> {prodCostStage.Id}).get(0);
    	System.assertEquals(STATUS_FAILED, pcs.Status__c);
    	System.assertEquals(message, pcs.Message__c);
    }
    
    @isTest
    static void testScheduler() {
    	clone();
    	
    	Datetime dt = Datetime.now().addDays(1);
        String CRON_EXP = '0 0 0 ' + dt.day() + ' ' + dt.month() + ' ? ' + dt.year();
    	
    	String schedJobId = System.schedule('ProductCostsProcessJobTest', CRON_EXP, new ProductCostsProcessJob());
    	CronTrigger ct = [select Id, CronExpression, TimesTriggered, NextFireTime from CronTrigger where Id = :schedJobId];
    	System.assertEquals(CRON_EXP, ct.CronExpression);
    	System.assertEquals(0, ct.TimesTriggered);
    	System.assertEquals(dt.format('yyyy-MM-dd 00:00:00'), String.valueOf(ct.NextFireTime));
    }
    
    @isTest
    static void testUpdate() {
    	final Decimal UNIT_COST = 1.23;
    	 
    	prodCostStage.Status__c = STATUS_QUEUED;
    	prodCostStage.Unit_Cost__c = UNIT_COST;
    	
    	update prodCostStage;
    	
    	processData();
    	
    	ProductCost__c pc = new ProductCostsSelector().selectBySalesItem(new Set<String> {SALES_ITEM}).get(0);
    	System.assertEquals(UNIT_COST, pc.Unit_Cost__c); 		
    }
    
    @isTest
    static void testDeduplicate() {
    	List<ProductCostStage__c> prodCostStages = new List<ProductCostStage__c>();
    	 
    	ProductCostStage__c clone1 = clone();
    	clone1.Unit_Cost__c = 1.2;
    	prodCostStages.add(clone1);
    	
    	ProductCostStage__c clone2 = clone();
    	clone2.Unit_Cost__c = 3.6;
    	prodCostStages.add(clone2);
    	
    	update prodCostStages;
    	
    	processData();
    	
    	ProductCostStage__c pcs = new ProductCostStagesSelector().selectById(new Set<Id> {clone1.Id}).get(0);
    	System.assertEquals(STATUS_DUPLICATED, pcs.Status__c);
    	
    	ProductCost__c pc = new ProductCostsSelector().selectBySalesItem(new Set<String> {SALES_ITEM_CLONE}).get(0);
    	System.assertEquals(3.6, pc.Unit_Cost__c);  
    }
    
    @isTest
    static void testInvalidate() {
    	ProductCostStage__c clone = clone();
    	clone.Sales_Item__c = '000123456789';
    	update clone;
    	
    	processData();
    	
    	ProductCostStage__c pcs = new ProductCostStagesSelector().selectById(new Set<Id> {clone.Id}).get(0);
    	System.assertEquals(STATUS_INVALID, pcs.Status__c);
    	
    	clone = clone();
    	clone.Sales_Item__c = '';
    	update clone;
    	
    	processData();
    	
    	pcs = new ProductCostStagesSelector().selectById(new Set<Id> {clone.Id}).get(0);
    	System.assertEquals(STATUS_INVALID, pcs.Status__c);
    	/*
    	clone = clone();
    	clone.Unit_Cost__c = 0;
    	update clone;
    	
    	processData();
    	
    	pcs = new ProductCostStagesSelector().selectById(new Set<Id> {clone.Id}).get(0);
    	System.assertEquals(STATUS_INVALID, pcs.Status__c);
    	*/
    }
    
    @isTest
    static void testSelectByStatusQueryLocator() {
    	System.assertNotEquals(null, new ProductCostStagesSelector().selectByStatusQueryLocator(new Set<String> {STATUS_QUEUED}));
    }
    
    private static void processData() {
    	User u = [select Id from User where Id = :CommonUtils.getDataAdminUserId()];
        
        System.runAs(u) {
			ProductCostStages.newInstance(new ProductCostStagesSelector().selectByStatus(new Set<String> {STATUS_QUEUED})).processData();	
        }
    }
    
    private static Id runBatch() {
    	return Database.executeBatch(new ProductCostsProcessJob());
    }
    
    private static ProductCostStage__c clone() {
    	ProductCostStage__c prodCostStageClone = prodCostStage.clone(false, true, false, false);
    	prodCostStageClone.Status__c = STATUS_QUEUED;
    	prodCostStageClone.Sales_Item__c = SALES_ITEM_CLONE;
    	    	
    	insert prodCostStageClone;
    	
    	return prodCostStageClone; 	
    } 

}