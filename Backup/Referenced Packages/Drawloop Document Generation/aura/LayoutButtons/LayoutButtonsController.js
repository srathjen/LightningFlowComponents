({
    onInit : function(component, event, helper) {
        component.set("v.isLoading", true);
        
        var domain = component.get("v.apiUrl");
        
        var checkAuthentication = component.get("c.checkAuthentication");
        checkAuthentication.setParams({
            domain: domain
        });
        checkAuthentication.setCallback(this, function(response) {
            if (response.getState() === "SUCCESS") {
                var parsedResponse = JSON.parse(response.getReturnValue());
                if (parsedResponse.isSuccess) {
                    component.set("v.isAuthorized", parsedResponse.isAuthorized);
                    component.set("v.oAuthUrl", parsedResponse.oAuthUrl);
                    component.set("v.connectedAppsEnabled", parsedResponse.connectedAppsEnabled);
                }
                else {
                    helper.fireErrorEvent(component, parsedResponse.errorMessage);
                }
            }
            else {
                helper.fireErrorEvent(component, 'There was a problem retrieving layout metadata.');
            }
            
        	component.set("v.isLoading", false);
        });
        
        $A.enqueueAction(checkAuthentication);
    },
    startOAuth : function(component, event, helper) {
        window.open(component.get("v.oAuthUrl"), 'Salesforce Auth', 'height=811,width=680,location=0,status=0,titlebar=0');
    },
    handleOAuthSuccessful : function(component, event, helper) {
        var sessionId = event.getParams().sessionId;
        
        component.set("v.isAuthorized", true);
        component.set("v.sessionId", sessionId);
    },
	filterObjects : function(component, event, helper) {
        var params = event.getParams();
        component.set("v.searchText", params.searchText || '');
	},
    save : function(component) {
        component.find("layoutButtonTable").save();
    }
})