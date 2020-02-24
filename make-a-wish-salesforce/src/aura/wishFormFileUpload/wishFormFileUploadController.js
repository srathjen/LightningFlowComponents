({
    doSave: function (component, event, helper) {
        if (component.find("fileId").get("v.files").length > 0) {
            helper.uploadHelper(component, event);
        }
    },

    handleFilesChange: function (component) {
        component.set("v.toastMessage", "");
        component.set("v.toastMessageType", "");
        component.set('v.showToast', false);
        var fileName = $A.get("$Label.c.Wish_Form_No_File_Selected"); 
        var files = component.get("v.files");
        if (files && files.length > 0) {
            var file = files[0][0];
            fileName = file.name;
            component.set("v.isButtonActive", false);
        }
        component.set("v.fileName", fileName);

    },

    descriptionUpdate: function (component) {
        var description = component.get("v.fileDescriptionNew");
        component.set("v.description", description);
    },

    closeToast: function (component) {
        $A.util.addClass(component.find('toastModel'), 'slds-hide');
        component.set("v.toastMessage", "");
        component.set("v.toastMessageType", "");
        component.set('v.showToast', false);
    },

    handleCustomToastCloseEvent: function (component) {
        component.set("v.toastMessage", "");
        component.set("v.toastMessageType", "");
        component.set('v.showToast', false);
    }
});