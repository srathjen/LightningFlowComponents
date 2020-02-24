/*
 * Date : 06/28/2018
 * Locker Service Ready code.
 */
({
    init: function(component, event, helper) {
        helper.checkUpload(component, event, helper);
    },
    doSave: function(component, event, helper) {
        if (component.find("fileId").get("v.files").length > 0) {
            component.set("v.isButtonclicked",true);
            helper.uploadHelper(component, event, helper);
        } else {
            alert('Please Select a Valid File');
        }
    },
    
  
    
    handleFilesChange: function(component, event, helper) {
        var fileName = 'No File Selected..';
        if (event.getSource().get("v.files").length > 0) {
            fileName = event.getSource().get("v.files")[0]['name'];
        }
        component.set("v.fileName", fileName);
    },
    
    navigateToTraker: function(component, event, helper) {
        //helper.syncAttachment(component, event, helper);
        var isExistFileName = component.find("fileId").get("v.files");
        if(!component.get("v.isButtonclicked") && isExistFileName != null){
            helper.openModal(component, event, helper);
        }else{
              window.location.href = '/apex/wishFormDashboard_VF?id=' + component.get("v.parentId");
        }
    },
    
    refreshComponent: function(component, event, helper) {
        helper.refreshComponent(component, event, helper);
    },
    
    syncAttachment: function(component, event, helper) {
        helper.syncAttachment(component, event, helper);
    },
    
    handleApplicationEvent: function(component, event, helper) {
        helper.checkUpload(component, event, helper);
    },
})