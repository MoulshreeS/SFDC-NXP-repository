/**************************************************************************************
@Modified By :       Jewelslyn
@Modified Date:      6 Nov 2015
@Description:        Added test method for sales org code HK91 (Julie CMD)
-------------------------------------------------------------------------------------
@Modified By :       Scarlett Kang
@Modified Date:      01 June 2016
@Description:        1606 Release SIR 915 - [COM] Revise Funloc CMD approval flow 
                     and add new Tax Classification for new Sales Orgs/CSC Site
****************************************************************************************
@Modified By :       Baji
@Modified Date:      24 Mar 2017
@Description:        *1704 Release (SFDC 327) - Remove Nexperia sales org. ( MY61, PH62, CN61 & HK91) from SAP CMD Request picklist
                     *To fix test class error : GSM Controller Approver Group is madatory 
---------------------------------------------------------------------------------
@Modified By :       Nisha Agrawal
@Modified Date:      Apr 26, 2017 
@Description:        SFDC-430 - Replace GSM COntroller Approver Group picklist to new multiselect picklist Controller Approver Group
-------------------------------------------------------------------------------------------
@Modified By :       Baji
@Modified Date:      27 Jun 2017
@Description:        1707 Release (SFDC 455) - Generate Tax Classifications for Sales Org. CN60
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
@Modified By :       Baji
@Modified Date:      01 Aug 2017 
@Description:        1708 Release (SFDC 729) - Generate Tax Classifications for MANU/SBE sales orgs.
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
@Modified By :       Anil Somani
@Modified Date:      19 Jan 2018
@Description:        (SFDC 1231) - New Attributes(CN and PH) added on Tax Classification session for sales org NL61. 
                     (SFDC 1235) - US63 - NXP San Jose Changed to US63 - NXP Austin for sales org US63.
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
@Modified By :       Baji
@Modified Date:      17 May 2018 
@Description:        1806 Release (SFDC 1713) - To test Tax Classifications for new MANU sales orgs.

------------------------------------------------------------------------------------------------------------------------------------------
@Modified by : Ankita P
@Modified Date : 18 Dec 2019
@Description : SFDC-3457: Added test code for new sales org MY62
                     
********************************************************************************************************/

@isTest
public class TaxClassificationCMDRControllerTest {
    private static final String TYPE_GLOBALENTERPRISE = 'Global_Enterprise';
    private static final String TYPE_SAP_New_Funloc_Request = 'SAP_New_Funloc_Request';
    private static final String TYPE_SAP_New_MANU_Funloc_Request = 'SAP_New_MANU_Funloc_request';
    private static final String TYPE_SAP_New_SBE_Funloc_Request = 'SAP_New_SBE_Funloc_request';
    
    private static RecordType SAP_New_Funloc_Request;
    private static RecordType SAP_New_MANU_Funloc_Request;
    private static RecordType globalCustomer;
    private static RecordType SAP_New_SBE_Funloc_request;
    
    private static Consolidated_Account_Code__c testCACC;
    private static Customer__c objCustomer;
    
    private static void fetchRecordTypes()
    {
        //get SAP CMD record type
        for(RecordType rt : [SELECT Id, DeveloperName
                             FROM   RecordType
                             WHERE  IsActive = TRUE AND  
                              ((SobjectType = 'CMD_Request__c' AND DeveloperName =: TYPE_SAP_New_Funloc_Request)
                              OR (SobjectType = 'CMD_Request__c' AND DeveloperName =: TYPE_SAP_New_MANU_Funloc_Request)
                              OR (SobjectType = 'CMD_Request__c' AND DeveloperName =: TYPE_SAP_New_SBE_Funloc_Request )
                              OR (SobjectType = 'Customer__c' AND DeveloperName =: TYPE_GLOBALENTERPRISE))
                              ])
        {
            if(rt.DeveloperName == TYPE_SAP_New_Funloc_Request)
                SAP_New_Funloc_Request = rt;
            if(rt.DeveloperName == TYPE_SAP_New_MANU_Funloc_Request)
                SAP_New_MANU_Funloc_Request = rt;
            if(rt.DeveloperName == TYPE_SAP_New_SBE_Funloc_Request)
                SAP_New_SBE_Funloc_request = rt; 
            if(rt.DeveloperName == TYPE_GLOBALENTERPRISE)
                globalCustomer = rt;
        }
    }   
    
    private static void createCustomer()
    {
         objCustomer = new Customer__c(RecordTypeId = globalCustomer.Id, Account_Name__c = 'ut_Global_Enterprise ',
                                        Legal_Name__c = 'ut_Global_Enterprise ', DUNS__c = 'ut_123', 
                                        Status__c = 'Active' ,  DNB_Verified__c = 'DNB Accepted' ,
                                        House_Number__c = 'ut', Street__c = 'ut_street_1',
                                        City__c = 'ut_city', Country__c = 'Netherlands', 
                                        Zip__c = 'ut_zip', Industry_Segment__c = 'CC - Computing' ,
                                        Type__c = 'Customer' , Role__c = 'OEM',GSM_Classification__c = 'Internal',
                                        Fulfillment_Channel__c = 'Disti', Sales__c = true,Street_2__c = 'ut_street_2',
                                        Street_3__c = 'ut_street_3' ,State__c = 'test',Industry_Sub_Segment__c = 'C1 - Computing',
                                        SIC_Code__c = 't1', NAICS_Code__c = 'ut', 
                                        Website__c = 'http://www.test.com', EMail__c  = 'test.test@test.com',
                                        Fax__c = '+1234567890', Telephone__c = '+1234567890');                                            
         insert objCustomer;
    }
    
    private static void createTestUser(){
    Id ProfileId = [Select id from profile where name = 'System Administrator' limit 1].Id;
        list<user> lstUsers = new list<user>();
        User testUser = new User();
        testUser.firstName = 'Test2260FirstName2';
        testUser.LastName = 'Test454LastName2';
        testUser.Alias = 'Ts4t2';
        testUser.Email = 'tes26t2@testorg.com';
        testUser.UserName= 'test24@te45storg.com' ;
        testUser.ProfileId = ProfileId;
        testUser.CommunityNickname = testUser.firstname+'_'+testUser.lastName;
        testUser.EmailEncodingKey ='ISO-8859-1';
        testUser.LanguageLocaleKey = 'en_US';
        testUser.TimeZoneSidKey ='America/Los_Angeles';
        testUser.LocaleSidKey = 'en_US';
        testUser.Country = 'USA';
        testUser.ForecastEnabled = true;
        
        insert testuser;
      }
    
    public static void prepareConsolidatedAccountCode(){
        testCACC = new Consolidated_Account_Code__c(
            Name = 'ABC',
            Base_Region__c = 'NA - Americas',
            Customer_Category__c = 'Internal',
            Delivery_Priority__c = '10 - Priority 1',
            Code_Description__c = 'ABC',
            PD_Key_Account__c = 'APP - Apple'
        );
        insert testCACC;
    }
    
    static testMethod void CMDRequestSALES_ORG_NL60(){
        //create data
        fetchRecordTypes();
        prepareConsolidatedAccountCode();
        createCustomer();
        createTestUser();
        
        //create CDM Request - SAP New Funloc Request
        CMD_Request__c objCMDRequest = new CMD_Request__c(
            Sales_Organisation__c = 'NL60 - RSO Europe',
            Reason_for_request__c = 'Test',
            Account_Group__c = 'Z001 - Sold To / Ship To / Bill To / Payer',
            RecordTypeId = SAP_New_Funloc_Request.Id,
            Consolidated_Account_Code__c = testCACC.Id,
            Ready_to_Submit__c = true,
            Request_Status__c = 'Ready to Submit',
            Business_Background_Comments__c = 'Test Business Background Comments',
            Global_Account__c = 'ABB - ABB',
            SP_GID__c = '100000000',
            SP_CustomerID__c = 'a1ND0000001vB7GMAU',
            SP_Name__c = 'Test Name',
            SP_Street__c = 'Test Street',
            SP_City__c = 'Test City',
            SP_Country__c = 'Netherlands',
            SP_Postal_Code__c = '12345',
            Postal_Code__c = '12345',
            Region__c = 'EU - Europe',
            SP_Telephone__c = '+1234567890',
            SP_Fax__c = '+1234567890',
            SP_Email__c = 'test@test.com',
            SP_Funloc__c = '100000',
            SP_Funloc_Id__c = 'a1UD0000000QhEjMAK',
            Company_Code__c = 'NL60 - RSO Europe',
            Label_required__c = 'No',
            Industry_Segment__c = 'CC - Computing',
            Industry_Sub_Segment__c = 'C1 - Computing',
            Customer_Factory_Calendar__c = '01 - Customer calendar Germany standard',
            Customer_Service_ZA__c = 'CN214 - Mary Ng',
            Incoterms_1__c = 'CPT - Carriage paid to',
            Incoterms_2__c = 'Test',
            Lockbox__c = 'NOREMIT',
            Payment_Credit_Memo__c= '014 - Prepaid',
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
            S_O_Sub_Group__c = 'NL - Netherlands',
            Sales_Office__c = 'BOS1 - Bosch',
            
            //GSM_Controller_Approver_Group__c = 'AMEC'  //commented by Nisha Agrawal on Apr 26 for SFDC-430
            Controller_Approver_Group__c = 'NA - Americas' //added by Nisha Agrawal on Apr 26 for SFDC-430
        );
        insert objCMDRequest;
        
        system.assert(objCMDRequest.Id != null);
        cmd_request__c objCMD = [select id,name,request_status__c from cmd_request__c where id=:objCMDRequest.id];
        objCMD.request_status__c = 'Pending for Approval';
        update objCMD;
        
        //start the test
        Test.startTest();
        user testuser = [select id,name from user where email='tes26t2@testorg.com']; 
        system.runas(testuser){
        cmd_request__c objCMDReq = [select id,name,request_status__c from cmd_request__c where id=:objCMDRequest.id];
        PageReference pgRef = Page.TaxClassification;
        pgRef.getParameters().put('Id',objCMDReq.Id);
        Test.setCurrentPageReference(pgRef);
        
        ApexPages.StandardSetController stdController = new Apexpages.StandardSetController(new List<Tax_Classification__c>());
        TaxClassificationCMDRequestController controller = new TaxClassificationCMDRequestController(stdController);
        
        System.assert(controller.lstTaxClassifications != null);
        System.assert(controller.lstTaxClassifications.size() > 0);
        
        //invoke saveTaxClassificationCMDRequest method
        pgRef = controller.saveTaxClassification();
        System.assert(pgRef != null);
        System.assertEquals(pgRef.getUrl(), '/' + controller.objCMDRequest.Id);
        
        //stop the test
        Test.stopTest();
      }
    }
    
    static testMethod void CMDRequestSALES_ORG_US60(){
        //create data
        fetchRecordTypes();
        prepareConsolidatedAccountCode();
        createCustomer();
        createTestUser();
        
        //create CDM Request - SAP New Funloc Request
        CMD_Request__c objCMDRequest = new CMD_Request__c(
            Sales_Organisation__c = 'US60 - RSO U.S.A.',
            Reason_for_request__c = 'Test',
            Account_Group__c = 'Z001 - Sold To / Ship To / Bill To / Payer',
            RecordTypeId = SAP_New_Funloc_Request.Id,
            Consolidated_Account_Code__c = testCACC.Id,
            Ready_to_Submit__c = true,
            Request_Status__c = 'Ready to Submit',
            Business_Background_Comments__c = 'Test Business Background Comments',
            Global_Account__c = 'ABB - ABB',
            SP_GID__c = '100000000',
            SP_CustomerID__c = 'a1ND0000001vB7GMAU',
            SP_Name__c = 'Test Name',
            SP_Street__c = 'Test Street',
            SP_City__c = 'Test City',
            SP_Country__c = 'Netherlands',
            SP_Postal_Code__c = '12345',
            Postal_Code__c = '12345',
            Region__c = 'EU - Europe',
            SP_Telephone__c = '+1234567890',
            SP_Fax__c = '+1234567890',
            SP_Email__c = 'test@test.com',
            SP_Funloc__c = '100000',
            SP_Funloc_Id__c = 'a1UD0000000QhEjMAK',
            Company_Code__c = 'US60 - RSO U.S.A.',
            Label_required__c = 'No',
            Industry_Segment__c = 'CC - Computing',
            Industry_Sub_Segment__c = 'C1 - Computing',
            Customer_Factory_Calendar__c = '01 - Customer calendar Germany standard',
            Customer_Service_ZA__c = 'CN214 - Mary Ng',
            Incoterms_1__c = 'CPT - Carriage paid to',
            Incoterms_2__c = 'Test',
           // Lockbox__c = 'NOREMIT',
            Payment_Credit_Memo__c= '014 - Prepaid',
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
            S_O_Sub_Group__c = 'NL - Netherlands',
            Sales_Office__c = 'BOS1 - Bosch',
            Lockbox__c = 'CIT-WIR',
            //GSM_Controller_Approver_Group__c = 'AMEC'  //commented by Nisha Agrawal on Apr 26 for SFDC-430
            Controller_Approver_Group__c = 'NA - Americas' //added by Nisha Agrawal on Apr 26 for SFDC-430 
        );
        insert objCMDRequest;
        
        system.assert(objCMDRequest.Id != null);
        cmd_request__c objCMD = [select id,name,request_status__c from cmd_request__c where id=:objCMDRequest.id];
        objCMD.request_status__c = 'Pending for Approval';
        update objCMD;
        
        //start the test
        Test.startTest();
        user testuser = [select id,name from user where email='tes26t2@testorg.com']; 
        system.runas(testuser){
        cmd_request__c objCMDReq = [select id,name,request_status__c from cmd_request__c where id=:objCMDRequest.id];
        PageReference pgRef = Page.TaxClassification;
        pgRef.getParameters().put('Id',objCMDReq.Id);
        Test.setCurrentPageReference(pgRef);
        
        ApexPages.StandardSetController stdController = new Apexpages.StandardSetController(new List<Tax_Classification__c>());
        TaxClassificationCMDRequestController controller = new TaxClassificationCMDRequestController(stdController);
        
        System.assert(controller.lstTaxClassifications != null);
        System.assert(controller.lstTaxClassifications.size() > 0);
        
        //invoke saveTaxClassificationCMDRequest method
        pgRef = controller.saveTaxClassification();
        System.assert(pgRef != null);
        System.assertEquals(pgRef.getUrl(), '/' + controller.objCMDRequest.Id);
        
        //stop the test
        Test.stopTest();
    }
   }
    
