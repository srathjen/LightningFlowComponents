({
    init : function(component) {
        var action = component.get('c.fetchServices');
        action.setParams({
            sessionId: component.get('v.sessionId'),
            location: '',
            domain: ''
        });  
        action.setCallback(this, function(response) {
            if (response.getState() === 'SUCCESS') {
                var parsedResponse = JSON.parse(response.getReturnValue());
                if (parsedResponse.isSuccess) {
                    component.set('v.isMass', parsedResponse.MassDdp);
                    component.set('v.subdomain', parsedResponse.subdomain);
                }
                else {
                    component.getEvent('showError').setParams({
                        message: parsedResponse.errorMessage
                    }).fire();
                }
            }
        });
            
        $A.enqueueAction(action);
    },
    subdomainChange : function(component, event) {
        var subdomain = event.source.get('v.value');
        component.set('v.subdomain', subdomain);
    },
    save : function(component, event, helper) {
        var oAuth = component.find('oAuth');
        oAuth.save();
        
        var action = component.get('c.setSubdomain');
        action.setParams({
            subdomain: component.get('v.subdomain')
        });
        
        $A.enqueueAction(action);
    }
})