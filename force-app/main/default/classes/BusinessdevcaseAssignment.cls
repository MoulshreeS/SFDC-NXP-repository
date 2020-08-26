/*************************************************************************
@Created By:     Manikanta
@Description:    To Assign owners for Business Development Cases.
**************************************************************************/

global class BusinessdevcaseAssignment implements Database.Batchable<Case>,Database.Stateful,Schedulable {
    global List<Id> nonbusinessdevelopmentgroupmembers = new List<Id>();
    
    global Iterable<Case> start(Database.BatchableContext BC) {
        DateTime dt = System.now().addHours(-48);
        List<Case> cases = new List<Case>([SELECT OwnerId,subject FROM Case where Assigned_to__c = null 
                                           and recordtype.name = 'Business Development' 
                                           and owner.name = 'Business Development' and createddate > :dt]);
        //System.debug('lds' + lds);
        
        return cases;
        
    }
    /*
global Database.QueryLocator start(Database.BatchableContext BC) {
String query = 'SELECT OwnerId,subject FROM Case where Assigned_to__c = null and recordtype.name = \'Business Development\' and owner.name = \'Business Development\' ' ;
//DateTime dt = System.now().addHours(-2);
//createddate <= :dt ;

return Database.getQueryLocator(query);
}

*/
    
    global void execute(SchedulableContext sc){
        Database.executeBatch(this);
    }
    
    global void execute(Database.BatchableContext BC, List<case> caseList) {
        
        
        List<Groupmember> Businessdevelopmentgroupmembers = [select id,group.name,UserOrGroupId from  GroupMember 
                                                             WHERE  Group.Type = 'Queue' AND Group.Name = 'Business Development'];
        set<Id> bdusers = new set<Id>();
        if(Businessdevelopmentgroupmembers.size() > 0 && Businessdevelopmentgroupmembers != null){
            
            for(Groupmember gm : Businessdevelopmentgroupmembers){
                bdusers.add(gm.UserOrGroupId);          
            }
        }
        string subject = '';
        string Idleft = '';
        
        List<case> casList = new List<case>();
        for(case cas: caseList){
            if(cas.subject != null && cas.Subject != ''){
                subject = cas.subject.trim();
                Pattern p = Pattern.compile('\\{([^}]*)\\}');
                Matcher m = p.matcher(subject);
                String stringextract;
                string Idextract;
                if (m.find()) 
                {
                    stringextract = m.group(1); 
                }
                if(stringextract != null && stringextract != ''){
                    string  stringextracttrim = stringextract.replaceAll('\\s+', '');
                    string  stringextracttrimupper = stringextracttrim.toUpperCase();
                    
                    if(stringextracttrimupper.contains('QUEUEID') || stringextracttrimupper.contains('USERID')){
                        
                        Idextract = stringextracttrim.right(18);
                        Idleft = Idextract.left(3);
                        
                        if(Idleft == '00G'){
                            cas.ownerId = Idextract; 
                            casList.add(cas);  
                        }
                        
                        if(Idleft == '005' && bdusers.contains(Idextract)){
                            
                            cas.Assigned_to__c = Idextract; 
                            casList.add(cas); 
                        }
                        
                        if(Idleft == '005' && !bdusers.contains(Idextract)){
                            cas.Assigned_to__c = Idextract; 
                            nonbusinessdevelopmentgroupmembers.add(Idextract);
                            casList.add(cas);
                            
                        }
                        
                    }
                }
            } 
        }
        Database.update(casList,false);
    }
    global void finish(Database.BatchableContext BC) {
        // execute any post-processing operations
        Group g = [select Id from Group where Name='Business Development' AND Type = 'Queue' limit 1];      
        if(nonbusinessdevelopmentgroupmembers != null){
            List<User> uu = [select id from user where id in :nonbusinessdevelopmentgroupmembers];
            List<GroupMember> gm = new List<GroupMember>();
            for(User u : uu ){
                GroupMember member = new GroupMember();
                member.UserOrGroupId = u.id;
                member.GroupId = g.Id;
                gm.add(member);                
            }
            Database.insert(gm,false);
        }
    }
}