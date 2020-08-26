/***************************************************************************************************
@Created By :       Saranya Sista
@Created Date:      28 June 2019
@Description:       Utility to prepare Test Data for Test Classes for New Case Portal. 
--------------------------------------------------------------------------------
@Modified By :     Nisha Agrawal
@Modified Date :   Jul 23,2019
@Description :     Refactored the whole code, updated to match naming convention requirements
                    and added new methods
****************************************************************************************************/

@isTest(SeeAllData=false)
public class CasePortalTestUtil 
{
    public static Id fetchProfileId(String strProfileName)
    { 
        List<Profile> lstProfiles = [Select Id from Profile where name= : strProfileName];
        if(lstProfiles.size() > 0)
        {
            return lstProfiles[0].Id;
        }        
        return null;
    }

    
    //method added by Nisha Agrawal on Jul 23,2019 to add one test project
    public static Project__c createTestProject(String strName, String strStage) 
    {
        return new Project__c(Name = strName, Project_Stage__c = strStage, Project_Annual_Volume__c = '1000 - 10000',
                                                End_Application_Type__c = 'Industrial', End_Application_Name__c = 'Test App');
    }
    
    /* ============================================================================================ 
    Description    : Inserts Project records
    @params1       : number of Project Teams to be inserted
    @params2       : 
    @return        : List of Projects
    Modification History:   
    created by saranya sista 28/6/2019
    ===============================================================================================*/
    public static List<Project__c> createTestProjects(Integer NumOfProjects) {
        List<Project__c> projList = new List<Project__c>();
        for(Integer eachProj=0; eachProj < NumOfProjects; eachProj++){
                Project__c Proj = new Project__c(Name ='TestProject'+ eachProj, Project_Stage__c = 'In Development', Project_Annual_Volume__c='1000 - 10000',
                                                End_Application_Type__c='Industrial', End_Application_Name__c = 'Test End' + eachProj);
                projList.add(Proj);
            }
        return projList;
    }  
    /* ============================================================================================ 
    Description    : Inserts Project Team records
    @params1       : Project list    
    @params2       : number of Project Teams to be inserted    
    @return        : List of Project Teams
    Modification History:   
    created by saranya sista 28/6/2019
    ===============================================================================================*/
    public static List<Project_Team__c> createTestProjectTeams(List<Project__c> projectList, Integer NumOfProjectTeams ) {
        List<Project_Team__c> lstTeamMemmbers = new List<Project_Team__c>();
        for(Project__c projRecs : projectList) {
            for(Integer eachProjTeam=0; eachProjTeam < NumOfProjectTeams; eachProjTeam++){
                Project_Team__c ProjT = new Project_Team__c(First_Name__c = 'Test FirstName'+eachProjTeam , Last_Name__c='Test LastName'+eachProjTeam,
                                                          Email_Address__c='test'+eachProjTeam+'email@gmail.com' , Status__c = 'Invited' , Project__c = projRecs.Id);
                lstTeamMemmbers.add(ProjT);
            }
        }
        return lstTeamMemmbers;
    }
     /* ============================================================================================ 
    Description    : Inserts Parent Account records
    @params1       : Number of Account    
    @return        : List of Parent Accounts
    ===============================================================================================*/
    //fetch record type for accounts
    
    public static List<Account> createTestParentAccount(Integer noOfAccs)
    {
        Id parentAccountTypeId = AccountHelper.getParentRecordTypeID();
        List<Account> lstAccs = new List<Account>();
        for(Integer eachAccount=0; eachAccount < noOfAccs; eachAccount++){
        Account acc = new Account(Name = 'Test Parent', RecordTypeId = parentAccountTypeId);
        lstAccs.add(acc);
        }
        return lstAccs;
    }
     /* ============================================================================================ 
    Description    : Inserts Child Account records
    @params1       : Number of Account    
    @return        : List of Contacts
    ===============================================================================================*/
    public static List<Account> createTestChildAccount(Integer noOfAccs,Id parentAccount)
    {
        Id childAccountTypeId =  AccountHelper.getChildRecordTypeID();
        List<Account> lstChildAccs = new List<Account>();
        for(Integer eachChildAccount=0; eachChildAccount < noOfAccs; eachChildAccount++){
        Account acc = new Account(Name = 'Test Child', RecordTypeId = childAccountTypeId, ParentId = parentAccount);
        lstChildAccs.add(acc);
        }
        return lstChildAccs;
    }
    
    /* ============================================================================================ 
    Description    : Inserts Contact records
    @params1       : Number of Contacts    
    @params2       : Account Id 
    @params3       : Email 
    @params4       : Last Name 
    @return        : List of Contacts
    ===============================================================================================*/
    
    public static List<Contact> createTestContact(Integer noOfConts,Id accountId, String strEmail, String LastName)
    {
        List<Contact> lstContacts = new List<Contact>();
        for(Integer eachContact=0; eachContact < noOfConts; eachContact++){
        Contact con = new Contact(FirstName = 'test First'+eachContact, LastName = LastName+eachContact, Email = strEmail, 
                                          AccountId = accountId, Community_web_country__c = 'India');
        lstContacts.add(con);
        }
        return lstContacts;
    }
    /* ============================================================================================ 
    Description    : Inserts Case records
    @params1       : Number of Case    
    @params2       : Record Type 
    @params3       : Associated project id
    @return        : List of Contacts
    ===============================================================================================*/
    public static List<Case> createCaseObject(Integer noOfCases,Id RecordType,Id projectId){
        List<Case> lstCases = new List<Case>();
        for(Integer eachCase=0; eachCase < noOfCases; eachCase++){
            case cse= new Case(Priority = 'Low', Description = 'Test Case',Status = 'New',Projects__c = projectId
                                 , RecordTypeId = RecordType,Subject = 'Test',Topics__c = 'Documentation');
            lstCases.add(cse);            
        }
        return lstCases;
    }
    /* ============================================================================================ 
    Description    : Inserts Case_Priority_Criteria__c records
    @params1       : Object   
    @params2       : Field
    @params3       : Field Value
    @params4       : Score
    @return        : List of Contacts
    ===============================================================================================*/
    public static Case_Priority_Criteria__c createTestCasePriorityCriteria(String cpObject,String Field,String FieldValue,Integer score){
        
        return new Case_Priority_Criteria__c(Object__c = cpObject, Field__c = Field,Field_Value__c = FieldValue,
                                             Score__c = score);
    }
    
    //method added by Nisha Agrawal on Jul 23, 2019 to add Test Project Team record
    public static Project_Team__c createTestProjectTeam(Id projectId, String strEmail, String strStatus)
    {
        return new Project_Team__c(First_Name__c = 'Test FirstName' , Last_Name__c = 'Test LastName',
                                    Email_Address__c = strEmail , Status__c = strStatus , Project__c = projectId, Role__c = CasePortalUtil.PROJECT_TEAM_ROLE_PARTICIPANT);
    }
    
}