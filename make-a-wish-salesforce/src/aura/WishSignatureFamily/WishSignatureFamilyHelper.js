({
    getAffiliations : function(cmp,event) {
        var action = cmp.get("c.getWishAffiliations");
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
    
    createSelectedAdultsList : function(cmp,event) {
        var isChecked =  event.getSource().get("v.checked");
        var adultId = event.getSource().get("v.name");
        let dataObj = adultId.split(',');
        let adult = dataObj[0];
        let wishAff = dataObj[1];
        var mapListData = cmp.get("v.adultList") || [];
        //Create a list of adult's contact Id and their corresponding Wish Affiliation Id
        if(isChecked){
            mapListData.push({'adult' : adult, 'wishAff' : wishAff});
            cmp.set("v.adultList", mapListData);
        }
        else{            
            let recordList = cmp.get("v.adultList");
            let index = 0;
            for(let i=0; i<recordList.length; i++){
                if(recordList[i].adult == adult && recordList[i].wishAff == wishAff){
                    index = i;
                    break;
                }
            }
            recordList.splice(index,1);
            cmp.set("v.adultList", recordList);
        }
    },
    
    createSelectedMinorsList : function(cmp,event) {
        try{
            let isChecked =  event.getSource().get("v.checked");
            let nameData = event.getSource().get("v.name");
            let dataObj = nameData.split(',');
            let minor = dataObj[0];
            let adult = dataObj[1];
            let wishAffMinor = dataObj[2];
            var mapListData = cmp.get("v.adultChildMap") || [];
            //Create a list of adult's and minor's contact Id and its corresponding Wish Affiliation Id
            if(isChecked){
                mapListData.push({'adult' : adult, 'minor' : minor, 'wishAffMinor' : wishAffMinor});
                cmp.set("v.adultChildMap", mapListData);
            }else{
                let recordList = cmp.get("v.adultChildMap");
                let index = 0;
                for(let i=0; i<recordList.length; i++){
                    if(recordList[i].adult == adult && recordList[i].minor == minor && recordList[i].wishAffMinor == wishAffMinor ){
                        index = i;
                        break;
                    }
                }
                recordList.splice(index,1);
                cmp.set("v.adultChildMap", recordList);
            }
        }catch(e){
            console.log(e);
        }
    },
    
    saveWRSRecords: function(cmp,event) {
        //Check if nothing was selected or form is not selected
        if(($A.util.isEmpty(cmp.get("v.adultList")) && $A.util.isEmpty(cmp.get("v.adultChildMap"))) || $A.util.isEmpty(cmp.get("v.selectedLookUpRecord"))){
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "type": "error",
                "title": "Error!",
                "message": "Please select a Wish Form and at least one Signer."
            });
            toastEvent.fire();
            return;
        }
        var action = cmp.get("c.saveFamilyWishSignatures");
        action.setParams({
            "adultsIdList" : JSON.stringify(cmp.get("v.adultList")),
            "adultsToChildIds" : JSON.stringify(cmp.get("v.adultChildMap")),
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
                //Refresh the Child Component
                var childCmp = cmp.find("familyDatatable")
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