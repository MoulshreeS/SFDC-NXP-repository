/******************************************************************************
* Created By: Manikanta
* Created Date : Dec 21,2018
* Description : Created this class to handle Owner Assignment for Leads.
*******************************************************************************/

public class LeadAssignmentHandler {
    
    public static List<String> parentGIDActive;
    public static Set<string> strLeadGIDs;
    public static Map<String,List<Account>> aaChildren; //{PARENTGID1_AA={child1,child2},PARENTGID2_AA={child1,child2}....) keyformat parentgid_AA 
    public static Map<String,List<Account>> tmmaChildren; //{PARENTGID1_TMMA={child1,child2},PARENTGID2_TMMA={child1,child2}....) keyformat parentgid_TMMA
    public static Map<String,Lead_Assignment_Exception_table__c> aaException;
    public static Map<String,Lead_Assignment_Exception_table__c> tmmaException;
    
    // RecordTypes
    
    public static  String AA_LEAD_RECORD_TYPE;
    public static String TMMA_LEAD_RECORD_TYPE;
    public static String ROM_LEAD_RECORD_TYPE;
    public static string UNCATEGORIZED_RECORD_TYPE;
    public static string CHILD_RECORD_TYPE;
    public static string PARENT_RECORD_TYPE;
    public static string AA_Exception_Record_Type;
    public static string TMMA_Exception_Record_Type;
    
    //Maps
    public static map<string,list<Account>> mapGIdsToAccountList;
    public static map<string,set<string>> mapGIdsToRecordTypes;
    public static map<string,Account> mapGIdsToParentAccount;
    public static map<string,Account> mapGIdsToAccount;
    public static List<Account> listAAChildAccounts;
    public static List<Account> listTMAAChildAccounts;
    Public static Map<Id,Lead> Updatefinalleads;
    public static map<string,list<Lead_Assignment_Exception_table__c>> mapGIdsToExceptionList;
    public static map<string,list<Lead_Assignment_Exception_table__c>> mapGIdsTotmmaExceptionList;
    
    static{
        init();
    }
    //For Initializing Record Types 	
    public static void init(){
        List<RecordType> recordTypes = [Select Id,name,developername From RecordType 
                                        where sobjecttype = 'Lead' OR sobjecttype = 'Account' 
                                        OR sobjecttype = 'Lead_Assignment_Exception_table__c'];        
        for(RecordType rt : recordTypes){
            if(rt.DeveloperName == 'Assigned_Account_Leads'){
                AA_LEAD_RECORD_TYPE = rt.Id;    
            }else if(rt.DeveloperName == 'TMMA_Leads'){
                TMMA_LEAD_RECORD_TYPE=rt.Id;
            }else if(rt.DeveloperName == 'ROM_Leads'){
                ROM_LEAD_RECORD_TYPE=rt.id;
            }else if(rt.DeveloperName == 'Uncategorized_Leads'){
                UNCATEGORIZED_RECORD_TYPE=rt.id;
            }
            else if(rt.DeveloperName == 'Child_Account'){
                CHILD_RECORD_TYPE=rt.id;
            }
            else if(rt.DeveloperName == 'Parent_Account'){
                PARENT_RECORD_TYPE=rt.id;
            }
            else if(rt.DeveloperName == 'AA_Exception'){
                AA_Exception_Record_Type = rt.id;
            }
            else if(rt.DeveloperName == 'TMMA_Exception'){
                TMMA_Exception_Record_Type = rt.id;
            }
            
            
        }
        aaException = new Map<String,Lead_Assignment_Exception_table__c>();
        tmmaException = new Map<String,Lead_Assignment_Exception_table__c>();
        mapGIdsToExceptionList=new map<string,list<Lead_Assignment_Exception_table__c>>();
        mapGIdsTotmmaExceptionList=new map<string,list<Lead_Assignment_Exception_table__c>>();
        list<Lead_Assignment_Exception_table__c> aaExceptionList = [SELECT Id,Name,Account_GID__c,Country__c,City__c,
                                                                    State__c,Alternative_Lead_Owner__c 
                                                                    from Lead_Assignment_Exception_table__c
                                                                    where recordtypeid =: AA_Exception_Record_Type];
        list<Lead_Assignment_Exception_table__c> tmmaExceptionList = [SELECT Id,Name,Account_GID__c,Country__c,
                                                                      City__c,State__c,Alternative_Lead_Owner__c 
                                                                      from Lead_Assignment_Exception_table__c
                                                                      where recordtypeid =: TMMA_Exception_Record_Type];
        
        for(Lead_Assignment_Exception_table__c objExcpTable : aaExceptionList){
            if(!mapGIdsToExceptionList.containskey(objExcpTable.Account_GID__c)){ 
                mapGIdsToExceptionList.put(objExcpTable.Account_GID__c,new list<Lead_Assignment_Exception_table__c>{objExcpTable}); 
            }
            else if(mapGIdsToExceptionList.containskey(objExcpTable.Account_GID__c)){
                mapGIdsToExceptionList.get(objExcpTable.Account_GID__c).add(objExcpTable);                    
            }                
            
            aaException.put(objExcpTable.Account_GID__c,objExcpTable);
            
        }
        
        for(Lead_Assignment_Exception_table__c objExcpTable : tmmaExceptionList){
            if(!mapGIdsTotmmaExceptionList.containskey(objExcpTable.Account_GID__c)){ 
                mapGIdsTotmmaExceptionList.put(objExcpTable.Account_GID__c,new list<Lead_Assignment_Exception_table__c>{objExcpTable}); 
            }
            else if(mapGIdsTotmmaExceptionList.containskey(objExcpTable.Account_GID__c)){
                mapGIdsTotmmaExceptionList.get(objExcpTable.Account_GID__c).add(objExcpTable);                    
            } 
            
            tmmaException.put(objExcpTable.Account_GID__c,objExcpTable);
            
        }
        
        Updatefinalleads = new Map<Id,Lead>();
        
    }
    
