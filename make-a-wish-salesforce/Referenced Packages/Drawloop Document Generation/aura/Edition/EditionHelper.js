({
    clearServices : function(component) {
        component.set("v.standardScheduledDdp", false);
        component.set("v.businessScheduledDdp", false);
        component.set("v.workflowDdp", false);
        component.set("v.componentLibrary", false);
        component.set("v.massDdp", false);
    },
    parseQueryString : function(qstr) {
        var query = {};
        qstr = qstr[0] === '?' ? qstr.substr(1) : qstr
        var a = qstr.split('&');
        for (var i = 0; i < a.length; i++) {
            var b = a[i].split('=');
            query[decodeURIComponent(b[0])] = decodeURIComponent(b[1] || '');
        }
        return query;
    },
    load : function(component, sessionId, location) {
        component.set("v.isLoading", true);
        
        var fetchServices = component.get("c.fetchServices");
        fetchServices.setParams({
            sessionId: sessionId,
            location: location ? location : "",
            domain: component.get("v.loopUrl")
        });
        fetchServices.setCallback(this, function(response) {
            if (response.getState() === "SUCCESS") {
                var parsedResponse = JSON.parse(response.getReturnValue());
                if (parsedResponse.isSuccess) {
                    component.set("v.isTrial", parsedResponse.isTrial);
                    component.set("v.isSandbox", parsedResponse.isSandbox);
                    component.set("v.hasContract", parsedResponse.hasContract);
                    
                    var isStandard = parsedResponse.isStandard;
                    this.clearServices(component);
                    component.set("v.isStandard", isStandard);
                    
                    if (isStandard) {
                        component.set("v.standardScheduledDdp", parsedResponse.scheduledDdp);
                    }
                    else {
                        component.set("v.businessScheduledDdp", parsedResponse.scheduledDdp);
                        component.set("v.workflowDdp", parsedResponse.workflowApexDdp);
                        component.set("v.componentLibrary", parsedResponse.componentLibrary);
                        component.set("v.massDdp", parsedResponse.massDdp);
                    }
                    
            		component.set("v.isLoading", false);
                }
                else {
                    this.fireErrorEvent(component, parsedResponse.errorMessage);
                }
                
                if (parsedResponse.hasContract && !parsedResponse.isSandbox) {
                    this.disableAll(component);
                	component.set("v.isLoading", false);
                }
            }
            else {
                this.fireErrorEvent(component, '');
            }
        });
        
        $A.enqueueAction(fetchServices);
    },
    disableAll : function(component) {
        component.set("v.disableAll", true);
        component.getEvent("disableSave").fire();
    },
    fireErrorEvent : function(component, message) {
        component.getEvent('showError').setParams({
            message: message
        }).fire();
    }
})