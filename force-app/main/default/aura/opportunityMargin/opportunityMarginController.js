({
	init: function(cmp, event, helper) {
        cmp.set("v.columns", [
            {label: "Sched Date", fieldName: "schedYearQtr", type: "text", cellAttributes: {class: {fieldName: "schedYearQtr"}, alignment: "right"}},
            {label: "QTY", fieldName: "prodQty", type: "number", cellAttributes: {class: {fieldName: "schedYearQtr"}}},
            {label: "ASP", fieldName: "prodSchedPrice", type: "number", typeAttributes: {style: "decimal", minimumFractionDigits: "6", maximumFractionDigits: "6"}, cellAttributes: {class: {fieldName: "schedYearQtr"}}},
            {label: "AMT", fieldName: "prodValue", type: "number", typeAttributes: {maximumFractionDigits: "0"}, cellAttributes: {class: {fieldName: "schedYearQtr"}}},
            {label: "Unit Cost", fieldName: "unitCost", type: "number", typeAttributes: {style: "decimal", minimumFractionDigits: "6", maximumFractionDigits: "6"}, cellAttributes: {class: {fieldName: "schedYearQtr"}}},
            {label: "Cost", fieldName: "prodCost", type: "number", typeAttributes: {maximumFractionDigits: "0"}, cellAttributes: {class: {fieldName: "schedYearQtr"}}},
            {label: "Margin", fieldName: "prodMargin", type: "number", typeAttributes: {maximumFractionDigits: "0"}, cellAttributes: {class: {fieldName: "schedYearQtr"}}},
            {label: "Margin %", fieldName: "prodMarginPct", type: "percent", cellAttributes: {class: {fieldName: "schedYearQtr"}, alignment: "center"}}
        ]);
        
        $A.util.addClass(cmp.find("nodata"), "slds-hide");
        $A.util.addClass(cmp.find("bizGroup"), "Summary");
        $A.util.addClass(cmp.find("salesItem"), "Summary");
        $A.util.addClass(cmp.find("amtCost"), "Summary");
        $A.util.addClass(cmp.find("amtNoCost"), "Summary");
        $A.util.addClass(cmp.find("ccy"), "Summary");
		
        helper.getOpportunityProducts(cmp);
        helper.getOpportunityProductSchedulesWithMargin(cmp);
    },
    
    handleChange: function(cmp, event, helper) {
        switch (event.getSource().get("v.name")) {
        	case "toggle":
                helper.setData(cmp);
                break;
            case "opptyBizSelect":
                helper.setOpptyProdGroups(cmp);
                helper.setSummaryInfo(cmp);
                helper.setData(cmp);
                break;
            case "opptyProdSelect":
                helper.setOpptyProd(cmp);
                helper.setSummaryInfo(cmp);
                helper.setData(cmp);
                break;
        }
    }
})