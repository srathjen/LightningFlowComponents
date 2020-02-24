/**
 * Created by gmayer on 7/26/2019.
 */

({
    doInit: function (component, event, helper) {
        // Make a copy of the initial value
        var wishOther = component.get("v.wishOther");
        component.set('v.wishOtherBackup', JSON.parse(JSON.stringify(wishOther)));
        if (wishOther.Wish_Affiliation_Type__c === "Wish Child") {
            component.set('v.isAffiliationTypeWishChild', true);
        }
        component.set('v.wishOtherBackup', JSON.parse(JSON.stringify(wishOther)));
        component.set('v.requiredParticipant', component.get('v.requiredParticipantPrevious'));
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
        var isValidFirstName = component.get('v.isValidFirstName');
        var isValidLastName = component.get('v.isValidLastName');
        var isValidCountry = component.get("v.isValidCountry");
        var isValidRelationshipType = component.get("v.isValidRelationshipType");
        var isValidResidingWithWishChild = component.get("v.isValidResidingWithWishChild");
        var isValidWishOtherListItemRelatedContactLookup = component.get('v.isValidWishOtherListItemRelatedContactLookup');
        var isWishAffiliationConvertingToMedicalProfessional = component.get('v.isWishAffiliationConvertingToMedicalProfessional');
        var isValidWishOtherListItemHealthTreatmentFacilityAccountLookup = component.get('v.isValidWishOtherListItemHealthTreatmentFacilityAccountLookup');
        var isValid = false;
        if (isWishAffiliationConvertingToMedicalProfessional) {
            isValid = isValidFirstName && isValidLastName && isValidCountry
                && isValidRelationshipType && isValidResidingWithWishChild
                && isValidWishOtherListItemRelatedContactLookup
                && isValidWishOtherListItemHealthTreatmentFacilityAccountLookup;
        } else {
            isValid = isValidFirstName && isValidLastName && isValidCountry
                && isValidRelationshipType && isValidResidingWithWishChild
                && isValidWishOtherListItemRelatedContactLookup;
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
        var isValidWishOtherListItemRelatedContactLookup = component.get('v.isValidWishOtherListItemRelatedContactLookup');
        var isWishAffiliationConvertingToMedicalProfessional = component.get('v.isWishAffiliationConvertingToMedicalProfessional');
        var isValidWishOtherListItemHealthTreatmentFacilityAccountLookup = component.get('v.isValidWishOtherListItemHealthTreatmentFacilityAccountLookup');
        var isValid = false;
        if (isWishAffiliationConvertingToMedicalProfessional) {
            isValid = isValidFirstName && isValidLastName && isValidCountry
                && isValidRelationshipType && isValidResidingWithWishChild
                && isValidWishOtherListItemRelatedContactLookup
                && isValidWishOtherListItemHealthTreatmentFacilityAccountLookup;
        } else {
            isValid = isValidFirstName && isValidLastName && isValidCountry
                && isValidRelationshipType && isValidResidingWithWishChild
                && isValidWishOtherListItemRelatedContactLookup;
        }
        if (isValid) {
            helper.save(component, event, helper);
        }
    },

    cancelAction: function (component, event, helper) {
        /*
         * Reset the values of the Wish Other  Mailing Country and Mailing State,
         * Mailing Country cannot be empty when Mailing State is selected
         */
        component.set('v.isValidFirstName', true);
        component.set('v.isValidLastName', true);
        component.set('v.isValidCountry', true);
        component.set('v.isValidRelationshipType', true);
        component.set('v.isValidResidingWithWishChild', true);
        component.get('v.isValidWishOtherListItemRelatedContactLookup', true);
        var wishOtherBackup = component.get("v.wishOtherBackup");
        component.set("v.wishOther", JSON.parse(JSON.stringify(wishOtherBackup)));
        component.set('v.editMode', false);
        component.set('v.requestParticipant', component.get('v.requestParticipantPrevious')); // Reset checkbox
    },

    onChangeValidate: function (component, event, helper) {
        /*
         * Validate Mailing Country and Mailing State,
         * Mailing Country cannot be empty when Mailing State is selected
         */
        var firstName = component.get("v.wishOther.Contact__r.FirstName");
        var lastName = component.get("v.wishOther.Contact__r.LastName");
        var mailingState = component.get("v.wishOther.Contact__r.MailingState");
        var mailingCountry = component.get("v.wishOther.Contact__r.MailingCountry");
        var relationshipType = component.find("relationshipType").get("v.value");
        var residingWithWishChild = component.find("residingWithWishChild").get("v.value");
        var wishOtherListItemRelatedContactLookup = component.get('v.wishOther.Relationship__r.npe4__Contact__c');
        var wishAffiliationType = component.get('v.wishOther.Wish_Affiliation_Type__c');
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
            if (wishOtherListItemRelatedContactLookup && relationshipType === "") {
                component.set('v.isValidRelationshipType', false);
            } else {
                component.set('v.isValidRelationshipType', true);
            }
            // Is Affiliation Type being changed to Medical Professional
            if (wishAffiliationType === "Medical Professional") {
                component.set('v.isWishAffiliationConvertingToMedicalProfessional', true);
                var healthTreatmentFacility = component.get('v.wishOther.Health_Treatment_Facility__c');
                if (!healthTreatmentFacility) {
                    component.set('v.isValidWishOtherListItemHealthTreatmentFacilityAccountLookup', false);
                } else {
                    component.set('v.isValidWishOtherListItemHealthTreatmentFacilityAccountLookup', true);
                }
            } else {
                component.set('v.isWishAffiliationConvertingToMedicalProfessional', false);
                component.set('v.isValidWishOtherListItemHealthTreatmentFacilityAccountLookup', true);
            }
            if (residingWithWishChild === "") {
                component.set('v.isValidResidingWithWishChild', false);
            } else {
                component.set('v.isValidResidingWithWishChild', true);
            }
            if (relationshipType !== "" && !wishOtherListItemRelatedContactLookup) {
                component.set('v.isValidWishOtherListItemRelatedContactLookup', false);
            } else {
                component.set('v.isValidWishOtherListItemRelatedContactLookup', true)
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
        var caseRecordId = component.get('v.wishOther.Wish__c');
        var wishAffiliationRecordId = component.get('v.wishOther.Id');
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
        if (lookupId === 'wishOtherListItemRelatedContactLookup') {
            component.set('v.wishOther.Relationship__r.npe4__Contact__c', recordId);
            var relationshipType = component.find("relationshipType").get("v.value");
            var wishOtherListItemRelatedContactLookup = component.get("v.wishOther.Relationship__r.npe4__Contact__c");
            if (wishOtherListItemRelatedContactLookup && relationshipType === "") {
                component.set('v.isValidRelationshipType', false);
            } else {
                component.set('v.isValidRelationshipType', true);
            }
            if (relationshipType !== "" && !wishOtherListItemRelatedContactLookup) {
                component.set('v.isValidWishOtherListItemRelatedContactLookup', false);
            } else {
                component.set('v.isValidWishOtherListItemRelatedContactLookup', true);
            }
        }
        if (lookupId === 'wishOtherListItemHealthTreatmentFacilityAccountLookup') {
            component.set('v.wishOther.Health_Treatment_Facility__c', recordId);
            component.set('v.isValidWishOtherListItemHealthTreatmentFacilityAccountLookup', true);
        }
    },

    handleLookupClearedEvent: function (component, event, helper) {
        var lookupId = event.getParam("lookupId");
        if (lookupId === 'wishOtherListItemRelatedContactLookup') {
            component.set('v.wishOther.Relationship__r.npe4__Contact__c', '');
            var relationshipType = component.find("relationshipType").get("v.value");
            var wishOtherListItemRelatedContactLookup = component.get("v.wishOther.Relationship__r.npe4__Contact__c");
            if (wishOtherListItemRelatedContactLookup && relationshipType === "") {
                component.set('v.isValidRelationshipType', false);
            } else {
                component.set('v.isValidRelationshipType', true);
            }
            if (relationshipType !== "" && !wishOtherListItemRelatedContactLookup) {
                component.set('v.isValidWishOtherListItemRelatedContactLookup', false);
            } else {
                component.set('v.isValidWishOtherListItemRelatedContactLookup', true);
            }
        }
        if (lookupId === 'wishOtherListItemHealthTreatmentFacilityAccountLookup') {
            component.set('v.isValidWishOtherListItemHealthTreatmentFacilityAccountLookup', false);
            component.set('v.wishOther.Health_Treatment_Facility__c', '');
        }
    },

    handleCustomToastCloseEvent: function (component, event, helper) {
        component.set('v.showToast', false);
    }
});