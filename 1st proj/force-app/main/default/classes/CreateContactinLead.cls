/*************************************************************************
@Created By:     Manikanta
@Description:    class to Create Contact from Lead
**************************************************************************/

public class CreateContactinLead {
    @AuraEnabled
    Public static Lead getLeadDetails(id Leadid){
        
        Lead leadCurrent;
        
        
        leadCurrent = [select ID,firstname,lastname,recordtype.Name,ownerId,Owner.Name,Title,Company,country,state,phone,
                       email,Street,City from Lead where id =:Leadid];
        
        
        return leadCurrent;
        
    }
    
    @AuraEnabled
    Public static Boolean getcontactemail(id Leadid){
        
        Lead leadCurrent;
        Boolean conexist;
        
        leadCurrent = [select ID,firstname,lastname,recordtype.Name,ownerId,Owner.Name,Title,Company,country,state,phone,
                       email,Street,City from Lead where id =:Leadid];
        List<Contact> c = [select id from contact where email =: leadCurrent.Email];
        if(c.size() > 0){
            conexist = true;
        }
        else{
            conexist = false;
        }
        
        return conexist;
        
    }
    
    @AuraEnabled
    Public static Boolean getrecordtype(id Leadid){
        
        Lead leadCurrent;
        Boolean recttype;
        System.debug('leadiddd:' + Leadid );
        leadCurrent = [select ID,firstname,lastname,recordtype.Name,ownerId,NXP_Global_Customer_Master_ID__c from Lead where id =:Leadid];
        List<Account> a =[select id,IsInactive__c from Account where IsInactive__c = false and nxp_gid__c =: leadCurrent.NXP_Global_Customer_Master_ID__c limit 1];
        if((leadCurrent.RecordType.Name == 'TMMA Leads' || leadCurrent.RecordType.Name == 'Assigned Account Leads') && leadCurrent.NXP_Global_Customer_Master_ID__c != null && a[0] != null )  {
            recttype = true;
        }
        else if(leadCurrent.RecordType.Name == 'ROM Leads'){
            recttype= false;
        }
        
        return recttype;
        
    }
    
    
    @AuraEnabled
    public static List < sObject >  fetchAccountlist(String searchKeyWord){
        list<Account> returnAccounts = new list<Account>();
        String searchKey = '%' + searchKeyWord + '%'; 
        returnAccounts =[select id,Name,Country__c,City__c from Account where Name LIKE: searchKey and IsInactive__c = false];
        
        return returnAccounts;
    }
    
    
    @AuraEnabled
    public static  Account   fetchAccountrectype(id Leadid){
        Lead l = [select id,NXP_Global_Customer_Master_ID__c from Lead where Id =: Leadid and  NXP_Global_Customer_Master_ID__c != ''];
        
        List<Account> returnAccount = new List<Account>();
        
        
        returnAccount =[select id,Name,Country__c,City__c from Account where IsInactive__c = false and   NXP_GID__c =: l.NXP_Global_Customer_Master_ID__c  limit 1];
        
        
        return returnAccount[0];
    }
    
    
    @AuraEnabled
    public static List < sObject >  fetchAccounts(){
        list<Account> returnAccounts= new list<Account>();        
        returnAccounts=[select id,Name,Country__c,City__c,createddate  from Account where  IsInactive__c = false order by createddate desc limit 100];
        return returnAccounts;
    }
    @AuraEnabled
    public static void createcontact (String firstnameval,String lastnameval, String emailval, String Titleval,
                                      Id AccountIdval,String countryval,String Stateval,String Cityval,String Streetval,String Mailingcountryval,String MailingStateval,String phoneval){
                                          
                                          
                                          Contact c = new Contact();
                                          c.lastname = lastnameval;
                                          c.FirstName = firstnameval;
                                          c.Email = emailval;
                                          c.AccountId = AccountIdval;
                                          c.Community_web_country__c = countryval;
                                          c.State_Province__c = Stateval; 
                                          c.MailingCity = Cityval;
                                          c.MailingCountry = Mailingcountryval;
                                          c.MailingState =MailingStateval;
                                          c.Title = Titleval;
                                          c.MailingStreet = Streetval;
                                          c.Contact_source__c = 'Lead';
                                          c.Phone = phoneval;
                                          
                                          Insert c;
                                          /*
Opportunity o = [select id from Opportunity where id= '0063E000006P7Wj'];
OpportunityContactRole oc = new OpportunityContactRole();
oc.OpportunityId = o.Id;
oc.ContactId = c.Id;
Insert oc;
*/
                                          
                                      }
    
}