    // For Setting up all Maps and Lists.
    public static void fieldValueMapping(list<lead> listUnCategorizedLead){
        
        
        List<Lead> leadlist = new List<Lead>();
        for(Lead l : listUnCategorizedLead){
            l.Geo_Score__c = 0;
            l.Account_GID_Match__c = '';
            leadlist.add(l);
        }
        Update leadlist;
        
        list<lead> listROMLeads=new list<lead>();
        strLeadGIDs = new set<String>();
        for(lead leadRec:listUnCategorizedLead){
            if(leadRec.NXP_Global_Customer_Master_ID__c != null){
                strLeadGIDs.add(leadRec.NXP_Global_Customer_Master_ID__c); 
                
            }
            // ROM Assigning start 
            else if(leadRec.NXP_Global_Customer_Master_ID__c == null){
                
                leadRec.RecordTypeId=ROM_LEAD_RECORD_TYPE;
                leadRec.Lead_Owner_Assignment__c='Lead Marked as ROM Leads as no match is found';
                // listROMLeads.add(leadRec);
                Updatefinalleads.put(leadRec.id,leadRec);
                
            }
            
        }
        
        // ROM Assigning end 
        
        
        list<Account> listAccount=[SELECT Id,Name,NXP_GID__c,RecordTypeId,IsInactive__c ,
                                   CMD_Industry_Segment__c,Customer_Category__c,OwnerId,Country__c,
                                   State_Province__c,City__c from Account 
                                   where NXP_GID__c in :strLeadGIDs]; 
        mapGIdsToAccountList = new map<string,list<Account>>();
        mapGIdsToRecordTypes=new map<string,set<string>>();
        mapGIdsToAccount=new map<string,Account>();
        mapGIdsToParentAccount=new map<string,account>();
        //mapParentIdsToAccountList=new map<string,list<Account>>();
        if(listAccount.size()!=0){
            for(account acc:listAccount){
                if(!mapGIdsToAccountList.containskey(acc.NXP_GID__c)){                  
                    mapGIdsToAccountList.put(acc.NXP_GID__c,new list<Account>{acc});                    
                }
                else if(mapGIdsToAccountList.containskey(acc.NXP_GID__c)){
                    mapGIdsToAccountList.get(acc.NXP_GID__c).add(acc);                    
                }                
            }   
        }
        
        // Parent Account Ids
        Set<Id> parentAccountIds=new set<Id>();
        for(lead ld : listUnCategorizedLead) {
            if(ld.NXP_Global_Customer_Master_ID__c !=null 
               && mapGIdsToAccountList.containskey(ld.NXP_Global_Customer_Master_ID__c)){
                   for(Account acc:mapGIdsToAccountList.get(ld.NXP_Global_Customer_Master_ID__c)){
                       if(!mapGIdsToRecordTypes.containsKey(ld.NXP_Global_Customer_Master_ID__c)){
                           mapGIdsToRecordTypes.put(ld.NXP_Global_Customer_Master_ID__c,new set<string>{acc.RecordTypeId});
                       }
                       else if(mapGIdsToRecordTypes.containsKey(ld.NXP_Global_Customer_Master_ID__c)){
                           mapGIdsToRecordTypes.get(ld.NXP_Global_Customer_Master_ID__c).add(acc.RecordTypeId);
                       }                    
                       if(acc.RecordTypeId==CHILD_RECORD_TYPE){
                           if(!mapGIdsToAccount.containsKey(ld.NXP_Global_Customer_Master_ID__c)){
                               mapGIdsToAccount.put(ld.NXP_Global_Customer_Master_ID__c,acc); 
                           }
                       }
                       if(acc.RecordTypeId==PARENT_RECORD_TYPE){
                           if(!mapGIdsToParentAccount.containsKey(ld.NXP_Global_Customer_Master_ID__c)){
                               mapGIdsToParentAccount.put(ld.NXP_Global_Customer_Master_ID__c,acc); 
                           }
                       }                    
                   }
                   
                   if(mapGIdsToRecordTypes.get(ld.NXP_Global_Customer_Master_ID__c).contains(PARENT_RECORD_TYPE) &&
                      mapGIdsToParentAccount.containsKey(ld.NXP_Global_Customer_Master_ID__c)){
                          if(mapGIdsToParentAccount.get(ld.NXP_Global_Customer_Master_ID__c).recordTypeID==PARENT_RECORD_TYPE &&
                             mapGIdsToParentAccount.get(ld.NXP_Global_Customer_Master_ID__c).IsInactive__c== False){
                                 parentAccountIds.add(mapGIdsToParentAccount.get(ld.NXP_Global_Customer_Master_ID__c).Id); 
                             }                                        
                      }                
               }
            
            
            
        }
        // Parent Account Ids End
        list<Account> listAAChildAccounts=[Select id,Name,Parent.Id,country__c,OwnerId,IsInactive__c,state_province__c,
                                           city__c,NXP_GID__c,RecordTypeId,parent.NXP_GID__c,Customer_Category__c,
                                           BillingCountry,BillingState,BillingCity,CMD_Industry_Segment__c from Account where Parent.Id IN:parentAccountIds
                                           AND RecordTypeId=:CHILD_RECORD_TYPE and IsInactive__c=False 
                                           and (Customer_Category__c = 'Tier 1' OR Customer_Category__c = 'Tier 2'
                                                OR Customer_Category__c = 'Tier 3')];
        list<Account> listTMAAChildAccounts=[Select id,Name,Parent.Id,country__c,OwnerId,IsInactive__c,
                                             state_province__c,city__c,NXP_GID__c,RecordTypeId,parent.NXP_GID__c,Customer_Category__c,BillingCountry,BillingState,BillingCity,CMD_Industry_Segment__c from Account where Parent.Id IN:parentAccountIds
                                             AND RecordTypeId=:CHILD_RECORD_TYPE and IsInactive__c=False 
                                             and Customer_Category__c = 'Tier 4 - TMMA'];
        
        aaChildren = new Map<String,List<Account>>();
        tmmaChildren = new Map<String,List<Account>>();
        if(listAAChildAccounts != null){
            for(Account acc:listAAChildAccounts){
                if(!aaChildren.containsKey(acc.Parent.NXP_GID__c)){
                    aaChildren.put(acc.Parent.NXP_GID__c,new list<account>{acc});
                }
                else if(aaChildren.containsKey(acc.Parent.NXP_GID__c)){
                    aaChildren.get(acc.Parent.NXP_GID__c).add(acc);
                }            
            }
        }	
        if(listTMAAChildAccounts != null){
            for(Account acc:listTMAAChildAccounts){
                if(!tmmaChildren.containsKey(acc.Parent.NXP_GID__c)){
                    tmmaChildren.put(acc.Parent.NXP_GID__c,new list<account>{acc});
                }
                else if(tmmaChildren.containsKey(acc.Parent.NXP_GID__c)){
                    tmmaChildren.get(acc.Parent.NXP_GID__c).add(acc);
                }            
            }
        }
        
        
    }
    
