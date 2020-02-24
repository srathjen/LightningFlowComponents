/**
 * Created by gmayer on 06-Nov-19.
 */

({
    removeParticipant: function (cmp, event, helper) {
        var action = cmp.get("c.removeAsParticipant");
        var wishParticipant = cmp.get("v.wishAffiliation");
        action.setParams({
            objWishAffiliation: JSON.stringify(wishParticipant)
        });
        action.setCallback(this, function (response) {
            var itemUpdatedEvent = cmp.getEvent('wishAffiliationDesignItemEvent');
            itemUpdatedEvent.fire();
        });
        $A.enqueueAction(action);
    },

    addUpdateAsParticipant: function (cmp, event, helper) {
        var action = cmp.get("c.addUpdateAsParticipant");
        var wishParticipant = cmp.get("v.wishAffiliation");
        var wishParticipantClone = cmp.get("v.wishAffiliationBackup");
        action.setParams({
            objWishAffiliation: JSON.stringify(wishParticipant),
            objOldWishAffiliation: JSON.stringify(wishParticipantClone)
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            var dataMap = response.getReturnValue();
            var validationErrors = dataMap['validationErrors'];
            var userMessage = '';
            if (state === 'SUCCESS' && !Array.isArray(validationErrors) || !validationErrors.length) {
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
        });
        $A.enqueueAction(action);
    }
});