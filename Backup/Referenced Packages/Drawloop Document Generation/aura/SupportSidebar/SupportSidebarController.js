({
    init : function(component, event, helper) {
        var action = component.get("c.caseBody");
        action.setCallback( this, function(response) {
            if (response.getState() === "SUCCESS") {
                var r = JSON.parse(response.getReturnValue());
                component.set("v.orgId", r.orgId);
                component.set("v.emailBody", r.emailBody);
            } 
        });
        $A.enqueueAction(action);
    },
	loginAccess : function(component, event, helper) {
		window.open("/partnerbt/grantLoginAccess.apexp", "_blank")
	},
    openCase : function(component, event, helper) {
        var body = component.get("v.emailBody");
        var link = "mailto:ddpsupport@nintex.com"
             + "?subject=" + escape("Support Request")
             + "&body=" + body
	    ;
        window.open(link, "_blank");
    }
})