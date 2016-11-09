({
    init : function(component, event, helper) {
        if (!helper.isLockerServiceActive()) {
            component.set('v.lockerServiceActive', false);
            
            //expandDdps
            if (component.get("v.startExpanded")) {
                helper.expandAndLoadDdps(component);
            }
            //Set ContactId if running from Contact
            if (component.get('v.recordId').substring(0, 3) === '003') {
                component.set('v.contactId', component.get('v.recordId'));
            }
            //Exposing run test for use
            var action = component.get('c.initalLoadData');
            action.setParams({
                recordId : component.get('v.recordId')
            });
            action.setCallback(this, function(response) {
                if (response.getState() === "SUCCESS") {
                    var parsedResponse = JSON.parse(response.getReturnValue());
                    component.set("v.runTestAvailable", parsedResponse.testAvailable);
                    component.set("v.objectName", parsedResponse.objectName);
                } else {
                    $A.util.addClass(component.find("runDdpContainer"), "hidden");
                    component.set("v.errorMessage", "An unexpected error has occurred. Please contact Drawloop Support if this issue persists.");
                    $A.util.removeClass(component.find("errorContainer"), "hidden");
                }
            });
            $A.enqueueAction(action);
        }
    },
    handleClickSelectDdp : function(component, event, helper) {
        helper.expandAndLoadDdps(component);
    },
    handleDdpSelected : function(component, event, helper) {
        var id = event.getParam("id");
        if (!component.get("v.ddpId") || component.get("v.ddpId") !== id) {
            // Reset accordions so Document Selection accordion is only displayed (conditionally) after it has been (re)evaluated.
            var secondaryAccordionSectionsLoadingRow = component.find('secondaryAccordionSectionsLoadingRow');
            if (secondaryAccordionSectionsLoadingRow) {
                secondaryAccordionSectionsLoadingRow.getElement().hidden = false;
            }
            var secondaryAccordionSections = component.find('secondaryAccordionSections');
            if (secondaryAccordionSections) {
                secondaryAccordionSections.getElement().hidden = true;
            }
            
            // Disable DDP accordion
            helper.toggleAccordionsDisabled(component, true);
            
            //reset previous selection data
            helper.resetSelections(component);
            
            var name = event.getParam("name");
            var contactRequired = event.getParam("contactRequired");
            var attachmentAllowed = event.getParam("attachmentAllowed");
            var attachmentRequired = event.getParam("attachmentRequired");
            var hasOptionalDocuments = event.getParam("hasOptionalDocuments");
            
            component.set('v.ddpId', id);
            component.set('v.contactRequired', contactRequired);
            component.set('v.attachmentAllowed', attachmentAllowed);
            component.set('v.attachmentRequired', attachmentRequired);
            component.set('v.documentNextButtonDisabled', attachmentRequired);
            component.set('v.displayDocumentSection', hasOptionalDocuments || attachmentRequired || attachmentAllowed);
            
            component.find("documentSelect-component").load(id, component.get("v.recordId"), attachmentAllowed, attachmentRequired);
            component.find("deliverySelect-component").load(id, component.get("v.recordId"), component.get('v.contactId'));
            
            component.find('ddpAccordionSection').setBadge(name);
            component.find('documentAccordionSection').setBadge('');
            component.find('deliveryAccordionSection').setBadge('');
            
            //If there isn't a contact selected (which happens on initial load), it will toggle to the contact accordion, and load fresh data.
            component.find("contactSelect-component").load(component.get("v.recordId"), contactRequired);
            if (!component.get('v.contactId')) {
                component.find('contactAccordionSection').setBadge('');
            }
    
            helper.updateRunButtonStatus(component);
            helper.fetchPreOAuthData(component);
        }
            
        helper.toggleNextSection(component)
    },
    revealSecondaryAccordionSections : function(component, event, helper) {
        var documentAccordionSection = component.find('documentAccordionSection');
        
        documentAccordionSection.getElement().hidden = !component.get('v.displayDocumentSection');
        
        var displayContactSection = component.get('v.recordId').substring(0, 3) !== '003';
        var contactAccordionSection = component.find('contactAccordionSection');
        contactAccordionSection.getElement().hidden = !displayContactSection;
        
        var secondaryAccordionSectionsLoadingRow = component.find('secondaryAccordionSectionsLoadingRow');
        secondaryAccordionSectionsLoadingRow.getElement().hidden = true;
        var secondaryAccordionSections = component.find('secondaryAccordionSections');
        secondaryAccordionSections.getElement().hidden = false;
        
        // Enable DDP accordion
        helper.toggleAccordionsDisabled(component, false);
    },
    handleContactSelected : function(component, event, helper) {
        var id = event.getParam("id");
        var name = event.getParam("name");
        if (id) {
            component.find('contactAccordionSection').setBadge(name);
            component.set('v.contactId', id);
        } else {
            component.find('contactAccordionSection').setBadge('None');
            component.set('v.contactId', '');
        }
        
        var nextSection = component.get('v.displayDocumentSection') ? 'documentAccordionSection' : 'deliveryAccordionSection';
        helper.toggleSections(component, nextSection);
        component.find('deliverySelect-component').load(component.get('v.ddpId'), component.get('v.recordId'), component.get('v.contactId'));
        component.set('v.deliveryOptionId', '');
        helper.updateRunButtonStatus(component);
    },
    handleDocumentSelected : function(component, event, helper) {
        var ids = event.getParam("ids");
        component.set('v.documentIds', ids);
        if (component.get('v.attachmentRequired')) {
            if (component.get("v.attachmentIds").length > 0) {
                component.find('documentAccordionSection').setBadge('SELECTED');
            } else {
                component.find('documentAccordionSection').setBadge('');
            }
        } else {
            if (ids.length > 0) {
                component.find('documentAccordionSection').setBadge('SELECTED');      
            } else {
                component.find('documentAccordionSection').setBadge('');
            }
        }
    },
    exposeAndLoadAttachments : function(component, event, helper) {
        var attachments = event.getParam('attachments');
        var globalIdTag = event.getParam('globalIdTag');
        
        // Disable run buttons and accordions
        helper.toggleAccordionsDisabled(component, true);
        component.set("v.runDisabled", true);
        
        component.find('selectAttachmentTiles').load(globalIdTag, attachments);
        component.find('optionalDocumentSlider').slide();
    },
    slideOut : function(component, event, helper) {
        // Enable run buttons and accordions
        helper.toggleAccordionsDisabled(component, false);
        helper.updateRunButtonStatus(component);
        
        component.find('optionalDocumentSlider').slideBack();
    },
    saveAttachments : function(component, event, helper) {
        var selectedAttachments = event.getParam('selectedAttachments');
        component.find('documentSelect-component').storeAttachments(selectedAttachments);
        helper.storeAttachmentIds(component, selectedAttachments);
    },
    updateRemoveAttachment : function(component, event, helper) {
        var removeAttachmentId = event.getParam('removeAttachmentId');
        var remainingAttachments = event.getParam('remainingAttachments');
        
        component.find('selectAttachmentTiles').updateDeselectedAttachments(removeAttachmentId, remainingAttachments);
        helper.storeAttachmentIds(component, remainingAttachments);
    },
    completedOptionalDocumentSelection : function(component, event, helper) {
        helper.toggleSections(component, 'deliveryAccordionSection');
    },
    handleDeliveryOptionSelected : function(component, event, helper) {
        var id = event.getParam("id");
        var name = event.getParam("name");
        var deliveryType = event.getParam("deliveryType");
        var attachToRecord = event.getParam("attachToRecord");
        var selectedContentLibrary = event.getParam("selectedContentLibrary");
        var emailSubject = event.getParam("emailSubject");
        var emailText = event.getParam("emailBody");
        var reminderDelay = event.getParam("reminderDelay");
        var reminderFrequency = event.getParam("reminderFrequency");
        var expireAfter = event.getParam("expireAfter");
        var expireWarn = event.getParam("expireWarn");
        
        component.set('v.deliveryOptionId', id);
        component.set('v.deliveryOptionType', deliveryType);
        component.set('v.attachToRecord', attachToRecord);
        component.set('v.selectedContentLibrary', selectedContentLibrary);
        
        //email data
        component.set('v.emailSubject', emailSubject);
        component.set('v.emailText', emailText);
        //DocuSign reminder data
        component.set('v.reminderDelay', reminderDelay);
        component.set('v.reminderFrequency', reminderFrequency);
        component.set('v.expireAfter', expireAfter);
        component.set('v.expireWarn', expireWarn);
        
        if (id) {
            component.find('deliveryAccordionSection').setBadge(name);
        } else {
            component.find('deliveryAccordionSection').setBadge('');
        }
        helper.updateRunButtonStatus(component);
    },
    handleUpdateESignRecipientsList : function(component, event, helper) {
        component.set("v.currentESignRecipients", event.getParams().updatedRecipientsList);
        helper.updateRunButtonStatus(component);
    },
    collapseOtherAccordionSections : function(component, event, helper) {
        var selectedAccordionSection = event.getParams().selectedAccordionSection;
        var accordionSections = ['ddpAccordionSection', 'contactAccordionSection', 'documentAccordionSection', 'deliveryAccordionSection'];
        for (var i = 0; i < accordionSections.length; i++) {
            var sectionName = accordionSections[i];
            var accordionSection = component.find(sectionName);
            if (accordionSection) {
                if (sectionName !== selectedAccordionSection) {
                    accordionSection.collapse();
                }
            }
        }
        
        if (component.get('v.displayDocumentSection') && selectedAccordionSection === 'documentAccordionSection' && $A.util.hasClass(component.find('documentNextButton'), 'hidden')) {
            $A.util.removeClass(component.find('documentNextButton'), 'hidden');
        } else {
            $A.util.addClass(component.find('documentNextButton'), 'hidden');
        }
    },
    handleRunDdpClick : function(component, event, helper) {
        helper.handleRunClick(component, false);
    },
    handleRunTestClick : function(component, event, helper) {
        helper.handleRunClick(component, true);
    },
    handleOAuthSuccessful : function(component, event, helper) {
        if (event.getParam("authorizingUser")) {
            component.set("v.needsAuthentication", false);
            helper.runDdp(component);
        }
    },
    processDdpFinished : function(component, event, helper) {
        setTimeout($A.getCallback(function() {
            $A.util.removeClass(component.find("documents"), "hidden");
            $A.util.removeClass(component.find("reRunButtons"), "hidden");
            
            $A.util.addClass(component.find("runDdpContainer"), "hidden");
            $A.util.addClass(component.find("processDdpContainer"), "hidden");
            $A.util.addClass(component.find("runDdpButton"), "hidden");
        }), 1500);
        component.find('previewFiles').startTimeout();
    },
    ddpSuccessful : function(component, event, helper) {
        var message = event.getParam("arguments").message;
        
        var attach = component.get('v.deliveryOptionType') === 'Attach';
        var download = component.get('v.deliveryOptionType') === 'Download';
        var nonAutoEmail = component.get('v.deliveryOptionType') === 'Email' && component.get('v.returnUri');
        if ((!download && !nonAutoEmail) || attach) {
        	component.find("previewFiles").showSuccess(message);
        }
    },
    startOver : function(component, event, helper) {
        helper.resetDdpData(component);
        
        component.find('fileEmailSlider').slideBack();
        component.find('emailComposer').reset();
        
        // Update Run DDP button
        helper.updateRunButtonStatus(component);
        // Enable all accordion sections
        helper.toggleAccordionsDisabled(component, false);
        // Reload DDPs
        component.find("ddpSelect-component").load(component.get("v.recordId"), "", "", "", component.get("v.ddpLabel"));
        // Reset Success Message
        component.find('previewFiles').showSuccess('');
        component.find('previewFiles').set('v.isSuccess', false);
        
        $A.util.removeClass(component.find("runDdpButton"), "hidden");
        $A.util.removeClass(component.find("runDdpContainer"), "hidden");
        
        $A.util.addClass(component.find("documents"), "hidden");
        $A.util.addClass(component.find("reRunButtons"), "hidden");
        $A.util.addClass(component.find("processDdpContainer"), "hidden");
        $A.util.addClass(component.find("errorContainer"), "hidden");
    },
    rerunDdp : function(component, event, helper) {
        $A.util.removeClass(component.find("runDdpContainer"), "hidden");
		
        component.find('fileEmailSlider').slideBack();
        component.find('emailComposer').reset();
        // Reset Success Message
        component.find('previewFiles').showSuccess('');
        component.find('previewFiles').set('v.isSuccess', false);
        
        helper.runDdp(component);
        
        $A.util.addClass(component.find("documents"), "hidden");
        $A.util.addClass(component.find("errorContainer"), "hidden");
        $A.util.addClass(component.find("reRunButtons"), "hidden");
    },
    modifyDdp : function(component, event, helper) {
        $A.util.removeClass(component.find("runDdpButton"), "hidden");
        $A.util.removeClass(component.find("runDdpContainer"), "hidden");
        
        component.find('fileEmailSlider').slideBack();
        component.find('emailComposer').reset();
        
        // Enable Run DDP button
        helper.updateRunButtonStatus(component);
        // Enable all accordion sections
        helper.toggleAccordionsDisabled(component, false);
        // Expand the second section (whatever comes after DDP)
        helper.toggleNextSection(component);
        // Reset Success Message
        component.find('previewFiles').showSuccess('');
        component.find('previewFiles').set('v.isSuccess', false);
        
        $A.util.addClass(component.find("documents"), "hidden");
        $A.util.addClass(component.find("reRunButtons"), "hidden");
        $A.util.addClass(component.find("processDdpContainer"), "hidden");
        $A.util.addClass(component.find("errorContainer"), "hidden");
    },
    cancelEmail : function(component, event, helper) {
        var fileEmailSlider = component.find('fileEmailSlider');
        fileEmailSlider.slideBack();
        helper.toggleModifyButtons(component, false);
    },
    composeEmail : function(component, event, helper) {
        var emailUrl = component.get('v.returnUri');

        component.find('emailComposer').load(emailUrl);

        var fileEmailSlider = component.find('fileEmailSlider');
        fileEmailSlider.slide();
        helper.toggleModifyButtons(component, true);
    },
    enableModifyButtons : function(component, event, helper) {
        helper.toggleModifyButtons(component, false);
    },
    showError : function(component, event, helper) {
        var errorPrompt = component.find('errorPrompt');
        var title = event.getParam('title');
        var message = event.getParam('message');
        errorPrompt.showError(title, message);
    },
    toggleAccordions : function(component, event, helper) {
        helper.toggleAccordionsDisabled(component, event.getParam('disable'));
    },
    toggleRunDdpButtons : function(component, event, helper) {
        if (event.getParam('disable')) {
            component.set("v.runDisabled", true);
        } else {
            helper.updateRunButtonStatus(component);
        }
    },
    updateSlideEmail : function(component, event, helper) {
        component.set("v.emailSubject", event.getParam("emailSubject"));
        component.set("v.emailText", event.getParam("emailBody"));
    },
    updateSlideDocuSignReminders : function(component, event, helper) {
        component.set("v.reminderDelay", event.getParam("reminderDelay"));
        component.set("v.expireAfter", event.getParam("daysTillSigningExpires"));
        component.set("v.reminderFrequency", event.getParam("reminderFrequency"));
        component.set("v.expireWarn", event.getParam("warnOfExpiration"));
    },
    continueDelivery : function(component, event, helper) {
        helper.toggleModifyButtons(component, event.getParam("disableModify"));
    }
})