    // Main method to assign Lead owners..
    
    public static void assignLeadOwners(List<Lead> unassignedLeads){
        fieldValueMapping(unassignedLeads);
        
        
        for(Lead ldrec:unassignedLeads){
            boolean ownerAssigned=false;
            if(mapGIdsToRecordTypes.get(ldrec.NXP_Global_Customer_Master_ID__c) != null){
                
                
                if(strLeadGIDs.contains(ldrec.NXP_Global_Customer_Master_ID__c) 
                   && mapGIdsToRecordTypes.get(ldrec.NXP_Global_Customer_Master_ID__c).contains(PARENT_RECORD_TYPE)){
                       
                       ownerAssigned = aaBasedAssignment(ldrec,aaChildren,aaException,mapGIdsToExceptionList);
                       if(ownerAssigned == false){
                           tmmaBasedAssignment(ldrec,tmmaChildren,tmmaException);
                       }
                   }
                
                else if(strLeadGIDs.contains(ldrec.NXP_Global_Customer_Master_ID__c) 
                        && mapGIdsToRecordTypes.get(ldrec.NXP_Global_Customer_Master_ID__c).contains(CHILD_RECORD_TYPE)
                        && !mapGIdsToParentAccount.containsKey(ldrec.NXP_Global_Customer_Master_ID__c)){
                            //logic if GID is child Account.
                            
                            Account a = mapGIdsToAccount.get(ldrec.NXP_Global_Customer_Master_ID__c);
                            if(a.IsInactive__c != true){
                                
                                ownerAssigned = aaChildBasedAssignment(ldrec,a,aaException,mapGIdsToExceptionList);
                                if(ownerAssigned == false){
                                    System.debug('enter tmmachild');
                                    tmmaChildBasedAssignment(ldrec,a,tmmaException);
                                }
                            }
                            else {
                                ldrec.RecordTypeId=ROM_LEAD_RECORD_TYPE;
                                ldrec.Account_GID_Match__c = '';
                                ldrec.Geo_Score__c = 0;
                                ldrec.Lead_Owner_Assignment__c='Lead Marked as ROM Leads as no match is found';
                                Updatefinalleads.put(ldrec.id,ldrec);
                            }
                            
                            
                        }
            }
            
        }
        Update Updatefinalleads.values();
    }
    // For Assigning Leads having AA Child Gid    
    Public Static boolean aaChildBasedAssignment(Lead ldrec, Account a,Map<String,Lead_Assignment_Exception_table__c> aaException,map<string,list<Lead_Assignment_Exception_table__c>> allaaExceptionList){
        Boolean Ownerassigned = false;
        Boolean ExceptionAsssigned =false;
        if(a.Customer_Category__c == 'Tier 1' || a.Customer_Category__c == 'Tier 2' || a.Customer_Category__c == 'Tier 3'){
            
            if(allaaExceptionList.containsKey(a.NXP_GID__c)){
                for(Lead_Assignment_Exception_table__c exep:allaaExceptionList.get(a.NXP_GID__c)){
                    
                    
                    if(exep.Account_GID__c == a.NXP_GID__c && (ldrec.Country == exep.Country__c || exep.Country__c == 'All Countries') 
                       && (ldrec.State == exep.State__c || exep.State__c == null) 
                       && (ldrec.City == exep.City__c || exep.City__c == null) && exep.Alternative_Lead_Owner__c != null){
                           ExceptionAsssigned = true;
                           Ownerassigned = true;
                           ldrec.Geo_Score__c = 0;
                           ldrec.OwnerId = exep.Alternative_Lead_Owner__c;
                           ldrec.RecordTypeId = AA_LEAD_RECORD_TYPE;
                           ldrec.Account_GID_Match__c = a.NXP_GID__c ;
                           ldrec.Lead_Owner_Assignment__c = 'Owner is Assigned based on AA Exception Alternative Lead Owner - Account Id : ' + a.Id;
                           
                       }
                    if(exep.Account_GID__c == a.NXP_GID__c && (ldrec.Country == exep.Country__c || exep.Country__c == 'All Countries') 
                       && (ldrec.State == exep.State__c || exep.State__c == null) 
                       && (ldrec.City == exep.City__c || exep.City__c == null) && exep.Alternative_Lead_Owner__c == null){
                           ExceptionAsssigned = true;
                           Ownerassigned = true;
                           ldrec.Geo_Score__c = 0;
                           ldrec.OwnerId = a.OwnerId;
                           ldrec.RecordTypeId = AA_LEAD_RECORD_TYPE;
                           ldrec.Account_GID_Match__c = a.NXP_GID__c ;
                           ldrec.Lead_Owner_Assignment__c = 'Owner is Assigned based on AA Exception Table - Account Id : ' + a.Id;
                           
                       }
                }
            }
            
            if(ExceptionAsssigned == false){
                
                integer score=geoMatch(ldrec,a);
                
                if(score == 10  && Ownerassigned == false){
                    Ownerassigned = true;
                    ldrec.Geo_Score__c = 10;
                    ldrec.Account_GID_Match__c = a.NXP_GID__c;
                    ldrec.OwnerId = a.OwnerId;
                    ldrec.RecordTypeId = AA_LEAD_RECORD_TYPE;
                    ldrec.Lead_Owner_Assignment__c = 'Owner is Assigned based on AA Account Geo Score - Account Id :' + a.Id;
                    
                }
                
                if(Score != 0  && Score != 10 &&  Score > ldrec.Geo_Score__c && Ownerassigned == false){
                    
                    //Ownerassigned = false;
                    ldrec.Geo_Score__c = Score;
                    ldrec.OwnerId = a.OwnerId;
                    ldrec.RecordTypeId = AA_LEAD_RECORD_TYPE;
                    ldrec.Account_GID_Match__c = a.NXP_GID__c;
                    ldrec.Lead_Owner_Assignment__c = 'Owner is Assigned based on AA Account Geo Score ' + a.Id ;
                    
                }
                
            }
        }
        //Updatefinalleads = new List<Lead>();
        Updatefinalleads.put(ldrec.id,ldrec);
        //Database.Update (ldrec,false);
        return Ownerassigned;
    }
    
