({
    handleChangeSigner: function (cmp, event, helper) {
        helper.changeSigner(cmp, event);
    },
    
    doInit: function(cmp, event, helper) {
        cmp.find("changeSignerModal").open();
    },
    
    handleChangeSignerCancel: function (cmp, event, helper) {
        let componentName = cmp.getType();
        componentName = componentName.substring(componentName.indexOf(":") + 1, componentName.length);
        var cmpEvent = cmp.getEvent("refreshEvent");
        cmpEvent.setParams({
            "isRefresh" : true,
            "childCmp" : componentName
        });
        cmpEvent.fire();
    },
    
    fetchWishAff: function (cmp, event, helper) {
        helper.getWishAffiliation(cmp, event);
    }
})