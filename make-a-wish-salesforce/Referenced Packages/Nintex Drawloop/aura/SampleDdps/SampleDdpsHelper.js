({
    fireErrorEvent : function(component, message) {
        component.getEvent('showError').setParams({
            message: message
        }).fire();
    }
})