    // For Assigning Leads having TMMA Child Gid
    Public Static Void tmmaChildBasedAssignment(Lead ldrec, Account a ,Map<String,Lead_Assignment_Exception_table__c> tmmaException){
        Boolean Ownerassigned = false;
        
        if(a.Customer_Category__c == 'Tier 4 - TMMA'){
            if(tmmaException.containsKey(a.NXP_GID__c)){
                Ownerassigned = true;
                ldrec.Geo_Score__c = 0;
                ldrec.OwnerId = a.OwnerId;
                ldrec.RecordTypeId = TMMA_LEAD_RECORD_TYPE;
                ldrec.Account_GID_Match__c = a.NXP_GID__c;
                ldrec.Lead_Owner_Assignment__c = 'Owner is Assigned based on TMMA Exception Table - Account Id : ' + a.Id;
                
            }
            else{
                integer score=geoMatch(ldrec,a);
                if(score == 10   && !tmmaException.containsKey(a.NXP_GID__c)){
                    
                    Ownerassigned = true;
                    ldrec.Geo_Score__c = 10;
                    ldrec.OwnerId = a.OwnerId;
                    ldrec.RecordTypeId = TMMA_LEAD_RECORD_TYPE;
                    ldrec.Account_GID_Match__c = a.NXP_GID__c;
                    ldrec.Lead_Owner_Assignment__c = 'Owner is Assigned based on TMMA Account Geo Score - Account Id : ' + a.Id ;
                }
                if(Score != 0 && Score > ldrec.Geo_Score__c && Score != 10 && Ownerassigned == false){
                    
                    Ownerassigned = true;
                    ldrec.Geo_Score__c = Score;
                    ldrec.OwnerId = a.OwnerId;
                    ldrec.RecordTypeId = TMMA_LEAD_RECORD_TYPE;
                    ldrec.Account_GID_Match__c = a.NXP_GID__c;
                    ldrec.Lead_Owner_Assignment__c = 'Owner is Assigned based on TMMA Account Geo Score - Account Id : ' + a.Id  ;
                    
                }
                
                
            }
            
        }
        
        if(ldrec.Geo_Score__c == 0 && Ownerassigned == false){
            
            ldrec.RecordTypeId=ROM_LEAD_RECORD_TYPE;
            ldrec.Account_GID_Match__c = '';
            ldrec.Geo_Score__c = 0;
            ldrec.Lead_Owner_Assignment__c='Lead Marked as ROM Leads as no match is found';
            
        }
        
        Updatefinalleads.put(ldrec.id,ldrec);
        
        
        
    }
    
