({
	setValues : function(component, event, helper) {
        component.set("v.id", event.getParams().arguments.id);
		component.set("v.isHtmlEmail", event.getParams().arguments.isHtmlEmail);
        component.set("v.emailSubject", event.getParams().arguments.emailSubject);
        component.set("v.emailBody", event.getParams().arguments.emailBody);
	},
    saveSlideEmail : function(component, event, helper) {
        var saveSlideEmail = component.getEvent("saveSlideEmail");
        saveSlideEmail.setParams({
            id: component.get("v.id"),
            emailSubject: component.find("emailSubject").get("v.value"),
            emailBody: component.get("v.isHtmlEmail") ? component.find("emailRichText").get("v.value") : component.find("emailBody").get("v.value")
        });
        saveSlideEmail.fire();
    },
    cancel : function(component, event, helper) {
        component.getEvent("cancelSlide").fire();
    }
})