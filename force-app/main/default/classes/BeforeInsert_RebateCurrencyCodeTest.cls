/*********************************************************************************
Name           :    UpdateStdCurrency
Author         :    Naveen
Date           :    23 June 2019
Description    :   SBE Team report have Rebate Actual Payout Current Issues            
**********************************************************************************/

@isTest
Public class BeforeInsert_RebateCurrencyCodeTest
{
    
       @testSetup
   static void createFunloc(){
   /*
      List<Funloc__c>  lstFunloc = new List<Funloc__c>();
        
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
        */
    }
    
    static testMethod void BeforeInsert_RebateCurrencyCode1() 
    {
        //prepare test data
        //insert approver users
         List<Funloc__c>  lstFunloc = new List<Funloc__c>();
        
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
        List<Profile> lstProfiles =[Select Id, Name From Profile Where Name = 'Standard User' Limit 1 ];
        if(lstProfiles.size() > 0)
        {
            Profile objProfile = lstProfiles[0];
            List<User> lstApprovers = TestUtil.createTestUsers(objProfile.Id, 10);
            insert lstApprovers;
            
            User objApttusChecker = lstApprovers[0];            
            User objLegal = lstApprovers[1];
            User objCorpCotrol = lstApprovers[2];
            User objGlobalSalesOPS = lstApprovers[3];
            User objRegionalController = lstApprovers[4];
            User objRegionalChannelController = lstApprovers[5];
            User objGlobalChannelController = lstApprovers[6];
            User objRegionalDistiManager = lstApprovers[7];
            User objRegionalSalesManager  = lstApprovers[8];
            User objGSMController = lstApprovers[9];

            system.assert(objApttusChecker.Id != null);                        
            system.assert(objLegal.Id != null);
            system.assert(objCorpCotrol.Id != null);
            system.assert(objGlobalSalesOPS.Id != null);
            system.assert(objRegionalController.Id != null);
            system.assert(objRegionalChannelController.Id != null);            
            system.assert(objGlobalChannelController.Id != null);
            system.assert(objRegionalDistiManager.Id != null);
            system.assert(objRegionalSalesManager.Id != null);
            system.assert(objGSMController.Id != null);
                    
            //insert approver matrix
            List<Rebate_Approver_Matrix__c> lstRebateApprovers = new List<Rebate_Approver_Matrix__c>();
            lstRebateApprovers.add(new Rebate_Approver_Matrix__c(Region__c = 'EMEA' , Role__c = 'Apttus Aggrement Checker' , Approver__c = objApttusChecker.Id));
            lstRebateApprovers.add(new Rebate_Approver_Matrix__c(Region__c = 'EMEA' , Role__c = 'Legal' , Approver__c = objLegal.Id));
            lstRebateApprovers.add(new Rebate_Approver_Matrix__c(Region__c = 'EMEA' , Role__c = 'Corporate Control' , Approver__c = objCorpCotrol.Id));
            lstRebateApprovers.add(new Rebate_Approver_Matrix__c(Region__c = 'EMEA' , Role__c = 'Global Sales & OPS Manager' , Approver__c = objGlobalSalesOPS.Id));
            lstRebateApprovers.add(new Rebate_Approver_Matrix__c(Region__c = 'EMEA' , Role__c = 'Regional Controller' , Approver__c = objRegionalController.Id));           
          
            lstRebateApprovers.add(new Rebate_Approver_Matrix__c(Region__c = 'EMEA', Program_Type__c = 'OEM / EMS' , Role__c = 'Regional Channel Controller' , Approver__c = objRegionalChannelController.Id));
            lstRebateApprovers.add(new Rebate_Approver_Matrix__c(Region__c = 'EMEA' , Role__c = 'Global Channel Controller' , Approver__c = objGlobalChannelController.Id));
            lstRebateApprovers.add(new Rebate_Approver_Matrix__c(Region__c = 'EMEA' , Role__c = 'Regional Disti Manager' , Approver__c = objRegionalDistiManager.Id));
            lstRebateApprovers.add(new Rebate_Approver_Matrix__c(Region__c = 'EMEA' , Role__c = 'Regional Sales Manager' , Approver__c = objRegionalSalesManager.Id));
            lstRebateApprovers.add(new Rebate_Approver_Matrix__c(Region__c = 'EMEA' , Role__c = 'GSM Controller' , Approver__c = objGSMController.Id));
            
            insert lstRebateApprovers;
            
            for(Rebate_Approver_Matrix__c objApprover : lstRebateApprovers)
            {
                system.assert(objApprover.Id != null);
            }
            
            //insert FX_Rates       
            FX_Rates__c rebateCurrency = new FX_Rates__c(Name = 'USD' , Currency_Code__c = 'USD');
            insert rebateCurrency;          
            system.assert(rebateCurrency.Id != null);
           
            //insert Consolidated Account code
            Consolidated_Account_Code__c objCACC = new Consolidated_Account_Code__c();
            objCACC.Code_Description__c='123';
            insert objCACC;
            system.assert(objCACC.Id != null);
            
            Test.startTest();
            
            //insert eRebate
            eRebate__c objRebate = new eRebate__c(Rebate_Program_Name__c = 'ut_program' , End_Customer__c ='ut_endcustomer', 
                Rebate_End_Date__c = date.today().addDays(30) , Rebate_Effective_Date__c = date.today() , Sales_Region__c = 'EMEA' , 
                Rebate_Currency__c = rebateCurrency.Id,  CurrencyIsoCode = 'USD', Apttus_Agreement__c = true, 
                Apttus_Agreement_Number__c ='1234',Approval_Status__c='Approved', Consolidated_Account_Code_Description__c = objCACC.Id, Industry_Segment__c = 'Computing',Programe_Type__c = 'OEM / EMS');
            insert objRebate;
            system.assert(objRebate.Id != null);
            
             //assert the result            
            objRebate = [Select Id , Apttus_Rebate_Checker__c,  Legal__c , Corporate_Controller__c , Global_Sales_OPS_Manager__c , Regional_Controller__c ,  Regional_Channel_Controller__c ,  Global_Channel_Controller__c , Regional_Disti_Manager__c,
                            Regional_Sales_Manager__c , GSM_Controller__c , BL_Marketing_Mgr_1__c , BL_Marketing_Mgr_2__c , BL_Marketing_Mgr_3__c , BL_Marketing_Mgr_4__c , BL_Marketing_Mgr_5__c , BL_Marketing_Mgr_6__c ,
                            BL_Marketing_Mgr_7__c , BL_Marketing_Mgr_8__c
                        From eRebate__c
                        Where Id =: objRebate.Id limit 1];
                        
               integer numOfProducts = 100;
        integer i;
        
       //insert products
        List<Product2> lstProducts = new List<Product2>();
        Product2 objProduct;
        
        for(i =0; i < numOfProducts ;  i++)
        {
            objProduct = new Product2(Name = 'ut_product' + i , ProductCode = 'ut_code' + i, MAG__c = 'ut_mag' + i, isActive = true);
            lstProducts.add(objProduct);
        }
        insert lstProducts;
        
        system.assert(objRebate.Id != null);
        
         eRebate_Payout__c ObjRebatePayout = new eRebate_Payout__c(eRebate__c=objRebate.Id,PO_Number__c='4566',Sales_Organization__c='CN60',Customer__c='7897465',Condition_Type__c='ZDMN',Distribution_Channel__c='00',Division__c='00',Sales_Document_Type__c='GL',Reason_Code__c='P02',
         Sold_To_Funloc__c= lstFunloc[0].Id,Ship_To_Funloc__c=lstFunloc[0].Id,Description__c='test',Exchange_Rate__c=1);           
                        
         insert ObjRebatePayout;
         
         system.assert(ObjRebatePayout.Id != null);
         
         eRebate_Payout_Line_Item__c ObjrebLineItem = new eRebate_Payout_Line_Item__c(eRebate_Payout__c=ObjRebatePayout.Id,MAG_Code__c='R05 | 432225238041',Actual_Payout__c=20);
         insert ObjrebLineItem;
         
         system.assert(ObjrebLineItem.Id != null);
         
            }
        }
   }