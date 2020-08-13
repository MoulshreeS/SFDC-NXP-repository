/*************************************************************************
@Created By:     Manikanta
@Description:    class to Show Leads in Contact
**************************************************************************/

public  class leadhistorycontact {
    
    @AuraEnabled 
    
    //Writing Wrapper class to get the Owner.Name from Lead record.
    Public static LeadHistoryWrapper getleadhistorydetails(id contactid){
        
        Contact conCurrent;
        
        conCurrent = [select ID,email from contact where id =:contactid and email != null];
        
        List<Lead> l = [select Id,Name,rating,CreatedDate,Owner.Name,Status,Rejection_Reason__c,Company,
                        Project_Description__c,MAG_Code__c,OwnerId,Lead_History__c,Distributor__c  from lead where email =: conCurrent.Email and Lead_History__c = false order by LastModifiedDate desc];
        
        LeadHistoryWrapper lhw =  new LeadHistoryWrapper();
        lhw.leadHistoryChanges = new List<LeadHistoryDTO> ();
        
        
        for(Lead led : l){
            lhw.leadHistoryChanges.add(new LeadHistoryDTO(led));
        }
        return lhw;
        
    }
    public class LeadHistoryWrapper {
        @AuraEnabled public List<LeadHistoryDTO> leadHistoryChanges { get; set; }
    }
    
    
    public class LeadHistoryDTO {
        @AuraEnabled public Id LeadId { get; set; }
        @AuraEnabled public String LeadName { get; set; }
        @AuraEnabled public String Rating { get; set; }
        @AuraEnabled public String Status { get; set; }
        @AuraEnabled public String RejectionReason { get; set; }
        @AuraEnabled public Date CreatedDate { get; set; }
        @AuraEnabled public String Company { get; set; }
        @AuraEnabled public String ProjectDescription { get; set; }
        @AuraEnabled public String MAGCode { get; set; }
        @AuraEnabled public String User { get; set; }
        // @AuraEnabled public String Leadurl { get; set; }
        
        public LeadHistoryDTO (Lead leadHistoryRecord) {
            if(leadHistoryRecord != null) {
                this.LeadId = leadHistoryRecord.Id;
                this.LeadName = leadHistoryRecord.Name;
                this.Rating = leadHistoryRecord.Rating;
                this.Status = leadHistoryRecord.Status;
                this.RejectionReason = leadHistoryRecord.Rejection_Reason__c;
                this.Company = leadHistoryRecord.Distributor__c;
                this.ProjectDescription = leadHistoryRecord.Project_Description__c;
                this.MAGCode = leadHistoryRecord.MAG_Code__c;
                this.CreatedDate = leadHistoryRecord.CreatedDate.date();
                this.User = leadHistoryRecord.Owner.Name;
                
            }
            
        }
        
    }
    
    
    
    
}