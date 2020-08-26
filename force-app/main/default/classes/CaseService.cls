/***************************************************************************************************
@Created By :      Ranganath C N
@Created Date:     08 May 2018
@Description:      SFDC-1601-Webservice to get CaseDetails 
*******************************************************************************************************/

/***************************************************************************************************
@Modified By :     Gunjan Singh
@Created Date:     16 Oct 2018
@Description:      SFDC-2237-Webservice GetCaseInformation get modified
*******************************************************************************************************/


//REST service to get Case details
@RestResource(urlMapping='/CaseService/*')
global with sharing class CaseService{
   
    //Wrapper class for sending case details
    global class CaseDetailsToBeSent{
        public String CaseOwnerName;
        public String CaseID;
        public String Subject;
        public String Priority;
        public String Status;
        public String Description;
        public String Origin;
        public String RecordType;
        public String AssignedToUserName;
        public String AssignedToUserEmail;
        public String Topic;
        public String ProductName;
        public String ContactServiceLevel;
        public String CaseNumber;
        public String ContactAccountName;
        public String ContactEmail;
        public String ContactCompany;
        public String ContactCountry;
        public String ContactName;
        public datetime LastContactToCustomer;
        public String CommunityGroupName;
        public String CommunityTopicName;
        public String CommunityOriginId; 
        public String CommunityQuestionURL;
        public Decimal QuestionResolutionCode;
        public String ErrorMessage;
        
    }
   
    @HttpGet
    global static List<CaseDetailsToBeSent> getCaseInformation(){
        List<Case> caseRecords = new List<Case>();
        List<String> lstStatusFilter = new List<String>();
        List<String> lstOriginFilter = new List<String>();
        List<CaseDetailsToBeSent> caseDetailsSent = new List<CaseDetailsToBeSent>();
        
        // Input Coming from WebService
        String CaseIdOrUserEmail = RestContext.request.params.get('CaseIdOrEmail');
        String StatusFilter = RestContext.request.params.get('StatusFilter');
        if(StatusFilter != null){
            lstStatusFilter = StatusFilter.split(',');
        }
        
        String OriginFilter = RestContext.request.params.get('OriginFilter');
        if(OriginFilter!= null){
            lstOriginFilter = OriginFilter.split(',');
        }
        
        system.debug('Value of CaseIdOrUserEmail '+CaseIdOrUserEmail);
        system.debug('Value of StatusFilter '+StatusFilter);
        system.debug('Value of OriginFilter '+OriginFilter);
        
        if(CaseIdOrUserEmail != Null){
            String soqlQuery = 'Select id,Owner.Name,Case_Owner_Name__c,Last_Contact_to_Customer__c,Community_Topic_Name__c,RelatedToId__c,Community_Question_URL__c,Question_Resolution_Code__c,Community_Group_Name__c,Product_Name__r.Name,subject,priority,status,description,origin,RecordType.Name,Assigned_to__r.name,Assigned_to__r.Email,My_Question_is_Related__c,Product.Name,Contact_Service_Level__c,casenumber,Account.name,Email_Contact__c,Company__c,Community_Web_Country__c,contact.name from case';
            if(CaseIdOrUserEmail.contains('@')){
                soqlQuery = soqlQuery + ' where Assigned_to__r.email =\''+ CaseIdOrUserEmail +'\'';
            }else{
                soqlQuery = soqlQuery + ' where Id =\''+  CaseIdOrUserEmail +'\''; 
            }
            
            if(StatusFilter != Null){
                Boolean first = true;
                for(String filterStatus : lstStatusFilter){
                    if(!first){
                        soqlQuery += ' OR ';
                    } else {
                        soqlQuery += ' AND (';
                    }
                soqlQuery = soqlQuery + ' status LIKE \'%' + filterStatus + '%\'';
                first = false;
                }
                
                soqlquery = soqlQuery + ')';
            }
            
            if(OriginFilter!= Null){
                Boolean first = true;
                for(String filterStatus : lstOriginFilter){
                    if(!first){
                        soqlQuery += ' OR ';
                    } else {
                        soqlQuery += ' AND (';
                    }
                soqlQuery = soqlQuery + ' origin LIKE \'%' + filterStatus + '%\'';
                first = false;
                }
                
                soqlquery = soqlQuery + ')';
            }
            
            /*if(OriginFilter != Null){
                soqlQuery = soqlQuery + ' And origin =\''+ OriginFilter +'\'';
            
            }*/
            
            system.debug('Value of query' + soqlQuery);
            caseRecords = Database.query(soqlQuery);
            for(Case objCase: caseRecords){
                CaseDetailsToBeSent caseDetails = mapCaseSObjectToWrapperClass(objCase,'No Error');
                system.debug('Value of caseDetails '+' '+caseDetails);
                caseDetailsSent.add(caseDetails);
            }
            
            return caseDetailsSent;
            
        }
        else{
            system.debug('Inside Else');
            CaseDetailsToBeSent caseDetails = mapCaseSObjectToWrapperClass(null,'CaseId or UserEmail are mandatory fields. Please send any one of them as input to web service');
            caseDetailsSent.add(caseDetails);
            return caseDetailsSent;
        }
        return null;
    }
    
    
    private static CaseDetailsToBeSent mapCaseSObjectToWrapperClass(Case objCase,String strMessage){
        CaseDetailsToBeSent caseDetails = new CaseDetailsToBeSent();
        if(objCase!=null){
            caseDetails.CaseID = objCase.id;
            caseDetails.CaseOwnerName= objCase.Owner.Name;
            caseDetails.Subject =  objCase.subject;
            caseDetails.Priority =  objCase.priority;
            caseDetails.Status =  objCase.status;
            caseDetails.Description =  objCase.description;
            caseDetails.Origin =  objCase.origin;
            caseDetails.RecordType =  objCase.RecordType.Name;
            caseDetails.AssignedToUserName = objCase.Assigned_to__r.name;
            caseDetails.AssignedToUserEmail = objCase.Assigned_to__r.Email;
            caseDetails.Topic =  objCase.My_Question_is_Related__c;
            caseDetails.ProductName =  objCase.Product_Name__r.Name;
            caseDetails.ContactServiceLevel =   objCase.Contact_Service_Level__c;
            caseDetails.CaseNumber =   objCase.casenumber;
            caseDetails.ContactAccountName =   objCase.Account.name;
            caseDetails.ContactEmail =  objCase.Email_Contact__c;
            caseDetails.ContactCompany =  objCase.Company__c;
            caseDetails.ContactCountry =  objCase.Community_Web_Country__c;
            caseDetails.ContactName=  objCase.contact.name;
            caseDetails.LastContactToCustomer = objCase.Last_Contact_to_Customer__c;
            caseDetails.CommunityGroupName =objCase.Community_Group_Name__c;
            caseDetails.CommunityTopicName = objCase.Community_Topic_Name__c;
            caseDetails.CommunityOriginId = objCase.RelatedToId__c;
            caseDetails.CommunityQuestionURL = objCase.Community_Question_URL__c;
            caseDetails.QuestionResolutionCode = objCase.Question_Resolution_Code__c;
        }
            
            caseDetails.ErrorMessage = strMessage;
            return caseDetails;
    }
   
   
}