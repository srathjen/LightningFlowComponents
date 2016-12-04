({
    setValues : function(component, event, helper) {
        component.set("v.id", event.getParams().arguments.id);
        component.set("v.reminderDelay", event.getParams().arguments.reminderDelay);
        component.set("v.daysTillSigningExpires", event.getParams().arguments.daysTillSigningExpires);
        component.set("v.reminderFrequency", event.getParams().arguments.reminderFrequency);
        component.set("v.warnOfExpiration", event.getParams().arguments.warnOfExpiration);
        
    },
    saveSettings : function(component, event, helper) {
        var saveSlideDocuSignReminders = component.getEvent("saveSlideDocuSignReminders");
        saveSlideDocuSignReminders.setParams({
            id: component.get("v.id"),
            reminderDelay: component.find("reminderDelay").get("v.value"),
            daysTillSigningExpires: component.find("daysTillSigningExpires").get("v.value"),
            reminderFrequency: component.find("reminderFrequency").get("v.value"),
            warnOfExpiration: component.find("warnOfExpiration").get("v.value")
        });
        saveSlideDocuSignReminders.fire();
    },
	cancel : function(component, event, helper) {
        component.getEvent("cancelSlide").fire();
    }
})