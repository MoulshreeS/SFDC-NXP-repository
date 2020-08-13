/***************************************************************************************************
@Created By :       Nisha Agrawal
@Created Date:      19 Jun 2013
@Description:       To generate funloc number automatically. 
-----------------------------------------------------------------------------------------------------------
@Modified By :     Baji
@Modified Date:    10 Sep 2015
@Description:      Modified to generate funloc number in different range for NXP/Julie based on 'funloc range' field.
-----------------------------------------------------------------------------------------------------------
@Modified By :     Scarlett Kang
@Modified Date:    10 Nov 2015
@Description:      1510 Hot-fix, SIR 567 - Change WeEn Funloc Range to 742100 - 748000
-----------------------------------------------------------------------------------------------------------
@Modified By:     Scarlett Kang
@Modified Date:   25 Feb 2016
@Description:     1602 Hot-fix, SIR 751 - Cannot insert Funloc (System create duplicate Funloc Number)
-----------------------------------------------------------------------------------------------------------
@Modified By:     Rex Lai
@Modified Date:   08 Sep 2017
@Description:     1709 Hot-fix, SFDC-923 - Modify NXP Funloc upper range from 440000 to 439960
---------------------------------------------------------------------------------------------------------------
@Modified by : Naveen
@Date : 12/17/2018
@Description - SFDC-2463 Extend the range of NXP Funloc
----------------------------------------------------------------------------------------------------------------
@Modified by : Ankita
@Date :   19 Sep 2019
@Description - SFDC-3227 As CMD Team, Enhance Funloc Object (Make the Funloc Name field more meaning for and The logic to generate Funloc Num)
----------------------------------------------------------------------------------------------------------------
@Modified by : Ankita
@Date : 26 Sep 2019
@Description: SFDC- 3227 Replacing the hardcoded Funloc Ranges with code that fetch the same from custom metadata
-------------------------------------------------------------------------------------------------------------------
@Modified by : Ankita
@Date : 03 Oct 2019
@Description: SFDC-3227 Added logic for handling before update event
------------------------------------------------------------------------------------------------------------------
@Modified by : Ankita
@Date : 19 Nov 2019
@Description : SFDC-3464 : As part of optimizing the Funloc Before trigger, shifted logic to this handler class
------------------------------------------------------------------------------------------------------------------
*******************************************************************************************************/
public class Funloc_trigger_handler
{
        
        public static List <Integer> Ranges = new List<Integer>();
        public static Integer FUNLOC_LOWER_NXP,FUNLOC_UPPER_NXP,FUNLOC_LOWER_JULIE,FUNLOC_UPPER_JULIE ;
        
        public static void FunlocRangeSetting()
        {
            Funloc_Range__mdt[] FR = [Select Range__c from Funloc_Range__mdt ORDER BY Range__c ASC];
            if(FR!=null || FR.size()>0 )
            {
                for(Funloc_Range__mdt f : FR)
                {
                    Ranges.add(Integer.valueOf(f.Range__c));    
                }
                FUNLOC_LOWER_NXP = Ranges[0];
                FUNLOC_UPPER_NXP = Ranges[1];
                FUNLOC_LOWER_JULIE = Ranges[2];
                FUNLOC_UPPER_JULIE  = Ranges[3];
            }
        }

        public static void getFunlocRange(List<Funloc__c> FunlocRequestList)
        {
            FunlocRangeSetting();
            
            integer j=0, i=0;
            Decimal  nxpFunlocNumber;
            Set<Decimal> FunlocAllValues = new Set<Decimal>();
            List<FunLoc__c> lstNxpFunlocs = new List<FunLoc__c>();
            Set<Decimal> FunlocExistingValues = new Set<Decimal>();
            Set <Decimal> FunlocMissedValues = new Set <Decimal>();
            List<Decimal> Fl=new List<Decimal>();
            integer julieFunlocNumber = 0; 
            
            //FOR JULIE FUNLOC RANGE
            List<FunLoc__c> lstJulieFunlocs = [Select Id , FunLoc_Number__c
                                     From FunLoc__c 
                                     Where
                                     FunLoc_Number__c > : FUNLOC_LOWER_JULIE  and FunLoc_Number__c < : FUNLOC_UPPER_JULIE                                        
                                     Order By FunLoc_Number__c DESC
                                     Limit 1];
 
            if(lstJulieFunlocs.size() > 0)
            {
                    julieFunlocNumber = lstJulieFunlocs[0].FunLoc_Number__c.intValue() + 1;
            }
            else
            {
                    julieFunlocNumber = FUNLOC_LOWER_JULIE + 1;
            }
            
            // for NXP funloc Range    

            for(i= FUNLOC_LOWER_NXP+1; i<FUNLOC_UPPER_NXP;i++)
            {
                    FunlocAllValues.add(i);
            }
            lstNxpFunlocs = [Select Id,FunLoc_Number__c From FunLoc__c Where FunLoc_Number__c > : FUNLOC_LOWER_NXP
                 and FunLoc_Number__c < : FUNLOC_UPPER_NXP AND Funloc_Range__c = 'NXP' Order By FunLoc_Number__c];
                 
            for(FunLoc__c f : lstNxpFunlocs){
                    FunlocExistingValues.add(f.FunLoc_Number__c);
            }

            for (Decimal k : FunlocAllValues)
            {
                    if(!FunlocExistingValues.contains(k))
                    {
                        FunlocMissedValues.add(k);
                    }
            } 
       
            Fl.addAll(FunlocMissedValues);
            if(Fl.size()>0)
            {
                    nxpFunlocNumber = Fl[0];   
            }

            for(FunLoc__c objFunloc : FunlocRequestList)
            {

                    // for NXP funloc
                    if(objFunloc.FunLoc_Number__c == null && objFunloc.Funloc_Range__c == 'NXP')
                    {
                            objFunloc.FunLoc_Number__c = nxpFunlocNumber;
                            objFunloc.Name = String.valueOf(Integer.valueof(objFunloc.FunLoc_Number__c));
                            nxpFunlocNumber ++;    
                    }   
                    // for Julie funloc
                    if(objFunloc.FunLoc_Number__c == null && objFunloc.Funloc_Range__c == 'WeEN')
                    {
                            objFunloc.FunLoc_Number__c = julieFunlocNumber;
                            julieFunlocNumber++;    
                    }   
            } 
    }
    public static void UpdtFunlocRange(List<Funloc__c> FunlocRequestList)
    {
          for(FunLoc__c objFunloc : FunlocRequestList)
          {
            objFunloc.Name = String.valueOf(Integer.valueof(objFunloc.FunLoc_Number__c));
          }  
    }
}