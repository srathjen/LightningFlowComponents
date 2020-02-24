({
    doInit : function (cmp, event, helper) {
        cmp.find("PrintOfflineModal").open();
    },
    
    handlePrintCancel: function (cmp, event, helper) {
        let componentName = cmp.getType();
        componentName = componentName.substring(componentName.indexOf(":") + 1, componentName.length);
        var cmpEvent = cmp.getEvent("refreshEvent");
        cmpEvent.setParams({
            "isRefresh" : true,
            "childCmp" : componentName
        });
        cmpEvent.fire();
    },
    
    handlePrintOffline: function (cmp, event, helper) {
        helper.getDocgenDetails(cmp, event);
    }
})