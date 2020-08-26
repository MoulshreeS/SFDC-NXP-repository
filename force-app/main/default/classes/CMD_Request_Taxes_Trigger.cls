/*------------------------------------------------------------------------------------------------------------------
 * Created By   : Baji
 * Created Date : 05 Feb,2019
 * Description   : SFDC-2260 - To validate taxes on CMD Request & SAP CMD and to send tax changes for Fiscal team's approval.
 ------------------------------------------------------------------------------------------------------------------
 *Modified By : Naveen
 *Modified Date : 03/28/2019
 *Description : SFDC-2647 - As CMD Officer, Due to Process Change, I want able to change the SAP CMD Status to "Approved"
------------------------------------------------------------------------------------------------------------------*/
public class CMD_Request_Taxes_Trigger{
  
    private static String TYPE_SAP_Funloc_Edit_Request = 'SAP_Funloc_Edit_Request';
    private static String TYPE_SAP_New_Funloc_Request = 'SAP_New_Funloc_Request';
    
    private static RecordType SAP_Funloc_Edit_Request;
    private static RecordType SAP_New_Funloc_Request;
    
    private static String TYPE_System_Admin = 'System Administrator';
    private static String TYPE_CMD_Officer = 'NXP CMD Officer';
    private static String TYPE_Standard_User = 'TS Standard User - API Enabled';
    
    private static Profile System_Administrator;
    private static Profile NXP_CMD_Officer;
    private static profile TS_Standard_User;
    
    private static void fetchCMDRecordType(){
    
        if(SAP_Funloc_Edit_Request == null || SAP_New_Funloc_Request == null){
        for(RecordType objRecType : [SELECT Id, DeveloperName
                             FROM   RecordType
                             WHERE  IsActive = TRUE 
                             AND (SobjectType = 'CMD_Request__c' 
                                  AND (DeveloperName =: TYPE_SAP_Funloc_Edit_Request OR DeveloperName =: TYPE_SAP_New_Funloc_Request)
                                 )
                              ])
        {
            if(objRecType.DeveloperName == TYPE_SAP_Funloc_Edit_Request)
                SAP_Funloc_Edit_Request = objRecType;
            if(objRecType.DeveloperName == TYPE_SAP_New_Funloc_Request)
                SAP_New_Funloc_Request = objRecType;
        }
       }
    }
    
    private static void fetchUserProifleId(){
    
     if(System_Administrator == null || NXP_CMD_Officer == null || TS_Standard_User == null){
        for(Profile objProfile : [SELECT Id, Name
                                  FROM  Profile
                                  WHERE Name =: TYPE_System_Admin OR Name =: TYPE_CMD_Officer OR Name =: TYPE_Standard_User])
        {
            if(objProfile.Name == TYPE_System_Admin)
                System_Administrator = objProfile;
            if(objProfile.Name == TYPE_CMD_Officer)
                NXP_CMD_Officer = objProfile;
            if(objProfile.Name == TYPE_Standard_User)
                TS_Standard_User = objProfile;
        }
       }
    }
    