    static testMethod void CMDRequestSALES_ORG_CN62(){
        //create data
        fetchRecordTypes();
        prepareConsolidatedAccountCode();
        createCustomer();
        createTestUser();
        
        //create CDM Request - SAP New Funloc Request
        CMD_Request__c objCMDRequest = new CMD_Request__c(
            Sales_Organisation__c = 'CN62 - MSO China',
            Reason_for_request__c = 'Test',
            Account_Group__c = 'Z001 - Sold To / Ship To / Bill To / Payer',
            RecordTypeId = SAP_New_Funloc_Request.Id,
            Consolidated_Account_Code__c = testCACC.Id,
            Ready_to_Submit__c = true,
            Request_Status__c = 'Ready to Submit',
            Business_Background_Comments__c = 'Test Business Background Comments',
            Global_Account__c = 'ABB - ABB',
            SP_GID__c = '100000000',
            SP_CustomerID__c = 'a1ND0000001vB7GMAU',
            SP_Name__c = 'Test Name',
            SP_Street__c = 'Test Street',
            SP_City__c = 'Test City',
            SP_Country__c = 'Netherlands',
            SP_Postal_Code__c = '12345',
            Postal_Code__c = '12345',
            Region__c = 'EU - Europe',
            SP_Telephone__c = '+1234567890',
            SP_Fax__c = '+1234567890',
            SP_Email__c = 'test@test.com',
            SP_Funloc__c = '100000',
            SP_Funloc_Id__c = 'a1UD0000000QhEjMAK',
            Company_Code__c = 'CN62 - MSO China',
            Label_required__c = 'No',
            Industry_Segment__c = 'CC - Computing',
            Industry_Sub_Segment__c = 'C1 - Computing',
            Customer_Factory_Calendar__c = '01 - Customer calendar Germany standard',
            Customer_Service_ZA__c = 'CN214 - Mary Ng',
            Incoterms_1__c = 'CPT - Carriage paid to',
            Incoterms_2__c = 'Test',
            Lockbox__c = 'NOREMIT',
            Payment_Credit_Memo__c= '014 - Prepaid',
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
            S_O_Sub_Group__c = 'NL - Netherlands',
            Sales_Office__c = 'BOS1 - Bosch',
            //GSM_Controller_Approver_Group__c = 'AMEC'  //commented by Nisha Agrawal on Apr 26 for SFDC-430
            Controller_Approver_Group__c = 'NA - Americas' //added by Nisha Agrawal on Apr 26 for SFDC-430
        );
        insert objCMDRequest;
        
        system.assert(objCMDRequest.Id != null);
        cmd_request__c objCMD = [select id,name,request_status__c from cmd_request__c where id=:objCMDRequest.id];
        objCMD.request_status__c = 'Pending for Approval';
        update objCMD;
        
        //start the test
        Test.startTest();
        user testuser = [select id,name from user where email='tes26t2@testorg.com']; 
        system.runas(testuser){
        cmd_request__c objCMDReq = [select id,name,request_status__c from cmd_request__c where id=:objCMDRequest.id];
        PageReference pgRef = Page.TaxClassification;
        pgRef.getParameters().put('Id',objCMDReq.Id);
        Test.setCurrentPageReference(pgRef);
        
        ApexPages.StandardSetController stdController = new Apexpages.StandardSetController(new List<Tax_Classification__c>());
        TaxClassificationCMDRequestController controller = new TaxClassificationCMDRequestController(stdController);
        
        System.assert(controller.lstTaxClassifications != null);
        System.assert(controller.lstTaxClassifications.size() > 0);
        
        //invoke saveTaxClassificationCMDRequest method
        pgRef = controller.saveTaxClassification();
        System.assert(pgRef != null);
        System.assertEquals(pgRef.getUrl(), '/' + controller.objCMDRequest.Id);
        
        //stop the test
        Test.stopTest();
    }
   }
    static testMethod void CMDRequestSALES_ORG_CN60(){
        //create data
        fetchRecordTypes();
        prepareConsolidatedAccountCode();
        createCustomer();
        createTestUser();
        
        //create CDM Request - SAP New Funloc Request
        CMD_Request__c objCMDRequest = new CMD_Request__c(
            Sales_Organisation__c = 'CN60 - MSO China CN60',
            Reason_for_request__c = 'Test',
            Account_Group__c = 'Z001 - Sold To / Ship To / Bill To / Payer',
            RecordTypeId = SAP_New_Funloc_Request.Id,
            Consolidated_Account_Code__c = testCACC.Id,
            Ready_to_Submit__c = true,
            Request_Status__c = 'Ready to Submit',
            Business_Background_Comments__c = 'Test Business Background Comments',
            Global_Account__c = 'ABB - ABB',
            SP_GID__c = '100000000',
            SP_CustomerID__c = 'a1ND0000001vB7GMAU',
            SP_Name__c = 'Test Name',
            SP_Street__c = 'Test Street',
            SP_City__c = 'Test City',
            SP_Country__c = 'Netherlands',
            SP_Postal_Code__c = '12345',
            Postal_Code__c = '12345',
            Region__c = 'EU - Europe',
            SP_Telephone__c = '+1234567890',
            SP_Fax__c = '+1234567890',
            SP_Email__c = 'test@test.com',
            SP_Funloc__c = '100000',
            SP_Funloc_Id__c = 'a1UD0000000QhEjMAK',
            Company_Code__c = 'CN60 - MSO China (NXP FSL)',
            Label_required__c = 'No',
            Industry_Segment__c = 'CC - Computing',
            Industry_Sub_Segment__c = 'C1 - Computing',
            Customer_Factory_Calendar__c = '01 - Customer calendar Germany standard',
            Customer_Service_ZA__c = 'CN214 - Mary Ng',
            Incoterms_1__c = 'CPT - Carriage paid to',
            Incoterms_2__c = 'Test',
            Lockbox__c = 'NOREMIT',
            Payment_Credit_Memo__c= '014 - Prepaid',
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
            S_O_Sub_Group__c = 'NL - Netherlands',
            Sales_Office__c = 'AP01 - Conti, JP & Network',
           
            //GSM_Controller_Approver_Group__c = 'AMEC'  //commented by Nisha Agrawal on Apr 26 for SFDC-430
            Controller_Approver_Group__c = 'NA - Americas' //added by Nisha Agrawal on Apr 26 for SFDC-430
        );
        insert objCMDRequest;
        
        
system.assert(objCMDRequest.Id != null);
        cmd_request__c objCMD = [select id,name,request_status__c from cmd_request__c where id=:objCMDRequest.id];
        objCMD.request_status__c = 'Pending for Approval';
        update objCMD;
        
        //start the test
        Test.startTest();
        user testuser = [select id,name from user where email='tes26t2@testorg.com']; 
        system.runas(testuser){
        cmd_request__c objCMDReq = [select id,name,request_status__c from cmd_request__c where id=:objCMDRequest.id];
        PageReference pgRef = Page.TaxClassification;
        pgRef.getParameters().put('Id',objCMDReq.Id);
        Test.setCurrentPageReference(pgRef);
        
        ApexPages.StandardSetController stdController = new Apexpages.StandardSetController(new List<Tax_Classification__c>());
        TaxClassificationCMDRequestController controller = new TaxClassificationCMDRequestController(stdController);
        
        System.assert(controller.lstTaxClassifications != null);
        System.assert(controller.lstTaxClassifications.size() > 0);
        
        //invoke saveTaxClassificationCMDRequest method
        pgRef = controller.saveTaxClassification();
        System.assert(pgRef != null);
        System.assertEquals(pgRef.getUrl(), '/' + controller.objCMDRequest.Id);
        
        //stop the test
        Test.stopTest();
    }
    
   } 
   //Test method is added to include the sales org HK-91 for Julie CMD 
  /*  static testMethod void CMDRequestSALES_ORG_HK_91()
    {
        fetchRecordTypes();
        prepareConsolidatedAccountCode();
        createCustomer();
        
        CMD_Request__c objCMDRequest = new CMD_Request__c(
            Sales_Organisation__c = 'HK91 - WeEn Semiconductor',
            Reason_for_request__c = 'Test',
            Account_Group__c = 'Z001 - Sold To / Ship To / Bill To / Payer',
            RecordTypeId = SAP_New_Funloc_Request.Id,
            Consolidated_Account_Code__c = testCACC.Id,
            Ready_to_Submit__c = true,
            Request_Status__c = 'Ready to Submit',
            Business_Background_Comments__c = 'Test Business Background Comments',
            Global_Account__c = 'ABB - ABB',
            SP_GID__c = '100000000',            
            SP_Name__c = 'Test Name',
            SP_Street__c = 'Test Street',
            SP_City__c = 'Test City',
            SP_Country__c = 'Netherlands',
            SP_Postal_Code__c = '12345',
            Postal_Code__c = '12345',
            Region__c = 'EU - Europe',
            SP_Telephone__c = '+1234567890',
            SP_Fax__c = '+1234567890',
            SP_Email__c = 'test@test.com',
            SP_Funloc__c = '100000',            
            Company_Code__c = 'Test',
            Label_required__c = 'No',
            Industry_Segment__c = 'Test',
            Industry_Sub_Segment__c = 'Test',
            Customer_Factory_Calendar__c = 'Test',
            Customer_Service_ZA__c = 'Test',
            Incoterms_1__c = 'Test',
            Incoterms_2__c = 'Test',
            Lockbox__c = 'Test',
            Payment_Credit_Memo__c= 'Test',
            Pull_Up_OK_SH__c = 'Test',
            Rounding_Rule_SH__c = 'Test',
            Terms_of_Payment__c = 'Test',
            Terms_of_Payment_Sales__c = 'Test',
            Con_Acct_SP_EMS__c = 'Test',
            Cust_pric_proc__c = 'Test',
            Grp_1_Sls_Channel_SP__c = 'Test',
            Currency__c = 'Test Currency',
            PD_Key_Account__c = 'Test PD Key Account',
            Reprice_Basis__c = 'Test Reprice Basis',
            Sales_Office__c = 'Test Sales_Office__c',
            S_O_Sub_Group__c = 'Test S O Sub Group',
            GSM_Controller_Approver_Group__c = 'AMEC'
            );
            
        insert objCMDRequest;        
        system.assert(objCMDRequest.Id != null);
        
        //start the test
        Test.startTest();
        
         PageReference pgRef = Page.TaxClassification;
        pgRef.getParameters().put('Id',objCMDRequest.Id);
        Test.setCurrentPageReference(pgRef);
        
        ApexPages.StandardSetController stdController = new Apexpages.StandardSetController(new List<Tax_Classification__c>());
        TaxClassificationCMDRequestController controller = new TaxClassificationCMDRequestController(stdController);
        
        System.assert(controller.lstTaxClassifications != null);
        System.assert(controller.lstTaxClassifications.size() > 0);
        
        //invoke saveTaxClassificationCMDRequest method
        pgRef = controller.saveTaxClassification();
        System.assert(pgRef != null);
        System.assertEquals(pgRef.getUrl(), '/' + controller.objCMDRequest.Id);
        
        //stop the test
        Test.stopTest();   
    
    } */
    static testMethod void CMDRequestSALES_ORG_JP_60()
    {
        fetchRecordTypes();
        prepareConsolidatedAccountCode();
        createCustomer();
        createTestUser();
        
        CMD_Request__c objCMDRequest = new CMD_Request__c(
            Sales_Organisation__c = 'JP60 - MSO Japan',
            Reason_for_request__c = 'Test',
            Account_Group__c = 'Z001 - Sold To / Ship To / Bill To / Payer',
            RecordTypeId = SAP_New_Funloc_Request.Id,
            Consolidated_Account_Code__c = testCACC.Id,
            Ready_to_Submit__c = true,
            Request_Status__c = 'Ready to Submit',
            Business_Background_Comments__c = 'Test Business Background Comments',
            Global_Account__c = 'ABB - ABB',
            SP_GID__c = '100000000',            
            SP_Name__c = 'Test Name',
            SP_Street__c = 'Test Street',
            SP_City__c = 'Test City',
            SP_Country__c = 'Netherlands',
            SP_Postal_Code__c = '12345',
            Postal_Code__c = '12345',
            Region__c = 'EU - Europe',
            SP_Telephone__c = '+1234567890',
            SP_Fax__c = '+1234567890',
            SP_Email__c = 'test@test.com',
            SP_Funloc__c = '100000',            
            Company_Code__c = 'JP60 - MSO Japan',
            Label_required__c = 'No',
            Industry_Segment__c = 'CC - Computing',
            Industry_Sub_Segment__c = 'C1 - Computing',
            Customer_Factory_Calendar__c = '01 - Customer calendar Germany standard',
            Customer_Service_ZA__c = 'CN214 - Mary Ng',
            Incoterms_1__c = 'CPT - Carriage paid to',
            Incoterms_2__c = 'Test',
            Lockbox__c = 'NOREMIT',
            Payment_Credit_Memo__c= '014 - Prepaid',
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
            S_O_Sub_Group__c = 'NL - Netherlands',
            Sales_Office__c = 'AP01 - Conti, JP & Network',
            
            //GSM_Controller_Approver_Group__c = 'AMEC'  //commented by Nisha Agrawal on Apr 26 for SFDC-430
            Controller_Approver_Group__c = 'NA - Americas' //added by Nisha Agrawal on Apr 26 for SFDC-430
            );
            
        insert objCMDRequest;        
        system.assert(objCMDRequest.Id != null);
        cmd_request__c objCMD = [select id,name,request_status__c from cmd_request__c where id=:objCMDRequest.id];
        objCMD.request_status__c = 'Pending for Approval';
        update objCMD;
        
        //start the test
        Test.startTest();
        user testuser = [select id,name from user where email='tes26t2@testorg.com']; 
        system.runas(testuser){
        cmd_request__c objCMDReq = [select id,name,request_status__c from cmd_request__c where id=:objCMDRequest.id];
        PageReference pgRef = Page.TaxClassification;
        pgRef.getParameters().put('Id',objCMDReq.Id);
        Test.setCurrentPageReference(pgRef);
        
        ApexPages.StandardSetController stdController = new Apexpages.StandardSetController(new List<Tax_Classification__c>());
        TaxClassificationCMDRequestController controller = new TaxClassificationCMDRequestController(stdController);
        
        System.assert(controller.lstTaxClassifications != null);
        System.assert(controller.lstTaxClassifications.size() > 0);
        
        //invoke saveTaxClassificationCMDRequest method
        pgRef = controller.saveTaxClassification();
        System.assert(pgRef != null);
        System.assertEquals(pgRef.getUrl(), '/' + controller.objCMDRequest.Id);
        
        //stop the test
        Test.stopTest();   
      }
    }
    static testMethod void CMDRequestSALES_ORG_US_63()
    {
        fetchRecordTypes();
        prepareConsolidatedAccountCode();
        createCustomer();
        createTestUser();
        
        CMD_Request__c objCMDRequest = new CMD_Request__c(
            Sales_Organisation__c = 'US63 - NXP Austin',
            Reason_for_request__c = 'Test',
            Account_Group__c = 'Z001 - Sold To / Ship To / Bill To / Payer',
            RecordTypeId = SAP_New_Funloc_Request.Id,
            Consolidated_Account_Code__c = testCACC.Id,
            Ready_to_Submit__c = true,
            Request_Status__c = 'Ready to Submit',
            Business_Background_Comments__c = 'Test Business Background Comments',
            Global_Account__c = 'ABB - ABB',
            SP_GID__c = '100000000',            
            SP_Name__c = 'Test Name',
            SP_Street__c = 'Test Street',
            SP_City__c = 'Test City',
            SP_Country__c = 'Netherlands',
            SP_Postal_Code__c = '12345',
            Postal_Code__c = '12345',
            Region__c = 'EU - Europe',
            SP_Telephone__c = '+1234567890',
            SP_Fax__c = '+1234567890',
            SP_Email__c = 'test@test.com',
            SP_Funloc__c = '100000',            
            Company_Code__c = ' US63 - NXP USA, Inc.',
            Label_required__c = 'No',
            Industry_Segment__c = 'CC - Computing',
            Industry_Sub_Segment__c = 'C1 - Computing',
            Customer_Factory_Calendar__c = '01 - Customer calendar Germany standard',
           Customer_Service_ZA__c = 'CN214 - Mary Ng',
            Incoterms_1__c = 'CPT - Carriage paid to',
            Incoterms_2__c = 'Test',
            Lockbox__c = 'NOREMIT',
            Payment_Credit_Memo__c= '014 - Prepaid',
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
            S_O_Sub_Group__c = 'NL - Netherlands',
            Sales_Office__c = 'US63 - NXP San Jose',
            
            //GSM_Controller_Approver_Group__c = 'AMEC'  //commented by Nisha Agrawal on Apr 26 for SFDC-430
            Controller_Approver_Group__c = 'NA - Americas' //added by Nisha Agrawal on Apr 26 for SFDC-430
            );
            
        insert objCMDRequest;        
        system.assert(objCMDRequest.Id != null);
        cmd_request__c objCMD = [select id,name,request_status__c from cmd_request__c where id=:objCMDRequest.id];
        objCMD.request_status__c = 'Pending for Approval';
        update objCMD;
        
        //start the test
        Test.startTest();
        user testuser = [select id,name from user where email='tes26t2@testorg.com']; 
        system.runas(testuser){
        cmd_request__c objCMDReq = [select id,name,request_status__c from cmd_request__c where id=:objCMDRequest.id];
        PageReference pgRef = Page.TaxClassification;
        pgRef.getParameters().put('Id',objCMDReq.Id);
        Test.setCurrentPageReference(pgRef);
        
        ApexPages.StandardSetController stdController = new Apexpages.StandardSetController(new List<Tax_Classification__c>());
        TaxClassificationCMDRequestController controller = new TaxClassificationCMDRequestController(stdController);
        
        System.assert(controller.lstTaxClassifications != null);
        System.assert(controller.lstTaxClassifications.size() > 0);
        
        //invoke saveTaxClassificationCMDRequest method
        pgRef = controller.saveTaxClassification();
        System.assert(pgRef != null);
        System.assertEquals(pgRef.getUrl(), '/' + controller.objCMDRequest.Id);
        
        //stop the test
        Test.stopTest();   
     }
    }
  /*  static testMethod void CMDRequestSALES_ORG_CN_61()
    {
        fetchRecordTypes();
        prepareConsolidatedAccountCode();
        createCustomer();
        
        CMD_Request__c objCMDRequest = new CMD_Request__c(
            Sales_Organisation__c = 'CN61 - MSO China',
            Reason_for_request__c = 'Test',
            Account_Group__c = 'Z001 - Sold To / Ship To / Bill To / Payer',
            RecordTypeId = SAP_New_Funloc_Request.Id,
            Consolidated_Account_Code__c = testCACC.Id,
            Ready_to_Submit__c = true,
            Request_Status__c = 'Ready to Submit',
            Business_Background_Comments__c = 'Test Business Background Comments',
            Global_Account__c = 'ABB - ABB',
            SP_GID__c = '100000000',            
            SP_Name__c = 'Test Name',
            SP_Street__c = 'Test Street',
            SP_City__c = 'Test City',
            SP_Country__c = 'Netherlands',
            SP_Postal_Code__c = '12345',
            Postal_Code__c = '12345',
            Region__c = 'EU - Europe',
            SP_Telephone__c = '+1234567890',
            SP_Fax__c = '+1234567890',
            SP_Email__c = 'test@test.com',
            SP_Funloc__c = '100000',            
            Company_Code__c = 'Test',
            Label_required__c = 'No',
            Industry_Segment__c = 'Test',
            Industry_Sub_Segment__c = 'Test',
            Customer_Factory_Calendar__c = 'Test',
            Customer_Service_ZA__c = 'Test',
            Incoterms_1__c = 'Test',
            Incoterms_2__c = 'Test',
            Lockbox__c = 'Test',
            Payment_Credit_Memo__c= 'Test',
            Pull_Up_OK_SH__c = 'Test',
            Rounding_Rule_SH__c = 'Test',
            Terms_of_Payment__c = 'Test',
            Terms_of_Payment_Sales__c = 'Test',
            Con_Acct_SP_EMS__c = 'Test',
            Cust_pric_proc__c = 'Test',
            Grp_1_Sls_Channel_SP__c = 'Test',
            Currency__c = 'Test Currency',
            PD_Key_Account__c = 'Test PD Key Account',
            Reprice_Basis__c = 'Test Reprice Basis',
            Sales_Office__c = 'Test Sales_Office__c',
            S_O_Sub_Group__c = 'Test S O Sub Group');
            
        insert objCMDRequest;        
        system.assert(objCMDRequest.Id != null);
        
        //start the test
        Test.startTest();
        
         PageReference pgRef = Page.TaxClassification;
        pgRef.getParameters().put('Id',objCMDRequest.Id);
        Test.setCurrentPageReference(pgRef);
        
        ApexPages.StandardSetController stdController = new Apexpages.StandardSetController(new List<Tax_Classification__c>());
        TaxClassificationCMDRequestController controller = new TaxClassificationCMDRequestController(stdController);
        
        System.assert(controller.lstTaxClassifications != null);
        System.assert(controller.lstTaxClassifications.size() > 0);
        
        //invoke saveTaxClassificationCMDRequest method
        pgRef = controller.saveTaxClassification();
        System.assert(pgRef != null);
        System.assertEquals(pgRef.getUrl(), '/' + controller.objCMDRequest.Id);
        
        //stop the test
        Test.stopTest();   
    
    } */
    
