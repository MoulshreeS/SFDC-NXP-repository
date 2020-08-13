({
	getProjects : function(component) {
        var action = component.get("c.getProjectList");
        action.setCallback(this,function(a){
        	component.set("v.projects",a.getReturnValue()); 
        });
    	$A.enqueueAction(action);
	},
    OnReject : function(component) {
        var projectTeamIdReject = component.get("v.projectTeamId");
        var action = component.get("c.UpdateStatusRejected");
        action.setParams({ "projectTeamIdReject" : projectTeamIdReject});
        action.setCallback(this, function(a) {
		if (a.getState() === "SUCCESS") {
		} else if (a.getState() === "ERROR") {
		$A.log("Errors", a.getError());
           alert('There is an unknown error.Please contact your system administrator for further details'); 
		}
		});
    	$A.enqueueAction(action);
        window.location.reload();  
	},
  
    OnAccept : function(component) {
        var projectTeamIdAccept = component.get("v.projectTeamId");
        var action = component.get("c.UpdateStatusAccepted");
        action.setParams({ "projectTeamIdAccept" : projectTeamIdAccept});
        action.setCallback(this, function(a) {
		if (a.getState() === "SUCCESS") {
            component.set("v.projectId",a.getReturnValue());
		} else if (a.getState() === "ERROR") {
		$A.log("Errors", a.getError());
            alert('There is an unknown error.Please contact your system administrator for further details');
		}
		});
    	$A.enqueueAction(action);
        component.set("v.isOpen", false);
        component.set("v.SuccessBox", true);
	},
})