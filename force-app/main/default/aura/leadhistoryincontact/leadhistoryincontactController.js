({
    doInit : function(component, event, helper) {
        /*
        
        
         component.set('v.columnsToDisplay', [
            {label: 'Field', fieldName: 'Field', type: 'Name'},                   
            {label: 'Old Value', fieldName: 'OldValue'},
            {label: 'New Value', fieldName: 'NewValue'},
            {label: 'Created Date', fieldName: 'CreatedDate'},
   
        ]);
        */
        helper.getLeadHistoryChanges(component,event, helper);
        
        component.set('v.columnsToDisplay', [
            //  {label: 'Id', fieldName: 'LeadId', type: 'Id', initialWidth: 180},
            
            {label: 'Lead Name', fieldName: 'linkName', type: 'url', initialWidth: 110,
             typeAttributes: {label: { fieldName: 'LeadName' },value:{fieldName: 'linkName'}, target: '_blank'}
            }, 
            {label: 'Lead Category', fieldName: 'Rating',initialWidth: 10},
            {label: 'CreatedDate', fieldName: 'CreatedDate',initialWidth: 100},
             {label: 'Owner', fieldName: 'User', initialWidth: 90},
            {label: 'Status', fieldName: 'Status',initialWidth: 80},
            {label: 'Rejection Reason', fieldName: 'RejectionReason',initialWidth: 100},
            {label: 'Disti Company', fieldName: 'Company',initialWidth: 120},
            {label: 'Project Description', fieldName: 'ProjectDescription',initialWidth: 120},
            {label: 'MAG Code', fieldName: 'MAGCode'},
           
            
            
            
        ]);
            
            
            }
            })