    static testMethod void CMDRequestSALES_ORG_CN_64()
    {
        fetchRecordTypes();
        prepareConsolidatedAccountCode();
        createCustomer();
        createTestUser();
        
        CMD_Request__c objCMDRequest = new CMD_Request__c(
            Sales_Organisation__c = 'CN64 - Tianjin',
            Reason_for_request__c = 'Test',
            Account_Group__c = 'Z001 - Sold To / Ship To / Bill To / Payer',
            RecordTypeId = SAP_New_Funloc_Request.Id,
            Consolidated_Account_Code__c = testCACC.Id,
            Ready_to_Submit__c = true,
            Request_Status__c = 'Ready to Submit',
            Business_Background_Comments__c = 'Test Business Background Comments',
            Global_Account__c = 'ABB - ABB',
            SP_GID__c = '100000000',            
            SP_Name__c = 'Test Name',
            SP_Street__c = 'Test Street',
            SP_City__c = 'Test City',
            SP_Country__c = 'Netherlands',
            SP_Postal_Code__c = '12345',
            Postal_Code__c = '12345',
            Region__c = 'EU - Europe',
            SP_Telephone__c = '+1234567890',
            SP_Fax__c = '+1234567890',
            SP_Email__c = 'test@test.com',
            SP_Funloc__c = '100000',            
            Company_Code__c = 'CN64 - NXP FSL IWH Tianjin',
            Label_required__c = 'No',
            Industry_Segment__c = 'CC - Computing',
            Industry_Sub_Segment__c = 'C1 - Computing',
            Customer_Factory_Calendar__c = '01 - Customer calendar Germany standard',
            Customer_Service_ZA__c = 'CN214 - Mary Ng',
            Incoterms_1__c = 'CPT - Carriage paid to',
            Incoterms_2__c = 'Test',
            Lockbox__c = 'NOREMIT',
            Payment_Credit_Memo__c= '014 - Prepaid',
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
            S_O_Sub_Group__c = 'NL - Netherlands',
            Sales_Office__c = 'CN64 - Tianjin',
            
            //GSM_Controller_Approver_Group__c = 'EMEA'  //commented by Nisha Agrawal on Apr 26 for SFDC-430
            Controller_Approver_Group__c = 'EU - EMEA' //added by Nisha Agrawal on Apr 26 for SFDC-430
            );
            
        insert objCMDRequest;        
        system.assert(objCMDRequest.Id != null);
        cmd_request__c objCMD = [select id,name,request_status__c from cmd_request__c where id=:objCMDRequest.id];
        objCMD.request_status__c = 'Pending for Approval';
        update objCMD;
        
        //start the test
        Test.startTest();
        user testuser = [select id,name from user where email='tes26t2@testorg.com']; 
        system.runas(testuser){
        cmd_request__c objCMDReq = [select id,name,request_status__c from cmd_request__c where id=:objCMDRequest.id];
        PageReference pgRef = Page.TaxClassification;
        pgRef.getParameters().put('Id',objCMDReq.Id);
        Test.setCurrentPageReference(pgRef);
        
        ApexPages.StandardSetController stdController = new Apexpages.StandardSetController(new List<Tax_Classification__c>());
        TaxClassificationCMDRequestController controller = new TaxClassificationCMDRequestController(stdController);
        
        System.assert(controller.lstTaxClassifications != null);
        System.assert(controller.lstTaxClassifications.size() > 0);
        
        //invoke saveTaxClassificationCMDRequest method
        pgRef = controller.saveTaxClassification();
        System.assert(pgRef != null);
        System.assertEquals(pgRef.getUrl(), '/' + controller.objCMDRequest.Id);
        
        //stop the test
        Test.stopTest();   
    
    }
   }
    static testMethod void CMDRequestSALES_ORG_CN_6B()
    {
        fetchRecordTypes();
        prepareConsolidatedAccountCode();
        createCustomer();
        createTestUser();
        
        CMD_Request__c objCMDRequest = new CMD_Request__c(
            Sales_Organisation__c = 'CN6B - NXP Tianjin',
            Reason_for_request__c = 'Test',
            Account_Group__c = 'Z001 - Sold To / Ship To / Bill To / Payer',
            RecordTypeId = SAP_New_Funloc_Request.Id,
            Consolidated_Account_Code__c = testCACC.Id,
            Ready_to_Submit__c = true,
            Request_Status__c = 'Ready to Submit',
            Business_Background_Comments__c = 'Test Business Background Comments',
            Global_Account__c = 'ABB - ABB',
            SP_GID__c = '100000000',            
            SP_Name__c = 'Test Name',
            SP_Street__c = 'Test Street',
            SP_City__c = 'Test City',
            SP_Country__c = 'Netherlands',
            SP_Postal_Code__c = '12345',
            Postal_Code__c = '12345',
            Region__c = 'EU - Europe',
            SP_Telephone__c = '+1234567890',
            SP_Fax__c = '+1234567890',
            SP_Email__c = 'test@test.com',
            SP_Funloc__c = '100000',            
            Company_Code__c = 'CN6B - NXP FSL IWH Tianjin',
            Label_required__c = 'No',
            Industry_Segment__c = 'CC - Computing',
            Industry_Sub_Segment__c = 'C1 - Computing',
            Customer_Factory_Calendar__c = '01 - Customer calendar Germany standard',
            Customer_Service_ZA__c = 'CN214 - Mary Ng',
            Incoterms_1__c = 'CPT - Carriage paid to',
            Incoterms_2__c = 'Test',
            Lockbox__c = 'NOREMIT',
            Payment_Credit_Memo__c= '014 - Prepaid',
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
            S_O_Sub_Group__c = 'NL - Netherlands',
            Sales_Office__c = 'CN6B - SOffice Tianjin',
           
            //GSM_Controller_Approver_Group__c = 'EMEA'  //commented by Nisha Agrawal on Apr 26 for SFDC-430
            Controller_Approver_Group__c = 'EU - EMEA' //added by Nisha Agrawal on Apr 26 for SFDC-430
            );
            
        insert objCMDRequest;        
        system.assert(objCMDRequest.Id != null);
        cmd_request__c objCMD = [select id,name,request_status__c from cmd_request__c where id=:objCMDRequest.id];
        objCMD.request_status__c = 'Pending for Approval';
        update objCMD;
        
        //start the test
        Test.startTest();
        user testuser = [select id,name from user where email='tes26t2@testorg.com']; 
        system.runas(testuser){
        cmd_request__c objCMDReq = [select id,name,request_status__c from cmd_request__c where id=:objCMDRequest.id];
        PageReference pgRef = Page.TaxClassification;
        pgRef.getParameters().put('Id',objCMDReq.Id);
        Test.setCurrentPageReference(pgRef);
        
        ApexPages.StandardSetController stdController = new Apexpages.StandardSetController(new List<Tax_Classification__c>());
        TaxClassificationCMDRequestController controller = new TaxClassificationCMDRequestController(stdController);
        
        System.assert(controller.lstTaxClassifications != null);
        System.assert(controller.lstTaxClassifications.size() > 0);
        
        //invoke saveTaxClassificationCMDRequest method
        pgRef = controller.saveTaxClassification();
        System.assert(pgRef != null);
        System.assertEquals(pgRef.getUrl(), '/' + controller.objCMDRequest.Id);
        
        //stop the test
        Test.stopTest();   
      }
    }
  /*  static testMethod void CMDRequestSALES_ORG_MY_61()
    {
        fetchRecordTypes();
        prepareConsolidatedAccountCode();
        createCustomer();
        
        CMD_Request__c objCMDRequest = new CMD_Request__c(
            Sales_Organisation__c = 'MY61 - NXP Seremban',
            Reason_for_request__c = 'Test',
            Account_Group__c = 'Z001 - Sold To / Ship To / Bill To / Payer',
            RecordTypeId = SAP_New_Funloc_Request.Id,
            Consolidated_Account_Code__c = testCACC.Id,
            Ready_to_Submit__c = true,
            Request_Status__c = 'Ready to Submit',
            Business_Background_Comments__c = 'Test Business Background Comments',
            Global_Account__c = 'ABB - ABB',
            SP_GID__c = '100000000',            
            SP_Name__c = 'Test Name',
            SP_Street__c = 'Test Street',
            SP_City__c = 'Test City',
            SP_Country__c = 'Netherlands',
            SP_Postal_Code__c = '12345',
            Postal_Code__c = '12345',
            Region__c = 'EU - Europe',
            SP_Telephone__c = '+1234567890',
            SP_Fax__c = '+1234567890',
            SP_Email__c = 'test@test.com',
            SP_Funloc__c = '100000',            
            Company_Code__c = 'Test',
            Label_required__c = 'No',
            Industry_Segment__c = 'Test',
            Industry_Sub_Segment__c = 'Test',
            Customer_Factory_Calendar__c = 'Test',
            Customer_Service_ZA__c = 'Test',
            Incoterms_1__c = 'Test',
            Incoterms_2__c = 'Test',
            Lockbox__c = 'Test',
            Payment_Credit_Memo__c= 'Test',
            Pull_Up_OK_SH__c = 'Test',
            Rounding_Rule_SH__c = 'Test',
            Terms_of_Payment__c = 'Test',
            Terms_of_Payment_Sales__c = 'Test',
            Con_Acct_SP_EMS__c = 'Test',
            Cust_pric_proc__c = 'Test',
            Grp_1_Sls_Channel_SP__c = 'Test',
            Currency__c = 'Test Currency',
            PD_Key_Account__c = 'Test PD Key Account',
            Reprice_Basis__c = 'Test Reprice Basis',
            Sales_Office__c = 'Test Sales_Office__c',
            S_O_Sub_Group__c = 'Test S O Sub Group');
            
        insert objCMDRequest;        
        system.assert(objCMDRequest.Id != null);
        
        //start the test
        Test.startTest();
        
         PageReference pgRef = Page.TaxClassification;
        pgRef.getParameters().put('Id',objCMDRequest.Id);
        Test.setCurrentPageReference(pgRef);
        
        ApexPages.StandardSetController stdController = new Apexpages.StandardSetController(new List<Tax_Classification__c>());
        TaxClassificationCMDRequestController controller = new TaxClassificationCMDRequestController(stdController);
        
        System.assert(controller.lstTaxClassifications != null);
        System.assert(controller.lstTaxClassifications.size() > 0);
        
        //invoke saveTaxClassificationCMDRequest method
        pgRef = controller.saveTaxClassification();
        System.assert(pgRef != null);
        System.assertEquals(pgRef.getUrl(), '/' + controller.objCMDRequest.Id);
        
        //stop the test
        Test.stopTest();   
    
    }
    
    static testMethod void CMDRequestSALES_ORG_PH_62()
    {
        fetchRecordTypes();
        prepareConsolidatedAccountCode();
        createCustomer();
        
        CMD_Request__c objCMDRequest = new CMD_Request__c(
            Sales_Organisation__c = 'PH62 - NXP Cabuyao',
            Reason_for_request__c = 'Test',
            Account_Group__c = 'Z001 - Sold To / Ship To / Bill To / Payer',
            RecordTypeId = SAP_New_Funloc_Request.Id,
            Consolidated_Account_Code__c = testCACC.Id,
            Ready_to_Submit__c = true,
            Request_Status__c = 'Ready to Submit',
            Business_Background_Comments__c = 'Test Business Background Comments',
            Global_Account__c = 'ABB - ABB',
            SP_GID__c = '100000000',            
            SP_Name__c = 'Test Name',
            SP_Street__c = 'Test Street',
            SP_City__c = 'Test City',
            SP_Country__c = 'Netherlands',
            SP_Postal_Code__c = '12345',
            Postal_Code__c = '12345',
            Region__c = 'EU - Europe',
            SP_Telephone__c = '+1234567890',
            SP_Fax__c = '+1234567890',
            SP_Email__c = 'test@test.com',
            SP_Funloc__c = '100000',            
            Company_Code__c = 'Test',
            Label_required__c = 'No',
            Industry_Segment__c = 'Test',
            Industry_Sub_Segment__c = 'Test',
            Customer_Factory_Calendar__c = 'Test',
            Customer_Service_ZA__c = 'Test',
            Incoterms_1__c = 'Test',
            Incoterms_2__c = 'Test',
            Lockbox__c = 'Test',
            Payment_Credit_Memo__c= 'Test',
            Pull_Up_OK_SH__c = 'Test',
            Rounding_Rule_SH__c = 'Test',
            Terms_of_Payment__c = 'Test',
            Terms_of_Payment_Sales__c = 'Test',
            Con_Acct_SP_EMS__c = 'Test',
            Cust_pric_proc__c = 'Test',
            Grp_1_Sls_Channel_SP__c = 'Test',
            Currency__c = 'Test Currency',
            PD_Key_Account__c = 'Test PD Key Account',
            Reprice_Basis__c = 'Test Reprice Basis',
            Sales_Office__c = 'Test Sales_Office__c',
            S_O_Sub_Group__c = 'Test S O Sub Group');
            
        insert objCMDRequest;        
        system.assert(objCMDRequest.Id != null);
        
        //start the test
        Test.startTest();
        
         PageReference pgRef = Page.TaxClassification;
        pgRef.getParameters().put('Id',objCMDRequest.Id);
        Test.setCurrentPageReference(pgRef);
        
        ApexPages.StandardSetController stdController = new Apexpages.StandardSetController(new List<Tax_Classification__c>());
        TaxClassificationCMDRequestController controller = new TaxClassificationCMDRequestController(stdController);
        
        System.assert(controller.lstTaxClassifications != null);
        System.assert(controller.lstTaxClassifications.size() > 0);
        
        //invoke saveTaxClassificationCMDRequest method
        pgRef = controller.saveTaxClassification();
        System.assert(pgRef != null);
        System.assertEquals(pgRef.getUrl(), '/' + controller.objCMDRequest.Id);
        
        //stop the test
        Test.stopTest();   
    
    }*/
    static testMethod void CMDRequestSALES_ORG_TH_61()
    {
        fetchRecordTypes();
        prepareConsolidatedAccountCode();
        createCustomer();
        createTestUser();
        
        CMD_Request__c objCMDRequest = new CMD_Request__c(
            Sales_Organisation__c = 'TH61 - NXP Thailand',
            Reason_for_request__c = 'Test',
            Account_Group__c = 'Z001 - Sold To / Ship To / Bill To / Payer',
            RecordTypeId = SAP_New_Funloc_Request.Id,
            Consolidated_Account_Code__c = testCACC.Id,
            Ready_to_Submit__c = true,
            Request_Status__c = 'Ready to Submit',
            Business_Background_Comments__c = 'Test Business Background Comments',
            Global_Account__c = 'ABB - ABB',
            SP_GID__c = '100000000',            
            SP_Name__c = 'Test Name',
            SP_Street__c = 'Test Street',
            SP_City__c = 'Test City',
            SP_Country__c = 'Netherlands',
            SP_Postal_Code__c = '12345',
            Postal_Code__c = '12345',
            Region__c = 'EU - Europe',
            SP_Telephone__c = '+1234567890',
            SP_Fax__c = '+1234567890',
            SP_Email__c = 'test@test.com',
            SP_Funloc__c = '100000',            
            Company_Code__c = 'TH61 - NXP Thailand',
            Label_required__c = 'No',
            Industry_Segment__c = 'CC - Computing',
            Industry_Sub_Segment__c = 'C1 - Computing',
            Customer_Factory_Calendar__c = '01 - Customer calendar Germany standard',
            Customer_Service_ZA__c = 'CN214 - Mary Ng',
            Incoterms_1__c = 'CPT - Carriage paid to',
            Incoterms_2__c = 'Test',
            Lockbox__c = 'NOREMIT',
            Payment_Credit_Memo__c= '014 - Prepaid',
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
            S_O_Sub_Group__c = 'NL - Netherlands',
            Sales_Office__c = 'TH61 - PST BANGKOK',
            
            //GSM_Controller_Approver_Group__c = 'SAP'  //commented by Nisha Agrawal on Apr 26 for SFDC-430
            Controller_Approver_Group__c = 'AP - South Asia-Pacific' //added by Nisha Agrawal on Apr 26 for SFDC-430
        );
            
        insert objCMDRequest;        
        system.assert(objCMDRequest.Id != null);
        cmd_request__c objCMD = [select id,name,request_status__c from cmd_request__c where id=:objCMDRequest.id];
        objCMD.request_status__c = 'Pending for Approval';
        update objCMD;
        
        //start the test
        Test.startTest();
        user testuser = [select id,name from user where email='tes26t2@testorg.com']; 
        system.runas(testuser){
        cmd_request__c objCMDReq = [select id,name,request_status__c from cmd_request__c where id=:objCMDRequest.id];
        PageReference pgRef = Page.TaxClassification;
        pgRef.getParameters().put('Id',objCMDReq.Id);
        Test.setCurrentPageReference(pgRef);
        
        ApexPages.StandardSetController stdController = new Apexpages.StandardSetController(new List<Tax_Classification__c>());
        TaxClassificationCMDRequestController controller = new TaxClassificationCMDRequestController(stdController);
        
        System.assert(controller.lstTaxClassifications != null);
        System.assert(controller.lstTaxClassifications.size() > 0);
        
        //invoke saveTaxClassificationCMDRequest method
        pgRef = controller.saveTaxClassification();
        System.assert(pgRef != null);
        System.assertEquals(pgRef.getUrl(), '/' + controller.objCMDRequest.Id);
        
        //stop the test
        Test.stopTest();   
     }
    }   
    static testMethod void CMDRequestSALES_ORG_TW_61()
    {
        fetchRecordTypes();
        prepareConsolidatedAccountCode();
        createCustomer();
        createTestUser();
        
        CMD_Request__c objCMDRequest = new CMD_Request__c(
            Sales_Organisation__c = 'TW61 - NXP Kaohsiung',
            Reason_for_request__c = 'Test',
            Account_Group__c = 'Z001 - Sold To / Ship To / Bill To / Payer',
            RecordTypeId = SAP_New_Funloc_Request.Id,
            Consolidated_Account_Code__c = testCACC.Id,
            Ready_to_Submit__c = true,
            Request_Status__c = 'Ready to Submit',
            Business_Background_Comments__c = 'Test Business Background Comments',
            Global_Account__c = 'ABB - ABB',
            SP_GID__c = '100000000',            
            SP_Name__c = 'Test Name',
            SP_Street__c = 'Test Street',
            SP_City__c = 'Test City',
            SP_Country__c = 'Netherlands',
            SP_Postal_Code__c = '12345',
            Postal_Code__c = '12345',
            Region__c = 'EU - Europe',
            SP_Telephone__c = '+1234567890',
            SP_Fax__c = '+1234567890',
            SP_Email__c = 'test@test.com',
            SP_Funloc__c = '100000',            
            Company_Code__c = 'TW61 - NXP Kaohsiung',
            Label_required__c = 'No',
            Industry_Segment__c = 'CC - Computing',
            Industry_Sub_Segment__c = 'C1 - Computing',
            Customer_Factory_Calendar__c = '01 - Customer calendar Germany standard',
            Customer_Service_ZA__c = 'CN214 - Mary Ng',
            Incoterms_1__c = 'CPT - Carriage paid to',
            Incoterms_2__c = 'Test',
            Lockbox__c = 'NOREMIT',
            Payment_Credit_Memo__c= '014 - Prepaid',
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
            S_O_Sub_Group__c = 'NL - Netherlands',
            Sales_Office__c = 'TW61 - PSK TAIWAN',
           
            //GSM_Controller_Approver_Group__c = 'GC'  //commented by Nisha Agrawal on Apr 26 for SFDC-430
            Controller_Approver_Group__c = 'GC - Greater China' //added by Nisha Agrawal on Apr 26 for SFDC-430
            );
            
        insert objCMDRequest;        
        system.assert(objCMDRequest.Id != null);
        cmd_request__c objCMD = [select id,name,request_status__c from cmd_request__c where id=:objCMDRequest.id];
        objCMD.request_status__c = 'Pending for Approval';
        update objCMD;
        
        //start the test
        Test.startTest();
        user testuser = [select id,name from user where email='tes26t2@testorg.com']; 
        system.runas(testuser){
        cmd_request__c objCMDReq = [select id,name,request_status__c from cmd_request__c where id=:objCMDRequest.id];
        PageReference pgRef = Page.TaxClassification;
        pgRef.getParameters().put('Id',objCMDReq.Id);
        Test.setCurrentPageReference(pgRef);
        
        ApexPages.StandardSetController stdController = new Apexpages.StandardSetController(new List<Tax_Classification__c>());
        TaxClassificationCMDRequestController controller = new TaxClassificationCMDRequestController(stdController);
        
        System.assert(controller.lstTaxClassifications != null);
        System.assert(controller.lstTaxClassifications.size() > 0);
        
        //invoke saveTaxClassificationCMDRequest method
        pgRef = controller.saveTaxClassification();
        System.assert(pgRef != null);
        System.assertEquals(pgRef.getUrl(), '/' + controller.objCMDRequest.Id);
        
        //stop the test
        Test.stopTest();   
      }
    }  
    static testMethod void CMDRequestSALES_ORG_AT_61()
    {
        fetchRecordTypes();
        prepareConsolidatedAccountCode();
        createCustomer();
        
        CMD_Request__c objCMDRequest = new CMD_Request__c(
            Sales_Organisation__c = 'AT61 - SOrg. GRK',
            Reason_for_request__c = 'Test',
            Account_Group__c = 'Z001 - Sold To / Ship To / Bill To / Payer',
            RecordTypeId = SAP_New_MANU_Funloc_Request.Id,
            Consolidated_Account_Code__c = testCACC.Id,
            Ready_to_Submit__c = true,
            Request_Status__c = 'Ready to Submit',
            Business_Background_Comments__c = 'Test Business Background Comments',
            Global_Account__c = 'ABB - ABB',
            SP_GID__c = '100000000',            
            SP_Name__c = 'Test Name',
            SP_Street__c = 'Test Street',
            SP_City__c = 'Test City',
            SP_Country__c = 'Netherlands',
            SP_Postal_Code__c = '12345',
            Postal_Code__c = '12345',
            Region__c = 'EU - Europe',
            SP_Telephone__c = '+1234567890',
            SP_Fax__c = '+1234567890',
            SP_Email__c = 'test@test.com',
            SP_Funloc__c = '100000',            
            Company_Code__c = 'AT61 - NXP SemiconductorsAustria',
            Label_required__c = 'No',
            Industry_Segment__c = 'CC - Computing',
            Industry_Sub_Segment__c = 'C1 - Computing',
           // Customer_Factory_Calendar__c = '01 - Customer calendar Germany standard',
            Customer_Service_ZA__c = 'CN010 - China',
            Incoterms_1__c = 'CPT - Carriage paid to',
            Incoterms_2__c = 'Test',
            Lockbox__c = 'NOREMIT',
            Payment_Credit_Memo__c= '014 - Prepaid',
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
            S_O_Sub_Group__c = 'NL - Netherlands',
            Sales_Office__c = 'AT61 - SOffice GRK'
           
           );
            
        insert objCMDRequest;        
        system.assert(objCMDRequest.Id != null);
        
        //start the test
        Test.startTest();
        
        PageReference pgRef = Page.TaxClassification;
        pgRef.getParameters().put('Id',objCMDRequest.Id);
        Test.setCurrentPageReference(pgRef);
        
        ApexPages.StandardSetController stdController = new Apexpages.StandardSetController(new List<Tax_Classification__c>());
        TaxClassificationCMDRequestController controller = new TaxClassificationCMDRequestController(stdController);
        
        System.assert(controller.lstTaxClassifications != null);
        System.assert(controller.lstTaxClassifications.size() > 0);
        
        //invoke saveTaxClassificationCMDRequest method
        pgRef = controller.saveTaxClassification();
        System.assert(pgRef != null);
        System.assertEquals(pgRef.getUrl(), '/' + controller.objCMDRequest.Id);
        
        //stop the test
        Test.stopTest();   
    
    }  
    static testMethod void CMDRequestSALES_ORG_BE_61()
    {
        fetchRecordTypes();
        prepareConsolidatedAccountCode();
        createCustomer();
        
        CMD_Request__c objCMDRequest = new CMD_Request__c(
            Sales_Organisation__c = 'BE61 - NXP Semicon. Leuven',
            Reason_for_request__c = 'Test',
            Account_Group__c = 'Z001 - Sold To / Ship To / Bill To / Payer',
            RecordTypeId = SAP_New_MANU_Funloc_Request.Id,
            Consolidated_Account_Code__c = testCACC.Id,
            Ready_to_Submit__c = true,
            Request_Status__c = 'Ready to Submit',
            Business_Background_Comments__c = 'Test Business Background Comments',
            Global_Account__c = 'ABB - ABB',
            SP_GID__c = '100000000',            
            SP_Name__c = 'Test Name',
            SP_Street__c = 'Test Street',
            SP_City__c = 'Test City',
            SP_Country__c = 'Netherlands',
            SP_Postal_Code__c = '12345',
            Postal_Code__c = '12345',
            Region__c = 'EU - Europe',
            SP_Telephone__c = '+1234567890',
            SP_Fax__c = '+1234567890',
            SP_Email__c = 'test@test.com',
            SP_Funloc__c = '100000',            
            Company_Code__c = 'BE61 - NXP Semiconductors Leuven',
            Label_required__c = 'No',
            Industry_Segment__c = 'CC - Computing',
            Industry_Sub_Segment__c = 'C1 - Computing',
           // Customer_Factory_Calendar__c = '01 - Customer calendar Germany standard',
            Customer_Service_ZA__c = 'CN010 - China',
            Incoterms_1__c = 'CPT - Carriage paid to',
            Incoterms_2__c = 'Test',
            Lockbox__c = 'NOREMIT',
            Payment_Credit_Memo__c= '014 - Prepaid',
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
            S_O_Sub_Group__c = 'NL - Netherlands',
            Sales_Office__c = 'BE61 - NXP Semicon. Leuven'
           
           );
            
        insert objCMDRequest;        
        system.assert(objCMDRequest.Id != null);
        
        //start the test
        Test.startTest();
        
        PageReference pgRef = Page.TaxClassification;
        pgRef.getParameters().put('Id',objCMDRequest.Id);
        Test.setCurrentPageReference(pgRef);
        
        ApexPages.StandardSetController stdController = new Apexpages.StandardSetController(new List<Tax_Classification__c>());
        TaxClassificationCMDRequestController controller = new TaxClassificationCMDRequestController(stdController);
        
        System.assert(controller.lstTaxClassifications != null);
        System.assert(controller.lstTaxClassifications.size() > 0);
        
        //invoke saveTaxClassificationCMDRequest method
        pgRef = controller.saveTaxClassification();
        System.assert(pgRef != null);
        System.assertEquals(pgRef.getUrl(), '/' + controller.objCMDRequest.Id);
        
        //stop the test
        Test.stopTest();   
    
    }  
     static testMethod void CMDRequestSALES_ORG_CN68()
    {
        fetchRecordTypes();
        prepareConsolidatedAccountCode();
        createCustomer();
        
        CMD_Request__c objCMDRequest = new CMD_Request__c(
            Sales_Organisation__c = 'CN68 - NXP(China)Management',
            Reason_for_request__c = 'Test',
            Account_Group__c = 'Z001 - Sold To / Ship To / Bill To / Payer',
            RecordTypeId = SAP_New_MANU_Funloc_Request.Id,
            Consolidated_Account_Code__c = testCACC.Id,
            Ready_to_Submit__c = true,
            Request_Status__c = 'Ready to Submit',
            Business_Background_Comments__c = 'Test Business Background Comments',
            Global_Account__c = 'ABB - ABB',
            SP_GID__c = '100000000',            
            SP_Name__c = 'Test Name',
            SP_Street__c = 'Test Street',
            SP_City__c = 'Test City',
            SP_Country__c = 'Netherlands',
            SP_Postal_Code__c = '12345',
            Postal_Code__c = '12345',
            Region__c = 'EU - Europe',
            SP_Telephone__c = '+1234567890',
            SP_Fax__c = '+1234567890',
            SP_Email__c = 'test@test.com',
            SP_Funloc__c = '100000',            
            Company_Code__c = 'CN68 - NXP(China) Management Ltd',
            Label_required__c = 'No',
            Industry_Segment__c = 'CC - Computing',
            Industry_Sub_Segment__c = 'C1 - Computing',
          //  Customer_Factory_Calendar__c = '01 - Customer calendar Germany standard',
            Customer_Service_ZA__c = 'CN010 - China',
            Incoterms_1__c = 'CPT - Carriage paid to',
            Incoterms_2__c = 'Test',
            Lockbox__c = 'NOREMIT',
            Payment_Credit_Memo__c= '014 - Prepaid',
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
            S_O_Sub_Group__c = 'NL - Netherlands',
            Sales_Office__c = 'CN68 - NXP(China)Management'
           
           );
            
        insert objCMDRequest;        
        system.assert(objCMDRequest.Id != null);
        
        //start the test
        Test.startTest();
        
        PageReference pgRef = Page.TaxClassification;
        pgRef.getParameters().put('Id',objCMDRequest.Id);
        Test.setCurrentPageReference(pgRef);
        
        ApexPages.StandardSetController stdController = new Apexpages.StandardSetController(new List<Tax_Classification__c>());
        TaxClassificationCMDRequestController controller = new TaxClassificationCMDRequestController(stdController);
        
        System.assert(controller.lstTaxClassifications != null);
        System.assert(controller.lstTaxClassifications.size() > 0);
        
        //invoke saveTaxClassificationCMDRequest method
        pgRef = controller.saveTaxClassification();
        System.assert(pgRef != null);
        System.assertEquals(pgRef.getUrl(), '/' + controller.objCMDRequest.Id);
        
        //stop the test
        Test.stopTest();   
    
    }  
     static testMethod void CMDRequestSALES_ORG_DE42()
    {
        fetchRecordTypes();
        prepareConsolidatedAccountCode();
        createCustomer();
        
        CMD_Request__c objCMDRequest = new CMD_Request__c(
            Sales_Organisation__c = 'DE42 - NXP Hamburg Other',
            Reason_for_request__c = 'Test',
            Account_Group__c = 'Z001 - Sold To / Ship To / Bill To / Payer',
            RecordTypeId = SAP_New_MANU_Funloc_Request.Id,
            Consolidated_Account_Code__c = testCACC.Id,
            Ready_to_Submit__c = true,
            Request_Status__c = 'Ready to Submit',
            Business_Background_Comments__c = 'Test Business Background Comments',
            Global_Account__c = 'ABB - ABB',
            SP_GID__c = '100000000',            
            SP_Name__c = 'Test Name',
            SP_Street__c = 'Test Street',
            SP_City__c = 'Test City',
            SP_Country__c = 'Netherlands',
            SP_Postal_Code__c = '12345',
            Postal_Code__c = '12345',
            Region__c = 'EU - Europe',
            SP_Telephone__c = '+1234567890',
            SP_Fax__c = '+1234567890',
            SP_Email__c = 'test@test.com',
            SP_Funloc__c = '100000',            
            Company_Code__c = ' DE63 - NXP Semi. Germany(non-SP)',
            Label_required__c = 'No',
            Industry_Segment__c = 'CC - Computing',
            Industry_Sub_Segment__c = 'C1 - Computing',
        //    Customer_Factory_Calendar__c = '01 - Customer calendar Germany standard',
            Customer_Service_ZA__c = 'CN010 - China',
            Incoterms_1__c = 'CPT - Carriage paid to',
            Incoterms_2__c = 'Test',
            Lockbox__c = 'NOREMIT',
            Payment_Credit_Memo__c= '014 - Prepaid',
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
            S_O_Sub_Group__c = 'NL - Netherlands',
            Sales_Office__c = 'DE42 - NXP Hamburg Other'
            
           );
            
        insert objCMDRequest;        
        system.assert(objCMDRequest.Id != null);
        
        //start the test
        Test.startTest();
        
        PageReference pgRef = Page.TaxClassification;
        pgRef.getParameters().put('Id',objCMDRequest.Id);
        Test.setCurrentPageReference(pgRef);
        
        ApexPages.StandardSetController stdController = new Apexpages.StandardSetController(new List<Tax_Classification__c>());
        TaxClassificationCMDRequestController controller = new TaxClassificationCMDRequestController(stdController);
        
        System.assert(controller.lstTaxClassifications != null);
        System.assert(controller.lstTaxClassifications.size() > 0);
        
        //invoke saveTaxClassificationCMDRequest method
        pgRef = controller.saveTaxClassification();
        System.assert(pgRef != null);
        System.assertEquals(pgRef.getUrl(), '/' + controller.objCMDRequest.Id);
        
        //stop the test
        Test.stopTest();   
    
    }  
     static testMethod void CMDRequestSALES_ORG_DE63()
    {
        fetchRecordTypes();
        prepareConsolidatedAccountCode();
        createCustomer();
        
        CMD_Request__c objCMDRequest = new CMD_Request__c(
            Sales_Organisation__c = 'DE63 - NXP Semi. Germany',
            Reason_for_request__c = 'Test',
            Account_Group__c = 'Z001 - Sold To / Ship To / Bill To / Payer',
            RecordTypeId = SAP_New_MANU_Funloc_Request.Id,
            Consolidated_Account_Code__c = testCACC.Id,
            Ready_to_Submit__c = true,
            Request_Status__c = 'Ready to Submit',
            Business_Background_Comments__c = 'Test Business Background Comments',
            Global_Account__c = 'ABB - ABB',
            SP_GID__c = '100000000',            
            SP_Name__c = 'Test Name',
            SP_Street__c = 'Test Street',
            SP_City__c = 'Test City',
            SP_Country__c = 'Netherlands',
            SP_Postal_Code__c = '12345',
            Postal_Code__c = '12345',
            Region__c = 'EU - Europe',
            SP_Telephone__c = '+1234567890',
            SP_Fax__c = '+1234567890',
            SP_Email__c = 'test@test.com',
            SP_Funloc__c = '100000',            
            Company_Code__c = 'DE63 - NXP Semi. Germany(non-SP)',
            Label_required__c = 'No',
            Industry_Segment__c = 'CC - Computing',
            Industry_Sub_Segment__c = 'C1 - Computing',
         //   Customer_Factory_Calendar__c = '01 - Customer calendar Germany standard',
            Customer_Service_ZA__c = 'CN010 - China',
            Incoterms_1__c = 'CPT - Carriage paid to',
            Incoterms_2__c = 'Test',
            Lockbox__c = 'NOREMIT',
            Payment_Credit_Memo__c= '014 - Prepaid',
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
            S_O_Sub_Group__c = 'NL - Netherlands',
            Sales_Office__c = 'DE63 - NXP Semi Germany SO'
            
           );
            
        insert objCMDRequest;        
        system.assert(objCMDRequest.Id != null);
        
        //start the test
        Test.startTest();
        
        PageReference pgRef = Page.TaxClassification;
        pgRef.getParameters().put('Id',objCMDRequest.Id);
        Test.setCurrentPageReference(pgRef);
        
        ApexPages.StandardSetController stdController = new Apexpages.StandardSetController(new List<Tax_Classification__c>());
        TaxClassificationCMDRequestController controller = new TaxClassificationCMDRequestController(stdController);
        
        System.assert(controller.lstTaxClassifications != null);
        System.assert(controller.lstTaxClassifications.size() > 0);
        
        //invoke saveTaxClassificationCMDRequest method
        pgRef = controller.saveTaxClassification();
        System.assert(pgRef != null);
        System.assertEquals(pgRef.getUrl(), '/' + controller.objCMDRequest.Id);
        
        //stop the test
        Test.stopTest();   
    
    }  
     static testMethod void CMDRequestSALES_ORG_EM61()
    {
        fetchRecordTypes();
        prepareConsolidatedAccountCode();
        createCustomer();
        
        CMD_Request__c objCMDRequest = new CMD_Request__c(
            Sales_Organisation__c = 'EM61 - NXP GEM',
            Reason_for_request__c = 'Test',
            Account_Group__c = 'Z001 - Sold To / Ship To / Bill To / Payer',
            RecordTypeId = SAP_New_MANU_Funloc_Request.Id,
            Consolidated_Account_Code__c = testCACC.Id,
            Ready_to_Submit__c = true,
            Request_Status__c = 'Ready to Submit',
            Business_Background_Comments__c = 'Test Business Background Comments',
            Global_Account__c = 'ABB - ABB',
            SP_GID__c = '100000000',            
            SP_Name__c = 'Test Name',
            SP_Street__c = 'Test Street',
            SP_City__c = 'Test City',
            SP_Country__c = 'Netherlands',
            SP_Postal_Code__c = '12345',
            Postal_Code__c = '12345',
            Region__c = 'EU - Europe',
            SP_Telephone__c = '+1234567890',
            SP_Fax__c = '+1234567890',
            SP_Email__c = 'test@test.com',
            SP_Funloc__c = '100000',            
            Company_Code__c = ' TW61 - NXP Kaohsiung',
            Label_required__c = 'No',
            Industry_Segment__c = 'CC - Computing',
            Industry_Sub_Segment__c = 'C1 - Computing',
        //    Customer_Factory_Calendar__c = '01 - Customer calendar Germany standard',
            Customer_Service_ZA__c = 'CN010 - China',
            Incoterms_1__c = 'CPT - Carriage paid to',
            Incoterms_2__c = 'Test',
            Lockbox__c = 'NOREMIT',
            Payment_Credit_Memo__c= '014 - Prepaid',
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
            S_O_Sub_Group__c = 'NL - Netherlands',
            Sales_Office__c = 'TW61 - PSK TAIWAN'
            
           );
            
        insert objCMDRequest;        
        system.assert(objCMDRequest.Id != null);
        
        //start the test
        Test.startTest();
        
        PageReference pgRef = Page.TaxClassification;
        pgRef.getParameters().put('Id',objCMDRequest.Id);
        Test.setCurrentPageReference(pgRef);
        
        ApexPages.StandardSetController stdController = new Apexpages.StandardSetController(new List<Tax_Classification__c>());
        TaxClassificationCMDRequestController controller = new TaxClassificationCMDRequestController(stdController);
        
        System.assert(controller.lstTaxClassifications != null);
        System.assert(controller.lstTaxClassifications.size() > 0);
        
        //invoke saveTaxClassificationCMDRequest method
        pgRef = controller.saveTaxClassification();
        System.assert(pgRef != null);
        System.assertEquals(pgRef.getUrl(), '/' + controller.objCMDRequest.Id);
        
        //stop the test
        Test.stopTest();   
    
    }  
     static testMethod void CMDRequestSALES_ORG_FR61()
    {
        fetchRecordTypes();
        prepareConsolidatedAccountCode();
        createCustomer();
        
        CMD_Request__c objCMDRequest = new CMD_Request__c(
            Sales_Organisation__c = 'FR61 - NXP Caen',
            Reason_for_request__c = 'Test',
            Account_Group__c = 'Z001 - Sold To / Ship To / Bill To / Payer',
            RecordTypeId = SAP_New_MANU_Funloc_Request.Id,
            Consolidated_Account_Code__c = testCACC.Id,
            Ready_to_Submit__c = true,
            Request_Status__c = 'Ready to Submit',
            Business_Background_Comments__c = 'Test Business Background Comments',
            Global_Account__c = 'ABB - ABB',
            SP_GID__c = '100000000',            
            SP_Name__c = 'Test Name',
            SP_Street__c = 'Test Street',
            SP_City__c = 'Test City',
            SP_Country__c = 'Netherlands',
            SP_Postal_Code__c = '12345',
            Postal_Code__c = '12345',
            Region__c = 'EU - Europe',
            SP_Telephone__c = '+1234567890',
            SP_Fax__c = '+1234567890',
            SP_Email__c = 'test@test.com',
            SP_Funloc__c = '100000',            
            Company_Code__c = 'FR61 - NXP Semi. France',
            Label_required__c = 'No',
            Industry_Segment__c = 'CC - Computing',
            Industry_Sub_Segment__c = 'C1 - Computing',
            Customer_Factory_Calendar__c = '01 - Customer calendar Germany standard',
            Customer_Service_ZA__c = 'CN010 - China',
            Incoterms_1__c = 'CPT - Carriage paid to',
            Incoterms_2__c = 'Test',
            Lockbox__c = 'NOREMIT',
            Payment_Credit_Memo__c= '014 - Prepaid',
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
            S_O_Sub_Group__c = 'NL - Netherlands',
            Sales_Office__c = 'FR61 - NXP Caen'
            
           );
            
        insert objCMDRequest;        
        system.assert(objCMDRequest.Id != null);
        
        //start the test
        Test.startTest();
        
        PageReference pgRef = Page.TaxClassification;
        pgRef.getParameters().put('Id',objCMDRequest.Id);
        Test.setCurrentPageReference(pgRef);
        
        ApexPages.StandardSetController stdController = new Apexpages.StandardSetController(new List<Tax_Classification__c>());
        TaxClassificationCMDRequestController controller = new TaxClassificationCMDRequestController(stdController);
        
        System.assert(controller.lstTaxClassifications != null);
        System.assert(controller.lstTaxClassifications.size() > 0);
        
        //invoke saveTaxClassificationCMDRequest method
        pgRef = controller.saveTaxClassification();
        System.assert(pgRef != null);
        System.assertEquals(pgRef.getUrl(), '/' + controller.objCMDRequest.Id);
        
        //stop the test
        Test.stopTest();   
    
    }  
     static testMethod void CMDRequestSALES_ORG_IN61()
    {
        fetchRecordTypes();
        prepareConsolidatedAccountCode();
        createCustomer();
        
        CMD_Request__c objCMDRequest = new CMD_Request__c(
            Sales_Organisation__c = 'IN61 - NXP India',
            Reason_for_request__c = 'Test',
            Account_Group__c = 'Z001 - Sold To / Ship To / Bill To / Payer',
            RecordTypeId = SAP_New_MANU_Funloc_Request.Id,
            Consolidated_Account_Code__c = testCACC.Id,
            Ready_to_Submit__c = true,
            Request_Status__c = 'Ready to Submit',
            Business_Background_Comments__c = 'Test Business Background Comments',
            Global_Account__c = 'ABB - ABB',
            SP_GID__c = '100000000',            
            SP_Name__c = 'Test Name',
            SP_Street__c = 'Test Street',
            SP_City__c = 'Test City',
            SP_Country__c = 'Netherlands',
            SP_Postal_Code__c = '12345',
            Postal_Code__c = '12345',
            Region__c = 'EU - Europe',
            SP_Telephone__c = '+1234567890',
            SP_Fax__c = '+1234567890',
            SP_Email__c = 'test@test.com',
            SP_Funloc__c = '100000',            
            Company_Code__c = 'IN61 - NXP India Private Limited',
            Label_required__c = 'No',
            Industry_Segment__c = 'CC - Computing',
            Industry_Sub_Segment__c = 'C1 - Computing',
            Customer_Factory_Calendar__c = '01 - Customer calendar Germany standard',
            Customer_Service_ZA__c = 'CN010 - China',
            Incoterms_1__c = 'CPT - Carriage paid to',
            Incoterms_2__c = 'Test',
            Lockbox__c = 'NOREMIT',
            Payment_Credit_Memo__c= '014 - Prepaid',
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
            S_O_Sub_Group__c = 'NL - Netherlands',
            Sales_Office__c = 'IN61 - NXP India'
           
           );
            
        insert objCMDRequest;        
        system.assert(objCMDRequest.Id != null);
        
        //start the test
        Test.startTest();
        
        PageReference pgRef = Page.TaxClassification;
        pgRef.getParameters().put('Id',objCMDRequest.Id);
        Test.setCurrentPageReference(pgRef);
        
        ApexPages.StandardSetController stdController = new Apexpages.StandardSetController(new List<Tax_Classification__c>());
        TaxClassificationCMDRequestController controller = new TaxClassificationCMDRequestController(stdController);
        
        System.assert(controller.lstTaxClassifications != null);
        System.assert(controller.lstTaxClassifications.size() > 0);
        
        //invoke saveTaxClassificationCMDRequest method
        pgRef = controller.saveTaxClassification();
        System.assert(pgRef != null);
        System.assertEquals(pgRef.getUrl(), '/' + controller.objCMDRequest.Id);
        
        //stop the test
        Test.stopTest();   
    
    } 
    
