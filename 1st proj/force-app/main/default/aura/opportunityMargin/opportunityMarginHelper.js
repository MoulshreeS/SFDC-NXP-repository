({
	getOpportunityProducts: function(cmp) {
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
                    this.setOpptyBizGroups(cmp);
                	this.setOpptyProdGroups(cmp);
                }
            } else {
                console.log("Failed with state: " + state);
            }
        });
        
        $A.enqueueAction(action);	
	},
    
    setOpptyBizGroups: function(cmp) {
        var opptyProds = cmp.get("v.opptyProds");
        
        var result = [];
        var groups = new Map();
        
        groups.set("BU", new Set());
        groups.set("BL", new Set());
        groups.set("MAG", new Set());
        
        opptyProds.forEach(function(op) {
            groups.get("BU").add(op.bu + " - " + op.buDesc);
            groups.get("BL").add(op.bl + " - " + op.blDesc);
            groups.get("MAG").add(op.mag + " - " + op.magDesc);
        });
        
        groups.forEach(function(value, key, map) {
            result.push({
                name: key,
                items: Array.from(value).sort()    
            });    
        });
        
        cmp.set("v.opptyBizGroups", result);	    
    },
    
    setOpptyProdGroups: function(cmp) {
        var bizGroup = cmp.find("opptyBizSelect").get("v.value");
        cmp.set("v.bizGroup", bizGroup);
        cmp.set("v.opptyProdGroups", this.getOpptyProdGroups(cmp, bizGroup));
        cmp.find("opptyProdSelect").set("v.value", "ALL");
        cmp.set("v.salesItem", "ALL");
    },
    
    getOpptyProdGroups: function(cmp, bizGroup) {
        var opptyProds = cmp.get("v.opptyProds");
        
    	var result = [];
        var groups = new Map();
        
        // Cannot use opptyProds.forEach since it is not allowed to call function inside forEach. 
        for (var i = 0; i < opptyProds.length; i++) {
            var op = opptyProds[i];
            
            if (!this.prodInGroup(op, bizGroup)) continue; 
            
            if (groups.has(op.type)) {
                groups.get(op.type).push({
                    id: op.id,
                    prodName: op.prodName,
                    salesItem: op.salesItem 
                });
            } else {
                var items = [];
                
                items.push({
                    id: op.id,
                    prodName: op.prodName,
                    salesItem: op.salesItem
                });
                
                groups.set(op.type, items);
            }
        }
        
        groups.forEach(function(value, key, map) {
            result.push({
                name: key,
                items: value    
            })    
        });
        
        return result;
    },
    
    prodInGroup: function(opptyProd, bizGroup) {
        return (bizGroup == "ALL") || 
               ((opptyProd.bu + " - " + opptyProd.buDesc) == bizGroup) || 
               ((opptyProd.bl + " - " + opptyProd.blDesc) == bizGroup) || 
               ((opptyProd.mag + " - " + opptyProd.magDesc) == bizGroup);
    },
    
    getOpportunityProductSchedulesWithMargin: function(cmp) {
        var action = cmp.get("c.getOpportunityProductSchedulesWithMargin");
        
        action.setParams({
            opptyId: cmp.get("v.recordId")
        });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            
            if (state === "SUCCESS") {
                this.doneLoading(cmp);
                this.setOpptyProdSchedsWithMargin(cmp, response.getReturnValue());
                this.setSummaryInfo(cmp);
                this.setData(cmp);
            } else {
                this.doneLoading(cmp);
                console.log("Failed with state: " + state);
            }
        });
        
        $A.enqueueAction(action);		
	},
    
    doneLoading: function(cmp) {
    	cmp.set("v.loaded", !cmp.get("v.loaded"));
        $A.util.addClass(cmp.find("spinner"), "slds-hide");    
    },
    
    setOpptyProdSchedsWithMargin: function(cmp, prodScheds) {
        var result = new Map();
        
        for (var group in prodScheds) {
            var scheds = new Map();
            
            for (var time in prodScheds[group]) {
                scheds.set(time, prodScheds[group][time]);
            }
            
            result.set(group, scheds);
        }
        
        cmp.set("v.opptyProdSchedsWithMargin", result);
    },
    
    setSummaryInfo: function(cmp) {
        var prodGroups = cmp.get("v.opptyProdGroups");
        var prod = cmp.find("opptyProdSelect").get("v.value");
        var amtCost = 0;
        var amtNoCost = 0;
                
        prodGroups.forEach(function(value, index, array) {
            var type = value["name"];  
            var prods = value["items"];
            
            if (type == "With Cost") {
                prods.forEach(function(value, index, array) {
                    var prodScheds = cmp.get("v.opptyProdSchedsWithMargin").get(value["id"]).get("Year");
                    
                    if ((prod == "ALL") || (prod == value["id"])) {
                        prodScheds.forEach(function(value, index, array) {
                            if (value["schedYearQtr"] != "Total") {
                                amtCost += value["prodValue"];    
                            }    
                        });    
                    }
                });
            } else if (type == "Without Cost") {
            	prods.forEach(function(value, index, array) {
                    var prodScheds = cmp.get("v.opptyProdSchedsWithMargin").get(value["id"]).get("Year");
                    
                    if ((prod == "ALL") || (prod == value["id"])) {
                        prodScheds.forEach(function(value, index, array) {
                            if (value["schedYearQtr"] != "Total") {
                                amtNoCost += value["prodValue"];    
                            }    
                        });    
                    }
                });    
            }
        });
        
        cmp.set("v.amtCost", Math.round(amtCost));
        cmp.set("v.amtNoCost", Math.round(amtNoCost));
    },
    
    setData: function(cmp) {
        var key;
        var time = cmp.find("toggle").get("v.checked") ? "Qtr" : "Year";
        var bizGroup = cmp.find("opptyBizSelect").get("v.value");
        var prod = cmp.find("opptyProdSelect").get("v.value");
        
        if (prod != "ALL") {
        	key = prod;    
        } else {
            key = bizGroup;
        }
        
        var value = cmp.get("v.opptyProdSchedsWithMargin").get(key);
        
        if (value && value.get(time).length > 0) {
        	cmp.set("v.data", value.get(time)); 
            $A.util.removeClass(cmp.find("data"), "slds-hide");
            $A.util.addClass(cmp.find("nodata"), "slds-hide");
        } else {
            cmp.set("v.data", null);
            $A.util.addClass(cmp.find("data"), "slds-hide");
            $A.util.removeClass(cmp.find("nodata"), "slds-hide");
        }
    },
    
    setOpptyProd: function(cmp) {
        var prod = cmp.find("opptyProdSelect").get("v.value");
        var opptyProds = cmp.get("v.opptyProds");
        var salesItem = "ALL";
        
        opptyProds.forEach(function(value, index, array) {
            if (value["id"] == prod) {
                salesItem = value["salesItem"];
                return;    
            }    
        });
        
        cmp.set("v.salesItem", salesItem);
    },
})