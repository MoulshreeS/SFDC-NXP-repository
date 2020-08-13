/*******************************************************************
Name           :    Attachment_afterInsertDelete
Created By     :    Jewelslyn Shama
Date           :    13 July 2015
Description    :    This Trigger is to count the number of Attachments related to an Opportunity
-------------------------------------------------------------------------
Modified By    :    Gunjan
Date           :    9th Oct 2019
Description    :    Added AttachmentHelper class methods . 
-------------------------------------------------------------------------
Modified By    :    Wayne
Date           :    25th Oct 2019
Description    :    Comment out numAtts__c update operation since attachment functionality will retired .
********************************************************************/

trigger AttachmentTrigger on Attachment (after insert, after Update, after Delete, after unDelete) 
{
    Set<Id> opptyIds = new Set<Id>();
    List<Opportunity> listOpp = new List<Opportunity>();
    map<id,List<Attachment>> mapOppAttList=new map<id,List<Attachment>>();
    map<id,List<Attachment>> mapOppAttDelList=new map<id,List<Attachment>>();
    
    if(Trigger.isafter){
        if(trigger.isDelete)
        {   
            // Calling Method to delete files from TS Support Cases whenever attachment get deleted
            //Method needs to be removed after New Case Portal GoLive
            AttachmentHelper.deleteFileOnDeletionOfAttachment(Trigger.old);
            /*
            for(Attachment att:trigger.old)
            {
                if(string.isNotBlank(att.parentId))
                {
                    string pId= att.parentId;
                    if(pId.startsWith('006'))
                    {
                        if(!mapOppAttDelList.containskey(pId))
                        {
                            mapOppAttDelList.put(pId,new list<Attachment>());
                        }                
                        mapOppAttDelList.get(pId).add(att);
                        opptyIds.add(att.parentId); 
                    }
                }        
            }
            */
        }
        if(Trigger.isInsert){
            // Calling Method to copy attachment to files for TS Support Cases 
            //Method needs to be removed after New Case Portal GoLive
            AttachmentHelper.copyAttchmentToFileObject(Trigger.New);
        }
        /*
        if(Trigger.isunDelete || Trigger.isinsert || Trigger.isUpdate)
        {   
            for(Attachment att:trigger.new)
            {
                if(string.isNotBlank(att.parentId))
                {
                    string pId=att.parentId;
                    if(pId.startsWith('006'))
                    {
                        if(!mapOppAttList.containskey(pId))
                        {                    
                            mapOppAttList.put(pId,new list<Attachment>());                    
                        }                               
                        mapOppAttList.get(pId).add(att); 
                        opptyIds.add(pId); 
                    }
                }
            }
        }  
        if(opptyIds.size()>0)
        {
            listOpp=[Select id,numAtts__c from opportunity where Id IN:opptyIds];        
            for(Opportunity opp:listOpp)
            {
                if(mapOppAttList.containskey(opp.Id))
                {
                    opp.numAtts__c=opp.numAtts__c+mapOppAttList.get(opp.Id).size();
                }
                if(mapOppAttDelList.containskey(opp.Id))
                {               
                    opp.numAtts__c=opp.numAtts__c-mapOppAttDelList.get(opp.Id).size();
                }
            }                    
            update listOpp;
        } 
        */
    }
    
}