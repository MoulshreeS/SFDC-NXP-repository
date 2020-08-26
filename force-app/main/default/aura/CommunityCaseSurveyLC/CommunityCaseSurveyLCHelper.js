({	
    caseDetails : function(component){
        var caseIdcurrent = component.get("v.currentcaseId"); 
        console.log('id is:'+caseIdcurrent);
        if(caseIdcurrent == null || caseIdcurrent == ''){
            component.set("v.Error",true);
        }  
        var action = component.get("c.caseSurveyDetailNCP");
        action.setParams({ "caseIdcurrent" : caseIdcurrent});
        action.setCallback(this,function(a){
            if (a.getState() === "SUCCESS") {
                console.log('success');
                component.set("v.caselist",a.getReturnValue());
            } else if (a.getState() === "ERROR") {
                $A.log("Errors", a.getError());
                alert('There is an unknown error.Please contact your system administrator for further details'); 
            }
        });
        $A.enqueueAction(action); 
    },
    submitSurvey : function(component) {
        var option1 = component.get("v.ques1");
        var option2 = component.get("v.ques2");
        var option3 = component.get("v.ques3");
        var option4 = component.get("v.ques4");
        var comments = (component.get("v.commentText") != null ? component.get("v.commentText"): ' ');
        var surveycaseId = component.get("v.currentcaseId");
        var submitvalue = component.get("v.doNotSubmit");
        if(option1 == null || option1 == '' || option2 == null || option2 == '' || option3 == null || option3 == '' || option4 == null || option4 == ''){
            
            component.set("v.doNotSubmit",true);
            alert('Please answer all questions under satisfaction survey section.'); 
            window.location.reload();  
        } 
        if(component.get("v.doNotSubmit") == false){
            var action = component.get("c.submitSurveyToSalesforce");
            action.setParams({ "option1" : option1,
                              "option2" : option2,
                              "option3" : option3,
                              "option4" : option4,
                              "caseId" : surveycaseId,
                              "comments" : comments});
            action.setCallback(this, function(a) {
                if (a.getState() === "SUCCESS") {
                    console.log('success');
                    component.set("v.feedbackPage",false);
                } else if (a.getState() === "ERROR") {
                    $A.log("Errors", a.getError());
                    console.log('unknown error');
                    component.set("v.Error",true);
                }
            });
            $A.enqueueAction(action); 
        }
    },
})