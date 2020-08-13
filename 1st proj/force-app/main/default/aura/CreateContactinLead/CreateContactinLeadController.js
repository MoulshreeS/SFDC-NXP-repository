({
    doInit : function(component, event, helper) {
        
        helper.fetchrecordtype(component, event, helper);
        helper.checkduplicatecontactemail(component, event, helper);
        helper.fetchLeadVal(component, event, helper);
        helper.fetchrecordtypeval(component, event, helper);
        //component.set("v.selectedRecord","");
        
        component.set("v.toggleSpinner", true); 
        
    },
    
    
    
    keyPressController : function(component, event, helper) {
        // get the search Input keyword   
        var getInputkeyWord = component.get("v.SearchKeyWord");
        console.log(getInputkeyWord);
        // check if getInputKeyWord size id more then 0 then open the lookup result List and 
        // call the helper 
        // else close the lookup result List part.   
        //  if( getInputkeyWord.length > 0 && getInputkeyWord.length != 0 ){
        if( getInputkeyWord != null){
            var forOpen = component.find("searchRes");
            $A.util.addClass(forOpen, 'slds-is-open');
            $A.util.removeClass(forOpen, 'slds-is-close');
            helper.searchHelper(component,event,getInputkeyWord);
        }
        else{  
            component.set("v.listOfSearchRecords", null ); 
            var forclose = component.find("searchRes");
            $A.util.addClass(forclose, 'slds-is-close');
            $A.util.removeClass(forclose, 'slds-is-open');
        }
        
        
    },
    
    hidelist :function(component,event,helper){
        var lookUpTarget = component.find("lookupField");
        $A.util.addClass(lookUpTarget, 'slds-show');
        $A.util.removeClass(lookUpTarget, 'slds-hide');
        
        var forclose = component.find("searchRes");
        $A.util.addClass(forclose, 'slds-is-close');
        $A.util.removeClass(forclose, 'slds-is-open'); 
    },
    
    displaylist:function(component, event, helper){
        var forOpen = component.find("searchRes");        
        $A.util.addClass(forOpen, 'slds-is-open');
        $A.util.removeClass(forOpen, 'slds-is-close');               
        // call the apex class method         
        var action = component.get("c.fetchAccounts");              
        
        // set a callBack    
        action.setCallback(this, function(response) {
            var state = response.getState();
            
            if (state === "SUCCESS") {
                
                var storeResponse = response.getReturnValue();   
                
                // set searchResult list with return value from server.
                component.set("v.listOfSearchRecords", storeResponse);
                
            }
            if (storeResponse.length == 0) {
                component.set("v.Message", 'No Result Found...');
            }                	
            else {
                component.set("v.Message", 'Search Result...');
            }
            
        });
        // enqueue the Action  
        $A.enqueueAction(action);
    },
    
    clear :function(component,event,helper){      
        var pillTarget = component.find("lookup-pill");                           
        $A.util.addClass(pillTarget, 'slds-hide');
        $A.util.removeClass(pillTarget, 'slds-show'); 
        var lookUpTarget = component.find("lookupField");
        $A.util.addClass(lookUpTarget, 'slds-show');
        $A.util.removeClass(lookUpTarget, 'slds-hide');                       
        component.set("v.SearchKeyWord",null);
        component.set("v.listOfSearchRecords", null ); 
        // var accIdClear=component.find("pre-disti-Inp1").set("v.value", "");
        // var accIdClear=component.find("pre-disti-Inp").set("v.value", "");
        component.set("v.selectedRecord","");
        component.set("v.recordtypeexixts",false);
        
        
    },
    
    closeModel: function(component, event, helper) {
        //for Hide/Close Model,set the "isOpen" attribute to "Fasle" 
          var AccountId = component.get("v.selectedRecord").Id;
        var LeadId = component.get("v.recordId");
        component.set("v.isCreated", false);
        window.location.href = '/'+AccountId;
    },
    
    handleComponentEvent : function(component, event, helper) {
        
        // get the selected Opportunity record from the COMPONETN event 	 
        var selectedUserGetFromEvent = event.getParam("UserRecordByEvent");
        
        var rectype =  component.get("v.recordtypeexixts"); 
        
        
        
        
        component.set("v.selectedRecord" , selectedUserGetFromEvent);
        
        var forclose = component.find("lookup-pill");
        $A.util.addClass(forclose, 'slds-show');
        $A.util.removeClass(forclose, 'slds-hide');
        
        
        var forclose = component.find("searchRes");
        $A.util.addClass(forclose, 'slds-is-close');
        $A.util.removeClass(forclose, 'slds-is-open');
        
        var lookUpTarget = component.find("lookupField");
        $A.util.addClass(lookUpTarget, 'slds-hide');
        $A.util.removeClass(lookUpTarget, 'slds-show');                      
    },
    
    cancelLead : function(component, event, helper) {
        // component.set("v.isSpinner", true);
        var recordId = component.get("v.recordId");                                        
        window.location.href = '/'+recordId;                                       
    },
    
    createcontactButton : function(component, event, helper) {  
        var conFirstName=component.find("first-Name-Inp-c").get("v.value");
        var conlastName=component.find("last-Name-Inp-c").get("v.value");
        var conCountry=component.find("Country").get("v.value");
        var conState=component.find("State").get("v.value");
        var conTitle=component.find("Title").get("v.value");
        var conEmail=component.find("Email").get("v.value");
        var conmailingcountry=component.find("Mailing Country").get("v.value");
        var conMailingState=component.find("Mailing State").get("v.value");
        var conMailingcity=component.find("Mailing City").get("v.value");
        var conMailingStreet=component.find("Mailing Street").get("v.value");
        var conphone=component.find("Phone").get("v.value");  
        var selrec = component.get("v.selectedRecord");
        var firstnamenull=component.find("first-Name-Inp-c");
        var lastnamenull=component.find("last-Name-Inp-c");
        var Emailnull=component.find("Email");
        var Countrynull=component.find("Country");
        var Accountnull=component.find("pre-disti-Inp2");
        var dupconemail =component.get("v.dupContactexists");
        
        
        
        
        if(conlastName == null || conlastName == ''){
            
            lastnamenull.set("v.errors", [{message:"Please enter Lastname"}]); 
        }
        else{
            lastnamenull.set("v.errors", '');
        }   
        if(conFirstName == null || conFirstName == ''){
            
            firstnamenull.set("v.errors", [{message:"Please enter Firstname"}]); 
        }
        else{
            firstnamenull.set("v.errors", '');
        }  
        
        if(dupconemail == true){
            
            Emailnull.set("v.errors", [{message:"Contact already exists"}]); 
        }
        else{
            Emailnull.set("v.errors", '');
        }  
        if(conCountry == '' || conCountry == null){
            
            Countrynull.set("v.errors", [{message:"Please enter Country"}]); 
        }
        else{
            Countrynull.set("v.errors", '');
        }  
        
        if(selrec == null || selrec == ''){
            Accountnull.set("v.errors", [{message:"Please enter Account"}]); 
        }
        else{
            var selrec1 = component.get("v.selectedRecord").Id;
        }
        
        
             if((conFirstName != null &&  conFirstName != '')  && ( selrec != '' && selrec != null )
           && (Countrynull !='' && Countrynull != null) && ( conlastName != '' && conlastName != null) && dupconemail == false){
            
             component.set("v.toggleSpinner", true); 
            var action = component.get("c.createcontact"); 
            
            action.setParams({ firstnameval : conFirstName,
                              lastnameval : conlastName, 
                              emailval : conEmail, 
                              AccountIdval: selrec1,
                              countryval:conCountry,
                              Stateval:conState,
                              Cityval:conMailingcity,
                              Streetval:conMailingStreet,
                              Mailingcountryval:conmailingcountry,
                              MailingStateval:conMailingState,Titleval:conTitle,phoneval:conphone
                              
                              
                             }); 
            
            action.setCallback(this, function(response){
                var state = response.getState();
                
                
                if (state === "SUCCESS"){
                    component.set("v.toggleSpinner", false); 
                    component.set("v.isCreated", true); 
                    
                    
                }
                
            });
            $A.enqueueAction(action);
            
        }     
        
    },
    
    
    
})