/*------------------------------------------------------------------------------------------------------------------
 * Created By   : Naveen
 * Created Date : 03 Mar,2019
 * Description   : SFDC-2647 - As CMD Officer, Due to Process Change, I want able to change the SAP CMD Status to "Approved"
 ------------------------------------------------------------------------------------------------------------------*/
public class SAP_CMD_Partner_Function_Trigger {

    private static String TYPE_System_Admin = 'System Administrator';
    private static String TYPE_CMD_Officer = 'NXP CMD Officer';
    private static String TYPE_Standard_User = 'TS Standard User - API Enabled';
    
    private static Profile System_Administrator;
    private static Profile NXP_CMD_Officer;
    private static profile TS_Standard_User;
    
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
    
     // SFDC -2647 Deletion of Tax clasification related list in sap cmd 
    
   Public static void validationOfPartnerFunOnSAPCMD( list<Partner_Function__c> lstReqPfuns) {    
       fetchUserProifleId();
       set<Id> SapcmdId = new set<Id>();
       for(Partner_Function__c objPfId : lstReqPfuns){
           SapcmdId.add(objPfId.SAP_Customer__c);      
       }
     Map<Id,SAP_CMD__c> sapcmdlst = new Map<Id,SAP_CMD__c>( [select id,status__c from SAP_CMD__c where id in: SapcmdId] );
       for(Partner_Function__c objPfunction : lstReqPfuns){
        //System.debug('Statuess' + objTaxes.SAP_Customer__c.Status__c);
 
           if((objPfunction.SAP_Customer__c != null) && (userinfo.getProfileId() != System_Administrator.id && userinfo.getProfileId() != TS_Standard_User.id) 
              && (sapcmdlst.get(objPfunction.SAP_Customer__c).Status__c == 'PickedForDistribution' || 
                  sapcmdlst.get(objPfunction.SAP_Customer__c).Status__c == 'Approved and Failed Distribution' || 
                  sapcmdlst.get(objPfunction.SAP_Customer__c).Status__c == 'Approved and Distributed')){
               objPfunction.addError(' Partner Function can be created/updated/deleted only by CMD Officers on SAP CMD when status is Draft, Ready for Approval, or Approved.');            
            }           
          }        
        }
  
    // End - SFDC 2647
}