    static testMethod void CMDRequestSALES_ORG_BR61()
    {
        fetchRecordTypes();
        prepareConsolidatedAccountCode();
        createCustomer();
        
        CMD_Request__c objCMDRequest = new CMD_Request__c(
            Sales_Organisation__c = 'BR61 - SOrg. Brazil',
            Reason_for_request__c = 'Test',
            Account_Group__c = 'Z001 - Sold To / Ship To / Bill To / Payer',
            RecordTypeId = SAP_New_MANU_Funloc_Request.Id,
            Consolidated_Account_Code__c = testCACC.Id,
            Ready_to_Submit__c = true,
            Request_Status__c = 'Ready to Submit',
            Business_Background_Comments__c = 'Test Business Background Comments',
            Global_Account__c = 'ABB - ABB',
            SP_GID__c = '100000000',            
            SP_Name__c = 'Test Name',
            SP_Street__c = 'Test Street',
            SP_City__c = 'Test City',
            SP_Country__c = 'Netherlands',
            SP_Postal_Code__c = '12345',
            Postal_Code__c = '12345',
            Region__c = 'EU - Europe',
            SP_Telephone__c = '+1234567890',
            SP_Fax__c = '+1234567890',
            SP_Email__c = 'test@test.com',
            SP_Funloc__c = '100000',            
            Company_Code__c = 'BR61 - NXP Semi Brasil',
            Label_required__c = 'No',
            Industry_Segment__c = 'CC - Computing',
            Industry_Sub_Segment__c = 'C1 - Computing',
            Customer_Factory_Calendar__c = '01 - Customer calendar Germany standard',
            Customer_Service_ZA__c = 'CN010 - China',
            Incoterms_1__c = 'CPT - Carriage paid to',
            Incoterms_2__c = 'Test',
            Lockbox__c = 'NOREMIT',
            Payment_Credit_Memo__c= '014 - Prepaid',
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
            S_O_Sub_Group__c = 'NL - Netherlands',
            Sales_Office__c = 'BR61 - SOffice Brazil'
           
           );
            
        insert objCMDRequest;        
        system.assert(objCMDRequest.Id != null);
        
        //start the test
        Test.startTest();
        
        PageReference pgRef = Page.TaxClassification;
        pgRef.getParameters().put('Id',objCMDRequest.Id);
        Test.setCurrentPageReference(pgRef);
        
        ApexPages.StandardSetController stdController = new Apexpages.StandardSetController(new List<Tax_Classification__c>());
        TaxClassificationCMDRequestController controller = new TaxClassificationCMDRequestController(stdController);
        
        System.assert(controller.lstTaxClassifications != null);
        System.assert(controller.lstTaxClassifications.size() > 0);
        
        //invoke saveTaxClassificationCMDRequest method
        pgRef = controller.saveTaxClassification();
        System.assert(pgRef != null);
        System.assertEquals(pgRef.getUrl(), '/' + controller.objCMDRequest.Id);
        
        //stop the test
        Test.stopTest();   
    
    }   
    static testMethod void CMDRequestSALES_ORG_HU61()
    {
        fetchRecordTypes();
        prepareConsolidatedAccountCode();
        createCustomer();
        
        CMD_Request__c objCMDRequest = new CMD_Request__c(
            Sales_Organisation__c = 'HU61 - Sorg Hungary',
            Reason_for_request__c = 'Test',
            Account_Group__c = 'Z001 - Sold To / Ship To / Bill To / Payer',
            RecordTypeId = SAP_New_MANU_Funloc_Request.Id,
            Consolidated_Account_Code__c = testCACC.Id,
            Ready_to_Submit__c = true,
            Request_Status__c = 'Ready to Submit',
            Business_Background_Comments__c = 'Test Business Background Comments',
            Global_Account__c = 'ABB - ABB',
            SP_GID__c = '100000000',            
            SP_Name__c = 'Test Name',
            SP_Street__c = 'Test Street',
            SP_City__c = 'Test City',
            SP_Country__c = 'Netherlands',
            SP_Postal_Code__c = '12345',
            Postal_Code__c = '12345',
            Region__c = 'EU - Europe',
            SP_Telephone__c = '+1234567890',
            SP_Fax__c = '+1234567890',
            SP_Email__c = 'test@test.com',
            SP_Funloc__c = '100000',            
            Company_Code__c = 'HU61 - NXP SMO Hungary',
            Label_required__c = 'No',
            Industry_Segment__c = 'CC - Computing',
            Industry_Sub_Segment__c = 'C1 - Computing',
            Customer_Factory_Calendar__c = '01 - Customer calendar Germany standard',
            Customer_Service_ZA__c = 'CN010 - China',
            Incoterms_1__c = 'CPT - Carriage paid to',
            Incoterms_2__c = 'Test',
            Lockbox__c = 'NOREMIT',
            Payment_Credit_Memo__c= '014 - Prepaid',
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
            S_O_Sub_Group__c = 'NL - Netherlands',
            Sales_Office__c = 'HU61 - SOffice Hungary'
           
           );
            
        insert objCMDRequest;        
        system.assert(objCMDRequest.Id != null);
        
        //start the test
        Test.startTest();
        
        PageReference pgRef = Page.TaxClassification;
        pgRef.getParameters().put('Id',objCMDRequest.Id);
        Test.setCurrentPageReference(pgRef);
        
        ApexPages.StandardSetController stdController = new Apexpages.StandardSetController(new List<Tax_Classification__c>());
        TaxClassificationCMDRequestController controller = new TaxClassificationCMDRequestController(stdController);
        
        System.assert(controller.lstTaxClassifications != null);
        System.assert(controller.lstTaxClassifications.size() > 0);
        
        //invoke saveTaxClassificationCMDRequest method
        pgRef = controller.saveTaxClassification();
        System.assert(pgRef != null);
        System.assertEquals(pgRef.getUrl(), '/' + controller.objCMDRequest.Id);
        
        //stop the test
        Test.stopTest();   
    
    }   
    static testMethod void CMDRequestSALES_ORG_IT61()
    {
        fetchRecordTypes();
        prepareConsolidatedAccountCode();
        createCustomer();
        
        CMD_Request__c objCMDRequest = new CMD_Request__c(
            Sales_Organisation__c = 'IT61 - Sorg Italy',
            Reason_for_request__c = 'Test',
            Account_Group__c = 'Z001 - Sold To / Ship To / Bill To / Payer',
            RecordTypeId = SAP_New_MANU_Funloc_Request.Id,
            Consolidated_Account_Code__c = testCACC.Id,
            Ready_to_Submit__c = true,
            Request_Status__c = 'Ready to Submit',
            Business_Background_Comments__c = 'Test Business Background Comments',
            Global_Account__c = 'ABB - ABB',
            SP_GID__c = '100000000',            
            SP_Name__c = 'Test Name',
            SP_Street__c = 'Test Street',
            SP_City__c = 'Test City',
            SP_Country__c = 'Netherlands',
            SP_Postal_Code__c = '12345',
            Postal_Code__c = '12345',
            Region__c = 'EU - Europe',
            SP_Telephone__c = '+1234567890',
            SP_Fax__c = '+1234567890',
            SP_Email__c = 'test@test.com',
            SP_Funloc__c = '100000',            
            Company_Code__c = 'IT61 - NXP Semi Branch Italia',
            Label_required__c = 'No',
            Industry_Segment__c = 'CC - Computing',
            Industry_Sub_Segment__c = 'C1 - Computing',
            Customer_Factory_Calendar__c = '01 - Customer calendar Germany standard',
            Customer_Service_ZA__c = 'CN010 - China',
            Incoterms_1__c = 'CPT - Carriage paid to',
            Incoterms_2__c = 'Test',
            Lockbox__c = 'NOREMIT',
            Payment_Credit_Memo__c= '014 - Prepaid',
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
            S_O_Sub_Group__c = 'NL - Netherlands',
            Sales_Office__c = 'IT61 - SOffice Italy'
           
           );
            
        insert objCMDRequest;        
        system.assert(objCMDRequest.Id != null);
        
        //start the test
        Test.startTest();
        
        PageReference pgRef = Page.TaxClassification;
        pgRef.getParameters().put('Id',objCMDRequest.Id);
        Test.setCurrentPageReference(pgRef);
        
        ApexPages.StandardSetController stdController = new Apexpages.StandardSetController(new List<Tax_Classification__c>());
        TaxClassificationCMDRequestController controller = new TaxClassificationCMDRequestController(stdController);
        
        System.assert(controller.lstTaxClassifications != null);
        System.assert(controller.lstTaxClassifications.size() > 0);
        
        //invoke saveTaxClassificationCMDRequest method
        pgRef = controller.saveTaxClassification();
        System.assert(pgRef != null);
        System.assertEquals(pgRef.getUrl(), '/' + controller.objCMDRequest.Id);
        
        //stop the test
        Test.stopTest();   
    
    }   
    static testMethod void CMDRequestSALES_ORG_KR61()
    {
        fetchRecordTypes();
        prepareConsolidatedAccountCode();
        createCustomer();
        
        CMD_Request__c objCMDRequest = new CMD_Request__c(
            Sales_Organisation__c = 'KR61 - Sorg Korea',
            Reason_for_request__c = 'Test',
            Account_Group__c = 'Z001 - Sold To / Ship To / Bill To / Payer',
            RecordTypeId = SAP_New_MANU_Funloc_Request.Id,
            Consolidated_Account_Code__c = testCACC.Id,
            Ready_to_Submit__c = true,
            Request_Status__c = 'Ready to Submit',
            Business_Background_Comments__c = 'Test Business Background Comments',
            Global_Account__c = 'ABB - ABB',
            SP_GID__c = '100000000',            
            SP_Name__c = 'Test Name',
            SP_Street__c = 'Test Street',
            SP_City__c = 'Test City',
            SP_Country__c = 'Netherlands',
            SP_Postal_Code__c = '12345',
            Postal_Code__c = '12345',
            Region__c = 'EU - Europe',
            SP_Telephone__c = '+1234567890',
            SP_Fax__c = '+1234567890',
            SP_Email__c = 'test@test.com',
            SP_Funloc__c = '100000',            
            Company_Code__c = 'KR61 - NXP Semiconductors Korea',
            Label_required__c = 'No',
            Industry_Segment__c = 'CC - Computing',
            Industry_Sub_Segment__c = 'C1 - Computing',
            Customer_Factory_Calendar__c = '01 - Customer calendar Germany standard',
            Customer_Service_ZA__c = 'CN010 - China',
            Incoterms_1__c = 'CPT - Carriage paid to',
            Incoterms_2__c = 'Test',
            Lockbox__c = 'NOREMIT',
            Payment_Credit_Memo__c= '014 - Prepaid',
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
            S_O_Sub_Group__c = 'NL - Netherlands',
            Sales_Office__c = 'KR61 - SOffice KOREA'
           
           );
            
        insert objCMDRequest;        
        system.assert(objCMDRequest.Id != null);
        
        //start the test
        Test.startTest();
        
        PageReference pgRef = Page.TaxClassification;
        pgRef.getParameters().put('Id',objCMDRequest.Id);
        Test.setCurrentPageReference(pgRef);
        
        ApexPages.StandardSetController stdController = new Apexpages.StandardSetController(new List<Tax_Classification__c>());
        TaxClassificationCMDRequestController controller = new TaxClassificationCMDRequestController(stdController);
        
        System.assert(controller.lstTaxClassifications != null);
        System.assert(controller.lstTaxClassifications.size() > 0);
        
        //invoke saveTaxClassificationCMDRequest method
        pgRef = controller.saveTaxClassification();
        System.assert(pgRef != null);
        System.assertEquals(pgRef.getUrl(), '/' + controller.objCMDRequest.Id);
        
        //stop the test
        Test.stopTest();   
    
    }   
     static testMethod void CMDRequestSALES_ORG_MX61()
    {
        fetchRecordTypes();
        prepareConsolidatedAccountCode();
        createCustomer();
        
        CMD_Request__c objCMDRequest = new CMD_Request__c(
            Sales_Organisation__c = 'MX61 - SOrg. Mexico',
            Reason_for_request__c = 'Test',
            Account_Group__c = 'Z001 - Sold To / Ship To / Bill To / Payer',
            RecordTypeId = SAP_New_MANU_Funloc_Request.Id,
            Consolidated_Account_Code__c = testCACC.Id,
            Ready_to_Submit__c = true,
            Request_Status__c = 'Ready to Submit',
            Business_Background_Comments__c = 'Test Business Background Comments',
            Global_Account__c = 'ABB - ABB',
            SP_GID__c = '100000000',            
            SP_Name__c = 'Test Name',
            SP_Street__c = 'Test Street',
            SP_City__c = 'Test City',
            SP_Country__c = 'Netherlands',
            SP_Postal_Code__c = '12345',
            Postal_Code__c = '12345',
            Region__c = 'EU - Europe',
            SP_Telephone__c = '+1234567890',
            SP_Fax__c = '+1234567890',
            SP_Email__c = 'test@test.com',
            SP_Funloc__c = '100000',            
            Company_Code__c = 'MX61 - NXP Semiconductors Mexico',
            Label_required__c = 'No',
            Industry_Segment__c = 'CC - Computing',
            Industry_Sub_Segment__c = 'C1 - Computing',
            Customer_Factory_Calendar__c = '01 - Customer calendar Germany standard',
            Customer_Service_ZA__c = 'CN010 - China',
            Incoterms_1__c = 'CPT - Carriage paid to',
            Incoterms_2__c = 'Test',
            Lockbox__c = 'NOREMIT',
            Payment_Credit_Memo__c= '014 - Prepaid',
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
            S_O_Sub_Group__c = 'NL - Netherlands',
            Sales_Office__c = 'MX61 - SOffice Mexico'
           
           );
            
        insert objCMDRequest;        
        system.assert(objCMDRequest.Id != null);
        
        //start the test
        Test.startTest();
        
        PageReference pgRef = Page.TaxClassification;
        pgRef.getParameters().put('Id',objCMDRequest.Id);
        Test.setCurrentPageReference(pgRef);
        
        ApexPages.StandardSetController stdController = new Apexpages.StandardSetController(new List<Tax_Classification__c>());
        TaxClassificationCMDRequestController controller = new TaxClassificationCMDRequestController(stdController);
        
        System.assert(controller.lstTaxClassifications != null);
        System.assert(controller.lstTaxClassifications.size() > 0);
        
        //invoke saveTaxClassificationCMDRequest method
        pgRef = controller.saveTaxClassification();
        System.assert(pgRef != null);
        System.assertEquals(pgRef.getUrl(), '/' + controller.objCMDRequest.Id);
        
        //stop the test
        Test.stopTest();   
    
    }  
     static testMethod void CMDRequestSALES_ORG_NL40()
    {
        fetchRecordTypes();
        prepareConsolidatedAccountCode();
        createCustomer();
        
        CMD_Request__c objCMDRequest = new CMD_Request__c(
            Sales_Organisation__c = 'NL40 - NXP Nijmegen Site Su',
            Reason_for_request__c = 'Test',
            Account_Group__c = 'Z001 - Sold To / Ship To / Bill To / Payer',
            RecordTypeId = SAP_New_MANU_Funloc_Request.Id,
            Consolidated_Account_Code__c = testCACC.Id,
            Ready_to_Submit__c = true,
            Request_Status__c = 'Ready to Submit',
            Business_Background_Comments__c = 'Test Business Background Comments',
            Global_Account__c = 'ABB - ABB',
            SP_GID__c = '100000000',            
            SP_Name__c = 'Test Name',
            SP_Street__c = 'Test Street',
            SP_City__c = 'Test City',
            SP_Country__c = 'Netherlands',
            SP_Postal_Code__c = '12345',
            Postal_Code__c = '12345',
            Region__c = 'EU - Europe',
            SP_Telephone__c = '+1234567890',
            SP_Fax__c = '+1234567890',
            SP_Email__c = 'test@test.com',
            SP_Funloc__c = '100000',            
            Company_Code__c = 'NL61 - NXP Semi. Netherlands BV',
            Label_required__c = 'No',
            Industry_Segment__c = 'CC - Computing',
            Industry_Sub_Segment__c = 'C1 - Computing',
            Customer_Factory_Calendar__c = '01 - Customer calendar Germany standard',
            Customer_Service_ZA__c = 'CN010 - China',
            Incoterms_1__c = 'CPT - Carriage paid to',
            Incoterms_2__c = 'Test',
            Lockbox__c = 'NOREMIT',
            Payment_Credit_Memo__c= '014 - Prepaid',
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
            S_O_Sub_Group__c = 'NL - Netherlands',
            Sales_Office__c = 'NL40 - NXP Nijmegen Site Su'
           
           );
            
        insert objCMDRequest;        
        system.assert(objCMDRequest.Id != null);
        
        //start the test
        Test.startTest();
        
        PageReference pgRef = Page.TaxClassification;
        pgRef.getParameters().put('Id',objCMDRequest.Id);
        Test.setCurrentPageReference(pgRef);
        
        ApexPages.StandardSetController stdController = new Apexpages.StandardSetController(new List<Tax_Classification__c>());
        TaxClassificationCMDRequestController controller = new TaxClassificationCMDRequestController(stdController);
        
        System.assert(controller.lstTaxClassifications != null);
        System.assert(controller.lstTaxClassifications.size() > 0);
        
        //invoke saveTaxClassificationCMDRequest method
        pgRef = controller.saveTaxClassification();
        System.assert(pgRef != null);
        System.assertEquals(pgRef.getUrl(), '/' + controller.objCMDRequest.Id);
        
        //stop the test
        Test.stopTest();   
    
    }  
     static testMethod void CMDRequestSALES_ORG_NL61()
    {
        fetchRecordTypes();
        prepareConsolidatedAccountCode();
        createCustomer();
        
        CMD_Request__c objCMDRequest = new CMD_Request__c(
            Sales_Organisation__c = 'NL61 - Nijmegen',
            Reason_for_request__c = 'Test',
            Account_Group__c = 'Z001 - Sold To / Ship To / Bill To / Payer',
            RecordTypeId = SAP_New_MANU_Funloc_Request.Id,
            Consolidated_Account_Code__c = testCACC.Id,
            Ready_to_Submit__c = true,
            Request_Status__c = 'Ready to Submit',
            Business_Background_Comments__c = 'Test Business Background Comments',
            Global_Account__c = 'ABB - ABB',
            SP_GID__c = '100000000',            
            SP_Name__c = 'Test Name',
            SP_Street__c = 'Test Street',
            SP_City__c = 'Test City',
            SP_Country__c = 'Netherlands',
            SP_Postal_Code__c = '12345',
            Postal_Code__c = '12345',
            Region__c = 'EU - Europe',
            SP_Telephone__c = '+1234567890',
            SP_Fax__c = '+1234567890',
            SP_Email__c = 'test@test.com',
            SP_Funloc__c = '100000',            
            Company_Code__c = 'NL61 - NXP Semi. Netherlands BV',
            Label_required__c = 'No',
            Industry_Segment__c = 'CC - Computing',
            Industry_Sub_Segment__c = 'C1 - Computing',
            Customer_Factory_Calendar__c = '01 - Customer calendar Germany standard',
            Customer_Service_ZA__c = 'CN010 - China',
            Incoterms_1__c = 'CPT - Carriage paid to',
            Incoterms_2__c = 'Test',
            Lockbox__c = 'NOREMIT',
            Payment_Credit_Memo__c= '014 - Prepaid',
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
            S_O_Sub_Group__c = 'NL - Netherlands',
            Sales_Office__c = 'NL61 - NIJMEGEN'
            
           );
            
        insert objCMDRequest;        
        system.assert(objCMDRequest.Id != null);
        
        //start the test
        Test.startTest();
        
        PageReference pgRef = Page.TaxClassification;
        pgRef.getParameters().put('Id',objCMDRequest.Id);
        Test.setCurrentPageReference(pgRef);
        
        ApexPages.StandardSetController stdController = new Apexpages.StandardSetController(new List<Tax_Classification__c>());
        TaxClassificationCMDRequestController controller = new TaxClassificationCMDRequestController(stdController);
        
        System.assert(controller.lstTaxClassifications != null);
        System.assert(controller.lstTaxClassifications.size() > 0);
        
        //invoke saveTaxClassificationCMDRequest method
        pgRef = controller.saveTaxClassification();
        System.assert(pgRef != null);
        System.assertEquals(pgRef.getUrl(), '/' + controller.objCMDRequest.Id);
        
        //stop the test
        Test.stopTest();   
    
    }  
     static testMethod void CMDRequestSALES_ORG_NL68()
    {
        fetchRecordTypes();
        prepareConsolidatedAccountCode();
        createCustomer();
        
        CMD_Request__c objCMDRequest = new CMD_Request__c(
            Sales_Organisation__c = 'NL68 - NXP Software',
            Reason_for_request__c = 'Test',
            Account_Group__c = 'Z001 - Sold To / Ship To / Bill To / Payer',
            RecordTypeId = SAP_New_SBE_Funloc_request.Id,
            Consolidated_Account_Code__c = testCACC.Id,
            Ready_to_Submit__c = true,
            Request_Status__c = 'Ready to Submit',
            Business_Background_Comments__c = 'Test Business Background Comments',
            Global_Account__c = 'ABB - ABB',
            SP_GID__c = '100000000',            
            SP_Name__c = 'Test Name',
            SP_Street__c = 'Test Street',
            SP_City__c = 'Test City',
            SP_Country__c = 'Netherlands',
            SP_Postal_Code__c = '12345',
            Postal_Code__c = '12345',
            Region__c = 'EU - Europe',
            SP_Telephone__c = '+1234567890',
            SP_Fax__c = '+1234567890',
            SP_Email__c = 'test@test.com',
            SP_Funloc__c = '100000',            
            Company_Code__c = 'NL68 - NXP Software B.V.',
            Label_required__c = 'No',
            Industry_Segment__c = 'CC - Computing',
            Industry_Sub_Segment__c = 'C1 - Computing',
            Customer_Factory_Calendar__c = '01 - Customer calendar Germany standard',
            Customer_Service_ZA__c = 'NL029 - NL60 Country Administrator',
            Incoterms_1__c = 'CPT - Carriage paid to',
            Incoterms_2__c = 'Test',
            Lockbox__c = 'NOREMIT',
            Payment_Credit_Memo__c= '014 - Prepaid',
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
            S_O_Sub_Group__c = 'NL - Netherlands',
            Sales_Office__c = 'NL68 - NXP Software'
           
           );
            
        insert objCMDRequest;        
        system.assert(objCMDRequest.Id != null);
        
        //start the test
        Test.startTest();
        
        PageReference pgRef = Page.TaxClassification;
        pgRef.getParameters().put('Id',objCMDRequest.Id);
        Test.setCurrentPageReference(pgRef);
        
        ApexPages.StandardSetController stdController = new Apexpages.StandardSetController(new List<Tax_Classification__c>());
        TaxClassificationCMDRequestController controller = new TaxClassificationCMDRequestController(stdController);
        
        System.assert(controller.lstTaxClassifications != null);
        System.assert(controller.lstTaxClassifications.size() > 0);
        
        //invoke saveTaxClassificationCMDRequest method
        pgRef = controller.saveTaxClassification();
        System.assert(pgRef != null);
        System.assertEquals(pgRef.getUrl(), '/' + controller.objCMDRequest.Id);
        
        //stop the test
        Test.stopTest();   
    
    }  
     static testMethod void CMDRequestSALES_ORG_RO61()
    {
        fetchRecordTypes();
        prepareConsolidatedAccountCode();
        createCustomer();
        
        CMD_Request__c objCMDRequest = new CMD_Request__c(
            Sales_Organisation__c = 'RO61 - SOrg. Romania',
            Reason_for_request__c = 'Test',
            Account_Group__c = 'Z001 - Sold To / Ship To / Bill To / Payer',
            RecordTypeId = SAP_New_MANU_Funloc_Request.Id,
            Consolidated_Account_Code__c = testCACC.Id,
            Ready_to_Submit__c = true,
            Request_Status__c = 'Ready to Submit',
            Business_Background_Comments__c = 'Test Business Background Comments',
            Global_Account__c = 'ABB - ABB',
            SP_GID__c = '100000000',            
            SP_Name__c = 'Test Name',
            SP_Street__c = 'Test Street',
            SP_City__c = 'Test City',
            SP_Country__c = 'Netherlands',
            SP_Postal_Code__c = '12345',
            Postal_Code__c = '12345',
            Region__c = 'EU - Europe',
            SP_Telephone__c = '+1234567890',
            SP_Fax__c = '+1234567890',
            SP_Email__c = 'test@test.com',
            SP_Funloc__c = '100000',            
            Company_Code__c = 'RO61 - NXP FSL R&D SMO Romania Bucharest',
            Label_required__c = 'No',
            Industry_Segment__c = 'CC - Computing',
            Industry_Sub_Segment__c = 'C1 - Computing',
            Customer_Factory_Calendar__c = '01 - Customer calendar Germany standard',
            Customer_Service_ZA__c = 'CN010 - China',
            Incoterms_1__c = 'CPT - Carriage paid to',
            Incoterms_2__c = 'Test',
            Lockbox__c = 'NOREMIT',
            Payment_Credit_Memo__c= '014 - Prepaid',
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
            S_O_Sub_Group__c = 'NL - Netherlands',
            Sales_Office__c = 'RO61 - SOffice Rom'
          
           );
            
        insert objCMDRequest;        
        system.assert(objCMDRequest.Id != null);
        
        //start the test
        Test.startTest();
        
        PageReference pgRef = Page.TaxClassification;
        pgRef.getParameters().put('Id',objCMDRequest.Id);
        Test.setCurrentPageReference(pgRef);
        
        ApexPages.StandardSetController stdController = new Apexpages.StandardSetController(new List<Tax_Classification__c>());
        TaxClassificationCMDRequestController controller = new TaxClassificationCMDRequestController(stdController);
        
        System.assert(controller.lstTaxClassifications != null);
        System.assert(controller.lstTaxClassifications.size() > 0);
        
        //invoke saveTaxClassificationCMDRequest method
        pgRef = controller.saveTaxClassification();
        System.assert(pgRef != null);
        System.assertEquals(pgRef.getUrl(), '/' + controller.objCMDRequest.Id);
        
        //stop the test
        Test.stopTest();   
    
    }  
     static testMethod void CMDRequestSALES_ORG_CA61()
    {
        fetchRecordTypes();
        prepareConsolidatedAccountCode();
        createCustomer();
        
        CMD_Request__c objCMDRequest = new CMD_Request__c(
            Sales_Organisation__c = 'CA61 - SOrg Canada',
            Reason_for_request__c = 'Test',
            Account_Group__c = 'Z001 - Sold To / Ship To / Bill To / Payer',
            RecordTypeId = SAP_New_MANU_Funloc_Request.Id,
            Consolidated_Account_Code__c = testCACC.Id,
            Ready_to_Submit__c = true,
            Request_Status__c = 'Ready to Submit',
            Business_Background_Comments__c = 'Test Business Background Comments',
            Global_Account__c = 'ABB - ABB',
            SP_GID__c = '100000000',            
            SP_Name__c = 'Test Name',
            SP_Street__c = 'Test Street',
            SP_City__c = 'Test City',
            SP_Country__c = 'Netherlands',
            SP_Postal_Code__c = '12345',
            Postal_Code__c = '12345',
            Region__c = 'EU - Europe',
            SP_Telephone__c = '+1234567890',
            SP_Fax__c = '+1234567890',
            SP_Email__c = 'test@test.com',
            SP_Funloc__c = '100000',            
            Company_Code__c = 'CA61 - NXP Canada',
            Label_required__c = 'No',
            Industry_Segment__c = 'CC - Computing',
            Industry_Sub_Segment__c = 'C1 - Computing',
           // Customer_Factory_Calendar__c = '01 - Customer calendar Germany standard',
            Customer_Service_ZA__c = 'CN010 - China',
            Incoterms_1__c = 'CPT - Carriage paid to',
            Incoterms_2__c = 'Test',
            Lockbox__c = 'NOREMIT',
            Payment_Credit_Memo__c= '014 - Prepaid',
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
            S_O_Sub_Group__c = 'NL - Netherlands',
            Sales_Office__c = 'CA61 - SOffice Canada'
            
           );
            
        insert objCMDRequest;        
        system.assert(objCMDRequest.Id != null);
        
        //start the test
        Test.startTest();
        
        PageReference pgRef = Page.TaxClassification;
        pgRef.getParameters().put('Id',objCMDRequest.Id);
        Test.setCurrentPageReference(pgRef);
        
        ApexPages.StandardSetController stdController = new Apexpages.StandardSetController(new List<Tax_Classification__c>());
        TaxClassificationCMDRequestController controller = new TaxClassificationCMDRequestController(stdController);
        
        System.assert(controller.lstTaxClassifications != null);
        System.assert(controller.lstTaxClassifications.size() > 0);
        
        //invoke saveTaxClassificationCMDRequest method
        pgRef = controller.saveTaxClassification();
        System.assert(pgRef != null);
        System.assertEquals(pgRef.getUrl(), '/' + controller.objCMDRequest.Id);
        
        //stop the test
        Test.stopTest();   
    
    }  
    static testMethod void CMDRequestSALES_ORG_CN6A()
    {
        fetchRecordTypes();
        prepareConsolidatedAccountCode();
        createCustomer();
        
        CMD_Request__c objCMDRequest = new CMD_Request__c(
            Sales_Organisation__c = 'CN6A - SOrg. Chongqing',
            Reason_for_request__c = 'Test',
            Account_Group__c = 'Z001 - Sold To / Ship To / Bill To / Payer',
            RecordTypeId = SAP_New_MANU_Funloc_Request.Id,
            Consolidated_Account_Code__c = testCACC.Id,
            Ready_to_Submit__c = true,
            Request_Status__c = 'Ready to Submit',
            Business_Background_Comments__c = 'Test Business Background Comments',
            Global_Account__c = 'ABB - ABB',
            SP_GID__c = '100000000',            
            SP_Name__c = 'Test Name',
            SP_Street__c = 'Test Street',
            SP_City__c = 'Test City',
            SP_Country__c = 'Netherlands',
            SP_Postal_Code__c = '12345',
            Postal_Code__c = '12345',
            Region__c = 'EU - Europe',
            SP_Telephone__c = '+1234567890',
            SP_Fax__c = '+1234567890',
            SP_Email__c = 'test@test.com',
            SP_Funloc__c = '100000',            
            Company_Code__c = 'CN6A - NXP(Chongqing)Semi.Co.Ltd',
            Label_required__c = 'No',
            Industry_Segment__c = 'CC - Computing',
            Industry_Sub_Segment__c = 'C1 - Computing',
         //   Customer_Factory_Calendar__c = '01 - Customer calendar Germany standard',
            Customer_Service_ZA__c = 'CN010 - China',
            Incoterms_1__c = 'CPT - Carriage paid to',
            Incoterms_2__c = 'Test',
            Lockbox__c = 'NOREMIT',
            Payment_Credit_Memo__c= '014 - Prepaid',
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
            S_O_Sub_Group__c = 'NL - Netherlands',
            Sales_Office__c = 'CN6A - SOffice Chongqing'
            
           );
            
        insert objCMDRequest;        
        system.assert(objCMDRequest.Id != null);
        
        //start the test
        Test.startTest();
        
        PageReference pgRef = Page.TaxClassification;
        pgRef.getParameters().put('Id',objCMDRequest.Id);
        Test.setCurrentPageReference(pgRef);
        
        ApexPages.StandardSetController stdController = new Apexpages.StandardSetController(new List<Tax_Classification__c>());
        TaxClassificationCMDRequestController controller = new TaxClassificationCMDRequestController(stdController);
        
        System.assert(controller.lstTaxClassifications != null);
        System.assert(controller.lstTaxClassifications.size() > 0);
        
        //invoke saveTaxClassificationCMDRequest method
        pgRef = controller.saveTaxClassification();
        System.assert(pgRef != null);
        System.assertEquals(pgRef.getUrl(), '/' + controller.objCMDRequest.Id);
        
        //stop the test
        Test.stopTest();   
    
    }  
    static testMethod void CMDRequestSALES_ORG_CN69()
    {
        fetchRecordTypes();
        prepareConsolidatedAccountCode();
        createCustomer();
        
        CMD_Request__c objCMDRequest = new CMD_Request__c(
            Sales_Organisation__c = 'CN69 - SOrg. China',
            Reason_for_request__c = 'Test',
            Account_Group__c = 'Z001 - Sold To / Ship To / Bill To / Payer',
            RecordTypeId = SAP_New_MANU_Funloc_Request.Id,
            Consolidated_Account_Code__c = testCACC.Id,
            Ready_to_Submit__c = true,
            Request_Status__c = 'Ready to Submit',
            Business_Background_Comments__c = 'Test Business Background Comments',
            Global_Account__c = 'ABB - ABB',
            SP_GID__c = '100000000',            
            SP_Name__c = 'Test Name',
            SP_Street__c = 'Test Street',
            SP_City__c = 'Test City',
            SP_Country__c = 'Netherlands',
            SP_Postal_Code__c = '12345',
            Postal_Code__c = '12345',
            Region__c = 'EU - Europe',
            SP_Telephone__c = '+1234567890',
            SP_Fax__c = '+1234567890',
            SP_Email__c = 'test@test.com',
            SP_Funloc__c = '100000',            
            Company_Code__c = 'CN69 - NXP Qiangxin TJ Design',
            Label_required__c = 'No',
            Industry_Segment__c = 'CC - Computing',
            Industry_Sub_Segment__c = 'C1 - Computing',
         //   Customer_Factory_Calendar__c = '01 - Customer calendar Germany standard',
            Customer_Service_ZA__c = 'CN010 - China',
            Incoterms_1__c = 'CPT - Carriage paid to',
            Incoterms_2__c = 'Test',
            Lockbox__c = 'NOREMIT',
            Payment_Credit_Memo__c= '014 - Prepaid',
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
            S_O_Sub_Group__c = 'NL - Netherlands',
            Sales_Office__c = 'CN69 - SOffice China'
           
           );
            
        insert objCMDRequest;        
        system.assert(objCMDRequest.Id != null);
        
        //start the test
        Test.startTest();
        
        PageReference pgRef = Page.TaxClassification;
        pgRef.getParameters().put('Id',objCMDRequest.Id);
        Test.setCurrentPageReference(pgRef);
        
        ApexPages.StandardSetController stdController = new Apexpages.StandardSetController(new List<Tax_Classification__c>());
        TaxClassificationCMDRequestController controller = new TaxClassificationCMDRequestController(stdController);
        
        System.assert(controller.lstTaxClassifications != null);
        System.assert(controller.lstTaxClassifications.size() > 0);
        
        //invoke saveTaxClassificationCMDRequest method
        pgRef = controller.saveTaxClassification();
        System.assert(pgRef != null);
        System.assertEquals(pgRef.getUrl(), '/' + controller.objCMDRequest.Id);
        
        //stop the test
        Test.stopTest();   
    
    }  
    static testMethod void CMDRequestSALES_ORG_CZ61()
    {
        fetchRecordTypes();
        prepareConsolidatedAccountCode();
        createCustomer();
        
        CMD_Request__c objCMDRequest = new CMD_Request__c(
            Sales_Organisation__c = 'CZ61 - SOrg.Czech Republic',
            Reason_for_request__c = 'Test',
            Account_Group__c = 'Z001 - Sold To / Ship To / Bill To / Payer',
            RecordTypeId = SAP_New_MANU_Funloc_Request.Id,
            Consolidated_Account_Code__c = testCACC.Id,
            Ready_to_Submit__c = true,
            Request_Status__c = 'Ready to Submit',
            Business_Background_Comments__c = 'Test Business Background Comments',
            Global_Account__c = 'ABB - ABB',
            SP_GID__c = '100000000',            
            SP_Name__c = 'Test Name',
            SP_Street__c = 'Test Street',
            SP_City__c = 'Test City',
            SP_Country__c = 'Netherlands',
            SP_Postal_Code__c = '12345',
            Postal_Code__c = '12345',
            Region__c = 'EU - Europe',
            SP_Telephone__c = '+1234567890',
            SP_Fax__c = '+1234567890',
            SP_Email__c = 'test@test.com',
            SP_Funloc__c = '100000',            
            Company_Code__c = 'CZ61 - NXP Semiconductors Czech',
            Label_required__c = 'No',
            Industry_Segment__c = 'CC - Computing',
            Industry_Sub_Segment__c = 'C1 - Computing',
        //    Customer_Factory_Calendar__c = '01 - Customer calendar Germany standard',
            Customer_Service_ZA__c = 'CN010 - China',
            Incoterms_1__c = 'CPT - Carriage paid to',
            Incoterms_2__c = 'Test',
            Lockbox__c = 'NOREMIT',
            Payment_Credit_Memo__c= '014 - Prepaid',
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
            S_O_Sub_Group__c = 'NL - Netherlands',
            Sales_Office__c = 'CZ61 - SOffice Czech Rep'
           
           );
            
        insert objCMDRequest;        
        system.assert(objCMDRequest.Id != null);
        
        //start the test
        Test.startTest();
        
        PageReference pgRef = Page.TaxClassification;
        pgRef.getParameters().put('Id',objCMDRequest.Id);
        Test.setCurrentPageReference(pgRef);
        
        ApexPages.StandardSetController stdController = new Apexpages.StandardSetController(new List<Tax_Classification__c>());
        TaxClassificationCMDRequestController controller = new TaxClassificationCMDRequestController(stdController);
        
        System.assert(controller.lstTaxClassifications != null);
        System.assert(controller.lstTaxClassifications.size() > 0);
        
        //invoke saveTaxClassificationCMDRequest method
        pgRef = controller.saveTaxClassification();
        System.assert(pgRef != null);
        System.assertEquals(pgRef.getUrl(), '/' + controller.objCMDRequest.Id);
        
        //stop the test
        Test.stopTest();   
    
    }  
    static testMethod void CMDRequestSALES_ORG_GB63()
    {
        fetchRecordTypes();
        prepareConsolidatedAccountCode();
        createCustomer();
        
        CMD_Request__c objCMDRequest = new CMD_Request__c(
            Sales_Organisation__c = 'GB63 - NXP Laboratories UK',
            Reason_for_request__c = 'Test',
            Account_Group__c = 'Z001 - Sold To / Ship To / Bill To / Payer',
            RecordTypeId = SAP_New_MANU_Funloc_Request.Id,
            Consolidated_Account_Code__c = testCACC.Id,
            Ready_to_Submit__c = true,
            Request_Status__c = 'Ready to Submit',
            Business_Background_Comments__c = 'Test Business Background Comments',
            Global_Account__c = 'ABB - ABB',
            SP_GID__c = '100000000',            
            SP_Name__c = 'Test Name',
            SP_Street__c = 'Test Street',
            SP_City__c = 'Test City',
            SP_Country__c = 'Netherlands',
            SP_Postal_Code__c = '12345',
            Postal_Code__c = '12345',
            Region__c = 'EU - Europe',
            SP_Telephone__c = '+1234567890',
            SP_Fax__c = '+1234567890',
            SP_Email__c = 'test@test.com',
            SP_Funloc__c = '100000',            
            Company_Code__c = 'GB63 - NXP Laboratories UK Ltd',
            Label_required__c = 'No',
            Industry_Segment__c = 'CC - Computing',
            Industry_Sub_Segment__c = 'C1 - Computing',
            Customer_Factory_Calendar__c = '01 - Customer calendar Germany standard',
            Customer_Service_ZA__c = 'CN010 - China',
            Incoterms_1__c = 'CPT - Carriage paid to',
            Incoterms_2__c = 'Test',
            Lockbox__c = 'NOREMIT',
            Payment_Credit_Memo__c= '014 - Prepaid',
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
            S_O_Sub_Group__c = 'NL - Netherlands',
            Sales_Office__c = 'GB63 - NXP Laboratories UK'
           
           );
            
        insert objCMDRequest;        
        system.assert(objCMDRequest.Id != null);
        
        //start the test
        Test.startTest();
        
        PageReference pgRef = Page.TaxClassification;
        pgRef.getParameters().put('Id',objCMDRequest.Id);
        Test.setCurrentPageReference(pgRef);
        
        ApexPages.StandardSetController stdController = new Apexpages.StandardSetController(new List<Tax_Classification__c>());
        TaxClassificationCMDRequestController controller = new TaxClassificationCMDRequestController(stdController);
        
        System.assert(controller.lstTaxClassifications != null);
        System.assert(controller.lstTaxClassifications.size() > 0);
        
        //invoke saveTaxClassificationCMDRequest method
        pgRef = controller.saveTaxClassification();
        System.assert(pgRef != null);
        System.assertEquals(pgRef.getUrl(), '/' + controller.objCMDRequest.Id);
        
        //stop the test
        Test.stopTest();   
    
    }  
    static testMethod void CMDRequestSALES_ORG_HK63()
    {
        fetchRecordTypes();
        prepareConsolidatedAccountCode();
        createCustomer();
        
        CMD_Request__c objCMDRequest = new CMD_Request__c(
            Sales_Organisation__c = 'HK63 - NXP Semi Hong Kong',
            Reason_for_request__c = 'Test',
            Account_Group__c = 'Z001 - Sold To / Ship To / Bill To / Payer',
            RecordTypeId = SAP_New_MANU_Funloc_Request.Id,
            Consolidated_Account_Code__c = testCACC.Id,
            Ready_to_Submit__c = true,
            Request_Status__c = 'Ready to Submit',
            Business_Background_Comments__c = 'Test Business Background Comments',
            Global_Account__c = 'ABB - ABB',
            SP_GID__c = '100000000',            
            SP_Name__c = 'Test Name',
            SP_Street__c = 'Test Street',
            SP_City__c = 'Test City',
            SP_Country__c = 'Netherlands',
            SP_Postal_Code__c = '12345',
            Postal_Code__c = '12345',
            Region__c = 'EU - Europe',
            SP_Telephone__c = '+1234567890',
            SP_Fax__c = '+1234567890',
            SP_Email__c = 'test@test.com',
            SP_Funloc__c = '100000',            
            Company_Code__c = 'HK63 - NXP Semi Asia Hong Kong L',
            Label_required__c = 'No',
            Industry_Segment__c = 'CC - Computing',
            Industry_Sub_Segment__c = 'C1 - Computing',
            Customer_Factory_Calendar__c = '01 - Customer calendar Germany standard',
            Customer_Service_ZA__c = 'CN010 - China',
            Incoterms_1__c = 'CPT - Carriage paid to',
            Incoterms_2__c = 'Test',
            Lockbox__c = 'NOREMIT',
            Payment_Credit_Memo__c= '014 - Prepaid',
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
            S_O_Sub_Group__c = 'NL - Netherlands',
            Sales_Office__c = 'HK63 - NXP Semi Hong Kong'
           
           );
            
        insert objCMDRequest;        
        system.assert(objCMDRequest.Id != null);
        
        //start the test
        Test.startTest();
        
        PageReference pgRef = Page.TaxClassification;
        pgRef.getParameters().put('Id',objCMDRequest.Id);
        Test.setCurrentPageReference(pgRef);
        
        ApexPages.StandardSetController stdController = new Apexpages.StandardSetController(new List<Tax_Classification__c>());
        TaxClassificationCMDRequestController controller = new TaxClassificationCMDRequestController(stdController);
        
        System.assert(controller.lstTaxClassifications != null);
        System.assert(controller.lstTaxClassifications.size() > 0);
        
        //invoke saveTaxClassificationCMDRequest method
        pgRef = controller.saveTaxClassification();
        System.assert(pgRef != null);
        System.assertEquals(pgRef.getUrl(), '/' + controller.objCMDRequest.Id);
        
        //stop the test
        Test.stopTest();   
    
    }  
    static testMethod void CMDRequestSALES_ORG_IN62()
    {
        fetchRecordTypes();
        prepareConsolidatedAccountCode();
        createCustomer();
        
        CMD_Request__c objCMDRequest = new CMD_Request__c(
            Sales_Organisation__c = 'IN62 - SOrg. Noida',
            Reason_for_request__c = 'Test',
            Account_Group__c = 'Z001 - Sold To / Ship To / Bill To / Payer',
            RecordTypeId = SAP_New_MANU_Funloc_Request.Id,
            Consolidated_Account_Code__c = testCACC.Id,
            Ready_to_Submit__c = true,
            Request_Status__c = 'Ready to Submit',
            Business_Background_Comments__c = 'Test Business Background Comments',
            Global_Account__c = 'ABB - ABB',
            SP_GID__c = '100000000',            
            SP_Name__c = 'Test Name',
            SP_Street__c = 'Test Street',
            SP_City__c = 'Test City',
            SP_Country__c = 'Netherlands',
            SP_Postal_Code__c = '12345',
            Postal_Code__c = '12345',
            Region__c = 'EU - Europe',
            SP_Telephone__c = '+1234567890',
            SP_Fax__c = '+1234567890',
            SP_Email__c = 'test@test.com',
            SP_Funloc__c = '100000',            
            Company_Code__c = 'IN62 - NXP - Noida',
            Label_required__c = 'No',
            Industry_Segment__c = 'CC - Computing',
            Industry_Sub_Segment__c = 'C1 - Computing',
            Customer_Factory_Calendar__c = '01 - Customer calendar Germany standard',
            Customer_Service_ZA__c = 'CN010 - China',
            Incoterms_1__c = 'CPT - Carriage paid to',
            Incoterms_2__c = 'Test',
            Lockbox__c = 'NOREMIT',
            Payment_Credit_Memo__c= '014 - Prepaid',
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
            S_O_Sub_Group__c = 'NL - Netherlands',
            Sales_Office__c = 'IN62 - SOffice Noida'
           
           );
            
        insert objCMDRequest;        
        system.assert(objCMDRequest.Id != null);
        
        //start the test
        Test.startTest();
        
        PageReference pgRef = Page.TaxClassification;
        pgRef.getParameters().put('Id',objCMDRequest.Id);
        Test.setCurrentPageReference(pgRef);
        
        ApexPages.StandardSetController stdController = new Apexpages.StandardSetController(new List<Tax_Classification__c>());
        TaxClassificationCMDRequestController controller = new TaxClassificationCMDRequestController(stdController);
        
        System.assert(controller.lstTaxClassifications != null);
        System.assert(controller.lstTaxClassifications.size() > 0);
        
        //invoke saveTaxClassificationCMDRequest method
        pgRef = controller.saveTaxClassification();
        System.assert(pgRef != null);
        System.assertEquals(pgRef.getUrl(), '/' + controller.objCMDRequest.Id);
        
        //stop the test
        Test.stopTest();   
    
    }  
    static testMethod void CMDRequestSALES_ORG_IN63()
    {
        fetchRecordTypes();
        prepareConsolidatedAccountCode();
        createCustomer();
        
        CMD_Request__c objCMDRequest = new CMD_Request__c(
            Sales_Organisation__c = 'IN63 - SOrg. Hyderabad',
            Reason_for_request__c = 'Test',
            Account_Group__c = 'Z001 - Sold To / Ship To / Bill To / Payer',
            RecordTypeId = SAP_New_MANU_Funloc_Request.Id,
            Consolidated_Account_Code__c = testCACC.Id,
            Ready_to_Submit__c = true,
            Request_Status__c = 'Ready to Submit',
            Business_Background_Comments__c = 'Test Business Background Comments',
            Global_Account__c = 'ABB - ABB',
            SP_GID__c = '100000000',            
            SP_Name__c = 'Test Name',
            SP_Street__c = 'Test Street',
            SP_City__c = 'Test City',
            SP_Country__c = 'Netherlands',
            SP_Postal_Code__c = '12345',
            Postal_Code__c = '12345',
            Region__c = 'EU - Europe',
            SP_Telephone__c = '+1234567890',
            SP_Fax__c = '+1234567890',
            SP_Email__c = 'test@test.com',
            SP_Funloc__c = '100000',            
            Company_Code__c = 'IN63 - NXP - Hyderabad',
            Label_required__c = 'No',
            Industry_Segment__c = 'CC - Computing',
            Industry_Sub_Segment__c = 'C1 - Computing',
            Customer_Factory_Calendar__c = '01 - Customer calendar Germany standard',
            Customer_Service_ZA__c = 'CN010 - China',
            Incoterms_1__c = 'CPT - Carriage paid to',
            Incoterms_2__c = 'Test',
            Lockbox__c = 'NOREMIT',
            Payment_Credit_Memo__c= '014 - Prepaid',
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
            S_O_Sub_Group__c = 'NL - Netherlands',
            Sales_Office__c = 'IN63 - SOffice Hyderabad'
           
           );
            
        insert objCMDRequest;        
        system.assert(objCMDRequest.Id != null);
        
        //start the test
        Test.startTest();
        
        PageReference pgRef = Page.TaxClassification;
        pgRef.getParameters().put('Id',objCMDRequest.Id);
        Test.setCurrentPageReference(pgRef);
        
        ApexPages.StandardSetController stdController = new Apexpages.StandardSetController(new List<Tax_Classification__c>());
        TaxClassificationCMDRequestController controller = new TaxClassificationCMDRequestController(stdController);
        
        System.assert(controller.lstTaxClassifications != null);
        System.assert(controller.lstTaxClassifications.size() > 0);
        
        //invoke saveTaxClassificationCMDRequest method
        pgRef = controller.saveTaxClassification();
        System.assert(pgRef != null);
        System.assertEquals(pgRef.getUrl(), '/' + controller.objCMDRequest.Id);
        
        //stop the test
        Test.stopTest();   
    
    }  
    
