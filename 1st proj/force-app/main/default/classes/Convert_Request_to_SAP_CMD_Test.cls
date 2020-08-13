/***************************************************************************************************************************
@Modified By :       Scarlett Kang
@Modified Date:    20 Mar 2015
@Description:      Change the field type of SAP_CMD__c.Industry_Segment__c to formula
---------------------------------------------------------------------------------------------------------------------------
@Modified By :       Scarlett Kang
@Modified Date:    02 Oct 2015
@Description:      1510 Release - SIR 404. SAP CMD - ZA & ZS change - from manual to auto (for edit funloc request), 
                    enhance code coverage
-------------------------------------------------------------------------------------------------------------------------------------------
@Modified By :       Scarlett Kang
@Modified Date:    May 30 2016
@Description:      1606 Release - SIR 292, [IMO]Divide CACC "Industry Segment" to "CBG" and "SUB-CBG", 
           SAP_CMD__c.Industry_Sub_Segment__c is going to be formula field
-------------------------------------------------------------------------------
@Modified By :       Baji
@Modified Date:      Aug 31, 2016 
@Description:        1609 Release SIR 1102 & 990 & 1138 - commented/uncommented the code to change CMD Request's field data-type.
---------------------------------------------------------------------------------
@Modified By :       Nisha Agrawal
@Modified Date:      Apr 26, 2017 
@Description:        SFDC-430 - Replace GSM COntroller Approver Group picklist to new multiselect picklist Controller Approver Group
----------------------------------------------------------------------------------------------------------------------
@Modified By :       Baji
@Modified Date:      27 Jun 2017
@Description:        1707 Release (SFDC 585) -  To test new fields 'Version ID for internationla addresses' & 'Tax Number 5' for MSO China project
                     Improved code coverage from 93% - 98%
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
@Modified By :       Baji
@Modified Date:      17 Jul 2017 
@Description:        1708 Release (SFDC 684) - SAP CMD - BillCurrency-PY should be on SAP CMD layout
***************************************************************************************************************************/
@isTest
public class Convert_Request_to_SAP_CMD_Test {
    private RecordType newSfdcParentAccount;
    public string newSfdcParentAccountRTId;
    
    private static final String TYPE_Global_Enterprise = 'Global_Enterprise';//ojb: Customer
    private static final String TYPE_Z001_SOLDTO_SHIPTO_BILLTO_PAYER = 'Z001_SoldTo_ShipTo_BillTo_Payer';// obj: SAP CMD
    private static final String TYPE_Z002_Ship_To = 'Z002_Ship_To';// obj: SAP CMD
    private static final String TYPE_Z010_Intermediate_Consignee = 'Z010_Intermediate_Consignee';// obj: SAP CMD
    private static final String TYPE_New_SFDC_Parent_Account = 'New_SFDC_Parent_Account';// obj: CMD Request
    private static final String TYPE_Parent_Account = 'Parent_Account';//obj: Account
    private static final String TYPE_Child_Account = 'Child_Account';//obj: Account
    private static final String TYPE_Country_and_Region = 'Country_and_Region';//obj: Hub Foundation
    private static final String TYPE_SAP_New_Funloc_Request = 'SAP_New_Funloc_Request';// obj: CMD Request
    private static final String TYPE_SAP_Funloc_Edit_Request = 'SAP_Funloc_Edit_Request';// obj: CMD Request
    private static final String TYPE_ZA_ZS = 'ZA_ZS';// obj: Partner Function
    
    private static RecordType Global_Enterprise;
    private static RecordType Z001_SoldTo_ShipTo_BillTo_Payer;
    private static RecordType New_SFDC_Parent_Account;
    private static RecordType SAP_New_Funloc_Request;
    private static RecordType SAP_Funloc_Edit_Request;
    private static RecordType Parent_Account;
    private static RecordType Child_Account;
    private static RecordType Country_and_Region;
    private static RecordType Z002_Ship_To;
    private static RecordType Z010_Intermediate_Consignee;
    private static RecordType ZA_ZS;
      
    private static List<Customer__c> lstCustomer;
    private static Customer__c objCustomer;
    //private static List<Hub_Foundation__C> lstHubFoundation;
    private static Hub_Foundation__c objHubFoundation;
    private static List<SAP_CMD__c> lstSAPCMD;
    private static SAP_CMD__c objSAPCMD;
    private static Tax_Classification__c objSAPTax;
    private static Tax_Classification__c objSAPCMDTax;
    private static Tax_Classification__c objCMDTax;
    private static Tax_Classification__c objTax;
    private static Account objParentAccount;
    private static Account objChildAccount;
    private static Funloc__c objFunloc;
    private static List<Funloc__c> lstFunloc;
    private static Consolidated_Account_Code__c objCACC;
    private static List<Partner_Function__c> lstPartnerFunction;
    private static Tax_Classification__c objCMDTaxes;
    private static List<Partner_Function__c> lstPartnerFuncDelete;
    
    private static String TYPE_System_Admin = 'System Administrator';
    private static String TYPE_CMD_Officer = 'NXP CMD Officer';
    private static String TYPE_Standard_User = 'TS Standard User - API Enabled';
    
    private static Profile System_Administrator;
    private static Profile NXP_CMD_Officer;
    private static profile TS_Standard_User;
    public static list<User> listUser=new list<user>();
    public static final String TEST_USER_EMAIL_0 = 'testuser@testorg.com.test';
    public static final String TEST_USER_EMAIL_1 = 'testcmdofficeruser@testorg.com.test';
    public static final String TEST_USER_EMAIL_2 = 'teststduser@testorg.com.test';
    
    private static void fetchRecordType(){
        for(RecordType rt : [SELECT Id, DeveloperName
                             FROM   RecordType
                             WHERE  IsActive = TRUE 
                             AND ((SobjectType = 'Customer__c' AND DeveloperName =: TYPE_Global_Enterprise)
                                 OR (SobjectType = 'SAP_CMD__c' AND DeveloperName =: TYPE_Z001_SOLDTO_SHIPTO_BILLTO_PAYER)
                                 OR (SobjectType = 'SAP_CMD__c' AND DeveloperName =: TYPE_Z002_Ship_To)
                                 OR (SobjectType = 'SAP_CMD__c' AND DeveloperName =: TYPE_Z010_Intermediate_Consignee)
                                 OR (SobjectType = 'Account' and DeveloperName =: TYPE_Parent_Account)
                                 OR (SobjectType = 'Account' and DeveloperName =: TYPE_Child_Account)
                                 OR (SobjectType = 'CMD_Request__c' and DeveloperName =: TYPE_New_SFDC_Parent_Account)
                                 OR (SobjectType = 'CMD_Request__c' and DeveloperName =: TYPE_SAP_New_Funloc_Request)
                                 OR (SobjectType = 'CMD_Request__c' and DeveloperName =: TYPE_SAP_Funloc_Edit_Request)
                                 OR (SobjectType = 'Hub_Foundation__c' and DeveloperName =: TYPE_Country_and_Region )
                                 OR (SobjectType = 'Partner_Function__c' and DeveloperName =: TYPE_ZA_ZS))
                              ])
        {
            if(rt.DeveloperName == TYPE_Global_Enterprise)
                Global_Enterprise = rt;
            if(rt.DeveloperName == TYPE_Z001_SOLDTO_SHIPTO_BILLTO_PAYER)
                Z001_SoldTo_ShipTo_BillTo_Payer = rt;
            if(rt.DeveloperName == TYPE_Z002_Ship_To) 
                Z002_Ship_To = rt;
            if(rt.DeveloperName == TYPE_Z010_Intermediate_Consignee)
                Z010_Intermediate_Consignee = rt;
            if(rt.DeveloperName == TYPE_New_SFDC_Parent_Account)
                New_SFDC_Parent_Account = rt;
            if(rt.DeveloperName == TYPE_Parent_Account)
                Parent_Account = rt;            
            if(rt.DeveloperName == TYPE_Child_Account)
                Child_Account = rt;
            if(rt.DeveloperName == TYPE_SAP_New_Funloc_Request)
                SAP_New_Funloc_Request = rt;    
            if(rt.DeveloperName == TYPE_SAP_Funloc_Edit_Request)
                SAP_Funloc_Edit_Request = rt; 
            if(rt.DeveloperName == TYPE_Country_and_Region)
                Country_and_Region = rt; 
            if(rt.DeveloperName == TYPE_ZA_ZS)
                ZA_ZS = rt; 
        }
    }
    
  /*  public static testMethod void fetchUserProifleId(){
    CMD_Request_Taxes_Trigger.fetchUserProifleId();
     }
    
    */
        
    private static void createCustomer()
    {
        lstCustomer = new List<Customer__c>();
        for(integer i=0; i < 10; i++)
        {
            objCustomer = new Customer__c(RecordTypeId = Global_Enterprise.Id, Account_Name__c = 'ut_Global_Enterprise ' + i ,
                                          Legal_Name__c = 'ut_Global_Enterprise ' + i , DUNS__c = 'ut_123'+ i , 
                                          Status__c = 'Active' ,  DNB_Verified__c = 'DNB Accepted' ,
                                          House_Number__c = 'ut'+ i , Street__c = 'ut_street_1' + i ,
                                          Zip__c = 'ut_zip' + i , City__c = 'ut_city' + i, Country__c = 'USA' ,  
                                          Industry_Segment__c = 'CC - Computing' ,
                                          Type__c = 'Service Provider' , Role__c = 'OEM',GSM_Classification__c = 'Internal',
                                          Fulfillment_Channel__c = 'Disti',  Street_2__c = 'ut_street_2' + i ,
                                          Street_3__c = 'ut_street_3' + i ,State__c = 'Nevada' + i,Industry_Sub_Segment__c = 'C1 - Computing',
                                          SIC_Code__c = 't' + i, NAICS_Code__c = 'ut_' + i, 
                                          Website__c = 'http://www.test.com', EMail__c  = 'test.test@test.com',
                                          Fax__c = '+1234567890', Telephone__c = '+1234567890');
            lstCustomer.add(objCustomer);                        
         }                                         
         insert lstCustomer;
    }
    
    private static void createHubFundation(){
        objHubFoundation= new Hub_Foundation__c(
            RecordTypeId = Country_and_Region.Id,
            Alpha_2_Code__c =  'AE',
            Region__c = 'EU - EMEA',
            Country__c = 'USA',
            Alpha_3_Code__c = 'ARE'
        );

        insert objHubFoundation;
    }
    
    /*
    private static void createParentAccount(){
        objParentAccount = new Account(
            RecordTypeId = Parent_Account.Id,
            Customer_Category__c = 'Key',
            Name ='Unit Test Parent Account', 
            Status_of_D_B_Cleansing__c = 'D&B Data Accepted' , 
            D_B_Account_Name__c = 'DB Name' , 
            D_B_Street__c = 'DB Street' , 
            D_B_State_Province__c = 'DB State' , 
            D_B_City__c = 'DB City' , 
            D_B_Country__c = 'DB Country' , 
            D_B_ZIP_Postal_Code__c = 'DB Zip' , 
            D_B_SIC_Code__c = 'DB Sic' , 
            D_B_SIC_Code_Description__c = 'DB Sic Desc' 
        );
        insert objParentAccount;    
    }
    */
    
    private static void createFunloc(){
        lstFunloc = new List<Funloc__c>();
        
        for(integer i = 0 ; i < 10 ; i++){
            Funloc__c objFonloc = new Funloc__c(
                Name__c = 'Test Convert' + i,
                Call_Name__c = 'Test Convert',
                Street_Name__c = 'Test Convert',
                Place_Name__c = 'Test Convert',
                Country_Name__c = 'Test Convert'
            );
            lstFunloc.add(objFonloc);
        }
        insert lstFunloc;
    }
    