    // For Assigning Leads having AA Parent Gid
    public static boolean aaBasedAssignment(Lead ldrec,Map<String,List<Account>> aaChildren,Map<String,Lead_Assignment_Exception_table__c> aaException,map<string,list<Lead_Assignment_Exception_table__c>> allaaExceptionList) {
        Boolean Ownerassigned = false;
        
        Boolean ExceptionAsssigned =false;
        
        if(aaChildren.get(ldrec.NXP_Global_Customer_Master_ID__c) != null){
            
            
            for(Account aaAcc : aaChildren.get(ldrec.NXP_Global_Customer_Master_ID__c)){
                
                if(allaaExceptionList.containsKey(aaAcc.NXP_GID__c)){
                    
                    for(Lead_Assignment_Exception_table__c exep:allaaExceptionList.get(aaAcc.NXP_GID__c)){
                        
                        if(exep.Account_GID__c == aaAcc.NXP_GID__c && (ldrec.Country == exep.Country__c || exep.Country__c == 'All Countries')
                           && (ldrec.State == exep.State__c || exep.State__c == null) 
                           && (ldrec.City == exep.City__c || exep.City__c == null) && exep.Alternative_Lead_Owner__c != null) {
                               
                               ExceptionAsssigned = true;
                               Ownerassigned = true;
                               ldrec.Geo_Score__c = 0;
                               ldrec.Account_GID_Match__c = '';
                               ldrec.OwnerId = exep.Alternative_Lead_Owner__c;
                               ldrec.RecordTypeId = AA_LEAD_RECORD_TYPE;
                               ldrec.Account_GID_Match__c = aaAcc.NXP_GID__c ;
                               ldrec.Lead_Owner_Assignment__c = 'Owner is Assigned based on AA Exception Alternative Lead Owner - Account Id : ' + aaAcc.Id ;
                               break;
                           }
                        if(exep.Account_GID__c == aaAcc.NXP_GID__c && (ldrec.Country == exep.Country__c || exep.Country__c == 'All Countries') 
                           && (ldrec.State == exep.State__c || exep.State__c == null) 
                           && (ldrec.City == exep.City__c || exep.City__c == null) && exep.Alternative_Lead_Owner__c == null) {
                               
                               ExceptionAsssigned = true;
                               Ownerassigned = true;
                               ldrec.Geo_Score__c = 0;
                               ldrec.Account_GID_Match__c = '';
                               ldrec.OwnerId = aaAcc.OwnerId;
                               ldrec.RecordTypeId = AA_LEAD_RECORD_TYPE;
                               ldrec.Account_GID_Match__c = aaAcc.NXP_GID__c ;
                               ldrec.Lead_Owner_Assignment__c = 'Owner is Assigned based on AA Exception Table Account Id : ' + aaAcc.Id ;
                               break;
                           }
                    }
                }
                
                /*
if(ExceptionAsssigned == true){
break;
}
*/
                
                if(ExceptionAsssigned == false){
                    
                    integer score=geoMatch(ldrec,aaAcc);
                    
                    
                    if(score == 10  && Ownerassigned == false){
                        Ownerassigned = true;
                        ldrec.Geo_Score__c = 10;
                        ldrec.Account_GID_Match__c = aaAcc.NXP_GID__c;
                        ldrec.OwnerId = aaAcc.OwnerId;
                        ldrec.RecordTypeId = AA_LEAD_RECORD_TYPE;
                        ldrec.Lead_Owner_Assignment__c = 'Owner is Assigned based on AA Account Geo Score - Account Id :' + aaAcc.Id;
                        
                    }
                    
                    if(Score != 0 && Score > ldrec.Geo_Score__c  && Score != 10 && Ownerassigned == false){
                        System.debug('enrer score');
                        //Ownerassigned = false;
                        ldrec.Geo_Score__c = Score;
                        ldrec.OwnerId = aaAcc.OwnerId;
                        ldrec.RecordTypeId = AA_LEAD_RECORD_TYPE;
                        ldrec.Account_GID_Match__c = aaAcc.NXP_GID__c;
                        ldrec.Lead_Owner_Assignment__c = 'Owner is Assigned based on AA Account Geo Score ' + aaAcc.Id ;
                        
                    }
                    
                }
            }
        }
        
        Updatefinalleads.put(ldrec.id,ldrec);
        
        return Ownerassigned;
        
    }
    // For Assigning Leads having TMMA Parent Gid   
    public static Void tmmaBasedAssignment(Lead ldrec,Map<String,List<Account>> tmmaChildren,Map<String,Lead_Assignment_Exception_table__c> tmmaException){
        Boolean Ownerassigned = false;
        if(tmmaChildren.get(ldrec.NXP_Global_Customer_Master_ID__c) != null){
            for(Account aaAcc : tmmaChildren.get(ldrec.NXP_Global_Customer_Master_ID__c)){
                if(tmmaException.containsKey(aaAcc.NXP_GID__c)){
                    Ownerassigned = true;
                    System.debug('inddf 1');
                    ldrec.Geo_Score__c = 0;
                    ldrec.Account_GID_Match__c = '';
                    ldrec.OwnerId = aaAcc.OwnerId;
                    ldrec.RecordTypeId = TMMA_LEAD_RECORD_TYPE;
                    ldrec.Account_GID_Match__c = aaAcc.NXP_GID__c;
                    ldrec.Lead_Owner_Assignment__c = 'Owner is Assigned based on TMMA Exception Table Account Id : ' + aaAcc.Id;
                    break;
                }
                
                else {
                    integer score=geoMatch(ldrec,aaAcc);
                    if(score == 10   && !tmmaException.containsKey(aaAcc.NXP_GID__c)){
                        System.debug('inddf 2');
                        Ownerassigned = true;
                        ldrec.Geo_Score__c = 10;
                        ldrec.OwnerId = aaAcc.OwnerId;
                        ldrec.RecordTypeId = TMMA_LEAD_RECORD_TYPE;
                        ldrec.Account_GID_Match__c = aaAcc.NXP_GID__c;
                        ldrec.Lead_Owner_Assignment__c = 'Owner is Assigned based on TMMA Account Geo Score - Account Id : ' + aaAcc.Id ;
                        
                    }
                    if(Score != 0 && Score > ldrec.Geo_Score__c && Score != 10){
                        
                        Ownerassigned = true;
                        ldrec.Geo_Score__c = Score;
                        ldrec.OwnerId = aaAcc.OwnerId;
                        ldrec.RecordTypeId = TMMA_LEAD_RECORD_TYPE;
                        ldrec.Account_GID_Match__c = aaAcc.NXP_GID__c;
                        ldrec.Lead_Owner_Assignment__c = 'Owner is Assigned based on TMMA Account Geo Score - Account Id : ' + aaAcc.Id  ;
                        
                    }
                }
            }
        }
        
        if(ldrec.Geo_Score__c == 0 && Ownerassigned == false){
            System.debug('Enter ROm zero');
            
            ldrec.RecordTypeId=ROM_LEAD_RECORD_TYPE;
            ldrec.Account_GID_Match__c = '';
            ldrec.Geo_Score__c = 0;
            ldrec.Lead_Owner_Assignment__c='Lead Marked as ROM Leads as no match is found';
            
        }
        
        Updatefinalleads.put(ldrec.id,ldrec);
        
        
    }
    
