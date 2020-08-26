/***************************************************************************************************
@Created By :      Prakahr Gupta
@Created Date:     20 Dec 2014
@Description:      Class for all the methods for triggers on Case
-----------------------------------------------------------------------------------------------------
@Modified By :      Amrutha R
@Modified Date:     27 Feb 2015
@Description:       Changed according to new case assignment process
-----------------------------------------------------------------------------------------------------
@Modified By :      Amrutha R
@Modified Date:     23 Nov 2015
@Description:       Skip case assignment field in user object- dont assign case to user if value is true
-------------------------------------------------------------------------------------------------------
@Modified By :      Amrutha R
@Modified Date:     27 Jan 2016
@Description:       Change default queue from '1st line support' to 'TS L1 inbox'
---------------------------------------------------------------------------------------------------------
@Modified By :      Avichal Kumar
@Modified Date:     07 Apr 2016
@Description:       Cleanup of case assignment rules
---------------------------------------------------------------------------------------------------------
@Modified By :      Avichal Kumar
@Modified Date:     22 july 2016
@Description:       Entitlement based routing
-------------------------------------------------------------------------------------------------------
@Modified By :      vinanthi ittigi
@Modified Date:     25 july 2016
@Description:       sir 1080
-------------------------------------------------------------------------------------------------------
@Modified By :      Shridevi Badiger
@Modified Date:     11 Jan 2017
@Description:       sir 207-Finalise case service level and  case priority.
-------------------------------------------------------------------------------------------------------
@Modified By :      Shridevi Badiger
@Modified Date:     28 Jun 2017
@Description:       SIR-518-Remove the usage of tech support record type to disable it
-------------------------------------------------------------------------------------------------------
@Modified By :      Harish Gowda N.
@Modified Date:     06 Jul 2018
@Description:       SFDC-1761 mapping between "Title"(Contact field) to "Contact Title "(Case Field).
------------------------------------------------------------------------------------------------------
@Modified By :      Gunjan Singh
@Modified Date:     11 Sep 2018
@Description:       SFDC-2078 Web-to-Case form without Login - Enhancement (Creating contact along with case)
Created method createContact() to create Contact, along with Case if contact doesnot exist
-------------------------------------------------------------------------------------------------------------
@Modified By :      Nisha Agrawal
@Modified Date:     Jul 15, 2019
@Description:       SFDC-3064 , Method added to grant sharing to the cases based on the projects
-------------------------------------------------------------------------------------------------------------
@Modified By :      Saranya Sista
@Modified Date:     Jul 16, 2019
@Description:       SFDC-2961 Refactoring Case trigger to incorporate Project object instead of Entitlement
Method added to update "Cases Per Project","Last Case Created" fields when ever case is created.
**********************************************************************************************************/

public class CaseTrigger 
{ 
    private static final string DOMAIN_SEPARATOR = '@';
    private static final string DEFAULT_QUEUE = 'TS L1 Inbox';
    private static Id tscommunityRT= Schema.SObjectType.Case.getRecordTypeInfosByName().get('TS Community').getRecordTypeId();
    private static Id DEFAULT_QUEUE_ID;
    
    private static void getDefaultQueueId()
    {
        if(DEFAULT_QUEUE_ID == null)
        {
            List<Group> lstGroups = [Select Id, Name From Group Where Name = :DEFAULT_QUEUE  limit 1] ;
            if(lstGroups.size() > 0)
            {
                DEFAULT_QUEUE_ID = lstGroups[0].Id ;  
            }    
        }
    }    
    
    /***added for NCP **/
    public static void populateContactIdToCase(List<case> caseLst){
        List<case> lstCasesWithoutContacts = new List<case>(); 
        for(case eachcse : caseLst){
            if(eachcse.RecordTypeId == tscommunityRT && eachcse.ContactId == null){
                lstCasesWithoutContacts.add(eachcse);
            }
        }
        if(lstCasesWithoutContacts.size() > 0){   
            List<User> lstUser = [Select Id, ContactId, Contact_Id__c From User Where Id = :userinfo.getuserid() Limit 1];
            if(lstUser.size() > 0 )
            {
                Id contactId =  (lstUser[0].ContactId != null ? lstUser[0].ContactId : lstUser[0].Contact_Id__c );
                for(Case eachnewcase : lstCasesWithoutContacts)
                {
                    eachnewcase.ContactId = contactId;
                }
            } 
        }    
    }
    
    /****************************************************************
Case Trigger Consolidation
Modified by :Sumanth
Date:18-07-2017
Method to populate the Product Values based on the Product Type Number to Case
***************************************************************/
    public static void populateProductValuesToCase(List<Case> CaseList)
    {
        List<Case> lstCases= new List<Case>(); 
        for (Case objCase: CaseList) 
        {
            if(objCase.Origin != null && objCase.Projects__c == null && objCase.RecordTypeId==tscommunityRT)
            {
                lstCases.add(objCase);
            }
        }
        
        Map<Case,String> mapCaseIdProducTypeNumber = new Map<Case,String>();
        Map<String,Product2> mapProductTypeProduct = new Map<String,Product2>();        
        Set <String> productTypeNumberSet= new Set<String>();
        
        //loop over all case records and process one by one
        for(Case objCase : lstCases)        
        {
            if (objCase.Product_Type_Number__c!= null && objCase.Product_Type_Number__c!='')
            {
                mapCaseIdProducTypeNumber.put(objCase,objCase.Product_Type_Number__c);
                productTypeNumberSet.add(objCase.Product_Type_Number__c);
            }            
        }  
        
        if(!mapCaseIdProducTypeNumber.IsEmpty())
        {            
            Map<ID, Product2> Idproduct = new Map<ID, Product2>([Select Id, Basic_Type__c,BL_Description__c,
                                                                 Basic_Type_Description__c,BL__c,BU__c,BU_Description__c,MAG__c,
                                                                 MAG_Description__c,Product_Type__c From Product2 
                                                                 Where Product_Type__c In : productTypeNumberSet]);
            for(Id id:Idproduct.keyset())
            {  
                mapProductTypeProduct.put(Idproduct.get(id).Product_Type__c,Idproduct.get(id));
            }
        }
        
        if(!mapProductTypeProduct.isEmpty())
        {            
            for (Case objCase: lstCases)
            {
                if(mapCaseIdProducTypeNumber.containsKey(objCase))
                {
                    if(mapProductTypeProduct.containsKey(mapCaseIdProducTypeNumber.get(objCase)))
                    {   
                        Product2 objProduct= mapProductTypeProduct.get(mapCaseIdProducTypeNumber.get(objCase));
                        objCase.BL__c=objProduct.BL__c;
                        objCase.BL_Description__c=objProduct.BL_Description__c;
                        objCase.BU__c=objProduct.BU__c;
                        objCase.BU_Description__c=objProduct.BU_Description__c;
                        objCase.MAG__c=objProduct.MAG__c;
                        objCase.MAG_Description__c=objProduct.MAG_Description__c;
                        objCase.Basic_Type_Description__c=objProduct.Basic_Type_Description__c;
                        objCase.Basic_Type__c=objProduct.Basic_Type__c;
                    }
                }
            }
        } 
        
    }
    
