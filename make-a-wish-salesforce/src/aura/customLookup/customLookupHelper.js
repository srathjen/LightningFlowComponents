({
    searchHelper: function (component, event, getInputkeyWord) {
        $A.util.removeClass(component.find("mySpinner"), "slds-hide");
        $A.util.addClass(component.find("mySpinner"), "slds-show");
        // call the apex class method 
        var action = component.get("c.fetchLookUpValues");
        // set param to method
        action.setParams({
            'searchKeyWord': getInputkeyWord,
            'additionalAttributes': component.get("v.additionalParams"),
            'ObjectName': component.get("v.objectAPIName"),
            'caseId': component.get("v.selectedRecordId"),
            'formType': component.get("v.formType")
        });
        // set a callBack    
        action.setCallback(this, function (response) {
            $A.util.removeClass(component.find("mySpinner"), "slds-show");
            $A.util.addClass(component.find("mySpinner"), "slds-hide");
            var state = response.getState();
            if (state === "SUCCESS") {
                var storeResponse = response.getReturnValue();
                // if storeResponse size is equal 0 ,display No Result Found... message on screen.                }
                if (storeResponse.length == 0) {
                    component.set("v.Message", 'No Result Found...');
                } else {
                    component.set("v.Message", '');
                }
                // set searchResult list with return value from server.
                component.set("v.listOfSearchRecords", storeResponse);
            }

        });
        // enqueue the Action  
        $A.enqueueAction(action);

    },
})