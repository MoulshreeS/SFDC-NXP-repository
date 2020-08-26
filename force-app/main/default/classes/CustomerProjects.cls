public class CustomerProjects extends ApplicationDomain {

    public CustomerProjects(List<Customer_Project__c> cusProjs) {
        super(cusProjs);
    }

    public class Constructor implements fflib_SObjectDomain.IConstructable {
        public fflib_SObjectDomain construct(List<SObject> sObjectList) {
            return new CustomerProjects(sObjectList);
        }
    }
    
    public override void onBeforeInsert() {
        p('onBeforeInsert');
        allowOneCustProjPerOppty();
    }
    
    public override void onBeforeUpdate(Map<Id, SObject> existingRecords) {
        p('onBeforeUpdate');
        allowOneCustProjPerOppty();
    }
    
    private void allowOneCustProjPerOppty() {
        p('allowOneCustProjPerOppty');
        
        Set<Id> opptyIds = new Set<Id>();
        
        for (Customer_Project__c cp : (List<Customer_Project__c>)this.records) {
            opptyIds.add(cp.Opportunity__c); 
        }
        
        Map<Id,Opportunity> opptyById = new Map<Id, Opportunity>();
        
        for (Opportunity oppty : [SELECT Id, (SELECT Id FROM CAS__r) FROM Opportunity WHERE Id in :opptyIds]) {
            opptyById.put(oppty.Id, oppty);
        }
        
        for (Customer_Project__c cp : (List<Customer_Project__c>)this.records) {        
            if (opptyById.containsKey(cp.Opportunity__c)) {
                Integer numOfCustomerProjectsPerOppty = opptyById.get(cp.Opportunity__c).CAS__r.size();    
                if (numOfCustomerProjectsPerOppty > 1 || (cp.isClone() && numOfCustomerProjectsPerOppty > 0)) {
                    cp.addError('This Opportunity has an existing Customer Project.');
                }
            }               
        }
    }
}