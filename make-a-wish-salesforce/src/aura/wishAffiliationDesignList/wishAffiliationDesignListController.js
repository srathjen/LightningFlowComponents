/**
 * Created by mnahar on 11/4/2019.
 */

({
    doInit: function (cmp) {
        // Make a copy of the initial value
        var wishParticipant = cmp.get("v.wishAffiliation");
        cmp.set('v.wishAffiliationBackup', JSON.parse(JSON.stringify(wishParticipant)));
    },

    handleClick: function (cmp, event, helper) {
        var itemList = [
            'reviewParticipant',
            'addParticipant',
            'updateParticipant'];
        var selectedMenuItemValue = event.getSource().get("v.name");
        if (itemList.includes(selectedMenuItemValue)) {
            cmp.set("v.showModal", true);
            cmp.find("participantModal").open();
        } else if (selectedMenuItemValue === 'removeParticipant') {
            cmp.set('v.isButtonDisabled', true);
            helper.removeParticipant(cmp, event, helper);
        }
    },

    handleCancel: function (cmp, event) {
        cmp.set('v.isButtonDisabled', true);
        event.preventDefault();
        var itemUpdatedEvent = cmp.getEvent('wishAffiliationDesignItemEvent');
        itemUpdatedEvent.fire();
    },

    handleSave: function (cmp, event, helper) {
        cmp.onChangeValidate(cmp);
        var isValidData = false;
        var isRelationshipTypeValid = cmp.get('v.isValidRelationshipType');
        var isFirstNameValid = cmp.get('v.isValidFirstName');
        var isLastNameValid = cmp.get('v.isValidLastName');
        var isBirthdateValid = cmp.get('v.isValidBirthdate');
        var isValidResidingWithWishChild = cmp.get('v.isValidResidingWithWishChild');
        if (isFirstNameValid
            && isLastNameValid
            && isRelationshipTypeValid
            && isBirthdateValid
            && isValidResidingWithWishChild) {
            isValidData = true;
        }
        if (isValidData) {
            cmp.set('v.isButtonDisabled', true);
            helper.addUpdateAsParticipant(cmp, event, helper);
            var itemUpdatedEvent = cmp.getEvent('wishAffiliationDesignItemEvent');
            itemUpdatedEvent.fire();
        }
    },

    // Handle close of Toast Message from Parent Component
    closeToast: function (cmp) {
        $A.util.addClass(cmp.find('toastModel'), 'slds-hide');
        cmp.set("v.toastMessage", "");
        cmp.set("v.toastMessageType", "");
        cmp.set('v.showToast', false);
    },

    // Validate fields data
    onChangeValidate: function (cmp) {
        var relationshipType = cmp.get("v.wishAffiliation.wishAffRecord.Relationship__r.npe4__Type__c");
        var firstName = cmp.get("v.wishAffiliation.wishAffRecord.Contact__r.FirstName");
        var lastName = cmp.get("v.wishAffiliation.wishAffRecord.Contact__r.LastName");
        var birthdate = cmp.get("v.wishAffiliation.wishAffRecord.Contact__r.Birthdate");
        var residingWithWishChild = cmp.get("v.wishAffiliation.wishAffRecord.Residing_with_Wish_child__c");

        if (relationshipType === undefined || relationshipType === null || relationshipType === "") {
            cmp.set('v.isValidRelationshipType', false);
        } else {
            cmp.set('v.isValidRelationshipType', true);
        }
        if (firstName === undefined || firstName === null || firstName === "") {
            cmp.set('v.isValidFirstName', false);
        } else {
            cmp.set('v.isValidFirstName', true);
        }
        if (lastName === undefined || lastName === null || lastName === "") {
            cmp.set('v.isValidLastName', false);
        } else {
            cmp.set('v.isValidLastName', true);
        }
        if (birthdate === undefined || birthdate === null || birthdate === "") {
            cmp.set('v.isValidBirthdate', false);
        } else {
            cmp.set('v.isValidBirthdate', true);
        }
        if (residingWithWishChild === undefined || residingWithWishChild === null || residingWithWishChild === "") {
            cmp.set('v.isValidResidingWithWishChild', false);
        } else {
            cmp.set('v.isValidResidingWithWishChild', true);
        }
    }
});