    //call geo specific geoscorer based on lead country
    
    public  static Integer  geoMatch(Lead l,Account a){
        
        Integer Score;
        if (l.Country == 'USA' || l.Country == 'Canada'){
            
            score = geoMatchUSACAN(l,a);
        }
        if(l.Country == 'China'){
            
            score = geoMatchCHN(l,a);
        }
        if(l.country != 'USA' && l.Country != 'Canada' && l.Country != 'China' ){
            
            score = geoMatchOther(l,a);
        }
        return score;
        
    }
    
    // Geo Match Logic if Lead Country is USA/Canada
    public static integer geoMatchUSACAN(Lead l,Account a){
        string ldCountry;  
        string ldState;
        string ldCity;
        string ldCBG;
        string accCountry;  
        string accState;
        string accCity;
        string accCBG;
        Integer geoscore;
        
        if(l.country!=null){
            ldCountry=l.country.toUpperCase();
        }
        if(l.state!=null){ 
            ldState=l.state.toUpperCase();
            
        }
        if(l.city!=null){
            ldCity=l.city.toUpperCase();
            
        }
        if(l.CBG__c!=null){
            ldCBG=l.CBG__c.toUpperCase();
            
        }
        
        if(a.Country__c   != null){
            accCountry=a.Country__c.toUpperCase();
        }
        if(a.State_Province__c !=null){ 
            accState=a.State_Province__c.toUpperCase();
            
        }
        if(a.City__c != null){
            accCity=a.City__c.toUpperCase();
            
        }
        if(a.CMD_Industry_Segment__c != null){
            accCBG = a.CMD_Industry_Segment__c.toUpperCase();
            
        }
        
        if(ldCountry == accCountry && ldState == accState && ldCity == accCity && ldCBG == accCBG){
            geoscore = 10;
        }
        
        if(ldCountry == accCountry && ldState == accState && ldCity != accCity && ldCBG == accCBG){
            
            geoscore =  8;
        }
        if(ldCountry == accCountry && ldState == accState && ldCity == accCity && ldCBG != accCBG){
            
            geoscore =  6;
        }
        if(ldCountry == accCountry && ldState == accState && ldCity != accCity && ldCBG != accCBG){
            
            geoscore =  4;
        }
        System.debug('geoscoregeoscore1d' + geoscore);
        
        return geoscore;
        
        
    }
    
