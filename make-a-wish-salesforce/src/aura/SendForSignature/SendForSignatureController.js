({

    doInit: function (cmp, event, helper) {
        helper.initialize(cmp);
        if (cmp.get("v.statusList").includes(cmp.get("v.rowStatus"))) {
            cmp.set("v.isValidStatus", true);
        }
        cmp.find("SendESignModal").open();
        cmp.set('v.uploadSpinner', true);
        cmp.set('v.selectedLookUpRecord', null);
    },

    handleOnload: function (component, event, helper) {
        var contactEmails = [];
        var recUi = event.getParam("recordUi");
        var emailAddress = recUi.record.fields["Sent_to_Email_Address__c"].value;
        component.set("v.wishReqSignEmail", emailAddress);
        if ($A.util.isEmpty(emailAddress)) {
            emailAddress = component.get("v.wishReqSignRecord.Wish_Affiliation__r.Contact__r.Email");
        }

        if (recUi.record.fields.Wish_Affiliation__r.value.fields.hasOwnProperty("Contact__r")) {
            if (!$A.util.isEmpty(recUi.record.fields.Wish_Affiliation__r.value.fields.Contact__r.value.fields.npe01__WorkEmail__c.value)) {
                var workEmail = recUi.record.fields.Wish_Affiliation__r.value.fields.Contact__r.value.fields.npe01__WorkEmail__c.value;
                contactEmails.push({label: workEmail, value: workEmail});
            }
            if (!$A.util.isEmpty(recUi.record.fields.Wish_Affiliation__r.value.fields.Contact__r.value.fields.npe01__AlternateEmail__c.value)) {
                var altEmail = recUi.record.fields.Wish_Affiliation__r.value.fields.Contact__r.value.fields.npe01__AlternateEmail__c.value;
                contactEmails.push({label: altEmail, value: altEmail});
            }
            if (!$A.util.isEmpty(recUi.record.fields.Wish_Affiliation__r.value.fields.Contact__r.value.fields.Alternate_Email_2__c.value)) {
                var alt2Email = recUi.record.fields.Wish_Affiliation__r.value.fields.Contact__r.value.fields.Alternate_Email_2__c.value;
                contactEmails.push({label: alt2Email, value: alt2Email});
            }
            if (!$A.util.isEmpty(recUi.record.fields.Wish_Affiliation__r.value.fields.Contact__r.value.fields.RecordTypeId.value)) {
                var recordTypeId = recUi.record.fields.Wish_Affiliation__r.value.fields.Contact__r.value.fields.RecordTypeId.value;
                component.set("v.MPRecordTypeId", recordTypeId);
            }
        }

        component.set("v.otherEmails", contactEmails);
        component.set("v.emailId", emailAddress);

        if (component.find("sendViaEmail")) {
            component.find("sendViaEmail").set("v.value", emailAddress);
        }
        component.set('v.uploadSpinner', false);
    },

    handleSendESignCancel: function (cmp, event, helper) {
        let componentName = cmp.getType();
        componentName = componentName.substring(componentName.indexOf(":") + 1, componentName.length);
        var cmpEvent = cmp.getEvent("refreshEvent");
        cmpEvent.setParams({
            "isRefresh": true,
            "childCmp": componentName
        });
        cmpEvent.fire();
    },

    handleSendESign: function (cmp, event, helper) {
        var emailId;

        if (cmp.find("changeEmail") && cmp.find("changeEmail").get("v.checked")) {
            emailId = cmp.find("otherEmails") ? cmp.find("otherEmails").get("v.value") : '';
        } else {
            emailId = cmp.find("sendViaEmail") ? cmp.find("sendViaEmail").get("v.value") : '';
        }

        if ($A.util.isEmpty(emailId)) {
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "type": "error",
                "title": "Error!",
                "message": "Please specify an Email address to send the document for E-Signature"
            });
            toastEvent.fire();
            return;
        }
        helper.getDocgenDetails(cmp, event);
    },

    handleResendEnv: function (cmp, event, helper) {
        var actionToPerform = event.getSource().get("v.label");
        helper.updateEnvelope(cmp, event, actionToPerform);
    },

    enableDisableRadioButtons: function (cmp, event, helper) {
        var val = event.getSource().get("v.checked");
        cmp.find("otherEmails").set("v.disabled", !val);
        cmp.find("sendViaEmail").set("v.disabled", val);
    }
});