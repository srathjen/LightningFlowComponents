({
    onInit : function(component, event, helper) {
        var recipient = component.get("v.recipient");
        
        if (recipient.RecipientType === "NameEmail") {
            component.set("v.name", recipient.Name);
            component.set("v.email", recipient.Email);
        }
        
        component.set("v.selectedRecipientId", recipient.DefaultRecipientId ? recipient.DefaultRecipientId : '');
        
        if (component.get('v.isHost')) {
            component.set("v.signerLabel", "Host");
        }
        
        helper.sendRecipientInfo(component);
    },
    close : function(component, event, helper) {
        var recipientType = component.get("v.recipient").RecipientType;
        if (recipientType === 'DropDown') {
            var dropdowns = component.find('recipientDropdown');
            if (dropdowns.length) {
                for (var i = 0; i < dropdowns.length; i++) {
                    dropdowns[i].closeDropdown();
                }
            }
            else {
                dropdowns.closeDropdown();
            }
        }
    },
    open : function(component, event, helper) {
        var recipientType = component.get("v.recipient").RecipientType;
        if (recipientType === 'DropDown') {
            component.find('recipientDropdown').openDropdown();
        }
    },
    clicked : function(component, event) {
        component.getEvent("recipientSelectorClicked").setParams({
            globalId: component.getGlobalId()
        }).fire();
    },
    handleRecipientSelected : function(component, event, helper) {
        component.set("v.selectedRecipientId", event.getParams().id);
        helper.sendRecipientInfo(component);
    },
    exposeAccessCodeInput : function(component, event, helper) {
        component.find("accessCodeLink").getElement().hidden = true;
        component.find("accessCodeInput").getElement().hidden = false;
        component.find("accessCode").getElement().value = component.get("v.accessCodeValue");
    },
    inputAccessCode : function(component, event, helper) {
        var currentInput = component.find("accessCode").getElement().value;
        component.set("v.accessCodeValue", currentInput);
        
        var remaining = 100 - currentInput.length;
        if (remaining < 15) {
            $A.util.addClass(component.find("characters"), "red");
        } else {
            $A.util.removeClass(component.find("characters"), "red");
        }
        component.set("v.remainingCharacters", remaining === 1 ? remaining + " character remaining" : remaining + " characters remaining");
        helper.sendRecipientInfo(component);
    },
    exposeNoteInput : function(component, event, helper) {
        component.find("noteLink").getElement().hidden = true;
        component.find("noteInput").getElement().hidden = false;
        component.find("note").getElement().value = component.get("v.noteValue");
    },
    inputNote : function(component, event, helper) {
        var currentInput = component.find("note").getElement().value;
        component.set("v.noteValue", currentInput);
        helper.sendRecipientInfo(component);
    },
    updateStaticName : function(component, event, helper) {
        component.set("v.name", event.currentTarget.value);
        helper.sendRecipientInfo(component);
    },
    updateStaticEmail : function(component, event, helper) {
        component.set("v.email", event.currentTarget.value);
        helper.sendRecipientInfo(component);
    }
})