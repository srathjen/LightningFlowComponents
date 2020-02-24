({
    changeSigner : function (cmp, event) {
        var action = cmp.get("c.updateSignerOnWRS");
        action.setParams({ wrsId :  cmp.get("v.WRSId"),
                          conId : cmp.get("v.selectedLookUpRecord.Id"),
                          caseId :  cmp.get("v.caseId"),
                         });
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "type": "success",
                    "title": "Success!",
                    "message": "Wish Signer changed successfully."
                });
                toastEvent.fire();
                
                let componentName = cmp.getType();
                componentName = componentName.substring(componentName.indexOf(":") + 1, componentName.length);
                var cmpEvent = cmp.getEvent("refreshEvent");
                cmpEvent.setParams({
                    "isRefresh" : true,
                    "childCmp" : componentName
                });
                cmpEvent.fire();
            }
            else if(state === 'ERROR'){
                cmp.set("v.errors",response.getError());
            }
        });
        $A.enqueueAction(action);
    },
    
    getWishAffiliation : function (cmp, event) {
        if(!$A.util.isEmpty( cmp.get("v.selectedLookUpRecord.Id"))){
            cmp.set('v.uploadSpinner', true);
            var action = cmp.get("c.getWishAffRecord");
            action.setParams({                           
                conId : cmp.get("v.selectedLookUpRecord.Id"),
                caseId :  cmp.get("v.caseId")
            });
            action.setCallback(this, function(response){
                var state = response.getState();
                if (state === "SUCCESS") {
                    cmp.set("v.wishAffRecord",response.getReturnValue());
                }
                cmp.set('v.uploadSpinner', false);
            });
            $A.enqueueAction(action);
        }
    } 
    
})