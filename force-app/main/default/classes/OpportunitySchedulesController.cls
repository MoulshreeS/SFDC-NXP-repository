public with sharing class OpportunitySchedulesController {
	
	public class OpportunityWrapper {
		@AuraEnabled public String id { get; set; }
		@AuraEnabled public String opptyName { get; set; }
		@AuraEnabled public String opptyUrl { get; set; }
		@AuraEnabled public String acctName { get; set; }
		@AuraEnabled public String acctUrl { get; set; }
		@AuraEnabled public String stage { get; set; }
		@AuraEnabled public Datetime createdDate { get; set; }
		@AuraEnabled public Date closeDate { get; set; }
		@AuraEnabled public Date prodDate { get; set; }
		@AuraEnabled public Double ltValue { get; set; }
		@AuraEnabled public String blConcat { get; set; }	
	} 
	
	public class OpportunityScheduleWrapper {
		@AuraEnabled public String id { get; set; }
		@AuraEnabled public Date schedDate { get; set; }
		@AuraEnabled public String schedYearQtr { get; set; }
        @AuraEnabled public Decimal schedQty { get; set; }
        @AuraEnabled public Decimal frozenSchedQty { get; set; }
		@AuraEnabled public String comment { get; set; }
		@AuraEnabled public Boolean newRecord { get; set; }
	}
	
	public class OpportunityProductScheduleWrapper {
		@AuraEnabled public String id { get; set; }
		@AuraEnabled public String prodId { get; set; }
		@AuraEnabled public Date schedDate { get; set; }
		@AuraEnabled public String schedYearQtr { get; set; }
        @AuraEnabled public Decimal prodSchedPrice { get; set; }
        @AuraEnabled public Decimal frozenProdSchedPrice { get; set; }
		@AuraEnabled public Decimal share { get; set; }
		@AuraEnabled public Decimal qtyPerSys { get; set; }
		@AuraEnabled public Decimal opptySchedQty { get; set; }
        @AuraEnabled public Decimal prodValue { get; set; }
	}
	
	public class OpportunityProductWrapper {
		@AuraEnabled public String id { get; set; }
		@AuraEnabled public String prodName { get; set; }
		@AuraEnabled public Decimal claimValue { get; set; }
		@AuraEnabled public Decimal ltValue { get; set; }
	}
	
	@AuraEnabled
    public static List<OpportunityWrapper> getOpportunities(Id progId) {
    	p('getOpportunities');
    	List<OpportunityWrapper> result = new List<OpportunityWrapper>();
    	
    	List<Opportunity> oppties = new OpportunitiesSelector().selectByProgramIdAndOwnerIdWithAccountAndOwnerAndProducts(new Set<Id> {progId}, new Set<Id> {UserInfo.getUserId()});
    	
    	for (Opportunity o : oppties) {
    		OpportunityWrapper ow = new OpportunityWrapper();
    		ow.id = o.Id;
    		ow.opptyName = o.Name;
    		ow.opptyUrl = '/' + o.Id;
    		ow.acctName = o.Account.Name;
    		ow.acctUrl = '/' + o.Account.Id;
    		ow.stage = o.StageName;
    		ow.createdDate = o.CreatedDate;
    		ow.closeDate = o.CloseDate;
    		ow.prodDate = o.Production_Date__c;
    		ow.ltValue = o.LT_Value_USD__c;
    		ow.blConcat = o.BL__c;
    		result.add(ow);	
    	}
    	
    	return result;	
    }
	
	@AuraEnabled
    public static List<OpportunityScheduleWrapper> getOpportunitySchedules(Id opptyId) {
    	p('getOpportunitySchedules');
    	List<OpportunityScheduleWrapper> result = new List<OpportunityScheduleWrapper>();
    	List<OpportunitySchedule__c> opptyScheds;
    	
    	try {
    		opptyScheds = new OpportunitySchedulesSelector().selectByOpptyId(new Set<Id> {opptyId});	
    	} catch (Exception e) {
    		throw new AuraHandledException('Error while retrieving opportunity schedules. ' + e.getMessage());		
    	}
    	
    	for (OpportunitySchedule__c os : opptyScheds) {
    		OpportunityScheduleWrapper osw = new OpportunityScheduleWrapper();
    		osw.id = os.Id;
    		osw.schedDate = os.Sched_Date__c;
    		osw.schedYearQtr = os.Sched_Year_Qtr__c;
    		osw.schedQty = os.Oppty_Sched_Qty__c;
    		osw.frozenSchedQty = os.Frozen_Oppty_Sched_Qty__c;
    		osw.comment = os.Comment__c;
    		result.add(osw);
    	}
    	
    	return result;	
    }
    
    @AuraEnabled
    public static void updateOpportunitySchedules(Opportunity opptyRecord, Boolean isFullEdit, Boolean isTmmaOverride, List<OpportunityScheduleWrapper> scheds, Boolean isMassUpdate) {
    	p('updateOpportunitySchedules');
    	List<OpportunitySchedule__c> opptyScheds = new OpportunitySchedulesSelector().selectByOpptyId(new Set<Id> {opptyRecord.Id});
    	List<OpportunitySchedule__c> opptySchedsUpdated = new List<OpportunitySchedule__c>();
    	List<OpportunitySchedule__c> opptySchedsDeleted = new List<OpportunitySchedule__c>();
    	List<OpportunitySchedule__c> opptySchedsUpserted = new List<OpportunitySchedule__c>();
    	
    	for (OpportunityScheduleWrapper osw : scheds) {
    		OpportunitySchedule__c os = new OpportunitySchedule__c();
    		os.Opportunity__c = opptyRecord.Id;
    		if (osw.schedDate != null) os.Sched_Date__c = osw.schedDate;
    		if (osw.schedQty != null) os.Oppty_Sched_Qty__c = osw.schedQty;
    		if (osw.frozenSchedQty != null) os.Frozen_Oppty_Sched_Qty__c = osw.frozenSchedQty;
    		if (osw.comment != null) os.Comment__c = osw.comment;
    		
    		if (osw.id instanceof Id) {
    			os.Id = osw.id;
    			opptySchedsUpdated.add(os);
    		}
    		
    		opptySchedsUpserted.add(os);
    	}
    	
    	opptySchedsDeleted = Collection.of(opptyScheds).difference(Collection.of(opptySchedsUpdated), new Set<Schema.SObjectField>{OpportunitySchedule__c.Id}).asList();
    	
    	try {
            Opportunity oppty;
            
            if (isFullEdit) {
                oppty = new Opportunity(
                    Id = opptyRecord.Id, 
                    CloseDate = opptyRecord.CloseDate, 
                    Production_Date__c = opptyRecord.Production_Date__c,
                    TMMA_Override__c = isTmmaOverride,
                    Bypass_Validation_Sched_Start_Date__c = true
                );	
            } else if (isTmmaOverride) {
            	oppty = new Opportunity(
                    Id = opptyRecord.Id, 
                    TMMA_Override__c = true
                );    
            } 
            
    		if (oppty != null) {
    			update oppty;	
    		}
    	
	    	upsert opptySchedsUpserted;
	    	delete opptySchedsDeleted;
	    	
	    	OpportunityService.updateOpportunityProductSchedules(new Set<Id> {opptyRecord.Id});
	    	
	    	if (oppty != null && isFullEdit) {
	    		oppty.Bypass_Validation_Sched_Start_Date__c = false;
	    		update oppty;	
	    	}
	    } catch (Exception e) {
    		throw new AuraHandledException('Error while saving opportunity schedules. ' + e.getMessage());	
    	}
    	
    	if (isMassUpdate) massUpdateOpportunitySchedules(opptyRecord); 
    }
    
    @AuraEnabled
    public static List<OpportunityProductWrapper> getOpportunityProducts(Id opptyId) {
    	p('getOpportunityProducts');
    	List<OpportunityProductWrapper> result = new List<OpportunityProductWrapper>();
    	List<OpportunityLineItem> opptyProds;
    	
    	try {
    		opptyProds = new OpportunityLineItemsSelector().selectByOpptyIdWithProduct(new Set<Id> {opptyId}, OpportunityLineItems.LOST_CANCELLED);	
    	} catch (Exception e) {
    		throw new AuraHandledException('Error while retrieving opportunity products. ' + e.getMessage());		
    	}
    	
    	for (OpportunityLineItem oli : opptyProds) {
			OpportunityProductWrapper opw = new OpportunityProductWrapper();
			opw.id = oli.Id;
			opw.prodName = oli.Product_Name__c;
			opw.claimValue = oli.Claim_Value_USD__c;
			opw.ltValue = oli.LT_Value_USD__c;
			result.add(opw);		
		}
    	
    	return result;	
    }
    
    @AuraEnabled
    public static List<OpportunityProductScheduleWrapper> getOpportunityProductSchedules(Id opptyId, List<Id> opptyProdIds) {
    	p('getOpportunityProductSchedules');
    	List<OpportunityProductScheduleWrapper> result = new List<OpportunityProductScheduleWrapper>();
    	List<OpportunityProductSchedule__c> opptyProdScheds;
    	
    	try {
    		opptyProdScheds = new OpportunityProductSchedulesSelector().selectByOpptyIdAndOpptyProdId(new Set<Id> {opptyId}, new Set<Id>(opptyProdIds));	
    	} catch (Exception e) {
    		throw new AuraHandledException('Error while retrieving opportunity product schedules. ' + e.getMessage());		
    	}
        
        for (OpportunityProductSchedule__c ops : opptyProdScheds) {
    		OpportunityProductScheduleWrapper opsw = new OpportunityProductScheduleWrapper();
    		opsw.id = ops.Id;
    		opsw.prodId = ops.Oppty_Prod_ID_Full__c;
    		opsw.schedDate = ops.Sched_Date__c;
    		opsw.schedYearQtr = ops.Sched_Year_Qtr__c;
    		opsw.prodSchedPrice = ops.Prod_Sched_Price__c;
    		opsw.frozenProdSchedPrice = ops.Frozen_Prod_Sched_Price__c;
    		opsw.share = ops.Share__c / 100;
    		opsw.qtyPerSys = ops.Qty_Per_Sys__c;
    		opsw.opptySchedQty = ops.Oppty_Sched_Qty__c;
            opsw.prodValue = ops.Forecast_Value_USD__c;
    		result.add(opsw);
    	}
        
        OpportunityProductScheduleWrapper opsw = new OpportunityProductScheduleWrapper();
        opsw.id = 'total';
        opsw.prodValue = result.size() != 0 ? mapToDecimal(result, 'prodValue').sum() : 0;
        result.add(opsw);
        
        Map<String, List<OpportunityProductScheduleWrapper>> groupings = groupBy(result, 'prodId');
        
        for (String prodId : groupings.keySet()) {
        	if (prodId == null) continue;
        	
            List<OpportunityProductScheduleWrapper> prodScheds = groupings.get(prodId);
            opsw = new OpportunityProductScheduleWrapper();
            opsw.id = 'subtotal-' + prodId;
            opsw.prodId = prodId;
            opsw.prodValue = prodScheds.size() != 0 ? mapToDecimal(prodScheds, 'prodValue').sum() : 0;
            result.add(opsw);
        }
        
        return result;	
    }
    
    @AuraEnabled
    public static void updateOpportunityProductSchedules(Id opptyId, Boolean isTmmaOverride, String changedValues) {
    	p('updateOpportunityProductSchedules');
    	List<OpportunityProductSchedule__c> opptyProdSchedsUpdated = new List<OpportunityProductSchedule__c>();

    	for (OpportunityProductScheduleWrapper opsw : (List<OpportunityProductScheduleWrapper>)JSON.deserialize(changedValues, List<OpportunityProductScheduleWrapper>.class)) {
    		OpportunityProductSchedule__c ops = new OpportunityProductSchedule__c();
    		ops.Id = opsw.id;
    		if (opsw.prodSchedPrice != null) ops.Prod_Sched_Price__c = opsw.prodSchedPrice;
    		if (opsw.share != null) ops.Share__c = opsw.share * 100;
    		opptyProdSchedsUpdated.add(ops);  	
    	}
    	
    	try {
            if (isTmmaOverride) {
                Opportunity oppty = new Opportunity(
                    Id = opptyId, 
                    TMMA_Override__c = true
                );
                
                update oppty;
            }
    		
    		update opptyProdSchedsUpdated;	
    	} catch (Exception e) {
    		throw new AuraHandledException('Error while saving opportunity product schedules. ' + e.getMessage());		
    	}
    }
    
    @TestVisible
    private static void massUpdateOpportunitySchedules(Opportunity opptyMaster) {
    	p('massUpdateOpportunitySchedules');
    	Map<Id, Opportunity> oppties = new Map<Id, Opportunity>(new OpportunitiesSelector().selectByProgramIdAndOwnerIdWithAccountAndOwnerAndProducts(new Set<Id> {opptyMaster.Program__c}, new Set<Id> {UserInfo.getUserId()})); 
    	Map<Id, Opportunity> opptiesUpdated = new Map<Id, Opportunity>(oppties);
    	
    	opptiesUpdated.remove(opptyMaster.Id);
    	
    	for (Opportunity o : opptiesUpdated.values()) {
    		o.CloseDate = opptyMaster.CloseDate;
    		o.Production_Date__c = opptyMaster.Production_Date__c; 
    		o.Bypass_Validation_Sched_Start_Date__c = true;  
    		
    		if (OpportunityService.isMnRecordType(o)) {
    			o.TMMA_Override__c = true;	
    		}
    	}
    	
    	Map<Id, List<OpportunitySchedule__c>> opptySchedsByOpptyId = new OpportunitySchedulesSelector().selectByOpptyIdGroupByOpptyId(oppties.keySet());
    	Map<Id, List<OpportunitySchedule__c>> opptySchedsByOpptyIdUpdated = new Map<Id, List<OpportunitySchedule__c>>(opptySchedsByOpptyId);
    	
    	List<OpportunitySchedule__c> opptyMasterScheds = opptySchedsByOpptyId.get(opptyMaster.Id);
    	
    	opptySchedsByOpptyIdUpdated.remove(opptyMaster.Id); 
    	
    	List<OpportunitySchedule__c> opptySchedsDeleted = new List<OpportunitySchedule__c>();
    	List<OpportunitySchedule__c> opptySchedsCreated = new List<OpportunitySchedule__c>();
    	
    	for (Id oid : opptySchedsByOpptyIdUpdated.keySet()) {
    		opptySchedsDeleted.addAll(opptySchedsByOpptyIdUpdated.get(oid));
    		
    		for (OpportunitySchedule__c os : opptyMasterScheds) {
    			OpportunitySchedule__c opptySched = new OpportunitySchedule__c();
    			
    			opptySched.Opportunity__c = oid;
    			opptySched.Sched_Date__c = os.Sched_Date__c;
    			opptySched.Oppty_Sched_Qty__c = os.Oppty_Sched_Qty__c;
    			opptySched.Frozen_Oppty_Sched_Qty__c = os.Frozen_Oppty_Sched_Qty__c;
    			opptySched.Comment__c = os.Comment__c;
    			opptySched.CurrencyIsoCode = opptiesUpdated.get(oid).CurrencyIsoCode;
    			
    			opptySchedsCreated.add(opptySched);	
    		}
    	}
		
    	try {
    		update opptiesUpdated.values();
    		delete opptySchedsDeleted;
    		insert opptySchedsCreated;
    		
    		OpportunityService.updateOpportunityProductSchedules(oppties.keySet());
    		
    		for (Opportunity o : opptiesUpdated.values()) {
				o.Bypass_Validation_Sched_Start_Date__c = false;
			}
		
			update opptiesUpdated.values(); 
    	} catch (Exception e) {
    		throw new AuraHandledException('Error while mass updating opportunity schedules. ' + e.getMessage());	
    	} 
    }
    
    private static Map<String, List<OpportunityProductScheduleWrapper>> groupBy(List<OpportunityProductScheduleWrapper> scheds, String fieldName) {
    	p('groupBy');
        Map<String, List<OpportunityProductScheduleWrapper>> result = new Map<String, List<OpportunityProductScheduleWrapper>>();
        
        for (OpportunityProductScheduleWrapper opsw : scheds) {
            String key = (String)CommonUtils.getFieldValue(opsw, fieldName);
            
            if (!result.containsKey(key)) {
                result.put(key, new List<OpportunityProductScheduleWrapper>());
            }
            
            result.get(key).add(opsw);
        }
        
        return result;
    }
    
    private static DecimalCollection mapToDecimal(List<OpportunityProductScheduleWrapper> scheds, String fieldName) {
    	p('mapToDecimal');
        List<Decimal> decimals = new List<Decimal>();
        
        for (OpportunityProductScheduleWrapper opsw : scheds) {
            decimals.add((Decimal)CommonUtils.getFieldValue(opsw, fieldName));
        }
        
        return new DecimalCollection(decimals);
    }
    
    private static void p(String msg) {
		CommonUtils.p(OpportunitySchedulesController.class, '//-c', msg);
	}

}