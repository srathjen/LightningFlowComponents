({
    load : function(component, event, helper) {
        component.set("v.loading", true);
        
        // clear data that would not have been cleared out from a previous Ddp selection
        component.set('v.hasErrorOccurred', false);
        component.set('v.errorMessage', '');
        
        var ddpId = event.getParam("arguments").ddpId;
        var recordId = event.getParam("arguments").recordId;
        var selectedContactId = event.getParam("arguments").selectedContactId;
        
        var selectedDeliveryOptionId = component.get("v.selectedDeliveryOptionId");
        
        var action = component.get("c.getDeliveryOptions");
        action.setParams({
            recordId : recordId,
            ddpId: ddpId,
            contactId: selectedContactId
        });
        action.setCallback(this, function(response) {
            if (response.getState() === "SUCCESS") {
                var parsedResponse = JSON.parse(response.getReturnValue());
                if (parsedResponse.isSuccess) {
                    component.set("v.records", parsedResponse.deliveryOptions);
                }
                else {
                    helper.fireErrorEvent(component, parsedResponse.errorMessage);
                }
            }
            else {
                helper.fireErrorEvent(component, "An unexpected error has occurred. Please contact Drawloop Support if this error persists.");
            }

            component.set("v.loading", false);
        });
        $A.enqueueAction(action);
    },
    search : function(component, event, helper) {
        var searchString = event.getParams().arguments.searchString;
        component.find('deliveryTiles').search(searchString);
    },
    handleErrorEvent : function(component, event) {
        component.set("v.hasErrorOccurred", true);
        component.set("v.errorMessage", event.getParam("message"));
        event.stopPropagation();
    },
    cancelSlide : function(component, event, helper) {
        helper.disableAccordions(component, false);
        helper.disableRunDdpButtons(component, false);
        helper.slideOut(component);
    },
    editEmail : function(component, event, helper) {
        var id = event.getParam("id");
        var isHtmlEmail = event.getParam("htmlEmail");
        var emailSubject = event.getParam("emailSubject");
        var emailBody = event.getParam("emailBody");
        
        component.find("editEmail").setValues(id, isHtmlEmail, emailSubject, emailBody);
        
        helper.disableAccordions(component, true);
        helper.disableRunDdpButtons(component, true);
        helper.hideReminderContainer(component);
        component.find("emailContainer").getElement().hidden = false;
        
        helper.slideIn(component, isHtmlEmail ? '522px' : '407px');
    },
    editDocuSignReminderSettings : function(component, event, helper) {
        var id = event.getParam("id");
        var reminderDelay = event.getParam("reminderDelay");
        var daysTillSigningExpires = event.getParam("daysTillSigningExpires");
        var reminderFrequency = event.getParam("reminderFrequency");
        var warnOfExpiration = event.getParam("warnOfExpiration");
		
        component.find("editDocuSignReminder").setValues(id, reminderDelay, daysTillSigningExpires, reminderFrequency, warnOfExpiration);
        
        helper.disableAccordions(component, true);
        helper.disableRunDdpButtons(component, true);
        helper.hideEmailContainer(component);
        component.find("reminderContainer").getElement().hidden = false;
        helper.slideIn(component, '282px');
    },
    passEmailDataToSelectTiles : function(component, event, helper) {
        helper.slideOut(component);
        helper.disableAccordions(component, false);
        helper.disableRunDdpButtons(component, false);
        component.find("deliveryTiles").passEmailDataToTile(event.getParam("id"),  event.getParam("emailSubject"), event.getParam("emailBody"));
        var updateRunDdp = component.getEvent("updateSlideEmail");
        updateRunDdp.setParams({
            emailSubject : event.getParam("emailSubject"),
            emailBody : event.getParam("emailBody")
        });
        updateRunDdp.fire();
    },
    passDocuSignDataToSelectTiles : function(component, event, helper) {
        helper.slideOut(component);
        helper.disableAccordions(component, false);
        helper.disableRunDdpButtons(component, false);
        component.find("deliveryTiles").passDocuSignReminderDataToTile(event.getParam("id"), event.getParam("reminderDelay"), event.getParam("daysTillSigningExpires"), event.getParam("reminderFrequency"), event.getParam("warnOfExpiration"));
        var updateRunDdp = component.getEvent("updateSlideDocuSignReminders");
        updateRunDdp.setParams({
            reminderDelay : event.getParam("reminderDelay"),
            daysTillSigningExpires : event.getParam("daysTillSigningExpires"),
            reminderFrequency : event.getParam("reminderFrequency"),
            warnOfExpiration : event.getParam("warnOfExpiration")
        });
        updateRunDdp.fire();
    }
})