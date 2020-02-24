({
    doInit : function(cmp, event, helper) {	
        cmp.find("uploadFileModal").open();
        cmp.set('v.uploadSpinner', true);
    },
    
    handleLoad: function(cmp, event, helper) {
        cmp.set('v.uploadSpinner', false);
    },
    
    handleFileUploadCancel: function (cmp, event, helper) {
        let componentName = cmp.getType();
        componentName = componentName.substring(componentName.indexOf(":") + 1, componentName.length);
        var cmpEvent = cmp.getEvent("refreshEvent");
        cmpEvent.setParams({
            "isRefresh" : true,
            "childCmp" : componentName
        });
        cmpEvent.fire();
    },
    
    handleUploadFile: function (cmp, event, helper) {
        var child = cmp.find("fileUpload");
        child.handleSaveFromParentMethod(cmp.get("v.wishReqSignRecord"));
    },
    
})