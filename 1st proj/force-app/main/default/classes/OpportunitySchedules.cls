public class OpportunitySchedules extends ApplicationDomain {
	
	public OpportunitySchedules(List<OpportunitySchedule__c> opptyScheds) {
		super(opptyScheds);
	}

	public class Constructor implements fflib_SObjectDomain.IConstructable {
		public fflib_SObjectDomain construct(List<SObject> sObjectList) {
			return new OpportunitySchedules(sObjectList);
		}
	}
	
	public override void onBeforeInsert() {
		p('onBeforeInsert');
		updateOpptyScheds(null);	
	}
	
	public override void onBeforeUpdate(Map<Id, SObject> existingRecords) {
		p('onBeforeUpdate');
		updateOpptyScheds((List<OpportunitySchedule__c>)existingRecords.values());
	}
	
	public override void onAfterInsert() {
		p('onAfterInsert');	
		updateOpptyProdQty((List<OpportunitySchedule__c>)this.records);
	}
	
	public override void onAfterUpdate(Map<Id, SObject> existingRecords) {
		p('onAfterUpdate');
		updateOpptyProdQty((List<OpportunitySchedule__c>)existingRecords.values());
	}
	
	public override void onAfterDelete() {
		p('onAfterDelete');	
		updateOpptyProdQty((List<OpportunitySchedule__c>)this.records);
	}
	
	private void updateOpptyScheds(List<OpportunitySchedule__c> opptySchedsOld){
        p('updateOpptyScheds');
        if (!(Trigger.isBefore && (Trigger.isInsert || Trigger.isUpdate))) return;
        
        Set<Id> opptyIds = new Set<Id>();
        
        for (OpportunitySchedule__c opptySchedNew : (List<OpportunitySchedule__c>)this.records) {
            opptyIds.add(opptySchedNew.Opportunity__c);
        }
        
        Map<Id, Opportunity> oppties = new Map<Id, Opportunity>(new OpportunitiesSelector().selectById(opptyIds));
        
        for (OpportunitySchedule__c opptySchedNew : (List<OpportunitySchedule__c>)this.records){
        	if (Trigger.isInsert) {
                if (oppties.get(opptySchedNew.Opportunity__c).StageName != Opportunities.STAGES.get(Opportunities.Stage.COMMITMENT)) {
        			opptySchedNew.Frozen_Oppty_Sched_Qty__c = opptySchedNew.Oppty_Sched_Qty__c;
                }
                
        		opptySchedNew.CurrencyIsoCode = oppties.get(opptySchedNew.Opportunity__c).CurrencyIsoCode;	
        	}
        	
        	if (Trigger.isUpdate) {
        		for (OpportunitySchedule__c opptySchedOld : opptySchedsOld){
                	if (opptySchedOld.Id == opptySchedNew.Id) {
                		if (oppties.get(opptySchedNew.Opportunity__c).StageName != Opportunities.STAGES.get(Opportunities.Stage.COMMITMENT)) {
                        	opptySchedNew.Frozen_Oppty_Sched_Qty__c = opptySchedNew.Oppty_Sched_Qty__c;
                    	}
                	}
            	}	
        	}
        }
    }  
	
	private void updateOpptyProdQty(List<OpportunitySchedule__c> opptyScheds) {
		p('updateOpptyProdQty');
		Set<Id> opptyIds = new Set<Id>();
        
        for (OpportunitySchedule__c os : opptyScheds) {
            opptyIds.add(os.Opportunity__c);
        }
        
        for (Opportunity o : new OpportunitiesSelector().selectById(opptyIds)) {
        	if (o.StageName == Opportunities.STAGES.get(Opportunities.Stage.COMMITMENT)) {
        		opptyIds.remove(o.Id);	
        	}
        }
        
        if (opptyIds.size() == 0) return;
        
        List<OpportunitySchedulesSelector.OpportunityScheduleValueSummary> schedValues = new OpportunitySchedulesSelector().selectSchedValueByOpptyIdGroupByOpptyId(opptyIds);
             
        List<OpportunityLineItem> opptyProdsUpdated = new OpportunityLineItemsSelector().selectByOpptyIdWithOpportunity(opptyIds);   
        
        for (OpportunityLineItem oli : opptyProdsUpdated) {
            for (OpportunitySchedulesSelector.OpportunityScheduleValueSummary osvs : schedValues) {
                if (oli.OpportunityId == osvs.opptyId) {
                    oli.Quantity = osvs.totalFrozenSchedQty;
                    oli.UnitPrice = oli.UnitPrice;  // SFDC constraint. Need to update UnitPrice and Quantity at the same time. 
                    break;
                }
            }
        }          
        
        update opptyProdsUpdated;
    }
        
}