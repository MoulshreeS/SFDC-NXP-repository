({
	getOpportunitySchedules: function(cmp) {
        this.p(cmp, "getOpportunitySchedules");
        
        var action = cmp.get("c.getOpportunitySchedules");
        
        action.setParams({
            opptyId: cmp.get("v.recordId")
        });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            
            if (state === "SUCCESS") {
                cmp.set("v.data", response.getReturnValue());
                
                this.checkAdd(cmp);
                this.checkRemove(cmp);
                this.checkReestablish(cmp);
                this.checkMassUpdate(cmp);
                
                this.getOpportunityProducts(cmp);
            } else if (state === "ERROR") {
                this.hideSpinner(cmp);
                this.handleError(cmp, response);
            }
        });
        
        $A.enqueueAction(action);
    },
    
    updateOpportunitySchedules: function(cmp) {
        if (!this.validate(cmp)) return;
        
        this.p(cmp, "updateOpportunitySchedules");
        
		var action = cmp.get("c.updateOpportunitySchedules");
                
        cmp.get("v.opptyRecord");
        
        action.setParams({ 
            opptyRecord: cmp.get("v.opptyRecord"),
            isFullEdit: this.isFullEdit(cmp),
            isTmmaOverride: this.isTmmaOverride(cmp),
            scheds: cmp.get("v.data"),
            isMassUpdate: this.isMassUpdate(cmp)
        });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            
            if (state === "SUCCESS") {
                cmp.find("recordLoader").reloadRecord(true, function() {
        			cmp.find("datatable").set("v.draftValues", null);
                });
                
                this.getOpportunitySchedules(cmp); // must reload to get Id of new record
                
                this.handleSuccess("Saved Successfully");
            } else if (state === "ERROR") {
            	this.hideSpinner(cmp);
                this.handleError(cmp, response);
            }
        });
        
        $A.enqueueAction(action);
        
        this.showSpinner(cmp);
	},
    
    getOpportunityProducts: function(cmp) {
        if (!this.lock(cmp)) return;
        
        this.p(cmp, "getOpportunityProducts");
        
        var action = cmp.get("c.getOpportunityProducts");
        
        action.setParams({
            opptyId: cmp.get("v.recordId")
        });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                cmp.set("v.opptyProds", result);
                
                if (result.length > 0) {
                	cmp.find("prodList").set("v.value", result[0].id);
                    this.getOpportunityProductSchedules(cmp);
                    cmp.find("toggle").set("v.disabled", false);
                } else {
                    this.unlock(cmp);
                    this.hideSpinner(cmp);
                    cmp.find("toggle").set("v.checked", false);
                    this.handleViewChange(cmp);
                    cmp.find("toggle").set("v.disabled", true);
                    cmp.set("v.prodValue", 0);
                }
            } else if (state === "ERROR") {
                this.unlock(cmp);
                this.hideSpinner(cmp);
                this.handleError(cmp, response);
            }
        });
        
        $A.enqueueAction(action);
    },
    
    getOpportunityProductSchedules: function(cmp) {
        this.p(cmp, "getOpportunityProductSchedules");
        
        var action = cmp.get("c.getOpportunityProductSchedules");
        
        var opptyProdIds = [];
        
        cmp.get("v.opptyProds").forEach(function(value, index, array) {
            opptyProdIds.push(value["id"]);
        });
        
        action.setParams({
            opptyId: cmp.get("v.recordId"),
            opptyProdIds: opptyProdIds
        });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            
            if (state === "SUCCESS") {
                cmp.set("v.data2", response.getReturnValue());
                
                if (this.isProdView(cmp)) {
                	cmp.find("datatable2").set("v.draftValues", null);
                    this.setProdScheds(cmp);
                } else {
                    this.setOpptyProdValue(cmp);
                }
                
                this.unlock(cmp);
                this.hideSpinner(cmp);
            } else if (state === "ERROR") {
                this.unlock(cmp);
                this.hideSpinner(cmp);
                this.handleError(cmp, response);
            }
        });
        
        $A.enqueueAction(action);
    },
    
    updateOpportunityProductSchedules: function(cmp) {
        if (!this.validate2(cmp)) return;
        
        this.p(cmp, "updateOpportunityProductSchedules");
        
        var action = cmp.get("c.updateOpportunityProductSchedules");
        
		action.setParams({
            opptyId: cmp.get("v.recordId"),
            isTmmaOverride: this.isTmmaOverride(cmp),
            changedValues: JSON.stringify(cmp.find("datatable2").get("v.draftValues"))
        });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            
            if (state === "SUCCESS") {
                cmp.find("recordLoader").reloadRecord(true, function() {
        			cmp.find("datatable2").set("v.draftValues", null);
                });
        		
                this.getOpportunityProductSchedules(cmp);
                this.handleSuccess("Saved Successfully");	
            } else if (state === "ERROR") {
                this.hideSpinner(cmp);
                this.handleError(cmp, response);
            }
        });
        
        $A.enqueueAction(action);
        
        this.showSpinner(cmp);
	},
    
    setProdScheds: function(cmp) {
    	var data2 = cmp.get("v.data2");
        var prodScheds = cmp.get("v.prodScheds");
        prodScheds.length = 0;
        cmp.set("v.prodValue", 0);
        var opptyProds = cmp.get("v.opptyProds");
        var prodId = cmp.find("prodList").get("v.value");
        
        opptyProds.forEach(function(value, index, array) {
        	if (value["id"] == prodId) cmp.set("v.opptyProd", value);     
        });
        
        data2.forEach(function(value, index, array) {
            if (value["prodId"] == prodId) {
                if (value["id"].startsWith("subtotal")) {
                    cmp.set("v.prodValue", value["prodValue"]);    
                } else {
                	prodScheds.push(value);    
                }
            }
        });
        
        cmp.set("v.prodScheds", prodScheds);
    },
    
    setOpptyProdValue: function(cmp) {
        cmp.get("v.data2").forEach(function(value, index, array) {
            if (value["id"].startsWith("total")) {
                cmp.set("v.prodValue", value["prodValue"])    
            } 
        });
    },
    
    validate: function(cmp) {
    	return this.validateDates(cmp) && this.validateDataGrid(cmp);    
    },
    
    validateDates: function(cmp) {
        if (!this.isFullEdit(cmp)) return true;
        
        var closeDate;
        var prodDate;
        
    	var result = cmp.find("opptyData").reduce(function (validSoFar, inputCmp) {
            if (inputCmp.get("v.name") == "closeDate") {
            	closeDate = inputCmp.get("v.value");
                var today = new Date();
                today = today.getFullYear() +  
                		"-" + ("0" + (today.getMonth() + 1)).slice(-2) +  
                		"-" + ("0" + today.getDate()).slice(-2);
                
                if (closeDate < today) {
                    inputCmp.setCustomValidity("Expected Close Date must be on or after today.");
                } else {
                    inputCmp.setCustomValidity("");
                }
                
                inputCmp.reportValidity();
            }
            
            if (inputCmp.get("v.name") == "prodDate") {
                prodDate = inputCmp.get("v.value");  
                
                if (prodDate < closeDate) {
                    inputCmp.setCustomValidity("Production Date must be on or after Expected Close Date.");
                } else {
                    inputCmp.setCustomValidity("");
                }
                
                inputCmp.reportValidity();
            }
            
            // Displays error messages for invalid fields
            inputCmp.showHelpMessageIfInvalid();
            
            return validSoFar && inputCmp.get("v.validity").valid;
        }, true);

        return result;
    },
    
    validateDataGrid: function(cmp) {
        this.syncData(cmp);
        
        var totalErrors = 0;
        var errors = {};
        var rowsError = {};
        var data = cmp.get("v.data");
        
        for (let i = 0; i < data.length; i++) {
        	let row = data[i];
            let rowErrorMessages = [];
            let rowErrorFieldNames = [];
            
            var schedQty = row["schedQty"];
                       
            if (!this.isNormalInteger(schedQty.toString())) {
                rowErrorMessages.push("Sched Qty should be an integer greater than or equal to 0.");
                rowErrorFieldNames.push("schedQty");
            } 
            
            if (rowErrorMessages.length > 0) {
                totalErrors += rowErrorMessages.length;
                
                rowsError[row["id"]] = {
                    messages: rowErrorMessages,
                    fieldNames: rowErrorFieldNames,
                    title: this.getSchedDateById(data, row["id"]) + ": Invalid number"
                };
            }
        } 
        
        if (totalErrors > 0) {
            let tableMessages = [];
            let rowErrorValues = Object.values(rowsError);
            
            rowErrorValues.forEach(function (rowError) {
                tableMessages.push(rowError.title);
            });
            
            errors = {
                rows: rowsError,
                table: { 
                    title : "Some records have errors",
                    messages : tableMessages
                }
            };
        } else {
            let totalSchedQty = 0;
            
            data.forEach(function(value, index, array) {
                totalSchedQty += parseInt(value["schedQty"]);
            });
            
            if (totalSchedQty <= 0) {
            	errors = {
                    table: { 
                        title : "Invalid total quantity",
                        messages : ["Total schedule quantity should be greater than 0."]
                    }
                };
            }    
        }
        
        if (Object.keys(errors).length > 0) {
            cmp.set("v.errors", errors);
        } else {
            cmp.set("v.errors", null);
        }
        
        return cmp.get("v.errors") == null;
    },
    
    syncData: function(cmp) {
    	var data = cmp.get("v.data");
        var draftValues = cmp.find("datatable").get("v.draftValues"); 
        
      	data.forEach(function(value1, index1, array1) {
            draftValues.forEach(function(value2, index2, array2) {
            	if (value1["id"] == value2["id"]) {
                    if (value2.hasOwnProperty("schedQty")) {
                        if (!value2["schedQty"]) {
                        	value2["schedQty"] = 0;    
                        } else {
                        	value2["schedQty"] = value2["schedQty"].toString().replace(/^0+/, "");
                            
                            if (value2["schedQty"] === "") value2["schedQty"] = 0;
                        }
                            
                        value1["schedQty"] = value2["schedQty"];    
                    } 
                        
					if (value2.hasOwnProperty("comment")) value1["comment"] = value2["comment"];
                }
        	});
        });
        
        cmp.set("v.data", data);
        cmp.find("datatable").set("v.draftValues", draftValues);
    },
    
    validate2: function(cmp) {
        var totalErrors = 0;
        var errors = {};
        var rowsError = {};
        var prodScheds = cmp.get("v.prodScheds");
    	var draftValues = cmp.find("datatable2").get("v.draftValues"); 
        
        for (let i = 0; i < draftValues.length; i++) {
            let row = draftValues[i];
            let rowErrorMessages = [];
            let rowErrorFieldNames = [];
            
            if (row.hasOwnProperty("prodSchedPrice") && !row["prodSchedPrice"]) row["prodSchedPrice"] = 0;
            if (row.hasOwnProperty("share") && !row["share"]) row["share"] = 0;
            
            if (row["prodSchedPrice"] && row["prodSchedPrice"] < 0) {
                rowErrorMessages.push("Production Price should be greater than or equal to 0.");
                rowErrorFieldNames.push("prodSchedPrice");
            }
            
            if (row["share"] && (row["share"] < 0 || row["share"] > 1)) {
                rowErrorMessages.push("Share should be a value between 0 (0%) and 1 (100%).");
                rowErrorFieldNames.push("share");
            }
            
            if (rowErrorMessages.length > 0) {
                totalErrors += rowErrorMessages.length;
                
                rowsError[row["id"]] = {
                    messages: rowErrorMessages,
                    fieldNames: rowErrorFieldNames,
                    title: this.getSchedDateById(prodScheds, row["id"]) + ": Invalid number"
                };
            }
        }
        
        cmp.find("datatable2").set("v.draftValues", draftValues);
        
        if (totalErrors > 0) {
            let tableMessages = [];
            let rowErrorValues = Object.values(rowsError);
            
            rowErrorValues.forEach(function (rowError) {
                tableMessages.push(rowError.title);
            });
            
            errors = {
                rows: rowsError,
                table: { 
                    title : "Some records have errors",
                    messages : tableMessages
                }
            };
        }
        
        if (Object.keys(errors).length > 0) {
            cmp.set("v.errors2", errors);
        } else {
            cmp.set("v.errors2", null);
        }
        
        return cmp.get("v.errors2") == null;
    },
    
    getSchedDateById: function(data, id) {
        var result;
        
    	data.forEach(function(value, index, array) {
            if (value["id"] == id) result = value["schedYearQtr"];
        });
        
        return result;
    },
    
    generateOpportunityScheduleDates: function(startDate, qtrs) {
    	var result = [];
        
        startDate = this.dateFromISO8601(startDate.toISOString());
    	var startQtr = Math.floor(startDate.getMonth() / 3) + 1;
        var startQtrStartMonth = 3 * (startQtr - 1);
        var startQtrStartDate = new Date(startDate.getFullYear(), startQtrStartMonth, 1);
        
    	for (var i = 0; i < qtrs; i++) {
            var newDate;
            var startQtrStartDateCopy = new Date(startQtrStartDate);
            
            if (i == 0) {
            	newDate = new Date(startDate);	    
            } else {
            	newDate = new Date(startQtrStartDateCopy.setMonth(startQtrStartDateCopy.getMonth() + (3 * i)));    
            }
            
            result.push({
                schedDate: this.toSchedDate(newDate), 
                schedYearQtr: this.toSchedYearQtr(newDate)
            });
        }
    	
    	return result;    
    },
    
    handleViewChange: function(cmp) {
        if (this.isProdView(cmp)) {
            this.enableProdView(cmp);
            this.checkEditMode2(cmp);
            this.setProdScheds(cmp);
        } else {
            this.disableProdView(cmp);
            this.checkEditMode(cmp);
            this.setOpptyProdValue(cmp);
        }
    },
    
    handleCloseDateChange: function(cmp) {
        cmp.set("v.opptyRecord.CloseDate", cmp.get("v.closeDate"));
        this.showSave(cmp);
    },
    
    handleProdDateChange: function(cmp) {
        var data = cmp.get("v.data");
        //var prodDate = this.dateFromISO8601((new Date(cmp.get("v.opptyRecord").Production_Date__c)).toISOString());
        var prodDate = new Date(cmp.get("v.opptyRecord").Production_Date__c);
        
        if (data.length == 0) {
            var defaultSched = {
                id: this.createUuid(),
                schedDate: this.toSchedDate(prodDate),
                schedYearQtr: this.toSchedYearQtr(prodDate),
                schedQty: 0,
                frozenSchedQty: 0,
                comment: ""
            } 
            
            data.push(defaultSched);
            cmp.set("v.data", data);
            data = cmp.get("v.data");
            this.enableGridEdit(cmp);
        } 
        
        var schedDates = this.generateOpportunityScheduleDates(prodDate, data.length);
        var draftValues = cmp.find("datatable").get("v.draftValues");
        var schedShifted = false;
        
        if (data[0].schedYearQtr != schedDates[0].schedYearQtr) {
            schedShifted = true;    
        }
        
        schedDates.forEach(function(value1, index1, array1) {
            var sched = data[index1];
            sched.schedDate = value1["schedDate"];
            sched.schedYearQtr = value1["schedYearQtr"]; 
            
            draftValues.forEach(function(value2, index2, array2) {
            	if (value2["id"] == sched.id) {
                    if (value2["schedQty"]) sched.schedQty = value2["schedQty"];
                	if (value2["comment"]) sched.comment = value2["comment"];
                }
            });
            
            draftValues.push(sched);
        });
        
        cmp.find("datatable").set("v.draftValues", draftValues);
        cmp.set("v.data", data);
        
        if (schedShifted) this.handleSuccess("Sched Date(s) Shifted");
    },
    
    handleProdListChange: function(cmp) {
    	this.setProdScheds(cmp);
    },
    
    handleRecordUpdated2: function(cmp) {
        this.p(cmp, "handleRecordUpdated2");
        
        if (this.isProdView(cmp)) {
        	this.checkEditMode2(cmp);    
        } else {
        	this.checkEditMode(cmp);    
        }
        
        this.checkCloseDate(cmp);
        this.checkOpptyProdUpdate(cmp);
    },
    
    handleSuccess: function(msg) {
    	this.showToast("success", msg);    
    },
    
    handleError: function(cmp, response) {
        let errors = response.getError();
        let message = 'Unknown error'; // Default error message
        
        if (errors && Array.isArray(errors) && errors.length > 0) {
            message = errors[0].message;
        }
        
        this.showToast("error", message);
    },
    
    showToast: function(type, msg) {
        var toastEvent = $A.get("e.force:showToast");
        
        var params = {
            mode: type == "success" ? "dismissible" : "sticky",
            type: type,
            message: msg
        }
        
        if (type == "error") {
            params["messageTemplate"] = "{0}\n\n Please try again. If the problem persists, contact support by clicking {1}.";
            params["messageTemplateData"] = [msg, {
                url: "https://nxpsemiconductors.secure.force.com/welcome/",
                label: "here",
            }];
        }
        
        toastEvent.setParams(params);
        toastEvent.fire();
    },
    
    add: function(cmp) {
    	var data = cmp.get("v.data");
        var last = data[data.length - 1];
        var qtrs = parseInt(cmp.get("v.qtrs"));
        var schedDates = this.generateOpportunityScheduleDates(new Date(last.schedDate), qtrs + 1);
        var draftValues = cmp.find("datatable").get("v.draftValues");
        
        draftValues.forEach(function(value, index, array) {
            if (value["id"] == last.id && value["schedQty"]) {
                last.schedQty = value["schedQty"];
            }
        });    
       
        for (let i = 0; i < schedDates.length; i++) {
        	let value = schedDates[i];
            
            if (i > 0) {
                var newSched = JSON.parse(JSON.stringify(last));
                newSched.id = this.createUuid();
                newSched.schedDate = value["schedDate"];
                newSched.schedYearQtr = value["schedYearQtr"];
                newSched.comment = "";
                
                if (this.isPartialEdit(cmp)) {
                	newSched.frozenSchedQty = null;    
                }
              
                draftValues.push(newSched);
                data.push(newSched);    
            }
        }
            
        cmp.find("datatable").set("v.draftValues", draftValues);
        cmp.set("v.data", data);
       
        this.syncData(cmp);
        this.checkRemove(cmp);
        this.checkReestablish(cmp);    
    },
    
    remove: function(cmp, qtrs, reset) {
    	var data = cmp.get("v.data");
        
        for (var i = 0; i < qtrs; i++) {
            data.length = data.length - 1;
            cmp.set("v.data", data);
            
            if (!this.checkRemove(cmp)) break;
        }
        
        if (reset) {
        	var last = cmp.get("v.data")[0];
            last.schedQty = 0;
            last.comment = "";
            cmp.set("v.data", cmp.get("v.data"));
            cmp.find("datatable").set("v.draftValues", null);
        }
        
        this.syncData(cmp);
        this.showSave(cmp);
        this.checkReestablish(cmp); 
    },
    
    checkPageReference: function(cmp) {
        if (cmp.get("v.pageReference") != null) {
            cmp.set("v.recordId", cmp.get("v.pageReference").state.c__opptyId);
            cmp.set("v.progName", cmp.get("v.pageReference").state.c__progName);
            
            if (cmp.get("v.pageReference").state.hasOwnProperty("c__massUpdate")) cmp.set("v.massUpdate", true);
            
            cmp.find("recordLoader").reloadRecord(true);
        	cmp.find("recordLoader2").reloadRecord(true);
        }
    },
    
    checkMassUpdate: function(cmp) {
        if (this.isMassUpdate(cmp)) this.showSave(cmp);
    },
    
    checkCloseDate: function(cmp) {
    	cmp.set("v.closeDate", cmp.get("v.opptyRecord2.CloseDate"));
    },
    
    checkOpptyProdUpdate: function(cmp) {
        var claimValue = cmp.get("v.claimValue");
        
        if (typeof claimValue !== "undefined" &&
            claimValue != cmp.get("v.opptyRecord2.Claim_Value_USD__c")) {
            this.p(cmp, "old claim value: " + claimValue + ", new claim value: " + cmp.get("v.opptyRecord2.Claim_Value_USD__c"));
            this.getOpportunityProducts(cmp);    
        }
        
        cmp.set("v.claimValue", cmp.get("v.opptyRecord2.Claim_Value_USD__c"));    
    },
    
    checkAdd: function(cmp) {
    	if (cmp.get("v.data").length > 0) {
            cmp.find("add").set("v.disabled", false);
        } else {
            cmp.find("add").set("v.disabled", true);    
        }
    },
    
    checkRemove: function(cmp) {
        var data = cmp.get("v.data");
        var last = data[data.length - 1];
        
        if ((data.length <= 1) || (this.isPartialEdit(cmp) && last.frozenSchedQty)) {
            cmp.find("remove").set("v.disabled", true);
            return false;
        } else {
            cmp.find("remove").set("v.disabled", false);
            return true;
        }
    },
    
    checkReestablish: function(cmp) {
        if (this.isFullEdit(cmp)) {
            $A.util.removeClass(cmp.find("reestablish"), "slds-hide");
            
            if (cmp.get("v.data").length > 1) {
                cmp.find("reestablish").set("v.disabled", false);    
            } else {
                cmp.find("reestablish").set("v.disabled", true);    
            }
        } else {
            $A.util.addClass(cmp.find("reestablish"), "slds-hide");    
        }
    },
    
    checkEditMode: function(cmp) {
        if (this.isFullEdit(cmp)) {
            this.enableDateEdit(cmp);
            this.enableGridEdit(cmp); 
        } else if (this.isPartialEdit(cmp)) {
        	this.disableDateEdit(cmp);
            this.enableGridEdit(cmp);
        } else if (this.isLocked(cmp)) {
            this.disableDateEdit(cmp);    
            this.disableGridEdit(cmp);
        } else {
            alert('Error: indeterminate criteria');
        }   
    },
    
    checkEditMode2: function(cmp) {
        this.disableDateEdit(cmp);
        
        if (this.isFullEdit(cmp)) {
            this.disableGrid2Edit(cmp);
        } else if (this.isPartialEdit(cmp)) {
        	this.enableGrid2Edit(cmp);
        } else if (this.isLocked(cmp)) {
            this.disableGrid2Edit(cmp);
        } else {
            alert('Error: indeterminate criteria');
        }   
    },
    
    disableDateEdit: function(cmp) {
    	cmp.find("opptyData").forEach(function(value, index, array) {
            value.set("v.disabled", true); 	    
        });    
    },
    
    enableDateEdit: function(cmp) {
    	cmp.find("opptyData").forEach(function(value, index, array) {
            value.set("v.disabled", false); 	    
        });    
    },
    
    disableGridEdit: function(cmp) {
        // datatable
        cmp.set("v.columns", this.getColumnDefinitions(cmp, false));
        cmp.find("datatable").set("v.hideCheckboxColumn", true);
        
        // buttons
        $A.util.addClass(cmp.find("action"), "slds-hide");
    },
    
    enableGridEdit: function(cmp) {
        // datatable
        cmp.set("v.columns", this.getColumnDefinitions(cmp, true));
        cmp.find("datatable").set("v.hideCheckboxColumn", false);
        
        // buttons
        $A.util.removeClass(cmp.find("action"), "slds-hide");
        
        this.checkAdd(cmp);
        this.checkRemove(cmp);
        this.checkReestablish(cmp);
    },
    
    disableGrid2Edit: function(cmp) {
    	cmp.set("v.columns2", this.getColumnDefinitions2(cmp, false));
        cmp.find("datatable2").set("v.hideCheckboxColumn", true);    
    },
    
    enableGrid2Edit: function(cmp) {
    	cmp.set("v.columns2", this.getColumnDefinitions2(cmp, true));
        cmp.find("datatable2").set("v.hideCheckboxColumn", false);    
    },
    
    disableProdView: function(cmp) {
    	$A.util.addClass(cmp.find("prodList"), "slds-hide");
        $A.util.addClass(cmp.find("prodSum"), "slds-hide");
        $A.util.addClass(cmp.find("prodView"), "slds-hide");
        
        $A.util.removeClass(cmp.find("opptySum"), "slds-hide");
        $A.util.removeClass(cmp.find("opptyView"), "slds-hide");
    },
    
    enableProdView: function(cmp) {
    	$A.util.removeClass(cmp.find("prodList"), "slds-hide");
        $A.util.removeClass(cmp.find("prodSum"), "slds-hide");
        $A.util.removeClass(cmp.find("prodView"), "slds-hide");
        
        $A.util.addClass(cmp.find("opptySum"), "slds-hide");
        $A.util.addClass(cmp.find("opptyView"), "slds-hide");
    },
    
    showSave: function(cmp) {
        // The purpose of the following logic is to force Cancel/Save buttons to show.
        var data = cmp.get("v.data");
        
        if (data.length == 0) return;
        
        var draftValues = cmp.find("datatable").get("v.draftValues");
        draftValues.push(data[0]);
        cmp.find("datatable").set("v.draftValues", draftValues);    
    },
    
    showSpinner: function(cmp) {
    	cmp.set("v.done", false);
        $A.util.removeClass(cmp.find("spinner"), "slds-hide");
        cmp.find("datatable").set("v.suppressBottomBar", true);
        cmp.find("datatable2").set("v.suppressBottomBar", true);
    },
    
    hideSpinner: function(cmp) {
        cmp.set("v.done", true);
        $A.util.addClass(cmp.find("spinner"), "slds-hide");
        cmp.find("datatable").set("v.suppressBottomBar", false);
        cmp.find("datatable2").set("v.suppressBottomBar", false);
    },
    
    getColumnDefinitions: function(cmp, editable) {
        var columns = [];
        
        if (editable) {
            columns = [
                {label: "Sched Date", fieldName: "schedYearQtr", type: "text", cellAttributes: {class: {fieldName: "schedYearQtr"}, alignment: "center"}},
                {label: "Sched Qty", fieldName: "schedQty", type: "number", cellAttributes: {class: {fieldName: "schedYearQtr"}}, editable: "true"},
                {label: "Comment", fieldName: "comment", type: "text", cellAttributes: {class: {fieldName: "schedYearQtr"}, alignment: "left"}, editable: "true"}
            ];    
        } else {
        	columns = [
                {label: "Sched Date", fieldName: "schedYearQtr", type: "text", cellAttributes: {class: {fieldName: "schedYearQtr"}, alignment: "center"}},
                {label: "Sched Qty", fieldName: "schedQty", type: "number", cellAttributes: {class: {fieldName: "schedYearQtr"}}},
                {label: "Comment", fieldName: "comment", type: "text", cellAttributes: {class: {fieldName: "schedYearQtr"}, alignment: "left"}}
            ];     
        }
        
    	return columns;
    },
    
    getColumnDefinitions2: function(cmp, editable) {
        var columns = [];
        
        if (editable) {
            columns = [
                {label: "Sched Date", fieldName: "schedYearQtr", type: "text", cellAttributes: {class: {fieldName: "schedYearQtr"}, alignment: "center"}},
                {label: "Production Price", fieldName: "prodSchedPrice", type: "number", typeAttributes: {style: "decimal", minimumFractionDigits: "6", maximumFractionDigits: "6"}, cellAttributes: {class: {fieldName: "schedYearQtr"}, alignment: "center"}, editable: "true"},
                {label: "Frozen Price", fieldName: "frozenProdSchedPrice", type: "number", typeAttributes: {style: "decimal", minimumFractionDigits: "6", maximumFractionDigits: "6"}, cellAttributes: {class: {fieldName: "schedYearQtr"}, alignment: "center"}},
                {label: "Share", fieldName: "share", type: "percent", cellAttributes: {class: {fieldName: "schedYearQtr"}, alignment: "center"}, editable: "true"},
                {label: "Qty Per Sys", fieldName: "qtyPerSys", type: "number", cellAttributes: {class: {fieldName: "schedYearQtr"}, alignment: "center"}},
                {label: "Oppty Sched Qty", fieldName: "opptySchedQty", type: "number", typeAttributes: {style: "decimal", minimumFractionDigits: "1"}, cellAttributes: {class: {fieldName: "schedYearQtr"}}}
            ];    
        } else {
        	columns = [
                {label: "Sched Date", fieldName: "schedYearQtr", type: "text", cellAttributes: {class: {fieldName: "schedYearQtr"}, alignment: "center"}},
                {label: "Production Price", fieldName: "prodSchedPrice", type: "number", typeAttributes: {style: "decimal", minimumFractionDigits: "6", maximumFractionDigits: "6"}, cellAttributes: {class: {fieldName: "schedYearQtr"}, alignment: "center"}},
                {label: "Frozen Price", fieldName: "frozenProdSchedPrice", type: "number", typeAttributes: {style: "decimal", minimumFractionDigits: "6", maximumFractionDigits: "6"}, cellAttributes: {class: {fieldName: "schedYearQtr"}, alignment: "center"}},
                {label: "Share", fieldName: "share", type: "percent", cellAttributes: {class: {fieldName: "schedYearQtr"}, alignment: "center"}},
                {label: "Qty Per Sys", fieldName: "qtyPerSys", type: "number", cellAttributes: {class: {fieldName: "schedYearQtr"}, alignment: "center"}},
                {label: "Oppty Sched Qty", fieldName: "opptySchedQty", type: "number", typeAttributes: {style: "decimal", minimumFractionDigits: "1"}, cellAttributes: {class: {fieldName: "schedYearQtr"}}}
            ];     
        }
        
    	return columns;
    },
    
    stage: function(cmp) {
    	return cmp.get("v.opptyRecord2.StageName");
    },
    
    status: function(cmp) {
    	return cmp.get("v.opptyRecord2.Design_Win_Approval_Process__c");
    },
    
    isFullEdit: function(cmp) {
    	return (this.isSfdc(cmp) && this.isOpen(cmp) && !this.isPending(cmp)) ||
               (this.isMn(cmp) && this.isTmma(cmp) && this.isOpen(cmp));
    },
    
    isPartialEdit: function(cmp) {
        return (this.isSfdc(cmp) && this.isCommitment(cmp)) ||
               (this.isMn(cmp) && this.isTmma(cmp) && this.isCommitment(cmp));	
    },
    
    isLocked: function(cmp) {
    	return this.isLost(cmp) || 
               (this.isSfdc(cmp) && this.isPending(cmp)) ||
               (this.isMn(cmp) && !this.isTmma(cmp));		
    },
    
    isOpen: function(cmp) {
        return ["Initial Engagement", "Discovery", "Decision"].includes(this.stage(cmp));
    },
    
    isLost: function(cmp) {
        return ["Lost", "Cancelled"].includes(this.stage(cmp));
    },
    
    isCommitment: function(cmp) {
        return this.stage(cmp) == "Commitment";
    },
    
    isPending: function(cmp) {
        return this.status(cmp) == "Pending";
    },
    
    isSfdc: function(cmp) {
    	return cmp.get("v.opptyRecord2.RecordType.DeveloperName") == "SFDC_Oppty";	
    },
    
    isMn: function(cmp) {
    	return cmp.get("v.opptyRecord2.RecordType.DeveloperName") == "Model_N_Oppty";		
    },
    
    isTmma: function(cmp) {
    	return cmp.get("v.opptyRecord2.Account.Customer_Category__c") == "Tier 4 - TMMA";		
    },
    
    isTmmaOverride: function(cmp) {
    	return this.isMn(cmp) && this.isTmma(cmp);		
    },
    
    isProdView: function(cmp) {
    	return cmp.find("toggle").get("v.checked");		
    },
    
    isMassUpdate: function(cmp) {
    	return cmp.get("v.massUpdate");		
    },
    
    createUuid: function() {
        var dt = new Date().getTime();
        var uuid = 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, function(c) {
            var r = (dt + Math.random()*16)%16 | 0;
            dt = Math.floor(dt/16);
            return (c=='x' ? r :(r&0x3|0x8)).toString(16);
        });
        
        return uuid;    
    },
    
    dateFromISO8601: function(isostr) {
    	var parts = isostr.match(/\d+/g);
    	return new Date(parts[0], parts[1] - 1, parts[2], parts[3], parts[4], parts[5]);   
    },
    
    toSchedDate: function(aDate) {
        return aDate.getFullYear() +  
               "-" + ("0" + (aDate.getMonth() + 1)).slice(-2) +  
               "-" + ("0" + aDate.getDate()).slice(-2);	    
    },
    
    toSchedYearQtr: function(aDate) {
        return aDate.getFullYear() + "Q" + (Math.floor(aDate.getMonth() / 3) + 1);	    
    },
                        
    isNormalInteger: function(str) {
    	var n = Math.floor(Number(str));
    	return n !== Infinity && String(n) === str && n >= 0;    
    },
    
    reset: function(cmp) {
        this.showSpinner(cmp);
        cmp.find("recordLoader").reloadRecord(true);
        cmp.find("recordLoader2").reloadRecord(true);
        this.getOpportunitySchedules(cmp);
        cmp.find("datatable").set("v.draftValues", null);
    },
    
    reset2: function(cmp) {
        cmp.find("datatable2").set("v.draftValues", null);    
    },
    
    debug: function(cmp) {
        //alert('draftValues: ' + JSON.stringify(cmp.find("datatable").get("v.draftValues")));
        //alert('data: ' + JSON.stringify(cmp.get("v.data")));
        //alert('errors: ' + JSON.stringify(cmp.find("datatable").get("v.errors")));
        //alert('draftValues2: ' + JSON.stringify(cmp.find("datatable2").get("v.draftValues")));
        //alert('data2: ' + JSON.stringify(cmp.get("v.data2")));
        //alert('opptyRecord: ' + JSON.stringify(cmp.get("v.opptyRecord"))); 
    	//alert('is sfdc: ' + this.isSfdc(cmp));
        //alert('is mn: ' + this.isMn(cmp));
        //alert('is tmma: ' + this.isTmma(cmp));
        //alert('isTmmaOverride: ' + this.isTmmaOverride(cmp));			
        //alert('stage: ' + this.stage(cmp));			
        //alert('is open: ' + this.isOpen(cmp));
        //alert('is lost: ' + this.isLost(cmp));
        //alert('is commitment: ' + this.isCommitment(cmp));
        //alert('is pending: ' + this.isPending(cmp));
        //alert('is full edit: ' + this.isFullEdit(cmp));
        //alert('is partial edit: ' + this.isPartialEdit(cmp));
        //alert('is locked: ' + this.isLocked(cmp));
    },
    
    lock: function(cmp) {
        if (!cmp.get("v.mutex")) {
            this.p(cmp, "acquired lock");
        	cmp.set("v.mutex", true);
            return true;
        } else {
            return false;
        }
    },
    
    unlock: function(cmp) {
        this.p(cmp, "released lock");
    	cmp.set("v.mutex", false);    
    },
    
    p: function(cmp, msg) {
        if (cmp.get("v.debug")) {
        	alert(msg);
            //this.debug(cmp);
        }    
    },
    
})