/*
Modification Log:
1. 03/28/2018 - Yuvraj - IME-59 - Line No: 48, 70, 95, 112-116
2. 25/04/2018 - Vignesh SM - IME 131 - Line No. 73, 100, 103-106
3. 12/07/2018 - Vignesh SM - IME 231
4. 06/01/2020- Brittany SIW-543
5. 08/28/2020- Pramod N - ODP-19
*/
({
    globalParams: {},
    processLeadForDV: function (component) {
        //Get Lead information and send for further processing
        let _this = this;
        let actionName = "c.getLeadInformation";
        let params = {
            "leadId": component.get("v.recordId")
        };
        _this.callAction(component, actionName, params, function (response) {
            component.set("v.leadData", response);
            _this.handleDiagnosisVerficationProcess(response, component);
        });
    },
    handleDiagnosisVerficationProcess: function (lead, component) {
        //Handle diagnosis verfication - checking criteria and send to appropriate processing
        let _this = this;
        if (lead.PD_Condition_Description__c || lead.PD_ICD_Code__c) {
            if (lead.Sub_Status__c === 'Pending Diagnosis Verification'
                || lead.Status === 'Eligibility Review') {
                _this.handleMediProfessional(lead, component);
            } else if (lead.Status !== 'Referred') {
                _this.handleReferredLead(lead.Status, component);
            } else {
                _this.ensureMPandHTFContactCreation(lead, component);
            }
        } else {
            _this.handleConfirmation(false, component, "Please Enter ICD Code or Condition Description", function () {
                _this.closeQuickAction();
            }, true);
        }
    },
    ensureMPandHTFContactCreation: function (lead, component) {
        //Check if lookup fields for Medical Professionals and HTFs are populated or Not
        let _this = this, msg = $A.get("$Label.c.MP_or_HTF_are_required");
        let contacts = [];
        //if referrer type is medical professional checks for referrer MP and HTF contact creation
        if (lead.Relationship_to_child__c === 'Medical Professional') {
            if (!lead.Referring_MP__c && (lead.Referring_MP_First_Name__c || lead.Referring_MP_Last_Name__c)) {
                contacts.push(lead.Referring_MP_First_Name__c + ' ' + lead.Referring_MP_Last_Name__c);
            }
            if (!lead.Referring_MP_HTF__c && lead.Referring_MP_HTF_Name__c) {
                contacts.push(lead.Referring_MP_HTF_Name__c);
            }
        }
        if (!lead.Treating_MP__c && (lead.Treating_Medical_Professional_First_Name__c || lead.Treating_Medical_Professional_Last_Name__c)) {
            contacts.push(lead.Treating_Medical_Professional_First_Name__c + ' ' + lead.Treating_Medical_Professional_Last_Name__c);
        }
        if (!lead.Treating_MP_HTF__c && lead.Hospital_Treatment_Facility_Treating__c) {
            contacts.push(lead.Hospital_Treatment_Facility_Treating__c);
        }
        if (!lead.Best_Contact__c && (lead.Best_Contact_for_Physician_First_Name__c || lead.Best_Contact_for_Physician_Last_Name__c)) {
            contacts.push(lead.Best_Contact_for_Physician_First_Name__c + ' ' + lead.Best_Contact_for_Physician_Last_Name__c);
        }
        if (!lead.Best_Contact_HTF__c && lead.Best_Contact_HTF_Name__c) {
            contacts.push(lead.Best_Contact_HTF_Name__c);
        }
        if (contacts.length > 0) {
            msg += '</br>' + contacts.join(", ");
            _this.handleConfirmation(false, component, msg, function () {
                _this.closeQuickAction();
            }, true);
        } else {
            _this.handleLeadDupe(lead, component);
        }
    },
    handleLeadDupe: function (lead, component) {
        //find for lead dupe
        let _this = this,
            paperDVProcess = lead.Using_Paper_Process_For_DV__c;
        //IME 272
        let leadDupe;
        let familyContactDupe;
        let notBlocked = lead.Dup_Check__c !== 'Block Lead Dup';
        let notBlockedContact = lead.Contact_Dup_Check__c !== 'Block Contact Dup';
        let priorWish = lead.Has_this_child_ever_received_prior_wish__c;

        let medProfessionalEmail = (lead.Treating_Medical_Professional_Email__c || lead.Treating_MP__c)
            || (lead.Best_contact_for_Physician_Email__c || lead.Best_Contact__c)
            || lead.Alternate1MedicalProfessionalEmail__c
            || lead.Alternate2MedProfessionalEmail__c;
        let params = {
            "leadId": lead.Id
        };
        //IME 272/**/
        _this.callAction(component, "c.findLeadDupe", params, function (response) {
            leadDupe = response;
            if (leadDupe && notBlocked) {
                _this.handleConfirmation(false, component, leadDupe, function () {
                    _this.navigateTo("/apex/LeadDuplicate_VF?id=" + lead.Id);
                }, false);
            } else if (!leadDupe || !notBlocked) {
                if (priorWish && priorWish.toLowerCase().indexOf('yes') != -1) {
                    _this.handleConfirmation(false, component, "Diagnosis verification cannot be sent as this child has received prior wish.", function () {
                        _this.closeQuickAction();
                    }, true);
                } else if (!medProfessionalEmail && !paperDVProcess) { //Modified as per IME 131
                    _this.handleConfirmation(false, component, "Please provide Treating/Best physician/Alternate Medical Professional Email or Using Paper Process for DV.", function () {
                        _this.closeQuickAction();
                    }, true);
                } else {
                    //IME 272
                    _this.callAction(component, "c.findFamilyContactDupe", params, function (response) {
                        familyContactDupe = response;
                        if (familyContactDupe && notBlockedContact) {
                            _this.handleConfirmation(false, component, familyContactDupe, function () {
                                _this.navigateTo("/apex/LeadDuplicate_VF?id=" + lead.Id + "&wishFamily=true");
                            }, false);
                        } else if (!familyContactDupe || !notBlockedContact) {
                            _this.handleMediProfessional(lead, component);
                        }
                    });
                }
            }
        });
    },
    handleMediProfessional: function (lead, component) {
        //Check for medical professional
        let _this = this,
            paperDVProcess = lead.Using_Paper_Process_For_DV__c,
            AgeRequirementNotMet = lead.Child_Age__c === 'Under 2.5' || lead.Child_Age__c === '18 & Above';
        if (!paperDVProcess && !AgeRequirementNotMet) {
            _this.navigateTo("/apex/LeadSelectMedEmail_VF?id=" + lead.Id);
        } else if (!paperDVProcess && AgeRequirementNotMet) {
            let verificationMessage = "This child did not meet our referral age. A DV should not be sent for this child unless your chapter has received a waiver from the Chapter Performance Committee. " + verificationMessage;
            // }
            _this.handleConfirmation(false, component, verificationMessage, function () {
                let checkMedProf = (lead.Treating_Medical_Professional_Email__c || lead.Treating_MP__c),
                    checkAltProf = (lead.Best_contact_for_Physician_Email__c || lead.Best_Contact__c)
                        || lead.Alternate1MedicalProfessionalEmail__c || lead.Alternate2MedProfessionalEmail__c,
                    mediProf_criteria = checkMedProf || checkAltProf;
                if (checkAltProf || checkMedProf) {
                    _this.navigateTo("/apex/LeadSelectMedEmail_VF?id=" + lead.Id);
                } else {
                    _this.handleConfirmation(false, component, "Please provide Treating/Best physician/Alternate Medical Professional Email or Using Paper Process for DV.", function () {
                        _this.closeQuickAction();
                    }, true);
                }
            }, false);
        } else {
            _this.handleConfirmation(false, component, "No potential duplicates found. Please send the Paper Diagnosis Verification Form manually.", function () {
                _this.closeQuickAction();
            }, true);
        }
    },
    handleReferredLead: function (leadStatus, component) {
        //Check lead in referred status
        let _this = this;
        let msg = "Diagnosis verification cannot be sent when lead is in " + leadStatus + " status.";
        _this.handleConfirmation(false, component, msg, function () {
            _this.closeQuickAction();
        }, true);
    },
    refreshPage: function (Id) {
        //Refresh current lead record page
        var _this = this;
        var navEvt = $A.get("e.force:navigateToSObject");
        _this.closeQuickAction();
        navEvt.setParams({
            "recordId": Id
        });
        navEvt.fire();
    },
    navigateTo: function (url) {
        //utility - navigate to specified URL
        $A.get("e.force:navigateToURL").setParams({"url": url}).fire();
    },
    handleConfirmation: function (isBtnAction, component, msgToDisplay, callback, isAlert) {
        //Confirmation box handler
        var _this = this;
        if (isBtnAction) {
            component.set("v.showLoader", true);
            _this.globalParams.confHandler();
        } else {
            component.set("v.showCancelBtn", !isAlert);
            component.set("v.dispMsg", msgToDisplay);
            component.set("v.showLoader", false);
            _this.globalParams.confHandler = callback;
        }
    },
    closeQuickAction: function () {
        //utility - Close the current quick action
        $A.get("e.force:closeQuickAction").fire();
    },
    callAction: function (component, actionName, params, callback) {
        var _this = this;
        var action = component.get(actionName);
        action.setParams(params);
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                callback(response.getReturnValue());
            } else if (state === "ERROR") {
                var errors = response.getError();
                var toastEvent = $A.get("e.force:showToast");
                var message = "Failed to process data";

                if (errors && errors[0] && (errors[0].message || (errors[0].pageErrors[0] && errors[0].pageErrors[0].message))) {
                    message = errors[0].message || errors[0].pageErrors[0].message;
                }
                toastEvent.setParams({
                    "title": "Failure!",
                    "message": message,
                    "type": "error"
                });
                toastEvent.fire();
                _this.closeQuickAction();
            }
        });
        $A.enqueueAction(action);
    }
});