    //Consolidated for NCP
    //This method is populating AccountId, Default Owner and Assigned To/Owner based on project    
    public static void AssignCaseOwnerAndAccount(List<Case> lstCases)
    {
        if(lstCases != null && lstCases.size() > 0 )
        {            
            getDefaultQueueId();            
            
            List<Case> lstCasesToUpdateAccount = new List<Case>();
            List<Case> lstCasesToAssignOwnerByProject = new List<Case>();
            
            Set<Id> contactIds = new Set<Id>(); 
            Set<Id> projectIds = new Set<Id>();
            
            for(Case objCase:  lstCases)
            {
                if(objCase.RecordTypeId == tscommunityRT)
                {
                    if(objCase.Origin != null && objCase.Origin != 'Forum' && objCase.Projects__c == null)
                    {
                        if(objCase.ContactId != null){
                            contactIds.add(objCase.ContactId); 
                        } 
                        lstCasesToUpdateAccount.add(objCase);
                    }
                    if(objCase.Projects__c != null)
                    {
                        projectIds.add(objCase.Projects__c);                        
                        lstCasesToAssignOwnerByProject.add(objCase);
                    }
                    
                    //assign default owner
                    objCase.OwnerId = DEFAULT_QUEUE_ID;                 
                }
            }    
            
            if(contactIds.size() > 0)
            {
                Map<Id,Contact> mapContactIdToContact = new Map<Id,Contact>([Select Id,AccountId From Contact where ID IN : contactIds]);     
                for (Case objCase: lstCasesToUpdateAccount) 
                {
                    if(mapContactIdToContact.containsKey(objCase.ContactId)){
                        Contact objContact = mapContactIdToContact.get(objCase.ContactId);
                        if(objContact.accountId != null){
                            objCase.AccountId = objContact.accountId;
                        }
                    }
                }
            }           
                    
            if(projectIds.size() > 0)
            {
                Map<Id, Project__c> mapProjectIdToProject = new Map<Id, Project__c>([Select Id, Route_to_Assigned_To__c, Route_To_Case_Owner__c 
                                                                                From Project__c Where Id in : projectIds AND Contract_Status__c = 'Active']);
                Set<String> caseOwnerNamesFromProject = new Set<String>();
                for(Project__c objProject : mapProjectIdToProject.values() )
                {
                    if(String.isNotBlank(objProject.Route_To_Case_Owner__c)){
                        caseOwnerNamesFromProject.add(objProject.Route_To_Case_Owner__c);
                    }
                }

                Map<String,Id> MapQueueNameToQueueId = new Map<String,Id>();
                
                if(caseOwnerNamesFromProject.size() > 0)
                {
                    for(Group eachGroup : [Select Id, Name From Group Where Name IN : caseOwnerNamesFromProject and Type = 'Queue']){
                        if(MapQueueNameToQueueId.containsKey(eachGroup.Name) == false){
                            MapQueueNameToQueueId.put(eachGroup.Name,eachGroup.Id);
                        }
                    }
                }
                
                for(Case objCase:  lstCasesToAssignOwnerByProject)
                {
                    if(objCase.Projects__c != null && mapProjectIdToProject.containsKey(objCase.Projects__c))
                    {
                        Project__c objProject = mapProjectIdToProject.get(objCase.Projects__c);
                        //Assign Owner from Project
                        if(MapQueueNameToQueueId.containsKey(objProject.Route_To_Case_Owner__c))
                        {
                            objCase.OwnerId = MapQueueNameToQueueId.get(objProject.Route_To_Case_Owner__c);
                        }
                        
                        //Assign Assigned To from Project
                        objCase.Assigned_to__c = mapProjectIdToProject.get(objCase.Projects__c).Route_to_Assigned_To__c ;                       
                    }
                }
            }
        }
    }
    
    
    //method to assign account and owner to case- new assignment process
    /*  public static void newProcessCasesToAssignOwnerAndAccount(List<Case> lstCases)
{

Id caseOwnerId;
List<User> lstUser=new List<User>();
List<Case_Owner_Assignment__c> lstCaseAssignmentRules = [Select Case_Owner_Id__c, 
MAG__c, Region__c, Country__c 
From Case_Owner_Assignment__c];
Map<String,Case> mapCaseOwnerToCase = new Map<String,Case>();
Map <Id,Account> mapIdToAccount = new Map<Id,Account> ( [Select Id, Name, Account_Manager_AMEC__c,                                                                    Account_Manager_EMEA__c, Account_Manager_GC__c,
Account_Manager_Japan__c, Account_Manager_Korea__c,
Account_Manager_Korea_2__c, Account_Manager_SAP__c,
Account_Manager_SAP_2__c, Account_Manager_SAP_3__c,
Service_Manager_AMEC__c,   Service_Manager_EMEA__c,
Service_Manager_GC__c, Service_Manager_Japan__c,
Service_Manager_Korea__c, Service_Manager_SAP__c, NXP_GID__c
From Account ]);  
List<Contact> lstContacts = new List<Contact>();

for (case objCase : lstCases)
{
if(objCase.Case_Owner_Name__c != null && objCase.Case_Owner_Name__c.trim() != '')
{              
mapCaseOwnerToCase.put(objCase.Case_Owner_Name__c, objCase);            
}  
}

fetchDefaultQueueId();                
Account objAccTechnicalServices;
Account objAccNXPCommunity;
List<Account> lstAccTechnicalServices = [Select Id,Name From Account 
Where Name='Technical Services' limit 1 ];
if(lstAccTechnicalServices.size()>0)
{
objAccTechnicalServices =lstAccTechnicalServices.get(0); 
}
else
{
objAccTechnicalServices=null;  
}
List<Account> lstAccNXPCommunity = [Select Id,Name From Account 
Where Name=: NXP_COMMUNITY limit 1 ];
if(lstAccNXPCommunity.size()>0)
{
objAccNXPCommunity =lstAccNXPCommunity.get(0); 
}
else
{
objAccNXPCommunity=null;  
}

for(Case objCase: lstCases)
{
lstContacts=[select id,accountId,Account.owner.id from contact where id=: objCase.ContactId LIMIT 1];
if(lstContacts.size()>0)
{
Contact objContact=lstContacts[0]; 
if(objContact.AccountId!= objAccTechnicalServices.Id && objContact.AccountId!= objAccNXPCommunity.Id)
{
lstUser= [Select Id,Name from User where Id=: objContact.Account.owner.id and IsActive=true 
and Skip_Case_Assignment__c!=true LIMIT 1];
if(lstUser.size()>0)
{
caseOwnerId = defaultQueueId;
assignOwnerAndAccount(objCase, caseOwnerId,objContact.AccountId,mapIdToAccount);
}
else
{
caseOwnerId = defaultQueueId;
assignOwnerAndAccount(objCase, caseOwnerId,objContact.AccountId,mapIdToAccount);
} 

}

else if(objContact.AccountId== objAccTechnicalServices.Id || objContact.AccountId== objAccNXPCommunity.Id)
{ */
    /***************************************************************************************
NOTE : NOT SURE ABOUT THE REQUIREMENT SO JUST KEPT THE CODE AS IT IS
AND MIGHT NEED TO REWRITE THE CODE IN CLEANUP 
***************************************************************************************
if ((objCase.MAG__c !=null|| objCase.MAG__c!='' )&&(objCase.Web_Region__c!=null || objCase.Web_Region__c!='')
&&(objCase.Web_Country__c!=null || objCase.Web_Country__c!='')) //case 4 : assignment rule
{
for( Case_Owner_Assignment__c  objRule : lstCaseAssignmentRules) 
{                
if(objCase.MAG__c == objRule.MAG__c && objCase.Web_Region__c==objRule.Region__c)
{
if(objRule.Country__c!=null && objRule.Country__c!='')
{
if(objCase.Web_Country__c==objRule.Country__c)
{
objCase.OwnerId=objRule.Case_Owner_Id__c;
caseOwnerId = objCase.OwnerId;
} 
}
else
{
objCase.OwnerId=objRule.Case_Owner_Id__c;
caseOwnerId = objCase.OwnerId;
}
}
}
}

if(objContact.AccountId== objAccTechnicalServices.Id)
{
objCase.AccountId= objAccTechnicalServices.Id;
}

else if(objContact.AccountId== objAccNXPCommunity.Id)
{
objCase.AccountId= objAccNXPCommunity.Id;

}
if(caseOwnerId==null)
{
system.debug('+++casenot '+caseOwnerId);
objCase.OwnerId= defaultQueueId;
}

}
}


} */
    
    /**************************************************************************************************************************************       
NOTE - THE MERGED CODE FROM BEFORINSERT_CASE Trigger FROM LINE NO : 392 TO 447
**************************************************************************************************************************************

//Step 1 - First Search for User
if(mapCaseOwnerToCase.size() > 0)
{
Map<String,Id> mapOwnerNameToId = new Map<String,Id>();

for(User objUser : [Select Id , Name From User Where Name 
in : mapCaseOwnerToCase.keySet() and IsActive =true ])
{
mapOwnerNameToId.put(objUser.Name, objUser.Id);
}

Map<String,Case> mapQueueNameToCase = new Map<String,Case>();
Set<String> queueNameSet = new Set<String>();

for(String ownerName : mapCaseOwnerToCase.keySet())
{
if(mapOwnerNameToId.containsKey(ownerName))
{
mapCaseOwnerToCase.get(ownerName).OwnerId = mapOwnerNameToId.get(ownerName);                       
}
else
{
mapQueueNameToCase.put(ownerName, mapCaseOwnerToCase.get(ownerName));
queueNameSet.add(ownerName);
}
}

//Step 2 - Search for Queue
if(queueNameSet.size() > 0)
{
queueNameSet.add(DEFAULT_QUEUE);

Map<String,Id> mapQueueNameToId = new Map<String,Id>();
for(Group objGroup : [Select Id, Name From Group Where Type='Queue' and Name In :queueNameSet])
{
mapQueueNameToId.put(objGroup.Name,objGroup.Id);                        
}

for(String ownerName : mapQueueNameToCase.keySet())
{                        
if(mapQueueNameToId.containsKey(ownerName))
{
mapQueueNameToCase.get(ownerName).OwnerId = mapQueueNameToId.get(ownerName);
}
else
{
mapQueueNameToCase.get(ownerName).OwnerId = mapQueueNameToId.get(DEFAULT_QUEUE);
}
}
}
} // end of for loop 


}

//Description : Method to assign Case OwerId, AccountId and NXP GID to cases  
private static void assignOwnerAndAccount(Case objCase, Id ownerId,  Id accountId , 
map <Id , Account> mapIdToAccount)
{

objCase.AccountId = accountId;
if(mapIdToAccount.containsKey(accountId))
{
if(mapIdToAccount.get(accountId).NXP_GID__c != null)
{
objCase.Account_GID__c = mapIdToAccount.get(accountId).NXP_GID__c;  
}           
}
if(ownerId !=null)
{           
objCase.OwnerId = ownerId;     
}
else
{
objCase.OwnerId= defaultQueueId;
} 
} */ 
    
