({
    init: function (cmp, event, helper) {
        helper.getAttachmentList(cmp, event, helper);
    },
    
    // this function automatic call by aura:waiting event  
    showSpinner: function(component, event, helper) {
        // make Spinner attribute true for display loading spinner 
        component.set("v.Spinner", true); 
    },
    
    // this function automatic call by aura:doneWaiting event 
    hideSpinner : function(component,event,helper){
        // make Spinner attribute to false for hide loading spinner    
        component.set("v.Spinner", false);
    },
    
    getSelectedAccName: function (cmp, event) {
        var selectedAccRows = event.getParam('selectedRows');
        for (var i = 0; i < selectedAccRows.length; i++){
            //alert(selectedAccRows[i].accountName+" is selected");
        }
    },
    
    handleRowAction: function (cmp, event, helper) {
        var action = event.getParam('action');
        var row = event.getParam('row');
        switch (action.name) {
            case 'download':
                helper.downloadAttachment(cmp, event, helper, row);
                break;
            case 'delete':
                helper.removeAttachment(cmp, event, helper, row.Id);
                break;
        }
    },
    
    navigateToDashboard: function (component, event, helper) {
        helper.navigateToDashboard(component, event, helper);
    },
    
    handleApplicationEvent:  function (component, event, helper) {
        if(event.getParam("notifymessage") == 'fileupload') {
            component.set('v.showComponent', true);
            helper.refreshAttachment(component, event, helper);
        }
        
    }
})