    static testMethod void CMDRequestSALES_ORG_IN66()
    {
        fetchRecordTypes();
        prepareConsolidatedAccountCode();
        createCustomer();
        
        CMD_Request__c objCMDRequest = new CMD_Request__c(
            Sales_Organisation__c = 'IN66 - NXP India - Pune',
            Reason_for_request__c = 'Test',
            Account_Group__c = 'Z001 - Sold To / Ship To / Bill To / Payer',
            RecordTypeId = SAP_New_MANU_Funloc_Request.Id,
            Consolidated_Account_Code__c = testCACC.Id,
            Ready_to_Submit__c = true,
            Request_Status__c = 'Ready to Submit',
            Business_Background_Comments__c = 'Test Business Background Comments',
            Global_Account__c = 'ABB - ABB',
            SP_GID__c = '100000000',            
            SP_Name__c = 'Test Name',
            SP_Street__c = 'Test Street',
            SP_City__c = 'Test City',
            SP_Country__c = 'Netherlands',
            SP_Postal_Code__c = '12345',
            Postal_Code__c = '12345',
            Region__c = 'EU - Europe',
            SP_Telephone__c = '+1234567890',
            SP_Fax__c = '+1234567890',
            SP_Email__c = 'test@test.com',
            SP_Funloc__c = '100000',            
            Company_Code__c = 'IN66 - NXP India - Pune',
            Label_required__c = 'No',
            Industry_Segment__c = 'CC - Computing',
            Industry_Sub_Segment__c = 'C1 - Computing',
            Customer_Factory_Calendar__c = '01 - Customer calendar Germany standard',
            Customer_Service_ZA__c = 'CN010 - China',
            Incoterms_1__c = 'CPT - Carriage paid to',
            Incoterms_2__c = 'Test',
            Lockbox__c = 'NOREMIT',
            Payment_Credit_Memo__c= '014 - Prepaid',
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
            S_O_Sub_Group__c = 'NL - Netherlands',
            Sales_Office__c = 'IN66 - NXP India - Pune'
           
           );
            
        insert objCMDRequest;        
        system.assert(objCMDRequest.Id != null);
        
        //start the test
        Test.startTest();
        
        PageReference pgRef = Page.TaxClassification;
        pgRef.getParameters().put('Id',objCMDRequest.Id);
        Test.setCurrentPageReference(pgRef);
        
        ApexPages.StandardSetController stdController = new Apexpages.StandardSetController(new List<Tax_Classification__c>());
        TaxClassificationCMDRequestController controller = new TaxClassificationCMDRequestController(stdController);
        
        System.assert(controller.lstTaxClassifications != null);
        System.assert(controller.lstTaxClassifications.size() > 0);
        
        //invoke saveTaxClassificationCMDRequest method
        pgRef = controller.saveTaxClassification();
        System.assert(pgRef != null);
        System.assertEquals(pgRef.getUrl(), '/' + controller.objCMDRequest.Id);
        
        //stop the test
        Test.stopTest();   
    
    }  
    
