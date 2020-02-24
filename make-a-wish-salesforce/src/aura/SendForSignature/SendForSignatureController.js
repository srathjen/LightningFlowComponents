({
    
    doInit : function(cmp, event, helper) {	
        if(cmp.get("v.statusList").includes(cmp.get("v.rowStatus"))){
            cmp.set("v.isValidStatus",true);
        }
        cmp.find("SendESignModal").open();
        cmp.set('v.uploadSpinner', true);
        cmp.set('v.selectedLookUpRecord',null);
    },
    
    handleOnload : function(component, event, helper) {
        var recUi = event.getParam("recordUi");
        var emailAddress = recUi.record.fields["Sent_to_Email_Address__c"].value;
        component.set("v.wishReqSignEmail",emailAddress);
        if($A.util.isEmpty(emailAddress))
        {
            emailAddress = component.get("v.wishReqSignRecord.Wish_Affiliation__r.Contact__r.Email");
        }
        
        component.set("v.emailId", emailAddress);
        if(component.find("sendViaEmail")){
            component.find("sendViaEmail").set("v.value",emailAddress);
        }
        component.set('v.uploadSpinner', false);
    },
    
    handleSendESignCancel: function (cmp, event, helper) {
        let componentName = cmp.getType();
        componentName = componentName.substring(componentName.indexOf(":") + 1, componentName.length);
        var cmpEvent = cmp.getEvent("refreshEvent");
        cmpEvent.setParams({
            "isRefresh" : true,
            "childCmp" : componentName
        });
        cmpEvent.fire();
    },
    
    handleSendESign: function (cmp, event, helper) {
        var emailId = cmp.find("sendViaEmail") ? cmp.find("sendViaEmail").get("v.value") : '';
        
        if($A.util.isEmpty(emailId) ){
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "type": "error",
                "title": "Error!",
                "message": "Please specify an Email address to send the document for E-Signature"
            });
            toastEvent.fire();
            return;
        }
        
        /*var validFields = [];
        validFields.push(cmp.find('recordViewForm'));
        var allValid = validFields.reduce(function (validSoFar, inputCmp) {
            inputCmp.reportValidity();
            return validSoFar && inputCmp.checkValidity();
        }, true);
        if (allValid) {
        } else {
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "type": "error",
                "title": "Error!",
                "message": "Please enter a Valid Email address"
            });
            toastEvent.fire();
            return;
        }*/
        helper.getDocgenDetails(cmp, event);
    },
    
    handleResendEnv: function (cmp, event, helper) {
        var actionToPerform = event.getSource().get("v.label");
        helper.updateEnvelope(cmp, event, actionToPerform);
    },
    
})