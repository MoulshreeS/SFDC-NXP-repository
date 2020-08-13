public class ProductCostStages extends ApplicationDomain {
	
	public enum Status {QUEUED, PROCESSING, COMPLETED, INVALID, DUPLICATED, FAILED, ABORTED}
		
	public static final Map<Status, String> STATUSES = new Map<Status, String> {
		Status.QUEUED => 'Queued',
		Status.PROCESSING => 'Processing',
		Status.COMPLETED => 'Completed',
		Status.INVALID => 'Invalid',
		Status.DUPLICATED => 'Duplicated',
		Status.FAILED => 'Failed',
		Status.ABORTED => 'Aborted'
	};
	
	public static final String STATUS_QUEUED = STATUSES.get(Status.QUEUED);
	public static final String STATUS_PROCESSING = STATUSES.get(Status.PROCESSING);
	public static final String STATUS_COMPLETED = STATUSES.get(Status.COMPLETED);
	public static final String STATUS_INVALID = STATUSES.get(Status.INVALID);
	public static final String STATUS_DUPLICATED = STATUSES.get(Status.DUPLICATED);
	public static final String STATUS_FAILED = STATUSES.get(Status.FAILED);
	public static final String STATUS_ABORTED = STATUSES.get(Status.ABORTED);
	
	private List<ProductCostStage__c> prodCostStages;
	
	private ProductCostStages() {}   
	
	private ProductCostStages(List<ProductCostStage__c> prodCostStages) {
		super(prodCostStages);	
	}

	public class Constructor implements fflib_SObjectDomain.IConstructable {
		public fflib_SObjectDomain construct(List<SObject> sObjectList) {
			return new ProductCostStages(sObjectList);
		}
	}
	
	public static ProductCostStages newInstance(List<ProductCostStage__c> prodCostStages) {
		ProductCostStages newInstance = new ProductCostStages();
		newInstance.prodCostStages = prodCostStages;
		newInstance.deduplicate();
		newInstance.invalidate();
		
		return newInstance; 	
	}
	
	public override void onBeforeInsert() {
		p('onBeforeInsert');
		for (ProductCostStage__c pcs : (List<ProductCostStage__c>)this.records) {
			pcs.Status__c = STATUS_QUEUED;
		}
	}
	
	public void processData() {
		p('processData');
		if (this.prodCostStages.size() == 0) return;
		
		Map<String, List<Product2>> prodsBySalesItem = getProdsBySalesItem();
		
		List<ProductCost__c> prodCosts = new List<ProductCost__c>();
		
		for (ProductCostStage__c pcs : this.prodCostStages) {
			pcs.Message__c = '';
			pcs.Product_Cost__c = null;
			
			ProductCost__c prodCost = new ProductCost__c();
			prodCost.Biz_Id__c = pcs.Sales_Item__c; // External Id
			
			if (prodsBySalesItem.containsKey(pcs.Sales_Item__c)) {
				prodCost.Product__c = prodsBySalesItem.get(pcs.Sales_Item__c).get(0).Id;
			} else {
				pcs.Status__c = STATUS_INVALID;
				pcs.Message__c = 'Sales Item is not found.';
			}
			
			prodCost.Unit_Cost__c = pcs.Unit_Cost__c; 
			
			prodCosts.add(prodCost);	
		}
		
		update this.prodCostStages;  
		
		List<Database.UpsertResult> prodCostsUpsertResults = Database.upsert(prodCosts, ProductCost__c.Fields.Biz_Id__c, false);
		
		Set<Id> prodCostIdsDeleted = new Set<Id>();
		
		for (Integer i = 0; i < this.prodCostStages.size(); i++) {
			ProductCostStage__c prodCostStage = this.prodCostStages.get(i);
			Database.UpsertResult prodCostUpsertResult = prodCostsUpsertResults.get(i); 
			
			if (prodCostUpsertResult.isSuccess()) {
				if (prodCostStage.Status__c == STATUS_INVALID) {
					prodCostIdsDeleted.add(prodCostUpsertResult.getId());
				} else {
					prodCostStage.Status__c = STATUS_COMPLETED;
					prodCostStage.Product_Cost__c = prodCostUpsertResult.getId(); 	
				}  	
			} else {
				prodCostStage.Status__c = STATUS_FAILED;
				prodCostStage.Message__c = 'Failed to upsert Sales Item. ' + processErrors(prodCostUpsertResult.getErrors());
			}
		}
		
		if (prodCostIdsDeleted.size() > 0) {
			Database.delete(new List<Id>(prodCostIdsDeleted), false);
		}
		
		update this.prodCostStages;
	}
	
	private Map<String, List<Product2>> getProdsBySalesItem() {
		p('getProdsBySalesItem');
		List<String> salesItems = Collection.of(this.prodCostStages).pluckStrings(ProductCostStage__c.Sales_Item__c);
		List<Product2> prods = new ProductsSelector().selectBySalesItem(new Set<String>(salesItems));
		return Collection.of(prods).groupByStrings(Product2.Sales_Item__c, List<Product2>.class); 
	}
	
	private String processErrors(List<Database.Error> errors) {
		p('processErrors');
		String result = '';
		
		for (Database.Error err : errors) {
			result += err.getStatusCode() + ': ' + err.getMessage() + '. Fields that affected this error: ' + err.getFields() + '. ';
		}	
		
		return result;
	}
	
	private void deduplicate() {
		p('deduplicate');
		Map<String, ProductCostStage__c> prodCostStagesDeduped = new Map<String, ProductCostStage__c>();
		
		for (ProductCostStage__c pcs : this.prodCostStages) {
			prodCostStagesDeduped.put(pcs.Sales_Item__c, pcs);
		}
		
		for (ProductCostStage__c pcs : this.prodCostStages) {
			String extId = pcs.Sales_Item__c;
			
			if (prodCostStagesDeduped.containsKey(extId) && prodCostStagesDeduped.get(extId) !== pcs) {
				pcs.Status__c = STATUS_DUPLICATED;
				pcs.Message__c = 'Duplicated with record Id: ' + prodCostStagesDeduped.get(extId).Id;
				pcs.Product_Cost__c = null;	 
			}
				
		}
		
		update this.prodCostStages;
		
		this.prodCostStages = prodCostStagesDeduped.values();
	}
	
	private void invalidate() {
		p('invalidate');
		Map<Id, ProductCostStage__c> prodCostStagesById = new Map<Id, ProductCostStage__c>(this.prodCostStages); 
		
		for (ProductCostStage__c pcs : this.prodCostStages) {
			pcs.Message__c = '';
			
			String message = checkProdCostStageInvalid(pcs);
			
			if (message != '') {
				pcs.Status__c = STATUS_INVALID;
				pcs.Message__c = message;
				pcs.Product_Cost__c = null;
				prodCostStagesById.remove(pcs.Id);	
			}
		}
		
		update this.prodCostStages;
		
		this.prodCostStages = prodCostStagesById.values();	
	}
	
	private String checkProdCostStageInvalid(ProductCostStage__c prodCostStage) {
		p('checkProdCostStageInvalid');
		String result = prodCostStage.Message__c;
		
		if (prodCostStage.Sales_Item__c == null) {
			result += 'Sales_Item__c is blank. ';	
		}
		/*
		if (prodCostStage.Unit_Cost__c == null || prodCostStage.Unit_Cost__c == 0) {
			result += 'Unit_Cost__c is blank or 0. ';
		}
		*/
		return result;
	} 

}