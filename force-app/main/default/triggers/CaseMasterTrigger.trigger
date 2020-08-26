/***************************************************************************************************
@Modified By :      Gunjan Singh
@Modified Date:     11 Sep 2018
@Description:       SFDC-2078 Web-to-Case form without Login - Enhancement (Creating contact along with case)
                    Created method createContact to create Contact, along with Case if contact doesnot exist 
-----------------------------------------------------------------------------------------------------------
@Modified By :      Gunjan Singh
@Modified Date:     06 June 2019
@Description:       SFDC-2833 calling method to update user record through flow to check if user has created
                    cases and projects or not.
----------------------------------------------------------------------------------------------------------
@Modified By :      Nisha Agrawal
@Modified Date:     Jul 16,2019
@Description:       SFDC-3604 updated to call method to grant access to cases linked to projects.
**********************************************************************************************************/

trigger CaseMasterTrigger on Case (before insert,before update,after insert,after update,before delete,after delete) 
{
         if(Trigger.isInsert)
         {
            if(Trigger.isBefore)
            {
                 //Method to populate contact Id of Case with created user contact
                 CaseTrigger.populateContactIdToCase(Trigger.New);
                 /**Calling Method to populate the Product Values based on the Product Type Number to Case**/
                 CaseTrigger.populateProductValuesToCase(Trigger.New);

                 /**Calling Method to asssign the Case Owner and Account to Case**/
                 CaseTrigger.AssignCaseOwnerAndAccount(Trigger.New);
                 
                 /**Calling Method to verify email to case contact**/

                 CaseTrigger.emailToCaseContactCheck(Trigger.New);                 
                 /**Calling Method to fetch Contact info **/
                 CaseTrigger.fetchContactInfo(Trigger.New, null);

                 /**Calling Method that determines/Verifies Entitlement Pattern**/
                 CaseTrigger.projectIdentificationForCases(Trigger.New,Trigger.NewMap,Trigger.Old,Trigger.OldMap);
                  /**Calling set of Methods that perform Service level calculations**/
                // caseTrigger.PSLIdentification(Trigger.New);

                 //caseTrigger.projectServiceLevelIdentification(Trigger.New);

                 //caseTrigger.caseServiceLevelIdentification(Trigger.New);
                 caseTrigger.casePriority(Trigger.New); 

                 /**Calling method to calculate Due date on Case Insert**/
                 caseTrigger.dueDateInsert(Trigger.New);

                 /**Calling  Method to convert country value to USA if coming from Web form **/
                 caseTrigger.convertCountryValuetoUSA(Trigger.New);

                 /**Calling Method to update certain case fields befor Inserting **/
                 caseTrigger.updateCaseFieldsonInsert(Trigger.New);

                 /**Calling a routine related to 7summits code **/
                 MappingCaseRouting objMCR = new MappingCaseRouting();
                 objMCR.onBeforeInsert(Trigger.new); 

                 //Created as part of SFDC-2078
                 /**Calling method createContact to create Contact, along with Case if contact doesnot exist  **/
                 caseTrigger.createContact(Trigger.New);
            }            
            else if(Trigger.isAfter)
            {   
                 /**Calling method to update the No of Cases field on Project object ***/
                 CaseTrigger.updateNoOfCases(Trigger.New, null);

                 /**Calling method to assign gsas cases***/
                 CaseTrigger.assignGsasCases(Trigger.New);

                 /**Calling method to set autorepsonseEmail= true for Cases with Record Type 'TS_Webmaster' & 'TS_Community'**/
                 CaseTrigger.setAutoResponseEmail(Trigger.New);

                 /**Calling method to delete cases with origin ="Unkown Contact" **/
                 CaseTrigger.deleteCaseWithUnkownContact(Trigger.New); 

                 /**Calling a routine related to 7summits code **/
                 MappingCaseRouting objMCR = new MappingCaseRouting();
                 objMCR.onAfterInsert(Trigger.new); 

                // Calling method to update user record (Implemented as part of SFDC-2833)
                CaseTrigger.updateUsersHasCreatedCaseField(Trigger.new);
                  
                //code added by Nisha Agrawal on Jul 16,2019
                CaseTrigger.grantAccessToCases(Trigger.new, Trigger.oldMap);                
                 
                //code added by Bhagya
                CaseTrigger.sendCaseCreateNotification(Trigger.new);
            }
         }         
         else if(Trigger.isUpdate)
         {
             if(Trigger.isBefore)
            {            
                       /**Calling Method to fetch Contact info **/
                       CaseTrigger.fetchContactInfo(Trigger.New, Trigger.OldMap); 

                       /**Calling Method to update Case Fields like MAG,BU,BL from Related Product Information**/
                       CaseTrigger.updateCaseFieldsWithProductInfo(Trigger.New,Trigger.NewMap,Trigger.OldMap);

                       /**Calling  Method Method that determines/Verifies Entitlement Pattern**/
                       CaseTrigger.projectIdentificationForCases(Trigger.New,Trigger.NewMap,Trigger.Old,Trigger.OldMap);

                        /**Calling set of Methods that perform Service level calculations**/
                      // caseTrigger.PSLIdentification(Trigger.New);
                     //  caseTrigger.projectServiceLevelIdentification(Trigger.New);
                      // caseTrigger.caseServiceLevelIdentification(Trigger.New);
                       caseTrigger.casePriority(Trigger.New); 

                      /**Calling Method that calculates case due date on update **/
                      caseTrigger.CalculateDueDate(Trigger.New,Trigger.oldMap);

            } 
            else if(Trigger.isAfter)
            {
                     /**Calling  Method to populate the Product Values based on the Product Type Number to Case **/
                    CaseTrigger.projectUpdate(Trigger.New,Trigger.oldMap);
          CaseTrigger.updateNoOfCases(Trigger.New, Trigger.oldMap);
                  
                    //code added by Nisha Agrawal on Jul 16,2019
                    CaseTrigger.grantAccessToCases(Trigger.new, Trigger.oldMap);
            }
         }
}