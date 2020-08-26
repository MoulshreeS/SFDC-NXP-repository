global class Updateobject implements Database.Batchable<sObject>{
    
    global final String Query;
    global final String Entity;
    global final String Field;
    global final String Value;
    global final Datetime dtt;
    
  
    global Updateobject(String q, String e, String f, String v,datetime dt){
        
        Query=q; Entity=e; Field=f;Value=v;dtt=dt;
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC){
     
 		String formattedDt = dtt.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');      
        String query1 = 'select id from ' + Entity +  ' '  +  Query + ' ' + 'and SystemModstamp > ' + formattedDt;
		//sYSTEM.DEBUG('datee' + formattedDt);
        //system.debug('query1'+query1);
        return Database.getQueryLocator(query1); 

    }
    
    global void execute(Database.BatchableContext BC, List<sObject> scope){
        //system.debug('Inside execute1'+scope);
        if(scope != null){
        //system.debug('Inside execute');
        for(sobject s : scope){
            s.put(Field,Value); 
        }
        update scope;
            }
    }
    
    global void finish(Database.BatchableContext BC){
    }
}