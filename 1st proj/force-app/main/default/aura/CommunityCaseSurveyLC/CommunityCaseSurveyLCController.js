({
    doInit : function(component, event, helper) {
        var sPageURL = decodeURIComponent(window.location.search.substring(1)); //You get the whole decoded URL of the page.
        var sURLVariables = sPageURL.split('&'); //Split by & so that you get the key value pairs separately in a list
        var sParameterName;
        var i;
        
        for (i = 0; i < sURLVariables.length; i++) {
            sParameterName = sURLVariables[i].split('='); //to split the key from the value.
            
            if (sParameterName[0] === 'firstName') { //lets say you are looking for param name - firstName
                sParameterName[1] === undefined ? 'Not found' : sParameterName[1];
            }
        }
        component.set("v.currentcaseId",sParameterName[1]);
        helper.caseDetails(component,event);
    },
    submitSurvey : function(component, event, helper) {
        var surveyflagvalue = component.find("Surveyflag").get("v.value");
        component.set("v.doNotSubmit",false);
        if(surveyflagvalue != 'False'){
            helper.submitSurvey(component, event);
        }
        else
            component.set("v.surveysubmitted",true);
        
    },
})