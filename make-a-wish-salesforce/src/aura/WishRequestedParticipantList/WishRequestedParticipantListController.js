/**
 * Created by gmayer on 6/28/2019.
 */
({
    doInit: function (component, event, helper) {
        helper.initialize(component, event, helper);
    },

    refresh: function (component, event, helper) {
        component.reInit(component, event, helper);
    },

    openCloseModal: function (component, event, helper) {
        var isShowModal = component.get('v.showModal');
        component.set("v.newWishRequestedParticipant", component.initializeNewWishAffiliation(component));
        if (isShowModal) {
            component.set('v.showModal', false);
            component.set('v.showCreateContact', false);
            component.closeToast(component);
            /*
             * Reset the values of the Wish RequestedParticipant  Mailing Country and Mailing State,
             * Mailing Country cannot be empty when Mailing State is selected
             */
            component.set('v.isValidFirstName', true);
            component.set('v.isValidLastName', true);
            component.set('v.isValidCountry', true);
            component.set('v.isValidRelationshipType', true);
            component.set('v.isValidWishAffiliationType', true);
            component.set('v.isValidWishRequestedParticipantListContactLookup', true);
            component.set('v.isValidWishRequestedParticipantListRelatedContactLookup', true);
            component.set('v.modalContactLookupRecordId', '');
            component.set('v.newWishRequestedParticipant.Relationship__r.npe4__Contact__c', '');
            component.set("v.relationshipContactHouseholdAddress", '');
            component.onChangeShowContactAddressForm(component);
        } else {
            component.onChangeShowContactAddressForm(component);
            var wishChildContactId = component.get("v.wishChildContactId");
            component.set('v.showModal', true);
            helper.getHouseholdAddressByContactId(component, wishChildContactId);
        }
    },

    createNewWishAffiliationAction: function (component, event, helper) {
        component.onChangeValidate(component, event, helper);
        var isFirstNameValid = component.get('v.isValidFirstName');
        var isLastNameValid = component.get('v.isValidLastName');
        var isCountryValid = component.get('v.isValidCountry');
        var isRelationshipValid = component.get('v.isValidRelationshipType');
        var isWishAffiliationTypeValid = component.get('v.isValidWishAffiliationType');
        var isValidWishRequestedParticipantListContactLookup = component.get('v.isValidWishRequestedParticipantListContactLookup');
        var isValidWishRequestedParticipantListRelatedContactLookup = component.get('v.isValidWishRequestedParticipantListRelatedContactLookup');
        var isUserProfileAllowedToUpdateWishAffiliation = component.get("v.isUserProfileAllowedToUpdateWishAffiliation");
        var showCreateContact = component.get("v.showCreateContact");
        var isValidData;
        if (showCreateContact) {
            if (isFirstNameValid
                && isLastNameValid
                && isCountryValid
                && isRelationshipValid
                && isWishAffiliationTypeValid
                && isValidWishRequestedParticipantListRelatedContactLookup) {
                isValidData = true;
            } else {
                isValidData = false;
            }
        } else {
            if (isRelationshipValid
                && ((isValidWishRequestedParticipantListContactLookup
                && isWishAffiliationTypeValid
                && isValidWishRequestedParticipantListRelatedContactLookup)
                    || !isUserProfileAllowedToUpdateWishAffiliation)) {
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
        var wishAffiliationType = component.get("v.newWishRequestedParticipant.Wish_Affiliation_Type__c");
        if (wishAffiliationType === "") {
            component.set('v.isValidWishAffiliationType', false);
        } else {
            component.set('v.isValidWishAffiliationType', true);
        }

        var relationshipType = component.find("relationshipType").get("v.value");
        var wishRequestedParticipantListRelatedContactLookup = component.get("v.newWishRequestedParticipant.Relationship__r.npe4__Contact__c");
        if (relationshipType === "") {
            component.set('v.isValidRelationshipType', false);
        } else {
            component.set('v.isValidRelationshipType', true);
        }
        if (!wishRequestedParticipantListRelatedContactLookup) {
            component.set('v.isValidWishRequestedParticipantListRelatedContactLookup', false);
        } else {
            component.set('v.isValidWishRequestedParticipantListRelatedContactLookup', true);
        }

        var showCreateContact = component.get("v.showCreateContact");
        if (showCreateContact) {
            var firstName = component.get("v.newWishRequestedParticipant.Contact__r.FirstName");
            var lastName = component.get("v.newWishRequestedParticipant.Contact__r.LastName");
            var mailingState = component.get("v.newWishRequestedParticipant.Contact__r.MailingState");
            var mailingCountry = component.get("v.newWishRequestedParticipant.Contact__r.MailingCountry");

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
                component.set('v.isValidWishRequestedParticipantListContactLookup', false);
            } else {
                component.set('v.isValidWishRequestedParticipantListContactLookup', true);
            }
        }
    },

    initializeNewWishAffiliation: function (component) {
        var wishCaseRecordId = component.get("v.recordId");
        var wishChildContactId = component.get("v.wishChildContactId");
        var wishAffiliationTypeDefault = component.get("v.wishAffiliationTypesOfCategoryDefault");
        return JSON.parse('{ ' +
            '"Wish__c":"' + wishCaseRecordId + '", "Wish_Affiliation_Type__c":"' + wishAffiliationTypeDefault + '","Residing_with_Wish_child__c":"",' +
            '"Medical_Needs__c":false,"Survey_Recipient__c":false,"Non_Comped__c":false,"Details__c":"",' +
            '"Contact__r":{"Salutation":"","FirstName":"","LastName":"","Birthdate":"","MailingStreet":"","MailingCity":"","MailingState":"",' +
            '"MailingPostalCode":"","MailingCountry":"","npe01__PreferredPhone__c":"","Phone":"","npe01__HomeEmail__c":"",' +
            '"npsp__is_Address_Override__c":false,"npsp__Do_Not_Contact__c":false,"Do_Not_Contact_Notes__c":"","npsp__Deceased__c":false},' +
            '"Relationship__r":{"npe4__Type__c":"","Parent_Legal_Guardian__c":false,' +
            '"npe4__Contact__c":"' + wishChildContactId + '"}}');
    },

    onChangeShowContactAddressForm: function (component) {
        var relationshipContact = component.get("v.newWishRequestedParticipant.Relationship__r.npe4__Contact__c");
        var contactResidesWithRelationshipContact = component.get("v.contactResidesWithRelationshipContact");
        var addressOverride = component.get("v.newWishRequestedParticipant.Contact__r.npsp__is_Address_Override__c");
        if (relationshipContact) {
            if (contactResidesWithRelationshipContact) {
                if (addressOverride) {
                    component.set('v.isAddressOverride', true);
                } else {
                    component.set('v.isAddressOverride', false);
                    component.set("v.newWishRequestedParticipant.Contact__r.MailingStreet", "");
                    component.set("v.newWishRequestedParticipant.Contact__r.MailingCity", "");
                    component.set("v.newWishRequestedParticipant.Contact__r.MailingPostalCode", "");
                    component.set("v.newWishRequestedParticipant.Contact__r.MailingState", "");
                    component.set("v.newWishRequestedParticipant.Contact__r.MailingCountry", "");
                }
            } else {
                component.set("v.newWishRequestedParticipant.Contact__r.npsp__is_Address_Override__c", false);
                component.set('v.isAddressOverride', false);
                component.set("v.newWishRequestedParticipant.Contact__r.MailingStreet", "");
                component.set("v.newWishRequestedParticipant.Contact__r.MailingCity", "");
                component.set("v.newWishRequestedParticipant.Contact__r.MailingPostalCode", "");
                component.set("v.newWishRequestedParticipant.Contact__r.MailingState", "");
                component.set("v.newWishRequestedParticipant.Contact__r.MailingCountry", "");
            }
        } else {
            component.set("v.contactResidesWithRelationshipContact", false);
            component.set("v.newWishRequestedParticipant.Contact__r.npsp__is_Address_Override__c", false);
            component.set('v.isAddressOverride', false);
            component.set("v.newWishRequestedParticipant.Contact__r.MailingStreet", "");
            component.set("v.newWishRequestedParticipant.Contact__r.MailingCity", "");
            component.set("v.newWishRequestedParticipant.Contact__r.MailingPostalCode", "");
            component.set("v.newWishRequestedParticipant.Contact__r.MailingState", "");
            component.set("v.newWishRequestedParticipant.Contact__r.MailingCountry", "");
        }
    },

    handleLookupSelectedEvent: function (component, event, helper) {
        var lookupId = event.getParam("lookupId");
        var recordId = event.getParam("recordId");
        if (lookupId === 'wishRequestedParticipantListContactLookup') {
            component.set('v.modalContactLookupRecordId', recordId);
            component.set('v.isValidWishRequestedParticipantListContactLookup', true);
        } else if (lookupId === 'wishRequestedParticipantListRelatedContactLookup') {
            component.set('v.newWishRequestedParticipant.Relationship__r.npe4__Contact__c', recordId);
            component.onChangeShowContactAddressForm(component);
            component.set('v.isValidWishRequestedParticipantListRelatedContactLookup', true);
            helper.getHouseholdAddressByContactId(component, recordId);
        }
    },

    handleLookupClearedEvent: function (component, event, helper) {
        var lookupId = event.getParam("lookupId");
        if (lookupId === 'wishRequestedParticipantListContactLookup') {
            component.set('v.modalContactLookupRecordId', '');
            component.set('v.isValidWishRequestedParticipantListContactLookup', false);
        } else if (lookupId === 'wishRequestedParticipantListRelatedContactLookup') {
            component.set('v.newWishRequestedParticipant.Relationship__r.npe4__Contact__c', '');
            component.onChangeShowContactAddressForm(component);
            component.set('v.isValidWishRequestedParticipantListRelatedContactLookup', false);
            component.set("v.relationshipContactHouseholdAddress", '');
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