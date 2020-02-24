({
    doInit: function(component, event, helper) {
        //fires when component is initialized        
        helper.processLeadForDV(component);        
    },
    confirmAction: function(component, event, helper){
        //confirmation box handler        
        helper.handleConfirmation(true, component);
    },
    closeComponent: function(component, event, helper){
        //Close the current component
        helper.closeQuickAction();
    }
})