({
    getDocgenDetails : function(cmp, event) {
        var action = cmp.get("c.getDocGen");
        action.setParams({
            wishSignId : cmp.get("v.wishReqSignRecord.Id"),
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state === 'SUCCESS'){
                cmp.set('v.wishForm',response.getReturnValue());
                
                var actionUpdate = cmp.get("c.updateWishSignature");
                actionUpdate.setParams({
                    "wrsId": cmp.get("v.WRSId"),
                    "format" : 'E-Signature',
                    "emailId" :  cmp.find("sendViaEmail") ? cmp.find("sendViaEmail").get("v.value") : ''
                });
                actionUpdate.setCallback(this, function (response) {
                    var state = response.getState();
                    if (state === 'SUCCESS') {
                        var emailId = cmp.find("sendViaEmail") ? cmp.find("sendViaEmail").get("v.value") : '';
                        console.log('emailId '+emailId);
                        
                        var attachId = '';
                        if(cmp.find("fileUpload")){
                            attachId = cmp.find("fileUpload").get("v.attachmentId");
                        }
                        var url = window.location.protocol + '//' + window.location.host + '/apex/loop__looplus';
                        url = url + '?eid=' +  cmp.get("v.wishReqSignRecord.Id");
                        url = url + '&CaseId=' + cmp.get("v.caseId");
                        url = url + '&ddpIds=' + cmp.get("v.wishForm.DocGen_Package_ID__c");
                        url = url + '&deploy=' + cmp.get("v.wishForm.Delivery_Option_ID_eSign__c");
                        url = url + '&signer_name=' + cmp.get("v.wishReqSignRecord.Wish_Affiliation__r.Contact__r.Name");
                        url = url + '&signer_email=' + emailId;
                        url = url + '&attachIds=' + attachId;
                        url = url + '&header=false';
                        url = url + '&sidebar=false';
                        url = url + '&autorun=true';
                        
                        if (!cmp.get('v.iframeUrl')) {
                            cmp.set('v.iframeUrl', url);
                        }
                        else {
                            // Set blank and then set in order to reset iframe
                            cmp.set('v.iframeUrl', '');
                            setTimeout($A.getCallback(function() {
                                cmp.set('v.iframeUrl', url);
                            }), 2000);
                        }	
                    }
                    else if (state === 'ERROR') {
                        cmp.set("v.errors", response.getError());
                    }
                });
                $A.enqueueAction(actionUpdate);
            } 
            else if(state === 'ERROR'){
                cmp.set("v.errors", response.getError());
            }
        });
        $A.enqueueAction(action);	
    },
    
    updateEnvelope: function(cmp,event,actionToPerform) {
        if(actionToPerform == "Reassign"
           && ($A.util.isEmpty(cmp.get("v.selectedLookUpRecord")) || ((cmp.find("reassignEmail")) && $A.util.isEmpty( cmp.find("reassignEmail").get("v.value"))))) {
            let toastParams = {
                title: "Error",
                message: "Please select a Signer and Send to Email address",
                type: "error"
            }
            let toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams(toastParams);
            toastEvent.fire();
            return;
        }
        if(actionToPerform == "Reassign"){
            var validFields = [];
            validFields.push(cmp.find('reassignEmail'));
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
            } 
        }
        var wishAffList = [];
        if(actionToPerform == "Reassign"){
            if(!$A.util.isEmpty(cmp.get("v.selectedLookUpRecord")) && !$A.util.isEmpty(cmp.get("v.selectedLookUpRecord").Wish_Affiliations__r) ){
                for(let record of cmp.get("v.selectedLookUpRecord").Wish_Affiliations__r){
                    wishAffList.push(record);
                } 
            }
            
        }
       
        var action = cmp.get("c.updateEnvelopeDocusign");
        action.setParams({
            "action" : actionToPerform,
            "resendToEmail" : cmp.get("v.wishReqSignEmail"),
            "wrsId" : cmp.get("v.WRSId"),
            "voidReason" : cmp.get("v.voidReason"),
            "selectedCon" : cmp.get("v.selectedLookUpRecord"),
            "reassignToEmail" : cmp.find("reassignEmail") ? cmp.find("reassignEmail").get("v.value") : "",
            "wishAffList" : JSON.stringify(wishAffList)
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state === 'SUCCESS'){
                let res = response.getReturnValue();
                if(!$A.util.isEmpty(res["errorMessage"])){
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "type": "error",
                        "title": "Error!",
                        "message": res["errorMessage"]
                    });
                    toastEvent.fire();
                }
                else if(!$A.util.isEmpty(res["successMessage"])){
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "type": "success",
                        "title": "Success!",
                        "message": res["successMessage"]
                    });
                    toastEvent.fire();
                }
                cmp.set("v.refresh", cmp.get("v.refresh") + 1);
            }
            else if(state === 'ERROR'){
                cmp.set("v.errors", response.getError());
            }
            
        });
        $A.enqueueAction(action);	 
    },
    
})