    Public static void validationOfCTCTableonCMDRequest( list<Tax_Classification__c> lstReqTaxes) { 
     
          fetchCMDRecordType();
          set<string> setCmdReqs = new set<string>();
          set<string> setTaxCountry = new set<string>();
          set<string> setTaxCategory = new set<string>();
          set<Id> setSapCmds = new set<Id>();
          
        for(Tax_Classification__c objTax : lstReqTaxes){
            if(objTax.SAP_CMD_Tax_Classification__c == null){
                setCmdReqs.add(objTax.CMD_Request__c);
                setTaxCountry.add(objTax.Country__c);
                setTaxCategory.add(objTax.Tax_Category__c);
             }
          }
    
         system.debug('linkedCmdReq' +setCmdReqs);
         system.debug('linkedCountry' +setTaxCountry);
         system.debug('linkedCategory' +setTaxCategory);
      
    
       if(!setCmdReqs.isEmpty() && !setTaxCountry.isEmpty() && !setTaxCategory.isEmpty()){
    
            list<CMD_Request__c> lstlinkedSAPCMD = [select Id,Funloc_SAP_CMD__c,recordtype.developername from CMD_Request__c where Id=:setCmdReqs AND recordtypeid =: SAP_Funloc_Edit_Request.id];

               if(!lstlinkedSAPCMD.isEmpty()){
                for(CMD_Request__c objCMD: lstlinkedSAPCMD){
                    setSapCmds.add(objCMD.Funloc_SAP_CMD__c);
               }
        
                system.debug('linkedSapCMD' +setSapCmds);
                system.debug('linkedSapCMDsize' +setSapCmds.size());
                
              
              setSapCmds.remove(null); 
              if(!setSapCmds.isEmpty() &&  setSapCmds.size()>0){
              
                 if(trigger.isBefore && (trigger.isInsert || trigger.isUpdate))  {
              
                     list<Tax_Classification__c> lstSapCmdTaxes = [Select Id,CMD_Request__c,SAP_CMD_Tax_Classification__c,Country__c,Tax_Category__c 
                                            FROM Tax_Classification__c
                                            WHERE SAP_CMD_Tax_Classification__c=:setSapCmds
                                            AND Country__c =: setTaxCountry
                                            AND Tax_Category__c =: setTaxCategory];
                                            
                 system.debug('linkedTaxes' +lstSapCmdTaxes); 
                 system.debug('linkedTaxes' +lstSapCmdTaxes.size());
    
    
               if(lstSapCmdTaxes.isEmpty()) {
                   for(Tax_Classification__c objTax : lstReqTaxes){
                       objTax.addError('The combination of Tax Classification is not matched, please double check.');
       
                       }
                     }
                   }
               }
    
           if(trigger.isbefore && trigger.isInsert){
           
                system.debug('nblinkedCmdReq' +setCmdReqs);
                system.debug('nblinkedCountry' +setTaxCountry);
                system.debug('nblinkedCategory' +setTaxCategory);
                
                list<Tax_Classification__c> lstCMDTaxes = [Select Id,CMD_Request__c,SAP_CMD_Tax_Classification__c,Country__c,Tax_Category__c 
                                            FROM Tax_Classification__c
                                            WHERE CMD_Request__c=:setCmdReqs
                                            AND Country__c =: setTaxCountry
                                            AND Tax_Category__c =: setTaxCategory];
                 system.debug('nblstCMDTaxes' +lstCMDTaxes); 
                 system.debug('nblstCMDTaxessize' +lstCMDTaxes.size());                                                                     
                  if(!lstCMDTaxes.isEmpty()) {
                     for(Tax_Classification__c objTaxes : lstReqTaxes){
                      for(Tax_Classification__c objCMDTax : lstCMDTaxes){ 
                       if(objTaxes.CMD_Request__c == objCMDTax.CMD_Request__c){
                             objTaxes.addError('Duplicate entries found in Tax Classification table, please double check.');      
                            }
                          }
                        }
                     }                                      
                   } 
                }
            if(trigger.isBefore && trigger.isDelete)  {
                system.debug('cmdvalue' + setCmdReqs);
                
                list<CMD_Request__c> lstReqStatus = [select Id,Funloc_SAP_CMD__c,ownerid,recordtype.name,request_status__c from CMD_Request__c where Id=:setCmdReqs];
                
                system.debug('cmdvalue1' + lstReqStatus);
                system.debug('cmdvalue2' + lstReqStatus.size());
                
                for(Tax_Classification__c objTaxes : lstReqTaxes){
                 for(CMD_Request__c objCMD : lstReqStatus){
                      system.debug('cmdvalue3' + objTaxes.CMD_Request__c);
                      system.debug('cmdvalue4' + objCMD.id);
                      system.debug('cmdvalue5' + objCMD.Request_status__c);
                      system.debug('cmdvalue6' + objCMD.recordtype.name);
                      system.debug('ownercheckcmd' + objCMD.ownerid);
                      system.debug('ownercheckcurrent' + userinfo.getUserId());
      
                  if(objTaxes.CMD_Request__c == objCMD.id && objCMD.ownerid == userinfo.getUserId() && objCMD.recordtypeid == SAP_New_Funloc_Request.id){
                  
                       system.debug('cmdvalue7');
 
                       objTaxes.addError('Taxes can be created/updated/deleted only by Approvers for New Funloc request when it is Pending for approval.');
                     }
                  if(objTaxes.CMD_Request__c == objCMD.id && objCMD.ownerid != userinfo.getUserId() && objCMD.Request_status__c != 'Pending for Approval' && objCMD.recordtypeid == SAP_New_Funloc_Request.id){
                  
                       system.debug('cmdvalue7');
 
                       objTaxes.addError('Taxes can be created/updated/deleted only by Approvers for New Funloc request when it is Pending for approval.');
                     }
                   if(objTaxes.CMD_Request__c == objCMD.id && objCMD.ownerid != userinfo.getUserId() && objCMD.Request_status__c != 'Pending for Approval' && objCMD.recordtypeid == SAP_Funloc_Edit_Request.id){
                        
                        system.debug('cmdvalue8');
 
                        objTaxes.addError('Taxes can be added/edited/deleted only when Edit Funloc request is pending for approval.');
                     }
                   if(objTaxes.CMD_Request__c == objCMD.id && objCMD.ownerid == userinfo.getUserId() && (objCMD.Request_status__c != 'Draft' && objCMD.Request_status__c != 'Ready to Submit')&& objCMD.recordtypeid == SAP_Funloc_Edit_Request.id){
                        
                        system.debug('cmdvalue9');
 
                        objTaxes.addError('Taxes can be added/edited/deleted only before submitting the Edit funloc request for approval');
                      }
                     }  
                    }                                    
                 }
               }
             } 
        