    static testMethod void CMDRequestSALES_ORG_MY62()
    {
        fetchRecordTypes();
        prepareConsolidatedAccountCode();
        createCustomer();
        
        CMD_Request__c objCMDRequest = new CMD_Request__c(
            Sales_Organisation__c = 'MY62 - NXP Malaysia',
            Reason_for_request__c = 'Test',
            Account_Group__c = 'Z001 - Sold To / Ship To / Bill To / Payer',
            RecordTypeId = SAP_New_MANU_Funloc_Request.Id,
            Consolidated_Account_Code__c = testCACC.Id,
            Ready_to_Submit__c = true,
            Request_Status__c = 'Ready to Submit',
            Business_Background_Comments__c = 'Test Business Background Comments',
            Global_Account__c = 'ABB - ABB',
            SP_GID__c = '100000000',            
            SP_Name__c = 'Test Name',
            SP_Street__c = 'Test Street',
            SP_City__c = 'Test City',
            SP_Country__c = 'Netherlands',
            SP_Postal_Code__c = '12345',
            Postal_Code__c = '12345',
            Region__c = 'EU - Europe',
            SP_Telephone__c = '+1234567890',
            SP_Fax__c = '+1234567890',
            SP_Email__c = 'test@test.com',
            SP_Funloc__c = '100000',            
            Company_Code__c = 'MY62 - FSL Semi Malaysia Sdn Bhd',
            Label_required__c = 'No',
            Industry_Segment__c = 'CC - Computing',
            Industry_Sub_Segment__c = 'C1 - Computing',
            Customer_Factory_Calendar__c = '01 - Customer calendar Germany standard',
            Customer_Service_ZA__c = 'CN010 - China',
            Incoterms_1__c = 'CPT - Carriage paid to',
            Incoterms_2__c = 'Test',
            Lockbox__c = 'NOREMIT',
            Payment_Credit_Memo__c= '014 - Prepaid',
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
            S_O_Sub_Group__c = 'NL - Netherlands',
            Sales_Office__c = 'MY62 - NXP Malaysia'
           
           );
            
        insert objCMDRequest;        
        system.assert(objCMDRequest.Id != null);
        
        //start the test
        Test.startTest();
        
        PageReference pgRef = Page.TaxClassification;
        pgRef.getParameters().put('Id',objCMDRequest.Id);
        Test.setCurrentPageReference(pgRef);
        
        ApexPages.StandardSetController stdController = new Apexpages.StandardSetController(new List<Tax_Classification__c>());
        TaxClassificationCMDRequestController controller = new TaxClassificationCMDRequestController(stdController);
        
        System.assert(controller.lstTaxClassifications != null);
        System.assert(controller.lstTaxClassifications.size() > 0);
        
        //invoke saveTaxClassificationCMDRequest method
        pgRef = controller.saveTaxClassification();
        System.assert(pgRef != null);
        System.assertEquals(pgRef.getUrl(), '/' + controller.objCMDRequest.Id);
        
        //stop the test
        Test.stopTest();   
    
    }  
    static testMethod void CMDRequestSALES_ORG_JP61()
    {
        fetchRecordTypes();
        prepareConsolidatedAccountCode();
        createCustomer();
        
        CMD_Request__c objCMDRequest = new CMD_Request__c(
            Sales_Organisation__c = 'JP61 - SOrg. Japan',
            Reason_for_request__c = 'Test',
            Account_Group__c = 'Z001 - Sold To / Ship To / Bill To / Payer',
            RecordTypeId = SAP_New_MANU_Funloc_Request.Id,
            Consolidated_Account_Code__c = testCACC.Id,
            Ready_to_Submit__c = true,
            Request_Status__c = 'Ready to Submit',
            Business_Background_Comments__c = 'Test Business Background Comments',
            Global_Account__c = 'ABB - ABB',
            SP_GID__c = '100000000',            
            SP_Name__c = 'Test Name',
            SP_Street__c = 'Test Street',
            SP_City__c = 'Test City',
            SP_Country__c = 'Netherlands',
            SP_Postal_Code__c = '12345',
            Postal_Code__c = '12345',
            Region__c = 'EU - Europe',
            SP_Telephone__c = '+1234567890',
            SP_Fax__c = '+1234567890',
            SP_Email__c = 'test@test.com',
            SP_Funloc__c = '100000',            
            Company_Code__c = 'JP60 - MSO Japan',
            Label_required__c = 'No',
            Industry_Segment__c = 'CC - Computing',
            Industry_Sub_Segment__c = 'C1 - Computing',
            Customer_Factory_Calendar__c = '01 - Customer calendar Germany standard',
            Customer_Service_ZA__c = 'CN010 - China',
            Incoterms_1__c = 'CPT - Carriage paid to',
            Incoterms_2__c = 'Test',
            Lockbox__c = 'NOREMIT',
            Payment_Credit_Memo__c= '014 - Prepaid',
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
            S_O_Sub_Group__c = 'NL - Netherlands',
            Sales_Office__c = 'JP61 - SOffice Japan'
            
           );
            
        insert objCMDRequest;        
        system.assert(objCMDRequest.Id != null);
        
        //start the test
        Test.startTest();
        
        PageReference pgRef = Page.TaxClassification;
        pgRef.getParameters().put('Id',objCMDRequest.Id);
        Test.setCurrentPageReference(pgRef);
        
        ApexPages.StandardSetController stdController = new Apexpages.StandardSetController(new List<Tax_Classification__c>());
        TaxClassificationCMDRequestController controller = new TaxClassificationCMDRequestController(stdController);
        
        System.assert(controller.lstTaxClassifications != null);
        System.assert(controller.lstTaxClassifications.size() > 0);
        
        //invoke saveTaxClassificationCMDRequest method
        pgRef = controller.saveTaxClassification();
        System.assert(pgRef != null);
        System.assertEquals(pgRef.getUrl(), '/' + controller.objCMDRequest.Id);
        
        //stop the test
        Test.stopTest();   
    
    }  
    static testMethod void CMDRequestSALES_ORG_SG60()
    {
        fetchRecordTypes();
        prepareConsolidatedAccountCode();
        createCustomer();
        
        CMD_Request__c objCMDRequest = new CMD_Request__c(
            Sales_Organisation__c = 'SG60 - MSO Singapore',
            Reason_for_request__c = 'Test',
            Account_Group__c = 'Z001 - Sold To / Ship To / Bill To / Payer',
            RecordTypeId = SAP_New_MANU_Funloc_Request.Id,
            Consolidated_Account_Code__c = testCACC.Id,
            Ready_to_Submit__c = true,
            Request_Status__c = 'Ready to Submit',
            Business_Background_Comments__c = 'Test Business Background Comments',
            Global_Account__c = 'ABB - ABB',
            SP_GID__c = '100000000',            
            SP_Name__c = 'Test Name',
            SP_Street__c = 'Test Street',
            SP_City__c = 'Test City',
            SP_Country__c = 'Netherlands',
            SP_Postal_Code__c = '12345',
            Postal_Code__c = '12345',
            Region__c = 'EU - Europe',
            SP_Telephone__c = '+1234567890',
            SP_Fax__c = '+1234567890',
            SP_Email__c = 'test@test.com',
            SP_Funloc__c = '100000',            
            Company_Code__c = 'SG60 - MSO Singapore',
            Label_required__c = 'No',
            Industry_Segment__c = 'CC - Computing',
            Industry_Sub_Segment__c = 'C1 - Computing',
            Customer_Factory_Calendar__c = '01 - Customer calendar Germany standard',
            Customer_Service_ZA__c = 'CN010 - China',
            Incoterms_1__c = 'CPT - Carriage paid to',
            Incoterms_2__c = 'Test',
            Lockbox__c = 'NOREMIT',
            Payment_Credit_Memo__c= '014 - Prepaid',
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
            S_O_Sub_Group__c = 'NL - Netherlands',
            Sales_Office__c = 'SG60 - MSO SINGAPORE'
           
           );
            
        insert objCMDRequest;        
        system.assert(objCMDRequest.Id != null);
        
        //start the test
        Test.startTest();
        
        PageReference pgRef = Page.TaxClassification;
        pgRef.getParameters().put('Id',objCMDRequest.Id);
        Test.setCurrentPageReference(pgRef);
        
        ApexPages.StandardSetController stdController = new Apexpages.StandardSetController(new List<Tax_Classification__c>());
        TaxClassificationCMDRequestController controller = new TaxClassificationCMDRequestController(stdController);
        
        System.assert(controller.lstTaxClassifications != null);
        System.assert(controller.lstTaxClassifications.size() > 0);
        
        //invoke saveTaxClassificationCMDRequest method
        pgRef = controller.saveTaxClassification();
        System.assert(pgRef != null);
        System.assertEquals(pgRef.getUrl(), '/' + controller.objCMDRequest.Id);
        
        //stop the test
        Test.stopTest();   
    
    }  
    
