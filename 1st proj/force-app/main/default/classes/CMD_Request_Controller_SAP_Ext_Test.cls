/******************************************************************************
@Created By :       Scarlett Kang
@Created Date:      19 Aug 2015
@Description:       Test data revision for new validation rule
-------------------------------------------------------------------------------
@Modified By :       Scarlett Kang
@Modified Date:      01 April 2016
@Description:        1604 Release - SIR 706. SAP CMD - allow ZORG funloc to flow from SFDC to SAP
-------------------------------------------------------------------------------
@Modified By :       Shridevi   
@Modified Date:      April 21, 2016 
@Description:        1605 Release (SIR 534) - For testing the copied the value of the field  No_of_days_for_Early_Shipment__c from cmd Request to SAP cmd for Z001,Z002,Z012 Account groups.
-------------------------------------------------------------------------------
@Modified By :       Baji
@Modified Date:      Aug 31, 2016 
@Description:        1609 Release SIR 1102 & 990 - commented/uncommented the code to change CMD Request's field data-type.
---------------------------------------------------------------------------------
@Modified By :       Baji
@Modified Date:      Mar 14, 2017 
@Description:        To fix test class error : GSM Controller Approver Group is mandatory
---------------------------------------------------------------------------------
@Modified By :       Baji
@Modified Date:      Apr 17, 2017 
@Description:        To test SFDC-428 functionality(To link multiple ZORG SAP CMDs to CMD Request) and improve overall code coverage 
----------------------------------------------------------------------------------------------------------------------
@Modified By :       Baji
@Modified Date:      Apr 26, 2017
@Description:        To test 1705 Release (SFDC 467) -  To generate ZORG SAP CMDs based on rule provided.
---------------------------------------------------------------------------------
@Modified By :       Nisha Agrawal
@Modified Date:      Apr 26, 2017 
@Description:        SFDC-430 - Replace GSM COntroller Approver Group picklist to new multiselect picklist Controller Approver Group
---------------------------------------------------------------------------------
@Modified By :       Nisha Agrawal
@Modified Date:      Jun 01, 2017 
@Description:        SFDC-477 - Make Controller Approver required in case of new funloc request
----------------------------------------------------------------------------------------------------------------------
@Modified By :       Baji
@Modified Date:      21 Jun 2017
@Description:        1707 Release (SFDC 585) -  To test new fields 'Version ID for internationla addresses' & 'Tax Number 5' for MSO China project
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
@Modified By :       Baji
@Modified Date:      17 Jul 2017 
@Description:        1708 Release (SFDC 684) - SAP CMD - BillCurrency-PY should be on SAP CMD layout
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
@Modified By :       Baji
@Modified Date:      27 Feb 2019
@Description:        1904 Release (SFDC-2547) - To test "Generate additional set of ZORG Funloc SAP CMDs for Sales org CN60"
******************************************************************************/
@isTest
private class CMD_Request_Controller_SAP_Ext_Test {
    
    private static RecordType newSAPrt;
    private static Id newMANUSAPrt;
    private static String newSAPrtId = '012D0000000QlBaIAK';
//    private static String newSAPrtId = '012M00000004ejsIAA';
    
    private static CMD_Request__c testRequest;

    private static Customer__c testCustomer;
    
    private static Consolidated_Account_Code__c testCACC;
    
    private static Tax_Classification__c testTaxClassification;
    private static String funlocId;
    private static String funlocId1;
    
    private static void fetchRecordTypes(){
        for(RecordType rt : [   
            Select Id, DeveloperName
            From RecordType
            WHERE SobjectType = 'CMD_Request__c' 
            AND DeveloperName LIKE '%SAP%' 
            AND IsActive=true
        ]){
            if( rt.DeveloperName == 'SAP New Funloc Request' ) {
                newSAPrt = rt;
//              newSAPrtId = String.valueOf(rt.Id);            
                newSAPrtId = rt.Id;            
            }
           if( rt.DeveloperName == 'SAP_New_MANU_Funloc_request' ) {
                newMANUSAPrt = rt.id;
             }
    }
  }
    private static List<Sales_Organisation_ZORG__c> lstCustomSalesOrgSetting;
    private static void createSalesOrgCustomSetting(){
    lstCustomSalesOrgSetting = new List<Sales_Organisation_ZORG__c>();
    
    lstCustomSalesOrgSetting.add(new Sales_Organisation_ZORG__c(Name = 'CN6B - NXP Tianjin',Legal_Name_Name_1__c='NXP Semiconductors (Shanghai)',Name_2__c='Co.Ltd.',Name_3__c='Room 318',Name_4__c='3rd Floor of Auxiliary Area',Street_1__c='A5 Warehouse No.530 Zheng Ding Rd',City__c='SHANGHAI',Country__c='China',Zip__c='201207' ));
    lstCustomSalesOrgSetting.add(new Sales_Organisation_ZORG__c(Name = 'TH61 - NXP Thailand',Legal_Name_Name_1__c='NXP Semiconductors (Shanghai)',Name_2__c='Co.Ltd.',Name_3__c='Room 318',Name_4__c='3rd Floor of Auxiliary Area',Street_1__c='A5 Warehouse No.530 Zheng Ding Rd',City__c='SHANGHAI',Country__c='China',Zip__c='201207'));
    lstCustomSalesOrgSetting.add(new Sales_Organisation_ZORG__c(Name = 'TW61 - NXP Kaohsiung',Legal_Name_Name_1__c='NXP Semiconductors (Shanghai)',Name_2__c='Co.Ltd.',Name_3__c='Room 318',Name_4__c='3rd Floor of Auxiliary Area',Street_1__c='A5 Warehouse No.530 Zheng Ding Rd',City__c='SHANGHAI',Country__c='China',Zip__c='201207'));
    lstCustomSalesOrgSetting.add(new Sales_Organisation_ZORG__c(Name = 'US63 - NXP Austin',Legal_Name_Name_1__c='NXP Semiconductors (Shanghai)',Name_2__c='Co.Ltd.',Name_3__c='Room 318',Name_4__c='3rd Floor of Auxiliary Area',Street_1__c='A5 Warehouse No.530 Zheng Ding Rd',City__c='SHANGHAI',Country__c='China',Zip__c='201207'));
        
    insert lstCustomSalesOrgSetting;
  }

