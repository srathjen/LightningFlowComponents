({
    isLockerServiceActive : function() {
        try {
            // 'use strict' is enforced when LockerService is activated so the following undeclared variable should throw an exception.
            x = 3.14;
            return false;
        } catch (ex) {
            return true;
        }
    },
    toggleDeprecated : function(component, selected) {
        var accordionItems = ['ddpSelect', 'contactSelect', 'documentSelect', 'deliverySelect'];
        for (var i = 0; i < accordionItems.length; i++) {
            var item = accordionItems[i];
            var element = component.find(item + "-node");
            var icon = component.find(item + "-icon");
            var lookup = component.find(item + "-search");
            
            if (item === selected) {
                $A.util.toggleClass(element, "accordion-content-expand");
                $A.util.toggleClass(icon, "icon-on");
                $A.util.toggleClass(lookup, "search-hidden");
                
            } else {
                if ($A.util.hasClass(element, "accordion-content-expand")) {
	                $A.util.removeClass(element, "accordion-content-expand");
                }
                if ($A.util.hasClass(icon, "icon-on")) {
	                $A.util.removeClass(icon, "icon-on");
                }
                if (!$A.util.hasClass(lookup, "search-hidden")) {
	                $A.util.addClass(lookup, "search-hidden");
                }
           }
        }
	},
    toggleNextSection : function(component) {
        var nextSection = !component.get('v.contactId')
        	? 'contactAccordionSection'
        	: component.get('v.displayDocumentSection')
        		? 'documentAccordionSection' 
        		: 'deliveryAccordionSection';
        this.toggleSections(component, nextSection);
    },
    toggleSections : function(component, selectedSectionName) {
        var accordionSections = ['ddpAccordionSection', 'contactAccordionSection', 'documentAccordionSection', 'deliveryAccordionSection'];
        for (var i = 0; i < accordionSections.length; i++) {
            var sectionName = accordionSections[i];
            var accordionSection = component.find(sectionName);
            if (accordionSection) {
                if (sectionName === selectedSectionName) {
                    accordionSection.toggle();
                } else {
                    accordionSection.collapse();
                }
            }
        }
    },
    updateRunButtonStatus : function(component) {
        var ddpSelected = !!component.get('v.ddpId');
        var contactSatisfied = true;
        if (component.get("v.contactRequired")) {
            if (component.get("v.contactId")) {
                contactSatisfied = true;
            }
            else {
                contactSatisfied = false;
            }
        }
        var deliveryOptionSelected = !!component.get('v.deliveryOptionId');
        
        var eSignRecipients = component.get('v.currentESignRecipients');
        var recipientsSatisfied = true;
        for (var i = 0; i < eSignRecipients.length; i++) {
            if (!eSignRecipients[i].satisfied) {
                recipientsSatisfied = false;
                break;
            }
            
            if (eSignRecipients[i].host && !eSignRecipients[i].host.satisfied) {
                recipientsSatisfied = false;
                break;
            }
        }
        
        var attachmentSatisfied = true;
        if (component.get("v.attachmentRequired")) {
            if (component.get("v.attachmentIds").length > 0) {
                attachmentSatisfied = true;
            }
            else {
                attachmentSatisfied = false;
            }
        }
        var runEnabled = ddpSelected && contactSatisfied && deliveryOptionSelected && attachmentSatisfied && recipientsSatisfied;
        component.set('v.runDisabled', !runEnabled);
    },
    expandAndLoadDdps : function(component) {
        //disable 'Select DDP' button if it exists, it exists when !v.startExpanded
        var selectDdpButton = component.find('selectDdpButton');
        if (!component.get("v.startExpanded")) {
	        selectDdpButton.getElement().disabled = true;
        }
        
        //make sure the user has access to all the DDP objects before loading the Run DDP component
        var action = component.get('c.insufficientObjectAccess');
        action.setCallback(this, function(response) {
            if (response.getState() === 'SUCCESS') {
                if (response.getReturnValue()) {
                    $A.util.addClass(component.find("runDdpContainer"), "hidden");
                    $A.util.addClass(component.find("runDdpButton"), "hidden");
                    component.find("header").getElement().style.borderBottom = '1px solid #CFD7E6';
                    component.set("v.errorMessage", "You do not have the appropriate object level access. Please contact your Salesforce administrator.");
                    $A.util.removeClass(component.find("errorContainer"), "hidden");
                } else {
                    //hide 'Select DDP' button if it exists, it exists when !v.startExpanded
                    if (!component.get("v.startExpanded")) {
                        selectDdpButton.getElement().style.display = 'none';
                    }
                    
                    //expose hidden elements
                    $A.util.removeClass(component.find("runDdpContainer"), "hidden");
                    $A.util.removeClass(component.find("runDdpButton"), "hidden");
                    $A.util.removeClass(component.find("footer"), "hidden");
                    
                    //expandDdps
                    this.toggleSections(component, 'ddpAccordionSection');
                    
                    //TODO:
                    //the values being passed below need to be updated if there are any filters or pre-selected options.
                    component.find("ddpSelect-component").load(component.get("v.recordId"), "", "", "", component.get("v.ddpLabel"));
                }
            }
        });
        $A.enqueueAction(action);
    },
    fetchPreOAuthData : function(component) {
        var sub = window.location.hostname;
        sub = sub.substring(0, sub.indexOf('lightning.force.com') + 'lightning'.length);
        var action = component.get("c.fetchPreOAuthData");
        action.setParams({subdomain: sub});
        action.setCallback(this, function(response) {
            if (response.getState() === "SUCCESS") {
                var parsedResponse = JSON.parse(response.getReturnValue());
                if (parsedResponse.isSuccess) {
                    component.set("v.needsAuthentication", parsedResponse.needsAuthentication);
                    component.set("v.oAuthUrl", parsedResponse.oAuthUrl);
                }
            }
        });
        $A.enqueueAction(action);
    },
	authorizeLoopServices : function(component) {
        function onResponseMessage(event) {
            var subdomain = window.location.hostname.split('.')[0];
            if (event.origin.indexOf(subdomain) && event.origin.indexOf('visual.force.com')) {
                if (event.data.message === 'authorizeUser') {
                    var oAuthSuccessfulEvent = $A.get('e.Loop:oAuthSuccessful');
                    oAuthSuccessfulEvent.setParams({authorizingUser: event.data.user});
                    oAuthSuccessfulEvent.fire();
                }
            }
        }
        
        if (window.addEventListener) {
            window.addEventListener('message', onResponseMessage);
        }
        else if (window.attachEvent) {
            window.attachEvent('message', onResponseMessage);
        }
        
        window.open(component.get("v.oAuthUrl"), 'Salesforce Auth', 'width=500, height=680');
	},
    runDdp : function(component) {
        // Disable button
		component.set('v.runDisabled', true);
        
        // Disable all accordion sections
        this.toggleAccordionsDisabled(component, true);
        
        // Reset final message
        component.set('v.finalMessage', '');

        var action = component.get("c.prepRunDdp");
        action.setParams({
            ddpId: component.get("v.ddpId"),
            recordId: component.get("v.recordId"),
            contactId: component.get("v.contactId"),
            documentIds: component.get("v.documentIds"),
            deliveryOptionId: component.get("v.deliveryOptionId"),
            deliveryType: component.get("v.deliveryOptionType"),
            attachmentIds: component.get("v.attachmentIds"),
            usePreview: component.get("v.isTest"),
            workspaceId: component.get("v.selectedContentLibrary"),
            attachToRecord: component.get("v.attachToRecord"),
            reminderDelay: component.get("v.reminderDelay"),
            reminderFrequency: component.get("v.reminderFrequency"),
            expireAfter: component.get("v.expireAfter"),
            expireWarn: component.get("v.expireWarn"),
            workspaceId: component.get("v.selectedContentLibrary"),
            emailSubject: component.get("v.emailSubject"),
            emailText: component.get("v.emailText")
        });
        action.setCallback(this, function(response) {
            if (response.getState() === "SUCCESS") {
                var parsedResponse = JSON.parse(response.getReturnValue());
                if (parsedResponse.isSuccess) {
                    $A.util.addClass(component.find("runDdpButton"), "hidden");
                    $A.util.addClass(component.find("reRunButtons"), "hidden");

                    component.find("processDdp").resetBar();
                    $A.util.removeClass(component.find("processDdpContainer"), "hidden");
                    component.find("processDdp").start(parsedResponse.processDdpParameters, component.get("v.currentESignRecipients"), component.getGlobalId());

                    component.set("v.objectName", parsedResponse.objectType);
                } else {
                    $A.util.addClass(component.find("runDdpContainer"), "hidden");
                    component.set("v.errorMessage", parsedResponse.errorMessage);
                    $A.util.removeClass(component.find("errorContainer"), "hidden");
                }
            } else {
                $A.util.addClass(component.find("runDdpContainer"), "hidden");
                component.set("v.errorMessage", response.getError()[0]);
                $A.util.removeClass(component.find("errorContainer"), "hidden");
            }
        });
        $A.enqueueAction(action);
    },
    resetDdpData : function(component) {
        //badges are being set in AccordionSection component's setBadge function
        
        //DDP
        component.set('v.ddpId', '');
        this.resetSelections(component);
        component.find("ddpSelect-component").clearTiles();
        
        //Contact
        component.set('v.contactId', '');
        
        this.toggleSections(component, 'ddpAccordionSection');
    },
    resetSelections : function(component) {
        //Documents
        component.set('v.documentIds', []);
        
        //Attachments
        component.set('v.attachmentIds', []);
        
        //Delivery Options
        component.set('v.deliveryOptionId', '');
        
        //Download Links
        component.set('v.downloadLinks', []);
        
        //Error Message
        component.set('v.errorMessage', '');
        
        //Display Document Section
        component.set('v.displayDocumentSection', false);
    },
    toggleAccordionsDisabled : function(component, disable) {
        var accordionSections = ['ddpAccordionSection', 'contactAccordionSection', 'documentAccordionSection', 'deliveryAccordionSection'];
        for (var i = 0; i < accordionSections.length; i++) {
            var sectionName = accordionSections[i];
            var accordionSection = component.find(sectionName);
            if (accordionSection) {
                accordionSection.toggleAccordionDisabled(disable);
            }
        }
    },
    toggleModifyButtons : function(component, disable) {
        component.find('startOverButton').getElement().disabled = disable;
        component.find('modifyButton').getElement().disabled = disable;
        component.find('rerunButton').getElement().disabled = disable;
    },
    storeAttachmentIds : function(component, selectedAttachments) {
        var attachmentIds = [];
        for (var i = 0; i < selectedAttachments.length; i++) {
            attachmentIds.push(selectedAttachments[i].Id);
        }
        component.set('v.attachmentIds', attachmentIds);
        var optionalDocumentSelection = component.find('documentSelect-component');
        
        if (attachmentIds.length > 0) {
            component.find('documentAccordionSection').setBadge('SELECTED');
            optionalDocumentSelection.documentNextButtonDisabled(false);
        } else {
            component.find('documentAccordionSection').setBadge('');
            if (component.get('v.attachmentRequired')) {
                optionalDocumentSelection.documentNextButtonDisabled(true);
            } else {
                optionalDocumentSelection.documentNextButtonDisabled(false);
            }
        }
        this.updateRunButtonStatus(component);
    },
    handleRunClick : function(component, isTest) {
        this.toggleSections(component, '');
        
        component.set("v.isTest", isTest);
        if (component.get("v.needsAuthentication") && component.get("v.oAuthUrl")) {
            this.authorizeLoopServices(component);
        } else {
            this.runDdp(component);
        }
    }
})