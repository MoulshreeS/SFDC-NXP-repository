public class Disticontactroles {
    
    public static void Checkmaincontactroleinotherbranches(List<Disti_Branch_Contact_Role__c> dbc){
        Map<Id,List<String>> contactandcontactrole = new Map<Id,List<String>>();
        
        List<Disti_Branch_Contact_Role__c> dd = [select id,Disti_Branch__c,Contact_Role__c,Contact__c from Disti_Branch_Contact_Role__c];
        for(Disti_Branch_Contact_Role__c bc : dd){
            if(!contactandcontactrole.containsKey(bc.Contact__c )){
                contactandcontactrole.put(bc.Contact__c ,new list<string>{bc.Contact_Role__c});
            }
            else if(contactandcontactrole.containsKey(bc.Contact__c )){
                contactandcontactrole.get(bc.Contact__c).add(bc.Contact_Role__c);
            }     
        }
        
        
        
        for(Disti_Branch_Contact_Role__c bc : dbc){
            if(contactandcontactrole.containskey(bc.Contact__c )){
                if(contactandcontactrole.get(bc.Contact__c).contains('Main Distributor Contact') 
                   && bc.Contact_Role__c  == 'Main Distributor Contact'){
                       bc.adderror('The below contact is already a Main Distributor contact in other branch');
                   }
            }
            
        }
    }
    
    public static void  contactrolevalidations(List<Disti_Branch_Contact_Role__c> dbc){
        List<Id> Branchids = new List<Id>();
        Map<Id,List<String>> Branchandcontactrole = new Map<Id,List<String>>();
        for(Disti_Branch_Contact_Role__c db : dbc){
            Branchids.add(db.Disti_Branch__c);
        }
        List<Disti_Branch_Contact_Role__c> Distributorbranches = [select id,Disti_Branch__c,Contact_Role__c,Contact__c from Disti_Branch_Contact_Role__c
                                                                  where Disti_Branch__c in: Branchids];
        
        for(Disti_Branch_Contact_Role__c dbcr : Distributorbranches){
            if(!Branchandcontactrole.containsKey(dbcr.Disti_Branch__c )){
                Branchandcontactrole.put(dbcr.Disti_Branch__c ,new list<string>{dbcr.Contact_Role__c});
            }
            else if(Branchandcontactrole.containsKey(dbcr.Disti_Branch__c)){
                Branchandcontactrole.get(dbcr.Disti_Branch__c ).add(dbcr.Contact_Role__c);
            }     
        }
        /*
for(Disti_Branch_Contact_Role__c bc : dbc){
if(Branchandcontactrole.containskey(bc.Disti_Branch__c)){
if(Branchandcontactrole.get(bc.Disti_Branch__c).contains('Branch Executive') 
&& bc.Contact_Role__c  == 'Branch Executive'){
bc.adderror('There is already a Executive contact in this branch');
}
}
}
*/
        
        for(Disti_Branch_Contact_Role__c pbc : dbc){
            if(Branchandcontactrole.containskey(pbc.Disti_Branch__c)){
                if(Branchandcontactrole.get(pbc.Disti_Branch__c).contains('Main Distributor Contact') 
                   && pbc.Contact_Role__c  == 'Main Distributor Contact'){
                       pbc.adderror('There is already a Main Distributor Contact in this branch');
                   }
            }
            
        }
        
        
    }
    
    
    
    public static void duplicatecontactperbranch(List<Disti_Branch_Contact_Role__c> dbc){
        // check the current contact is there in list of contacts
        
        List<Id> Branchid = new List<Id>();
        Map<Id,List<String>> Branchandcontactlist = new Map<Id,List<String>>();
        
        for(Disti_Branch_Contact_Role__c db : dbc){
            Branchid.add(db.Disti_Branch__c);
        }
        List<Disti_Branch_Contact_Role__c> dd = [select id,Disti_Branch__c,Contact_Role__c,Contact__c from Disti_Branch_Contact_Role__c
                                                 where Disti_Branch__c in: Branchid];
        
        for(Disti_Branch_Contact_Role__c bc : dd){
            if(!Branchandcontactlist.containsKey(bc.Disti_Branch__c )){
                Branchandcontactlist.put(bc.Disti_Branch__c ,new list<String>{bc.Contact__c});
            }
            else if(Branchandcontactlist.containsKey(bc.Disti_Branch__c )){
                Branchandcontactlist.get(bc.Disti_Branch__c ).add(bc.Contact__c);
            }     
        }
        System.debug('Main Conatct' + Branchandcontactlist);
        for(Disti_Branch_Contact_Role__c bc : dbc){
            if(Branchandcontactlist.containskey(bc.Disti_Branch__c)){
                if(Branchandcontactlist.get(bc.Disti_Branch__c).contains(bc.Contact__c)){
                    bc.adderror('Duplicate Contact are not allowed in a branch.');
                }
            }
        }
        
    }
    
    @future
    
    public static void updateleadbranchnames(List<Id> dbc){
        Map<Id,String> mainDistiConMap = new Map<Id,String>();
        Map<Id,String> otherRolesMap = new Map<Id,String>();
        
        String distiBranchName = '';
        List<Disti_Branch_Contact_Role__c> distiConRoleList = [SELECT Contact_Role__c,Contact__c,Disti_Branch__r.name,Id FROM Disti_Branch_Contact_Role__c where Contact__c in :dbc];
        for(Disti_Branch_Contact_Role__c distiC: distiConRoleList)
        {
            if(distiC.Contact_Role__c == 'Main Distributor Contact' && distiC.Disti_Branch__c != null){
                MainDistiConMap.put(distiC.contact__c,distiC.Disti_Branch__r.Name);
            }
            if(distiC.Contact_Role__c != 'Main Distributor Contact' && distiC.Disti_Branch__c != null){
                
                
                
                if(!otherRolesMap.containsKey(distiC.contact__c)){
                    otherRolesMap.put(distiC.contact__c,distiC.Disti_Branch__r.Name);
                }
                else if(otherRolesMap.containsKey(distiC.contact__c)){
                    distiBranchName = otherRolesMap.get(distiC.contact__c) + ' ; ' + distiC.Disti_Branch__r.Name ;
                    // distiBranchName += otherRolesMap.get(distiC.contact__c) + ' ; ' + distiC.Disti_Branch__r.Name ;
                    
                    otherRolesMap.put(distiC.contact__c,distiBranchName);
                }  
                
            }    
            
        }
        List<lead> leadList = [SELECT name,Distributor_Contact__c, Disti_Branch_Name__c from Lead where Distributor_Contact__c in :dbc];
        
        for(Lead ld: leadList)
        {
            if(MainDistiConMap.containskey(ld.Distributor_Contact__c)){
                ld.Disti_Branch_Name__c = mainDistiConMap.get(ld.Distributor_Contact__c);
                
            }
            else if(otherRolesMap.containskey(ld.Distributor_Contact__c)){
                ld.Disti_Branch_Name__c = otherRolesMap.get(ld.Distributor_Contact__c);  
            }
            else{
                ld.Disti_Branch_Name__c = '';
            }
            
        }
        Database.Update(leadList,false);
        
    }
    
}