    private static void prepareTestCustomer(){
        testCustomer = new Customer__c(
            DNB_Verified__c = 'DNB Accepted',
            Legal_Name__c = 'Test Legal Name',
            Account_Name__c = 'Test Account Name',
            Street__c = 'Test Street',
            City__c = 'Test City',
            Country__c = 'Netherlands',
            Zip__c = 'Test',
            Industry_Segment__c = 'CC - Computing' ,
            Industry_Sub_Segment__c = 'C1 - Computing',
            Role__c = 'OEM'
        );
        insert testCustomer;
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
    
    private static void insertFunloc(){
        Funloc__c objFunloc = new Funloc__c(
            Name__c = 'Test Convert',
            Call_Name__c = 'Test Convert',
            Street_Name__c = 'Test Convert',
            Place_Name__c = 'Test Convert',
            Country_Name__c = 'Test Convert'
        );
        insert objFunLoc;  
        List<FunLoc__c> fl = [select id from FunLoc__c where Name__c='Test Convert'];
        if(fl.size() >0){
            funlocId = fl.get(0).id;
        }
    }
    private static void insertFunloc1(){
        Funloc__c objFunloc1 = new Funloc__c(
            Name__c = 'Test Convert1',
            Call_Name__c = 'Test Convert1',
            Street_Name__c = 'Test Convert1',
            Place_Name__c = 'Test Convert1',
            Country_Name__c = 'Test Convert1'
        );
        insert objFunLoc1;  
        List<FunLoc__c> f2 = [select id from FunLoc__c where Name__c='Test Convert1'];
        if(f2.size() >0){
            funlocId1 = f2.get(0).id;
        }
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
        lstUsers.add(testuser);
        
        User testUser1 = new User();
        testUser1.firstName = 'Test2261FirstName4';
        testUser1.LastName = 'Test453LastName4';
        testUser1.Alias = 'Ts4t2';
        testUser1.Email = 'tes2660@testorg.com';
        testUser1.UserName= 'test2660@testorg.com' ;
        testUser1.ProfileId = ProfileId;
        testUser1.CommunityNickname = testUser1.firstname+'_'+testUser1.lastName;
        testUser1.EmailEncodingKey ='ISO-8859-1';
        testUser1.LanguageLocaleKey = 'en_US';
        testUser1.TimeZoneSidKey ='America/Los_Angeles';
        testUser1.LocaleSidKey = 'en_US';
        testUser1.Country = 'USA';
        testUser1.ForecastEnabled = true;
        lstUsers.add(testuser1);
        
        insert lstUsers;
      }
    
    //@isTest(SeeAllData=true) 
    //static void theZ001Test(){
    static testmethod void theZ001Test(){
        fetchRecordTypes();
        prepareTestCustomer();
        prepareConsolidatedAccountCode();
        insertFunloc();
        createTestUser();
        List<Customer__c> lstCustomer = [SELECT Id, Name FROM Customer__c];
        user testuser = [select id,name from user where email='tes26t2@testorg.com']; 
        system.assert(lstCustomer.size() > 0);
       // system.runas(testuser){
        Test.startTest();
        system.debug('testusercheck' + testuser);
        testRequest = new CMD_Request__c(
            Account_Group__c = 'Z002 - Ship To',
            RecordTypeId = newSAPrtId,
            Ready_to_Submit__c = true,
            Request_Status__c = 'Draft',
            Business_Background_Comments__c = 'Test Business Background Comments',
            Global_Account__c = 'ACI - ACiG',
            Sales_Organisation__c = 'CN62 - MSO China',
/*STAN needs to enhance*/           //Consolidated_Account_Code__c = 'a1rD0000007BKFfIAO', 
/*Modified by Scarlett*/            Consolidated_Account_Code__c = testCACC.Id,
            //SP_GID__c = testCustomer.Name,
            SP_GID__c = string.valueof(lstCustomer[0].Name),
//Scarlett
//            SP_CustomerID__c = testCustomer.Id,
//            SP_GID__c = '100000000',
//            SP_CustomerID__c = 'a1ND0000001vB7GMAU',
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
            SP_Funloc_Id__c = funLocId,
            Company_Code__c = 'CN62 - MSO China',
            Label_required__c = 'No',
            Industry_Segment__c = 'CC - Computing',
            Industry_Sub_Segment__c = 'C1 - Computing',
            Customer_Factory_Calendar__c = '11 - Ship to Algeria',
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
            Sales_Office__c = 'BOS1 - Bosch',
            S_O_Sub_Group__c = 'CN - China',
            Reconciliation_Account__c = '1200100 - Trade AR with foreign parties',
            No_of_days_for_Early_Shipment__c=50,
            Order_combination__c='Yes',
            Central_deletion_block__c= 'Yes',
            Central_deletion_Flag__c = 'Yes',
            Central_posting_block__c = 'Yes',
            Deletion_Flag_Sales_Area__c = 'Yes',
            Screened_for_SDI__c = 'Yes',
            Deletion_Block_Company_Code__c = 'Yes',
            Deletion_Flag_Company_Code__c = 'Yes',
            Indicator_Record_Payment_History__c = 'Yes',
            Posting_Block_Company_Code__c = 'Yes',
            BillCurrency_PY__c = 'CNY - Chinese Renmimbi',
            Sales_Rep_ZS__c = 'US727 - AARON HOUT',
           // Controller_Approver_Group__c = 'AP - South Asia-Pacific', //Line added by Nisha Agrawal for SFDC-477
            Version_ID_for_International_Addresses__c = 'C',
            Tax_Number_5__c = 'Test Tax Number 5'
        );
        insert testRequest;
        
        cmd_request__c objCMD = [select id,name,request_status__c from cmd_request__c where id=:testrequest.id];
        objCMD.request_status__c = 'Pending for Approval';
        update objCMD;
        
     // }
       user testuseradmin = [select id,name from user where email='tes2660@testorg.com']; 
       system.runas(testuseradmin){ 
       system.debug('testuseradmincheck' + testuseradmin);
       cmd_request__c objCMDReq = [select id,name,request_status__c from cmd_request__c where id=:testrequest.id];
        testTaxClassification = new Tax_Classification__c(
            CMD_Request__c = objCMDReq.Id,
            Country__c = 'AT - Austria', 
            Tax_Category__c = 'MWST', 
            Tax_Classification__c = '1'
        );
        insert testTaxClassification;
      }
        ApexPages.StandardController theStandardController 
            = new ApexPages.standardController(testRequest);
        CMD_Request_Controller_SAP_Extension theControllerExt 
            = new CMD_Request_Controller_SAP_Extension( theStandardController );
        theControllerExt.theAccountGroup = 'Z001';
//        theControllerExt.theCMD.HUB_Customer__c = 'a1ND0000001vB7GMAU'; 
//        theControllerExt.theCMD.HUB_Customer__c = testCustomer.Id;
        theControllerExt.New_SAP_CMD(); 
      //  System.debug('theControllerExt::'+theControllerExt);
       //  System.debug('theControllerExt.theRequest----'+ theControllerExt.theRequest);  
       //   System.debug('theControllerExt.thecmd----'+ theControllerExt.thecmd); 
        //  System.debug('theControllerExt.thecmd.No_of_days_for_Early_Shipment__c----'+theControllerExt.thecmd.No_of_days_for_Early_Shipment__c); 
        /*********************************************** modified for SIR534**********************************************************************/
        system.assertEquals(theControllerExt.thecmd.No_of_days_for_Early_Shipment__c,theControllerExt.theRequest.No_of_days_for_Early_Shipment__c);
        /*********************************************** modified for SIR534**********************************************************************/
       Test.stopTest();
    }  
    
    static testmethod void theZ001Test2(){
        fetchRecordTypes();
        prepareTestCustomer();
        prepareConsolidatedAccountCode();
        insertFunloc();
        createTestUser();
        List<Customer__c> lstCustomer = [SELECT Id, Name FROM Customer__c];
        system.assert(lstCustomer.size() > 0);
        Test.startTest();
        testRequest = new CMD_Request__c(
            Account_Group__c = 'Z002 - Ship To',
            RecordTypeId = newSAPrtId,
            Ready_to_Submit__c = true,
            Request_Status__c = 'Draft',
            Business_Background_Comments__c = 'Test Business Background Comments',
            Global_Account__c = 'ACI - ACiG',
            Sales_Organisation__c = 'CN62 - MSO China',
            Consolidated_Account_Code__c = testCACC.Id,
            SP_GID__c = string.valueof(lstCustomer[0].Name),
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
            SP_Funloc_Id__c = funLocId,
            Company_Code__c = 'CN62 - MSO China',
            Label_required__c = 'No',
            Industry_Segment__c = 'CC - Computing',
            Industry_Sub_Segment__c = 'C1 - Computing',
            Customer_Factory_Calendar__c = '11 - Ship to Algeria',
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
            Sales_Office__c = 'BOS1 - Bosch',
            S_O_Sub_Group__c = 'CN - China',
            Reconciliation_Account__c = '1200100 - Trade AR with foreign parties',
            No_of_days_for_Early_Shipment__c=50,
            Order_combination__c='Yes',
            Central_deletion_block__c= 'Yes',
            Central_deletion_Flag__c = 'Yes',
            Central_posting_block__c = 'Yes',
            Deletion_Flag_Sales_Area__c = 'Yes',
            Screened_for_SDI__c = 'Yes',
            Deletion_Block_Company_Code__c = 'Yes',
            Deletion_Flag_Company_Code__c = 'Yes',
            Indicator_Record_Payment_History__c = 'Yes',
            Posting_Block_Company_Code__c = 'Yes',
            BillCurrency_PY__c = 'CNY - Chinese Renmimbi',
            Sales_Rep_ZS__c = 'US727 - AARON HOUT',
           // Controller_Approver_Group__c = 'AP - South Asia-Pacific', //Line added by Nisha Agrawal for SFDC-477
            Version_ID_for_International_Addresses__c = 'C',
            Tax_Number_5__c = 'Test Tax Number 5'
        );
       insert testRequest;
       
       cmd_request__c objCMD = [select id,name,request_status__c from cmd_request__c where id=:testrequest.id];
       objCMD.request_status__c = 'Pending for Approval';
       update objCMD;
        
       user testuser = [select id,name from user where email='tes26t2@testorg.com']; 
       system.runas(testuser){ 
       cmd_request__c objCMDReq = [select id,name,request_status__c from cmd_request__c where id=:testrequest.id];
        testTaxClassification = new Tax_Classification__c(
            CMD_Request__c = objCMDReq.Id,
            Country__c = 'ES - Spain', 
            Tax_Category__c = 'MWST', 
            Tax_Classification__c = '1'
        );
        insert testTaxClassification;
      }
        ApexPages.StandardController theStandardController 
            = new ApexPages.standardController(testRequest);
        CMD_Request_Controller_SAP_Extension theControllerExt 
            = new CMD_Request_Controller_SAP_Extension( theStandardController );
        theControllerExt.theAccountGroup = 'Z001';
        theControllerExt.New_SAP_CMD(); 
     
        /*********************************************** modified for SIR534**********************************************************************/
        system.assertEquals(theControllerExt.thecmd.No_of_days_for_Early_Shipment__c,theControllerExt.theRequest.No_of_days_for_Early_Shipment__c);
        /*********************************************** modified for SIR534**********************************************************************/
       Test.stopTest();
    }  

    //@isTest(SeeAllData=true) 
    @isTest
    static void theZ002Test(){
        fetchRecordTypes();
        prepareTestCustomer();
        prepareConsolidatedAccountCode();
        insertFunloc();
        Test.startTest();
        testRequest = new CMD_Request__c(
            Account_Group__c = 'Z002 - Ship To',
            RecordTypeId = newSAPrtId,
            Ready_to_Submit__c = true,
            Request_Status__c = 'Ready to Submit',
            Business_Background_Comments__c = 'Test Business Background Comments',
            Global_Account__c = 'ACI - ACiG',
            Sales_Organisation__c = 'CN62 - MSO China',
/*STAN needs to enhance*/          // Consolidated_Account_Code__c = 'a1rD0000007BKFfIAO', 
/*Modified by Scarlett*/            Consolidated_Account_Code__c = testCACC.Id,
//            SP_GID__c = testCustomer.Name,
//            SP_CustomerID__c = testCustomer.Id,
//Scarlett
            SP_CustomerID__c = testCustomer.Id,
            SP_GID__c = '100000000',
            SH_Name__c = 'Test Name',
            SH_Street__c = 'Test Street',
            SH_City__c = 'Test City',
            SH_Country__c = 'Netherlands',
            SH_Postal_Code__c = '12345',
            SH_Region__c = 'EU - EMEA',
           // Region__c = 'EU - Europe',
            SP_Telephone__c = '+1234567890',
            SP_Fax__c = '+1234567890',
            SP_Email__c = 'test@test.com',
            SP_Funloc__c = '100000',
            SP_Funloc_Id__c = funLocId,
            Company_Code__c = 'CN62 - MSO China',
            Label_required__c = 'No',
            Industry_Segment__c = 'CC - Computing',
            Industry_Sub_Segment__c = 'C1 - Computing',
            Customer_Factory_Calendar__c = '11 - Ship to Algeria',
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
            Sales_Office__c = 'BOS1 - Bosch',
            S_O_Sub_Group__c = 'CN - China',
            Reconciliation_Account__c = '1200100 - Trade AR with foreign parties',
            No_of_days_for_Early_Shipment__c=50,
            Order_combination__c='Yes',
            Central_deletion_block__c= 'Yes',
            Central_deletion_Flag__c = 'Yes',
            Central_posting_block__c = 'Yes',
            Deletion_Flag_Sales_Area__c = 'Yes',
            Screened_for_SDI__c = 'Yes',
            Deletion_Block_Company_Code__c = 'Yes',
            Deletion_Flag_Company_Code__c = 'Yes',
            Indicator_Record_Payment_History__c = 'Yes',
            Posting_Block_Company_Code__c = 'Yes',
            BillCurrency_PY__c = 'CNY - Chinese Renmimbi',
            Sales_Rep_ZS__c = 'US727 - AARON HOUT',
           // Controller_Approver_Group__c = 'AP - South Asia-Pacific', //Line added by Nisha Agrawal for SFDC-477
            Version_ID_for_International_Addresses__c = 'C'
           // Tax_Number_5__c = 'Test Tax Number 5'
        );
        insert testRequest;

        ApexPages.StandardController theStandardController 
            = new ApexPages.standardController(testRequest);
        CMD_Request_Controller_SAP_Extension theControllerExt 
            = new CMD_Request_Controller_SAP_Extension( theStandardController );
        theControllerExt.theAccountGroup = 'Z002';
//        theControllerExt.theCMD.HUB_Customer__c = 'a1ND0000001vB7GMAU';    
        theControllerExt.New_SAP_CMD();      
          /*********************************************** modified for SIR534**********************************************************************/
        system.assertEquals(theControllerExt.thecmd.No_of_days_for_Early_Shipment__c,theControllerExt.theRequest.No_of_days_for_Early_Shipment__c);
        /*********************************************** modified for SIR534**********************************************************************/
        Test.stopTest();
    }  
    
    static testmethod void theZ001MANUReq(){
        fetchRecordTypes();
        prepareTestCustomer();
        prepareConsolidatedAccountCode();
        insertFunloc();
        List<Customer__c> lstCustomer = [SELECT Id, Name FROM Customer__c];
        system.assert(lstCustomer.size() > 0);
        Test.startTest();
        testRequest = new CMD_Request__c(
            Account_Group__c = 'Z002 - Ship To',
            RecordTypeId = newMANUSAPrt,
            Ready_to_Submit__c = true,
            Request_Status__c = 'Ready to Submit',
            Business_Background_Comments__c = 'Test Business Background Comments',
            Global_Account__c = 'ACI - ACiG',
            Sales_Organisation__c = 'IN61 - NXP India',
/*STAN needs to enhance*/           //Consolidated_Account_Code__c = 'a1rD0000007BKFfIAO', 
/*Modified by Scarlett*/            Consolidated_Account_Code__c = testCACC.Id,
            //SP_GID__c = testCustomer.Name,
            SP_GID__c = string.valueof(lstCustomer[0].Name),
//Scarlett
//            SP_CustomerID__c = testCustomer.Id,
//            SP_GID__c = '100000000',
//            SP_CustomerID__c = 'a1ND0000001vB7GMAU',
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
            SP_Funloc_Id__c = funLocId,
            Company_Code__c = 'IN61 - NXP India Private Limited',
            Label_required__c = 'No',
            Industry_Segment__c = 'CC - Computing',
            Industry_Sub_Segment__c = 'C1 - Computing',
            Customer_Factory_Calendar__c = '01 - Customer calendar Germany standard',
           Customer_Service_ZA__c = 'JP000 - NXP Japan',
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
            Sales_Office__c = 'IN61 - NXP India',
            S_O_Sub_Group__c = 'CN - China',
            Reconciliation_Account__c = '1200100 - Trade AR with foreign parties',
            No_of_days_for_Early_Shipment__c=50,
            Order_combination__c='Yes',
            Central_deletion_block__c= 'Yes',
            Central_deletion_Flag__c = 'Yes',
            Central_posting_block__c = 'Yes',
            Deletion_Flag_Sales_Area__c = 'Yes',
            Screened_for_SDI__c = 'Yes',
            Deletion_Block_Company_Code__c = 'Yes',
            Deletion_Flag_Company_Code__c = 'Yes',
            Indicator_Record_Payment_History__c = 'Yes',
            Posting_Block_Company_Code__c = 'Yes',
            BillCurrency_PY__c = 'CNY - Chinese Renmimbi',
            Sales_Rep_ZS__c = 'US727 - AARON HOUT',
           // Controller_Approver_Group__c = 'AP - South Asia-Pacific', //Line added by Nisha Agrawal for SFDC-477
            Version_ID_for_International_Addresses__c = 'C',
            Tax_Number_5__c = 'Test Tax Number 5'
        );
        insert testRequest;
        
        testTaxClassification = new Tax_Classification__c(
            CMD_Request__c = testRequest.Id,
            Country__c = 'AT - Austria', 
            Tax_Category__c = 'MWST', 
            Tax_Classification__c = '1'
        );
        insert testTaxClassification;

        ApexPages.StandardController theStandardController 
            = new ApexPages.standardController(testRequest);
        CMD_Request_Controller_SAP_Extension theControllerExt 
            = new CMD_Request_Controller_SAP_Extension( theStandardController );
        theControllerExt.theAccountGroup = 'Z001';
//        theControllerExt.theCMD.HUB_Customer__c = 'a1ND0000001vB7GMAU'; 
//        theControllerExt.theCMD.HUB_Customer__c = testCustomer.Id;
        theControllerExt.New_SAP_CMD(); 
      //  System.debug('theControllerExt::'+theControllerExt);
       //  System.debug('theControllerExt.theRequest----'+ theControllerExt.theRequest);  
       //   System.debug('theControllerExt.thecmd----'+ theControllerExt.thecmd); 
        //  System.debug('theControllerExt.thecmd.No_of_days_for_Early_Shipment__c----'+theControllerExt.thecmd.No_of_days_for_Early_Shipment__c); 
        /*********************************************** modified for SIR534**********************************************************************/
        system.assertEquals(theControllerExt.thecmd.No_of_days_for_Early_Shipment__c,theControllerExt.theRequest.No_of_days_for_Early_Shipment__c);
        /*********************************************** modified for SIR534**********************************************************************/
       
       Test.stopTest();
    }  

    //@isTest(SeeAllData=true) 
    @isTest
    static void theZ002SPTest(){
        fetchRecordTypes();
        prepareTestCustomer();
        prepareConsolidatedAccountCode();
        insertFunloc();
        Test.startTest();
        testRequest = new CMD_Request__c(
            Account_Group__c = 'Z002 - Ship To',
            RecordTypeId = newSAPrtId,
            Ready_to_Submit__c = true,
            Request_Status__c = 'Ready to Submit',
            Business_Background_Comments__c = 'Test Business Background Comments',
            Global_Account__c = 'ACI - ACiG',
            Sales_Organisation__c = 'CN62 - MSO China',
/*STAN needs to enhance*/           //Consolidated_Account_Code__c = 'a1rD0000007BKFfIAO', 
/*Modified by Scarlett*/            Consolidated_Account_Code__c = testCACC.Id,
//            SP_GID__c = testCustomer.Name,
//            SP_CustomerID__c = testCustomer.Id,
//Scarlett
            SP_CustomerID__c = testCustomer.Id,
            SP_GID__c = '100000000',
            //SP_CustomerID__c = 'a1ND0000001vB7GMAU',
            SP_Name__c = 'Test Name',
            SP_Street__c = 'Test Street',
            SP_City__c = 'Test City',
            SP_Country__c = 'Netherlands',
            SP_Postal_Code__c = '12345',
           Region__c = 'EU - Europe',
            SP_Telephone__c = '+1234567890',
            SP_Fax__c = '+1234567890',
            SP_Email__c = 'test@test.com',
            SP_Funloc__c = '100000',
            SP_Funloc_Id__c = funLocId,
            Company_Code__c = 'CN62 - MSO China',
            Label_required__c = 'No',
            Industry_Segment__c = 'CC - Computing',
            Industry_Sub_Segment__c = 'C1 - Computing',
            Customer_Factory_Calendar__c = '11 - Ship to Algeria',
          Customer_Service_ZA__c = 'CN214 - Mary Ng',
            Incoterms_1__c = 'CPT - Carriage paid to',
            Incoterms_2__c = 'Test',
            Lockbox__c = 'NOREMIT',
            SH_Same_as_SP__c = true,
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
            Sales_Office__c = 'BOS1 - Bosch',
            S_O_Sub_Group__c = 'CN - China',
            Reconciliation_Account__c = '1200100 - Trade AR with foreign parties',
            No_of_days_for_Early_Shipment__c=50,
            Order_combination__c='Yes',
            Central_deletion_block__c= 'Yes',
            Central_deletion_Flag__c = 'Yes',
            Central_posting_block__c = 'Yes',
            Deletion_Flag_Sales_Area__c = 'Yes',
            Screened_for_SDI__c = 'Yes',
            Deletion_Block_Company_Code__c = 'Yes',
            Deletion_Flag_Company_Code__c = 'Yes',
            Indicator_Record_Payment_History__c = 'Yes',
            Posting_Block_Company_Code__c = 'Yes',
            BillCurrency_PY__c = 'CNY - Chinese Renmimbi',
            Sales_Rep_ZS__c = 'US727 - AARON HOUT',
           // Controller_Approver_Group__c = 'AP - South Asia-Pacific', //Line added by Nisha Agrawal for SFDC-477
            Version_ID_for_International_Addresses__c = 'C'
           // Tax_Number_5__c = 'Test Tax Number 5'
        );
        insert testRequest;

        ApexPages.StandardController theStandardController 
            = new ApexPages.standardController(testRequest);
        CMD_Request_Controller_SAP_Extension theControllerExt 
            = new CMD_Request_Controller_SAP_Extension( theStandardController );
        theControllerExt.theAccountGroup = 'Z002';
       // theControllerExt.City__c='Bengaluru';
//        theControllerExt.theCMD.HUB_Customer__c = 'a1ND0000001vB7GMAU';    
        theControllerExt.New_SAP_CMD();  
        Test.stopTest();
    }  

    //@isTest(SeeAllData=true) 
    @isTest
    static void theZ003Test(){
        fetchRecordTypes();
        prepareTestCustomer();
        prepareConsolidatedAccountCode();
        insertFunloc();
        Test.startTest();
        testRequest = new CMD_Request__c(
            Account_Group__c = 'Z001 - Sold To / Ship To / Bill To / Payer',
            RecordTypeId = newSAPrtId,
            Ready_to_Submit__c = true,
            Request_Status__c = 'Ready to Submit',
            Business_Background_Comments__c = 'Test Business Background Comments',
            Global_Account__c = 'ACI - ACiG',
            Sales_Organisation__c = 'CN62 - MSO China',
/*STAN needs to enhance*/           //Consolidated_Account_Code__c = 'a1rD0000007BKFfIAO', 
/*Modified by Scarlett*/            Consolidated_Account_Code__c = testCACC.Id,
//            PY_GID__c = testCustomer.Name,
            PY_CustomerID__c = testCustomer.Id,
            PY_GID__c = '100000000',
            //PY_CustomerID__c = 'a1ND0000001vB7GMAU',
            PY_Name__c = 'Test Name',
            PY_Street__c = 'Test Street',
            PY_City__c = 'Test City',
            PY_Country__c = 'Netherlands',
            PY_Postal_Code__c = '12345',
           Region__c = 'EU - Europe',
            SP_Telephone__c = '+1234567890',
            SP_Fax__c = '+1234567890',
            SP_Email__c = 'test@test.com',
            SP_Funloc__c = '100000',
            SP_Funloc_Id__c = funLocId,
            Company_Code__c = 'CN62 - MSO China',
            Label_required__c = 'No',
            Industry_Segment__c = 'CC - Computing',
            Industry_Sub_Segment__c = 'C1 - Computing',
            Customer_Factory_Calendar__c = '11 - Ship to Algeria',
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
            Sales_Office__c = 'BOS1 - Bosch',
            S_O_Sub_Group__c = 'CN - China',
            Reconciliation_Account__c = '1200100 - Trade AR with foreign parties',
            No_of_days_for_Early_Shipment__c=50,
            Order_combination__c='Yes',
            Central_deletion_block__c= 'Yes',
            Central_deletion_Flag__c = 'Yes',
            Central_posting_block__c = 'Yes',
            Deletion_Flag_Sales_Area__c = 'Yes',
            Screened_for_SDI__c = 'Yes',
            Deletion_Block_Company_Code__c = 'Yes',
            Deletion_Flag_Company_Code__c = 'Yes',
            Indicator_Record_Payment_History__c = 'Yes',
            Posting_Block_Company_Code__c = 'Yes',
            BillCurrency_PY__c = 'CNY - Chinese Renmimbi',
            Sales_Rep_ZS__c = 'US727 - AARON HOUT',
           // Controller_Approver_Group__c = 'AP - South Asia-Pacific', //Line added by Nisha Agrawal for SFDC-477
            Version_ID_for_International_Addresses__c = 'C',
            Tax_Number_5__c = 'Test Tax Number 5'
        );
        insert testRequest;

        ApexPages.StandardController theStandardController 
            = new ApexPages.standardController(testRequest);
        CMD_Request_Controller_SAP_Extension theControllerExt 
            = new CMD_Request_Controller_SAP_Extension( theStandardController );
        theControllerExt.theAccountGroup = 'Z003';
//        theControllerExt.theCMD.HUB_Customer__c = 'a1ND0000001vB7GMAU';    
        theControllerExt.New_SAP_CMD();
        Test.stopTest();
    }  
    @isTest
    static void theZ003MANUTest(){
        fetchRecordTypes();
        prepareTestCustomer();
        prepareConsolidatedAccountCode();
        insertFunloc();
        Test.startTest();
        testRequest = new CMD_Request__c(
            Account_Group__c = 'Z001 - Sold To / Ship To / Bill To / Payer',
            RecordTypeId = newMANUSAPrt,
            Ready_to_Submit__c = true,
            Request_Status__c = 'Ready to Submit',
            Business_Background_Comments__c = 'Test Business Background Comments',
           Global_Account__c = 'ACI - ACiG',
           Sales_Organisation__c = 'IN61 - NXP India',
/*STAN needs to enhance*/           //Consolidated_Account_Code__c = 'a1rD0000007BKFfIAO', 
/*Modified by Scarlett*/            Consolidated_Account_Code__c = testCACC.Id,
//            PY_GID__c = testCustomer.Name,
            PY_CustomerID__c = testCustomer.Id,
            PY_GID__c = '100000000',
            //PY_CustomerID__c = 'a1ND0000001vB7GMAU',
            PY_Name__c = 'Test Name',
            PY_Street__c = 'Test Street',
            PY_City__c = 'Test City',
            PY_Country__c = 'Netherlands',
            PY_Postal_Code__c = '12345',
           Region__c = 'EU - Europe',
            SP_Telephone__c = '+1234567890',
            SP_Fax__c = '+1234567890',
            SP_Email__c = 'test@test.com',
            SP_Funloc__c = '100000',
            SP_Funloc_Id__c = funLocId,
            Company_Code__c = 'IN61 - NXP India Private Limited',
            Label_required__c = 'No',
            Industry_Segment__c = 'CC - Computing',
            Industry_Sub_Segment__c = 'C1 - Computing',
            Customer_Factory_Calendar__c = '01 - Customer calendar Germany standard',
           Customer_Service_ZA__c = 'JP000 - NXP Japan',
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
            Sales_Office__c = 'IN61 - NXP India',
            S_O_Sub_Group__c = 'CN - China',
            Reconciliation_Account__c = '1200100 - Trade AR with foreign parties',
            No_of_days_for_Early_Shipment__c=50,
            Order_combination__c='Yes',
            Central_deletion_block__c= 'Yes',
            Central_deletion_Flag__c = 'Yes',
            Central_posting_block__c = 'Yes',
            Deletion_Flag_Sales_Area__c = 'Yes',
            Screened_for_SDI__c = 'Yes',
            Deletion_Block_Company_Code__c = 'Yes',
            Deletion_Flag_Company_Code__c = 'Yes',
            Indicator_Record_Payment_History__c = 'Yes',
            Posting_Block_Company_Code__c = 'Yes',
            BillCurrency_PY__c = 'CNY - Chinese Renmimbi',
            Sales_Rep_ZS__c = 'US727 - AARON HOUT',
           // Controller_Approver_Group__c = 'AP - South Asia-Pacific', //Line added by Nisha Agrawal for SFDC-477
            Version_ID_for_International_Addresses__c = 'C',
            Tax_Number_5__c = 'Test Tax Number 5'
        );
        insert testRequest;

        ApexPages.StandardController theStandardController 
            = new ApexPages.standardController(testRequest);
        CMD_Request_Controller_SAP_Extension theControllerExt 
            = new CMD_Request_Controller_SAP_Extension( theStandardController );
        theControllerExt.theAccountGroup = 'Z003';
//        theControllerExt.theCMD.HUB_Customer__c = 'a1ND0000001vB7GMAU';    
        theControllerExt.New_SAP_CMD();
        Test.stopTest();
    }  


    //@isTest(SeeAllData=true) 
    @isTest
    static void theZ003SPTest(){
        fetchRecordTypes();
        prepareTestCustomer();
        prepareConsolidatedAccountCode();
        insertFunloc();
        Test.startTest();
        testRequest = new CMD_Request__c(
            Account_Group__c = 'Z003 - Payer',
            RecordTypeId = newSAPrtId,
            Ready_to_Submit__c = true,
            Request_Status__c = 'Ready to Submit',
            Business_Background_Comments__c = 'Test Business Background Comments',
            Global_Account__c = 'ACI - ACiG',
            Sales_Organisation__c = 'CN62 - MSO China',
/*STAN needs to enhance*/           //Consolidated_Account_Code__c = 'a1rD0000007BKFfIAO', 
/*Modified by Scarlett*/            Consolidated_Account_Code__c = testCACC.Id,
//            SP_GID__c = testCustomer.Name,
            SP_CustomerID__c = testCustomer.Id,
            SP_GID__c = '100000000',
            //SP_CustomerID__c = 'a1ND0000001vB7GMAU',
            SP_Name__c = 'Test Name',
            SP_Street__c = 'Test Street',
            SP_City__c = 'Test City',
            SP_Country__c = 'Netherlands',
            SP_Postal_Code__c = '12345',
           Region__c = 'EU - Europe',
            SP_Telephone__c = '+1234567890',
            SP_Fax__c = '+1234567890',
            SP_Email__c = 'test@test.com',
            SP_Funloc__c = '100000',
            SP_Funloc_Id__c = funLocId,
            Company_Code__c = 'CN62 - MSO China',
            Label_required__c = 'No',
            Industry_Segment__c = 'CC - Computing',
            Industry_Sub_Segment__c = 'C1 - Computing',
            Customer_Factory_Calendar__c = '11 - Ship to Algeria',
           Customer_Service_ZA__c = 'CN214 - Mary Ng',
            Incoterms_1__c = 'CPT - Carriage paid to',
            Incoterms_2__c = 'Test',
            Lockbox__c = 'NOREMIT',
            PY_same_as_sp__c = true,
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
            Sales_Office__c = 'BOS1 - Bosch',
            S_O_Sub_Group__c = 'CN - China',
            Reconciliation_Account__c = '1200100 - Trade AR with foreign parties',
            No_of_days_for_Early_Shipment__c=50,
            Order_combination__c='Yes',
            Central_deletion_block__c= 'Yes',
            Central_deletion_Flag__c = 'Yes',
            Central_posting_block__c = 'Yes',
            Deletion_Flag_Sales_Area__c = 'Yes',
            Screened_for_SDI__c = 'Yes',
            Deletion_Block_Company_Code__c = 'Yes',
            Deletion_Flag_Company_Code__c = 'Yes',
            Indicator_Record_Payment_History__c = 'Yes',
            Posting_Block_Company_Code__c = 'Yes',
            BillCurrency_PY__c = 'CNY - Chinese Renmimbi',
            Sales_Rep_ZS__c = 'US727 - AARON HOUT',
           // Controller_Approver_Group__c = 'AP - South Asia-Pacific', //Line added by Nisha Agrawal for SFDC-477
            Version_ID_for_International_Addresses__c = 'C'
          //  Tax_Number_5__c = 'Test Tax Number 5'
          
        );
        insert testRequest;

        ApexPages.StandardController theStandardController 
            = new ApexPages.standardController(testRequest);
        CMD_Request_Controller_SAP_Extension theControllerExt 
            = new CMD_Request_Controller_SAP_Extension( theStandardController );
        theControllerExt.theAccountGroup = 'Z003';
//        theControllerExt.theCMD.HUB_Customer__c = 'a1ND0000001vB7GMAU';    
        theControllerExt.New_SAP_CMD();
        Test.stopTest();
    }  

    //@isTest(SeeAllData=true) 
    @isTest
    static void theZ004Test(){
        fetchRecordTypes();
        prepareTestCustomer();
        prepareConsolidatedAccountCode();
        insertFunloc();
        Test.startTest();
        testRequest = new CMD_Request__c(
            Account_Group__c = 'Z003 - Payer',
            RecordTypeId = newSAPrtId,
            Ready_to_Submit__c = true,
            Request_Status__c = 'Ready to Submit',
            Business_Background_Comments__c = 'Test Business Background Comments',
            Global_Account__c = 'ACI - ACiG',
            Sales_Organisation__c = 'CN62 - MSO China',
/*STAN needs to enhance*/           //Consolidated_Account_Code__c = 'a1rD0000007BKFfIAO', 
/*Modified by Scarlett*/            Consolidated_Account_Code__c = testCACC.Id,
//            BP_GID__c = testCustomer.Name,
            BP_CustomerID__c = testCustomer.Id,
            BP_GID__c = '100000000',
            //BP_CustomerID__c = 'a1ND0000001vB7GMAU',
            BP_Name__c = 'Test Name',
            BP_Street__c = 'Test Street',
            BP_City__c = 'Test City',
            BP_Country__c = 'Netherlands',
            BP_Postal_Code__c = '12345',
           Region__c = 'EU - Europe',
            SP_Telephone__c = '+1234567890',
            SP_Fax__c = '+1234567890',
            SP_Email__c = 'test@test.com',
            SP_Funloc__c = '100000',
            SP_Funloc_Id__c = funLocId,
            Company_Code__c = 'CN62 - MSO China',
            Label_required__c = 'No',
            Industry_Segment__c = 'CC - Computing',
            Industry_Sub_Segment__c = 'C1 - Computing',
            Customer_Factory_Calendar__c = '11 - Ship to Algeria',
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
            Sales_Office__c = 'BOS1 - Bosch',
            S_O_Sub_Group__c = 'CN - China',
            Reconciliation_Account__c = '1200100 - Trade AR with foreign parties',
            No_of_days_for_Early_Shipment__c=50,
            Order_combination__c='Yes',
            Central_deletion_block__c= 'Yes',
            Central_deletion_Flag__c = 'Yes',
            Central_posting_block__c = 'Yes',
            Deletion_Flag_Sales_Area__c = 'Yes',
            Screened_for_SDI__c = 'Yes',
            Deletion_Block_Company_Code__c = 'Yes',
            Deletion_Flag_Company_Code__c = 'Yes',
            Indicator_Record_Payment_History__c = 'Yes',
            Posting_Block_Company_Code__c = 'Yes',
            BillCurrency_PY__c = 'CNY - Chinese Renmimbi',
            Sales_Rep_ZS__c = 'US727 - AARON HOUT',
           // Controller_Approver_Group__c = 'AP - South Asia-Pacific', //Line added by Nisha Agrawal for SFDC-477
            Version_ID_for_International_Addresses__c = 'C'
          //  Tax_Number_5__c = 'Test Tax Number 5'
        );
        insert testRequest;

        ApexPages.StandardController theStandardController 
            = new ApexPages.standardController(testRequest);
        CMD_Request_Controller_SAP_Extension theControllerExt 
            = new CMD_Request_Controller_SAP_Extension( theStandardController );
        theControllerExt.theAccountGroup = 'Z004';
//        theControllerExt.theCMD.HUB_Customer__c = 'a1ND0000001vB7GMAU';    
        theControllerExt.New_SAP_CMD();   
        Test.stopTest();
    }  

    //@isTest(SeeAllData=true) 
    @isTest
    static void theZ004SPTest(){
        fetchRecordTypes();
        prepareTestCustomer();
        prepareConsolidatedAccountCode();
        insertFunloc();
        Test.startTest();
        testRequest = new CMD_Request__c(
            Account_Group__c = 'Z004 - Bill To',
            BP_Same_as_SP__c = true,
            RecordTypeId = newSAPrtId,
            Ready_to_Submit__c = true,
            Request_Status__c = 'Ready to Submit',
            Business_Background_Comments__c = 'Test Business Background Comments',
            Global_Account__c = 'ACI - ACiG',
            Sales_Organisation__c = 'CN62 - MSO China',
/*STAN needs to enhance*/           //Consolidated_Account_Code__c = 'a1rD0000007BKFfIAO', 
/*Modified by Scarlett*/            Consolidated_Account_Code__c = testCACC.Id,
//            SP_GID__c = testCustomer.Name,
            SP_CustomerID__c = testCustomer.Id,
            SP_GID__c = '100000000',
//            SP_CustomerID__c = 'a1ND0000001vB7GMAU',
            SP_Name__c = 'Test Name',
            SP_Street__c = 'Test Street',
            SP_City__c = 'Test City',
            SP_Country__c = 'Netherlands',
            SP_Postal_Code__c = '12345',
            Region__c = 'EU - Europe',
            SP_Telephone__c = '+1234567890',
            SP_Fax__c = '+1234567890',
            SP_Email__c = 'test@test.com',
            SP_Funloc__c = '100000',
            SP_Funloc_Id__c = funLocId,
            Company_Code__c = 'CN62 - MSO China',
            Label_required__c = 'No',
            Industry_Segment__c = 'CC - Computing',
            Industry_Sub_Segment__c = 'C1 - Computing',
            Customer_Factory_Calendar__c = '11 - Ship to Algeria',
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
            Sales_Office__c = 'BOS1 - Bosch',
            S_O_Sub_Group__c = 'CN - China',
            Reconciliation_Account__c = '1200100 - Trade AR with foreign parties',
            No_of_days_for_Early_Shipment__c=50,
            Order_combination__c='Yes',
            Central_deletion_block__c= 'Yes',
            Central_deletion_Flag__c = 'Yes',
            Central_posting_block__c = 'Yes',
            Deletion_Flag_Sales_Area__c = 'Yes',
            Screened_for_SDI__c = 'Yes',
            Deletion_Block_Company_Code__c = 'Yes',
            Deletion_Flag_Company_Code__c = 'Yes',
            Indicator_Record_Payment_History__c = 'Yes',
            Posting_Block_Company_Code__c = 'Yes',
            BillCurrency_PY__c = 'CNY - Chinese Renmimbi',
            Sales_Rep_ZS__c = 'US727 - AARON HOUT',
           // Controller_Approver_Group__c = 'AP - South Asia-Pacific', //Line added by Nisha Agrawal for SFDC-477
            Version_ID_for_International_Addresses__c = 'C',
            Tax_Number_5__c = 'Test Tax Number 5'
        );
        insert testRequest;

        ApexPages.StandardController theStandardController 
            = new ApexPages.standardController(testRequest);
        CMD_Request_Controller_SAP_Extension theControllerExt 
            = new CMD_Request_Controller_SAP_Extension( theStandardController );
        theControllerExt.theAccountGroup = 'Z004';
//        theControllerExt.theCMD.HUB_Customer__c = 'a1ND0000001vB7GMAU';    
        theControllerExt.New_SAP_CMD();      
        Test.stopTest();
    }  

    //@isTest(SeeAllData=true) 
    @isTest
    static void theZ004PYTest(){
        fetchRecordTypes();
        prepareTestCustomer();
        prepareConsolidatedAccountCode();
        insertFunloc();
        Test.startTest();
        testRequest = new CMD_Request__c(
            Account_Group__c = 'Z004 - Bill To',
            RecordTypeId = newSAPrtId,
            Ready_to_Submit__c = true,
            BP_Same_as_PY__c = true,
            Request_Status__c = 'Ready to Submit',
            Business_Background_Comments__c = 'Test Business Background Comments',
            Global_Account__c = 'ACI - ACiG',
            Sales_Organisation__c = 'CN62 - MSO China',
/*STAN needs to enhance*/           //Consolidated_Account_Code__c = 'a1rD0000007BKFfIAO', 
/*Modified by Scarlett*/            Consolidated_Account_Code__c = testCACC.Id,            
//            PY_GID__c = testCustomer.Name,
            PY_CustomerID__c = testCustomer.Id,
            PY_GID__c = '100000000',
//            PY_CustomerID__c = 'a1ND0000001vB7GMAU',
            PY_Name__c = 'Test Name',
            PY_Street__c = 'Test Street',
            PY_City__c = 'Test City',
            PY_Country__c = 'Netherlands',
            PY_Postal_Code__c = '12345',
           Region__c = 'EU - Europe',
            SP_Telephone__c = '+1234567890',
            SP_Fax__c = '+1234567890',
            SP_Email__c = 'test@test.com',
            SP_Funloc__c = '100000',
            SP_Funloc_Id__c = funLocId,
            Company_Code__c = 'CN62 - MSO China',
            Label_required__c = 'No',
            Industry_Segment__c = 'CC - Computing',
            Industry_Sub_Segment__c = 'C1 - Computing',
            Customer_Factory_Calendar__c = '11 - Ship to Algeria',
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
            Sales_Office__c = 'BOS1 - Bosch',
            S_O_Sub_Group__c = 'CN - China',
            Reconciliation_Account__c = '1200100 - Trade AR with foreign parties',
            No_of_days_for_Early_Shipment__c=50,
            Order_combination__c='Yes',
            Central_deletion_block__c= 'Yes',
            Central_deletion_Flag__c = 'Yes',
            Central_posting_block__c = 'Yes',
            Deletion_Flag_Sales_Area__c = 'Yes',
            Screened_for_SDI__c = 'Yes',
            Deletion_Block_Company_Code__c = 'Yes',
            Deletion_Flag_Company_Code__c = 'Yes',
            Indicator_Record_Payment_History__c = 'Yes',
            Posting_Block_Company_Code__c = 'Yes',
            BillCurrency_PY__c = 'CNY - Chinese Renmimbi',
            Sales_Rep_ZS__c = 'US727 - AARON HOUT',
           // Controller_Approver_Group__c = 'AP - South Asia-Pacific', //Line added by Nisha Agrawal for SFDC-477
            Version_ID_for_International_Addresses__c = 'C',
            Tax_Number_5__c = 'Test Tax Number 5'
        );
        insert testRequest;

        ApexPages.StandardController theStandardController 
            = new ApexPages.standardController(testRequest);
        CMD_Request_Controller_SAP_Extension theControllerExt 
            = new CMD_Request_Controller_SAP_Extension( theStandardController );
        theControllerExt.theAccountGroup = 'Z004';
//        theControllerExt.theCMD.HUB_Customer__c = 'a1ND0000001vB7GMAU';    
        theControllerExt.New_SAP_CMD();
        Test.stopTest();
    }  

    //@isTest(SeeAllData=true) 
    //static void theZ005Test(){
    static testmethod void theZ005test(){
        fetchRecordTypes();
        prepareTestCustomer();
        prepareConsolidatedAccountCode();
        insertFunloc();
        List<Customer__c> lstCustomer = [SELECT Id, Name FROM Customer__c];
        system.assert(lstCustomer.size() > 0);
        Test.startTest();
        testRequest = new CMD_Request__c(
            Account_Group__c = 'Z004 - Bill To',
            RecordTypeId = newSAPrtId,
            Ready_to_Submit__c = true,
            Request_Status__c = 'Ready to Submit',
            Business_Background_Comments__c = 'Test Business Background Comments',
            Global_Account__c = 'ACI - ACiG',
            Sales_Organisation__c = 'CN62 - MSO China',
/*STAN needs to enhance*/           //Consolidated_Account_Code__c = 'a1rD0000007BKFfIAO', 
/*Modified by Scarlett*/            Consolidated_Account_Code__c = testCACC.Id,
//            SP_GID__c = testCustomer.Name,
//            SP_CustomerID__c = testCustomer.Id,
//            SP_GID__c = '100000000',
//            SP_CustomerID__c = 'a1ND0000001vB7GMAU',
            SP_GID__c = string.valueof(lstCustomer[0].Name),
            SP_Name__c = 'Test Name',
            SP_Street__c = 'Test Street',
            SP_City__c = 'Test City',
            SP_Country__c = 'Netherlands',
            SP_Postal_Code__c = '12345',
           Region__c = 'EU - Europe',
            SP_Telephone__c = '+1234567890',
            SP_Fax__c = '+1234567890',
            SP_Email__c = 'test@test.com',
            SP_Funloc__c = '100000',
            SP_Funloc_Id__c = funLocId,
            Company_Code__c = 'CN62 - MSO China',
            Label_required__c = 'No',
            Industry_Segment__c = 'CC - Computing',
            Industry_Sub_Segment__c = 'C1 - Computing',
            Customer_Factory_Calendar__c = '11 - Ship to Algeria',
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
            Sales_Office__c = 'BOS1 - Bosch',
            S_O_Sub_Group__c = 'CN - China',
            Reconciliation_Account__c = '1200100 - Trade AR with foreign parties',
            No_of_days_for_Early_Shipment__c=50,
            Order_combination__c='Yes',
            Central_deletion_block__c= 'Yes',
            Central_deletion_Flag__c = 'Yes',
            Central_posting_block__c = 'Yes',
            Deletion_Flag_Sales_Area__c = 'Yes',
            Screened_for_SDI__c = 'Yes',
            Deletion_Block_Company_Code__c = 'Yes',
            Deletion_Flag_Company_Code__c = 'Yes',
            Indicator_Record_Payment_History__c = 'Yes',
            Posting_Block_Company_Code__c = 'Yes',
            BillCurrency_PY__c = 'CNY - Chinese Renmimbi',
            Sales_Rep_ZS__c = 'US727 - AARON HOUT',
           // Controller_Approver_Group__c = 'AP - South Asia-Pacific', //Line added by Nisha Agrawal for SFDC-477
            Version_ID_for_International_Addresses__c = 'C',
            Tax_Number_5__c = 'Test Tax Number 5'
        );
        insert testRequest;

        ApexPages.StandardController theStandardController 
            = new ApexPages.standardController(testRequest);
        CMD_Request_Controller_SAP_Extension theControllerExt 
            = new CMD_Request_Controller_SAP_Extension( theStandardController );
        theControllerExt.theAccountGroup = 'Z005';
//        theControllerExt.theCMD.HUB_Customer__c = 'a1ND0000001vB7GMAU';  
        theControllerExt.New_SAP_CMD();  
        Test.stopTest();
    }  
     static testmethod void theZ005MANUtest(){
        fetchRecordTypes();
        prepareTestCustomer();
        prepareConsolidatedAccountCode();
        insertFunloc();
        List<Customer__c> lstCustomer = [SELECT Id, Name FROM Customer__c];
        system.assert(lstCustomer.size() > 0);
        Test.startTest();
        testRequest = new CMD_Request__c(
            Account_Group__c = 'Z005 - Sold To / Bill To / Payer',
            RecordTypeId = newMANUSAPrt,
            Ready_to_Submit__c = true,
            Request_Status__c = 'Ready to Submit',
            Business_Background_Comments__c = 'Test Business Background Comments',
            Global_Account__c = 'ACI - ACiG',
           Sales_Organisation__c = 'IN61 - NXP India',
            Sales_Office__c = 'IN61 - NXP India',
             Company_Code__c = 'IN61 - NXP India Private Limited',
/*STAN needs to enhance*/           //Consolidated_Account_Code__c = 'a1rD0000007BKFfIAO', 
/*Modified by Scarlett*/            Consolidated_Account_Code__c = testCACC.Id,
//            SP_GID__c = testCustomer.Name,
//            SP_CustomerID__c = testCustomer.Id,
//            SP_GID__c = '100000000',
//            SP_CustomerID__c = 'a1ND0000001vB7GMAU',
            SP_GID__c = string.valueof(lstCustomer[0].Name),
            SP_Name__c = 'Test Name',
            SP_Street__c = 'Test Street',
            SP_City__c = 'Test City',
            SP_Country__c = 'Netherlands',
            SP_Postal_Code__c = '12345',
           Region__c = 'EU - Europe',
            SP_Telephone__c = '+1234567890',
            SP_Fax__c = '+1234567890',
            SP_Email__c = 'test@test.com',
            SP_Funloc__c = '100000',
            SP_Funloc_Id__c = funLocId,
           // Company_Code__c = 'CN62 - MSO China',
            Label_required__c = 'No',
            Industry_Segment__c = 'CC - Computing',
            Industry_Sub_Segment__c = 'C1 - Computing',
            Customer_Factory_Calendar__c = '01 - Customer calendar Germany standard',
            Customer_Service_ZA__c = 'JP000 - NXP Japan',
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
          //  Sales_Office__c = 'AT61 - SOffice GRK',
            S_O_Sub_Group__c = 'CN - China',
            Reconciliation_Account__c = '1200100 - Trade AR with foreign parties',
            No_of_days_for_Early_Shipment__c=50,
            Order_combination__c='Yes',
            Central_deletion_block__c= 'Yes',
            Central_deletion_Flag__c = 'Yes',
            Central_posting_block__c = 'Yes',
            Deletion_Flag_Sales_Area__c = 'Yes',
            Screened_for_SDI__c = 'Yes',
            Deletion_Block_Company_Code__c = 'Yes',
            Deletion_Flag_Company_Code__c = 'Yes',
            Indicator_Record_Payment_History__c = 'Yes',
            Posting_Block_Company_Code__c = 'Yes',
            BillCurrency_PY__c = 'CNY - Chinese Renmimbi',
            Sales_Rep_ZS__c = 'US727 - AARON HOUT',
           // Controller_Approver_Group__c = 'AP - South Asia-Pacific', //Line added by Nisha Agrawal for SFDC-477
            Version_ID_for_International_Addresses__c = 'C'
           // Tax_Number_5__c = 'Test Tax Number 5'
        );
        insert testRequest;

        ApexPages.StandardController theStandardController 
            = new ApexPages.standardController(testRequest);
        CMD_Request_Controller_SAP_Extension theControllerExt 
            = new CMD_Request_Controller_SAP_Extension( theStandardController );
        theControllerExt.theAccountGroup = 'Z005';
//        theControllerExt.theCMD.HUB_Customer__c = 'a1ND0000001vB7GMAU';  
        theControllerExt.New_SAP_CMD();  
        Test.stopTest();
    }  
    static testmethod void theZ005test2(){
        fetchRecordTypes();
        prepareTestCustomer();
        prepareConsolidatedAccountCode();
        insertFunloc();
        List<Customer__c> lstCustomer = [SELECT Id, Name FROM Customer__c];
        system.assert(lstCustomer.size() > 0);
        Test.startTest();
        testRequest = new CMD_Request__c(
            Account_Group__c = 'Z005 - Sold To / Bill To / Payer',
            RecordTypeId = newSAPrtId,
            Ready_to_Submit__c = true,
            Request_Status__c = 'Ready to Submit',
            Business_Background_Comments__c = 'Test Business Background Comments',
            Global_Account__c = 'ACI - ACiG',
            Sales_Organisation__c = 'CN62 - MSO China',
            Consolidated_Account_Code__c = testCACC.Id,
            SP_GID__c = string.valueof(lstCustomer[0].Name),
            SP_Name__c = 'Test Name',
            SP_Street__c = 'Test Street',
            SP_City__c = 'Test City',
            SP_Country__c = 'Netherlands',
            SP_Postal_Code__c = '12345',
           Region__c = 'EU - Europe',
            SP_Telephone__c = '+1234567890',
            SP_Fax__c = '+1234567890',
            SP_Email__c = 'test@test.com',
            SP_Funloc__c = '100000',
            SP_Funloc_Id__c = funLocId,
            Company_Code__c = 'CN62 - MSO China',
            Label_required__c = 'No',
            Industry_Segment__c = 'CC - Computing',
            Industry_Sub_Segment__c = 'C1 - Computing',
            Customer_Factory_Calendar__c = '11 - Ship to Algeria',
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
            Sales_Office__c = 'BOS1 - Bosch',
            S_O_Sub_Group__c = 'CN - China',
            Reconciliation_Account__c = '1200100 - Trade AR with foreign parties',
            No_of_days_for_Early_Shipment__c=50,
            Order_combination__c='Yes',
            Central_deletion_block__c= 'Yes',
            Central_deletion_Flag__c = 'Yes',
            Central_posting_block__c = 'Yes',
            Deletion_Flag_Sales_Area__c = 'Yes',
            Screened_for_SDI__c = 'Yes',
            Deletion_Block_Company_Code__c = 'Yes',
            Deletion_Flag_Company_Code__c = 'Yes',
            Indicator_Record_Payment_History__c = 'Yes',
            Posting_Block_Company_Code__c = 'Yes',
            BillCurrency_PY__c = 'CNY - Chinese Renmimbi',
            Sales_Rep_ZS__c = 'US727 - AARON HOUT',
           // Controller_Approver_Group__c = 'AP - South Asia-Pacific', //Line added by Nisha Agrawal for SFDC-477
            Version_ID_for_International_Addresses__c = 'C',
            Tax_Number_5__c = 'Test Tax Number 5'
        );
        insert testRequest;

        ApexPages.StandardController theStandardController 
            = new ApexPages.standardController(testRequest);
        CMD_Request_Controller_SAP_Extension theControllerExt 
            = new CMD_Request_Controller_SAP_Extension( theStandardController );
        theControllerExt.theAccountGroup = 'Z005';

        theControllerExt.New_SAP_CMD();  
        Test.stopTest();
    }  

    //@isTest(SeeAllData=true) 
    @isTest
    static void theZ010Test(){
        fetchRecordTypes();
        prepareTestCustomer();
        prepareConsolidatedAccountCode();
        insertFunloc();
        Test.startTest();
        testRequest = new CMD_Request__c(
            Account_Group__c = 'Z010 - Intermediate Consignee',
            RecordTypeId = newSAPrtId,
            Ready_to_Submit__c = true,
            Request_Status__c = 'Ready to Submit',
            Business_Background_Comments__c = 'Test Business Background Comments',
           Global_Account__c = 'ACI - ACiG',
            Sales_Organisation__c = 'CN62 - MSO China',
/*STAN needs to enhance*/           //Consolidated_Account_Code__c = 'a1rD0000007BKFfIAO', 
/*Modified by Scarlett*/            Consolidated_Account_Code__c = testCACC.Id,
//            ZI_GID__c = testCustomer.Name,
            ZI_CustomerID__c = testCustomer.Id,
            ZI_GID__c = '100000000',
//            ZI_CustomerID__c = 'a1ND0000001vB7GMAU',
            ZI_Name__c = 'Test Name',
            ZI_Street__c = 'Test Street',
            ZI_City__c = 'Test City',
            ZI_Country__c = 'Netherlands',
            ZI_Postal_Code__c = '12345',
           Region__c = 'EU - Europe',
            SP_Telephone__c = '+1234567890',
            SP_Fax__c = '+1234567890',
            SP_Email__c = 'test@test.com',
            SP_Funloc__c = '100000',
            SP_Funloc_Id__c = funLocId,
            Company_Code__c = 'CN62 - MSO China',
            Label_required__c = 'No',
            Industry_Segment__c = 'CC - Computing',
            Industry_Sub_Segment__c = 'C1 - Computing',
            Customer_Factory_Calendar__c = '11 - Ship to Algeria',
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
            Sales_Office__c = 'BOS1 - Bosch',
            S_O_Sub_Group__c = 'CN - China',
            Reconciliation_Account__c = '1200100 - Trade AR with foreign parties',
            No_of_days_for_Early_Shipment__c=50,
            Order_combination__c='Yes',
            Central_deletion_block__c= 'Yes',
            Central_deletion_Flag__c = 'Yes',
            Central_posting_block__c = 'Yes',
            Deletion_Flag_Sales_Area__c = 'Yes',
            Screened_for_SDI__c = 'Yes',
            Deletion_Block_Company_Code__c = 'Yes',
            Deletion_Flag_Company_Code__c = 'Yes',
            Indicator_Record_Payment_History__c = 'Yes',
            Posting_Block_Company_Code__c = 'Yes'
            
        );
        insert testRequest;

        ApexPages.StandardController theStandardController 
            = new ApexPages.standardController(testRequest);
        CMD_Request_Controller_SAP_Extension theControllerExt 
            = new CMD_Request_Controller_SAP_Extension( theStandardController );
        theControllerExt.theAccountGroup = 'Z010';
//        theControllerExt.theCMD.HUB_Customer__c = 'a1ND0000001vB7GMAU';    
        theControllerExt.New_SAP_CMD();      
        Test.stopTest();
    }  
    @isTest
    static void theZ010Test1(){
        fetchRecordTypes();
        prepareTestCustomer();
        prepareConsolidatedAccountCode();
        insertFunloc();
        Test.startTest();
        testRequest = new CMD_Request__c(
            Account_Group__c = 'Z010 - Intermediate Consignee',
            RecordTypeId = newSAPrtId,
            Ready_to_Submit__c = true,
            Request_Status__c = 'Ready to Submit',
            Business_Background_Comments__c = 'Test Business Background Comments',
            Global_Account__c = 'ACI - ACiG',
            Sales_Organisation__c = 'CN62 - MSO China',
/*STAN needs to enhance*/           //Consolidated_Account_Code__c = 'a1rD0000007BKFfIAO', 
/*Modified by Scarlett*/            Consolidated_Account_Code__c = testCACC.Id,
//            ZI_GID__c = testCustomer.Name,
            ZI_CustomerID__c = testCustomer.Id,
            ZI_GID__c = '100000000',
//            ZI_CustomerID__c = 'a1ND0000001vB7GMAU',
            ZI_Name__c = 'Test Name',
            ZI_Street__c = 'Test Street',
            ZI_City__c = 'Test City',
            ZI_Country__c = 'Netherlands',
            ZI_Postal_Code__c = '12345',
           Region__c = 'EU - Europe',
            SP_Telephone__c = '+1234567890',
            SP_Fax__c = '+1234567890',
            SP_Email__c = 'test@test.com',
            SP_Funloc__c = '100000',
            SP_Funloc_Id__c = funLocId,
            Company_Code__c = 'CN62 - MSO China',
            Label_required__c = 'No',
            Industry_Segment__c = 'CC - Computing',
            Industry_Sub_Segment__c = 'C1 - Computing',
            Customer_Factory_Calendar__c = '11 - Ship to Algeria',
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
            Sales_Office__c = 'BOS1 - Bosch',
            S_O_Sub_Group__c = 'CN - China',
            Reconciliation_Account__c = '1200100 - Trade AR with foreign parties',
            No_of_days_for_Early_Shipment__c=50,
            Order_combination__c='Yes',
            Central_deletion_block__c= 'Yes',
            Central_deletion_Flag__c = 'Yes',
            Central_posting_block__c = 'Yes',
            Deletion_Flag_Sales_Area__c = 'Yes',
            Screened_for_SDI__c = 'Yes',
            Deletion_Block_Company_Code__c = 'Yes',
            Deletion_Flag_Company_Code__c = 'Yes',
            Indicator_Record_Payment_History__c = 'Yes',
            Posting_Block_Company_Code__c = 'Yes'
           

        );
        insert testRequest;

        ApexPages.StandardController theStandardController 
            = new ApexPages.standardController(testRequest);
        CMD_Request_Controller_SAP_Extension theControllerExt 
            = new CMD_Request_Controller_SAP_Extension( theStandardController );
        theControllerExt.theAccountGroup = 'Z010';
//        theControllerExt.theCMD.HUB_Customer__c = 'a1ND0000001vB7GMAU';    
        theControllerExt.New_SAP_CMD();      
        Test.stopTest();
    }  


    //@isTest(SeeAllData=true) 
    //static void theZ011Test(){
    
    static testmethod void theZ011Test(){
        fetchRecordTypes();
        prepareTestCustomer();
        prepareConsolidatedAccountCode();
        insertFunloc();
        Test.startTest();
        List<Customer__c> lstCustomer = [SELECT Id, Name FROM Customer__c];
        system.assert(lstCustomer.size() > 0);
        
        testRequest = new CMD_Request__c(
            Account_Group__c = 'Z011 - Sold To',
            RecordTypeId = newSAPrtId,
            Ready_to_Submit__c = true,
            Request_Status__c = 'Ready to Submit',
            Business_Background_Comments__c = 'Test Business Background Comments',
            Global_Account__c = 'ACI - ACiG',
            Sales_Organisation__c = 'CN62 - MSO China',
/*STAN needs to enhance*/           //Consolidated_Account_Code__c = 'a1rD0000007BKFfIAO', 
/*Modified by Scarlett*/            Consolidated_Account_Code__c = testCACC.Id,
//            SP_GID__c = testCustomer.Name,
//            SP_CustomerID__c = testCustomer.Id,
//            SP_GID__c = '100000000',
//            SP_CustomerID__c = 'a1ND0000001vB7GMAU',
            SP_GID__c = string.valueof(lstCustomer[0].Name),
            SP_Name__c = 'Test Name',
            SP_Street__c = 'Test Street',
            SP_City__c = 'Test City',
            SP_Country__c = 'Netherlands',
            SP_Postal_Code__c = '12345',
           Region__c = 'EU - Europe',
            SP_Telephone__c = '+1234567890',
            SP_Fax__c = '+1234567890',
            SP_Email__c = 'test@test.com',
            SP_Funloc__c = '100000',
            SP_Funloc_Id__c = funLocId,
            Company_Code__c = 'CN62 - MSO China',
            Label_required__c = 'No',
            Industry_Segment__c = 'CC - Computing',
            Industry_Sub_Segment__c = 'C1 - Computing',
            Customer_Factory_Calendar__c = '11 - Ship to Algeria',
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
            Sales_Office__c = 'BOS1 - Bosch',
            S_O_Sub_Group__c = 'CN - China',
            Reconciliation_Account__c = '1200100 - Trade AR with foreign parties',
            No_of_days_for_Early_Shipment__c=50,
            Order_combination__c='Yes',
            Central_deletion_block__c= 'Yes',
            Central_deletion_Flag__c = 'Yes',
            Central_posting_block__c = 'Yes',
            Deletion_Flag_Sales_Area__c = 'Yes',
            Screened_for_SDI__c = 'Yes',
            Deletion_Block_Company_Code__c = 'Yes',
            Deletion_Flag_Company_Code__c = 'Yes',
            Indicator_Record_Payment_History__c = 'Yes',
            Posting_Block_Company_Code__c = 'Yes',
            BillCurrency_PY__c = 'CNY - Chinese Renmimbi',
            Sales_Rep_ZS__c = 'US727 - AARON HOUT',
           // Controller_Approver_Group__c = 'AP - South Asia-Pacific', //Line added by Nisha Agrawal for SFDC-477
            Version_ID_for_International_Addresses__c = 'C'
           // Tax_Number_5__c = 'Test Tax Number 5'
        );
        insert testRequest;

        ApexPages.StandardController theStandardController 
            = new ApexPages.standardController(testRequest);
        CMD_Request_Controller_SAP_Extension theControllerExt 
            = new CMD_Request_Controller_SAP_Extension( theStandardController );
        theControllerExt.theAccountGroup = 'Z011';
//        theControllerExt.theCMD.HUB_Customer__c = 'a1ND0000001vB7GMAU';   
        theControllerExt.New_SAP_CMD();   
        Test.stopTest();
    }  
    
    static testmethod void theZ011Test1(){
        fetchRecordTypes();
        prepareTestCustomer();
        prepareConsolidatedAccountCode();
        insertFunloc();
        Test.startTest();
        List<Customer__c> lstCustomer = [SELECT Id, Name FROM Customer__c];
        system.assert(lstCustomer.size() > 0);
        
        testRequest = new CMD_Request__c(
            Account_Group__c = 'Z011 - Sold To',
            RecordTypeId = newSAPrtId,
            Ready_to_Submit__c = true,
            Request_Status__c = 'Ready to Submit',
            Business_Background_Comments__c = 'Test Business Background Comments',
            Global_Account__c = 'ACI - ACiG',
            Sales_Organisation__c = 'CN62 - MSO China',
/*STAN needs to enhance*/           //Consolidated_Account_Code__c = 'a1rD0000007BKFfIAO', 
/*Modified by Scarlett*/            Consolidated_Account_Code__c = testCACC.Id,
//            SP_GID__c = testCustomer.Name,
//            SP_CustomerID__c = testCustomer.Id,
//            SP_GID__c = '100000000',
//            SP_CustomerID__c = 'a1ND0000001vB7GMAU',
            SP_GID__c = string.valueof(lstCustomer[0].Name),
            SP_Name__c = 'Test Name',
            SP_Street__c = 'Test Street',
            SP_City__c = 'Test City',
            SP_Country__c = 'Netherlands',
            SP_Postal_Code__c = '12345',
            Region__c = 'EU - Europe',
            SP_Telephone__c = '+1234567890',
            SP_Fax__c = '+1234567890',
            SP_Email__c = 'test@test.com',
            SP_Funloc__c = '100000',
            SP_Funloc_Id__c = funLocId,
            Company_Code__c = 'CN62 - MSO China',
            Label_required__c = 'No',
            Industry_Segment__c = 'CC - Computing',
            Industry_Sub_Segment__c = 'C1 - Computing',
            Customer_Factory_Calendar__c = '11 - Ship to Algeria',
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
            Sales_Office__c = 'BOS1 - Bosch',
            S_O_Sub_Group__c = 'CN - China',
            Reconciliation_Account__c = '1200100 - Trade AR with foreign parties',
            No_of_days_for_Early_Shipment__c=50,
            Order_combination__c='Yes',
            Central_deletion_block__c= 'Yes',
            Central_deletion_Flag__c = 'Yes',
            Central_posting_block__c = 'Yes',
            Deletion_Flag_Sales_Area__c = 'Yes',
            Screened_for_SDI__c = 'Yes',
            Deletion_Block_Company_Code__c = 'Yes',
            Deletion_Flag_Company_Code__c = 'Yes',
            Indicator_Record_Payment_History__c = 'Yes',
            Posting_Block_Company_Code__c = 'Yes',
            BillCurrency_PY__c = 'CNY - Chinese Renmimbi',
            Sales_Rep_ZS__c = 'US727 - AARON HOUT',
           // Controller_Approver_Group__c = 'AP - South Asia-Pacific', //Line added by Nisha Agrawal for SFDC-477
            Version_ID_for_International_Addresses__c = 'C',
            Tax_Number_5__c = 'Test Tax Number 5'
        );
        insert testRequest;

        ApexPages.StandardController theStandardController 
            = new ApexPages.standardController(testRequest);
        CMD_Request_Controller_SAP_Extension theControllerExt 
            = new CMD_Request_Controller_SAP_Extension( theStandardController );
        theControllerExt.theAccountGroup = 'Z011';
//        theControllerExt.theCMD.HUB_Customer__c = 'a1ND0000001vB7GMAU';   
        theControllerExt.New_SAP_CMD();   
        Test.stopTest();
    }  

    //@isTest(SeeAllData=true) 
    //static void theZ012Test(){
    static testmethod void theZ012Test(){
        fetchRecordTypes();
        prepareTestCustomer();
        prepareConsolidatedAccountCode();
        Test.startTest();
        insertFunloc();
        List<Customer__c> lstCustomer = [SELECT Id, Name FROM Customer__c];
        system.assert(lstCustomer.size() > 0);        
        
        testRequest = new CMD_Request__c(
            Account_Group__c = 'Z012 - Sold to / Ship To',
            RecordTypeId = newSAPrtId,
            Ready_to_Submit__c = true,
            Request_Status__c = 'Ready to Submit',
            Business_Background_Comments__c = 'Test Business Background Comments',
            Global_Account__c = 'ACI - ACiG',
            Sales_Organisation__c = 'CN62 - MSO China',
/*STAN needs to enhance*/           //Consolidated_Account_Code__c = 'a1rD0000007BKFfIAO', 
/*Modified by Scarlett*/            Consolidated_Account_Code__c = testCACC.Id,
//            SP_GID__c = testCustomer.Name,
//            SP_CustomerID__c = testCustomer.Id,
//            SP_GID__c = '100000000',
//            SP_CustomerID__c = 'a1ND0000001vB7GMAU',
            SP_GID__c = string.valueof(lstCustomer[0].Name),
            SP_Name__c = 'Test Name',
            SP_Street__c = 'Test Street',
            SP_City__c = 'Test City',
            SP_Country__c = 'Netherlands',
            SP_Postal_Code__c = '12345',
           Region__c = 'EU - Europe',
            SP_Telephone__c = '+1234567890',
            SP_Fax__c = '+1234567890',
            SP_Email__c = 'test@test.com',
            SP_Funloc__c = '100000',
            SP_Funloc_Id__c = funLocId,
            Company_Code__c = 'CN62 - MSO China',
            Label_required__c = 'No',
            Industry_Segment__c = 'CC - Computing',
            Industry_Sub_Segment__c = 'C1 - Computing',
            Customer_Factory_Calendar__c = '11 - Ship to Algeria',
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
            Sales_Office__c = 'BOS1 - Bosch',
            S_O_Sub_Group__c = 'CN - China',
            Reconciliation_Account__c = '1200100 - Trade AR with foreign parties',
            No_of_days_for_Early_Shipment__c=50,
            Order_combination__c='Yes',
            Central_deletion_block__c= 'Yes',
            Central_deletion_Flag__c = 'Yes',
            Central_posting_block__c = 'Yes',
            Deletion_Flag_Sales_Area__c = 'Yes',
            Screened_for_SDI__c = 'Yes',
            Deletion_Block_Company_Code__c = 'Yes',
            Deletion_Flag_Company_Code__c = 'Yes',
            Indicator_Record_Payment_History__c = 'Yes',
            Posting_Block_Company_Code__c = 'Yes',
            BillCurrency_PY__c = 'CNY - Chinese Renmimbi',
            Sales_Rep_ZS__c = 'US727 - AARON HOUT',
           // Controller_Approver_Group__c = 'AP - South Asia-Pacific', //Line added by Nisha Agrawal for SFDC-477
            Version_ID_for_International_Addresses__c = 'C',
            Tax_Number_5__c = 'Test Tax Number 5'
        );
        insert testRequest;

        ApexPages.StandardController theStandardController 
            = new ApexPages.standardController(testRequest);
        CMD_Request_Controller_SAP_Extension theControllerExt 
            = new CMD_Request_Controller_SAP_Extension( theStandardController );
        theControllerExt.theAccountGroup = 'Z012';
//        theControllerExt.theCMD.HUB_Customer__c = 'a1ND0000001vB7GMAU';  
        theControllerExt.New_SAP_CMD();      
          /*********************************************** modified for SIR534**********************************************************************/
        system.assertEquals(theControllerExt.thecmd.No_of_days_for_Early_Shipment__c,theControllerExt.theRequest.No_of_days_for_Early_Shipment__c);
        /*********************************************** modified for SIR534**********************************************************************/
       
        Test.stopTest();
    }  
    
    static testmethod void theZ012Test1(){
        fetchRecordTypes();
        prepareTestCustomer();
        prepareConsolidatedAccountCode();
        Test.startTest();
        insertFunloc();
        List<Customer__c> lstCustomer = [SELECT Id, Name FROM Customer__c];
        system.assert(lstCustomer.size() > 0);        
        
        testRequest = new CMD_Request__c(
            Account_Group__c = 'Z012 - Sold to / Ship To',
            RecordTypeId = newSAPrtId,
            Ready_to_Submit__c = true,
            Request_Status__c = 'Ready to Submit',
            Business_Background_Comments__c = 'Test Business Background Comments',
            Global_Account__c = 'ACI - ACiG',
            Sales_Organisation__c = 'CN62 - MSO China',
/*STAN needs to enhance*/           //Consolidated_Account_Code__c = 'a1rD0000007BKFfIAO', 
/*Modified by Scarlett*/            Consolidated_Account_Code__c = testCACC.Id,
//            SP_GID__c = testCustomer.Name,
//            SP_CustomerID__c = testCustomer.Id,
//            SP_GID__c = '100000000',
//            SP_CustomerID__c = 'a1ND0000001vB7GMAU',
            SP_GID__c = string.valueof(lstCustomer[0].Name),
            SP_Name__c = 'Test Name',
            SP_Street__c = 'Test Street',
            SP_City__c = 'Test City',
            SP_Country__c = 'Netherlands',
            SP_Postal_Code__c = '12345',
           Region__c = 'EU - Europe',
            SP_Telephone__c = '+1234567890',
            SP_Fax__c = '+1234567890',
            SP_Email__c = 'test@test.com',
            SP_Funloc__c = '100000',
            SP_Funloc_Id__c = funLocId,
            Company_Code__c = 'CN62 - MSO China',
            Label_required__c = 'No',
            Industry_Segment__c = 'CC - Computing',
            Industry_Sub_Segment__c = 'C1 - Computing',
            Customer_Factory_Calendar__c = '11 - Ship to Algeria',
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
            Sales_Office__c = 'BOS1 - Bosch',
            S_O_Sub_Group__c = 'CN - China',
            Reconciliation_Account__c = '1200100 - Trade AR with foreign parties',
            No_of_days_for_Early_Shipment__c=50,
            Order_combination__c='Yes',
            Central_deletion_block__c= 'Yes',
            Central_deletion_Flag__c = 'Yes',
            Central_posting_block__c = 'Yes',
            Deletion_Flag_Sales_Area__c = 'Yes',
            Screened_for_SDI__c = 'Yes',
            Deletion_Block_Company_Code__c = 'Yes',
            Deletion_Flag_Company_Code__c = 'Yes',
            Indicator_Record_Payment_History__c = 'Yes',
            Posting_Block_Company_Code__c = 'Yes',
            BillCurrency_PY__c = 'CNY - Chinese Renmimbi',
            Sales_Rep_ZS__c = 'US727 - AARON HOUT',
           // Controller_Approver_Group__c = 'AP - South Asia-Pacific', //Line added by Nisha Agrawal for SFDC-477
            Version_ID_for_International_Addresses__c = 'C',
            Tax_Number_5__c = 'Test Tax Number 5'
        );
        insert testRequest;

        ApexPages.StandardController theStandardController 
            = new ApexPages.standardController(testRequest);
        CMD_Request_Controller_SAP_Extension theControllerExt 
            = new CMD_Request_Controller_SAP_Extension( theStandardController );
        theControllerExt.theAccountGroup = 'Z012';
//        theControllerExt.theCMD.HUB_Customer__c = 'a1ND0000001vB7GMAU';  
        theControllerExt.New_SAP_CMD();      
          /*********************************************** modified for SIR534**********************************************************************/
        system.assertEquals(theControllerExt.thecmd.No_of_days_for_Early_Shipment__c,theControllerExt.theRequest.No_of_days_for_Early_Shipment__c);
        /*********************************************** modified for SIR534**********************************************************************/
       
        Test.stopTest();
    }  

    //@isTest(SeeAllData=true) 
    @isTest
    static void theZ013Test(){
        fetchRecordTypes();
        prepareTestCustomer();
        prepareConsolidatedAccountCode();
        insertFunloc();
        Test.startTest();
        testRequest = new CMD_Request__c(
            Account_Group__c = 'Z013 - Payer / Bill To',
            RecordTypeId = newSAPrtId,
            Ready_to_Submit__c = true,
            Request_Status__c = 'Ready to Submit',
            Business_Background_Comments__c = 'Test Business Background Comments',
            Global_Account__c = 'ACI - ACiG',
            Sales_Organisation__c = 'CN62 - MSO China',
/*STAN needs to enhance*/           //Consolidated_Account_Code__c = 'a1rD0000007BKFfIAO', 
/*Modified by Scarlett*/            Consolidated_Account_Code__c = testCACC.Id,
//            PY_GID__c = testCustomer.Name,
            PY_CustomerID__c = testCustomer.Id,
            PY_GID__c = '100000000',
//            PY_CustomerID__c = 'a1ND0000001vB7GMAU',
            PY_Name__c = 'Test Name',
            PY_Street__c = 'Test Street',
            PY_City__c = 'Test City',
            PY_Country__c = 'Netherlands',
            PY_Postal_Code__c = '12345',
           Region__c = 'EU - Europe',
            SP_Telephone__c = '+1234567890',
            SP_Fax__c = '+1234567890',
            SP_Email__c = 'test@test.com',
            SP_Funloc__c = '100000',
            SP_Funloc_Id__c = funLocId,
            Company_Code__c = 'CN62 - MSO China',
            Label_required__c = 'No',
            Industry_Segment__c = 'CC - Computing',
            Industry_Sub_Segment__c = 'C1 - Computing',
            Customer_Factory_Calendar__c = '11 - Ship to Algeria',
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
            Sales_Office__c = 'BOS1 - Bosch',
            S_O_Sub_Group__c = 'CN - China',
            Reconciliation_Account__c = '1200100 - Trade AR with foreign parties',
            No_of_days_for_Early_Shipment__c=50,
            Order_combination__c='Yes',
            Central_deletion_block__c= 'Yes',
            Central_deletion_Flag__c = 'Yes',
            Central_posting_block__c = 'Yes',
            Deletion_Flag_Sales_Area__c = 'Yes',
            Screened_for_SDI__c = 'Yes',
            Deletion_Block_Company_Code__c = 'Yes',
            Deletion_Flag_Company_Code__c = 'Yes',
            Indicator_Record_Payment_History__c = 'Yes',
            Posting_Block_Company_Code__c = 'Yes',
            BillCurrency_PY__c = 'CNY - Chinese Renmimbi',
            Sales_Rep_ZS__c = 'US727 - AARON HOUT',
           // Controller_Approver_Group__c = 'AP - South Asia-Pacific', //Line added by Nisha Agrawal for SFDC-477
            Version_ID_for_International_Addresses__c = 'C',
            Tax_Number_5__c = 'Test Tax Number 5'
        );
        insert testRequest;
        System.debug('STAN:testRequest.Account_Group__c=' + testRequest.Account_Group__c);
        System.debug('STAN:theRequest.PY_Same_as_SP__c=' + testRequest.PY_Same_as_SP__c);

        ApexPages.StandardController theStandardController 
            = new ApexPages.standardController(testRequest);
        CMD_Request_Controller_SAP_Extension theControllerExt 
            = new CMD_Request_Controller_SAP_Extension( theStandardController );
        theControllerExt.theAccountGroup = 'Z013';
//        theControllerExt.theCMD.HUB_Customer__c = 'a1ND0000001vB7GMAU';    
        theControllerExt.New_SAP_CMD();  
        Test.stopTest();
    }
    
     @isTest
    static void theZ013MANUTest(){
        fetchRecordTypes();
        prepareTestCustomer();
        prepareConsolidatedAccountCode();
        insertFunloc();
        Test.startTest();
        testRequest = new CMD_Request__c(
            Account_Group__c = 'Z013 - Payer / Bill To',
            RecordTypeId = newMANUSAPrt,
            Ready_to_Submit__c = true,
            Request_Status__c = 'Ready to Submit',
            Business_Background_Comments__c = 'Test Business Background Comments',
            Global_Account__c = 'ACI - ACiG',
            Sales_Organisation__c = 'IN61 - NXP India',
                Sales_Office__c = 'IN61 - NXP India',
                 Company_Code__c = 'IN61 - NXP India Private Limited',
/*STAN needs to enhance*/           //Consolidated_Account_Code__c = 'a1rD0000007BKFfIAO', 
/*Modified by Scarlett*/            Consolidated_Account_Code__c = testCACC.Id,
//            PY_GID__c = testCustomer.Name,
            PY_CustomerID__c = testCustomer.Id,
            PY_GID__c = '100000000',
//            PY_CustomerID__c = 'a1ND0000001vB7GMAU',
            PY_Name__c = 'Test Name',
            PY_Street__c = 'Test Street',
            PY_City__c = 'Test City',
            PY_Country__c = 'Netherlands',
            PY_Postal_Code__c = '12345',
           Region__c = 'EU - Europe',
            SP_Telephone__c = '+1234567890',
            SP_Fax__c = '+1234567890',
            SP_Email__c = 'test@test.com',
            SP_Funloc__c = '100000',
            SP_Funloc_Id__c = funLocId,
          //Company_Code__c = 'CN62 - MSO China',
            Label_required__c = 'No',
            Industry_Segment__c = 'CC - Computing',
            Industry_Sub_Segment__c = 'C1 - Computing',
            Customer_Factory_Calendar__c = '01 - Customer calendar Germany standard',
          Customer_Service_ZA__c = 'JP000 - NXP Japan',
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
          //  Sales_Office__c = 'AT61 - SOffice GRK',
            S_O_Sub_Group__c = 'CN - China',
            Reconciliation_Account__c = '1200100 - Trade AR with foreign parties',
            No_of_days_for_Early_Shipment__c=50,
            Order_combination__c='Yes',
            Central_deletion_block__c= 'Yes',
            Central_deletion_Flag__c = 'Yes',
            Central_posting_block__c = 'Yes',
            Deletion_Flag_Sales_Area__c = 'Yes',
            Screened_for_SDI__c = 'Yes',
            Deletion_Block_Company_Code__c = 'Yes',
            Deletion_Flag_Company_Code__c = 'Yes',
            Indicator_Record_Payment_History__c = 'Yes',
            Posting_Block_Company_Code__c = 'Yes',
            BillCurrency_PY__c = 'CNY - Chinese Renmimbi',
            Sales_Rep_ZS__c = 'US727 - AARON HOUT',
           // Controller_Approver_Group__c = 'AP - South Asia-Pacific', //Line added by Nisha Agrawal for SFDC-477
            Version_ID_for_International_Addresses__c = 'C',
            Tax_Number_5__c = 'Test Tax Number 5'
        );
        insert testRequest;
      ApexPages.StandardController theStandardController 
            = new ApexPages.standardController(testRequest);
        CMD_Request_Controller_SAP_Extension theControllerExt 
            = new CMD_Request_Controller_SAP_Extension( theStandardController );
        theControllerExt.theAccountGroup = 'Z013';
//        theControllerExt.theCMD.HUB_Customer__c = 'a1ND0000001vB7GMAU';    
        theControllerExt.New_SAP_CMD();  
        Test.stopTest();
    }

   // @isTest(SeeAllData=true) 
   @isTest
    static void theZ013SPTest(){
        fetchRecordTypes();
        prepareTestCustomer();
        prepareConsolidatedAccountCode();
        insertFunloc();
        Test.startTest();
        testRequest = new CMD_Request__c(
            Account_Group__c = 'Z013 - Payer / Bill To',
            RecordTypeId = newSAPrtId,
            Ready_to_Submit__c = true,
            Request_Status__c = 'Ready to Submit',
            Business_Background_Comments__c = 'Test Business Background Comments',
            Global_Account__c = 'ACI - ACiG',
            Sales_Organisation__c = 'CN62 - MSO China',
/*STAN needs to enhance*/           //Consolidated_Account_Code__c = 'a1rD0000007BKFfIAO',
/*Modified by Scarlett*/            Consolidated_Account_Code__c = testCACC.Id,
//            SP_GID__c = testCustomer.Name,
            SP_CustomerID__c = testCustomer.Id,
            SP_GID__c = '100000000',
//            SP_CustomerID__c = 'a1ND0000001vB7GMAU',
            SP_Name__c = 'Test Name',
            SP_Street__c = 'Test Street',
            SP_City__c = 'Test City',
            SP_Country__c = 'Netherlands',
            SP_Postal_Code__c = '12345',
            Region__c = 'EU - Europe',
            SP_Telephone__c = '+1234567890',
            SP_Fax__c = '+1234567890',
            SP_Email__c = 'test@test.com',
            SP_Funloc__c = '100000',
            SP_Funloc_Id__c = funLocId,
            PY_Same_as_SP__c = true,
            Company_Code__c = 'CN62 - MSO China',
            Label_required__c = 'No',
            Industry_Segment__c = 'CC - Computing',
            Industry_Sub_Segment__c = 'C1 - Computing',
            Customer_Factory_Calendar__c = '11 - Ship to Algeria',
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
            Sales_Office__c = 'BOS1 - Bosch',
            S_O_Sub_Group__c = 'CN - China',
            Reconciliation_Account__c = '1200100 - Trade AR with foreign parties',
            No_of_days_for_Early_Shipment__c=50,
            Order_combination__c='Yes',
            Central_deletion_block__c= 'Yes',
            Central_deletion_Flag__c = 'Yes',
            Central_posting_block__c = 'Yes',
            Deletion_Flag_Sales_Area__c = 'Yes',
            Screened_for_SDI__c = 'Yes',
            Deletion_Block_Company_Code__c = 'Yes',
            Deletion_Flag_Company_Code__c = 'Yes',
            Indicator_Record_Payment_History__c = 'Yes',
            Posting_Block_Company_Code__c = 'Yes',
            BillCurrency_PY__c = 'CNY - Chinese Renmimbi',
            Sales_Rep_ZS__c = 'US727 - AARON HOUT',
           // Controller_Approver_Group__c = 'AP - South Asia-Pacific', //Line added by Nisha Agrawal for SFDC-477
            Version_ID_for_International_Addresses__c = 'C',
            Tax_Number_5__c = 'Test Tax Number 5'
        );
        insert testRequest;

        ApexPages.StandardController theStandardController 
            = new ApexPages.standardController(testRequest);
        CMD_Request_Controller_SAP_Extension theControllerExt 
            = new CMD_Request_Controller_SAP_Extension( theStandardController );
        theControllerExt.theAccountGroup = 'Z013';
//        theControllerExt.theCMD.HUB_Customer__c = 'a1ND0000001vB7GMAU';    
        theControllerExt.New_SAP_CMD();  
        Test.stopTest();
    }  
    
    /***1604 Release - SIR 706, Added by Scarlett - START***/
    //ZORG not same as Ship-to
    //@isTest(seeAllData = TRUE)
    @isTest
    static void theZORGtest1(){
        fetchRecordTypes();
        prepareTestCustomer();
        prepareConsolidatedAccountCode();
        insertFunloc();
        Test.startTest();
        testRequest = new CMD_Request__c(
            ZORG_Same_as_SH__c = FALSE,
            Account_Group__c = 'ZORG',
            RecordTypeId = newSAPrtId,
            Ready_to_Submit__c = true,
            Request_Status__c = 'Ready to Submit',
            Business_Background_Comments__c = 'Test Business Background Comments',
           Global_Account__c = 'ACI - ACiG',
            Sales_Organisation__c = 'CN62 - MSO China',
            Consolidated_Account_Code__c = testCACC.Id,
            SP_CustomerID__c = testCustomer.Id,
            SP_GID__c = '100000000',
            //SP_CustomerID__c = 'a1ND0000001vB7GMAU',
            SP_Name__c = 'Test Name',
            SP_Street__c = 'Test Street',
            SP_City__c = 'Test City',
            SP_Country__c = 'Netherlands',
            SP_Postal_Code__c = '12345',
           Region__c = 'EU - Europe',
            SP_Telephone__c = '+1234567890',
            SP_Fax__c = '+1234567890',
            SP_Email__c = 'test@test.com',
            SP_Funloc__c = '100000',
            SP_Funloc_Id__c = funLocId,
            Company_Code__c = 'CN62 - MSO China',
            Label_required__c = 'No',
            Industry_Segment__c = 'CC - Computing',
            Industry_Sub_Segment__c = 'C1 - Computing',
            Customer_Factory_Calendar__c = '11 - Ship to Algeria',
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
            Sales_Office__c = 'BOS1 - Bosch',
            S_O_Sub_Group__c = 'CN - China',
            Reconciliation_Account__c = '1200100 - Trade AR with foreign parties',
            No_of_days_for_Early_Shipment__c=50,
            Order_combination__c='Yes',
            
            //GSM_Controller_Approver_Group__c = 'GC'  //commented by Nisha Agrawal on Apr 26 for SFDC-430
            Controller_Approver_Group__c = 'GC - Greater China', //added by Nisha Agrawal on Apr 26 for SFDC-430
            Additional_Shipping_Mark__c = 'Test',
            Additional_VAT_Number_1__c = '12345',
            Additional_VAT_Number_2__c = '12345',
            Additional_VAT_Number_3__c = '12345',
            Additional_VAT_Number_4__c = '12345',
            Additional_VAT_Number_5__c = '12345',
            Additional_VAT_Number_6__c = '12345',
            Additional_VAT_Number_7__c = '12345',
            Additional_VAT_Number_8__c = '12345',
            
            Billing_Block__c = 'Test',
            Brazil_Specific_Clause__c = 'Test',
            Central_Billing_Block__c = 'Test',
            //Central_deletion_block__c = true,
            //Central_Deletion_Flag__c = 'Yes',
            Central_delivery_block__c = 'Test',
            Central_order_block__c = 'Test',
            //Central_posting_block__c = 'Yes',
            ZORG_City__c = 'Test',
            City_Chinese__c = 'Test',
            Controlled_Party__c = 'Yes',
            ZORG_Country__c = 'USA',
            ZORG_State__c = 'Delaware',
            Country_Additional_VAT_Number_1__c = 'China',
            Country_Additional_VAT_Number_2__c = 'Canada',
            Country_Additional_VAT_Number_3__c = 'Colombia',
            Country_Additional_VAT_Number_4__c = 'Congo',
            Country_Additional_VAT_Number_5__c = 'Congo',
            Country_Additional_VAT_Number_6__c = 'France',
            Country_Additional_VAT_Number_7__c = 'Fiji',
            Country_Additional_VAT_Number_8__c = 'Fiji',
            CPNJ_for_Brazil__c = '12345',
            Customer_Statistics_Group__c = '1',
            //Deletion_Block_Company_Code__c = 'Yes',
            //Deletion_Flag_Company_Code__c = 'Yes',
            //Deletion_Flag_Sales_Area__c = 'Yes',
            Delivery_Block__c = '12345',
            Delivery_Group_Ind_SH__c = '01 - Sh per single line',
            Delivery_priority__c = '10 - Priority 1',
            Distribution_Channel__c = '12345',
            Distribution_Region__c = 'A1 - HK00',
            Division__c = '12345',
            ZORG_Email__c = 'test@test.com',
            Exch_rate_type__c = '4DEC - NXP Act. Rate',
            Freight_Forwarder__c = '12345',
            FunLoc_Type__c = 'Pure',
            Grp_2_Cus_Prce_Grp_SP__c = '018 - Bosch USD',
          
            Language__c = 'E - English',
            ZORG_Name__c  = 'Test',
            Main_shipping_mark__c  = 'Test',
            Matl_Det_Grp_SP__c = 'ABB - ABB',
            Max_partial_deliveries__c = '1',
            Military_Usage__c = 'Yes - ID for mainly military use',
            Chinese_Name1__c = 'Test',
            ZORG_Name_Line_2__c = 'Test',
            Chinese_Name2__c = 'Test',
            ZORG_Name_Line_3__c = 'Test',
            ZORG_Name_Line_4__c = 'Test',
            Non_I2_related_SP_ZORG__c = 'Yes',
            Order_Block__c = 'Test',
            Order_Combination_ZORG__c = 'Yes',
            Partial_delivery_per_item__c = 'C - Only complete delivery allowed',
            Payment_Guarantee_Procedure__c = 'Z001 - No guarantee required ',
            //Posting_Block_Company_Code__c = 'Yes',
            Sales_Area_Region__c = 'EU - Europe',
            Screened_for_SDI__c = 'Yes',
            Shipping_Condition__c = '01 - Ship via Std Route',
           
            Chinese_Street__c = 'Test',
            ZORG_Street__c = 'Test',
            Taxes_Number_1__c = 'Test',
            ZORG_Telephone__c = 'Test',
            Trading_Partner__c = '116178 - RSO Europe',
          //  Transportation_Zone_ZORG__c = 'Test',
            Unloading_Point__c = 'Test',
            VAT_Registration_Number__c = 'Test',
            ZORG_Postal_Code__c = 'Test',
            Central_deletion_block__c= 'Yes',
            Central_deletion_Flag__c = 'Yes',
            Central_posting_block__c = 'Yes',
            Deletion_Flag_Sales_Area__c = 'Yes',
            Deletion_Block_Company_Code__c = 'Yes',
            Deletion_Flag_Company_Code__c = 'Yes',
            Indicator_Record_Payment_History__c = 'Yes',
            Posting_Block_Company_Code__c = 'Yes',
            Version_ID_for_International_Addresses__c = 'C'
        );
        insert testRequest;

        ApexPages.StandardController theStandardController 
            = new ApexPages.standardController(testRequest);
        CMD_Request_Controller_SAP_Extension theControllerExt 
            = new CMD_Request_Controller_SAP_Extension( theStandardController );
        theControllerExt.theAccountGroup = 'ZORG'; 
        theControllerExt.New_SAP_CMD();   
        Test.stopTest();
    }
    
    //ZORG same as Ship-to, SH same as SP
    //@isTest(seeAllData = TRUE)
    @isTest
    static void theZORGtest2(){
        fetchRecordTypes();
        prepareTestCustomer();
        createSalesOrgCustomSetting();
        prepareConsolidatedAccountCode();
        insertFunloc();
        createTestUser();
        Test.startTest();
        testRequest = new CMD_Request__c(
            ZORG_Same_as_SH__c = true,
            SH_Same_as_SP__c = true,
            Account_Group__c = 'ZORG',
            RecordTypeId = newSAPrtId,
            Ready_to_Submit__c = true,
            Request_Status__c = 'Ready to Submit',
            Business_Background_Comments__c = 'Test Business Background Comments',
           Global_Account__c = 'ACI - ACiG',
            Sales_Organisation__c = 'CN62 - MSO China',
            Consolidated_Account_Code__c = testCACC.Id,
            SP_CustomerID__c = testCustomer.Id,
            SP_GID__c = '100000000',
            //SP_CustomerID__c = 'a1ND0000001vB7GMAU',
            SP_Name__c = 'Test Name',
            SP_Street__c = 'Test Street',
            SP_City__c = 'Test City',
            SP_Country__c = 'Netherlands',
            SP_Postal_Code__c = '12345',
           Region__c = 'EU - Europe',
            SP_Telephone__c = '+1234567890',
            SP_Fax__c = '+1234567890',
            SP_Email__c = 'test@test.com',
            SP_Funloc__c = '100000',
            SP_Funloc_Id__c = funLocId,
            Company_Code__c = 'CN62 - MSO China',
            Label_required__c = 'No',
            Industry_Segment__c = 'CC - Computing',
            Industry_Sub_Segment__c = 'C1 - Computing',
            Customer_Factory_Calendar__c = '11 - Ship to Algeria',
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
            Sales_Office__c = 'BOS1 - Bosch',
            S_O_Sub_Group__c = 'CN - China',
            Reconciliation_Account__c = '1200100 - Trade AR with foreign parties',
            No_of_days_for_Early_Shipment__c=50,
            Order_combination__c='Yes',
            
            //GSM_Controller_Approver_Group__c = 'GC'  //commented by Nisha Agrawal on Apr 26 for SFDC-430
            Controller_Approver_Group__c = 'GC - Greater China', //added by Nisha Agrawal on Apr 26 for SFDC-430
            Additional_Shipping_Mark__c = 'Test',
            Additional_VAT_Number_1__c = '12345',
            Additional_VAT_Number_2__c = '12345',
            Additional_VAT_Number_3__c = '12345',
            Additional_VAT_Number_4__c = '12345',
            Additional_VAT_Number_5__c = '12345',
            Additional_VAT_Number_6__c = '12345',
            Additional_VAT_Number_7__c = '12345',
            Additional_VAT_Number_8__c = '12345',
            
            Billing_Block__c = 'Test',
            Brazil_Specific_Clause__c = 'Test',
            Central_Billing_Block__c = 'Test',
            //Central_deletion_block__c = true,
            //Central_Deletion_Flag__c = 'Yes',
            Central_delivery_block__c = 'Test',
            Central_order_block__c = 'Test',
            //Central_posting_block__c = 'Yes',
           // ZORG_City__c = 'Test',
            City_Chinese__c = 'Test',
            Controlled_Party__c = 'Yes',
           //  ZORG_Country__c = 'USA',
         //   ZORG_State__c = 'Delaware',
            Country_Additional_VAT_Number_1__c = 'China',
            Country_Additional_VAT_Number_2__c = 'Canada',
            Country_Additional_VAT_Number_3__c = 'Colombia',
            Country_Additional_VAT_Number_4__c = 'Congo',
            Country_Additional_VAT_Number_5__c = 'Congo',
            Country_Additional_VAT_Number_6__c = 'France',
            Country_Additional_VAT_Number_7__c = 'Fiji',
            Country_Additional_VAT_Number_8__c = 'Fiji',
            CPNJ_for_Brazil__c = '12345',
            Customer_Statistics_Group__c = '1',
            //Deletion_Block_Company_Code__c = 'Yes',
            //Deletion_Flag_Company_Code__c = 'Yes',
            //Deletion_Flag_Sales_Area__c = 'Yes',
            Delivery_Block__c = '12345',
            Delivery_Group_Ind_SH__c = '01 - Sh per single line',
            Delivery_priority__c = '10 - Priority 1',
            Distribution_Channel__c = '12345',
            Distribution_Region__c = 'A1 - HK00',
            Division__c = '12345',
          //  ZORG_Email__c = 'test@test.com',
            Exch_rate_type__c = '4DEC - NXP Act. Rate',
            Freight_Forwarder__c = '12345',
            FunLoc_Type__c = 'Pure',
            Grp_2_Cus_Prce_Grp_SP__c = '018 - Bosch USD',
          
            Language__c = 'E - English',
            //ZORG_Name__c  = 'Test',
            Main_shipping_mark__c  = 'Test',
            Matl_Det_Grp_SP__c = 'ABB - ABB',
            Max_partial_deliveries__c = '0',
            Military_Usage__c = 'Yes - ID for mainly military use',
            Chinese_Name1__c = 'Test',
            //ZORG_Name_Line_2__c = 'Test',
            Chinese_Name2__c = 'Test',
            //ZORG_Name_Line_3__c = 'Test',
            //ZORG_Name_Line_4__c = 'Test',
            Non_I2_related_SP_ZORG__c = 'Yes',
            Order_Block__c = 'Test',
            Order_Combination_ZORG__c = 'Yes',
            Partial_delivery_per_item__c = 'C - Only complete delivery allowed',
            Payment_Guarantee_Procedure__c = 'Z001 - No guarantee required',
            //Posting_Block_Company_Code__c = 'Yes',
            Sales_Area_Region__c = 'EU - Europe',
            Screened_for_SDI__c = 'Yes',
            Shipping_Condition__c = '01 - Ship via Std Route',
            
            Chinese_Street__c = 'Test',
            //ZORG_Street__c = 'Test',
            Taxes_Number_1__c = 'Test',
            //ZORG_Telephone__c = 'Test',
            Trading_Partner__c = '116178 - RSO Europe',
          //  Transportation_Zone_ZORG__c = 'Test',
            Unloading_Point__c = 'Test',
            VAT_Registration_Number__c = 'Test',
            //ZORG_Postal_Code__c = 'Test',
            Central_deletion_block__c= 'Yes',
            Central_deletion_Flag__c = 'Yes',
            Central_posting_block__c = 'Yes',
            Deletion_Flag_Sales_Area__c = 'Yes',
            Deletion_Block_Company_Code__c = 'Yes',
            Deletion_Flag_Company_Code__c = 'Yes',
            Indicator_Record_Payment_History__c = 'Yes',
            Posting_Block_Company_Code__c = 'Yes',
            Version_ID_for_International_Addresses__c = 'M'
        );
        insert testRequest;
        cmd_request__c objCMD = [select id,name,request_status__c from cmd_request__c where id=:testrequest.id];
       objCMD.request_status__c = 'Pending for Approval';
       update objCMD;
        
       user testuser = [select id,name from user where email='tes26t2@testorg.com']; 
       system.runas(testuser){ 
       cmd_request__c objCMDReq = [select id,name,request_status__c from cmd_request__c where id=:testrequest.id];
        testTaxClassification = new Tax_Classification__c(
            CMD_Request__c = objCMDReq.Id,
            Country__c = 'ES - Spain', 
            Tax_Category__c = 'MWST', 
            Tax_Classification__c = '1'
        );
        insert testTaxClassification;
       }
        ApexPages.StandardController theStandardController 
            = new ApexPages.standardController(testRequest);
        CMD_Request_Controller_SAP_Extension theControllerExt 
            = new CMD_Request_Controller_SAP_Extension( theStandardController );
        theControllerExt.theAccountGroup = 'ZORG'; 
        theControllerExt.New_SAP_CMD(); 
        Test.stopTest();
    }
    //ZORG same as Ship-to, SH not same as SP
    //@isTest(seeAllData = TRUE)
    @isTest
    static void theZORGtest3(){
        fetchRecordTypes();
        prepareTestCustomer();
        prepareConsolidatedAccountCode();
        insertFunloc();
        Test.startTest();
        testRequest = new CMD_Request__c(
            ZORG_Same_as_SH__c = TRUE,
           //  ZORG_Same_as_SH__c = FALSE,
            SH_Same_as_SP__c = FALSE,
            Account_Group__c = 'ZORG',
            RecordTypeId = newSAPrtId,
            Ready_to_Submit__c = true,
            Request_Status__c = 'Ready to Submit',
            Business_Background_Comments__c = 'Test Business Background Comments',
            Global_Account__c = 'ACI - ACiG',
            Sales_Organisation__c = 'CN62 - MSO China',
            Consolidated_Account_Code__c = testCACC.Id,
            SP_CustomerID__c = testCustomer.Id,
            SP_GID__c = '100000000',
            //SP_CustomerID__c = 'a1ND0000001vB7GMAU',
             SH_Name__c = 'Test Name',
            SH_Street__c = 'Test Street',
            SH_City__c = 'Test City',
            SH_Country__c = 'Netherlands',
            SH_Postal_Code__c = '12345',
            SH_Region__c = 'EU - EMEA',
            SH_Telephone__c = '+1234567890',
            SH_Fax__c = '+1234567890',
            SH_Email__c = 'test@test.com',
            SH_Funloc__c = '100000',
            SH_Funloc_Id__c = funLocId,
            SP_Name__c = 'Test Name',
            SP_Street__c = 'Test Street',
            SP_City__c = 'Test City',
            SP_Country__c = 'Netherlands',
            SP_Postal_Code__c = '12345',
           Region__c = 'EU - Europe',
            SP_Telephone__c = '+1234567890',
            SP_Fax__c = '+1234567890',
            SP_Email__c = 'test@test.com',
            SP_Funloc__c = '100000',
           // SP_Funloc_Id__c = funLocId,
            Company_Code__c = 'CN62 - MSO China',
            Label_required__c = 'No',
            Industry_Segment__c = 'CC - Computing',
            Industry_Sub_Segment__c = 'C1 - Computing',
            Customer_Factory_Calendar__c = '11 - Ship to Algeria',
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
            Sales_Office__c = 'BOS1 - Bosch',
            S_O_Sub_Group__c = 'CN - China',
            Reconciliation_Account__c = '1200100 - Trade AR with foreign parties',
            No_of_days_for_Early_Shipment__c=50,
            Order_combination__c='Yes',
            
            //GSM_Controller_Approver_Group__c = 'GC'  //commented by Nisha Agrawal on Apr 26 for SFDC-430
            Controller_Approver_Group__c = 'GC - Greater China', //added by Nisha Agrawal on Apr 26 for SFDC-430
            Additional_Shipping_Mark__c = 'Test',
            Additional_VAT_Number_1__c = '12345',
            Additional_VAT_Number_2__c = '12345',
            Additional_VAT_Number_3__c = '12345',
            Additional_VAT_Number_4__c = '12345',
            Additional_VAT_Number_5__c = '12345',
            Additional_VAT_Number_6__c = '12345',
            Additional_VAT_Number_7__c = '12345',
            Additional_VAT_Number_8__c = '12345',
            
            Billing_Block__c = 'Test',
            Brazil_Specific_Clause__c = 'Test',
            Central_Billing_Block__c = 'Test',
            //Central_deletion_block__c = true,
            //Central_Deletion_Flag__c = 'Yes',
            Central_delivery_block__c = 'Test',
            Central_order_block__c = 'Test',
            //Central_posting_block__c = 'Yes',
         //   ZORG_City__c = 'Test',
           // City_Chinese__c = 'Test',
            Controlled_Party__c = 'Yes',
            //ZORG_Country__c = 'USA',
            //ZORG_State__c = 'Delaware',
            Country_Additional_VAT_Number_1__c = 'China',
            Country_Additional_VAT_Number_2__c = 'Canada',
            Country_Additional_VAT_Number_3__c = 'Colombia',
            Country_Additional_VAT_Number_4__c = 'Congo',
            Country_Additional_VAT_Number_5__c = 'Congo',
            Country_Additional_VAT_Number_6__c = 'France',
            Country_Additional_VAT_Number_7__c = 'Fiji',
            Country_Additional_VAT_Number_8__c = 'Fiji',
            CPNJ_for_Brazil__c = '12345',
            Customer_Statistics_Group__c = '1',
            //Deletion_Block_Company_Code__c = 'Yes',
            //Deletion_Flag_Company_Code__c = 'Yes',
            //Deletion_Flag_Sales_Area__c = 'Yes',
            Delivery_Block__c = '12345',
            Delivery_Group_Ind_SH__c = '01 - Sh per single line',
            Delivery_priority__c = '10 - Priority 1',
            Distribution_Channel__c = '12345',
            Distribution_Region__c = 'A1 - HK00',
            Division__c = '12345',
          //  ZORG_Email__c = 'test@test.com',
            Exch_rate_type__c = '4DEC - NXP Act. Rate',
            Freight_Forwarder__c = '12345',
            FunLoc_Type__c = 'Pure',
            Grp_2_Cus_Prce_Grp_SP__c = '018 - Bosch USD',
          
            Language__c = 'E - English',
         //   ZORG_Name__c  = 'Test',
            Main_shipping_mark__c  = 'Test',
            Matl_Det_Grp_SP__c = 'ABB - ABB',
            Max_partial_deliveries__c = '1',
            Military_Usage__c = 'Yes - ID for mainly military use',
            Chinese_Name1__c = 'Test',
            //ZORG_Name_Line_2__c = 'Test',
            Chinese_Name2__c = 'Test',
         //   ZORG_Name_Line_3__c = 'Test',
           // ZORG_Name_Line_4__c = 'Test',
            Non_I2_related_SP_ZORG__c = 'Yes',
            Order_Block__c = 'Test',
            Order_Combination_ZORG__c = 'Yes',
            Partial_delivery_per_item__c = 'C - Only complete delivery allowed',
            Payment_Guarantee_Procedure__c = 'Z001 - No guarantee required',
            //Posting_Block_Company_Code__c = 'Yes',
            Sales_Area_Region__c = 'EU - Europe',
            Screened_for_SDI__c = 'Yes',
            Shipping_Condition__c = '01 - Ship via Std Route',
            
            Chinese_Street__c = 'Test',
            //ZORG_Street__c = 'Test',
            Taxes_Number_1__c = 'Test',
        //    ZORG_Telephone__c = 'Test',
            Trading_Partner__c = '116178 - RSO Europe',
          //  Transportation_Zone_ZORG__c = 'Test',
            Unloading_Point__c = 'Test',
            VAT_Registration_Number__c = 'Test',
          //  ZORG_Postal_Code__c = 'Test',
            Central_deletion_block__c= 'Yes',
            Central_deletion_Flag__c = 'Yes',
            Central_posting_block__c = 'Yes',
            Deletion_Flag_Sales_Area__c = 'Yes',
            Deletion_Block_Company_Code__c = 'Yes',
            Deletion_Flag_Company_Code__c = 'Yes',
            Indicator_Record_Payment_History__c = 'Yes',
            Posting_Block_Company_Code__c = 'Yes',
            Version_ID_for_International_Addresses__c = 'C'
        );
        insert testRequest;

        ApexPages.StandardController theStandardController 
            = new ApexPages.standardController(testRequest);
        CMD_Request_Controller_SAP_Extension theControllerExt 
            = new CMD_Request_Controller_SAP_Extension( theStandardController );
        theControllerExt.theAccountGroup = 'ZORG'; 
        theControllerExt.New_SAP_CMD();
        Test.stopTest();
    }
    /***1604 Release - SIR 706, Added by Scarlett - END***/
    
    static testmethod void theZORGtest4(){
        fetchRecordTypes();
        prepareTestCustomer();
        prepareConsolidatedAccountCode();
        insertFunloc();
        insertFunloc1();
        createSalesOrgCustomSetting();
        Test.startTest();
        testRequest = new CMD_Request__c(
            ZORG_Same_as_SH__c = FALSE,
            Account_Group__c = 'ZORG',
            RecordTypeId = newSAPrtId,
            Ready_to_Submit__c = true,
            Request_Status__c = 'Ready to Submit',
            Business_Background_Comments__c = 'Test Business Background Comments',
            Global_Account__c = 'ACI - ACiG',
            Sales_Organisation__c = 'CN60 - MSO China CN60',
            Consolidated_Account_Code__c = testCACC.Id,
            SP_CustomerID__c = testCustomer.Id,
            SP_GID__c = '100000000',
            //SP_CustomerID__c = 'a1ND0000001vB7GMAU',
            SP_Name__c = 'Test Name',
            SP_Street__c = 'Test Street',
            SP_City__c = 'Test City',
            SP_Country__c = 'Netherlands',
            SP_Postal_Code__c = '12345',
           Region__c = 'EU - Europe',
            SP_Telephone__c = '+1234567890',
            SP_Fax__c = '+1234567890',
            SP_Email__c = 'test@test.com',
            SP_Funloc__c = '440000',
            SP_Funloc_Id__c = funLocId1,
            Company_Code__c = 'CN60 - MSO China (NXP FSL)',
            Label_required__c = 'No',
            Industry_Segment__c = 'CC - Computing',
            Industry_Sub_Segment__c = 'C1 - Computing',
            Customer_Factory_Calendar__c = '11 - Ship to Algeria',
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
            Sales_Office__c = 'CN60 - RSO China CN60',
            S_O_Sub_Group__c = 'CN - China',
            Reconciliation_Account__c = '1200100 - Trade AR with foreign parties',
            No_of_days_for_Early_Shipment__c=50,
            Order_combination__c='Yes',
            
            //GSM_Controller_Approver_Group__c = 'GC'  //commented by Nisha Agrawal on Apr 26 for SFDC-430
            Controller_Approver_Group__c = 'GC - Greater China', //added by Nisha Agrawal on Apr 26 for SFDC-430
            Additional_Shipping_Mark__c = 'Test',
            Additional_VAT_Number_1__c = '12345',
            Additional_VAT_Number_2__c = '12345',
            Additional_VAT_Number_3__c = '12345',
            Additional_VAT_Number_4__c = '12345',
            Additional_VAT_Number_5__c = '12345',
            Additional_VAT_Number_6__c = '12345',
            Additional_VAT_Number_7__c = '12345',
            Additional_VAT_Number_8__c = '12345',
            
            Billing_Block__c = 'Test',
            Brazil_Specific_Clause__c = 'Test',
            Central_Billing_Block__c = 'Test',
            //Central_deletion_block__c = true,
            //Central_Deletion_Flag__c = 'Yes',
            Central_delivery_block__c = 'Test',
            Central_order_block__c = 'Test',
            //Central_posting_block__c = 'Yes',
            ZORG_City__c = 'Test',
            City_Chinese__c = 'Test',
            Controlled_Party__c = 'Yes',
            ZORG_Country__c = 'USA',
            ZORG_State__c = 'Delaware',
            Country_Additional_VAT_Number_1__c = 'China',
            Country_Additional_VAT_Number_2__c = 'Canada',
            Country_Additional_VAT_Number_3__c = 'Colombia',
            Country_Additional_VAT_Number_4__c = 'Congo',
            Country_Additional_VAT_Number_5__c = 'Congo',
            Country_Additional_VAT_Number_6__c = 'France',
            Country_Additional_VAT_Number_7__c = 'Fiji',
            Country_Additional_VAT_Number_8__c = 'Fiji',
            CPNJ_for_Brazil__c = '12345',
            Customer_Statistics_Group__c = '1',
            //Deletion_Block_Company_Code__c = 'Yes',
            //Deletion_Flag_Company_Code__c = 'Yes',
            //Deletion_Flag_Sales_Area__c = 'Yes',
            Delivery_Block__c = '12345',
            Delivery_Group_Ind_SH__c = '01 - Sh per single line',
            Delivery_priority__c = '10 - Priority 1',
            Distribution_Channel__c = '12345',
            Distribution_Region__c = 'A1 - HK00',
            Division__c = '12345',
            ZORG_Email__c = 'test@test.com',
            Exch_rate_type__c = '4DEC - NXP Act. Rate',
            Freight_Forwarder__c = '12345',
            FunLoc_Type__c = 'Pure',
            Grp_2_Cus_Prce_Grp_SP__c = '018 - Bosch USD',
          
            Language__c = 'E - English',
            ZORG_Name__c  = 'Test',
            Main_shipping_mark__c  = 'Test',
            Matl_Det_Grp_SP__c = 'ABB - ABB',
            Max_partial_deliveries__c = '1',
            Military_Usage__c = 'Yes - ID for mainly military use',
            Chinese_Name1__c = 'Test',
            ZORG_Name_Line_2__c = 'Test',
            Chinese_Name2__c = 'Test',
            ZORG_Name_Line_3__c = 'Test',
            ZORG_Name_Line_4__c = 'Test',
            Non_I2_related_SP_ZORG__c = 'Yes',
            Order_Block__c = 'Test',
            Order_Combination_ZORG__c = 'Yes',
            Partial_delivery_per_item__c = 'C - Only complete delivery allowed',
            Payment_Guarantee_Procedure__c = 'Z001 - No guarantee required ',
            //Posting_Block_Company_Code__c = 'Yes',
            Sales_Area_Region__c = 'EU - Europe',
            Screened_for_SDI__c = 'Yes',
            Shipping_Condition__c = '01 - Ship via Std Route',
           
            Chinese_Street__c = 'Test',
            ZORG_Street__c = 'Test',
            Taxes_Number_1__c = 'Test',
            ZORG_Telephone__c = 'Test',
            Trading_Partner__c = '116178 - RSO Europe',
            Transportation_Zone_ZORG__c = 'Test',
            Unloading_Point__c = 'Test',
            VAT_Registration_Number__c = 'Test',
            ZORG_Postal_Code__c = 'Test',
            Central_deletion_block__c= 'Yes',
            Central_deletion_Flag__c = 'Yes',
            Central_posting_block__c = 'Yes',
            Deletion_Flag_Sales_Area__c = 'Yes',
            Deletion_Block_Company_Code__c = 'Yes',
            Deletion_Flag_Company_Code__c = 'Yes',
            Indicator_Record_Payment_History__c = 'Yes',
            Posting_Block_Company_Code__c = 'Yes',
            Version_ID_for_International_Addresses__c = 'C'
        );
        insert testRequest;

        ApexPages.StandardController theStandardController = new ApexPages.standardController(testRequest);
        CMD_Request_Controller_SAP_Extension theControllerExt = new CMD_Request_Controller_SAP_Extension( theStandardController );
        theControllerExt.theAccountGroup = 'ZORG'; 
        theControllerExt.New_SAP_CMD();   
        Test.stopTest();
    }
}