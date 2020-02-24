({
    deleteWishSignature : function (cmp,event){
        var action = cmp.get("c.deleteWishRequiredSigns");
        action.setParams({ wrsId : cmp.get("v.WRSId")});
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "type": "success",
                    "title": "Success!",
                    "message": "Wish Required Signature deleted successfully."
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
})