    static testMethod void CMDRequestSALES_ORG_SG60Delete()
    {
        fetchRecordTypes();
        prepareConsolidatedAccountCode();
        createCustomer();
        
        CMD_Request__c objCMDRequest = new CMD_Request__c(
            Sales_Organisation__c = 'SG60 - MSO Singapore',
            Reason_for_request__c = 'Test',
            Account_Group__c = 'Z001 - Sold To / Ship To / Bill To / Payer',
            RecordTypeId = SAP_New_MANU_Funloc_Request.Id,
            Consolidated_Account_Code__c = testCACC.Id,
            Ready_to_Submit__c = true,
            Request_Status__c = 'Ready to Submit',
            Business_Background_Comments__c = 'Test Business Background Comments',
            Global_Account__c = 'ABB - ABB',
            SP_GID__c = '100000000',            
            SP_Name__c = 'Test Name',
            SP_Street__c = 'Test Street',
            SP_City__c = 'Test City',
            SP_Country__c = 'Netherlands',
            SP_Postal_Code__c = '12345',
            Postal_Code__c = '12345',
            Region__c = 'EU - Europe',
            SP_Telephone__c = '+1234567890',
            SP_Fax__c = '+1234567890',
            SP_Email__c = 'test@test.com',
            SP_Funloc__c = '100000',            
            Company_Code__c = 'SG60 - MSO Singapore',
            Label_required__c = 'No',
            Industry_Segment__c = 'CC - Computing',
            Industry_Sub_Segment__c = 'C1 - Computing',
            Customer_Factory_Calendar__c = '01 - Customer calendar Germany standard',
            Customer_Service_ZA__c = 'CN010 - China',
            Incoterms_1__c = 'CPT - Carriage paid to',
            Incoterms_2__c = 'Test',
            Lockbox__c = 'NOREMIT',
            Payment_Credit_Memo__c= '014 - Prepaid',
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
            S_O_Sub_Group__c = 'NL - Netherlands',
            Sales_Office__c = 'SG60 - MSO SINGAPORE'
           
           );
            
        insert objCMDRequest;        
        system.assert(objCMDRequest.Id != null);
        
        //start the test
        Test.startTest();
        
        PageReference pgRef = Page.TaxClassification;
        pgRef.getParameters().put('Id',objCMDRequest.Id);
        Test.setCurrentPageReference(pgRef);
        
        ApexPages.StandardSetController stdController = new Apexpages.StandardSetController(new List<Tax_Classification__c>());
        TaxClassificationCMDRequestController controller = new TaxClassificationCMDRequestController(stdController);
        
        System.assert(controller.lstTaxClassifications != null);
        System.assert(controller.lstTaxClassifications.size() > 0);
        
        //invoke saveTaxClassificationCMDRequest method
        pgRef = controller.saveTaxClassification();
        System.assert(pgRef != null);
        System.assertEquals(pgRef.getUrl(), '/' + controller.objCMDRequest.Id);
        
        list<Tax_classification__c> lstTaxes = [select id from Tax_classification__c where CMD_Request__c=:objCMDRequest.id];
        delete lstTaxes;
        
        //stop the test
        Test.stopTest();   
    
    }  
}