/**
 * Created by gmayer on 7/26/2019.
 */
({
    doInit: function (component, event, helper) {
        helper.initialize(component, event, helper);
    },

    refresh: function (component, event, helper){
        component.reInit(component, event, helper);
    },

    openCloseModal: function (component) {
        var isShowModal = component.get('v.showModal');
        component.set("v.newWishMedicalProfessional", component.initializeNewWishAffiliation(component));
        if (isShowModal) {
            component.set('v.showModal', false);
            component.set('v.showCreateContact', false);
            component.closeToast(component);
            /*
             * Reset the values of the Wish MedicalProfessional  Mailing Country and Mailing State,
             * Mailing Country cannot be empty when Mailing State is selected
             */
            component.set('v.isValidFirstName', true);
            component.set('v.isValidLastName', true);
            component.set('v.isValidCountry', true);
            component.set('v.isValidRelationshipType', true);
            component.set('v.isValidWishAffiliationType', true);
            component.set('v.isValidWishMedicalProfessionalListContactLookup', true);
            component.set('v.isValidWishMedicalProfessionalListRelatedContactLookup', true);
            component.set('v.modalContactLookupRecordId', '');
            component.set('v.newWishMedicalProfessional.Relationship__r.npe4__Contact__c', '');
            component.set('v.newWishMedicalProfessional.Health_Treatment_Facility__c', '');
        } else {
            component.set('v.showModal', true);
        }
    },

    createNewWishAffiliationAction: function (component, event, helper) {
        component.onChangeValidate(component, event, helper);
        var isFirstNameValid = component.get('v.isValidFirstName');
        var isLastNameValid = component.get('v.isValidLastName');
        var isCountryValid = component.get('v.isValidCountry');
        var isRelationshipValid = component.get('v.isValidRelationshipType');
        var isWishAffiliationTypeValid = component.get('v.isValidWishAffiliationType');
        var isValidWishMedicalProfessionalListContactLookup = component.get('v.isValidWishMedicalProfessionalListContactLookup');
        var isValidWishMedicalProfessionalListRelatedContactLookup = component.get('v.isValidWishMedicalProfessionalListRelatedContactLookup');
        var showCreateContact = component.get("v.showCreateContact");
        var isValidData;
        if (showCreateContact) {
            if (isFirstNameValid && isLastNameValid && isCountryValid && isRelationshipValid
                && isWishAffiliationTypeValid && isValidWishMedicalProfessionalListRelatedContactLookup) {
                isValidData = true;
            } else {
                isValidData = false;
            }
        } else {
            if (isValidWishMedicalProfessionalListContactLookup && isRelationshipValid
                && isWishAffiliationTypeValid && isValidWishMedicalProfessionalListRelatedContactLookup) {
                isValidData = true;
            } else {
                isValidData = false;
            }
        }
        if (isValidData) {
            component.set('v.isHide', true);
            helper.createWishAffiliation(component, event, helper);
        }
    },

    onChangeValidate: function (component, event, helper) {
        /*
         * Validate Mailing Country and Mailing State,
         * Mailing Country cannot be empty when Mailing State is selected
         */
        var wishAffiliationType = component.get("v.newWishMedicalProfessional.Wish_Affiliation_Type__c");
        if (wishAffiliationType === "") {
            component.set('v.isValidWishAffiliationType', false);
        } else {
            component.set('v.isValidWishAffiliationType', true);
        }

        var relationshipType = component.find("relationshipType").get("v.value");
        var wishMedicalProfessionalListRelatedContactLookup = component.get("v.newWishMedicalProfessional.Relationship__r.npe4__Contact__c");
        if (relationshipType === "") {
            component.set('v.isValidRelationshipType', false);
        } else {
            component.set('v.isValidRelationshipType', true);
        }
        if (!wishMedicalProfessionalListRelatedContactLookup) {
            component.set('v.isValidWishMedicalProfessionalListRelatedContactLookup', false);
        } else {
            component.set('v.isValidWishMedicalProfessionalListRelatedContactLookup', true);
        }

        var showCreateContact = component.get("v.showCreateContact");
        if (showCreateContact) {
            var firstName = component.get("v.newWishMedicalProfessional.Contact__r.FirstName");
            var lastName = component.get("v.newWishMedicalProfessional.Contact__r.LastName");
            var mailingState = component.get("v.newWishMedicalProfessional.Contact__r.MailingState");
            var mailingCountry = component.get("v.newWishMedicalProfessional.Contact__r.MailingCountry");

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
        } else {
            var modalContactLookupRecordId = component.get('v.modalContactLookupRecordId');
            if (!modalContactLookupRecordId) {
                component.set('v.isValidWishMedicalProfessionalListContactLookup', false);
            } else {
                component.set('v.isValidWishMedicalProfessionalListContactLookup', true);
            }
        }
    },

    initializeNewWishAffiliation: function (component) {
        var wishCaseRecordId = component.get("v.recordId");
        var wishChildContactId = component.get("v.wishChildContactId");
        var wishAffiliationTypeDefault = component.get("v.wishAffiliationTypesOfCategoryDefault");
        return JSON.parse('{ ' +
            '"Wish__c":"' + wishCaseRecordId + '", "Wish_Affiliation_Type__c":"' + wishAffiliationTypeDefault + '",' +
            '"Details__c":"","Send_Clearance_Forms_To__c":false,"Health_Treatment_Facility__c":"",' +
            '"Contact__r":{"Salutation":"","FirstName":"","LastName":"","Provider_Type__c":"","Fax":"","MailingStreet":"","MailingCity":"","MailingState":"",' +
            '"MailingPostalCode":"","MailingCountry":"","npe01__PreferredPhone__c":"","Phone":"","npe01__HomeEmail__c":"",' +
            '"npsp__Deceased__c":false},"Relationship__r":{"npe4__Type__c":"","npe4__Contact__c":"' + wishChildContactId + '",' +
            '"Qualifying_Medical_Professional__c":false,"Treating_HCP__c":false,"Best_Contact__c":false,"Referring_Medical_Professional__c":false,' +
            '"Former_MP__c":false}}');
    },

    handleLookupSelectedEvent: function (component, event, helper) {
        var lookupId = event.getParam("lookupId");
        var recordId = event.getParam("recordId");
        if (lookupId === 'wishMedicalProfessionalListContactLookup') {
            component.set('v.modalContactLookupRecordId', recordId);
            component.set('v.isValidWishMedicalProfessionalListContactLookup', true);
        } else if (lookupId === 'wishMedicalProfessionalListRelatedContactLookup') {
            component.set('v.newWishMedicalProfessional.Relationship__r.npe4__Contact__c', recordId);
            component.set('v.isValidWishMedicalProfessionalListRelatedContactLookup', true);
        } else if (lookupId === 'wishMedicalProfessionalListHealthTreatmentFacilityAccountLookup') {
            component.set('v.newWishMedicalProfessional.Health_Treatment_Facility__c', recordId);
        }
    },

    handleLookupClearedEvent: function (component, event, helper) {
        var lookupId = event.getParam("lookupId");
        if (lookupId === 'wishMedicalProfessionalListContactLookup') {
            component.set('v.modalContactLookupRecordId', '');
            component.set('v.isValidWishMedicalProfessionalListContactLookup', false);
        } else if (lookupId === 'wishMedicalProfessionalListRelatedContactLookup') {
            component.set('v.newWishMedicalProfessional.Relationship__r.npe4__Contact__c', '');
            component.set('v.isValidWishMedicalProfessionalListRelatedContactLookup', false);
        } else if (lookupId === 'wishMedicalProfessionalListHealthTreatmentFacilityAccountLookup') {
            component.set('v.newWishMedicalProfessional.Health_Treatment_Facility__c', '');
        }
    },

    showCreateContact: function (component, event, helper) {
        var showCreateContact = component.get('v.showCreateContact');
        if (showCreateContact) {
            component.set('v.showCreateContact', false);
        } else {
            component.set('v.showCreateContact', true);
        }
    },

    closeToast: function (component) {
        $A.util.addClass(component.find('toastModel'), 'slds-hide');
        component.set("v.messageType", "");
        component.set("v.messageType", "");
        component.set('v.showToast', false);
    },

    handleCustomToastCloseEvent: function (component, event, helper) {
        component.set('v.showToast', false);
    }
});