/**
 * Created by gmayer on 6/28/2019.
 */
({
    doInit: function (component) {
        // Make a copy of the initial value
        var wishParticipant = component.get("v.wishParticipant");
        component.set('v.wishParticipantBackup', JSON.parse(JSON.stringify(wishParticipant)));
        if (wishParticipant.Wish_Affiliation_Type__c === "Wish Child") {
            component.set('v.isAffiliationTypeWishChild', true);
        }
        component.set('v.wishParticipantBackup', JSON.parse(JSON.stringify(wishParticipant)));
    },

    showItemDetails: function (component, event) {
        var collapsed = component.get("v.collapsed");
        if (collapsed) {
            component.set('v.collapsed', false);
        } else {
            component.set('v.collapsed', true);
            component.cancelAction();
        }
        event.preventDefault()
    },

    onClickEdit: function (component) {
        var editMode = component.get("v.editMode");
        if (editMode) {
            component.set('v.editMode', false);
        } else {
            component.set('v.editMode', true);
        }
    },

    saveAction: function (component, event, helper) {
        component.onChangeValidate(component, event, helper);
        var isValidFirstName = component.get('v.isValidFirstName');
        var isValidLastName = component.get('v.isValidLastName');
        var isValidCountry = component.get("v.isValidCountry");
        var isValidRelationshipType = component.get("v.isValidRelationshipType");
        var isValidResidingWithWishChild = component.get("v.isValidResidingWithWishChild");
        var isValidWishParticipantListItemRelatedContactLookup = component.get('v.isValidWishParticipantListItemRelatedContactLookup');
        var isWishAffiliationConvertingToMedicalProfessional = component.get('v.isWishAffiliationConvertingToMedicalProfessional');
        var isValidWishParticipantListItemHealthTreatmentFacilityAccountLookup = component.get('v.isValidWishParticipantListItemHealthTreatmentFacilityAccountLookup');
        var isValid = false;
        if (isWishAffiliationConvertingToMedicalProfessional) {
            isValid = isValidFirstName && isValidLastName && isValidCountry
                && isValidRelationshipType && isValidResidingWithWishChild
                && isValidWishParticipantListItemRelatedContactLookup
                && isValidWishParticipantListItemHealthTreatmentFacilityAccountLookup;
        } else {
            isValid = isValidFirstName && isValidLastName && isValidCountry
                && isValidRelationshipType && isValidResidingWithWishChild
                && isValidWishParticipantListItemRelatedContactLookup;
        }
        if (isValid) {
            helper.save(component, event, helper);
        }
    },

    requestChangeAction: function (component, event, helper) {
        var isValidFirstName = component.get("v.isValidFirstName");
        var isValidLastName = component.get("v.isValidLastName");
        var isValidCountry = component.get("v.isValidCountry");
        var isValidRelationshipType = component.get("v.isValidRelationshipType");
        var isValidResidingWithWishChild = component.get("v.isValidResidingWithWishChild");
        var isValidWishParticipantListItemRelatedContactLookup = component.get('v.isValidWishParticipantListItemRelatedContactLookup');
        var isWishAffiliationConvertingToMedicalProfessional = component.get('v.isWishAffiliationConvertingToMedicalProfessional');
        var isValidWishParticipantListItemHealthTreatmentFacilityAccountLookup = component.get('v.isValidWishParticipantListItemHealthTreatmentFacilityAccountLookup');
        var isValid = false;
        if (isWishAffiliationConvertingToMedicalProfessional) {
            isValid = isValidFirstName && isValidLastName && isValidCountry
                && isValidRelationshipType && isValidResidingWithWishChild
                && isValidWishParticipantListItemRelatedContactLookup
                && isValidWishParticipantListItemHealthTreatmentFacilityAccountLookup;
        } else {
            isValid = isValidFirstName && isValidLastName && isValidCountry
                && isValidRelationshipType && isValidResidingWithWishChild
                && isValidWishParticipantListItemRelatedContactLookup;
        }
        if (isValid) {
            helper.save(component, event, helper);
        }
    },

    cancelAction: function (component, event, helper) {
        /*
         * Reset the values of the Wish Participant  Mailing Country and Mailing State,
         * Mailing Country cannot be empty when Mailing State is selected
         */
        component.set('v.isValidFirstName', true);
        component.set('v.isValidLastName', true);
        component.set('v.isValidCountry', true);
        component.set('v.isValidRelationshipType', true);
        component.set('v.isValidResidingWithWishChild', true);
        component.get('v.isValidWishParticipantListItemRelatedContactLookup', true);
        var wishParticipantBackup = component.get("v.wishParticipantBackup");
        component.set("v.wishParticipant", JSON.parse(JSON.stringify(wishParticipantBackup)));
        component.set('v.editMode', false);
        component.set('v.requestParticipant', component.get('v.requestParticipantPrevious')); // Reset checkbox
    },

    onChangeValidate: function (component, event, helper) {
        /*
         * Validate Mailing Country and Mailing State,
         * Mailing Country cannot be empty when Mailing State is selected
         */
        var firstName = component.get("v.wishParticipant.Contact__r.FirstName");
        var lastName = component.get("v.wishParticipant.Contact__r.LastName");
        var mailingState = component.get("v.wishParticipant.Contact__r.MailingState");
        var mailingCountry = component.get("v.wishParticipant.Contact__r.MailingCountry");
        var relationshipType = component.find("relationshipType").get("v.value");
        var residingWithWishChild = component.find("residingWithWishChild").get("v.value");
        var wishParticipantListItemRelatedContactLookup = component.get('v.wishParticipant.Relationship__r.npe4__Contact__c');
        var wishAffiliationType = component.get('v.wishParticipant.Wish_Affiliation_Type__c');
        if (firstName === "") {
            component.set('v.isValidFirstName', false);
        } else {
            component.set('v.isValidFirstName', true);
        }
        if (lastName === "") {
            component.set('v.isValidLastName', false);
        } else {
            component.set('v.isValidLastName', true);
        }
        if ((mailingState === undefined || mailingState !== "") && mailingCountry === "") {
            component.set('v.isValidCountry', false);
        } else {
            component.set('v.isValidCountry', true);
        }
        if (wishAffiliationType !== "Wish Child") {
            if (relationshipType === "") {
                component.set('v.isValidRelationshipType', false);
            } else {
                component.set('v.isValidRelationshipType', true);
            }
            // Is Affiliation Type being changed to Medical Professional
            if (wishAffiliationType === "Medical Professional") {
                component.set('v.isWishAffiliationConvertingToMedicalProfessional', true);
                var healthTreatmentFacility = component.get('v.wishParticipant.Health_Treatment_Facility__c');
                if (!healthTreatmentFacility) {
                    component.set('v.isValidWishParticipantListItemHealthTreatmentFacilityAccountLookup', false);
                } else {
                    component.set('v.isValidWishParticipantListItemHealthTreatmentFacilityAccountLookup', true);
                }
            } else {
                component.set('v.isWishAffiliationConvertingToMedicalProfessional', false);
                component.set('v.isValidWishParticipantListItemHealthTreatmentFacilityAccountLookup', true);
            }
            if (residingWithWishChild === "") {
                component.set('v.isValidResidingWithWishChild', false);
            } else {
                component.set('v.isValidResidingWithWishChild', true);
            }
            if (!wishParticipantListItemRelatedContactLookup) {
                component.set('v.isValidWishParticipantListItemRelatedContactLookup', false);
            } else {
                component.set('v.isValidWishParticipantListItemRelatedContactLookup', true)
            }
        }
    },

    handleClick: function (component, event, helper) {
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
            "recordId": component.get("v.recordId")
        });
        navEvt.fire();
    },

    openWishAffiliationTab: function (component, event, helper) {
        var workspaceAPI = component.find("workspace");
        var caseRecordId = component.get('v.wishParticipant.Wish__c');
        var wishAffiliationRecordId = component.get('v.wishParticipant.Id');
        var urlCase = '/lightning/r/Case/' + caseRecordId + '/view';
        var urlWishAffiliation = '/lightning/r/Wish_Affiliation__c/' + wishAffiliationRecordId + '/view';
        workspaceAPI.openTab({
            url: urlCase,
            focus: true
        }).then(function (response) {
            workspaceAPI.openSubtab({
                parentTabId: response,
                url: urlWishAffiliation,
                focus: true
            });
        }).catch(function (error) {
            console.log(error);
        });
    },

    handleLookupSelectedEvent: function (component, event, helper) {
        var lookupId = event.getParam("lookupId");
        var recordId = event.getParam("recordId");
        if (lookupId === 'wishParticipantListItemRelatedContactLookup') {
            component.set('v.wishParticipant.Relationship__r.npe4__Contact__c', recordId);
            component.set('v.isValidWishParticipantListItemRelatedContactLookup', true);
        }
        if (lookupId === 'wishParticipantListItemHealthTreatmentFacilityAccountLookup') {
            component.set('v.wishParticipant.Health_Treatment_Facility__c', recordId);
            component.set('v.isValidWishParticipantListItemHealthTreatmentFacilityAccountLookup', true);
        }
    },

    handleLookupClearedEvent: function (component, event, helper) {
        var lookupId = event.getParam("lookupId");
        if (lookupId === 'wishParticipantListItemRelatedContactLookup') {
            component.set('v.isValidWishParticipantListItemRelatedContactLookup', false);
            component.set('v.wishParticipant.Relationship__r.npe4__Contact__c', '');
        }
        if (lookupId === 'wishParticipantListItemHealthTreatmentFacilityAccountLookup') {
            component.set('v.isValidWishParticipantListItemHealthTreatmentFacilityAccountLookup', false);
            component.set('v.wishParticipant.Health_Treatment_Facility__c', '');
        }
    },

    handleCustomToastCloseEvent: function (component, event, helper) {
        component.set('v.showToast', false);
    }
});