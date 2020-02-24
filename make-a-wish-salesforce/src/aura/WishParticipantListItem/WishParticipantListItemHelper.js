/**
 * Created by gmayer on 7/3/2019.
 */
({
    save: function (component, event, helper) {
        component.set('v.showSpinner', true);
        var modifiedWishAffiliationJson = JSON.stringify(component.get("v.wishParticipant"));
        var isUserProfileAllowedToUpdateWishAffiliation = component.get("v.isUserProfileAllowedToUpdateWishAffiliation");
        var requestParticipant = component.get("v.requestParticipant");
        var requestParticipantPrevious = component.get("v.requestParticipantPrevious");
        var save = component.get("c.saveWishAffiliation");
        save.setParams({
            payload: modifiedWishAffiliationJson,
            isUserProfileAllowedToUpdateWishAffiliation: isUserProfileAllowedToUpdateWishAffiliation,
            requestParticipant: requestParticipant,
            requestParticipantPrevious: requestParticipantPrevious
        });
        save.setCallback(this, function (response) {
            var state = response.getState();
            var dataMap = response.getReturnValue();
            var validationErrors = dataMap['validationErrors'];
            var userMessage = '';
            if (state === 'SUCCESS' && !Array.isArray(validationErrors) || !validationErrors.length) {
                // Set the Wish Participant only if its not a Wish Change Request that was made
                if (isUserProfileAllowedToUpdateWishAffiliation) {
                    var wishParticipant = dataMap['wishAffiliation'];
                    component.set("v.wishParticipant",wishParticipant);
                    component.set('v.wishParticipantBackup', JSON.parse(JSON.stringify(wishParticipant)));
                    userMessage = 'Record Saved';
                } else {
                    userMessage = 'Change Request Sent';
                }
                component.set('v.toastMessage', userMessage);
                component.set('v.toastMessageType', 'success');
                component.set("v.editMode", false);
                component.set("v.requestParticipantPrevious", requestParticipant);
            } else if (Array.isArray(validationErrors) || validationErrors.length) {
                validationErrors.forEach(function (validationError) {
                    userMessage += validationError;
                });
                component.set('v.toastMessage', userMessage);
                component.set('v.toastMessageType', 'error');
            } else {
                component.set('v.toastMessage', 'There was an error, please contact your administrator');
                component.set('v.toastMessageType', 'error');
            }
            component.set('v.showToast', true);
            component.set('v.showSpinner', false);
        });
        $A.enqueueAction(save);
    }
});