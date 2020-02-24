({
    getDocgenDetails : function (cmp, event) {
        var action = cmp.get("c.getDocGen");
        action.setParams({
            wishSignId: cmp.get("v.WRSId"),
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === 'SUCCESS') {
                cmp.set('v.wishForm', response.getReturnValue());

                var url = window.location.protocol + '//' + window.location.host + '/apex/loop__looplus';
                url = url + '?eid=' + cmp.get("v.WRSId");
                url = url + '&CaseId=' + cmp.get("v.caseId");
                url = url + '&ddpIds=' + cmp.get("v.wishForm.DocGen_Package_ID__c");
                url = url + '&deploy=' + cmp.get("v.wishForm.Delivery_Option_ID_Print__c");
                url = url + '&header=false';
                url = url + '&sidebar=false';
                url = url + '&autorun=true';

                console.log('url '+url);

                if (!cmp.get('v.iframeUrl')) {
                    cmp.set('v.iframeUrl', url);
                } else {
                    // Set blank and then set in order to reset iframe
                    cmp.set('v.iframeUrl', '');
                    setTimeout($A.getCallback(function () {
                        cmp.set('v.iframeUrl', url);
                    }), 2000);
                }
                var actionUpdate = cmp.get("c.updateWishSignature");
                actionUpdate.setParams({
                    "wrsId": cmp.get("v.WRSId"),
                    "format" : 'Paper'
                });
                actionUpdate.setCallback(this, function (response) {
                    var state = response.getState();
                    if (state === 'SUCCESS') {
                       /* var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            "type": "success",
                            "title": "Success!",
                            "message": "Wish Signature updated successfully"
                        });
                        toastEvent.fire(); */
                    }
                    else if (state === 'ERROR') {
                        cmp.set("v.errors", response.getError());
                    }
                });
                $A.enqueueAction(actionUpdate); 
				                   
            } else if (state === 'ERROR') {
                cmp.set("v.errors", response.getError());
            }
        });
        $A.enqueueAction(action);
    }
})