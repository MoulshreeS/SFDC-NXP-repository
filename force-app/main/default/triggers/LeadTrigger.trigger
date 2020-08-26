/*************************************************************************
@Created By:     Jewelslyn
@Description:    Trigger for updates in Lead
-----------------------------------------------------------------
@Modified By:     Jewelslyn
@Modified Date:   22 Sep 2017
@Description:    Modified trigger to include random Token generation and to update the Disti contact
if disti contact is not same as Disti feedback email provided Disti feedback email exists in sfdc.
--------------------------------------------------------------------
@Modified By:     Jewelslyn
@Modified Date:   4 Dec 2017
@Description:    Modified trigger to include Sending emails to multiple distis
----------------------------------------------------------------------------
@Modified By:     Nisha Agrawal
@Modified Date:   Jun 20, 2018
@Description:     Modified trigger to include Lead record sharing with Disti Users
----------------------------------------------------------------------------

@Modified By:    Sudhish Nair
@Modified Date:  October 9, 2018
@Description:    Modified to change logic around Send To Disti. Modified code to regenerate token 
only when disti account is changed

@Modified By:    Sudhish Nair
@Modified Date:  October 23, 2018
@Description:    Modified to change logic around Send To Disti. Added additional fields and logic for setting them. This
is to track if Leads are moving between Distis


----------------------------------------------------------------------------------------------------
@Modified By:     Ranganath C N
@Modified Date:   Nov 14, 2018
@Description:     Modified trigger to update Lead sub region from User
---------------------------------------------------------------------------------------------------
@Modified By:     Kumaresh M
@Modified Date:   Apr 29, 2019
@Description:     Modified as part of SFDC-2785
---------------------------------------------------------------------------------------------------

@Modified By:     Moulshree Shrivastava
@Modified Date:   Mar 30, 2020
@Description:     Modified as part of SFDC-3724
***********************************************************************************************/
trigger LeadTrigger on Lead (before insert,before update,after insert,after update) {
    Private Static Final string SENT_TO_DISTI='Sent to Distributor';
    /*CDLP-66: solution not valid, because Eloqua is sending more leads.
     * if(Utility.currentUserHasProfile('NXP API Integration User')) {
        for(Lead auxLead : Trigger.new) {
            if(LeadTriggerHandler.areChangesFromEloquaIgnored(auxLead.Id, auxLead.Eloqua_Last_Activity_Date__c, LeadTriggerHandler.ELOQUA_FIELDS_TO_DETECT_CHANGES)) {
                return;
            }
        }
    }*/

    if(Trigger.isbefore && Trigger.isInsert){
        LeadTriggerHandler.assignCountryNames(Trigger.new);    
    }else if(trigger.isbefore && Trigger.isUpdate){
        List<Lead> changedLeads = new List<Lead>();
        List<Lead> randomNumberLds = new List<Lead>();
        List<Lead> distiChangeLds = new List<Lead>();
        Map<String,Lead> distiChangeLdsMap = new Map<String,Lead>();
        List<Lead> distiContactUpdateLds = new List<Lead>();
        List<Lead> distiExpiredLeads = new List<Lead>();
        
        for(Lead newld:Trigger.new){
            Lead oldLd = Trigger.oldMap.get(newld.Id);
            if(oldLd !=null &&((oldLd.Country != newLd.Country) || (oldLd.State != newLd.State))){
                changedLeads.add(newld);
            }
            if(oldLd !=null &&(oldLd.distributor__c != newLd.distributor__c)){
                randomNumberLds.add(newld);
            }
            if(oldLd.distributor_contact__c !=newLd.distributor_contact__c){
                distiContactUpdateLds.add(newLd);
            }            
            if(oldLd !=null && oldLd.distributor_contact__c != newLd.distributor_contact__c && oldLd.distributor__c == newLd.distributor__c && (newLd.distributor__c==null || newLd.distributor__c=='Other')) {
                distiChangeLds.add(oldLd);
                distiChangeLdsMap.put(oldLd.id,newLd);
            }

            /*if(newLd.Status==SENT_TO_DISTI || oldLd.Note_To_Disti__c != newLd.Note_To_Disti__c){
                listEmailToDistiLds.add(newLd);
            }
            /*if(oldLd !=null&&((newLd.distributor_contact__r.Email != newLd.Disti_Feedback_Email_Address__c)) &&
               (newld.Status =='Accepted by Disti' || newld.Status =='Rejected by Disti') &&
               newLd.Disti_Feedback_Email_Address__c !=null) {
                   distiContactUpdateLds.add(newLd);
               }*/
        }
        if(changedLeads !=null && (!changedLeads.isEmpty())){
            LeadTriggerHandler.assignCountryNames(changedLeads); 
            
        }
        if(randomNumberLds!=null &&(!randomNumberLds.isEmpty())){
            LeadTriggerHandler.assignRandomString(randomNumberLds);
        }
        if(distiContactUpdateLds!=null && (!distiContactUpdateLds.isEmpty())){
            LeadTriggerHandler.updateDistiAccountFields(distiContactUpdateLds);    
        }
        if(distiChangeLds !=null && (!distiChangeLds.isEmpty())){
            LeadTriggerHandler.checkIfDistiChanged(distiChangeLds,distiChangeLdsMap);
        }

        /*if(listEmailToDistiLds!=null &&(!listEmailToDistiLds.isEmpty()) && LeadTriggerHandler.recursionCheck ==True){            
               LeadTriggerHandler.emailToMultipleDistis(listEmailToDistiLds);                         
        }
        /*if(distiContactUpdateLds !=null &&(!distiContactUpdateLds.isEmpty())){
            LeadTriggerHandler.distContactUpdate(distiContactUpdateLds);
        }*/
        
        //Added by ranganath as a part of SFDC
        if(trigger.new != null){
            LeadTriggerHandler.LeadtoUserSubregionupdate(trigger.new,trigger.oldmap);
        }
        //SFDC-3724
        LeadTriggerHandler.updatedistibranch(Trigger.new,trigger.oldmap);
    }
    if(trigger.isAfter && trigger.isInsert){
        
    }
    if(trigger.isAfter && trigger.isUpdate){
        list<Lead> listConvertedLeads=new list<lead>();
        List<Id> listEmailToDistiLds = new List<Id>();
        
                
         //Added by Ranganath --(SFDC-1708) 
        //rejected lead
        List<Lead> distiExpiredLeads = new List<Lead>();
        List<Lead> rejectedLeads = new List<Lead>();
        
        for(lead newld:trigger.new){
            Lead oldLd = Trigger.oldMap.get(newld.Id);
            if(newld.IsConverted && !oldLd.IsConverted){
                listConvertedLeads.add(newld);
            }
            if(oldLd.distributor_contact__c !=newLd.distributor_contact__c){
                listEmailToDistiLds.add(newLd.id);
           }
             //Added by Ranganath --(SFDC-1708) 
            //check if new value is rejected
            if(oldLd.status !='Disti Expired' && newLd.Status=='Disti Expired'&& 
               (newLd.Disti_Feedback_Email_Address__c==null || 
                newLd.Disti_Feedback_Email_Address__c.trim().length()==0)){
                distiExpiredLeads.add(newLd);
            }

            if(oldLd.status !='Rejected' && newLd.Status=='Rejected'){
                rejectedLeads.add(newLd);
            }           
            
        }
        if(listConvertedLeads!=null && (!listConvertedLeads.isEmpty())){
            LeadTriggerHandler.insertContactRoles(listConvertedLeads);
            LeadTriggerHandler.insertleadtoopty(listConvertedLeads);
        }
        if(listEmailToDistiLds!=null &&(!listEmailToDistiLds.isEmpty()) && LeadTriggerHandler.recursionCheck ==True){            
               LeadTriggerHandler.emailToMultipleDistis(listEmailToDistiLds); 
                LeadTriggerHandler.recursionCheck=false;                        
        }
        
       if(distiExpiredLeads!=null && (!distiExpiredLeads.isEmpty()) && LeadTriggerHandler.distiQueueReassign){
            LeadTriggerHandler.assignNewDistiFromQueue(distiExpiredLeads);    
        } 
        
        if(rejectedLeads!=null &&(!rejectedLeads.isEmpty()) ){            
               LeadTriggerHandler.rejectedleadswithreason(rejectedLeads);                         
        } 
        
        //code added by Nisha Agrawal on Jun 20, 2018
        LeadTriggerHandler.shareLeadRecordsToLPUsers(trigger.new, trigger.oldmap);
    }
    
}