    // Geo Match Logic if Lead Country is China
    public static integer geoMatchCHN(Lead l,Account a){
        string ldCountry;  
        string ldState;
        string ldCity;
        string ldCBG;
        string accCountry;  
        string accState;
        string accCity;
        string accCBG;
        Integer geoscore;
        if(l.country!=null){
            ldCountry=l.country.toUpperCase();
        }
        if(l.state!=null){ 
            ldState=l.state.toUpperCase();
            
        }
        if(l.city!=null){
            ldCity=l.city.toUpperCase();
            
        }
        if(l.CBG__c!=null){
            ldCBG=l.CBG__c.toUpperCase();
            
        }
        
        if(a.Country__c   != null){
            accCountry=a.Country__c.toUpperCase();
        }
        if(a.State_Province__c !=null){ 
            accState=a.State_Province__c.toUpperCase();
            
        }
        if(a.City__c != null){
            accCity=a.City__c.toUpperCase();
            
        }
        if(a.CMD_Industry_Segment__c != null){
            accCBG = a.CMD_Industry_Segment__c.toUpperCase();
            
        }
        
        if(ldCountry == accCountry &&  ldState == accState && ldCity == accCity && ldCBG == accCBG){
            geoscore = 10;
            
        }
        
        if(ldCountry == accCountry && ldCity == accCity &&  ldState != accState && ldCBG == accCBG){
            geoscore =  9;
            
        }
        if(ldCountry == accCountry && ldState == accState  && ldCity != accCity && ldCBG == accCBG){
            geoscore =  8;
            
        }
        if(ldCountry == accCountry && ldState == accState  && ldCity == accCity && ldCBG != accCBG){
            geoscore =  7;
            
        }
        if(ldCountry == accCountry && ldState != accState  && ldCity == accCity && ldCBG != accCBG){
            geoscore =  6;
            
        }
        if(ldCountry == accCountry && ldState == accState  && ldCity != accCity && ldCBG != accCBG){
            geoscore =  5;
            
        }
        
        return geoscore;
        
    }
    
