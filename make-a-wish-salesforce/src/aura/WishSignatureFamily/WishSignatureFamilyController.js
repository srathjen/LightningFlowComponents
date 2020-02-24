({
    init: function (cmp, event, helper) {
        var action = cmp.get("c.getWishSignatureForms");
        action.setParams({
            "caseId" : cmp.get("v.recordId"),
            "formType" : 'Family'
        });
        action.setCallback(this, function(response){
            console.log(' response.getReturnValue() '+  response.getReturnValue());
            var state = response.getState();
            var returnList = [];
            if(state === 'SUCCESS'){
                response.getReturnValue().forEach(function (element) {
                    returnList.push({ value: element.Id, label: element.Name });
                });
                console.log('returnList '+ returnList);
                cmp.set('v.options', returnList);
            }
            else if(state === 'ERROR'){
                this.handleErrors(response.getError());
            }
        });
        $A.enqueueAction(action);
    },

    handleChange: function (cmp, event, helper) {
        var selectedOptionValue = event.getParam("value");
        cmp.set("v.selectedLookUpRecord", selectedOptionValue);
        console.log('selectedOptionValue '+selectedOptionValue);
    },
    handleClick: function (cmp, event, helper) {
        helper.getAffiliations(cmp,event);
        cmp.set("v.showModal",true);
        cmp.find("addFormModal").open();
        
    },
    
    handleSave: function (cmp, event, helper) {
        helper.saveWRSRecords(cmp, event);
    },
    
    handleCancel: function (cmp, event, helper) {
        cmp.set("v.adultList",null);
        cmp.set("v.adultChildMap",null);
        cmp.set("v.selectedLookUpRecord",null);
        cmp.set("v.showModal",false);
        cmp.find("addFormModal").close();
    },
    
    handleAdultCheck: function (cmp, event, helper) {
        helper.createSelectedAdultsList(cmp, event);
    },
    
    handleMinorCheck: function (cmp, event, helper) {
        helper.createSelectedMinorsList(cmp, event);
    },
    
    handleRefresh: function (cmp, event, helper) {
        var childCmp = cmp.find("familyDatatable")
        childCmp.refreshMethod();
    },
})