({
    getAffiliations : function(cmp,event) {
        var action = cmp.get("c.getWishAffiliationsMedical");
        action.setParams({
            caseId : cmp.get("v.recordId")
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state === 'SUCCESS'){
                cmp.set('v.wrapperList', response.getReturnValue());
            }
            else if(state === 'ERROR'){
                this.handleErrors(response.getError());
            }
        });
        $A.enqueueAction(action);	
    },
    
    selectedMedicalProfList: function(cmp,event) {
        var isChecked =  event.getSource().get("v.checked");
        var adultId = event.getSource().get("v.name");
        let dataObj = adultId.split(',');
        let adult = dataObj[0];
        let wishAff = dataObj[1];
        var mapListData = cmp.get("v.medicalProfList") || [];
        if(isChecked){
            mapListData.push({'adult' : adult, 'wishAff' : wishAff});
            cmp.set("v.medicalProfList", mapListData);
        }
        else{
            let recordList = cmp.get("v.medicalProfList");
            let index = 0;
            for(let i=0; i<recordList.length; i++){
                if(recordList[i].adult == adult && recordList[i].wishAff == wishAff){
                    index = i;
                    break;
                }
            }
            recordList.splice(index,1);
            cmp.set("v.medicalProfList", recordList);
        }
    },
    
    saveWRSRecords: function(cmp,event) {
        if($A.util.isEmpty(cmp.get("v.medicalProfList")) || $A.util.isEmpty(cmp.get("v.selectedLookUpRecord"))){
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "type": "error",
                "title": "Error!",
                "message": "Please select a Wish Form and at least one Signer."
            });
            toastEvent.fire();
            return;
        }
        
        var action = cmp.get("c.saveMedicalWishSignatures");
        action.setParams({
            "adultsIdList" : JSON.stringify(cmp.get("v.medicalProfList")),
            "caseId" : cmp.get("v.recordId"),
            "formId" : cmp.get("v.selectedLookUpRecord")
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state === 'SUCCESS'){
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "type": "success",
                    "title": "Success!",
                    "message": "Wish Required Signatures have been created successfully."
                });
                toastEvent.fire();
                //Get the child cmp using its name and call it's method
                var childCmp = cmp.find("medicalDatatable")
                childCmp.refreshMethod();
                var actionClose = cmp.get("c.handleCancel");
                $A.enqueueAction(actionClose);
            }
            else if(state === 'ERROR'){
                this.handleErrors(response.getError());
            }
        });
        $A.enqueueAction(action);	
    },
    
    handleErrors : function(errors) {
        // Configure error toast
        let toastParams = {
            title: "Error",
            message: "Unknown error", // Default error message
            type: "error"
        };
        // Pass the error message if any
        if (errors && Array.isArray(errors) && errors.length > 0) {
            toastParams.message = errors[0].message;
        }
        // Fire error toast
        let toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams(toastParams);
        toastEvent.fire();
    },
    
})