({
    onInit : function(component) {
        component.set("v.isLoading", true);
        
        var checkAuthentication = component.get("c.checkAuthentication");
        checkAuthentication.setParams({
            domain: component.get("v.loopUrl") ? component.get("v.loopUrl") : ""
        });
        checkAuthentication.setCallback(this, function(response) {
            if (response.getState() === 'SUCCESS') {
                var parsedResponse = JSON.parse(response.getReturnValue());
                if (parsedResponse.isSuccess) {
                    component.set("v.isAuthorized", parsedResponse.isAuthorized);
                    component.set("v.connectedAppsEnabled", parsedResponse.connectedAppsEnabled);
                    component.set("v.oAuthUrl", parsedResponse.oAuthUrl);
                }
                else {
                    helper.fireErrorEvent(component, parsedResponse.errorMessage);
                }
            }
            else {
                helper.fireErrorEvent(component, 'There was a problem retrieving sample DDP metadata.');
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
	filterDdps : function(component, event, helper) {
        var params = event.getParams();
        component.set("v.searchText", params.searchText || '');
        component.set("v.businessUser", params.businessUser);
	},
    save : function(component, event, handler) {
        component.find('sampleDdpTable').save();
    }
})