    private static void createSAPCMD(){
        lstSAPCMD = new List<SAP_CMD__c>();
        //SAP CMD with Z001
        objSAPCMD = new SAP_CMD__c(
            RecordTypeId = Z001_SoldTo_ShipTo_BillTo_Payer.Id,
            Legal_Name__c = 'Test SAP CMD - Test Test',
            HUB_Customer__c = lstCustomer[0].Id,
            Status__c = 'Approved and Distributed',
            Funloc__c = lstFunloc[0].Id,
            Consolidated_Account_Code__c = objCACC.Id,
            Language__c='M - Traditional Chinese', FunLoc_Type__c='internal',
            Company_Code__c = 'NL60 - RSO Europe' , Sales_Organisation__c = 'NL60 - RSO Europe',
            Name_2__c = 'additional name', Name_3__c = 'test name 3', Name_4__c = 'test name 4', Grp_1_Sls_Channel_SP__c='DIS - Distributor',
            Acct_assgmt_group__c='01 - Local 3rd Party', Currency__c='USD - US Dollar',Incoterms_2__c='TEST', Acconting_Clerk__c = 'Test',
            Customer_Factory_Calendar__c = '01 - Customer calendar Germany standard', Cust_pric_proc__c = 'Test', 
             Transportation_Zone__c = 'AE1',
            Global_Account__c = 'ABAUT - ABA AB AUTOMOTIVE', Rounding_Rule_SH__c = 'C - Round to Closest',
//Scarlett          Industry_Segment__c = 'AA - Appliances', 
//Scarlett on May 30 2016           Industry_Sub_Segment__c = 'A1 - Major Home Appliances', 
            Ind_period_account_statement__c = '1 - No account statement needed',
            Region__c = 'AM - Americas', Label_Required__c = 'Yes', Zip__c = '300457', Unloading_Point__c = 'CUSTOMER UNLOADING POINT', 
            Military_Usage__c = 'No - ID for mainly non-military use', Fix_Price_Ind_SP__c = 'N - No', Delivery_Group_Ind_SH__c = '01 - Sh per single line',
            Pull_Up_OK_SH__c = 'N - No', Reconciliation_Account__c = '1200100 - Trade AR with foreign parties', Sorting_key_for_assignment_no__c = '000 - Allocation number',
            Terms_of_payment__c = '114 - 75 days after invoice date', Delivery_priority__c = '30 - Priority 3', Payment_Credit_Memo__c = '114 - 75 days after invoice date',
            Distribution_Region__c = 'Test', Act_clerk_internet_address__c = 'AMB3425@motorola.com', Indicator_Record_Payment_History__c = TRUE,
            Key_for_Payment_Grouping__c = '02 - Currency', Lockbox__c = 'USD', Selection_Rule_for_Payment_Advice__c = '001 - Document no / Reference',
            Reason_Code_Conversion__c = '001 - Version 001', User_at_customer__c = 'Motorola Mobili', 
            Distribution_Channel__c = '00', Sales_office__c = 'SG60 - MSO SINGAPORE', Sales_district__c = 'AC - AP Greater China', Exch_rate_type__c = '4DEC - NXP Act. Rate',
            Division__c = '00', S_O_Sub_Group__c = 'SG - Singapore',
            Reprice_Basis__c = 'C - Conf. Delivery Date', Acct_at_cust__c = '1106401', Customer_Statistics_Group__c = '1', 
            Max_partial_deliveries__c = '9', Order_combination__c = TRUE, Shipping_conditions__c = '01 - Ship via Std Route', Incoterms_1__c = 'FCA - Free carrier',     
            Paym_guar_proc__c = 'Z001 - No guarantee required', Cred_contr_area__c = 'NL60 - RSO Europe', 
            Terms_of_Payment_Sales__c = '114 - 75 days after invoice date', Grp_2_Cus_Prce_Grp_SP__c = '042 - Motorola Mobility',
            BillCurrency_PY__c = 'USD', Main_shipping_mark__c = 'NXP MOTOROLA(CHINA)', Additional_shipping_mark__c = 'C/NO.', City__c = 'Test', Country__c = 'Test', 
            Street_1__c = 'Test',Version_ID_for_International_Addresses__c = 'C',Tax_Number_5__c = 'Test Tax Number 5'
        );
        lstSAPCMD.add(objSAPCMD);
        
        //SAP CMD with Z001
        objSAPCMD = new SAP_CMD__c(
            RecordTypeId = Z001_SoldTo_ShipTo_BillTo_Payer.Id,
            Legal_Name__c = 'Test SAP CMD - Test Test',
            HUB_Customer__c = lstCustomer[1].Id,
            Status__c = 'Approved and Distributed',
            Funloc__c = lstFunloc[1].Id,
            Consolidated_Account_Code__c = objCACC.Id,
            Language__c='M - Traditional Chinese', FunLoc_Type__c='internal',
            Company_Code__c = 'NL60 - RSO Europe' , Sales_Organisation__c = 'NL60 - RSO Europe',
            Name_2__c = 'additional name', Name_3__c = 'test name 3', Name_4__c = 'test name 4', Grp_1_Sls_Channel_SP__c='DIS - Distributor',
            Acct_assgmt_group__c='01 - Local 3rd Party', Currency__c='USD - US Dollar',Incoterms_2__c='TEST', Acconting_Clerk__c = 'Test',
            Customer_Factory_Calendar__c = '01 - Customer calendar Germany standard', Cust_pric_proc__c = 'Test', 
             Transportation_Zone__c = 'AE1',
            Global_Account__c = 'ABAUT - ABA AB AUTOMOTIVE', Rounding_Rule_SH__c = 'C - Round to Closest',
//Scarlett          Industry_Segment__c = 'AA - Appliances', 
//Scarlett on May 30 2016           Industry_Sub_Segment__c = 'A1 - Major Home Appliances', 
            Ind_period_account_statement__c = '1 - No account statement needed',
            Region__c = 'AM - Americas', Label_Required__c = 'Yes', Zip__c = '300457', Unloading_Point__c = 'CUSTOMER UNLOADING POINT', 
            Military_Usage__c = 'No - ID for mainly non-military use', Fix_Price_Ind_SP__c = 'N - No', Delivery_Group_Ind_SH__c = '01 - Sh per single line',
            Pull_Up_OK_SH__c = 'N - No', Reconciliation_Account__c = '1200100 - Trade AR with foreign parties', Sorting_key_for_assignment_no__c = '000 - Allocation number',
            Terms_of_payment__c = '114 - 75 days after invoice date', Delivery_priority__c = '30 - Priority 3', Payment_Credit_Memo__c = '114 - 75 days after invoice date',
            Distribution_Region__c = 'Test', Act_clerk_internet_address__c = 'AMB3425@motorola.com', Indicator_Record_Payment_History__c = TRUE,
            Key_for_Payment_Grouping__c = '02 - Currency', Lockbox__c = 'USD', Selection_Rule_for_Payment_Advice__c = '001 - Document no / Reference',
            Reason_Code_Conversion__c = '001 - Version 001', User_at_customer__c = 'Motorola Mobili', 
            Distribution_Channel__c = '00', Sales_office__c = 'SG60 - MSO SINGAPORE', Sales_district__c = 'AC - AP Greater China', Exch_rate_type__c = '4DEC - NXP Act. Rate',
            Division__c = '00', S_O_Sub_Group__c = 'SG - Singapore',
            Reprice_Basis__c = 'C - Conf. Delivery Date', Acct_at_cust__c = '1106401', Customer_Statistics_Group__c = '1', 
            Max_partial_deliveries__c = '9', Order_combination__c = TRUE, Shipping_conditions__c = '01 - Ship via Std Route', Incoterms_1__c = 'FCA - Free carrier',     
            Paym_guar_proc__c = 'Z001 - No guarantee required', Cred_contr_area__c = 'NL60 - RSO Europe', 
            Terms_of_Payment_Sales__c = '114 - 75 days after invoice date', Grp_2_Cus_Prce_Grp_SP__c = '042 - Motorola Mobility',
            BillCurrency_PY__c = 'USD', Main_shipping_mark__c = 'NXP MOTOROLA(CHINA)', Additional_shipping_mark__c = 'C/NO.', City__c = 'Test', Country__c = 'Test', 
            Street_1__c = 'Test'
        );
        lstSAPCMD.add(objSAPCMD);
        
        //SAP CMD with ZI/Z010
        objSAPCMD = new SAP_CMD__c(
            RecordTypeId = Z010_Intermediate_Consignee.Id,
            Legal_Name__c = 'Test SAP CMD - Test Test',
            HUB_Customer__c = lstCustomer[2].Id,
            Status__c = 'Approved and Distributed',
            Funloc__c = lstFunloc[2].Id,
            Consolidated_Account_Code__c = objCACC.Id,
            Language__c='M - Traditional Chinese', FunLoc_Type__c='internal',
            Company_Code__c = 'NL60 - RSO Europe' , Sales_Organisation__c = 'NL60 - RSO Europe',
            Name_2__c = 'additional name', Name_3__c = 'test name 3', Name_4__c = 'test name 4', Grp_1_Sls_Channel_SP__c='DIS - Distributor',
            Acct_assgmt_group__c='01 - Local 3rd Party', Currency__c='USD - US Dollar',Incoterms_2__c='TEST', Acconting_Clerk__c = 'Test',
            Customer_Factory_Calendar__c = '01 - Customer calendar Germany standard', Cust_pric_proc__c = 'Test', 
             Transportation_Zone__c = 'AE1',
            Global_Account__c = 'ABAUT - ABA AB AUTOMOTIVE', Rounding_Rule_SH__c = 'C - Round to Closest',
//Scarlett          Industry_Segment__c = 'AA - Appliances', 
//Scarlett on May 30 2016           Industry_Sub_Segment__c = 'A1 - Major Home Appliances', 
            Ind_period_account_statement__c = '1 - No account statement needed',
            Region__c = 'AM - Americas', Label_Required__c = 'Yes', Zip__c = '300457', Unloading_Point__c = 'CUSTOMER UNLOADING POINT', 
            Military_Usage__c = 'No - ID for mainly non-military use', Fix_Price_Ind_SP__c = 'N - No', Delivery_Group_Ind_SH__c = '01 - Sh per single line',
            Pull_Up_OK_SH__c = 'N - No', Reconciliation_Account__c = '1200100 - Trade AR with foreign parties', Sorting_key_for_assignment_no__c = '000 - Allocation number',
            Terms_of_payment__c = '114 - 75 days after invoice date', Delivery_priority__c = '30 - Priority 3', Payment_Credit_Memo__c = '114 - 75 days after invoice date',
            Distribution_Region__c = 'Test', Act_clerk_internet_address__c = 'AMB3425@motorola.com', Indicator_Record_Payment_History__c = TRUE,
            Key_for_Payment_Grouping__c = '02 - Currency', Lockbox__c = 'USD', Selection_Rule_for_Payment_Advice__c = '001 - Document no / Reference',
            Reason_Code_Conversion__c = '001 - Version 001', User_at_customer__c = 'Motorola Mobili', 
            Distribution_Channel__c = '00', Sales_office__c = 'SG60 - MSO SINGAPORE', Sales_district__c = 'AC - AP Greater China', Exch_rate_type__c = '4DEC - NXP Act. Rate',
            Division__c = '00', S_O_Sub_Group__c = 'SG - Singapore',
            Reprice_Basis__c = 'C - Conf. Delivery Date', Acct_at_cust__c = '1106401', Customer_Statistics_Group__c = '1', 
            Max_partial_deliveries__c = '9', Order_combination__c = TRUE, Shipping_conditions__c = '01 - Ship via Std Route', Incoterms_1__c = 'FCA - Free carrier',     
            Paym_guar_proc__c = 'Z001 - No guarantee required', Cred_contr_area__c = 'NL60 - RSO Europe', 
            Terms_of_Payment_Sales__c = '114 - 75 days after invoice date', Grp_2_Cus_Prce_Grp_SP__c = '042 - Motorola Mobility',
            Main_shipping_mark__c = 'NXP MOTOROLA(CHINA)', Additional_shipping_mark__c = 'C/NO.', City__c = 'Test', Country__c = 'Test', 
            Street_1__c = 'Test'
        );
        lstSAPCMD.add(objSAPCMD);
        
        //SAP CMD with ZI/Z010
        objSAPCMD = new SAP_CMD__c(
            RecordTypeId = Z010_Intermediate_Consignee.Id,
            Legal_Name__c = 'Test SAP CMD - Test Test',
            HUB_Customer__c = lstCustomer[3].Id,
            Status__c = 'Approved and Distributed',
            Funloc__c = lstFunloc[3].Id,
            Consolidated_Account_Code__c = objCACC.Id,
            Language__c='M - Traditional Chinese', FunLoc_Type__c='internal',
            Company_Code__c = 'NL60 - RSO Europe' , Sales_Organisation__c = 'NL60 - RSO Europe',
            Name_2__c = 'additional name', Name_3__c = 'test name 3', Name_4__c = 'test name 4', Grp_1_Sls_Channel_SP__c='DIS - Distributor',
            Acct_assgmt_group__c='01 - Local 3rd Party', Currency__c='USD - US Dollar',Incoterms_2__c='TEST', Acconting_Clerk__c = 'Test',
            Customer_Factory_Calendar__c = '01 - Customer calendar Germany standard', Cust_pric_proc__c = 'Test', 
            Transportation_Zone__c = 'AE1',
            Global_Account__c = 'ABAUT - ABA AB AUTOMOTIVE', Rounding_Rule_SH__c = 'C - Round to Closest',
//Scarlett          Industry_Segment__c = 'AA - Appliances', 
//Scarlett on May 30 2016           Industry_Sub_Segment__c = 'A1 - Major Home Appliances', 
            Ind_period_account_statement__c = '1 - No account statement needed',
            Region__c = 'AM - Americas', Label_Required__c = 'Yes', Zip__c = '300457', Unloading_Point__c = 'CUSTOMER UNLOADING POINT', 
            Military_Usage__c = 'No - ID for mainly non-military use', Fix_Price_Ind_SP__c = 'N - No', Delivery_Group_Ind_SH__c = '01 - Sh per single line',
            Pull_Up_OK_SH__c = 'N - No', Reconciliation_Account__c = '1200100 - Trade AR with foreign parties', Sorting_key_for_assignment_no__c = '000 - Allocation number',
            Terms_of_payment__c = '114 - 75 days after invoice date', Delivery_priority__c = '30 - Priority 3', Payment_Credit_Memo__c = '114 - 75 days after invoice date',
            Distribution_Region__c = 'Test', Act_clerk_internet_address__c = 'AMB3425@motorola.com', Indicator_Record_Payment_History__c = TRUE,
            Key_for_Payment_Grouping__c = '02 - Currency', Lockbox__c = 'USD', Selection_Rule_for_Payment_Advice__c = '001 - Document no / Reference',
            Reason_Code_Conversion__c = '001 - Version 001', User_at_customer__c = 'Motorola Mobili', 
            Distribution_Channel__c = '00', Sales_office__c = 'SG60 - MSO SINGAPORE', Sales_district__c = 'AC - AP Greater China', Exch_rate_type__c = '4DEC - NXP Act. Rate',
            Division__c = '00', S_O_Sub_Group__c = 'SG - Singapore',
            Reprice_Basis__c = 'C - Conf. Delivery Date', Acct_at_cust__c = '1106401', Customer_Statistics_Group__c = '1', 
            Max_partial_deliveries__c = '9', Order_combination__c = TRUE, Shipping_conditions__c = '01 - Ship via Std Route', Incoterms_1__c = 'FCA - Free carrier',     
            Paym_guar_proc__c = 'Z001 - No guarantee required', Cred_contr_area__c = 'NL60 - RSO Europe', 
            Terms_of_Payment_Sales__c = '114 - 75 days after invoice date', Grp_2_Cus_Prce_Grp_SP__c = '042 - Motorola Mobility',
            Main_shipping_mark__c = 'NXP MOTOROLA(CHINA)', Additional_shipping_mark__c = 'C/NO.', City__c = 'Test', Country__c = 'Test', 
            Street_1__c = 'Test'
        );
        lstSAPCMD.add(objSAPCMD);
        
         objSAPCMD = new SAP_CMD__c(
            RecordTypeId = Z010_Intermediate_Consignee.Id,
            Legal_Name__c = 'Test SAP CMD - Test Test',
            HUB_Customer__c = lstCustomer[3].Id,
            Status__c = 'Approved and Distributed',
            Funloc__c = lstFunloc[4].Id,
             Name_1_Service_Provider__c = 'Service Provider',
            Consolidated_Account_Code__c = objCACC.Id,
            Language__c='M - Traditional Chinese', FunLoc_Type__c='internal',
            Company_Code__c = 'NL60 - RSO Europe' , Sales_Organisation__c = 'NL60 - RSO Europe',
            Name_2__c = 'additional name', Name_3__c = 'test name 3', Name_4__c = 'test name 4', Grp_1_Sls_Channel_SP__c='DIS - Distributor',
            Acct_assgmt_group__c='01 - Local 3rd Party', Currency__c='USD - US Dollar',Incoterms_2__c='TEST', Acconting_Clerk__c = 'Test',
            Customer_Factory_Calendar__c = '01 - Customer calendar Germany standard', Cust_pric_proc__c = 'Test', 
            Transportation_Zone__c = 'AE1',
            Global_Account__c = 'ABAUT - ABA AB AUTOMOTIVE', Rounding_Rule_SH__c = 'C - Round to Closest',
            Ind_period_account_statement__c = '1 - No account statement needed',
            Region__c = 'AM - Americas', Label_Required__c = 'Yes', Zip__c = '300457', Unloading_Point__c = 'CUSTOMER UNLOADING POINT', 
            Military_Usage__c = 'No - ID for mainly non-military use', Fix_Price_Ind_SP__c = 'N - No', Delivery_Group_Ind_SH__c = '01 - Sh per single line',
            Pull_Up_OK_SH__c = 'N - No', Reconciliation_Account__c = '1200100 - Trade AR with foreign parties', Sorting_key_for_assignment_no__c = '000 - Allocation number',
            Terms_of_payment__c = '114 - 75 days after invoice date', Delivery_priority__c = '30 - Priority 3', Payment_Credit_Memo__c = '114 - 75 days after invoice date',
            Distribution_Region__c = 'Test', Act_clerk_internet_address__c = 'AMB3425@motorola.com', Indicator_Record_Payment_History__c = TRUE,
            Key_for_Payment_Grouping__c = '02 - Currency', Lockbox__c = 'USD', Selection_Rule_for_Payment_Advice__c = '001 - Document no / Reference',
            Reason_Code_Conversion__c = '001 - Version 001', User_at_customer__c = 'Motorola Mobili', 
            Distribution_Channel__c = '00', Sales_office__c = 'SG60 - MSO SINGAPORE', Sales_district__c = 'AC - AP Greater China', Exch_rate_type__c = '4DEC - NXP Act. Rate',
            Division__c = '00', S_O_Sub_Group__c = 'SG - Singapore',
            Reprice_Basis__c = 'C - Conf. Delivery Date', Acct_at_cust__c = '1106401', Customer_Statistics_Group__c = '1', 
            Max_partial_deliveries__c = '9', Order_combination__c = TRUE, Shipping_conditions__c = '01 - Ship via Std Route', Incoterms_1__c = 'FCA - Free carrier',     
            Paym_guar_proc__c = 'Z001 - No guarantee required', Cred_contr_area__c = 'NL60 - RSO Europe', 
            Terms_of_Payment_Sales__c = '114 - 75 days after invoice date', Grp_2_Cus_Prce_Grp_SP__c = '042 - Motorola Mobility',
            Main_shipping_mark__c = 'NXP MOTOROLA(CHINA)', Additional_shipping_mark__c = 'C/NO.', City__c = 'Test', Country__c = 'Test', 
            Street_1__c = 'Test1'
        );
        lstSAPCMD.add(objSAPCMD);
        
         objSAPCMD = new SAP_CMD__c(
            RecordTypeId = Z010_Intermediate_Consignee.Id,
            Legal_Name__c = 'Test SAP CMD - Test Test',
            HUB_Customer__c = lstCustomer[2].Id,
            Status__c = 'Approved and Distributed',
            Funloc__c = lstFunloc[5].Id,
             Name_1_Service_Provider__c = 'Service Provider',
            Consolidated_Account_Code__c = objCACC.Id,
            Language__c='M - Traditional Chinese', FunLoc_Type__c='internal',
            Company_Code__c = 'NL60 - RSO Europe' , Sales_Organisation__c = 'NL60 - RSO Europe',
            Name_2__c = 'additional name', Name_3__c = 'test name 3', Name_4__c = 'test name 4', Grp_1_Sls_Channel_SP__c='DIS - Distributor',
            Acct_assgmt_group__c='01 - Local 3rd Party', Currency__c='USD - US Dollar',Incoterms_2__c='TEST', Acconting_Clerk__c = 'Test',
            Customer_Factory_Calendar__c = '01 - Customer calendar Germany standard', Cust_pric_proc__c = 'Test', 
            Transportation_Zone__c = 'AE1',
            Global_Account__c = 'ABAUT - ABA AB AUTOMOTIVE', Rounding_Rule_SH__c = 'C - Round to Closest',
            Ind_period_account_statement__c = '1 - No account statement needed',
            Region__c = 'AM - Americas', Label_Required__c = 'Yes', Zip__c = '300457', Unloading_Point__c = 'CUSTOMER UNLOADING POINT', 
            Military_Usage__c = 'No - ID for mainly non-military use', Fix_Price_Ind_SP__c = 'N - No', Delivery_Group_Ind_SH__c = '01 - Sh per single line',
            Pull_Up_OK_SH__c = 'N - No', Reconciliation_Account__c = '1200100 - Trade AR with foreign parties', Sorting_key_for_assignment_no__c = '000 - Allocation number',
            Terms_of_payment__c = '114 - 75 days after invoice date', Delivery_priority__c = '30 - Priority 3', Payment_Credit_Memo__c = '114 - 75 days after invoice date',
            Distribution_Region__c = 'Test', Act_clerk_internet_address__c = 'AMB3425@motorola.com', Indicator_Record_Payment_History__c = TRUE,
            Key_for_Payment_Grouping__c = '02 - Currency', Lockbox__c = 'USD', Selection_Rule_for_Payment_Advice__c = '001 - Document no / Reference',
            Reason_Code_Conversion__c = '001 - Version 001', User_at_customer__c = 'Motorola Mobili', 
            Distribution_Channel__c = '00', Sales_office__c = 'SG60 - MSO SINGAPORE', Sales_district__c = 'AC - AP Greater China', Exch_rate_type__c = '4DEC - NXP Act. Rate',
            Division__c = '00', S_O_Sub_Group__c = 'SG - Singapore',
            Reprice_Basis__c = 'C - Conf. Delivery Date', Acct_at_cust__c = '1106401', Customer_Statistics_Group__c = '1', 
            Max_partial_deliveries__c = '9', Order_combination__c = TRUE, Shipping_conditions__c = '01 - Ship via Std Route', Incoterms_1__c = 'FCA - Free carrier',     
            Paym_guar_proc__c = 'Z001 - No guarantee required', Cred_contr_area__c = 'NL60 - RSO Europe', 
            Terms_of_Payment_Sales__c = '114 - 75 days after invoice date', Grp_2_Cus_Prce_Grp_SP__c = '042 - Motorola Mobility',
            Main_shipping_mark__c = 'NXP MOTOROLA(CHINA)', Additional_shipping_mark__c = 'C/NO.', City__c = 'Test', Country__c = 'Test', 
            Street_1__c = 'Test1'
        );
        lstSAPCMD.add(objSAPCMD);
        
        insert lstSAPCMD;
           
        List<Tax_Classification__c> lstSapTax = new List<Tax_Classification__c>();
        objSAPTax = new Tax_Classification__c (SAP_CMD_Tax_Classification__c = lstSAPCMD[1].id, Country__c = 'BR - Brazil', Tax_Category__c = 'MWST', Tax_Classification__c ='0');
        lstSapTax.add(objSAPTax);
        objSAPTax = new Tax_Classification__c (SAP_CMD_Tax_Classification__c = lstSAPCMD[1].id, Country__c = 'CN - China', Tax_Category__c = 'MWST', Tax_Classification__c ='0');
        lstSapTax.add(objSAPTax);
        objSAPTax = new Tax_Classification__c (SAP_CMD_Tax_Classification__c = lstSAPCMD[3].id, Country__c = 'DE - Germany', Tax_Category__c = 'MWST', Tax_Classification__c ='0');
        lstSapTax.add(objSAPTax);
        insert lstSapTax;
        system.debug('1checksaptax'+lstSapTax);
        
         Profile p = [SELECT Id FROM Profile WHERE Name = :TYPE_CMD_Officer];
        
         User u = new User(Alias = 'test', Email = TEST_USER_EMAIL_0, 
            EmailEncodingKey = 'UTF-8', LastName = 'Testing', LanguageLocaleKey = 'en_US', 
            LocaleSidKey = 'en_US', TimeZoneSidKey = 'America/Los_Angeles',
            ProfileId = p.Id, UserName = TEST_USER_EMAIL_0);
            listUser.add(u); 
        
        System.runAs(u){
        CMD_Request_Taxes_Trigger.validationOfTaxClsonSAPCMD(lstSapTax);
            }  
            
        Profile p1 = [SELECT Id FROM Profile WHERE Name = :TYPE_Standard_User];
        
        User u1 = new User(Alias = 'test', Email = TEST_USER_EMAIL_2, 
            EmailEncodingKey = 'UTF-8', LastName = 'Testing', LanguageLocaleKey = 'en_US', 
            LocaleSidKey = 'en_US', TimeZoneSidKey = 'America/Los_Angeles',
            ProfileId = p1.Id, UserName = TEST_USER_EMAIL_2);
            listUser.add(u1); 
        
        System.runAs(u1){
        CMD_Request_Taxes_Trigger.validationOfCTCTableonSAPCMD(lstSapTax);
            } 
        
    }
    
