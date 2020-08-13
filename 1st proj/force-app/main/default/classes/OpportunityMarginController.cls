public with sharing class OpportunityMarginController {

	public class OpportunityProductWrapper implements Comparable {
		@AuraEnabled public String id { get; set; }
		@AuraEnabled public String prodName { get; set; }
        @AuraEnabled public String salesItem { get; set; }
		@AuraEnabled public String bu { get; set; }
        @AuraEnabled public String buDesc { get; set; }
		@AuraEnabled public String bl { get; set; }
        @AuraEnabled public String blDesc { get; set; }
        @AuraEnabled public String mag { get; set; }
        @AuraEnabled public String magDesc { get; set; }
		@AuraEnabled public String type { get; set; }
		
        public Integer compareTo(Object compareTo) {
			return type.compareTo(((OpportunityProductWrapper)compareTo).type);
		}
	}
	
	public class OpportunityProductScheduleWrapper {
		@AuraEnabled public String id { get; set; }
		@AuraEnabled public String schedYear { get; set; }
        @AuraEnabled public String schedYearQtr { get; set; }
        @AuraEnabled public Decimal prodQty { get; set; }
		@AuraEnabled public Decimal prodSchedPrice { get; set; }
		@AuraEnabled public Decimal prodValue { get; set; }
		@AuraEnabled public Decimal unitCost { get; set; }
		@AuraEnabled public Decimal prodCost { get; set; }
		@AuraEnabled public Decimal prodMargin { get; set; }
		@AuraEnabled public Decimal prodMarginPct { get; set; }
        @AuraEnabled public String type { get; set; }
	}
    
    @AuraEnabled
    public static List<OpportunityProductWrapper> getOpportunityProducts(Id opptyId) {
    	p('getOpportunityProducts');
    	List<OpportunityProductWrapper> result = new List<OpportunityProductWrapper>();
    	
    	List<OpportunityLineItem> opptyProds = new OpportunityLineItemsSelector().selectByOpptyIdWithProduct(new Set<Id> {opptyId}, OpportunityLineItems.LOST_CANCELLED);
    	
    	List<ProductCost__c> prodCosts = new ProductCostsSelector().selectByProdId(new Set<Id>(Collection.of(opptyProds).pluckIds(OpportunityLineItem.Product2Id))).values();
    	Set<Id> prodIdsWithCost = new Set<Id>(Collection.of(prodCosts).pluckIds(ProductCost__c.Product__c)); 
    	
    	for (OpportunityLineItem oli : opptyProds) {
    		OpportunityProductWrapper opw = new OpportunityProductWrapper();
			opw.id = oli.Id;
			opw.prodName = oli.Product_Name__c;
            opw.salesItem = oli.Product2.Sales_Item__c;
			opw.bu = oli.BU__c;
            opw.buDesc = oli.Product2.BU_Description__c;
			opw.bl = oli.BL__c;
            opw.blDesc = oli.Product2.BL_Description__c;
            opw.mag = oli.MAG__c;
            opw.magDesc = oli.Product2.MAG_Description__c;
			opw.type = prodIdsWithCost.contains(oli.Product2Id) ? 'With Cost' : 'Without Cost'; 
			result.add(opw);		
		}
        
        if (result.size() > 0) {
        	result.sort();
        }
        
    	return result;		
    }
    
    @AuraEnabled
    public static Map<String, Map<String, List<OpportunityProductScheduleWrapper>>> getOpportunityProductSchedulesWithMargin(Id opptyId) {
    	p('getOpportunityProductSchedulesWithMargin');
    	// (ALL, BU Code, BL Code, Oppty Prod Id) => (Year, Qtr) => List<OpportunityProductScheduleWrapper> 
    	Map<String, Map<String, List<OpportunityProductScheduleWrapper>>> result = new Map<String, Map<String, List<OpportunityProductScheduleWrapper>>>();
    	
    	List<OpportunityProductSchedule__c> opptyProdScheds = new OpportunityProductSchedulesSelector().selectByOpptyIdWithProduct(new Set<Id> {opptyId});
    	
    	Map<Id, ProductCost__c> prodCostsByProdId = new ProductCostsSelector().selectByProdId(new Set<Id>(Collection.of(opptyProdScheds).pluckIds(OpportunityProductSchedule__c.Product__c)));
    	
    	Map<String, List<OpportunityProductScheduleWrapper>> schedsByGroup = new Map<String, List<OpportunityProductScheduleWrapper>>();
        List<OpportunityProductScheduleWrapper> buScheds;
        List<OpportunityProductScheduleWrapper> blScheds;
        List<OpportunityProductScheduleWrapper> magScheds;
        List<OpportunityProductScheduleWrapper> prodScheds;
        List<OpportunityProductScheduleWrapper> allScheds = new List<OpportunityProductScheduleWrapper>();
    	
    	for (OpportunityProductSchedule__c ops : opptyProdScheds) {
            String buKey = ops.Product__r.BU__c + ' - ' + ops.Product__r.BU_Description__c;
            
    		if (schedsByGroup.get(buKey) == null) {
    			schedsByGroup.put(buKey, new List<OpportunityProductScheduleWrapper>());
                buScheds = schedsByGroup.get(buKey);
            } else {
                buScheds = schedsByGroup.get(buKey);
            }
    		
            String blKey = ops.Product__r.BL__c + ' - ' + ops.Product__r.BL_Description__c;
            
    		if (schedsByGroup.get(blKey) == null) {
    			schedsByGroup.put(blKey, new List<OpportunityProductScheduleWrapper>());
                blScheds = schedsByGroup.get(blKey);
            } else {
                blScheds = schedsByGroup.get(blKey);
            }
            
            String magKey = ops.Product__r.MAG__c + ' - ' + ops.Product__r.MAG_Description__c;
            
            if (schedsByGroup.get(magKey) == null) {
    			schedsByGroup.put(magKey, new List<OpportunityProductScheduleWrapper>());
                magScheds = schedsByGroup.get(magKey);
            } else {
                magScheds = schedsByGroup.get(magKey);
            }
            
            if (schedsByGroup.get(ops.Oppty_Prod_ID_Full__c) == null) {
    			schedsByGroup.put(ops.Oppty_Prod_ID_Full__c, new List<OpportunityProductScheduleWrapper>());
                prodScheds = schedsByGroup.get(ops.Oppty_Prod_ID_Full__c);
            } else {
                prodScheds = schedsByGroup.get(ops.Oppty_Prod_ID_Full__c);
            }
    		
			OpportunityProductScheduleWrapper opsw = new OpportunityProductScheduleWrapper();
			opsw.id = ops.Id;
            opsw.schedYear = ops.Sched_Year__c;
			opsw.schedYearQtr = ops.Sched_Year_Qtr__c;
			opsw.prodQty = ops.Prod_Qty__c;
			opsw.prodSchedPrice = ops.Prod_Sched_Price_USD__c;
			opsw.prodValue = ops.Forecast_Value_USD__c;
			
			ProductCost__c prodCost = prodCostsByProdId.get(ops.Product__c);
			
			if (prodCost != null) {
				opsw.unitCost = prodCost.Unit_Cost__c;
				opsw.prodCost = opsw.prodQty * opsw.unitCost;
				opsw.prodMargin = opsw.prodQty * (opsw.prodSchedPrice - opsw.unitCost);
				opsw.prodMarginPct = (opsw.prodValue != 0) ? (opsw.prodMargin / opsw.prodValue) : null;
                opsw.type = 'With Cost';
            } else {
                opsw.type = 'Without Cost';
            }
            
            buScheds.add(opsw);
            blScheds.add(opsw);
            magScheds.add(opsw);
            prodScheds.add(opsw);
            allScheds.add(opsw);
		}
        
        for (String key : schedsByGroup.keySet()) {
            result.put(key, group(schedsByGroup.get(key), (key.startsWith('00k')) ? true : false, mixedType(schedsByGroup.get(key))));  
        }
		
		result.put('ALL', group(allScheds, false, mixedType(allScheds)));
        
		return result;	
    }
    
    private static Boolean mixedType(List<OpportunityProductScheduleWrapper> scheds) {
        p('mixedType');
        return (groupBy(scheds, 'type').size() > 1);
    }
    
    private static Map<String, List<OpportunityProductScheduleWrapper>> group(List<OpportunityProductScheduleWrapper> scheds, Boolean isProd, Boolean mixedType) {
    	p('group');
        Map<String, List<OpportunityProductScheduleWrapper>> result = new Map<String, List<OpportunityProductScheduleWrapper>>();
        
        result.put('Year', aggregate(scheds, 'schedYear', isProd, mixedType));
        result.put('Qtr', aggregate(scheds, 'schedYearQtr', isProd, mixedType));
        
        return result;
    }
    
    private static List<OpportunityProductScheduleWrapper> aggregate(List<OpportunityProductScheduleWrapper> scheds, String fieldName, Boolean isProd, Boolean mixedType) {
        p('aggregate');
        List<OpportunityProductScheduleWrapper> result = new List<OpportunityProductScheduleWrapper>();
        
        Map<String, List<OpportunityProductScheduleWrapper>> groupings = groupBy(scheds, fieldName);
        
        for (String key : groupings.keySet()) {
            List<OpportunityProductScheduleWrapper> value = groupings.get(key);
        	OpportunityProductScheduleWrapper opsw = new OpportunityProductScheduleWrapper();
            opsw.schedYearQtr = key;
            
            if (isProd && (fieldName == 'schedYearQtr')) {
                opsw.prodSchedPrice = value.get(0).prodSchedPrice;
            	opsw.unitCost = value.get(0).unitCost;
			}
            
            opsw.prodQty = mapToDecimal(value, 'prodQty', mixedType).sum();
			opsw.prodValue = mapToDecimal(value, 'prodValue', mixedType).sum();
            opsw.prodCost = mapToDecimal(value, 'prodCost', mixedType).sum();
			opsw.prodMargin = mapToDecimal(value, 'prodMargin', mixedType).sum();
			if (opsw.prodMargin != null) opsw.prodMarginPct = (opsw.prodValue != 0) ? (opsw.prodMargin / opsw.prodValue) : null;
            result.add(opsw);
        }
        
        if (result.size() > 0) {
            OpportunityProductScheduleWrapper opsw = new OpportunityProductScheduleWrapper();
            opsw.schedYearQtr = 'Total';
            opsw.prodQty = mapToDecimal(scheds, 'prodQty', mixedType).sum();
            opsw.prodValue = mapToDecimal(scheds, 'prodValue', mixedType).sum();
            opsw.prodCost = mapToDecimal(scheds, 'prodCost', mixedType).sum();
            opsw.prodMargin = mapToDecimal(scheds, 'prodMargin', mixedType).sum();
            if (opsw.prodMargin != null) opsw.prodMarginPct = (opsw.prodValue != 0) ? (opsw.prodMargin / opsw.prodValue) : null;
            result.add(opsw);    
        }
        
    	return result;
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
    
    private static DecimalCollection mapToDecimal(List<OpportunityProductScheduleWrapper> scheds, String fieldName, Boolean mixedType) {
        p('mapToDecimal');
        List<Decimal> decimals = new List<Decimal>();
        
        for (OpportunityProductScheduleWrapper opsw : scheds) {
            decimals.add((mixedType && opsw.unitCost == null) ? null : (Decimal)CommonUtils.getFieldValue(opsw, fieldName));
        }
        
        return new DecimalCollection(decimals);
    }
    
    private static void p(String msg) {
		CommonUtils.p(OpportunityMarginController.class, '//-c', msg);
	}

}