    /****************************************************************
Case Trigger Consolidation
Modified by :Sumanth
Date:18-07-2017
Method to verify email to case contact
***************************************************************/
    
    
    public static void emailToCaseContactCheck(List<Case> CaseList)
    {
        List<Case> lstCases= new List<Case>();
        for (Case objCase: CaseList) 
        {
            if(objCase.Origin == 'Email' && objCase.RecordTypeId==tscommunityRT )
            {
                lstCases.add(objCase);
            }
        }
        
        if(lstCases.size()>0) 
        {
            Map<string,case> mapCaseEmail= new Map<string,case>();
            List<String> caseEmails=new List<String>();
            String[] strSendTo =new String[]{};
                Set<String> contactEmails=new Set<String>();
            string email=lstCases[0].SuppliedEmail;
            for(Case objCase : lstCases)        
            { 
                mapCaseEmail.put(objCase.SuppliedEmail,objCase);
                caseEmails.add(objCase.SuppliedEmail);       
            }  
            List<Contact> lstContact = [SELECT Id, Name, Email  FROM Contact WHERE Email = :mapCaseEmail.KeySet()];
            
            if(lstContact.size()>0)
            {
                for(Contact objContact : lstContact)
                    contactEmails.add(objContact.email);
            }
            for(String objString :caseEmails)
            {
                if(!contactEmails.contains(objString))
                    strSendTo.add(objString);
            }
            if(strSendTo.size()!=0)
            {
                List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                EmailTemplate objEmailTemplate=[Select Id, Name,DeveloperName From EmailTemplate 
                                                Where DeveloperName ='Community_email_to_case_creation_Contact_not_found' limit 1];
                mail.setTemplateId(objEmailTemplate.id);
                mail.setToAddresses(strSendTo);
                OrgWideEmailAddress[] owea = [select Id,Address from OrgWideEmailAddress where displayname='nxp technical support'];
                if( owea.size() > 0 ) 
                {
                    mail.setOrgWideEmailAddressId(owea.get(0).Id);
                }
                mail.setTargetObjectId(UserInfo.getUserId());
                mail.setSaveAsActivity(false);
                mail.setTreatTargetObjectAsRecipient(False);
                mails.add(mail);
                Messaging.sendEmail(mails);
                for(String strCaseEmail : strSendTo)
                {
                    mapCaseEmail.get(strCaseEmail).origin='UnknownContact';
                }
            }
        } 
    }
    /**************************************************
Future method to delete Cases where Case Origin = 'Unknown Contact'

**************************************************/
    