   Public static void validationOfCTCTableonSAPCMD( list<Tax_Classification__c> lstReqTaxes) {
    
       fetchUserProifleId();
       for(Tax_Classification__c objTaxes : lstReqTaxes){
           if(objTaxes.sap_cmd_tax_classification__c != null && userinfo.getProfileId() != System_Administrator.id && userinfo.getProfileId() != NXP_CMD_Officer.id){
               system.debug('cmdvalue11' + objTaxes.sap_cmd_tax_classification__c);
               system.debug('cmdvalue10' + userinfo.getProfileId());
               objTaxes.addError(' Taxes can be created/updated/deleted only by CMD Officers on SAP CMD.');
               
            }
          }
        
        }
    // SFDC -2647 Deletion of Tax clasification related list in sap cmd 
    
   Public static void validationOfTaxClsonSAPCMD( list<Tax_Classification__c> lstReqTaxes) {    
       fetchUserProifleId();
       set<Id> SapcmdId = new set<Id>();
       for(Tax_Classification__c objTaxeId : lstReqTaxes){
           SapcmdId.add(objTaxeId.sap_cmd_tax_classification__c);      
       }
     Map<Id,SAP_CMD__c> sapcmdlst = new Map<Id,SAP_CMD__c>( [select id,status__c from SAP_CMD__c where id in: SapcmdId] );
       for(Tax_Classification__c objTaxes : lstReqTaxes){
        System.debug('Status s' + objTaxes.SAP_CMD_Tax_Classification__r.Status__c);
 
           if((objTaxes.sap_cmd_tax_classification__c != null) && (userinfo.getProfileId() != System_Administrator.id && userinfo.getProfileId() != TS_Standard_User.id) 
              && (sapcmdlst.get(objTaxes.SAP_CMD_Tax_Classification__c).Status__c == 'PickedForDistribution' || 
                  sapcmdlst.get(objTaxes.SAP_CMD_Tax_Classification__c).Status__c == 'Approved and Failed Distribution' || 
                  sapcmdlst.get(objTaxes.SAP_CMD_Tax_Classification__c).Status__c == 'Approved and Distributed')){
               objTaxes.addError(' Taxes can be created/updated/deleted only by CMD Officers on SAP CMD when status is Draft, Ready for Approval, or Approved.');            
            }           
          }        
        }
  
    // End - SFDC 2647
    
   Public static void fiscalApprovalForTaxChange( list<Tax_Classification__c> lstReqTaxes){
   
           system.debug('entered here');
           set<string> setTaxRequest = new set<string>();
           list<CMD_Request__c> lstUpdateReqs = new list<CMD_Request__c>();
   
            for(Tax_Classification__c objTax : lstReqTaxes){
                setTaxRequest.add(objTax.CMD_Request__c);
              }
            system.debug('finalvalue'+setTaxRequest);
           // if(setTaxRequest!=null){
            list<CMD_Request__c> lstCMDRequests = [Select Id,Request_Status__c,FLAG_Fiscal__c,Tax_Classification_Flag__c,recordtype.name 
                                                   FROM CMD_Request__c 
                                                   WHERE Id=:setTaxRequest];
            if(!lstCMDRequests.isEmpty()){                                       
            list<Tax_Classification__c> lstCMDReqTaxes = [Select Id,CMD_Request__c,SAP_CMD_Tax_Classification__c,Country__c,Tax_Category__c 
                                                          FROM Tax_Classification__c 
                                                          WHERE CMD_Request__c=:setTaxRequest and SAP_CMD_Tax_Classification__c=null];
     
            system.debug('finalvalue0'+lstCMDRequests);
            system.debug('finalvaluetaxes'+lstCMDReqTaxes.size());
     
             if(trigger.isDelete && lstCMDReqTaxes.size()<=0){
                  for(CMD_Request__c objCMDReq : lstCMDRequests){
                      if((objCMDReq.Request_Status__c == 'Draft' || objCMDReq.Request_Status__c == 'Ready to Submit') && objCMDReq.recordtypeid == SAP_Funloc_Edit_Request.id){
                            objCMDReq.Tax_Classification_Flag__c = false;
                            if(!lstUpdateReqs.contains(objCMDReq)){
                                lstUpdateReqs.add(objCMDReq);
                             }
                  system.debug('finalvalue4'+objCMDReq.Tax_Classification_Flag__c);
                }
           }
      }
      
        if((trigger.isInsert || trigger.isUpdate) && (!lstCMDReqTaxes.isEmpty())){
          for(CMD_Request__c objCMDReq : lstCMDRequests){
             for(Tax_Classification__c objTaxes : lstCMDReqTaxes){
                if(objTaxes.CMD_Request__c == objCMDReq.Id && (objCMDReq.Request_Status__c == 'Draft' || objCMDReq.Request_Status__c == 'Ready to Submit') && objCMDReq.recordtypeid == SAP_Funloc_Edit_Request.id){
                    objCMDReq.Tax_Classification_Flag__c = true;
                    if(!lstUpdateReqs.contains(objCMDReq)){
                       lstUpdateReqs.add(objCMDReq);
                     }
                    system.debug('finalvalue1'+lstUpdateReqs);
                    system.debug('finalvalue2'+lstUpdateReqs.size());
                    system.debug('finalvalue3'+objCMDReq.Tax_Classification_Flag__c);
              }  
            }
          }
        }
      }  
    Update lstUpdateReqs;
   
   }
 }