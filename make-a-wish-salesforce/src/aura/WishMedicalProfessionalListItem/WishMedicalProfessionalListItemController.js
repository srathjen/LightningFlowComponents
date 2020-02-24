/**
 * Created by gmayer on 7/26/2019.
 */

({
    doInit: function (component, event, helper) {
        // Make a copy of the initial value
        var wishMedicalProfessional = component.get("v.wishMedicalProfessional");
        component.set('v.wishMedicalProfessionalBackup', JSON.parse(JSON.stringify(wishMedicalProfessional)));
        if (wishMedicalProfessional.Wish_Affiliation_Type__c === "Wish Child") {
            component.set('v.isAffiliationTypeWishChild', true);
        }
        component.set('v.wishMedicalProfessionalBackup', JSON.parse(JSON.stringify(wishMedicalProfessional)));
    },

    showItemDetails: function (component, event, helper) {
        var collapsed = component.get("v.collapsed");
        if (collapsed) {
            component.set('v.collapsed', false);
        } else {
            component.set('v.collapsed', true);
            component.cancelAction();
        }
        event.preventDefault()
    },

    onClickEdit: function (component, event, helper) {
        var editMode = component.get("v.editMode");
        if (editMode) {
            component.set('v.editMode', false);
        } else {
            component.set('v.editMode', true);
        }
    },

    saveAction: function (component, event, helper) {
        component.onChangeValidate(component, event, helper);
        var isFirstNameValid = component.get('v.isValidFirstName');
        var isLastNameValid = component.get('v.isValidLastName');
        var isValidCountry = component.get("v.isValidCountry");
        var isValidRelationshipType = component.get("v.isValidRelationshipType");
        var isValidWishMedicalProfessionalListItemRelatedContactLookup = component.get('v.isValidWishMedicalProfessionalListItemRelatedContactLookup');
        if (isFirstNameValid && isLastNameValid && isValidCountry
            && isValidRelationshipType && isValidWishMedicalProfessionalListItemRelatedContactLookup) {
            helper.save(component, event, helper);
        }
    },

    requestChangeAction: function (component, event, helper) {
        var isValidFirstName = component.get("v.isValidFirstName");
        var isValidLastName = component.get("v.isValidLastName");
        var isValidCountry = component.get("v.isValidCountry");
        var isValidRelationshipType = component.get("v.isValidRelationshipType");
        var isValidWishMedicalProfessionalListItemRelatedContactLookup = component.get('v.isValidWishMedicalProfessionalListItemRelatedContactLookup');
        if (isValidFirstName && isValidLastName && isValidCountry && isValidRelationshipType
            && isValidWishMedicalProfessionalListItemRelatedContactLookup) {
            helper.save(component, event, helper);
        }
    },

    cancelAction: function (component, event, helper) {
        /*
         * Reset the values of the Wish MedicalProfessional  Mailing Country and Mailing State,
         * Mailing Country cannot be empty when Mailing State is selected
         */
        component.set('v.isValidFirstName', true);
        component.set('v.isValidLastName', true);
        component.set('v.isValidCountry', true);
        component.set('v.isValidRelationshipType', true);
        component.get('v.isValidWishMedicalProfessionalListItemRelatedContactLookup', true);
        var wishMedicalProfessionalBackup = component.get("v.wishMedicalProfessionalBackup");
        component.set("v.wishMedicalProfessional", JSON.parse(JSON.stringify(wishMedicalProfessionalBackup)));
        component.set('v.editMode', false);
    },

    onChangeValidate: function (component, event, helper) {
        /*
         * Validate Mailing Country and Mailing State,
         * Mailing Country cannot be empty when Mailing State is selected
         */
        var firstName = component.get("v.wishMedicalProfessional.Contact__r.FirstName");
        var lastName = component.get("v.wishMedicalProfessional.Contact__r.LastName");
        var mailingState = component.get("v.wishMedicalProfessional.Contact__r.MailingState");
        var mailingCountry = component.get("v.wishMedicalProfessional.Contact__r.MailingCountry");
        var relationshipType = component.find("relationshipType").get("v.value");
        var wishMedicalProfessionalListItemRelatedContactLookup = component.get('v.wishMedicalProfessional.Relationship__r.npe4__Contact__c');
        var wishAffiliationType = component.get('v.wishMedicalProfessional.Wish_Affiliation_Type__c');
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
            if (!wishMedicalProfessionalListItemRelatedContactLookup) {
                component.set('v.isValidWishMedicalProfessionalListItemRelatedContactLookup', false);
            } else {
                component.set('v.isValidWishMedicalProfessionalListItemRelatedContactLookup', true)
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
        var caseRecordId = component.get('v.wishMedicalProfessional.Wish__c');
        var wishAffiliationRecordId = component.get('v.wishMedicalProfessional.Id');
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
        if (lookupId === 'wishMedicalProfessionalListItemRelatedContactLookup') {
            component.set('v.wishMedicalProfessional.Relationship__r.npe4__Contact__c', recordId);
            component.set('v.isValidWishMedicalProfessionalListItemRelatedContactLookup', true);
        } else if(lookupId === 'wishMedicalProfessionalListItemHealthTreatmentFacilityAccountLookup'){
            component.set('v.wishMedicalProfessional.Health_Treatment_Facility__c', recordId);
        }
    },

    handleLookupClearedEvent: function (component, event, helper) {
        var lookupId = event.getParam("lookupId");
        if (lookupId === 'wishMedicalProfessionalListItemRelatedContactLookup') {
            component.set('v.isValidWishMedicalProfessionalListItemRelatedContactLookup', false);
            component.set('v.wishMedicalProfessional.Relationship__r.npe4__Contact__c', '');
        } else if (lookupId === 'wishMedicalProfessionalListItemHealthTreatmentFacilityAccountLookup') {
            component.set('v.wishMedicalProfessional.Health_Treatment_Facility__c', '');
        }
    },

    handleCustomToastCloseEvent: function (component, event, helper) {
        component.set('v.showToast', false);
    }
});