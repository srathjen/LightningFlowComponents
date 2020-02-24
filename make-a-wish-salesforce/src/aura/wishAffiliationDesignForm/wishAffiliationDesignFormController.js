/**
 * Created by mnahar on 10/31/2019.
 */

({
    doInit: function (component, event, helper) {
        helper.initialize(component, event, helper);
    },

    handleAddNewParticipant: function (cmp) {
        cmp.set("v.newWishAffiliation", cmp.initializeNewWishAffiliation(cmp));
        cmp.set("v.showModal", true);
        cmp.find("newParticipantModal").open();
    },

    handleCancel: function (cmp, event) {
        cmp.resetFieldValidation(cmp);
        cmp.set("v.showModal", false);
        cmp.find("newParticipantModal").close();
        // Prevent Form Submission
        event.preventDefault();
    },

    // Handle save of a new Wish Affiliation
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
            helper.createWishAffiliation(cmp);
        }
    },

    // Initialize default payload to create a New Participant
    initializeNewWishAffiliation: function (cmp) {
        var wishCaseRecordId = cmp.get("v.recordId");
        return JSON.parse('{' +
            '"WishAffiliationWishCaseRecordId":"' + wishCaseRecordId +
            '","RelationshipType":"",' +
            '"ContactFirstName":"",' +
            '"ContactMiddleName":"",' +
            '"ContactLastName":"",' +
            '"ContactBirthdate":"",' +
            '"WishAffiliationResidingWithWishChild":"",' +
            '"ContactTShirtSize":"",' +
            '"ContactEmail":""' +
            '}');
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
        var relationshipType = cmp.get("v.newWishAffiliation.RelationshipType");
        var firstName = cmp.get("v.newWishAffiliation.ContactFirstName");
        var lastName = cmp.get("v.newWishAffiliation.ContactLastName");
        var birthdate = cmp.get("v.newWishAffiliation.ContactBirthdate");
        var residingWithWishChild = cmp.get("v.newWishAffiliation.WishAffiliationResidingWithWishChild");

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
    },

    // Reset Field Validation
    resetFieldValidation: function (cmp) {
        cmp.set('v.isValidRelationshipType', true);
        cmp.set('v.isValidFirstName', true);
        cmp.set('v.isValidLastName', true);
        cmp.set('v.isValidBirthdate', true);
        cmp.set('v.isValidResidingWithWishChild', true);
    },

    // Handle Event WishAffiliationDesignItemEvent
    handleWishAffiliationDesignItemEvent: function (cmp, event, helper) {
        cmp.reInit(cmp, event, helper);
    }
});