/**
 * Created by gmayer on 7/26/2019.
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
        component.set("v.newWishOther", component.initializeNewWishAffiliation(component));
        component.onChangeShowContactAddressForm(component);
        if (isShowModal) {
            component.set('v.showModal', false);
            component.set('v.showCreateContact', false);
            component.closeToast(component);
            /*
             * Reset the values of the Wish Other  Mailing Country and Mailing State,
             * Mailing Country cannot be empty when Mailing State is selected
             */
            component.set('v.isValidFirstName', true);
            component.set('v.isValidLastName', true);
            component.set('v.isValidCountry', true);
            component.set('v.isValidRelationshipType', true);
            component.set('v.isValidWishAffiliationType', true);
            component.set('v.isValidWishOtherListContactLookup', true);
            component.set('v.isValidWishOtherListRelatedContactLookup', true);
            component.set('v.modalContactLookupRecordId', '');
            component.set('v.newWishOther.Relationship__r.npe4__Contact__c', '');
            component.set("v.relationshipContactHouseholdAddress", '');
            component.onChangeShowContactAddressForm(component);
        } else {
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
        var isValidWishOtherListContactLookup = component.get('v.isValidWishOtherListContactLookup');
        var isValidWishOtherListRelatedContactLookup = component.get('v.isValidWishOtherListRelatedContactLookup');
        var isUserProfileAllowedToUpdateWishAffiliation = component.get("v.isUserProfileAllowedToUpdateWishAffiliation");
        var showCreateContact = component.get("v.showCreateContact");
        var isValidData;
        if (showCreateContact) {
            if (isFirstNameValid
                && isLastNameValid
                && isCountryValid
                && isRelationshipValid
                && isWishAffiliationTypeValid
                && isValidWishOtherListRelatedContactLookup) {
                isValidData = true;
            } else {
                isValidData = false;
            }
        } else {
            if (isRelationshipValid
                && ((isValidWishOtherListContactLookup
                    && isWishAffiliationTypeValid
                    && isValidWishOtherListRelatedContactLookup)
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
        var wishAffiliationType = component.get("v.newWishOther.Wish_Affiliation_Type__c");
        if (wishAffiliationType === "") {
            component.set('v.isValidWishAffiliationType', false);
        } else {
            component.set('v.isValidWishAffiliationType', true);
        }

        var relationshipType = component.find("relationshipType").get("v.value");
        var wishOtherListRelatedContactLookup = component.get("v.newWishOther.Relationship__r.npe4__Contact__c");
        if (wishOtherListRelatedContactLookup && relationshipType === "") {
            component.set('v.isValidRelationshipType', false);
        } else {
            component.set('v.isValidRelationshipType', true);
        }
        if (relationshipType !== "" && !wishOtherListRelatedContactLookup) {
            component.set('v.isValidWishOtherListRelatedContactLookup', false);
        } else {
            component.set('v.isValidWishOtherListRelatedContactLookup', true);
        }

        var showCreateContact = component.get("v.showCreateContact");
        if (showCreateContact) {
            var firstName = component.get("v.newWishOther.Contact__r.FirstName");
            var lastName = component.get("v.newWishOther.Contact__r.LastName");
            var mailingState = component.get("v.newWishOther.Contact__r.MailingState");
            var mailingCountry = component.get("v.newWishOther.Contact__r.MailingCountry");

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
            if (mailingState !== "" && mailingCountry === "") {
                component.set('v.isValidCountry', false);
            } else {
                component.set('v.isValidCountry', true);
            }
        } else {
            var modalContactLookupRecordId = component.get('v.modalContactLookupRecordId');
            if (!modalContactLookupRecordId) {
                component.set('v.isValidWishOtherListContactLookup', false);
            } else {
                component.set('v.isValidWishOtherListContactLookup', true);
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
            '"Contact__r":{"FirstName":"","LastName":"","Birthdate":"","MailingStreet":"","MailingCity":"","MailingState":"",' +
            '"MailingPostalCode":"","MailingCountry":"","npe01__PreferredPhone__c":"","Phone":"","npe01__HomeEmail__c":"",' +
            '"npsp__is_Address_Override__c":false,"npsp__Do_Not_Contact__c":false,"Do_Not_Contact_Notes__c":"","npsp__Deceased__c":false},' +
            '"Relationship__r":{"npe4__Type__c":"","Parent_Legal_Guardian__c":false,' +
            '"npe4__Contact__c":"' + wishChildContactId + '"}}');
    },

    onChangeShowContactAddressForm: function (component) {
        var relationshipContact = component.get("v.newWishOther.Relationship__r.npe4__Contact__c");
        var contactResidesWithRelationshipContact = component.get("v.contactResidesWithRelationshipContact");
        var addressOverride = component.get("v.newWishOther.Contact__r.npsp__is_Address_Override__c");
        if (relationshipContact) {
            if (contactResidesWithRelationshipContact) {
                if (addressOverride) {
                    component.set('v.isAddressOverride', true);
                } else {
                    component.set('v.isAddressOverride', false);
                    component.set("v.newWishOther.Contact__r.MailingStreet", "");
                    component.set("v.newWishOther.Contact__r.MailingCity", "");
                    component.set("v.newWishOther.Contact__r.MailingPostalCode", "");
                    component.set("v.newWishOther.Contact__r.MailingState", "");
                    component.set("v.newWishOther.Contact__r.MailingCountry", "");
                }
            } else {
                component.set("v.newWishOther.Contact__r.npsp__is_Address_Override__c", false);
                component.set('v.isAddressOverride', false);
                component.set("v.newWishOther.Contact__r.MailingStreet", "");
                component.set("v.newWishOther.Contact__r.MailingCity", "");
                component.set("v.newWishOther.Contact__r.MailingPostalCode", "");
                component.set("v.newWishOther.Contact__r.MailingState", "");
                component.set("v.newWishOther.Contact__r.MailingCountry", "");
            }
        } else {
            component.set("v.contactResidesWithRelationshipContact", false);
            component.set("v.newWishOther.Contact__r.npsp__is_Address_Override__c", false);
            component.set('v.isAddressOverride', false);
            component.set("v.newWishOther.Contact__r.MailingStreet", "");
            component.set("v.newWishOther.Contact__r.MailingCity", "");
            component.set("v.newWishOther.Contact__r.MailingPostalCode", "");
            component.set("v.newWishOther.Contact__r.MailingState", "");
            component.set("v.newWishOther.Contact__r.MailingCountry", "");
        }
    },

    handleLookupSelectedEvent: function (component, event, helper) {
        var lookupId = event.getParam("lookupId");
        var recordId = event.getParam("recordId");
        if (lookupId === 'wishOtherListContactLookup') {
            component.set('v.modalContactLookupRecordId', recordId);
            component.set('v.isValidWishOtherListContactLookup', true);
        } else if (lookupId === 'wishOtherListRelatedContactLookup') {
            component.set('v.newWishOther.Relationship__r.npe4__Contact__c', recordId);
            component.onChangeShowContactAddressForm(component);
            var relationshipType = component.find("relationshipType").get("v.value");
            var wishOtherListRelatedContactLookup = component.get("v.newWishOther.Relationship__r.npe4__Contact__c");
            if (wishOtherListRelatedContactLookup && relationshipType === "") {
                component.set('v.isValidRelationshipType', false);
            } else {
                component.set('v.isValidRelationshipType', true);
            }
            if (relationshipType !== "" && !wishOtherListRelatedContactLookup) {
                component.set('v.isValidWishOtherListRelatedContactLookup', false);
            } else {
                component.set('v.isValidWishOtherListRelatedContactLookup', true);
                helper.getHouseholdAddressByContactId(component, recordId);
            }
        }
    },

    handleLookupClearedEvent: function (component, event, helper) {
        var lookupId = event.getParam("lookupId");
        if (lookupId === 'wishOtherListContactLookup') {
            component.set('v.modalContactLookupRecordId', '');
            component.set('v.isValidWishOtherListContactLookup', false);
        } else if (lookupId === 'wishOtherListRelatedContactLookup') {
            component.set('v.newWishOther.Relationship__r.npe4__Contact__c', '');
            component.onChangeShowContactAddressForm(component);
            var relationshipType = component.find("relationshipType").get("v.value");
            var wishOtherListRelatedContactLookup = component.get("v.newWishOther.Relationship__r.npe4__Contact__c");
            if (wishOtherListRelatedContactLookup && relationshipType === "") {
                component.set('v.isValidRelationshipType', false);
            } else {
                component.set('v.isValidRelationshipType', true);
            }
            if (relationshipType !== "" && !wishOtherListRelatedContactLookup) {
                component.set('v.isValidWishOtherListRelatedContactLookup', false);
                component.set("v.relationshipContactHouseholdAddress", '');
            } else {
                component.set('v.isValidWishOtherListRelatedContactLookup', true);
            }
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

    closeToast: function (component, event, helper) {
        $A.util.addClass(component.find('toastModel'), 'slds-hide');
        component.set("v.messageType", "");
        component.set("v.messageType", "");
        component.set('v.showToast', false);
    },

    handleCustomToastCloseEvent: function (component, event, helper) {
        component.set('v.showToast', false);
    }
});