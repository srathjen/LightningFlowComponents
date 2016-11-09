({
    doInit : function(cmp, event, helper) {
        var action = cmp.get("c.currentOrgOAuthSetting");
        action.setCallback(this, function(response) {
            var retVal = response.getReturnValue();
            if (retVal) {
                helper.disable(cmp, 'Enable');
                helper.enable(cmp, 'Disable');
                cmp.set("v.oAuthEnabled", true);
        	} else {
                helper.disable(cmp, 'Disable');
                helper.enable(cmp, 'Enable');
                cmp.set("v.oAuthEnabled", false);
        	}
        });
        $A.enqueueAction(action);
    },
    onChange : function(cmp, event, helper) {
        var button = event.target.getAttribute("data-data");
        if (button === 'Enable') {
            cmp.set("v.oAuthEnabled", true);
            helper.disable(cmp, 'Enable');
        	helper.enable(cmp, 'Disable');
        } else {
            cmp.set("v.oAuthEnabled", false);
            helper.disable(cmp, 'Disable');
            helper.enable(cmp, 'Enable');
        }
    },
    save : function(cmp, event, helper) {
        var selection = cmp.get("v.oAuthEnabled");
        var action = cmp.get("c.enableDisableOrgOAuth");
        action.setParams({ "selection" : selection });
        action.setCallback(this, function(response) {
            var moveToNextStep = cmp.getEvent("moveToNextStep");
            moveToNextStep.setParams({success: true}).fire();
        });
        $A.enqueueAction(action);
    }
})