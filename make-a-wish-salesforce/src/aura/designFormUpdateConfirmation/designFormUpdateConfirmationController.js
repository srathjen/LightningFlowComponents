({
	 update : function(component, event, helper) {
        // When option is selected, set flow variable used in the flow decision to navigate to the next screen
        var response = event.getSource().getLocalId();
        component.set("v.formValue", response); 
        var navigate = component.get("v.navigateFlow");
        navigate("NEXT");
    },
    
    declineUpdate : function(component, event, helper) {
        // When option is selected, set flow variable used in the flow decision to navigate to the next screen
        var response = event.getSource().getLocalId();
        component.set("v.formValue", response); 
        var navigate = component.get("v.navigateFlow");
        navigate("BACK");
    },
})