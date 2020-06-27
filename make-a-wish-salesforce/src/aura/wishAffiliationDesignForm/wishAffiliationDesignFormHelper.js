/**
 * Created by mnahar on 10/31/2019.
 */

({
    initialize: function (cmp) {
        var action = cmp.get("c.getWishAffiliations");
        var wishAffiliationCategory = "Medical Professional";
        var wishCaseRecordId = cmp.get("v.recordId");
        var flowWishCaseRecordId = cmp.get("v.wishCaseRecordId");
        if (flowWishCaseRecordId) {
            wishCaseRecordId = flowWishCaseRecordId;
            cmp.set("v.recordId", wishCaseRecordId);
        }
        action.setParams({
            "wishCaseRecordId": wishCaseRecordId,
            "wishAffiliationCategory": wishAffiliationCategory
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            var dataMap = response.getReturnValue();
            if (state === 'SUCCESS') {
                cmp.set("v.wishAffiliationList", dataMap['wishAffiliations']);
                cmp.set("v.relationshipTypes", dataMap['relationshipTypes']);
                cmp.set("v.salutationOptions", dataMap['salutationOptions']);
                cmp.set("v.residingWithChildOptions", dataMap['residingWithChild']);
                cmp.set("v.isUserProfileAllowedToUpdateWishAffiliation", dataMap['isUserProfileAllowedToUpdateWishAffiliation']);
                cmp.set("v.wishChildFirstName", dataMap['wishChildFirstName']);
                cmp.set("v.countsOfRequestedParticipants", dataMap['countReqParticipants']);
            }
        });
        $A.enqueueAction(action);
    },

    createWishAffiliation: function (cmp, event, helper) {
        var action = cmp.get("c.createWishAffiliation");
        var newWishAffiliation = JSON.stringify(cmp.get("v.newWishAffiliation"));
        action.setParams({
            payload: newWishAffiliation
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            var dataMap = response.getReturnValue();
            var validationErrors = dataMap['validationErrors'];
            var userMessage = '';
            if (state === 'SUCCESS' && !Array.isArray(validationErrors) || !validationErrors.length) {
                cmp.set('v.showModal', false);
                cmp.set('v.isValidRelationshipType', true);
                cmp.set('v.isValidFirstName', true);
                cmp.set('v.isValidLastName', true);
                cmp.set('v.isValidBirthdate', true);
                cmp.set('v.isValidEmail', true);
                cmp.set("v.newWishRequestedParticipant", cmp.initializeNewWishAffiliation(cmp));
                cmp.set('v.showToast', false);
                cmp.reInit(cmp, event, helper); 
            } else if (Array.isArray(validationErrors) || validationErrors.length) {
                validationErrors.forEach(function (validationError) {
                    userMessage += validationError;
                });
                cmp.set('v.toastMessage', userMessage);
                cmp.set('v.toastMessageType', 'error');
                cmp.set('v.showToast', true);
            } else {
                cmp.set('v.toastMessage', 'There was an error, please contact your administrator');
                cmp.set('v.toastMessageType', 'error');
                cmp.set('v.showToast', true);
            }
            cmp.set('v.isButtonDisabled', false);
        });
        $A.enqueueAction(action);
    }
});