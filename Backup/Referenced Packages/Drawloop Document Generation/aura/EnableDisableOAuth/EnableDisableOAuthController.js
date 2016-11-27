({
    doInit : function(component, event, helper) {
        var action = component.get('c.currentOrgOAuthSetting');
        action.setCallback(this, function(response) {
            var retVal = response.getReturnValue();
            component.set('v.oAuthEnabled', retVal);
            helper.toggleOAuthButtons(component);
        });
        $A.enqueueAction(action);
    },
    onChange : function(component, event, helper) {
        var currentSelection = event.currentTarget.id;
        component.set('v.oAuthEnabled', currentSelection === 'enable');
        helper.toggleOAuthButtons(component);
    },
    save : function(component, event, helper) {
        var selection = component.get('v.oAuthEnabled');
        var action = component.get('c.enableDisableOrgOAuth');
        action.setParams({ 'selection' : selection });
        action.setCallback(this, function(response) {
            var moveToNextStep = component.getEvent('moveToNextStep');
            moveToNextStep.setParams({success: true}).fire();
        });
        $A.enqueueAction(action);
    }
})