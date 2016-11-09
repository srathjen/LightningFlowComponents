({	
    init : function(component, event, helper) {
        if (!helper.isLockerServiceActive()) {
            var action = component.get("c.salesforceBaseUrl");
            action.setCallback(this, function(response) {
                if (response.getState() === "SUCCESS") {
                    component.set("v.baseUrl", response.getReturnValue());
                }
            });
            $A.enqueueAction(action);  
            
            var getCustomizeApplication = component.get("c.getCustomizeApplication");
            getCustomizeApplication.setCallback(this, function(response) {
                var state = response.getState();
                if (state !== "SUCCESS") {
                    component.getEvent('showError').setParams({
                        message: 'An unexpected error has occurred.'
                    }).fire();
                    component.set('v.customizeApplication', false);
                } else if (response.getReturnValue() !== true) {
                    component.set('v.alertText', 'You need the Customize Application permission to complete the setup and start generating documents. Contact your system administrator, or continue and complete steps that require this permission later.');
                    component.set('v.customizeApplication', false);
                }
            });
            $A.enqueueAction(getCustomizeApplication);
        }
        else {
            $A.util.addClass(component.find('pageContent'), 'hidden');
            $A.util.removeClass(component.find('lockerServiceMessage'), 'hidden');
        }
    },
	toggle : function(component, event, helper) {
        var label = event.target.getAttribute("id");
        var iconDiv;
        var element = component.find(label + "-Node");
        if (label !== null && label.indexOf("-icon") > -1) {
            iconDiv = label;
        } else {
            iconDiv = label + "-icon"
        }
        var icon = component.find(iconDiv);
        $A.util.toggleClass(element, "slds-collapsed");
        !$A.util.hasClass(element, "slds-collapsed") ? $A.util.addClass(icon, "icon-on") : $A.util.removeClass(icon, "icon-on");
        component.set('v.onClickRenderDummy', !component.get('v.onClickRenderDummy'));
    },
    focused : function(component, event) {
    	var label = event.target.getAttribute("id");
    	$A.util.addClass(component.find(label), "section-header");
	},
    blur : function(component, event) {
    	var label = event.target.getAttribute("id");
    	$A.util.removeClass(component.find(label), "section-header");
	},
    click : function(component, event, helper){
        component.set('v.alertText', '');
        component.set('v.disableSave', false);
        var id = event.target.getAttribute("id");
        component.set("v.step", id);
        switch(id) {
            case "classicExperienceButtons":
            case "edition":
            case "settings":
            case "testUserConfiguration":
            case "userPermissions":
            case "sampleDdps":
                component.set("v.saveVisible", true);
                break;
            default:
                component.set("v.saveVisible", false);
                break;
        }
        helper.isSelected(component, event);
    },
    search : function(component, event, helper) {
        helper.searchHelper(component);
    },
    save : function(component, event, helper) {
        component.set('v.alertText', '');
        component.set('v.busy', true);
        if (component.get("v.step") === "edition") {
            var edition = component.find("editionComponent");
            edition.save();
        }
        else if (component.get("v.step") === "testUserConfiguration") {
            var testUsers = component.find("testUserConfigurationComponent");
            testUsers.save();
        }
        else if (component.get("v.step") === "userPermissions") {
            var setupUsers = component.find("setupUsers");
            setupUsers.save();
        }
        else if (component.get("v.step") === "settings") {
            var settings = component.find("settingsStep");
            settings.save();
            var pauseToEdit = component.find("pauseToEdit");
            pauseToEdit.save();
        }
        else if (component.get("v.step") === "classicExperienceButtons") {
            var classicButtons = component.find("classicButtons");
            classicButtons.save();
        }
        else if (component.get('v.step') === 'sampleDdps') {
            var sampleDdps = component.find('sampleDdpsComponent');
            sampleDdps.save();
        }
    },
    redirectButtons : function(component, event) {
        var label = event.getParam("buttonName");
        if (label) {
            component.set("v.step", label);
            $A.util.addClass(component.find(label), "slds-is-selected");
            $A.util.removeClass(component.find("buttonToggle-Node"), "slds-collapsed");
            $A.util.addClass(component.find("buttonToggle-icon"), "icon-on");
        }
        if (label === "classicExperienceButtons") {
            component.set("v.saveVisible", true);
        }
    },
    hideSpinner : function(component) {
        document.getElementById("spinner").style.display = 'none';
        document.getElementById("settingsContainer").style.display = 'inline-block';
    },
    actionComplete : function(component, event) {
        if (event.getParam('success')) {
	        component.set('v.alertText', 'Save successful!');
        }
        component.set('v.busy', false);
    },
    showError : function(component, event, helper) {
        var errorPrompt = component.find('errorPrompt');
        var title = event.getParam('title');
        var message = event.getParam('message');
        errorPrompt.showError(title, message);
    },
    disableSave : function(component, event) {
		component.set("v.disableSave", true);
    }
})