    @future
    public static void DeleteCases()
    {
        try{
            delete [select id from case where origin='UnknownContact'];
            // delete listCase;
        }
        catch(DMLException e)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Sorry, some problem occured during deletion'));     
            
        }
        
    }
    
    
    
    /****************************************************************
Case Trigger Consolidation
Modified by :Sumanth
Date:19-07-2017
Method to fetch related Contact Info and update Case Fields
***************************************************************/
    
    public static void fetchContactInfo(List<Case> CaseList, Map<Id, case> caseOldMap)
    {
        List<Case> lstCases = new List<Case>();
        Set<id> setContactID = new set<id>();
        case oldCase;
        for (Case objCase: CaseList) 
        {
            if(objCase.RecordTypeId==tscommunityRT){
                if(caseOldMap != null){
                    oldCase = caseOldMap.get(objCase.Id);    
                }
                if (objCase.contactID != null && ((oldCase == null) || (oldCase != null && objCase.contactID != oldCase.contactID)))
                {
                    lstCases.add(objCase);
                    setContactID.add(objCase.ContactID);
                }
            }    
        }
        
        Map<id,Contact> mapContact = new map<id,Contact>([SELECT Id, Name, Email,Company__c,Community_web_country__c,Linkedin__c,Twitter__c,
                                                          FirstName,State_Province__c,Web_Region__c,LastName,Phone,Job_Title__c,Facebook__c,Title FROM Contact WHERE Id in: setContactID]);
        
        for(Case objCase : lstCases)        
        {  
            if(mapContact.containsKey(objCase.contactID))
            {
                objCase.Community_Web_Country__c=mapContact.get(objCase.contactID).Community_web_country__c;                    
                objCase.Company__c=mapContact.get(objCase.contactID).Company__c;          
                objCase.Email__c= mapContact.get(objCase.contactID).Email;
                objCase.First_Name__c= mapContact.get(objCase.contactID).FirstName;
                objCase.Last_Name__c= mapContact.get(objCase.contactID).LastName;
                objCase.Phone_Number__c=mapContact.get(objCase.contactID).Phone;
                objCase.JobTitle__c= mapContact.get(objCase.contactID).Job_Title__c;
                objCase.Facebook__c=mapContact.get(objCase.contactID).Facebook__c;
                objCase.Linkedin__c=mapContact.get(objCase.contactID).Linkedin__c;
                objCase.Twitter__c=mapContact.get(objCase.contactID).Twitter__c;
                objCase.State_Province__c=mapContact.get(objCase.contactID).State_Province__c;
                objCase.Web_Region__c=mapContact.get(objCase.contactID).Web_Region__c;
                objCase.Contact_Title__c=mapContact.get(objCase.contactID).Title;
            }
            system.debug('objCase.Contact_Title__c'+objCase.Contact_Title__c);
        }
        
    }  
    
    /****************************************************************
Case Trigger Consolidation
Modified by :Sumanth
Date:19-07-2017
Method for Service Level Calculation
***************************************************************/
    
    
    /*public static void PSLIdentification(List<Case> CaseList)
    {   
        
        List<case> listCases = new List<case>();
        
        for(Case objCase: CaseList) 
        {
            if(objcase.isClosed==false)
            {
                listCases.add(objcase);
                
            }
            
        }
        
        if(listCases.size()>0 && listCases!=null)
        {
            
            String tempPSL;
            List<String> listProductLvl1=new List<String>();
            Map<String,product_service_level_criteria__c> productServicelevelcriteriamap = new Map<String,product_service_level_criteria__c>();
            for(Case caseRec:listCases)
                listProductLvl1.add(caseRec.Product__c);
            set<product_service_level_criteria__c> listPSL=new set<product_service_level_criteria__c>
                (
                    [select Product__c,Product_Category__c,Product_Sub__c,Product_Service_Level__c from product_service_level_criteria__c where Product__c in:listProductLvl1]
                );
            //Build a map of Product and Product Service level
            for(product_service_level_criteria__c P:listPSL) 
            {
                
                productServicelevelcriteriamap.put(P.Product__c,P);
                
            }
            
            for(case caseRec:listCases)    
            {
                tempPSL='';
                caseRec.Product_Service_Level__c='';
                if(listPSL!=null)
                {
                    
                    //if(productServicelevelcriteriamap.containsKey(caseRec.Product__c))
                    
                    
                    for(product_service_level_criteria__c PSLRec:listPSL)
                    {
                        System.debug(' PSLRec:'+ PSLRec);
                        System.debug(' PSLRec.Product_Category__c:'+ PSLRec.Product_Category__c+':PSLRec.Product_Sub__c:'+PSLRec.Product_Sub__c);
                        if(PSLRec.Product__c==caseRec.Product__c)
                        {
                            if(PSLRec.Product_Category__c==caseRec.Product_Category__c && PSLRec.Product_Sub__c==caseRec.Product_Sub__c)
                            {
                                caseRec.Product_Service_Level__c=PSLRec.Product_Service_Level__c;
                                break;
                            }
                            if(PSLRec.Product_Category__c==caseRec.Product_Category__c && (PSLRec.Product_Sub__c==null || PSLRec.Product_Sub__c==''))
                            {
                                tempPSL=PSLRec.Product_Service_Level__c;
                                System.debug('Entered if-2:tempPSL::'+tempPSL);
                                
                            }
                            if((PSLRec.Product_Category__c==null || PSLRec.Product_Category__c=='') && (tempPSL==null || tempPSL==''))
                            {
                                tempPSL=PSLRec.Product_Service_Level__c;
                                
                                System.debug('Entered if-3:tempPSL::'+tempPSL);
                            }
                            
                        }
                    } //end of inner for
                    if((caseRec.Product_Service_Level__c==null || caseRec.Product_Service_Level__c=='') && tempPSL!=null && tempPSL!='' )
                    {
                        
                        caseRec.Product_Service_Level__c=tempPSL;
                        System.debug('Entered if-4:tempPSL::'+tempPSL);
                        
                    }//end of if
                }//end of if
            }
        }
    }//end of method
    
*/
    
    
    /****************************************************************
Case Trigger Consolidation
Modified by :Sumanth
Date:19-07-2017
Method for Service level Calculations
***************************************************************/
 /*   
    
    public static void projectServiceLevelIdentification(List<Case> CaseList)
    {   
        List<case> listCases = new List<case>();
        for(Case objCase: CaseList) 
        {
            if(objcase.isClosed==false)
            {
                listCases.add(objcase);
            }
        }
        if(listCases.size()>0 && listCases!=null)
        {
            list<String> listId=new list<String>();
            set<String> setType=new set<String>();
            string PSLTemp;
            string PSLTemp1;
            map<id,Project__c> mapProject;
            list<Project_Service_Level_Criteria__c> listProjectSLC=new list<Project_Service_Level_Criteria__c>();
            
            for(case caseRec:listCases)
                listId.add(caseRec.Projects__c);
            
            if(listId.size()!=0 && listId!=null)
                mapProject=new map<id,Project__c>([select id,Type__c,Project_Service_Level__c from Project__c where id in:listId]);
            system.debug('this is map Project'+mapProject);
            //  listString=new list<String>();
            if(!mapProject.isEmpty()){
                for(case caseRec:listCases)
                {
                    if(caseRec.Projects__c!=null  && mapProject.get(caseRec.Projects__c).Type__c!='' && mapProject.get(caseRec.Projects__c).Type__c!=null)
                        setType.add(mapProject.get(caseRec.Projects__c).Type__c);
                }
                if(setType.size()!=0 && setType!=null)
                    listProjectSLC=[select Type__c,Sub_Type__c,Priority__c,Project_Service_Level__c from Project_Service_Level_Criteria__c where Type__c in:setType];
                
                for(case caseRec:listCases)
                {
                    PSLTemp='';
                    caseRec.Project_Service_Level__c='';
                    if(caseRec.Projects__c!=null)
                    {
                        if((mapProject.get(caseRec.Projects__c).Type__c==null || mapProject.get(caseRec.Projects__c).Type__c=='')
                           && (mapProject.get(caseRec.Projects__c).Project_Service_Level__c!=null)
                          )
                        {
                            caseRec.Project_Service_Level__c=mapProject.get(caseRec.Projects__c).Project_Service_Level__c;
                        }
                        
                        else if(listProjectSLC.size()!=0 && listProjectSLC!=null && (mapProject.get(caseRec.Projects__c).Type__c!=null))
                        {
                            for(Project_Service_Level_Criteria__c  PSLRec:listProjectSLC)
                            {
                                if(mapProject.get(caseRec.Projects__c).Type__c==PSLRec.type__c)
                                {    
                                    if(mapProject.get(caseRec.Projects__c).Project_Service_Level__c==PSLRec.Priority__c)
                                    {
                                        caseRec.Project_Service_Level__c=PSLRec.Project_Service_Level__c;
                                        break;
                                    }
                                    if(PSLRec.Priority__c==null)
                                    {
                                        PSLTemp=PSLRec.Project_Service_Level__c;
                                    }
                                    if(PSLRec.sub_type__c==null && PSLRec.Priority__c==mapProject.get(caseRec.Projects__c).Project_Service_Level__c && (PSLTemp==null || PSLTemp==''))
                                    {
                                        PSLTemp=PSLRec.Project_Service_Level__c;
                                    }
                                    
                                    if(PSLRec.sub_type__c==null && PSLRec.Priority__c==null && (PSLTemp==null || PSLTemp==''))
                                    {
                                        PSLTemp1=PSLRec.Project_Service_Level__c;
                                    }
                                }
                                
                            }//End of inner for loop
                            if((caseRec.Project_Service_Level__c==null || caseRec.Project_Service_Level__c=='') && PSLTemp!=null && PSLTemp!='')
                                caseRec.Project_Service_Level__c=PSLTemp;
                            else if((caseRec.Project_Service_Level__c==null || caseRec.Project_Service_Level__c=='') && PSLTemp1!=null && PSLTemp1!='')  
                                caseRec.Project_Service_Level__c=PSLTemp1;
                        }
                    }
                }//End of outer for loop
            }
            
        }
    } 
    
    */
    /****************************************************************
Case Trigger Consolidation
Modified by :Sumanth
Date:19-07-2017
Method for Service level Calculations
***************************************************************/
    
    
   /* public static void caseServiceLevelIdentification(List<case> CaseList)
    {
        
        List<case> listCases = new List<case>();
        
        for(Case objCase: CaseList) 
        {
            if(objcase.isClosed==false)
            {
                listCases.add(objcase);
                
            }
            
        }
        
        
        if(listCases.size()>0 && listCases!=null)
            
        {
            Set<String> setCSL=new Set<String>();
            Set<String> setPSL=new Set<String>();
            Set<String> setProjectSL=new Set<String>();
            String tempCSL;
            String tempCSL1;
            List<Case_Service_Level_Criteria__c> listCSLC=new List<Case_Service_Level_Criteria__c>();
            
            
            for(Case caseRec:listcases)
            {
                if(caseRec.Contact_Service_Level__c!=null)
                    setCSL.add('%'+caseRec.Contact_Service_Level__c+'%');
                
                if(caseRec.Product_Service_Level__c!=null)
                    setPSL.add('%'+caseRec.Product_Service_Level__c+'%');
                
                if(caseRec.Project_Service_Level__c!=null)
                    setProjectSL.add('%'+caseRec.Project_Service_Level__c+'%');
                
            }
            
            listCSLC=[select Contact_Service_Level__c,Product_Service_Level__c,Project_Service_Level__c,Case_Service_Level__c from Case_Service_Level_Criteria__c where  Contact_Service_Level__c Like :setCSL or Product_Service_Level__c like :setPSL or Project_Service_Level__c like :setProjectSL];
            system.debug('listCSLC::'+listCSLC);
            
            
            For(case caseRec:listCases)
            {
                caseRec.case_service_level__c='';
                If(listCSLC.size()!=0 && listCSLC!=null)
                {
                    For(Case_service_level_criteria__c cslc:listCSLC)
                    {
                        if(caseRec.contact_service_level__c!=null && caseRec.contact_service_level__c!='')
                        {
                            If(cslc.contact_service_level__c!=null && cslc.contact_service_level__c==caseRec.contact_service_level__c )
                            {
                                //combination 1:complete match found
                                If( cslc.product_service_level__c==caseRec.product_service_level__c &&cslc.project_service_level__c==caseRec.project_service_level__c)
                                {
                                    caseRec.case_service_level__c=cslc.case_service_level__c;
                                    Break;
                                }
                                //combination 2
                                System.debug('cslc.product_service_level__c:'+cslc.product_service_level__c);
                                System.debug('caseRec.product_service_level__c:'+caseRec.product_service_level__c);
                                System.debug('cslc.project_service_level__c:'+cslc.project_service_level__c);
                                
                                
                                If(cslc.product_service_level__c==caseRec.product_service_level__c && (cslc.project_service_level__c==null ||cslc.project_service_level__c==''))
                                {
                                    //tempCSL=cslc.case_service_level__c;
                                    caseRec.case_service_level__c=cslc.case_service_level__c;
                                }
                                //combination 3
                                If((cslc.product_service_level__c==null ||cslc.product_service_level__c=='') && (caseRec.case_service_level__c==null ||caseRec.case_service_level__c=='') && cslc.project_service_level__c==caseRec.project_service_level__c)
                                {
                                    //tempCSL=cslc.case_service_level__c;
                                    caseRec.case_service_level__c=cslc.case_service_level__c;
                                }
                                //combination 4
                                if((cslc.product_service_level__c==null ||cslc.product_service_level__c=='')&&(cslc.project_service_level__c==null ||cslc.project_service_level__c==''))
                                {
                                    tempCSL1=cslc.case_service_level__c;
                                }
                                
                            }//end of if()
                        }//end of if()
                        else
                        {
                            if(cslc.contact_service_level__c==null ||  cslc.contact_service_level__c=='')
                            {
                                if(cslc.project_service_level__c==caseRec.project_service_level__c && cslc.product_service_level__c==caseRec.product_service_level__c)
                                    caseRec.case_service_level__c=cslc.case_service_level__c;
                                if((caseRec.case_service_level__c==null || caseRec.case_service_level__c=='')&&(cslc.project_service_level__c==null || cslc.project_service_level__c=='') && cslc.product_service_level__c==caseRec.product_service_level__c)
                                    caseRec.case_service_level__c=cslc.case_service_level__c;
                                if((caseRec.case_service_level__c==null || caseRec.case_service_level__c=='')&&(cslc.project_service_level__c==caseRec.project_service_level__c) && (cslc.product_service_level__c==null || cslc.product_service_level__c==''))
                                    caseRec.case_service_level__c=cslc.case_service_level__c;
                            }              
                        }
                        
                        
                    }//end of inner for()
                    if((caseRec.case_service_level__c==null || caseRec.case_service_level__c=='') && (tempCSL1!=null || tempCSL1!=''))
                    {
                        caseRec.case_service_level__c=tempCSL1;
                    }
                }//end of if()
                
            }//end of outer for()
            
            
        } 
        
    }
    
    */
    /****************************************************************
Case Trigger Consolidation
Modified by :Sumanth
Date:19-07-2017
Method to Calculate Case Priority
***************************************************************/
    
    public static void casePriority(list<Case> CaseList)
    {
        List<case> listCases = new List<case>();
        for(Case objCase: CaseList) 
        {
            if(objcase.isClosed==false)
            {
                listCases.add(objcase);
            }
        }
        if(listCases.size()>0 && listCases!=null)
        { 
            list<Case_Priority_Criteria__c> listCPC=[select Object__c,Field__c,Field_Value__c,Score__c from Case_Priority_Criteria__c];
            Map<String,list<Case_Priority_Criteria__c>> MapCPC=new Map<String,list<Case_Priority_Criteria__c>>();
            list<Id> listProjectIds=new list<Id>();
            for(Case caseRec:listCases){
                listProjectIds.add(caseRec.Projects__c);
            }
            map<Id,Project__c> mapProjects=new map<Id,Project__c>([select id,Type__c,Project_Service_Level__c from Project__c where id in:listProjectIds]);
            list<Case_Priority_Criteria__c> listCasesCPC=new list<Case_Priority_Criteria__c>();
            list<Case_Priority_Criteria__c> listcontactsCPC=new list<Case_Priority_Criteria__c>();
            list<Case_Priority_Criteria__c> listProjectsCPC=new list<Case_Priority_Criteria__c>();
            double score=0;
            for(Case_Priority_Criteria__c CPCRec:listCPC)
            {
                if(CPCRec.Object__c=='Case')
                    listCasesCPC.add(CPCRec);
                if(CPCRec.Object__c=='Project__C')
                    listProjectsCPC.add(CPCRec);
            }
            
            for(Case caseRec:listCases)
            {
                system.debug('caseRec-1::::'+caseRec.createddate);
                caseRec.score__c=0;
                if((caseRec.Priority!=null && caseRec.Priority!='' && caseRec.Internal_Priority__c!=null && caseRec.Internal_Priority__c!='')||(caseRec.Product_Category__c!=null && CaseRec.Product_Category__c!='' ))
                {
                    for(Case_Priority_Criteria__c CaseCPC:listCasesCPC)
                    {
                        if(CaseCPC.field__c=='Origin' && caseRec.Origin!=null && CaseCPC.field_value__c==caseRec.Origin)
                            caseRec.score__c+=CaseCPC.Score__c;
                        //standard priority as a factor
                        if(CaseCPC.field__c=='Priority' && CaseCPC.field_value__c==caseRec.Priority)
                            caseRec.score__c+=CaseCPC.Score__c;
                        //Internal priority as a factor for score calculation
                        if(CaseCPC.field__c=='Internal Priority' && CaseCPC.field_value__c==caseRec.Internal_Priority__c)
                            caseRec.score__c+=CaseCPC.Score__c;
                        //product as a factor
                        if(caseRec.Product__c!=null && caseRec.Product__c!='')
                        {
                            if(CaseCPC.field__c=='Product Lvl 1' && CaseCPC.field_value__c==caseRec.Product__c)
                                caseRec.score__c+=CaseCPC.Score__c;
                            
                            if(CaseCPC.field__c=='Product Lvl 2' && caseRec.Product_Category__c!=null && CaseCPC.field_value__c==caseRec.Product_Category__c)
                                caseRec.score__c+=CaseCPC.Score__c;
                            
                            if(CaseCPC.field__c=='Product Lvl 3' && caseRec.Product_Sub__c!=null && CaseCPC.field_value__c==caseRec.Product_Sub__c)
                                caseRec.score__c+=CaseCPC.Score__c;
                        }
                        
                        //contact service level as factor
                        if(caseRec.Contact_Service_Level__c!=null && caseRec.Contact_Service_Level__c!='')
                        {
                            if(CaseCPC.field__c=='Contact Service Level' && CaseCPC.field_value__c==caseRec.Contact_Service_Level__c)
                                caseRec.score__c+=CaseCPC.Score__c;
                        }
                    }
                }
                
                //project's type and priority fields are considered as score factors
                if(caseRec.Projects__c!=null)
                {
                    for(Case_Priority_Criteria__c CaseCPC:listProjectsCPC)
                    {
                        if(mapProjects.get(caseRec.Projects__c).Type__c!=null && mapProjects.get(caseRec.Projects__c).Type__c!='')
                        {
                            if(CaseCPC.field__c=='Type' && CaseCPC.field_value__c==mapProjects.get(caseRec.Projects__c).Type__c)
                                caseRec.score__c+=CaseCPC.Score__c;
                        }
                        if(mapProjects.get(caseRec.Projects__c).Project_Service_Level__c!=null && mapProjects.get(caseRec.Projects__c).Project_Service_Level__c!='')
                        {
                            if(CaseCPC.field__c=='Ent-Priority' && CaseCPC.field_value__c==mapProjects.get(caseRec.Projects__c).Project_Service_Level__c)
                                caseRec.score__c+=CaseCPC.Score__c;
                        }
                    }
                }
            }
        }
    }  
    /****************************************************************
Case Trigger Consolidation
Modified by :Sumanth
Date:19-07-2017
Method to Calculate Case Due date on update
***************************************************************/
    
    public static void CalculateDueDate(list<Case> CaseList,map<id,Case> MapCasesOld) 
    {    
        
        List<case> listCasesNew= new List<case>();
        
        for(Case objCase: CaseList) 
        {
            if(objcase.isClosed==false)
            {
                listCasesNew.add(objcase);
                
            }
            
        }
        
        
        boolean matchfound=false;
        Integer tempPriority1=0;
        base_value_for_case_priority_calculation__c Objbase= base_value_for_case_priority_calculation__c.getValues('Base');
        base_value_for_case_priority_calculation__c ObjZeroScore=base_value_for_case_priority_calculation__c.getValues('Negative_Zero_Score_Hours');
        list<caseHistory> listcaseHistory=new list<caseHistory>();         
        map<id,case> mapCaseshistory=new map<id,case>([select id,status, (select field,OldValue, NewValue from Histories where field=:'status')from Case where id in:listCasesNew]);
        
        for(case caseRec:listCasesNew)
        { //system.debug('caseRec-1::::'+caseRec.createddate);
            matchfound=false;
            listcaseHistory=mapCaseshistory.get(caseRec.id).histories;
            //system.debug('listcaseHistory::'+listcaseHistory);
            if( MapCasesOld.get(caseRec.id)!=null) 
            {
                //calculate due date when priority changes
                if(caseRec.priority!=null && caseRec.priority!='' )
                {
                    //system.debug('map old priority::'+MapCasesOld.get(caseRec.id).priority);
                    //system.debug('map old :'+MapCasesOld.get(caseRec.id));
                    //system.debug('map new :'+caseRec);
                    //system.debug('caseRec.priority::'+caseRec.Internal_Priority__c);
                    if(caseRec.Internal_Priority__c!=MapCasesOld.get(caseRec.id).Internal_Priority__c)
                    {
                        
                        for(caseHistory caseHistoryRec:listcaseHistory)
                        {
                            
                            if(caseHistoryRec.oldvalue=='Pending Internal' ||caseHistoryRec.newvalue=='Pending Internal' ||
                               caseHistoryRec.oldvalue=='Pending Customer Reply' ||caseHistoryRec.newvalue=='Pending Customer Reply' ||
                               caseHistoryRec.oldvalue=='Received Reply' ||caseHistoryRec.newvalue=='Received Reply')
                            {
                                matchfound=true;
                                break;
                                
                            }
                            
                        }
                        //system.debug('caseRec.score__c::'+caseRec.score__c);
                        if(Objbase!=null)
                        {
                            if(matchfound==false && Objbase.base_value__c!=null)
                            {
                                if(caserec.score__c<=0 && ObjZeroScore!=null)
                                {
                                    
                                    caseRec.due_Date__c=System.now().addHours((Integer)ObjZeroScore.base_value__c);
                                }
                                else
                                {
                                    caseRec.due_Date__c=caserec.createddate.addhours((Integer) Math.ceil(Objbase.base_value__c/caserec.score__c));
                                    //system.debug(caseRec.due_Date__c);
                                }
                            }
                        }
                    }
                }
                //calculate due date when status changes
                if(caseRec.status!=MapCasesOld.get(caseRec.id).status && caseRec.status=='Pending Customer Reply')
                    caseRec.due_Date__c=system.now().addhours(84);
                if(caseRec.status!=MapCasesOld.get(caseRec.id).status && caseRec.status=='Pending Internal')
                    caseRec.due_Date__c=system.now().addhours(72);    
                if(Objbase!=null)
                {
                    
                    if(caseRec.status!=MapCasesOld.get(caseRec.id).status && caseRec.status=='Received Reply' && Objbase.base_value__c!=null)
                    {
                        if(caserec.score__c<=0 && ObjZeroScore!=null)
                        {
                            if(ObjZeroScore.base_value__c!=null)
                            {
                                caseRec.due_Date__c=System.now().addhours((Integer) Math.ceil(ObjZeroScore.base_value__c/2));
                            }
                        }
                        else
                        {
                            caseRec.due_Date__c=system.now().addhours((Integer) Math.ceil((Objbase.base_value__c/caserec.score__c)/2));
                        }
                        if(caserec.score__C !=0 && caserec.score__C!=null ){
                            caseRec.due_Date__c=system.now()+(((Objbase.base_value__c/caserec.score__C)/2))/1440;
                        }
                    }         
                }     
                
                
            }
            //system.debug('map old 1 :'+MapCasesOld.get(caseRec.id));
            //system.debug('map new 1:'+caseRec);  
        }
    }
    
    /****************************************************************
Case Trigger Consolidation
Modified by :Sumanth
Date:19-07-2017
Method that determines/Verifies Entitlement Pattern
***************************************************************/
    
    public static void projectIdentificationForCases(list<case> CaseNewList,Map<Id,Case> CaseNewMap,list<case> CaseOldList,Map<Id,Case> CaseOldMap)
    {
        list<Case> listCases=new list<Case>();
        if(CaseOldList==null)
        {
            for (Case objCase: CaseNewList)
            {
                if(objcase.isClosed==false && objcase.origin=='Forum')
                {
                    listCases.add(objCase);
                }
            }
        }
        else if(CaseOldList!=null)
        {
            for(case caseRec:CaseNewList)
            {
                if(caseRec.description!=CaseOldMap.get(caseRec.id).description && caseRec.Isclosed==false && caseRec.origin=='Forum')
                {
                    listCases.add(caseRec);
                }
            }
        }
        if(listCases.size()>0 && listCases!=null)
        {
            string strUniqueIdentifier;
            map<string,id> mapPattern=new map<string,id>();
            list<string> listPattern=new list<string>();
            map<id,string> mapCasePattern=new map<id,string>();
            for(case caseRec:listCases)
            {
                if(caseRec.Description!=null && caseRec.Description!='' )//&& caseRec.Description.contains(label.Community_unique_pattern_for_email_service+'[a-z|A-Z|0-9]{1,8}[0-9]{6}'))
                {
                    Pattern objPattern1= Pattern.compile('[CONTEXT::|context::][a-z|A-Z|0-9]{1,8}[0-9]{6}');
                    Matcher objMatcher1= objPattern1.matcher(caseRec.Description);
                    if(objMatcher1.find())
                    {
                        strUniqueIdentifier=objMatcher1.group(0);
                    }
                    Pattern objPattern2= Pattern.compile('[a-z|A-Z|0-9]{1,8}[0-9]{6}');
                    Matcher objMatcher2;
                    if(strUniqueIdentifier!=null)
                    {
                        objMatcher2= objPattern2.matcher(strUniqueIdentifier);
                    }
                    
                    if(objMatcher2!=null && objMatcher2.find(1))
                    {
                        mapCasePattern.put(caseRec.id,objMatcher2.group(0));
                        listPattern.add(objMatcher2.group(0));
                    }
                }
            }//end of for
            if(listPattern.size()!=0 && listPattern!=null)
            {
                for(Project__c prjtRec:[select id,Project_Pattern__c from Project__c where Project_Pattern__c in:listPattern])// mapCasePattern.values()])
                {
                    mapPattern.put(prjtRec.Project_Pattern__c,prjtRec.id);   
                }
            }
            for(case caseRec:listCases)
            {
                caseRec.Projects__c=null;
                if(mapPattern!=null)
                {
                    for(string pattern:listPattern)
                    {
                        if(caseRec.description!=null && caseRec.description!='' && caseRec.description.contains(pattern))
                        {
                            caseRec.Projects__c=mapPattern.get(pattern);
                            break;
                        }
                    }
                }
            }
        }
    }
    
    
    
    /****************************************************************
Case Trigger Consolidation
Added by :Sumanth
Date:17-07-2017
Method that sets autorepsonseEmail= true for Cases with Record Type 'TS_Webmaster' & 'TS_Community'
***************************************************************/
    
    public static void setAutoResponseEmail(List<Case> CaseList)
    {
        
        String CASE_TSWEBMASTER = 'TS_Webmaster';
        String CASE_TSCOMMUNITY = 'TS_Community';
        String CASE_TSAUTOGroup = 'TS_AUTO_Group';
        String CASE_TSDNGroup =   'TS_DN_Group';
        String CASE_TSMICRGroup = 'TS_MICR_Group';
        String CASE_GSAS='CRM_Issues';
        
        Id tsGSASRT= Schema.SObjectType.Case.getRecordTypeInfosByName().get('GSAS Issues').getRecordTypeId();
        
        //Get the record type
        List<RecordType> lstRecordTypes = [Select Id, DeveloperName 
                                           From RecordType Where SobjectType = 'Case' and 
                                           (
                                               DeveloperName =: CASE_TSWEBMASTER 
                                               or DeveloperName=: CASE_TSCOMMUNITY  
                                               or DeveloperName=: CASE_TSAUTOGroup 
                                               or DeveloperName=: CASE_TSDNGroup
                                               or DeveloperName=: CASE_TSMICRGroup
                                               or DeveloperName=: CASE_GSAS) and IsActive=true
                                           Limit 6];
        
        List<Case> lstCases = new List<Case>();
        Set<Id> caseRecordTypeSet = new Set<Id>();    
        
        
        //Logic
        if(lstRecordTypes.size() > 0)
        {
            for(RecordType rt : lstRecordTypes)
            {
                caseRecordTypeSet.add(rt.Id);
            }        
            for(Case objCase : CaseList)
            {
                if(caseRecordTypeSet.contains(objCase.RecordTypeId) && objCase.Origin !='Forum')
                {
                    Case objCse = new Case(Id = objCase.Id);
                    lstCases.add(objCse);
                }              
            }
            
            if(lstCases.size() > 0)
            {
                
                Database.DMLOptions dmlOptions = new Database.DMLOptions(); 
                //dmlOptions.emailHeader.triggerUserEmail = true;
                //dmlOptions.assignmentRuleHeader.useDefaultRule = true;          
                dmlOptions.EmailHeader.triggerAutoResponseEmail = true;           
                for(Case objCase : lstCases)
                {
                    objCase.setOptions(dmlOptions);
                }
                
                update lstCases;
            }
        }
    }
    
    
    
    /****************************************************************
Case Trigger Consolidation
Added by :Sumanth
Date:17-07-2017
Method that deletes cases with case origin ="Unkown contact"
***************************************************************/
    
    public static void deleteCaseWithUnkownContact(List<Case> CaseList)
        
    {
        
        List<Case> listDeleteCase=new List<case>();
        
        
        for(Case objCase : CaseList)
        {
            if(objCase.origin=='UnknownContact')
                listDeleteCase.add(objCase);
            
        }
        if(listDeleteCase.size()>0)
        {
            DeleteCases();
        }
        
        
    }
    
    
    
    /****************************************************************
Case Trigger Consolidation
Added by :Sumanth
Date:18-07-2017
Method to calculate Due date when Case is Inserted
***************************************************************/
    public static void dueDateInsert(List<Case> CaseList)
    {
        //RecordType tsRecordType=[Select Id,name from recordtype where name='TS Community' LIMIT 1];
        base_value_for_case_priority_calculation__c Objbase= base_value_for_case_priority_calculation__c.getValues('Base');
        base_value_for_case_priority_calculation__c ObjZeroScore=base_value_for_case_priority_calculation__c.getValues('Negative_Zero_Score_Hours');
        
        for (Case caseRec: CaseList)
        {
            
            //-----------Due date claculation----------------------------------------------------
            if(caseRec.RecordTypeId==tscommunityRT)
            {
                
                
                caseRec.Internal_Priority__c=caseRec.priority;
                //System.debug(caserec);
                //System.debug(caserec.score__c);
                //System.debug(Objbase);//.base_value__c);
                //System.debug(caserec);
                if(Objbase!=null)
                {
                    if(caseRec.status=='New' && Objbase.base_value__c!=null)
                    {
                        if(caserec.score__c<=0 && ObjZeroScore!=null )
                        {       
                            if(ObjZeroScore.base_value__c!=null)          
                                caseRec.due_Date__c=System.now().addHours((Integer) ObjZeroScore.base_value__c);
                        }
                        else
                        {
                            //system.debug('Now::'+System.now());
                            caseRec.due_Date__c=System.now().addhours((Integer) Math.ceil(Objbase.base_value__c/caserec.score__c));
                            //system.debug('hours::'+(Objbase.base_value__c/caserec.score__c)+'---- ceiled val::'+(Integer) Math.ceil(Objbase.base_value__c/caserec.score__c));
                            //system.debug('caseRec.due_Date__c::'+caseRec.due_Date__c);
                        }
                    }
                }
            }     
            
        }
    }
    
    
    
    /****************************************************************
Case Trigger Consolidation
Added by :Sumanth
Date:18-07-2017
Method to convert country value to USA if coming from Web form
***************************************************************/
    
    public static void convertCountryValuetoUSA(List<Case> CaseList)
    {
        for(Case caseRec:CaseList)
        {
            if(caseRec.Web_Country__c!=null || caseRec.Web_Country__c!='')
            {
                if(caseRec.Web_Country__c=='United States of America')
                {
                   // System.debug('Case Web Country is United States???????????????????????????????'+caseRec.Web_Country__c);
                    caseRec.Web_Country__c='USA';
                }
            }
        }  
    }
    
    
    /****************************************************************
Case Trigger Consolidation
Added by :Sumanth
Date:19-07-2017
Method to update certain case fields on case insert
***************************************************************/
    
    public static void updateCaseFieldsonInsert(List<Case> CaseList)
    {
        
        for(Case caseRec:CaseList)
            
        {
            //Modified by shridevi-SIR 1015-replaced the case origin from community to Self Service Portal and  extended the functionlaity to case origin Forum 
            system.debug('updatecasefieldoninsert'+ caseRec.Contact_Title__c);
            if(caseRec.Origin=='Self Service Portal' || caseRec.Origin=='Forum')
            {   system.debug('updatecasefieldoninsert'+ caseRec.Contact_Title__c); 
                caseRec.SuppliedCompany=caseRec.Company__c;
                caseRec.SuppliedPhone=caseRec.Phone_Number__c;
                caseRec.SuppliedName=caseRec.First_Name__c+' '+caseRec.Last_Name__c;
                caseRec.SuppliedEmail=caseRec.Email__c;
                caseRec.Web_Country__c=caseRec.Community_Web_Country__c;
                caseRec.Web_State__c=caseRec.State_Province__c;
                if(caseRec.Origin=='Forum'){
                    caseRec.Contact_Title__c= caseRec.JobTitle__c;
                }
                caseRec.My_question_is_about__c=caseRec.My_Question_is_Related__c;
                caseRec.Case_Owner_Name__c=caseRec.Owner.Name;
            }
            
        }
    }
    
    
    
    /****************************************************************
Case Trigger Consolidation
Added by :Sumanth
Date:19-07-2017
Method to update Case Fields like MAG,BU,BL from Related Product Information
***************************************************************/
    
    public static void updateCaseFieldsWithProductInfo(List<Case> CaseNewList,Map<Id,Case> CaseNewMap,Map<Id,Case> CaseOldMap)
    {
        Map<Id,Id>CaseProductIDMap = new Map<Id,Id>();
        
        Map<Id,Product2>productIdMap;
        List<Case> caseList = [Select Id, Product_Name__c from Case where Id In : CaseNewList];
        List<String>ProductIdList= new List<String>();
        if(caseList.size()>0)
        {
            for(Case ca : caseList)
            {
                if(CaseNewMap.get(ca.Id).Product_Name__c!=null || CaseNewMap.get(ca.Id).Product_Name__c !='')
                {
                    ProductIdList.add(CaseNewMap.get(ca.Id).Product_Name__c);
                }
            }
        }
        
        
        if(ProductIdList.size()>0)
        {
            productIdMap = new Map<Id,Product2>([Select Id,BL__c,BL_Description__c,BU__c,BU_Description__c,MAG__c,
                                                 MAG_Description__c,Basic_Type__c,Basic_Type_Description__c,Sales_Item__c,X9NC__c,Product_Type__c from product2 where Id In : ProductIdList]);
        }
        System.debug('<<<<<<<<<<<<<<<<<<<<<<<<Product Map >>>>>>>>>>>>>>>>>>>>>'+productIdMap);
        
        for(Case c: CaseNewList)
        {
            if(c.Product_Name__c!=null || c.Product_Name__c!=' '){
                CaseProductIDMap.put(c.Id,c.Product_Name__c);
            }
            //System.debug('<<<<<<<<<<<<<<<<<<<<<<<<<<<<'+CaseOldMap.get(c.ID).Contact_Title__c);
            
            /*if( c.JobTitle__c!=(CaseOldMap.get(c.ID)).Contact_Title__c  )
{

c.Contact_Title__c= c.JobTitle__c;

}*/
            
            if( c.My_Question_is_Related__c !=(CaseOldMap.get(c.ID)).My_Question_is_Related__c )
                
            {
                
                c.My_question_is_about__c = c.My_Question_is_Related__c;
                
            }
            
            //.............................................................................
            if(!productIdMap.IsEmpty())
                
            {
                
                //System.debug('<<<<<<<<<<<<<<Prodcut info'+c.Product_Name__c);
                if(c.Product_Name__c!=null || c.Product_Name__c!=' ')
                { 
                    if(productIdMap.get(c.Product_Name__c) != NULL)
                    {       
                        c.BL__c=productIdMap.get(c.Product_Name__c).BL__c;
                        
                        
                        c.X9NC__c=productIdMap.get(c.Product_Name__c).X9NC__c;
                        c.BL_Description__c=productIdMap.get(c.Product_Name__c).BL_Description__c;
                        c.BU__c=productIdMap.get(c.Product_Name__c).BU__c;
                        c.BU_Description__c=productIdMap.get(c.Product_Name__c).BU_Description__c;
                        c.MAG__c=productIdMap.get(c.Product_Name__c).MAG__c;
                        c.MAG_Description__c=productIdMap.get(c.Product_Name__c).MAG_Description__c;
                        c.Sales_Item__c=productIdMap.get(c.Product_Name__c).Sales_Item__c;
                        c.Basic_Type_Description__c=productIdMap.get(c.Product_Name__c).Basic_Type_Description__c;
                        c.Basic_Type__c=productIdMap.get(c.Product_Name__c).Basic_Type__c;
                        c.Product_Type_Number__c=productIdMap.get(c.Product_Name__c).Product_Type__c;
                    }
                }   
            }
        }
    }
    
    /***************************************************************
Modified By     :    Kumaresh M
Modified Date   :    11 Apr2019
Description     :    SFDC-2692-Cases for Paid Support: Project hours counting robustness improvement
The Logic is Completed Re-written as the Previous Logic few Functionalities are not working Perfectly.
***************************************************************/
    
    public static void projectUpdate(List<Case> CaseNew,Map<Id,Case> CaseOld)
    {
        set<Id> projectIds = new set<Id>(); // To get the Updated Case record ID's
        
        for(Case ca:CaseNew)
        {
            //system.debug('projectUpdate case values'+ca);
            Case caseOldObj = CaseOld.get(ca.Id);
            if((ca.Projects__c != null || ca.Projects__c != '') && (caseOldObj != null) && ca.Hours_spent_by_Support_person__c != caseOldObj.Hours_spent_by_Support_person__c)
            {
                projectIds.add(ca.Projects__c);
            }
            if((ca.Projects__c != caseOldObj.Projects__c) && ((caseOldObj != null))){
                projectIds.add(ca.Projects__c);
                projectIds.add(caseOldObj.Projects__c);
            }
        }
        List<Project__c > lstProjectToUpdate = new List<Project__c >();
        
        //Map to retrieve new version of Project and it's Case Child Record that has been either inserted or Updated
        if(projectIds.size() > 0){
            for(Project__c objProject : [Select Id,Used_number_of_Hours__c,(select Id,Projects__c,Hours_spent_by_Support_person__c from Cases__r) from Project__c 
                                         Where Id in :projectIds ])
            {
                Decimal totalHours = 0;
                for(Case ca: objProject.Cases__r)
                {
                    if(ca.Hours_spent_by_Support_person__c != null ){
                        totalHours += ca.Hours_spent_by_Support_person__c;
                    }
                }            
                objProject.Used_number_of_Hours__c = totalHours;
                lstProjectToUpdate.add(objProject);            
            }
            if(lstProjectToUpdate.size() > 0)
            {
                Update lstProjectToUpdate;
            }
        }
    }    
    
    public static void assignGsasCases(List<Case> CaseList)
    {
        
        List<Case> RelevantCases = new List<Case>();
        Id tsGSASRT= Schema.SObjectType.Case.getRecordTypeInfosByName().get('GSAS Issues').getRecordTypeId();
        
        for(Case C:CaseList)
        {
            
            if(C.recordtypeid==tsGSASRT)
            {
                Case objCse = new Case(Id = C.Id);
                RelevantCases.add(objCse);
                
                
            }
            
        }
        
        if(RelevantCases.size() > 0)
        {
            
            Database.DMLOptions dmlOptions = new Database.DMLOptions(); 
            dmlOptions.emailHeader.triggerUserEmail = true;
            dmlOptions.assignmentRuleHeader.useDefaultRule = true;          
            
            for(Case objCase : RelevantCases)
            {
                objCase.setOptions(dmlOptions);
            }
            
            update RelevantCases;
        }
    }
    
    // Created this method as part of SFDC-2078 , To create the contact along with case if contact doesnt exist.
    public static void createContact(List<Case> caseList){
        List<String> emailAddresses = new List<String>();
        List<Account> objAcc = new List<Account>();
        for (Case caseObj:caseList) {
            
            if (caseObj.SuppliedEmail!='' || caseObj.SuppliedEmail!=Null)
            {
                system.debug('Value of caseObj.SuppliedEmail'+ caseObj.Contact_Title__c);
                system.debug('Value of caseObj.SuppliedEmail1'+ caseObj.Email__c);
                emailAddresses.add(caseObj.SuppliedEmail);
                
            }
        }
        List<Contact> listContacts = [Select Id, Email From Contact Where Email in :emailAddresses];
        Set<String> takenEmails = new Set<String>();
        if(listContacts != Null){
            for (Contact c:listContacts) {
                takenEmails.add(c.Email);
            }
        }
        system.debug('Value of takenEmails'+takenEmails);
        List<Contact> lstContact = new List<Contact>(); 
        Map<String,Contact> emailToContactMap = new Map<String,Contact>();
        
        List<Case> lstCasesToUpdate = new List<Case>();
        objAcc = [Select Id,Name from Account where Name = 'NXP Community' limit 1];
        
        system.debug('Value of AccountId is'+objAcc);
        system.debug('createContact1 ' +caseList);
        for(Case objCase:caseList){
            
            if (!takenEmails.contains(objCase.SuppliedEmail)&& objCase.ContactId==null && objCase.Web_First_Name__c!=null &&
                objCase.Web_First_Name__c!='' && objCase.Web_Last_Name__c!='' && objCase.Web_Last_Name__c!=null &&
                objCase.SuppliedEmail!=null && objCase.SuppliedEmail!='' && objAcc!=Null ){
                    
                    String strCountry;
                    if(objCase.Community_web_country__c != null){
                        strCountry = objCase.Community_web_country__c;
                    }
                    else{
                        strCountry = 'Unknown';
                    }
                    Contact objCont = new Contact(FirstName=objCase.Web_First_Name__c,
                                                  LastName=objCase.Web_Last_Name__c,
                                                  Email=objCase.SuppliedEmail,
                                                  AccountId = objAcc[0].Id,
                                                  Community_web_country__c=strCountry 
                                                 );
                    emailToContactMap.put(objCase.SuppliedEmail,objCont);
                    lstCasesToUpdate.add(objCase);
                    //system.debug('createContact ' +lstCasesToUpdate);                            
                    
                }          
        }
        system.debug('createContact 2' );
        if(emailToContactMap != Null){
            lstContact = emailToContactMap.values();
        }
        system.debug('createContact ' +lstContact );
        if(lstContact !=Null){
            insert lstContact;
        }
        for (Case caseObj:lstCasesToUpdate) {
            
            if(emailToContactMap !=Null && emailToContactMap.containsKey(caseObj.SuppliedEmail)==True && emailToContactMap.get(caseObj.SuppliedEmail)!=Null){
                Contact newContact = emailToContactMap.get(caseObj.SuppliedEmail);
                caseObj.ContactId = newContact.Id;
            } 
            
        }
    }
    
    public static void updateNoOfCases(List<Case> caseList, Map<Id,Case> oldCaseMap){
        Set<Id> projId = new Set<id>();
        List<Project__c> prjLst = new List<Project__c>();
        for (Case objCase: caseList) 
        {
            if(objCase.Projects__c != null )
            {
                projId.add(objCase.Projects__c);
            }
            // system.debug('updateNoOfCasesoldCaseMapobjCase.Projects__c'+ oldCaseMap.get(objCase.Id).Projects__c);
            
            if((oldCaseMap != null) && (oldCaseMap.get(objCase.Id).Projects__c != null) && (objCase.Projects__c != oldCaseMap.get(objCase.Id).Projects__c)){
                projId.add(oldCaseMap.get(objCase.Id).Projects__c);
            }
        } 
        
        if(!projId.isEmpty()){
            prjLst = [SELECT Id,(SELECT id,CreatedDate FROM Cases__r ORDER BY CreatedDate DESC),Cases_Per_Project__c FROM Project__c WHERE Id  in : projId];
        }
        List<Project__c> updateLst = new List<Project__c>();
        if(!prjLst.isEmpty()){  
            for(project__c eachProj : prjLst)
            {
                eachProj.Cases_Per_Project__c = eachProj.Cases__r.size();
                eachProj.Last_Case_Created_Date_Time__c = (eachProj.Cases__r.size() > 0 ? eachProj.Cases__r[0].CreatedDate : null);
                updateLst.add(eachProj);
            }
            
            if(!updateLst.isEmpty()){
                try{
                    update updateLst;
                }
                catch(Exception e){
                    System.debug('The following exception has occurred: ' + e.getMessage());
                }
            } 
        } 
    }  
    public static void grantAccessToCases(List<Case> lstCases, Map<Id, Case> mapOldCases)
    {
        
        List<Case> lstCasesToProcess = new List<Case>();
        for(Case objCase :lstCases)
        {
            system.debug('objCase1' + objcase.Contact_Title__c);
            if(objCase.Projects__c != null)
            {
                lstCasesToProcess.add(objCase);
            }
        }
        
        if(lstCasesToProcess.size() > 0)
        {
            CasePortalUtil.shareCaseAccesstoTheTeam(lstCasesToProcess, mapOldCases) ;  
        }
    }
    
    /****************************************************************
    Case Trigger 
    Added by :Bhagya
    Date:12-08-2019
    Send notification to all invitees on creation of case SFDC-3610
    ***************************************************************/
    public static void sendCaseCreateNotification(List<Case> lstCases){
        
        Set<Id> ProjectId = new Set<Id>();
        
        for(Case objCase:lstCases )
        {
            system.debug('objcaseAfterInsert' +objCase.Contact_Title__c);
            if(objCase.RecordTypeId == tscommunityRT && objCase.Projects__c != null)
            {
                ProjectId.add(objCase.Projects__c); 
            }
        }
        
        Map<Id, List<String>> projToProjTeamEmailMap = new Map<Id, List<String>>();
        
        if(ProjectId.size() > 0)
        {   
           
            for(Project_Team__c objProjTeam : [SELECT Project__c,Email_Address__c 
                                               From Project_Team__c where status__c = : CasePortalUtil.PROJECT_TEAM_STATUS_ACCEPTED and Project__c = :ProjectId ])
            {
                if(projToProjTeamEmailMap.containsKey(objProjTeam.Project__c)){
                    projToProjTeamEmailMap.get(objProjTeam.Project__c).add(objProjTeam.Email_Address__c);
                }
                else{
                    projToProjTeamEmailMap.put(objProjTeam.Project__c, new List<String>{objProjTeam.Email_Address__c});
                }
            }             
            
            Id orgDefaultEmailAddressId;
            List<OrgWideEmailAddress> lstDefaultOrgEmailAddress = CasePortalUtil.getOrgWideEmailAddress();
            for(OrgWideEmailAddress objDefaultEmailAddress :lstDefaultOrgEmailAddress ){
                if(objDefaultEmailAddress.DisplayName == Label.CommunityDefaultOrgName)
                    orgDefaultEmailAddressId = objDefaultEmailAddress.Id;
            } 
                      
            EmailTemplate emailTemplate=[select Id, Subject, Body ,HtmlValue  from EmailTemplate where DeveloperName = 'CaseCreateNotificationToActiveProjectMembers'];
            
            if( emailTemplate !=null ){
                List<String> lstEmailAddresses = new List<String>();
                List<Messaging.Singleemailmessage> emailLst = new List<Messaging.Singleemailmessage>();
                for(Case caseObj:lstCases ){
                    if(caseObj.Projects__c != null && caseObj.ContactId != null )
                    {

                        if(projToProjTeamEmailMap.size()>0){
                            for(String strInviteeEmail : projToProjTeamEmailMap.get(caseObj.Projects__c)){
                                if(strInviteeEmail != caseObj.Email_Contact__c ){
                                   lstEmailAddresses.add(strInviteeEmail);
                                }
                            }
                        
                            if(lstEmailAddresses.size()>0){
                                Messaging.Singleemailmessage objEmailMessage = new Messaging.Singleemailmessage();
                                objEmailMessage.setWhatId(caseObj.id);
                                objEmailMessage.setTemplateId(emailTemplate.Id);
                                objEmailMessage.setToaddresses(lstEmailAddresses);
                               
                                if(orgDefaultEmailAddressId != null){
                                    objEmailMessage.setOrgWideEmailAddressId(orgDefaultEmailAddressId);
                                }
                                
                                objEmailMessage.setCharset('UTF-8');
                                objEmailMessage.setTargetObjectId(caseObj.ContactId);
                                objEmailMessage.setTreatTargetObjectAsRecipient(false); 
                                emailLst.add(objEmailMessage);      
                            }
                        }
                    }
                }
                
                if(emailLst.size()>0){
                    List<Messaging.SendEmailResult> results = Messaging.sendEmail(emailLst);
                }
            }
        }
    }
    
     /**************************************************************** 
    Added by :Gunjan
    Date:08-01-2019
    Method to update user record (Implemented as part of SFDC-2833)
    ***************************************************************/
    public static void updateUsersHasCreatedCaseField(List<Case> lstNewCases){
        Set<Id> setCaseId = new Set<Id>();
        for(Case objCase:lstNewCases)
        {
            if(objCase.RecordTypeId == tscommunityRT)
            {
                setCaseId.add(objCase.Id);      
            }
        }
        if(setCaseId.size()>0){
             User objUser = [Select id, HasCreatedCases__c,HasCreatedProjects__c FROM User where id =: UserInfo.getUserId()];
             system.debug('Value of HasCreatedCases'+ objUser.HasCreatedCases__c);
             if(objUser.HasCreatedCases__c == FALSE){
                 objUser.HasCreatedCases__c = TRUE;
                 update objUser; 
             }
        }
    }
      
    
    /*
* @name         : getThreadId
* @description  : to generate the thread ID
* @ Input param : void
* @ return type : void
*/ 
    public static String getThreadId(Id caseId) {
        return 
            'ref:_' + shortenId(UserInfo.getOrganizationId()) +
            '._'    + shortenId(caseId) +  ':ref';
    }
    
    /*
* @name         : shortenID
* @description  : to generate the reference ID
* @ Input param : void
* @ return type : void
*/ 
    public static String shortenID(String idValue) {
        String[] keys = idValue.left(15).split('');
        while(keys.size() > 5 && keys[5] == '0') {
            keys.remove(5);
        }
        return String.join(keys,'');
    }
}