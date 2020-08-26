/******************************************************************************************
@Modified By :    Scarlett Kang
@Modified Date :   26 Sep 2014
@Description :     Updated test methods to fix it due to new mandatory field - Postal Code
******************************************************************************************
@Modified By :    Baji
@Modified Date :   13 Mar 2018
@Description :     Commented seealldata = true at line #86
*******************************************************************************************/
/******************************************************************************************
@Modified By :   Anil Somani
@Modified Date:  04 Apr 2018
@Description :   Removed(SeeAllData=true) at line #86 from test class and 
                 created all test data in test method as part of SFDC-1489.
*******************************************************************************************/
 
@isTest
private class CustomerTrigger_SAP_CMD_Request_Test{

    private static RecordType newSAP_RecordType;
    private static CMD_Request__c testRequest;
    private static Customer__c testCustomer;
    
    private static List<RecordType> RecT;
    
    static testMethod void thePositiveUnitTest() {
    RecT=[SELECT Id, DeveloperName
          FROM RecordType
          WHERE SobjectType = 'CMD_Request__c' 
          AND DeveloperName LIKE '%SAP%' 
          AND IsActive=true
          LIMIT 1];
    for(RecordType rt :RecT)
    {
       newSAP_RecordType = rt;
    }    
   
       testRequest = new CMD_Request__c(
            RecordTypeId = newSAP_RecordType.Id,
//          SP_GID__c = '100000000',
//            SP_CustomerID__c = 'a1ND0000001vB7GMAU',
            SP_Name__c = 'Test Name',
            SP_Street__c = 'Test Street',
            SP_City__c = 'Test City',
            SP_Country__c = 'Netherlands',
            SP_Telephone__c = '+1234567890',
            SP_Fax__c = '+1234567890',
            SP_Email__c = 'test@test.com',
            SP_Funloc__c = '100000',
            SP_Funloc_Id__c = 'TEST',
            Business_Background_Comments__c = 'Test Business Background Comments',
            Global_Account__c = 'ACI - ACiG',
            Sales_Organisation__c = 'CN62 - MSO China',
            Company_Code__c = 'CN62 - MSO China',
            Customer_Factory_Calendar__c = '11 - Ship to Algeria',
           Customer_Service_ZA__c = 'CN214 - Mary Ng',
            Incoterms_1__c = 'CPT - Carriage paid to',
            Incoterms_2__c = 'Test',
            Lockbox__c = 'CNY',
            Payment_Credit_Memo__c = '014 - Prepaid',
             Pull_Up_OK_SH__c = 'N - No',
            Rounding_Rule_SH__c = 'C - Round to Closest',
            Terms_of_Payment__c = '014 - Prepaid',
            Terms_of_Payment_Sales__c = '014 - Prepaid',
            Con_Acct_SP_EMS__c = 'ACI - ACiG',
            Cust_pric_proc__c = 'R - Russian Disti',
            Grp_1_Sls_Channel_SP__c = 'DIS - Distributor',
            Currency__c = 'EUR - Euro',
            PD_Key_Account__c = 'ACG - ACG',
            Reprice_Basis__c = 'C - Conf. Delivery Date',
            Sales_Office__c = 'BOS1 - Bosch',
            S_O_Sub_Group__c = 'CN - China',
            Postal_Code__c = '100000'
       );    
       insert testRequest; 
    
       testCustomer = new Customer__c(
            CMD_Request_Id__c = testRequest.Id,
            CMD_Request_Partner_Function__c = 'SP',
            DNB_Verified__c = 'DNB Accepted',
            Legal_Name__c = 'Test Legal Name',
            Account_Name__c = 'Test Account Name',
            Street__c = 'TEST STREET',
            City__c = 'TEST CITY',
            Country__c = 'Netherlands',
            Zip__c = 'Test',
            Industry_Segment__c = 'CC - Computing',
            Industry_Sub_Segment__c = 'C1 - Computing',
            Role__c = 'OEM'
        );
       
        insert testCustomer;
       
     System.assert( testCustomer.Name == testRequest.SP_GID__c );
    }
}