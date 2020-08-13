/**************************************************************************************
@Created By :    Nisha Agrawal
@Created Date:   Sep 18, 2018
@Description:    Class for server side controller for lightning component ForwardToDisti component
******************************************************************************************/

public without sharing class ForwardLeadToDistiController
{
    @AuraEnabled 
    public static void forwardLeadWithinDisti(Id leadId, Id contactId)
    {
        if(leadId != null && contactId != null)
        {
			//assign it to Distributor Contact and shift the previous values to Previous Assignee Fields
			List<Lead> lstLeads = [Select Id, Distributor_Contact__c, Previous_Assignee__c, Original_Assignee__c From Lead
                              		Where Id =: leadId Limit 1];
			Lead objLead;
            if(lstLeads.size() > 0)
            {
                objLead = lstLeads[0];
                objLead.Previous_Assignee__c = objLead.Distributor_Contact__c;
                if(objLead.Original_Assignee__c == null)
                {
                    objLead.Original_Assignee__c = objLead.Distributor_Contact__c;
                }
                objLead.Distributor_Contact__c = contactId;
                
                try
                {
                    update objLead;
                }
                catch(Exception ex)
                {
                    throw new AuraHandledException('Some error occured while forwarding the lead : ' + ex.getMessage());
                }                
            }
        }
    }
    
    @AuraEnabled(cacheable=true)
    public static Contact findContactByEmail(String email) 
    {
        if(String.isNotBlank(email)) 
        {
			List<Contact> lstContacts = [SELECT Id, Name, Email, Community_web_country__c, Account.Name FROM Contact WHERE Email = :email];
            if(lstContacts.size() > 0)
            {
            	return lstContacts[0];    
            }
        }
        
        return null;
    }
    
    @AuraEnabled
    public static void moveContactToForwardeeAccount(Id contactId) 
    {
        User currentUser = getAccountIdAndCountryFromCurrentCommunityUser();
        Id accountId = currentUser.Contact.AccountId;
                
        if(contactId != null && accountId  != null)
        {
            List<Contact> lstContacts = [SELECT Id, AccountId, Community_web_country__c FROM Contact WHERE Id = :contactId];
            if(lstContacts.size() > 0)
            {
            	Contact objContact = lstContacts[0];
                objContact.AccountId = accountId;
                
                if(String.isBlank(objContact.Community_web_country__c) )
                {
                	objContact.Community_web_country__c = currentUser.Contact.Community_web_country__c;    
                }
                
            	try
                {
                    update objContact;
                }
                catch(Exception ex)
                {
                    throw new AuraHandledException('Some error occured while moving the contact to forwardee\'s account  : ' + ex.getMessage());
                }
            }
        } 
    }
    
    @AuraEnabled
    public static User getAccountIdAndCountryFromCurrentCommunityUser() 
    {
        Id currentUserId = UserInfo.getUserId();
        List<User> lstUsers = [SELECT ContactId, Contact.AccountId, Contact.Community_web_country__c  FROM User WHERE Id = :currentUserId];
        if(lstUsers.size() > 0 && lstUsers[0].ContactId != null)
        {
            return lstUsers[0];
        }
        return null; 
    }
    
}