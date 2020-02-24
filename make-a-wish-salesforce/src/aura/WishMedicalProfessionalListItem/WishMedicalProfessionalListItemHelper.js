/**
 * Created by gmayer on 7/26/2019.
 */
({
    save: function (component, event, helper) {
        component.set('v.showSpinner', true);
        var modifiedWishAffiliationJson = JSON.stringify(component.get("v.wishMedicalProfessional"));
        var isUserProfileAllowedToUpdateWishAffiliation = component.get("v.isUserProfileAllowedToUpdateWishAffiliation");
        var save = component.get("c.saveWishAffiliation");
        save.setParams({
            payload: modifiedWishAffiliationJson,
            isUserProfileAllowedToUpdateWishAffiliation: isUserProfileAllowedToUpdateWishAffiliation
        });
        save.setCallback(this, function (response) {
            var state = response.getState();
            var dataMap = response.getReturnValue();
            var validationErrors = dataMap['validationErrors'];
            var userMessage = '';
            if (state === 'SUCCESS' && !Array.isArray(validationErrors) || !validationErrors.length) {
                // Set the Wish MedicalProfessional only if its not a Wish Change Request that was made
                if (isUserProfileAllowedToUpdateWishAffiliation) {
                    var wishMedicalProfessional = dataMap['wishAffiliation'];
                    component.set("v.wishMedicalProfessional",wishMedicalProfessional);
                    component.set('v.wishMedicalProfessionalBackup', JSON.parse(JSON.stringify(wishMedicalProfessional)));
                    userMessage = 'Record Saved';
                } else {
                    userMessage = 'Change Request Sent';
                }
                component.set('v.toastMessage', userMessage);
                component.set('v.toastMessageType', 'success'); 
                component.set("v.editMode", false);
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