    // Geo Match Logic if Lead Country is Other Countries
    
    public static integer geoMatchOther(Lead l,Account a){
        string ldCountry;  
        string ldState;
        string ldCity;
        string ldCBG;
        string accCountry;  
        string accState;
        string accCity;
        string accCBG;
        Integer geoscore;
        if(l.country!=null){
            ldCountry=l.country.toUpperCase();
        }
        if(l.state!=null){ 
            ldState=l.state.toUpperCase();
            
        }
        if(l.city!=null){
            ldCity=l.city.toUpperCase();
            
        }
        if(l.CBG__c!=null){
            ldCBG=l.CBG__c.toUpperCase();
            
        }
        
        if(a.Country__c   != null){
            accCountry=a.Country__c.toUpperCase();
        }
        if(a.State_Province__c !=null){ 
            accState=a.State_Province__c.toUpperCase();
            
        }
        if(a.City__c != null){
            accCity=a.City__c.toUpperCase();
            
        }
        if(a.CMD_Industry_Segment__c != null){
            accCBG = a.CMD_Industry_Segment__c.toUpperCase();
            
        }
        
        if(ldCountry == accCountry &&  ldState == accState && ldCity == accCity && ldCBG == accCBG){
            geoscore = 10;
        }
        
        if(ldCountry == accCountry && ldCity == accCity &&  ldState != accState && ldCBG == accCBG){
            geoscore =  9;
        }
        if(ldCountry == accCountry && ldState == accState && ldCity != accCity && ldCBG == accCBG){
            geoscore =  8;
        }
        if(ldCountry == accCountry &&  ldState != accState && ldCity != accCity && ldCBG == accCBG){
            geoscore =  7;
        }
        if(ldCountry == accCountry &&  ldState == accState && ldCity == accCity && ldCBG != accCBG){
            geoscore =  6;
        }
        if(ldCountry == accCountry &&  ldState != accState && ldCity == accCity && ldCBG != accCBG){
            geoscore =  5;
        }
        if(ldCountry == accCountry &&  ldState == accState && ldCity != accCity && ldCBG != accCBG){
            geoscore =  4;
        }
        if(ldCountry == accCountry &&  ldState != accState && ldCity != accCity && ldCBG != accCBG){
            geoscore =  3;
        }
        
        
        
        return geoscore;
        
    }
    
}