/******************************************************************************
@Created By :       Nisha Agrawal
@Created Date:      30 Sep 2013
@Description:       To generate Funloc record for SAP CMD 
****************************************************************************
@Modified By :     Scarlett Kang
@Modified Date :   31 Mar 2015
@Description :     Upsert SAP CMD Request records after update or insert
********************************************************************************/
trigger SAP_CMD_BeforeTrigger on SAP_CMD__c (before insert, before update) 
{
   
   if(trigger.isBefore && trigger.isInsert){
       SapCmdTrigger.generateFunLocAndCopyCustomerAddress(Trigger.new);
   }

   list<SAP_CMD__c> lstSapCmd=new List<SAP_CMD__c>();
   for(SAP_CMD__c sapcmd:trigger.new)
   {
       if(sapcmd.CMD_Request_Id__c !=null && sapcmd.CMD_Request_Id__c != '')
       {
           lstSapCmd.add(sapcmd);
       }      
   } 
   if(lstSapCmd.size() >0)
    {
        SAP_CMD_Request_Trigger.syncSAP_CMD_Approval_Fields(lstSapCmd);
    } 
    
 
  if(trigger.isBefore && trigger.isInsert){
 
     list<SAP_CMD__c> lstSapCmdInsert = new List<SAP_CMD__c>();
 
     for(SAP_CMD__c objSapCmd :trigger.new){ 
           if(objSapCmd.Sales_Organisation__c != null && objSapCmd.Customer_Funloc_Number__c !=null){
               lstSapCmdInsert.add(objSapCmd);
             }
           }
       if(lstSapCmdInsert.size() >0)
            {
               SAP_CMD_Request_Trigger.generateSAPCMDName(trigger.new);
            }
   }     
  
  if(trigger.isBefore && trigger.isupdate){
  
   list<SAP_CMD__c> lstSapCmdUpdate = new List<SAP_CMD__c>();
   for(SAP_CMD__c objSapCmd:trigger.new)
   {
     SAP_CMD__c oldobjSAPCMD = Trigger.oldMap.get(objSapCmd.Id);
     
     if((objSapCmd.Sales_Organisation__c != null &&  objSapCmd.Customer_Funloc_Number__c != null) && (objSapCmd.Sales_Organisation__c != oldobjSAPCMD.Sales_Organisation__c || objSapCmd.Customer_Funloc_Number__c != oldobjSAPCMD.Customer_Funloc_Number__c) ) {
         lstSapCmdUpdate.add(objSapCmd);
     }
     
     else if(objSapCmd.Name != oldobjSAPCMD.Name && objSapCmd.Sales_Organisation__c == oldobjSAPCMD.Sales_Organisation__c || objSapCmd.Customer_Funloc_Number__c == oldobjSAPCMD.Customer_Funloc_Number__c){
         objSapCmd.Name = oldobjSAPCMD.Name ;
     }
   }
    
    if(lstSapCmdUpdate.size() >0)
       {
           SAP_CMD_Request_Trigger.generateSAPCMDName(trigger.new);
       }
    }
  }