    private static void createCACC(){
        objCACC = new Consolidated_Account_Code__c(
            Name ='ZZZ', Code_Description__c = 'Test Code' , 
            End_Customer_GID__c = objCustomer.Id, 
            Customer_Category__c = 'Internal', 
            PD_Key_Account__c = 'APP - Apple', 
            Base_Region__c = 'NA - Americas'
        );
        insert objCACC;
    }
    
    private static void createPartnerFunction(){   
        lstPartnerFunction = new List<Partner_Function__c>();
        
        Profile p = [SELECT Id FROM Profile WHERE Name = :TYPE_CMD_Officer];
        
         User CMDOfficer = new User(Alias = 'test', Email = TEST_USER_EMAIL_1, 
            EmailEncodingKey = 'UTF-8', LastName = 'Testing1', LanguageLocaleKey = 'en_US', 
            LocaleSidKey = 'en_US', TimeZoneSidKey = 'America/Los_Angeles',
            ProfileId = p.Id, UserName = TEST_USER_EMAIL_1);
            insert CMDOfficer;
        //ZA
        Partner_Function__c objPartnerFunctionZA = new Partner_Function__c(
            RecordTypeId = ZA_ZS.Id,
            FunLoc__c = lstFunloc[0].Id,
            Partner_Function_Type__c = 'ZA - Customer Service Rep',
            Person_Name__c = 'Test Person Name -ZA',
            SAP_Customer__c = lstSAPCMD[0].Id
        );
        lstPartnerFunction.add(objPartnerFunctionZA);
        
        //ZS
        Partner_Function__c objPartnerFunctionZS = new Partner_Function__c(
            RecordTypeId = ZA_ZS.Id,
            FunLoc__c = lstFunloc[0].Id,
            Partner_Function_Type__c = 'ZS - Sales Person',
            Person_Name__c = 'Test Person Name - ZS',
            SAP_Customer__c = lstSAPCMD[0].Id
        ); 
        lstPartnerFunction.add(objPartnerFunctionZS);
        
        //ZS - Delete 
        Partner_Function__c objPartnerFunctionZS1 = new Partner_Function__c(
            RecordTypeId = ZA_ZS.Id,
            FunLoc__c = lstFunloc[0].Id,
            Partner_Function_Type__c = 'ZS - Sales Person',
            Person_Name__c = 'AP004 - Anca Lin',
            SAP_Customer__c = lstSAPCMD[0].Id
        ); 
        lstPartnerFunction.add(objPartnerFunctionZS1);
        
        Partner_Function__c objPartFuncZAError = new Partner_Function__c(
            RecordTypeId = ZA_ZS.Id,
            FunLoc__c = lstFunloc[0].Id,
            Partner_Function_Type__c = 'ZA - Customer Service Rep',
            Person_Name__c = 'Test Person Name Error -ZA',
            SAP_Customer__c = lstSAPCMD[0].Id
        );
        lstPartnerFunction.add(objPartFuncZAError);
        
        insert lstPartnerFunction;
        
        lstPartnerFuncDelete = new List<Partner_Function__c>();
        System.runAs(CMDOfficer){
        
        //ZA
     /*   Partner_Function__c objPartFuncZAError = new Partner_Function__c(
            RecordTypeId = ZA_ZS.Id,
            FunLoc__c = lstFunloc[0].Id,
            Partner_Function_Type__c = 'ZA - Customer Service Rep',
            Person_Name__c = 'Test Person Name Error -ZA',
            SAP_Customer__c = lstSAPCMD[0].Id
        );
        lstPartnerFuncDelete.add(objPartFuncZAError);
        insert lstPartnerFuncDelete;*/
        
        partner_function__c objPF = [select id,person_name__c from partner_function__c where Person_Name__c = 'Test Person Name Error -ZA'];
        
        try{
        delete objPF;
        }
        catch(Exception e){}
        
        }
        
     }
    
     
    //create SAP New Funloc Request
    static testmethod void myUnitTest1(){

        //prepare data
        fetchRecordType();
        createCustomer();
        //createParentAccount();
        createCACC();
        createHubFundation();
        createFunloc();
        createSAPCMD();
        createPartnerFunction();
        
        List<Customer__c> tempLstCustomer = [SELECT Id, Name FROM Customer__c];
        system.assert(tempLstCustomer.size() > 0);
        List<Hub_Foundation__c> tempLstHubFoundation = [SELECT Id FROM Hub_Foundation__c];
        system.assert(tempLstHubFoundation.size() > 0);
        List<Partner_Function__c> tempPartnerFunction = [SELECT Id FROM Partner_Function__c];
        system.assert(tempPartnerFunction.size() > 0);
        
        Funloc__c tempLstFunloc1 = [SELECT Id, Funloc_Number_Text__c FROM Funloc__c WHERE Id =: lstFunloc[0].Id];
        
        test.startTest();
        Datetime dt1 = DateTime.newInstance(2014,01,01,00,00,00);
        Datetime dt2 = DateTime.newInstance(2014,01,31,00,00,00);
        Datetime dt3 = DateTime.newInstance(2014,01,10,00,00,00);
        
        //CMD Request with duplicate SAP CMD
        CMD_Request__c theRequest = new CMD_Request__c(
            RecordTypeId = SAP_Funloc_Edit_Request.Id,
            Funloc__c = tempLstFunloc1.FunLoc_Number_Text__c,
            //Funloc_SAP_CMD__c = lstSAPCMD[0].Id,
            Consolidated_Account_Code__c = objCACC.Id,
            Global_Customer_ID__c = lstCustomer[0].Id,
            Ready_to_Submit__c = true,
            Request_Status__c = 'draft',
            Reason_for_request__c = 'Test',
            Sales_Organisation__c = 'NL60 - RSO Europe',
            GCP_Q_Approver_Group__c = 'AMEC Disti',
            //GSM_Controller_Approver_Group__c = 'JAPAN',  //commented by Nisha Agrawal on Apr 26 for SFDC-430
            Controller_Approver_Group__c = 'JP - Japan', //added by Nisha Agrawal on Apr 26 for SFDC-430 
            Approval_Submission_Date__c = dt2,
            Effective_Date__c = null,
            Update_SAP_CMD_Failed__c = false,
            Name_1_Service_Provider__c ='Test',
            Customer_Type__c = 'Service Provider',
            Deletion_Block_Company_Code__c = 'Yes',
            Deletion_Flag_Company_Code__c = 'Yes',
            Indicator_Record_Payment_History__c = 'Yes',
            Posting_Block_Company_Code__c = 'Yes',
            City_Chinese__c = 'Test',
            Chinese_Name2__c = 'Test',
            Chinese_Street__c = 'Test',
            Version_ID_for_International_Addresses__c = 'C'
        );
        insert theRequest;       
        
        theRequest.Request_Status__c = 'Approved';
        theRequest.Approval_Submission_Date__c = dt3;
        update theRequest; 
          
        System.assert(theRequest.Funloc__c != null);
        //system.assert(theRequest.Funloc_SAP_CMD__c != null);
        system.assert(theRequest.Approval_Submission_Date__c != null);
     
        CMD_Request__c theRequest1 = new CMD_Request__c(
            RecordTypeId = SAP_Funloc_Edit_Request.Id,
            Funloc__c = tempLstFunloc1.FunLoc_Number_Text__c,
            //Funloc_SAP_CMD__c = lstSAPCMD[0].Id,
            Consolidated_Account_Code__c = objCACC.Id,
            Global_Customer_ID__c = lstCustomer[0].Id,           
            Ready_to_Submit__c = true,
            Request_Status__c = 'draft',
            Reason_for_request__c = 'Test',
            Sales_Organisation__c = 'NL60 - RSO Europe',
            GCP_Q_Approver_Group__c = 'AMEC Disti',
            //GSM_Controller_Approver_Group__c = 'JAPAN',  //commented by Nisha Agrawal on Apr 26 for SFDC-430
            Controller_Approver_Group__c = 'JP - Japan', //added by Nisha Agrawal on Apr 26 for SFDC-430 
            Role__c = 'OEM' ,
            Name_Legal_Name__c = 'Test Convert 1',
            Name_Line_2__c = 'Test',
            Name_Line_3__c = 'Test',
            Name_Line_4__c = 'Test',
            City__c = 'Test',
            Country__c = 'USA',
            State_Province__c = 'Indiana',
            Postal_Code__c = '115',
            PO_Box__c = '115',
            PO_Box_City__c = 'Test',
            PO_Box_Postal_Code__c = '115',
            Telephone__c = '123456789',
            Fax__c = '123456789',
            Email__c = 'test@test.com',
            VAT_Registration_Number__c = '123455555',
            Taxes_Number_1__c = '1234555555',
           Transportation_Zone__c = '123',
            Language__c = 'M - Traditional Chinese',
            Chinese_Name1__c = 'test',
            Street__c = 'Test',
            Street_4__c = 'test',
            Ind_period_account_statement__c = '1 - No account statement needed',
            Tolerance_Group__c = 'DIST - Distributors (10 grace days)',
            Screened_for_SDI__c = 'Yes',
            Controlled_Party__c = 'Yes',
            FLAG_Bill_to__c = True,
            FLAG_Sold_to__c = True,
            FLAG_Ship_to__c = True,
            Street_House_Number__c = 'Test 1',
            Approval_Submission_Date__c = dt1,
            Effective_Date__c = null,
            Update_SAP_CMD_Failed__c = false,
            //Global_Customer_ID__c = '1234567890',
            Name_1_Service_Provider__c ='Test',
            Customer_Type__c = 'Service Provider',
            City_Chinese__c = 'Test',
            Chinese_Name2__c = 'Test',
            Chinese_Street__c = 'Test',
            Additional_VAT_Number_1__c = '123456',
            Additional_VAT_Number_2__c = '123456',  
            Additional_VAT_Number_3__c = '123456',
            Additional_VAT_Number_4__c = '123456',
            Additional_VAT_Number_5__c = '123456',
            Additional_VAT_Number_6__c = '123456',
            Additional_VAT_Number_7__c = '123456',
            Additional_VAT_Number_8__c = '123456',
            Country_Additional_VAT_Number_1__c = 'USA',
            Country_Additional_VAT_Number_2__c = 'USA',
            Country_Additional_VAT_Number_3__c = 'USA',
            Country_Additional_VAT_Number_4__c = 'USA',
            Country_Additional_VAT_Number_5__c = 'USA',
            Country_Additional_VAT_Number_6__c = 'USA',
            Country_Additional_VAT_Number_7__c = 'USA',
            Country_Additional_VAT_Number_8__c = 'USA', 
            Trading_Partner__c = '116202 - NXP Semiconductors Netherlands',
            Global_Account__c = 'ACA - Actia',
            Military_Usage__c = 'Yes - ID for mainly military use',
            Fix_Price_Ind_SP__c = 'Y - Yes',
            Industry_Segment__c = 'CC - Computing',
            Industry_Sub_Segment__c = 'C1 - Computing',
            Acct_at_cust__c = 'Test',
            Currency__c = 'USD - US Dollar',
            Cust_pric_proc__c = 'D - Disti Pricing',
            Customer_Statistics_Group__c = '1',
            Distribution_Channel__c = 'Test',
            Division__c = 'Test',
            Exch_rate_type__c = '4DEC - NXP Act. Rate',
            Region__c = 'EU - Europe',
            Reprice_Basis__c = 'C - Conf. Delivery Date',
            S_O_Sub_Group__c = 'NL - Netherlands',
            Sales_office__c = 'BOS1 - Bosch',
            Delivery_priority__c = '10 - Priority 1',
            Max_partial_deliveries__c = '1',
            BillCurrency_PY__c = 'EUR - Euro',
            Grp_1_Sls_Channel_SP__c = 'DIS - Distributor',
            Grp_2_Cus_Prce_Grp_SP__c = '018 - Bosch USD',
            Matl_Det_Grp_SP__c = 'ABB - ABB',
            Additional_shipping_mark__c = 'Test',
            Brazil_Specific_Clause__c = 'Test',
            CPNJ_for_Brazil__c = 'Test',
            Freight_Forwarder__c = 'Test',
            Main_shipping_mark__c = 'Test',
            Billing_Block__c = 'Test',
            Central_Billing_Block__c = 'Test',
            Central_delivery_block__c = 'Test',
            FunLoc_Type__c = 'Pure',
            Central_order_block__c = 'Test',
            Delivery_Block__c = 'Test',
            Order_Block__c = 'Test',
            Order_Combination__c = 'Yes',
            Distribution_Region__c = 'E1 - NL00',
            Sales_district__c = 'EC - EU Central',
            Partial_delivery_per_item__c = 'C - Only complete delivery allowed',
            Reconciliation_Account__c = '1200100 - Trade AR with foreign parties',
            Fixed_Currency_Ind_SP__c = 'Yes',
            Non_I2_related_SP__c = 'Yes',
            Sales_Area_Region__c = 'EU - Europe',
            Accept_Dupl_PO_SP__c  = 'Yes',
            Ch_dupl_PO_item_SP__c = 'Yes',
            Customer_Factory_Calendar__c = '01 - Customer calendar Germany standard',
            Unloading_Point__c = 'test',
            Delivery_Group_Ind_SH__c = '01 - Sh per single line',
            Pull_Up_OK_SH__c = 'N - No',
            Rounding_Rule_SH__c = 'C - Round to Closest',
            C_GAD_Indicator_SH__c = 'Yes',
            Shipping_Condition__c  = '01 - Ship via Std Route',
            Incoterms_1__c = 'CPT - Carriage paid to',
            Incoterms_2__c = 'Test',
            Label_Required__c = 'No',
            Company_Code__c = 'NL60 - RSO Europe',
            Sorting_key_for_assignment_no__c = '000 - Allocation number',
            Indicator_Record_Payment_History__c = 'Yes',
            Lockbox__c  = 'EUR',
            Payment_Credit_Memo__c = '014 - Prepaid',
            Reason_Code_Conversion__c = '001 - Version 001',
            Selection_Rule_for_Payment_Advice__c = '002 - Reference',
            Terms_of_Payment__c = '014 - Prepaid',
            
            Account_memo__c = 'test',
            Accounting_Clerk__c = '01 - Jim Chen',
            Act_clerk_fax_number__c = '+886281709999',
            Act_clerk_internet_address__c = 'Test',
            Act_clerk_tel_no__c = '+886281709999',
            User_at_customer__c = 'Test',
            Acct_assgmt_group__c = '01 - Local 3rd Party',
            Payment_Guarantee_Procedure__c = 'Z001 - No guarantee required',
            Terms_of_Payment_Sales__c = '014 - Prepaid',
            Our_account_at_customer__c = 'Test',
            Deletion_Block_Company_Code__c = 'No',
            Deletion_Flag_Company_Code__c = 'No',
            Posting_Block_Company_Code__c = 'No',
            Customer_Service_ZA__c = 'CN214 - Mary Ng',
            Sales_Rep_ZS__c = 'AP004 - Anca Lin',
            Version_ID_for_International_Addresses__c = 'M',
            Tax_Number_5__c = 'Test Tax 5'
        );
        insert theRequest1;       
        
        theRequest1.Request_Status__c = 'Approved';
        update theRequest1;
        
        system.assert(theRequest1.FLAG_Sold_to__c == true);  
        system.assert(theRequest1.FLAG_Ship_to__c == true);   
        //system.assert(theRequest1.FLAG_Payer__c == true); 
        system.assert(theRequest1.FLAG_Bill_to__c == true); 
        system.assert(theRequest1.Global_Customer_ID__c != null);
        
        ////Request 2 with negative value
        Funloc__c tempLstFunloc2 = [SELECT Id, Funloc_Number_Text__c FROM Funloc__c WHERE Id =: lstFunloc[1].Id];
        
        CMD_Request__c theRequest2 = new CMD_Request__c(
            RecordTypeId = SAP_Funloc_Edit_Request.Id,
            Funloc__c = tempLstFunloc2.FunLoc_Number_Text__c,
            Funloc_SAP_CMD__c = lstSAPCMD[1].Id,
            Consolidated_Account_Code__c = objCACC.Id,
            Global_Customer_ID__c = lstCustomer[0].Id,        
Ready_to_Submit__c = true,
            Request_Status__c = 'draft',
            Reason_for_request__c = 'Test',
            Sales_Organisation__c = 'NL60 - RSO Europe',
            GCP_Q_Approver_Group__c = 'AMEC Disti',
            //GSM_Controller_Approver_Group__c = 'JAPAN',  //commented by Nisha Agrawal on Apr 26 for SFDC-430
            Controller_Approver_Group__c = 'JP - Japan', //added by Nisha Agrawal on Apr 26 for SFDC-430 
            Role__c = 'OEM' ,
            Name_Legal_Name__c = 'Test Convert 1',
            Name_Line_2__c = 'Test',
            Name_Line_3__c = 'Test',
            Name_Line_4__c = 'Test',
            City__c = 'Test',
            Country__c = 'USA',
            State_Province__c = 'Indiana',
            Postal_Code__c = '115',
            PO_Box__c = '115',
            PO_Box_City__c = 'Test',
            PO_Box_Postal_Code__c = '115',
            Telephone__c = '123456789',
            Fax__c = '123456789',
            Email__c = 'test@test.com',
            VAT_Registration_Number__c = '123455555',
            Taxes_Number_1__c = '1234555555',
           Transportation_Zone__c = '123',
            Language__c = 'M - Traditional Chinese',
            Chinese_Name1__c = 'test',
            Street__c = 'Test',
            Street_4__c = 'test',
            Ind_period_account_statement__c = '1 - No account statement needed',
            Tolerance_Group__c = 'DIST - Distributors (10 grace days)',
            Screened_for_SDI__c = 'Yes',
            Controlled_Party__c = 'Yes',
            FLAG_Bill_to__c = True,
            FLAG_Sold_to__c = True,
            FLAG_Ship_to__c = True,
            Street_House_Number__c = 'Test 1',
            Approval_Submission_Date__c = dt1,
            Effective_Date__c = null,
            Update_SAP_CMD_Failed__c = false,
            //Global_Customer_ID__c = '1234567890',
            Name_1_Service_Provider__c ='Test',
            Customer_Type__c = 'Service Provider',
            City_Chinese__c = 'Test',
            Chinese_Name2__c = 'Test',
            Chinese_Street__c = 'Test',
            Additional_VAT_Number_1__c = '123456',
            Additional_VAT_Number_2__c = '123456',  
            Additional_VAT_Number_3__c = '123456',
            Additional_VAT_Number_4__c = '123456',
            Additional_VAT_Number_5__c = '123456',
            Additional_VAT_Number_6__c = '123456',
            Additional_VAT_Number_7__c = '123456',
            Additional_VAT_Number_8__c = '123456',
            Country_Additional_VAT_Number_1__c = 'USA',
            Country_Additional_VAT_Number_2__c = 'USA',
            Country_Additional_VAT_Number_3__c = 'USA',
            Country_Additional_VAT_Number_4__c = 'USA',
            Country_Additional_VAT_Number_5__c = 'USA',
            Country_Additional_VAT_Number_6__c = 'USA',
            Country_Additional_VAT_Number_7__c = 'USA',
            Country_Additional_VAT_Number_8__c = 'USA', 
            Trading_Partner__c = '116202 - NXP Semiconductors Netherlands',
            Global_Account__c = 'ACA - Actia',
            Military_Usage__c = 'Yes - ID for mainly military use',
            Fix_Price_Ind_SP__c = 'Y - Yes',
            Industry_Segment__c = 'CC - Computing',
            Industry_Sub_Segment__c = 'C1 - Computing',
            Acct_at_cust__c = 'Test',
            Currency__c='USD - US Dollar',
            Cust_pric_proc__c = 'D - Disti Pricing',
            Customer_Statistics_Group__c = '1',
            Distribution_Channel__c = 'Test',
            Division__c = 'Test',
            Exch_rate_type__c = '4DEC - NXP Act. Rate',
            Region__c = 'EU - Europe',
            Reprice_Basis__c = 'C - Conf. Delivery Date',
            S_O_Sub_Group__c = 'NL - Netherlands',
            Sales_office__c = 'BOS1 - Bosch',
            Delivery_priority__c = '10 - Priority 1',
            Max_partial_deliveries__c = '1',
            BillCurrency_PY__c = 'EUR - Euro',
            Grp_1_Sls_Channel_SP__c = 'DIS - Distributor',
            Grp_2_Cus_Prce_Grp_SP__c = '018 - Bosch USD',
            Matl_Det_Grp_SP__c = 'ABB - ABB',
            Additional_shipping_mark__c = 'Test',
            Brazil_Specific_Clause__c = 'Test',
            CPNJ_for_Brazil__c = 'Test',
            Freight_Forwarder__c = 'Test',
            Main_shipping_mark__c = 'Test',
            Billing_Block__c = 'Test',
            Central_Billing_Block__c = 'Test',
            Central_delivery_block__c = 'Test',
            FunLoc_Type__c = 'Pure',
            Central_order_block__c = 'Test',
            Delivery_Block__c = 'Test',
            Order_Block__c = 'Test',
            Order_Combination__c = 'Yes',
            Distribution_Region__c = 'E1 - NL00',
            Sales_district__c = 'EC - EU Central',
            Partial_delivery_per_item__c = 'C - Only complete delivery allowed',
            Reconciliation_Account__c = '1200100 - Trade AR with foreign parties',
            Fixed_Currency_Ind_SP__c = 'Yes',
            Non_I2_related_SP__c = 'Yes',
            Sales_Area_Region__c = 'EU - Europe',
            Accept_Dupl_PO_SP__c  = 'Yes',
            Ch_dupl_PO_item_SP__c = 'Yes',
            Customer_Factory_Calendar__c = '01 - Customer calendar Germany standard',
            Unloading_Point__c = 'test',
            Delivery_Group_Ind_SH__c = '01 - Sh per single line',
            Pull_Up_OK_SH__c = 'N - No',
            Rounding_Rule_SH__c = 'C - Round to Closest',
            C_GAD_Indicator_SH__c = 'Yes',
            Shipping_Condition__c  = '01 - Ship via Std Route',
            Incoterms_1__c = 'CPT - Carriage paid to',
            Incoterms_2__c = 'Test',
          //  Label_Required__c = 'No',
            Company_Code__c = 'NL60 - RSO Europe',
            Sorting_key_for_assignment_no__c = '000 - Allocation number',
            Indicator_Record_Payment_History__c = 'Yes',
            Lockbox__c  = 'EUR',
            Payment_Credit_Memo__c = '014 - Prepaid',
            Reason_Code_Conversion__c = '001 - Version 001',
            Selection_Rule_for_Payment_Advice__c = '002 - Reference',
            Terms_of_Payment__c = '014 - Prepaid',
            
            Account_memo__c = 'test',
            Accounting_Clerk__c = '01 - Jim Chen',
            Act_clerk_fax_number__c = '+886281709999',
            Act_clerk_internet_address__c = 'Test',
            Act_clerk_tel_no__c = '+886281709999',
            User_at_customer__c = 'Test',
            Acct_assgmt_group__c = '01 - Local 3rd Party',
            Payment_Guarantee_Procedure__c = 'Z001 - No guarantee required',
            Terms_of_Payment_Sales__c = '014 - Prepaid',
            Our_account_at_customer__c = 'Test',
            Deletion_Block_Company_Code__c = 'No',
            Deletion_Flag_Company_Code__c = 'No',
            Posting_Block_Company_Code__c = 'No',
            Customer_Service_ZA__c = 'CN214 - Mary Ng',
            Sales_Rep_ZS__c = 'AP004 - Anca Lin',
           // Sales_Rep_ZS__c = 'Test ZS',
            Label_Required__c = 'Yes',
            Label_Code__c = 'Yes',
            Version_ID_for_International_Addresses__c = 'C'
        );
        insert theRequest2;     
        
        List<Tax_Classification__c> lstSapTaxupdate = new List<Tax_Classification__c>();
        objSAPCMDTax = new Tax_Classification__c (CMD_Request__c = theRequest2.id, Country__c = 'BR - Brazil', Tax_Category__c = 'MWST', Tax_Classification__c ='1');
        lstSapTaxupdate.add(objSAPCMDTax);
        objSAPCMDTax = new Tax_Classification__c (CMD_Request__c = theRequest2.id, Country__c = 'CN - China', Tax_Category__c = 'MWST', Tax_Classification__c ='1');
        lstSapTaxupdate.add(objSAPCMDTax);
      //  objSAPCMDTax = new Tax_Classification__c (CMD_Request__c = theRequest2.id, Country__c = 'CA - Canada', Tax_Category__c = 'MWST', Tax_Classification__c ='1');
      //  lstSapTaxupdate.add(objSAPCMDTax);
      //  objSAPCMDTax = new Tax_Classification__c (CMD_Request__c = theRequest2.id, Country__c = 'CN - China', Tax_Category__c = 'MWST', Tax_Classification__c ='B');
      //  lstSapTaxupdate.add(objSAPCMDTax);
        system.debug('2checksaptax'+lstSapTaxupdate);
        try{
            insert lstSapTaxupdate;
            } catch(exception e){}
  
        
        theRequest2.Request_Status__c = 'Approved';
        update theRequest2;   
        
        system.assert(theRequest2.Funloc__c != null);
        system.assert(theRequest2.Funloc_SAP_CMD__c != null);
        system.assert(theRequest2.FLAG_Sold_to__c == true);  
        system.assert(theRequest2.FLAG_Ship_to__c == true);   
        //system.assert(theRequest2.FLAG_Payer__c == true); 
        system.assert(theRequest2.FLAG_Bill_to__c == true); 
        
        //CMD Request with ZI
        Funloc__c tempLstFunloc3 = [SELECT Id, Funloc_Number_Text__c FROM Funloc__c WHERE Id =: lstFunloc[2].Id];
        
        CMD_Request__c theRequest3 = new CMD_Request__c(
            RecordTypeId = SAP_Funloc_Edit_Request.Id,
            Funloc__c = tempLstFunloc3.FunLoc_Number_Text__c,
            Funloc_SAP_CMD__c = lstSAPCMD[2].Id,
            Global_Customer_ID__c = lstCustomer[0].Id,  
            Consolidated_Account_Code__c = objCACC.Id,
           Ready_to_Submit__c = true,
            Request_Status__c = 'draft',
            Reason_for_request__c = 'Test',
            Sales_Organisation__c = 'NL60 - RSO Europe',
            GCP_Q_Approver_Group__c = 'AMEC Disti',
            //GSM_Controller_Approver_Group__c = 'JAPAN',  //commented by Nisha Agrawal on Apr 26 for SFDC-430
            Controller_Approver_Group__c = 'JP - Japan', //added by Nisha Agrawal on Apr 26 for SFDC-430 
            Role__c = 'OEM' ,
            Name_Legal_Name__c = 'Test Convert 1',
            Name_Line_2__c = 'Test',
            Name_Line_3__c = 'Test',
            Name_Line_4__c = 'Test',
            City__c = 'Test',
            Country__c = 'USA',
            State_Province__c = 'Indiana',
            Postal_Code__c = '115',
            PO_Box__c = '115',
            PO_Box_City__c = 'Test',
            PO_Box_Postal_Code__c = '115',
            Telephone__c = '123456789',
            Fax__c = '123456789',
            Email__c = 'test@test.com',
            VAT_Registration_Number__c = '123455555',
            Taxes_Number_1__c = '1234555555',
           Transportation_Zone__c = '123',
            Language__c = 'M - Traditional Chinese',
            Chinese_Name1__c = 'test',
            Street__c = 'Test',
            Street_4__c = 'test',
            Ind_period_account_statement__c = '1 - No account statement needed',
            Tolerance_Group__c = 'DIST - Distributors (10 grace days)',
            Screened_for_SDI__c = 'Yes',
            Controlled_Party__c = 'Yes',
            FLAG_Bill_to__c = True,
            FLAG_Sold_to__c = True,
            FLAG_Ship_to__c = True,
            Street_House_Number__c = 'Test 1',
            Approval_Submission_Date__c = dt1,
            Effective_Date__c = null,
            Update_SAP_CMD_Failed__c = false,
            //Global_Customer_ID__c = '1234567890',
            Name_1_Service_Provider__c ='Test',
            Customer_Type__c = 'Service Provider',
            City_Chinese__c = 'Test',
            Chinese_Name2__c = 'Test',
            Chinese_Street__c = 'Test',
            Additional_VAT_Number_1__c = '123456',
            Additional_VAT_Number_2__c = '123456',  
            Additional_VAT_Number_3__c = '123456',
            Additional_VAT_Number_4__c = '123456',
            Additional_VAT_Number_5__c = '123456',
            Additional_VAT_Number_6__c = '123456',
            Additional_VAT_Number_7__c = '123456',
            Additional_VAT_Number_8__c = '123456',
            Country_Additional_VAT_Number_1__c = 'USA',
            Country_Additional_VAT_Number_2__c = 'USA',
            Country_Additional_VAT_Number_3__c = 'USA',
            Country_Additional_VAT_Number_4__c = 'USA',
            Country_Additional_VAT_Number_5__c = 'USA',
            Country_Additional_VAT_Number_6__c = 'USA',
            Country_Additional_VAT_Number_7__c = 'USA',
            Country_Additional_VAT_Number_8__c = 'USA', 
            Trading_Partner__c = '116202 - NXP Semiconductors Netherlands',
            Global_Account__c = 'ACA - Actia',
            Military_Usage__c = 'Yes - ID for mainly military use',
            Fix_Price_Ind_SP__c = 'Y - Yes',
            Industry_Segment__c = 'CC - Computing',
            Industry_Sub_Segment__c = 'C1 - Computing',
            Acct_at_cust__c = 'Test',
            Currency__c='USD - US Dollar',
            Cust_pric_proc__c = 'D - Disti Pricing',
            Customer_Statistics_Group__c = '1',
            Distribution_Channel__c = 'Test',
            Division__c = 'Test',
            Exch_rate_type__c = '4DEC - NXP Act. Rate',
            Region__c = 'EU - Europe',
            Reprice_Basis__c = 'C - Conf. Delivery Date',
            S_O_Sub_Group__c = 'NL - Netherlands',
            Sales_office__c = 'BOS1 - Bosch',
            Delivery_priority__c = '10 - Priority 1',
            Max_partial_deliveries__c = '1',
            BillCurrency_PY__c = 'Set to BLANK',
            Grp_1_Sls_Channel_SP__c = 'DIS - Distributor',
            Grp_2_Cus_Prce_Grp_SP__c = '018 - Bosch USD',
            Matl_Det_Grp_SP__c = 'ABB - ABB',
            Additional_shipping_mark__c = 'Test',
            Brazil_Specific_Clause__c = 'Test',
            CPNJ_for_Brazil__c = 'Test',
            Freight_Forwarder__c = 'Test',
            Main_shipping_mark__c = 'Test',
            Billing_Block__c = 'Test',
            Central_Billing_Block__c = 'Test',
            Central_delivery_block__c = 'Test',
            FunLoc_Type__c = 'Pure',
            Central_order_block__c = 'Test',
            Delivery_Block__c = 'Test',
            Order_Block__c = 'Test',
            Order_Combination__c = 'Yes',
            Distribution_Region__c = 'E1 - NL00',
            Sales_district__c = 'EC - EU Central',
            Partial_delivery_per_item__c = 'Set to BLANK',
            Reconciliation_Account__c = '1200100 - Trade AR with foreign parties',
            Fixed_Currency_Ind_SP__c = 'Yes',
            Non_I2_related_SP__c = 'Yes',
            Sales_Area_Region__c = 'EU - Europe',
            Accept_Dupl_PO_SP__c  = 'Yes',
            Ch_dupl_PO_item_SP__c = 'Yes',
            Customer_Factory_Calendar__c = '01 - Customer calendar Germany standard',
            Unloading_Point__c = 'test',
            Delivery_Group_Ind_SH__c = 'Set to BLANK',
            Pull_Up_OK_SH__c = 'N - No',
            Rounding_Rule_SH__c = 'C - Round to Closest',
            C_GAD_Indicator_SH__c = 'Yes',
            Shipping_Condition__c  = '01 - Ship via Std Route',
            Incoterms_1__c = 'CPT - Carriage paid to',
            Incoterms_2__c = 'Test',
            Label_Required__c = 'No',
            Company_Code__c = 'NL60 - RSO Europe',
            Sorting_key_for_assignment_no__c = '000 - Allocation number',
            Indicator_Record_Payment_History__c = 'Yes',
            Lockbox__c  = 'EUR',
            Payment_Credit_Memo__c = '014 - Prepaid',
            Reason_Code_Conversion__c = '001 - Version 001',
            Selection_Rule_for_Payment_Advice__c = '002 - Reference',
            Terms_of_Payment__c = '014 - Prepaid',
            
            Account_memo__c = 'test',
            Accounting_Clerk__c = '01 - Jim Chen',
            Act_clerk_fax_number__c = '+886281709999',
            Act_clerk_internet_address__c = 'Test',
            Act_clerk_tel_no__c = '+886281709999',
            User_at_customer__c = 'Test',
            Acct_assgmt_group__c = '01 - Local 3rd Party',
            Payment_Guarantee_Procedure__c = 'Z001 - No guarantee required',
            Terms_of_Payment_Sales__c = '014 - Prepaid',
            Our_account_at_customer__c = 'Test',
            Deletion_Block_Company_Code__c = 'No',
            Deletion_Flag_Company_Code__c = 'No',
            Posting_Block_Company_Code__c = 'No',
            Customer_Service_ZA__c = 'CN214 - Mary Ng',
            Sales_Rep_ZS__c = 'AP004 - Anca Lin',
            Version_ID_for_International_Addresses__c = 'M',
            Tax_Number_5__c = 'Test Tax 5'
        );
        insert theRequest3; 
        
        List<Tax_Classification__c> lstSapTaxes = new List<Tax_Classification__c>();
        
        objCMDTax = new Tax_Classification__c (CMD_Request__c = theRequest3.id, Country__c = 'CA - Canada', Tax_Category__c = 'MWST', Tax_Classification__c ='1');
        lstSapTaxes.add(objCMDTax);
      
        system.debug('3checksaptax'+lstSapTaxes);
        try{
            insert lstSapTaxes;
            } catch(exception e){}
            
        
        theRequest3.Request_Status__c = 'Approved';
        update theRequest3;   
        
        system.assert(theRequest3.Funloc__c != null);
        system.assert(theRequest3.Funloc_SAP_CMD__c != null);
        system.assert(theRequest3.FLAG_ZI__c = true);
        
        //CMD Request with ZI - negative value
        Funloc__c tempLstFunloc4 = [SELECT Id, Funloc_Number_Text__c FROM Funloc__c WHERE Id =: lstFunloc[3].Id];
        
        CMD_Request__c theRequest4 = new CMD_Request__c(
            RecordTypeId = SAP_Funloc_Edit_Request.Id,
            Funloc__c = tempLstFunloc4.FunLoc_Number_Text__c,
            Funloc_SAP_CMD__c = lstSAPCMD[3].Id,
            Consolidated_Account_Code__c = objCACC.Id,
            Global_Customer_ID__c = lstCustomer[0].Id,   
           Ready_to_Submit__c = true,
            Request_Status__c = 'draft',
            Reason_for_request__c = 'Test',
            Sales_Organisation__c = 'NL60 - RSO Europe',
            GCP_Q_Approver_Group__c = 'AMEC Disti',
            //GSM_Controller_Approver_Group__c = 'JAPAN',  //commented by Nisha Agrawal on Apr 26 for SFDC-430
            Controller_Approver_Group__c = 'JP - Japan', //added by Nisha Agrawal on Apr 26 for SFDC-430 
            Role__c = 'OEM' ,
            Name_Legal_Name__c = 'Test Convert 1',
            Name_Line_2__c = 'Test',
            Name_Line_3__c = 'Test',
            Name_Line_4__c = 'Test',
            City__c = 'Test',
            Country__c = 'USA',
            State_Province__c = 'Indiana',
            Postal_Code__c = '115',
            PO_Box__c = '115',
            PO_Box_City__c = 'Test',
            PO_Box_Postal_Code__c = '115',
            Telephone__c = '123456789',
            Fax__c = '123456789',
            Email__c = 'test@test.com',
            VAT_Registration_Number__c = '123455555',
            Taxes_Number_1__c = '1234555555',
           Transportation_Zone__c = '123',
            Language__c = 'M - Traditional Chinese',
            Chinese_Name1__c = 'test',
            Street__c = 'Test',
            Street_4__c = 'test',
            Ind_period_account_statement__c = '1 - No account statement needed',
            Tolerance_Group__c = 'DIST - Distributors (10 grace days)',
            Screened_for_SDI__c = 'Yes',
            Controlled_Party__c = 'Yes',
            FLAG_Bill_to__c = True,
            FLAG_Sold_to__c = True,
            FLAG_Ship_to__c = True,
            Street_House_Number__c = 'Test 1',
            Approval_Submission_Date__c = dt1,
            Effective_Date__c = null,
            Update_SAP_CMD_Failed__c = false,
            //Global_Customer_ID__c = '1234567890',
            Name_1_Service_Provider__c ='Test',
            Customer_Type__c = 'Service Provider',
            City_Chinese__c = 'Test',
            Chinese_Name2__c = 'Test',
            Chinese_Street__c = 'Test',
            Additional_VAT_Number_1__c = '123456',
            Additional_VAT_Number_2__c = '123456',  
            Additional_VAT_Number_3__c = '123456',
            Additional_VAT_Number_4__c = '123456',
            Additional_VAT_Number_5__c = '123456',
            Additional_VAT_Number_6__c = '123456',
            Additional_VAT_Number_7__c = '123456',
            Additional_VAT_Number_8__c = '123456',
            Country_Additional_VAT_Number_1__c = 'USA',
            Country_Additional_VAT_Number_2__c = 'USA',
            Country_Additional_VAT_Number_3__c = 'USA',
            Country_Additional_VAT_Number_4__c = 'USA',
            Country_Additional_VAT_Number_5__c = 'USA',
            Country_Additional_VAT_Number_6__c = 'USA',
            Country_Additional_VAT_Number_7__c = 'USA',
            Country_Additional_VAT_Number_8__c = 'USA', 
            Trading_Partner__c = '116202 - NXP Semiconductors Netherlands',
            Global_Account__c = 'ACA - Actia',
            Military_Usage__c = 'Yes - ID for mainly military use',
            Fix_Price_Ind_SP__c = 'Y - Yes',
            Industry_Segment__c = 'CC - Computing',
            Industry_Sub_Segment__c = 'C1 - Computing',
            Acct_at_cust__c = 'Test',
            Currency__c='USD - US Dollar',
            Cust_pric_proc__c = 'D - Disti Pricing',
            Customer_Statistics_Group__c = '1',
            Distribution_Channel__c = 'Test',
            Division__c = 'Test',
            Exch_rate_type__c = '4DEC - NXP Act. Rate',
            Region__c = 'EU - Europe',
            Reprice_Basis__c = 'C - Conf. Delivery Date',
            S_O_Sub_Group__c = 'NL - Netherlands',
            Sales_office__c = 'BOS1 - Bosch',
            Delivery_priority__c = '10 - Priority 1',
            Max_partial_deliveries__c = '1',
            BillCurrency_PY__c = 'EUR - Euro',
            Grp_1_Sls_Channel_SP__c = 'DIS - Distributor',
            Grp_2_Cus_Prce_Grp_SP__c = '018 - Bosch USD',
            Matl_Det_Grp_SP__c = 'ABB - ABB',
            Additional_shipping_mark__c = 'Test',
            Brazil_Specific_Clause__c = 'Test',
            CPNJ_for_Brazil__c = 'Test',
            Freight_Forwarder__c = 'Test',
            Main_shipping_mark__c = 'Test',
            Billing_Block__c = 'Test',
            Central_Billing_Block__c = 'Test',
            Central_delivery_block__c = 'Test',
            FunLoc_Type__c = 'Pure',
            Central_order_block__c = 'Test',
            Delivery_Block__c = 'Test',
            Order_Block__c = 'Test',
            Order_Combination__c = 'Yes',
            Distribution_Region__c = 'E1 - NL00',
            Sales_district__c = 'EC - EU Central',
            Partial_delivery_per_item__c = 'C - Only complete delivery allowed',
            Reconciliation_Account__c = '1200100 - Trade AR with foreign parties',
            Fixed_Currency_Ind_SP__c = 'Yes',
            Non_I2_related_SP__c = 'Yes',
            Sales_Area_Region__c = 'EU - Europe',
            Accept_Dupl_PO_SP__c  = 'Yes',
            Ch_dupl_PO_item_SP__c = 'Yes',
            Customer_Factory_Calendar__c = '01 - Customer calendar Germany standard',
            Unloading_Point__c = 'test',
            Delivery_Group_Ind_SH__c = '01 - Sh per single line',
            Pull_Up_OK_SH__c = 'N - No',
            Rounding_Rule_SH__c = 'C - Round to Closest',
            C_GAD_Indicator_SH__c = 'Yes',
            Shipping_Condition__c  = '01 - Ship via Std Route',
            Incoterms_1__c = 'CPT - Carriage paid to',
            Incoterms_2__c = 'Test',
            Label_Required__c = 'No',
            Company_Code__c = 'NL60 - RSO Europe',
            Sorting_key_for_assignment_no__c = '000 - Allocation number',
            Indicator_Record_Payment_History__c = 'Yes',
            Lockbox__c  = 'EUR',
            Payment_Credit_Memo__c = '014 - Prepaid',
            Reason_Code_Conversion__c = '001 - Version 001',
            Selection_Rule_for_Payment_Advice__c = '002 - Reference',
            Terms_of_Payment__c = '014 - Prepaid',
            
            Account_memo__c = 'test',
            Accounting_Clerk__c = '01 - Jim Chen',
            Act_clerk_fax_number__c = '+886281709999',
            Act_clerk_internet_address__c = 'Test',
            Act_clerk_tel_no__c = '+886281709999',
            User_at_customer__c = 'Test',
            Acct_assgmt_group__c = '01 - Local 3rd Party',
            Payment_Guarantee_Procedure__c = 'Z001 - No guarantee required',
            Terms_of_Payment_Sales__c = '014 - Prepaid',
            Our_account_at_customer__c = 'Test',
            Deletion_Block_Company_Code__c = 'No',
            Deletion_Flag_Company_Code__c = 'No',
            Posting_Block_Company_Code__c = 'No',
            Customer_Service_ZA__c = 'CN214 - Mary Ng',
            Sales_Rep_ZS__c = 'AP004 - Anca Lin',
            Version_ID_for_International_Addresses__c = 'M'
            //Tax_Number_5__c = 'Test Tax 5'
        );
        insert theRequest4;       
        
       List<Tax_Classification__c> listCMDTaxes = new List<Tax_Classification__c>();
        
        objCMDTaxes = new Tax_Classification__c (CMD_Request__c = theRequest4.id, Country__c = 'DE - Germany', Tax_Category__c = 'MWST', Tax_Classification__c ='1');
        listCMDTaxes.add(objCMDTaxes);
      
        system.debug('5checksaptax'+listCMDTaxes);
        try{
            insert listCMDTaxes;
            } catch(exception e){}
        listCMDTaxes.clear();    
        objCMDTaxes = new Tax_Classification__c (CMD_Request__c = theRequest4.id, Country__c = 'DE - Germany', Tax_Category__c = 'MWST', Tax_Classification__c ='B');
        listCMDTaxes.add(objCMDTaxes);
      
        system.debug('5checksaptax'+listCMDTaxes);
        try{
            insert listCMDTaxes;
            } catch(exception e){}
        
        theRequest4.Request_Status__c = 'Approved';
        update theRequest4;   
        
        system.assert(theRequest4.Funloc__c != null);
        system.assert(theRequest4.Funloc_SAP_CMD__c != null);
        system.assert(theRequest4.FLAG_ZI__c = true);
        
        Funloc__c tempLstFunloc5 = [SELECT Id, Funloc_Number_Text__c FROM Funloc__c WHERE Id =: lstFunloc[4].Id];
        
        CMD_Request__c theRequest5 = new CMD_Request__c(
            RecordTypeId = SAP_Funloc_Edit_Request.Id,
            Funloc__c = tempLstFunloc5.FunLoc_Number_Text__c,
            Funloc_SAP_CMD__c = lstSAPCMD[4].Id,
            Consolidated_Account_Code__c = objCACC.Id,
            Global_Customer_ID__c = lstCustomer[0].Id,        
            Ready_to_Submit__c = true,
            Request_Status__c = 'draft',
            Reason_for_request__c = 'Test',
            Sales_Organisation__c = 'NL60 - RSO Europe',
            GCP_Q_Approver_Group__c = 'AMEC Disti',
            //GSM_Controller_Approver_Group__c = 'JAPAN',  //commented by Nisha Agrawal on Apr 26 for SFDC-430
            Controller_Approver_Group__c = 'JP - Japan', //added by Nisha Agrawal on Apr 26 for SFDC-430 
            Role__c = 'OEM' ,
            Name_Legal_Name__c = 'Test Convert 1',
            Name_1_Service_Provider__c = '#Remove#',
            Name_Line_2__c = '#Remove#',
            Name_Line_3__c = '#Remove#',
            Name_Line_4__c = '#Remove#',
            City__c = '#Remove#',
            Country__c = 'USA',
            State_Province__c = 'Indiana',
            Postal_Code__c = '#Remove#',
            PO_Box__c = '#Remove#',
            PO_Box_City__c = '#Remove#',
            PO_Box_Postal_Code__c = '#Remove#',
            Telephone__c = '#Remove#',
            Fax__c = '#Remove#',
            Email__c = 'email@remove.com',
            VAT_Registration_Number__c = '#Remove#',
            Taxes_Number_1__c = '#Remove#',
            Transportation_Zone__c = '123',
            Language__c = 'M - Traditional Chinese',
            Chinese_Name1__c = '#Remove#',
            Street__c = 'Test',
            Street_4__c = 'test',
            Ind_period_account_statement__c = '1 - No account statement needed',
            Tolerance_Group__c = 'DIST - Distributors (10 grace days)',
            Screened_for_SDI__c = 'No',
            Controlled_Party__c = 'No',
            FLAG_Bill_to__c = True,
            FLAG_Sold_to__c = True,
            FLAG_Ship_to__c = True,
            Street_House_Number__c = 'Test 1',
            Approval_Submission_Date__c = dt2,
            Effective_Date__c = null,
            Update_SAP_CMD_Failed__c = false,
           // Name_1_Service_Provider__c ='Test',
            Customer_Type__c = 'Service Provider',
            City_Chinese__c = '#Remove#',
            Chinese_Name2__c = '#Remove#',
            Chinese_Street__c = '#Remove#',
            Additional_VAT_Number_1__c = '#Remove#',
            Additional_VAT_Number_2__c = '#Remove#',  
            Additional_VAT_Number_3__c = '#Remove#',
            Additional_VAT_Number_4__c = '#Remove#',
            Additional_VAT_Number_5__c = '#Remove#',
            Additional_VAT_Number_6__c = '#Remove#',
            Additional_VAT_Number_7__c = '#Remove#',
            Additional_VAT_Number_8__c = '#Remove#',
            Country_Additional_VAT_Number_1__c = 'Set to BLANK',
            Country_Additional_VAT_Number_2__c = 'Set to BLANK',
            Country_Additional_VAT_Number_3__c = 'Set to BLANK',
            Country_Additional_VAT_Number_4__c = 'Set to BLANK',
            Country_Additional_VAT_Number_5__c = 'Set to BLANK',
            Country_Additional_VAT_Number_6__c = 'Set to BLANK',
            Country_Additional_VAT_Number_7__c = 'Set to BLANK',
            Country_Additional_VAT_Number_8__c = 'Set to BLANK',
           Trading_Partner__c = '116202 - NXP Semiconductors Netherlands',
            Global_Account__c = 'ACA - Actia',
            Military_Usage__c = 'Yes - ID for mainly military use',
            Fix_Price_Ind_SP__c = 'Y - Yes',
            Industry_Segment__c = 'CC - Computing',
            Industry_Sub_Segment__c = 'C1 - Computing',
          //  Acct_at_cust__c = 'Test',
            Currency__c='USD - US Dollar',
            Cust_pric_proc__c = 'D - Disti Pricing',
            Customer_Statistics_Group__c = '1',
            Distribution_Channel__c = 'Test',
            Division__c = 'Test',
            Exch_rate_type__c = '4DEC - NXP Act. Rate',
            Region__c = 'EU - Europe',
            Reprice_Basis__c = 'C - Conf. Delivery Date',
            S_O_Sub_Group__c = 'NL - Netherlands',
            Sales_office__c = 'BOS1 - Bosch',
            Delivery_priority__c = '10 - Priority 1',
            Max_partial_deliveries__c = '1',
            
            BillCurrency_PY__c = 'Set to BLANK',
            Grp_1_Sls_Channel_SP__c = 'DIS - Distributor',
            Grp_2_Cus_Prce_Grp_SP__c = 'Set to BLANK',
            Matl_Det_Grp_SP__c = 'Set to Blank',
          //  Additional_shipping_mark__c = 'Test',
            Brazil_Specific_Clause__c = '#Remove#',
            CPNJ_for_Brazil__c = '#Remove#',
          //  Freight_Forwarder__c = 'Test',
          //  Main_shipping_mark__c = 'Test',
          //  Billing_Block__c = 'Test',
            Central_Billing_Block__c = '#Remove#',
            Central_delivery_block__c = '#Remove#',
            FunLoc_Type__c = 'Pure',
            Central_order_block__c = '#Remove#',
            Delivery_Block__c = '#Remove#',
           // Order_Block__c = 'Test',
            Order_Combination__c = 'No',
             Distribution_Region__c = 'E1 - NL00',
                Sales_district__c = 'EC - EU Central',
            Partial_delivery_per_item__c = 'C - Only complete delivery allowed',
            Reconciliation_Account__c = '1200100 - Trade AR with foreign parties',
            Fixed_Currency_Ind_SP__c = 'Yes',
            Non_I2_related_SP__c = 'Yes',
            Sales_Area_Region__c = 'EU - Europe',
            Accept_Dupl_PO_SP__c  = 'Yes',
            Ch_dupl_PO_item_SP__c = 'Yes',
            Customer_Factory_Calendar__c = '01 - Customer calendar Germany standard',
            Unloading_Point__c = 'test',
            Delivery_Group_Ind_SH__c = 'Set to BLANK',
            C_GAD_Indicator_SH__c = 'No',
            Indicator_Record_Payment_History__c = 'No',
            Deletion_Block_Company_Code__c = 'Yes',
            Deletion_Flag_Company_Code__c = 'Yes',
            Central_deletion_block__c= 'No',
            Central_deletion_Flag__c = 'No',
            Central_posting_block__c = 'No',
            Deletion_Flag_Sales_Area__c = 'No',
            Posting_Block_Company_Code__c = 'Yes',
            Key_for_Payment_Grouping__c = '01 - Document types',
            Customer_Service_ZA__c = 'CN214 - Mary Ng',
            Sales_Rep_ZS__c = 'AP004 - Anca Lin',
            Label_Required__c = 'Yes',
            Label_Code__c = '#Remove#',
            Tax_Number_5__c = '#Remove#',
            Act_clerk_fax_number__c = '+9999999999',
            Our_account_at_customer__c = '#Remove#',
            User_at_customer__c = '#Remove#',
            Act_clerk_internet_address__c = '#Remove#',
            Act_clerk_tel_no__c = '+9999999999',
            Account_memo__c = '#Remove#',
            Acct_at_cust__c = '#Remove#',
            Order_Block__c = '#Remove#',
            Billing_Block__c = '#Remove#',
            Main_shipping_mark__c = '#Remove#',
            Additional_Shipping_Mark__c = '#Remove#',
            Freight_Forwarder__c = '#Remove#',
            Version_ID_for_International_Addresses__c = 'Set to BLANK'
        );
        insert theRequest5;       
        
        Funloc__c tempLstFunloc6 = [SELECT Id, Funloc_Number_Text__c FROM Funloc__c WHERE Id =: lstFunloc[5].Id];
        
        CMD_Request__c theRequest6 = new CMD_Request__c(
            RecordTypeId = SAP_Funloc_Edit_Request.Id,
            Funloc__c = tempLstFunloc6.FunLoc_Number_Text__c,
            Funloc_SAP_CMD__c = lstSAPCMD[5].Id,
            Consolidated_Account_Code__c = objCACC.Id,
            Global_Customer_ID__c = lstCustomer[0].Id,        
            Ready_to_Submit__c = true,
            Request_Status__c = 'draft',
            Reason_for_request__c = 'Test',
            Sales_Organisation__c = 'NL60 - RSO Europe',
            GCP_Q_Approver_Group__c = 'AMEC Disti',
            //GSM_Controller_Approver_Group__c = 'JAPAN',  //commented by Nisha Agrawal on Apr 26 for SFDC-430
            Controller_Approver_Group__c = 'JP - Japan', //added by Nisha Agrawal on Apr 26 for SFDC-430 
            Role__c = 'OEM' ,
            Name_Legal_Name__c = 'Test Convert 1',
            Name_1_Service_Provider__c = '#Remove#',
            Name_Line_2__c = '#Remove#',
            Name_Line_3__c = '#Remove#',
            Name_Line_4__c = '#Remove#',
            City__c = '#Remove#',
            Country__c = 'USA',
            State_Province__c = 'Indiana',
            Postal_Code__c = '#Remove#',
            PO_Box__c = '#Remove#',
            PO_Box_City__c = '#Remove#',
            PO_Box_Postal_Code__c = '#Remove#',
            Telephone__c = '#Remove#',
            Fax__c = '#Remove#',
            Email__c = 'email@remove.com',
            VAT_Registration_Number__c = '#Remove#',
            Taxes_Number_1__c = '#Remove#',
            Transportation_Zone__c = '123',
            Language__c = 'M - Traditional Chinese',
            Chinese_Name1__c = '#Remove#',
            Street__c = 'Test',
            Street_4__c = 'test',
            Ind_period_account_statement__c = '1 - No account statement needed',
            Tolerance_Group__c = 'DIST - Distributors (10 grace days)',
            Screened_for_SDI__c = 'No',
            Controlled_Party__c = 'No',
            FLAG_Bill_to__c = True,
            FLAG_Sold_to__c = True,
            FLAG_Ship_to__c = True,
            Street_House_Number__c = 'Test 1',
            Approval_Submission_Date__c = dt2,
            Effective_Date__c = null,
            Update_SAP_CMD_Failed__c = false,
           // Name_1_Service_Provider__c ='Test',
            Customer_Type__c = 'Service Provider',
            City_Chinese__c = '#Remove#',
            Chinese_Name2__c = '#Remove#',
            Chinese_Street__c = '#Remove#',
            Additional_VAT_Number_1__c = '#Remove#',
            Additional_VAT_Number_2__c = '#Remove#',  
            Additional_VAT_Number_3__c = '#Remove#',
            Additional_VAT_Number_4__c = '#Remove#',
            Additional_VAT_Number_5__c = '#Remove#',
            Additional_VAT_Number_6__c = '#Remove#',
            Additional_VAT_Number_7__c = '#Remove#',
            Additional_VAT_Number_8__c = '#Remove#',
            Country_Additional_VAT_Number_1__c = 'Set to BLANK',
            Country_Additional_VAT_Number_2__c = 'Set to BLANK',
            Country_Additional_VAT_Number_3__c = 'Set to BLANK',
            Country_Additional_VAT_Number_4__c = 'Set to BLANK',
            Country_Additional_VAT_Number_5__c = 'Set to BLANK',
            Country_Additional_VAT_Number_6__c = 'Set to BLANK',
            Country_Additional_VAT_Number_7__c = 'Set to BLANK',
            Country_Additional_VAT_Number_8__c = 'Set to BLANK',
           Trading_Partner__c = '116202 - NXP Semiconductors Netherlands',
            Global_Account__c = 'ACA - Actia',
            Military_Usage__c = 'Yes - ID for mainly military use',
            Fix_Price_Ind_SP__c = 'Y - Yes',
            Industry_Segment__c = 'CC - Computing',
            Industry_Sub_Segment__c = 'C1 - Computing',
         //   Acct_at_cust__c = 'Test',
            Currency__c='USD - US Dollar',
            Cust_pric_proc__c = 'D - Disti Pricing',
            Customer_Statistics_Group__c = '1',
            Distribution_Channel__c = 'Test',
            Division__c = 'Test',
            Exch_rate_type__c = '4DEC - NXP Act. Rate',
            Region__c = 'EU - Europe',
            Reprice_Basis__c = 'C - Conf. Delivery Date',
            S_O_Sub_Group__c = 'NL - Netherlands',
            Sales_office__c = 'BOS1 - Bosch',
            Delivery_priority__c = '10 - Priority 1',
            Max_partial_deliveries__c = '1',
            BillCurrency_PY__c = 'Set to BLANK',
            Grp_1_Sls_Channel_SP__c = 'DIS - Distributor',
            Grp_2_Cus_Prce_Grp_SP__c = 'Set to BLANK',
            Matl_Det_Grp_SP__c = 'Set to Blank',
          //  Additional_shipping_mark__c = 'Test',
            Brazil_Specific_Clause__c = '#Remove#',
            CPNJ_for_Brazil__c = '#Remove#',
          //  Freight_Forwarder__c = 'Test',
          //  Main_shipping_mark__c = 'Test',
          //  Billing_Block__c = 'Test',
            Central_Billing_Block__c = '#Remove#',
            Central_delivery_block__c = '#Remove#',
            FunLoc_Type__c = 'Pure',
            Central_order_block__c = '#Remove#',
            Delivery_Block__c = '#Remove#',
           // Order_Block__c = 'Test',
          Order_Combination__c = 'Yes',
            Distribution_Region__c = 'E1 - NL00',
            Sales_district__c = 'EC - EU Central',
            Partial_delivery_per_item__c = 'C - Only complete delivery allowed',
            Reconciliation_Account__c = '1200100 - Trade AR with foreign parties',
            Fixed_Currency_Ind_SP__c = 'Yes',
            Non_I2_related_SP__c = 'Yes',
            Sales_Area_Region__c = 'EU - Europe',
            Accept_Dupl_PO_SP__c  = 'Yes',
            Ch_dupl_PO_item_SP__c = 'Yes',
            Customer_Factory_Calendar__c = '01 - Customer calendar Germany standard',
            Unloading_Point__c = 'test',
            Delivery_Group_Ind_SH__c = 'Set to BLANK',
            C_GAD_Indicator_SH__c = 'No',
            Indicator_Record_Payment_History__c = 'No',
            Deletion_Block_Company_Code__c = 'Yes',
            Deletion_Flag_Company_Code__c = 'Yes',
            Central_deletion_block__c= 'No',
            Central_deletion_Flag__c = 'No',
            Central_posting_block__c = 'No',
            Deletion_Flag_Sales_Area__c = 'No',
            Posting_Block_Company_Code__c = 'Yes',
            Key_for_Payment_Grouping__c = '01 - Document types',
           Customer_Service_ZA__c = 'CN214 - Mary Ng',
            Sales_Rep_ZS__c = 'AP004 - Anca Lin',
            Label_Required__c = 'Yes',
            Label_Code__c = '#Remove#',
            Tax_Number_5__c = '#Remove#',
            Act_clerk_fax_number__c = '+9999999999',
            Our_account_at_customer__c = '#Remove#',
            User_at_customer__c = '#Remove#',
            Act_clerk_internet_address__c = '#Remove#',
            Act_clerk_tel_no__c = '+9999999999',
            Account_memo__c = '#Remove#',
            Acct_at_cust__c = '#Remove#',
            Order_Block__c = '#Remove#',
            Billing_Block__c = '#Remove#',
            Main_shipping_mark__c = '#Remove#',
            Additional_Shipping_Mark__c = '#Remove#',
            Freight_Forwarder__c = '#Remove#',
            Version_ID_for_International_Addresses__c = 'Set to BLANK'
        );
        insert theRequest6;
        
        
        
        List<cmd_request__c> listcmdreq = new List<cmd_request__c>();
        theRequest6.Request_Status__c = 'Approved';
        listcmdreq.add(theRequest6); 
        //update theRequest6;  
        
        theRequest5.Request_Status__c = 'Approved';
        listcmdreq.add(theRequest5);
        update listcmdreq;
        
        Partner_Function__c Pfunc = [Select Id,name,Person_Name__c from Partner_Function__c where Person_Name__c = 'AP004 - Anca Lin'];
        Delete Pfunc;
        
        test.stopTest();
        
        system.assert(theRequest5.Funloc__c != null);
        system.assert(theRequest5.Funloc_SAP_CMD__c != null);
        system.assert(theRequest5.FLAG_Sold_to__c == true);  
        system.assert(theRequest5.FLAG_Ship_to__c == true);   
        //system.assert(theRequest2.FLAG_Payer__c == true); 
        system.assert(theRequest5.FLAG_Bill_to__c == true); 
        
        Convert_Request_to_SAP_CMD convertRequests = new Convert_Request_to_SAP_CMD();
        
        List<Sap_cmd__c> sapcmdrec = [select Id,Name_2__c,Name_3__c,Name_4__c,Country_Additional_VAT_Number_1__c,Act_clerk_fax_number__c,Email__c,Version_ID_for_International_Addresses__c,Act_clerk_tel_no__c from Sap_cmd__c where Id =: lstSAPCMD[4].Id OR ID =: lstSAPCMD[5].Id];
        system.assertEquals(sapcmdrec[0].Name_2__c,null);
        system.assertEquals(sapcmdrec[1].Name_3__c,null);
        system.assertEquals(sapcmdrec[0].Name_4__c,null);
        system.assertEquals(sapcmdrec[0].Country_Additional_VAT_Number_1__c,null);
        system.assertEquals(sapcmdrec[0].Act_clerk_fax_number__c,null);
        system.assertEquals(sapcmdrec[1].Email__c,null);
        system.assertEquals(sapcmdrec[1].Version_ID_for_International_Addresses__c,null);
        system.assertEquals(sapcmdrec[0].Act_clerk_tel_no__c,null);
        
      /*  Sap_cmd__c sapcmdrec1 = [select Id,Name_2__c,Country_Additional_VAT_Number_1__c,Act_clerk_fax_number__c,Email__c,Act_clerk_tel_no__c from Sap_cmd__c where Id =: lstSAPCMD[5].Id];
        system.assertEquals(sapcmdrec1.Name_2__c,null);
        system.assertEquals(sapcmdrec1.Country_Additional_VAT_Number_1__c,null);
        system.assertEquals(sapcmdrec1.Act_clerk_fax_number__c,null);
        system.assertEquals(sapcmdrec1.Email__c,null);
        system.assertEquals(sapcmdrec1.Act_clerk_tel_no__c,null); */
        
    }
}