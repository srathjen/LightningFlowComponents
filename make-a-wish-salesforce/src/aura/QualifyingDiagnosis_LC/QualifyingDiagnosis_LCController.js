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
    },
    handleRadioChange : function(component, event, helper){
        helper.validateFormElements(component, event,helper);
    },
    handleComponentEvent: function(component, event, helper) {
        helper.resetRadioButtonValues(component, event);
    },
    updateDiagnosis : function(component, event, helper){
        helper.updateQualifyingDiagnosis(component,event);    
    },
    handleSampleEvent : function(component, event, helper){
      helper.resetLookupValues(component, event, helper);
    }
})