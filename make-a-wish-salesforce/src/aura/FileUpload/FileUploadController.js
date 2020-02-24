({    
    handleSave: function(component, event, helper) {
        if (!$A.util.isEmpty(component.find("fuploader")) 
            && !$A.util.isEmpty(component.find("fuploader").get("v.files"))
            && component.find("fuploader").get("v.files").length > 0) {
            helper.uploadHelper(component, event);
        } else {
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "type": "Error",
                "title": "Error!",
                "message": "Please Select a Valid File."
            });
            toastEvent.fire();
            return;
        }
    },
    
    handleFilesChange: function(component, event, helper) {
        var fileName = 'No File Selected..';
        if (event.getSource().get("v.files").length > 0) {
            fileName = event.getSource().get("v.files")[0]['name'];
        }
        component.set("v.fileName", fileName);
    },
    
    handleCancel: function(component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();
    },
})