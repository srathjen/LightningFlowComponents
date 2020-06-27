/**
 * Created by gmayer on 7/26/2019.
 */
({
    initialize: function (component, event, helper) {
        var action = component.get("c.findWishAffiliations");
        var wishCaseRecordId = component.get("v.recordId");
        var wishAffiliationCategory = "Other";
        var flowWishCaseRecordId = component.get("v.wishCaseRecordId");
        if (flowWishCaseRecordId) {
            wishCaseRecordId = flowWishCaseRecordId;
            component.set("v.recordId", wishCaseRecordId);
        }
        action.setParams({
            wishCaseRecordId: wishCaseRecordId,
            wishAffiliationCategory: wishAffiliationCategory
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            var dataMap = response.getReturnValue();
            if (state === 'SUCCESS') {
                component.set("v.wishOthers", dataMap['wishAffiliations']);
                component.set("v.states", dataMap['states']);
                component.set("v.countries", dataMap['countries']);
                component.set("v.preferredPhoneOptions", dataMap['preferredPhoneOptions']);
                component.set("v.salutationOptions", dataMap['salutationOptions']);
                component.set("v.residingWithChildOptions", dataMap['residingWithChildOptions']);
                component.set("v.relationshipTypes", dataMap['relationshipTypes']);
                component.set("v.isUserProfileAllowedToUpdateWishAffiliation", dataMap['isUserProfileAllowedToUpdateWishAffiliation']);
                component.set("v.wishAffiliationTypes", dataMap['wishAffiliationTypes']);
                component.set("v.wishAffiliationTypesOfCategory", dataMap['wishAffiliationTypesOfCategory']);
                component.set("v.wishAffiliationTypesOfCategoryDefault", dataMap['wishAffiliationTypesOfCategoryDefault']);
                component.set("v.wishChildContactId", dataMap['wishChildContactId']);
                component.set("v.wishChildName", dataMap['wishChildName']);
                component.set("v.wishAffiliationLabels", dataMap['wishAffiliationLabels']);
                component.set("v.contactLabels", dataMap['contactLabels']);
                component.set("v.relationshipLabels", dataMap['relationshipLabels']);
                component.set("v.wishAffiliationTypes", dataMap['wishAffiliationTypes']);
                var newWishOther = component.initializeNewWishAffiliation(component);
                component.set("v.newWishOther", newWishOther);
            } else if (state === "ERROR") {
                component.set("v.error", dataMap['error']);
            }
            component.set("v.showSpinner", false);
        });
        $A.enqueueAction(action);
    },

    createWishAffiliation: function (component, event, helper) {
        var newWishAffiliation = JSON.stringify(component.get("v.newWishOther"));
        var modalContactLookupRecordId = component.get("v.modalContactLookupRecordId");
        var contactResidesWithRelationshipContact = component.get("v.contactResidesWithRelationshipContact");
        var wishChildContactId = component.get("v.wishChildContactId");
        var relationshipContactHouseholdAddressPayload = JSON.stringify(component.get("v.relationshipContactHouseholdAddress"));
        var createWishAffiliation = component.get("c.createWishAffiliation");
        createWishAffiliation.setParams({
            "payload": newWishAffiliation,
            "existingContactId": modalContactLookupRecordId,
            "contactResidesWithRelationshipContact": contactResidesWithRelationshipContact,
            "wishChildContactId": wishChildContactId,
            "relationshipContactHouseholdAddressPayload": relationshipContactHouseholdAddressPayload
        });
        createWishAffiliation.setCallback(this, function (response) {
            var state = response.getState();
            var dataMap = response.getReturnValue();
            var validationErrors = dataMap['validationErrors'];
            var userMessage = '';
            if (state === 'SUCCESS' && !Array.isArray(validationErrors) || !validationErrors.length) {
                component.set('v.showModal', false);
                component.set('v.isValidCountry', true);
                component.set('v.isValidRelationshipType', true);
                component.set('v.isValidResidingWithWishChild', true);
                component.set('v.isValidWishAffiliationType', true);
                component.set('v.isValidContactLookup', true);
                component.set('v.modalContactLookupRecordId', '');
                component.set("v.newWishOther", component.initializeNewWishAffiliation(component));
                component.reInit(component, event, helper);
                component.set('v.showCreateContact', false);
                component.set('v.showToast', false);
            } else if (Array.isArray(validationErrors) || validationErrors.length) {
                validationErrors.forEach(function (validationError) {
                    userMessage += validationError;
                });
                component.set('v.toastMessage', userMessage);
                component.set('v.toastMessageType', 'error');
                component.set('v.showToast', true);
            } else {
                component.set('v.toastMessage', 'There was an error, please contact your administrator');
                component.set('v.toastMessageType', 'error');
                component.set('v.showToast', true);
            }
            component.set('v.isHide', false);
        });
        $A.enqueueAction(createWishAffiliation);
    },

    getHouseholdAddressByContactId: function (component, contactId) {
        var getHouseholdAddressOfContact = component.get("c.getHouseholdAddressOfContact");
        getHouseholdAddressOfContact.setParams({
            contactId: contactId
        });
        getHouseholdAddressOfContact.setCallback(this, function (response) {
            var state = response.getState();
            var dataMap = response.getReturnValue();
            if (state === 'SUCCESS') {
                component.set("v.relationshipContactHouseholdAddress", dataMap['relationshipContactHouseholdAddress']);
            }
        });
        $A.enqueueAction(getHouseholdAddressOfContact);
    }
});