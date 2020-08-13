public class OpportunityLineItems extends ApplicationDomain {
    
    public static final Set<String> LOST_CANCELLED = new Set<String> {'Lost', 'Cancelled'};
    //SFDC-3178
    public static final Set<String> NON_OPEN_OPPTY_STAGE = new Set<String> {'Lost', 'Cancelled', 'COMMITMENT'};
    
    private static final Integer PRICE_EROSION_QUARTERS = 4;
    private static final String PROBABILITY_TO_WIN_80_100 = '80% - 100%';
        
    private static Set<Id> opptyProdSchedIds;
    
    public OpportunityLineItems(List<OpportunityLineItem> opptyProds) {
        super(opptyProds);
    }

    public class Constructor implements fflib_SObjectDomain.IConstructable {
        public fflib_SObjectDomain construct(List<SObject> sObjectList) {
            return new OpportunityLineItems(sObjectList);
        }
    }
    
    public override void onBeforeInsert() {
        p('onBeforeInsert');
        checkOpptyScheds();
        
        updateLastBusinessModifiedInfo();
        
        updateQty();
        
        updateNpi();
        
        updateLostCancelledInfo();
        
        OpportunityProductClaimValue.setOpportunityProductClaimValues((List<OpportunityLineItem>)this.records);
        
        updateProgram();
    }
    
    public override void onBeforeUpdate(Map<Id, SObject> existingRecords) {
        p('onBeforeUpdate');
        // Must be the first method call to skip any field updates by the following method calls.
        bypassValidation(existingRecords);
        
        resetTmmaOverriddenFields((Map<Id, OpportunityLineItem>)existingRecords, new Map<Id, OpportunityLineItem>((List<OpportunityLineItem>)this.records));
        
        OpportunityProductClaimValue.setOpportunityProductClaimValues((List<OpportunityLineItem>)this.records); 
        
        updateLastBusinessModifiedInfo();
        
        updateNpi();

        updateLostCancelledInfo((List<OpportunityLineItem>)existingRecords.values());
        
        updateHelpNeededHistory((List<OpportunityLineItem>)existingRecords.values());
    }
    
    public override void onAfterInsert() {
        p('onAfterInsert'); 
        createOpptyProdScheds();
    }
    
    public override void onAfterUpdate(Map<Id, SObject> existingRecords) {
        p('onAfterUpdate');
        updateTmmaOverride((Map<Id, OpportunityLineItem>)existingRecords, new Map<Id, OpportunityLineItem>((List<OpportunityLineItem>)this.records));
        
        createReOpenOpptyProdScheds((List<OpportunityLineItem>)existingRecords.values());
        
        //updateOpptyProdScheds((List<OpportunityLineItem>)existingRecords.values());
        updateOpptyProdScheds((Map<Id, OpportunityLineItem>)existingRecords, new Map<Id, OpportunityLineItem>((List<OpportunityLineItem>)this.records));
        
        deleteLostCancelledOpptyProdScheds((List<OpportunityLineItem>)existingRecords.values());
    }
    
    public override void onAfterDelete() {
        p('onAfterDelete');
        deleteOpptyProdScheds();
    }
    
    /**
     * @param schedDateIndex: 0-based list index of the schedule date
     */
    public static Decimal calcOpportunityProductSchedulePrice(Decimal unitPrice, Decimal priceErosionRate, Integer schedDateIndex) {
        // Apply price erosion rate every PRICE_EROSION_QUARTERS quarters. Use previous quarter price as base price.
        return (unitPrice * Math.pow(Double.valueOf(1 - (priceErosionRate / 100)), schedDateIndex / PRICE_EROSION_QUARTERS)).setScale(6);
    }
     
    public void updateOpptyProdPrograms() {
        p('updateOpptyProdPrograms');
        for (OpportunityLineItem opptyProd : (List<OpportunityLineItem>)this.records) {
            opptyProd.Program__c = opptyProd.Opportunity.Program__c;
        }
        
        update this.records;
    }
    
    //SFDC-1154
    public void updateOpptyProdProbabilityToWin(fflib_ISObjectUnitOfWork uow) {
        p('updateProbabilityToWin');
        List<OpportunityLineItem> opptyProdsUpdated = new List<OpportunityLineItem>();
        
        for (OpportunityLineItem opptyProd : (List<OpportunityLineItem>)this.records) {
            if (!(LOST_CANCELLED.contains(opptyProd.Prod_Lost_Cancelled__c))) {
                opptyProdsUpdated.add(new OpportunityLineItem(Id = opptyProd.Id, Probability_to_Win__c = PROBABILITY_TO_WIN_80_100));
            }
        }
        
        uow.registerDirty(opptyProdsUpdated);
    }

    private void updateProgram() {
        p('updateProgram');
        Set<Id> opptyIds = new Set<Id>();
        
        for (OpportunityLineItem opptyProd : (List<OpportunityLineItem>)this.records) {
            opptyIds.add(opptyProd.OpportunityId);
        }
        
        Map<Id, Opportunity> oppties = new Map<Id, Opportunity>(new OpportunitiesSelector().selectById(opptyIds));
        
        for (OpportunityLineItem opptyProd : (List<OpportunityLineItem>)this.records) {
            opptyProd.Program__c = oppties.get(opptyProd.OpportunityId).Program__c; 
        }   
    }
    
    private void deleteOpptyProdScheds(){
        p('deleteOpptyProdScheds');
        Set<Id> opptyProdIds = new Set<Id>();
        List<OpportunityProductSchedule__c> opptyProdSchedsDeleted;
        
        for (OpportunityLineItem opptyProd : (List<OpportunityLineItem>)this.records) {
            opptyProdIds.add(opptyProd.Id);
        }
        
        // Opporunity Product Id -> (Opportunity Product Schedule Id -> Opportunity Product Schedule)
        Map<Id, Map<Id, OpportunityProductSchedule__c>> opptyProdSchedsByOpptyProdId = getOpptyProdSchedsByOpptyProdId((List<OpportunityLineItem>)this.records, opptyProdIds);
        
        opptyProdSchedsDeleted = new List<OpportunityProductSchedule__c>();
        
        for (OpportunityLineItem opptyProd : (List<OpportunityLineItem>)this.records) {
            for (Id opptyProdSchedId : opptyProdSchedIds) {
                if (opptyProdSchedsByOpptyProdId.containsKey(opptyProd.Id) && opptyProdSchedsByOpptyProdId.get(opptyProd.Id).containsKey(opptyProdSchedId)) {
                    opptyProdSchedsDeleted.add(opptyProdSchedsByOpptyProdId.get(opptyProd.Id).get(opptyProdSchedId));

                }
            }
        }
        
        delete opptyProdSchedsDeleted;
    }
    
    private Map<Id, Map<Id, OpportunityProductSchedule__c>> getOpptyProdSchedsByOpptyProdId(List<OpportunityLineItem> opptyProds, Set<Id> opptyProdIds){
        p('getOpptyProdSchedsByOpptyProdId');
        // Opporunity Product Id -> (Opportunity Product Schedule Id -> Opportunity Product Schedule)
        Map<Id, Map<Id, OpportunityProductSchedule__c>> result = new Map<Id, Map<Id, OpportunityProductSchedule__c>>();
        
        opptyProdSchedIds = new Set<Id>();
        
        Set<Id> opptyIds = getOpptyIds(opptyProds);

        for (OpportunityProductSchedule__c opptyProdSched : new OpportunityProductSchedulesSelector().selectByOpptyIdAndOpptyProdId(opptyIds, opptyProdIds)) {
            opptyProdSchedIds.add(opptyProdSched.Id);                                                     
                                                                 
            if (result.containsKey(opptyProdSched.Oppty_Prod_ID_Full__c)) {
                result.get(opptyProdSched.Oppty_Prod_ID_Full__c).put(opptyProdSched.Id, opptyProdSched);
            }
            else {
                result.put(opptyProdSched.Oppty_Prod_ID_Full__c, new Map<Id, OpportunityProductSchedule__c> {opptyProdSched.Id => opptyProdSched});
            }
        }
        
        return result;
    }
    
    private void createOpptyProdScheds() {
        p('createOpptyProdScheds');
        Set<Id> opptyIds = getOpptyIds((List<OpportunityLineItem>)this.records);
                     
        Id opptyId = null;
        List<OpportunitySchedule__c> opptyScheds = null;
        Map<Id, List<OpportunitySchedule__c>> opptySchedsMap = new Map<Id, List<OpportunitySchedule__c>>();
        
        for (OpportunitySchedule__c os : new OpportunitySchedulesSelector().selectByOpptyId(opptyIds)) {
            if (opptyId != os.Opportunity__c) {
                opptyId = os.Opportunity__c;
                opptyScheds = new List<OpportunitySchedule__c>();     
            }                                   
            
            opptyScheds.add(os);
            opptySchedsMap.put(opptyId, opptyScheds);           
        }            
        
        List<OpportunityProductSchedule__c> opptyProdSchedsCreated = new List<OpportunityProductSchedule__c>();
        
        for (OpportunityLineItem oli : (List<OpportunityLineItem>)this.records) {
            if (LOST_CANCELLED.contains(oli.Prod_Lost_Cancelled__c)) continue;
            
            Integer schedDateIndex = 0;
            
            for (OpportunitySchedule__c os : opptySchedsMap.get(oli.OpportunityId)) {
                Decimal price = calcOpportunityProductSchedulePrice(oli.UnitPrice, oli.Price_Erosion_Rate__c, schedDateIndex);
                OpportunityProductSchedule__c opptyProdSched = new OpportunityProductSchedule__c();
                    
                opptyProdSched.Sched_Date__c = os.Sched_Date__c;
                opptyProdSched.Oppty_Sched_Qty__c = os.Oppty_Sched_Qty__c;
                opptyProdSched.Frozen_Oppty_Sched_Qty__c = os.Frozen_Oppty_Sched_Qty__c;
                opptyProdSched.Opportunity__c = oli.OpportunityId;
                opptyProdSched.Oppty_Prod_ID_Full__c = oli.Id;
                opptyProdSched.Product__c = oli.Product2Id;
                opptyProdSched.Prod_Sched_Price__c = price;
                opptyProdSched.Frozen_Prod_Sched_Price__c = price;
                opptyProdSched.Share__c = oli.Share__c;
                opptyProdSched.Frozen_Share__c = oli.Share__c;
                opptyProdSched.Qty_Per_Sys__c = oli.Component_Multiplier__c;
                opptyProdSched.CurrencyIsoCode = oli.CurrencyIsoCode;  
                    
                opptyProdSchedsCreated.add(opptyProdSched);
                schedDateIndex++;
            }
        }
        
        insert opptyProdSchedsCreated;
    }
    
    private void deleteLostCancelledOpptyProdScheds(List<OpportunityLineItem> existingRecords) {
        p('deleteLostCancelledOpptyProdScheds');
        Set<Id> opptyProdIds = new Set<Id>();
        
        List<OpportunityLineItem> opptyProds = new List<OpportunityLineItem>(); 

        for (OpportunityLineItem opptyProdOld : existingRecords) {
            for (OpportunityLineItem opptyProdNew : (List<OpportunityLineItem>)this.records) {
                if(opptyProdOld.Id == opptyProdNew.Id) {
                    if (!LOST_CANCELLED.contains(opptyProdOld.Prod_Lost_Cancelled__c) && LOST_CANCELLED.contains(opptyProdNew.Prod_Lost_Cancelled__c)) {
                        opptyProdIds.add(opptyProdNew.Id);
                        opptyProds.add(opptyProdNew);
                        system.debug('=====[Scarlett] Oppty Prod is changed from Open to Lost/Cancelled...');
                    }
                    
                    break;
                }
            }
        }       
        
        // Opporunity Product Id -> (Opportunity Product Schedule Id -> Opportunity Product Schedule)
        Map<Id, Map<Id, OpportunityProductSchedule__c>> opptyProdSchedsByOpptyProdId = getOpptyProdSchedsByOpptyProdId(opptyProds, opptyProdIds);
        
        List<OpportunityProductSchedule__c> opptyProdSchedsDeleted = new List<OpportunityProductSchedule__c>();

        for (OpportunityLineItem opptyProdOld : existingRecords) {
            for (OpportunityLineItem opptyProdNew : (List<OpportunityLineItem>)this.records) {
                if(opptyProdOld.Id == opptyProdNew.Id) {
                    if (!LOST_CANCELLED.contains(opptyProdOld.Prod_Lost_Cancelled__c) && LOST_CANCELLED.contains(opptyProdNew.Prod_Lost_Cancelled__c)) {
                        for (Id opptyProdSchedId : opptyProdSchedIds) {
                            if (opptyProdSchedsByOpptyProdId.containsKey(opptyProdNew.Id) && opptyProdSchedsByOpptyProdId.get(opptyProdNew.Id).containsKey(opptyProdSchedId)) { //updated by Scarlett on Jan 19
                                opptyProdSchedsDeleted.add(opptyProdSchedsByOpptyProdId.get(opptyProdNew.Id).get(opptyProdSchedId));
                                system.debug('=====[Scarlett] delete oppty prod scheds when product is changed to Lost...');
                            }
                        }
                    }
                    
                    break;
                }
            }
        }

        delete opptyProdSchedsDeleted; 
    }
    
    private void createReOpenOpptyProdScheds(List<OpportunityLineItem> existingRecords) {
        p('createReOpenOpptyProdScheds');
        Set<Id> opptyIds = new Set<Id>();
        Set<Id> opptyProdIds = new Set<Id>();
                
        for (OpportunityLineItem opptyProdOld : existingRecords) {
            for (OpportunityLineItem opptyProdNew : (List<OpportunityLineItem>)this.records) {
                if (opptyProdOld.Id == opptyProdNew.Id) {
                    if (LOST_CANCELLED.contains(opptyProdOld.Prod_Lost_Cancelled__c) && !LOST_CANCELLED.contains(opptyProdNew.Prod_Lost_Cancelled__c)) {
                        opptyProdIds.add(opptyProdNew.Id);
                        opptyIds.add(opptyProdNew.OpportunityId);
                        system.debug('=====[Scarlett] create oppty prod scheds for re open oppty products...');
                    }
                    
                    break;
                }
            }
        } 
        
        List<OpportunityProductSchedule__c> opptyProdSchedsCreated = new List<OpportunityProductSchedule__c>();
        Map<Id, List<OpportunitySchedule__c>> opptySchedsByOpptyId = getOpptySchedsByOpptyId(opptyIds);

        List<OpportunitySchedule__c> opptyScheds;
        OpportunityProductSchedule__c opptyProdSchedNew;

        for (OpportunityLineItem opptyProdNew : (List<OpportunityLineItem>)this.records) {
            if (opptyProdIds.contains(opptyProdNew.Id)) { // re-open products
                Integer schedIndex = 0;
    
                if (opptySchedsByOpptyId.containsKey(opptyProdNew.OpportunityId)) { // has Oppty Sched
                    opptyScheds = opptySchedsByOpptyId.get(opptyProdNew.OpportunityId);
                    
                    if (opptyScheds.size() > 0) {
                        for (OpportunitySchedule__c opptySched : opptyScheds) {
                            opptyProdSchedNew = new OpportunityProductSchedule__c();
                            
                            opptyProdSchedNew.Opportunity__c = opptyProdNew.OpportunityId;
                            opptyProdSchedNew.CurrencyIsoCode = opptyProdNew.CurrencyIsoCode; //J
                            
                            opptyProdSchedNew.Sched_Date__c = opptySched.Sched_Date__c;
                            opptyProdSchedNew.Oppty_Sched_Qty__c = opptySched.Oppty_Sched_Qty__c;
                            opptyProdSchedNew.Frozen_Oppty_Sched_Qty__c = opptySched.Oppty_Sched_Qty__c;
                            
                            opptyProdSchedNew.Product__c = opptyProdNew.Product2Id;
                            opptyProdSchedNew.Oppty_Prod_ID_Full__c = opptyProdNew.Id;
                            opptyProdSchedNew.Qty_Per_Sys__c = opptyProdNew.Component_Multiplier__c;
                            opptyProdSchedNew.Share__c = opptyProdNew.Share__c;
                            opptyProdSchedNew.Frozen_Share__c = opptyProdNew.Share__c;
                            
                            opptyProdSchedNew.Prod_Sched_Price__c = calcOpportunityProductSchedulePrice(opptyProdNew.UnitPrice, opptyProdNew.Price_Erosion_Rate__c, schedIndex);
                            opptyProdSchedNew.Frozen_Prod_Sched_Price__c = calcOpportunityProductSchedulePrice(opptyProdNew.UnitPrice, opptyProdNew.Price_Erosion_Rate__c, schedIndex);
                            schedIndex++;
                            
                            opptyProdSchedsCreated.add(opptyProdSchedNew);
                            
                            system.debug('====[Scarlett] created oppty prod scheds for re open products...');
                        }
                    }
                }
            } // re-open products
        }
        
        insert opptyProdSchedsCreated; 
    }
    
    private Map<Id, List<OpportunitySchedule__c>> getOpptySchedsByOpptyId(Set<Id> opptyIds){
        p('getOpptySchedsByOpptyId');
        Map<Id, List<OpportunitySchedule__c>> result = new Map<Id, List<OpportunitySchedule__c>>(); // Oppty Id -> Oppty Sched List
        
        for (OpportunitySchedule__c opptySched : new OpportunitySchedulesSelector().selectByOpptyId(opptyIds)) {
            if (result.containsKey(opptySched.Opportunity__c)) {
                result.get(opptySched.Opportunity__c).add(opptySched);
            }
            else {
                result.put(opptySched.Opportunity__c, new List<OpportunitySchedule__c>{opptySched});
            }
        }
        
        return result;
    }
    
    private void updateOpptyProdScheds(Map<Id, OpportunityLineItem> opptyProdsOld, Map<Id, OpportunityLineItem> opptyProdsNew) {
        p('updateOpptyProdScheds');
        List<OpportunityProductSchedule__c> opptyProdSchedsUpdated = new List<OpportunityProductSchedule__c>();
        
        Set<Id> opptyIds = new Set<Id>();
        Set<Id> opptyProdIds = new Set<Id>();
        
        for (OpportunityLineItem opptyProdNew : opptyProdsNew.values()) {
            opptyIds.add(opptyProdNew.OpportunityId);
            opptyProdIds.add(opptyProdNew.Id);
        }
        
        Map<Id, Opportunity> oppties = new Map<Id, Opportunity>(new OpportunitiesSelector().selectById(opptyIds));
        Map<Id, List<OpportunityProductSchedule__c>> opptyProdSchedsByOpptyProdId = getOpptyProdSchedsByOpptyProdId(opptyIds, opptyProdIds);
        
        if (opptyProdSchedsByOpptyProdId.size() > 0) {
        	for (OpportunityLineItem opptyProdNew : opptyProdsNew.values()) {
        		// The assumption is if oppty prods can be modified (from frontend or backend), the corresponding oppty prod scheds should change accordingly.
            	// It relies on all the validation rules and business logic in triggers to be enforced without any error.
            	// However, sometimes for MN batch job processing, the TMMA Override rollback logic fails to work for unknown reason. 
            	// That's why the following condition needs to be in place in case the situation above happens.
            	if (isMnRecordType(opptyProdNew) && OpportunityService.isCommitment(oppties.get(opptyProdNew.OpportunityId)) && isTmmaOverride(opptyProdNew)) continue;
            	
            	OpportunityLineItem opptyProdOld = opptyProdsOld.get(opptyProdNew.Id);
            	
                if (opptyProdSchedsByOpptyProdId.containsKey(opptyProdNew.Id)) { 
                    List<OpportunityProductSchedule__c> opptyProdSchedList = opptyProdSchedsByOpptyProdId.get(opptyProdNew.Id);
                    
                    for (Integer i = 0 ; i < opptyProdSchedList.size() ; i++) {
                        OpportunityProductSchedule__c opptyProdSchedUpdated = new OpportunityProductSchedule__c(Id = opptyProdSchedList[i].Id);
                        
                        if (opptyProdOld.UnitPrice != opptyProdNew.UnitPrice || opptyProdOld.Price_Erosion_Rate__c != opptyProdNew.Price_Erosion_Rate__c) {  
                        	opptyProdSchedUpdated.Prod_Sched_Price__c = calcOpportunityProductSchedulePrice(opptyProdNew.UnitPrice, opptyProdNew.Price_Erosion_Rate__c, i);
                            opptyProdSchedUpdated.Frozen_Prod_Sched_Price__c = opptyProdSchedUpdated.Prod_Sched_Price__c;
                        }
                        
                        if (opptyProdOld.Share__c != opptyProdNew.Share__c) {
                        	opptyProdSchedUpdated.Share__c = opptyProdNew.Share__c;
                        	opptyProdSchedUpdated.Frozen_Share__c = opptyProdSchedUpdated.Share__c;	
                        }
                        
                        if (opptyProdOld.Component_Multiplier__c != opptyProdNew.Component_Multiplier__c) {
                        	opptyProdSchedUpdated.Qty_Per_Sys__c = opptyProdNew.Component_Multiplier__c;	
                        }
                        
                        opptyProdSchedsUpdated.add(opptyProdSchedUpdated);
                    }
                } 
        	}
        	
        	update opptyProdSchedsUpdated;
        }
    }
    
    private Map<Id, List<OpportunityProductSchedule__c>> getOpptyProdSchedsByOpptyProdId(Set<Id> opptyIds, Set<Id> opptyProdIds) {
        p('getOpptyProdSchedsByOpptyProdId');
        Map<Id, List<OpportunityProductSchedule__c>> result = new Map<Id, List<OpportunityProductSchedule__c>>();
        
        for (OpportunityProductSchedule__c ops : new OpportunityProductSchedulesSelector().selectByOpptyIdAndOpptyProdId(opptyIds, opptyProdIds)) {
            if (result.containsKey(ops.Oppty_Prod_ID_Full__c)) {
                result.get(ops.Oppty_Prod_ID_Full__c).add(ops);
            } else {
                result.put(ops.Oppty_Prod_ID_Full__c, new List<OpportunityProductSchedule__c> {ops});
            }
         }
         
         return result;
    }
    
    private void checkOpptyScheds() {
        p('checkOpptyScheds');
        Set<Id> opptyIds = getOpptyIds((List<OpportunityLineItem>)this.records);   
        
        Map<Id, Integer> opptyScheds = new Map<Id, Integer>();
        
        for (OpportunitySchedulesSelector.OpportunityScheduleValueSummary osvs : new OpportunitySchedulesSelector().selectSchedValueByOpptyIdGroupByOpptyId(opptyIds)) {
            opptyScheds.put(osvs.opptyId, osvs.totalCount);
        }  
        
        for (OpportunityLineItem oli : (List<OpportunityLineItem>)this.records) {
            if (!opptyScheds.containsKey(oli.OpportunityId)) {
                oli.addError('Please create opportunity schedules before creating an opportunity product.');
            }
        }
    }
    
    private void updateLastBusinessModifiedInfo() {
        p('updateLastBusinessModifiedInfo');
        for (OpportunityLineItem opptyProdNew : (List<OpportunityLineItem>)this.records) { 
            if (Trigger.isInsert) {
                opptyProdNew.LastUpdatedById__c = UserInfo.getUserId();
                opptyProdNew.LastUpdatedDate__c = Datetime.now();
            }
            if (Trigger.isUpdate) {
                if (!CommonUtils.isAdminOrIntegrationUser()) {
                    opptyProdNew.LastUpdatedById__c = UserInfo.getUserId();
                    opptyProdNew.LastUpdatedDate__c = Datetime.now();
                }
            }           
        }
    }
    
    private void updateQty() {  
        p('updateQty'); 
        Set<Id> opptyIds = getOpptyIds((List<OpportunityLineItem>)this.records);
        
        List<OpportunitySchedulesSelector.OpportunityScheduleValueSummary> schedValues = new OpportunitySchedulesSelector().selectSchedValueByOpptyIdGroupByOpptyId(opptyIds);
             
        for (OpportunityLineItem oli : (List<OpportunityLineItem>)this.records) {
            for (OpportunitySchedulesSelector.OpportunityScheduleValueSummary osvs : schedValues) {
                if (oli.OpportunityId == osvs.opptyId) {
                    oli.Quantity = osvs.totalFrozenSchedQty;
                    oli.UnitPrice = oli.UnitPrice;  // SFDC constraint. Need to update UnitPrice and Quantity at the same time.
                    break;
                }
            }
        }               
    }
    
    private void updateLostCancelledInfo() {
        p('updateLostCancelledInfo');
        Map<Id, Opportunity> opptyLostCancelledInfo;
        
        opptyLostCancelledInfo = getOpptyLostCancelledInfo();
        
        for (OpportunityLineItem opptyProd : (List<OpportunityLineItem>)this.records) {
            if (opptyLostCancelledInfo.get(opptyProd.OpportunityId).RecordTypeId == OpportunitiesSelector.getMnRecordTypeId() && 
                Opportunities.LOST_STAGES.contains(opptyLostCancelledInfo.get(opptyProd.OpportunityId).StageName)) {
                opptyProd.Prod_Lost__c = true;
                opptyProd.Prod_Lost_Cancelled__c = opptyLostCancelledInfo.get(opptyProd.OpportunityId).StageName;
                opptyProd.Prod_Lost_Cancelled_Date__c = opptyLostCancelledInfo.get(opptyProd.OpportunityId).Lost_Date__c;
                opptyProd.Prod_Lost_Cancelled_Reason__c = opptyLostCancelledInfo.get(opptyProd.OpportunityId).Lost_Reason__c;
            }
        }
    } 
 
    private Map<Id, Opportunity> getOpptyLostCancelledInfo() {
        p('getOpptyLostCancelledInfo');
        Set<Id> opptyIds = new Set<Id>();
        
        for (OpportunityLineItem opptyProd : (List<OpportunityLineItem>)this.records) {
            opptyIds.add(opptyProd.OpportunityId);
        }
        
        Map<Id, Opportunity> result = new Map<Id, Opportunity>(new OpportunitiesSelector().selectById(opptyIds));
        
        return result;
    }
    
    private void updateLostCancelledInfo(List<OpportunityLineItem> existingRecords) {
        p('updateLostCancelledInfo(existingRecords)');
        for (OpportunityLineItem opptyProdOld : existingRecords) {
            for (OpportunityLineItem opptyProdNew : (List<OpportunityLineItem>)this.records) {
                if (opptyProdOld.Id == opptyProdNew.Id && opptyProdNew.Opportunity_Record_Type_Id__c == OpportunitiesSelector.getSfdcRecordTypeId()) {
                    // From Open to Lost/Cancelled
                    if (!LOST_CANCELLED.contains(opptyProdOld.Prod_Lost_Cancelled__c) && LOST_CANCELLED.contains(opptyProdNew.Prod_Lost_Cancelled__c)) {
                        opptyProdNew.Prod_Lost_Cancelled_Date__c = date.today();
                        opptyProdNew.Prod_Lost__c = true;// Prod_Lost__c will be obsoleted in the near future
                    }
                    
                    // From Lost/Cancelled to Open
                    if (LOST_CANCELLED.contains(opptyProdOld.Prod_Lost_Cancelled__c) && !LOST_CANCELLED.contains(opptyProdNew.Prod_Lost_Cancelled__c)) {
                        opptyProdNew.Prod_Lost_Cancelled__c = null;
                        opptyProdNew.Prod_Lost_Cancelled_Date__c = null;
                        opptyProdNew.Prod_Lost_Reason__c = null;
                        opptyProdNew.Prod_Lost__c = false;// Prod_Lost__c will be obsoleted in the near future
                    }
                    
                    break;
                }
            }
        }
    }
    
    private Set<Id> getOpptyIds(List<OpportunityLineItem> opptyLineItems) {
        p('getOpptyIds');
        Set<Id> result = new Set<Id>();
        
        for (OpportunityLineItem oli : opptyLineItems) {
            result.add(oli.OpportunityId);
        }
        
        return result;
    }
    
    private Boolean isOpptyProdLostCancelled(OpportunityLineItem opptyLineItem) {
        return LOST_CANCELLED.contains(opptyLineItem.Prod_Lost_Cancelled__c);   
    }
    
    // SFDC-588
    private void updateHelpNeededHistory(List<OpportunityLineItem> existingRecords) {
        p('updateHelpNeededHistory');
        for (OpportunityLineItem opptyProdOld : existingRecords) {
            for (OpportunityLineItem opptyProdNew : (List<OpportunityLineItem>)this.records) {
                if (opptyProdOld.Id == opptyProdNew.Id) {
                    if(opptyProdOld.Help_Needed__c != opptyProdNew.Help_Needed__c && opptyProdOld.Help_Needed__c != '') {
                        opptyProdNew.Help_Needed_History__c = opptyProdOld.Help_Needed__c;
                    }
                    
                    break;
                }
            }
        }
    }
    
    private void updateNpi() {
        p('updateNpi');
        for (OpportunityLineItem oli : (List<OpportunityLineItem>)this.records) {
            oli.NPI_Shadow__c = new Set<String> {'DEV', 'CQS', 'ASM'}.contains(oli.Prod_State__c) ? 1 : 0;
        }
    }
    
    private void resetTmmaOverriddenFields(Map<Id, OpportunityLineItem> opptyLineItemsOld, Map<Id, OpportunityLineItem> opptyLineItemsNew) {
        p('resetTmmaOverriddenFields');
        if (!CommonUtils.isDataAdminUser()) return;
        
        Set<String> tmmaOverrideFields = getTmmaOverrideFields(); 
        
        for (OpportunityLineItem oliNew : opptyLineItemsNew.values()) {
            OpportunityLineItem oliOld = opptyLineItemsOld.get(oliNew.Id);    
            
            if (isMnRecordType(oliNew) && isTmmaOverride(oliNew)) {
                CommonUtils.resetFields(oliOld, oliNew, tmmaOverrideFields);
            }
        }   
    }
    
    private void updateTmmaOverride(Map<Id, OpportunityLineItem> opptyLineItemsOld, Map<Id, OpportunityLineItem> opptyLineItemsNew) {
        p('updateTmmaOverride');
        if (CommonUtils.isDataAdminUser()) return;
        
        Set<Id> opptyIds = new Set<Id>();
                
        for (OpportunityLineItem oli : opptyLineItemsNew.values()) {
            if (isMnRecordType(oli)) {
                opptyIds.add(oli.OpportunityId);
            }
        }
        
        if (opptyIds.size() == 0) return;
        
        Map<Id, Opportunity> oppties = new Map<Id, Opportunity>(new OpportunitiesSelector().selectById(opptyIds));
        
        Set<String> tmmaOverrideFields = getTmmaOverrideFields();
        Set<Opportunity> opptiesUpdated = new Set<Opportunity>(); 
        
        for (OpportunityLineItem oliNew : opptyLineItemsNew.values()) {
            OpportunityLineItem oliOld = opptyLineItemsOld.get(oliNew.Id);    
                        
            if (isMnRecordType(oliNew) && CommonUtils.fieldsChanged(oliOld, oliNew, tmmaOverrideFields)) {
                Opportunity oppty = oppties.get(oliNew.OpportunityId);
                oppty.TMMA_Override__c = true;
                opptiesUpdated.add(oppty);
            }
        }
        
        if (opptiesUpdated.size() > 0) {
            update new List<Opportunity>(opptiesUpdated);
        }
    }
   
    private Boolean isMnRecordType(OpportunityLineItem opptyProd) {
        p('isMnRecordType');
        return opptyProd.Opportunity_Record_Type_Id__c == OpportunitiesSelector.getMnRecordTypeId();
    }
    
    private Boolean isSfdcRecordType(OpportunityLineItem opptyProd) {
        p('isSfdcRecordType');
        return opptyProd.Opportunity_Record_Type_Id__c == OpportunitiesSelector.getSfdcRecordTypeId();
    }
    
    private Boolean isOpenStage(String stage) {
        p('isOpenStage');
        return Opportunities.OPEN_STAGES.contains(stage); 
     }          
    
    private Boolean isTmmaOverride(OpportunityLineItem opptyProd) {
        p('isTmmaOverride');
        return opptyProd.Opportunity_TMMA_Override__c;
    }
    
    private Set<String> getTmmaOverrideFields() {
        p('getTmmaOverrideFields');
        return new OpportunityTmmaOverrideSettingsSelector().selectFieldNamesByObjectName(getSObjectName());
    }

}