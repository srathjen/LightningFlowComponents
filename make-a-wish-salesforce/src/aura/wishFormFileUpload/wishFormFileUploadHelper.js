({
    MAX_FILE_SIZE: 4500000, // Max file size 4.5 MB
    CHUNK_SIZE: 750000,     // Chunk Max size 750Kb

    uploadHelper: function (component, event, helper) {
        // Show the loading spinner
        component.set("v.showLoadingSpinner", true);
        // Get the selected files using aura:id [return array of files]
        // var fileInput = component.find("fileId").get("v.files");
        var files = component.get("v.files");
        var file = files[0][0];
        // Get the first file using array index[0]
        var self = this;
        // Check the selected file size, if select file size greater then MAX_FILE_SIZE,
        // then show a alert msg to user,hide the loading spinner and return from function
        if (file.size > self.MAX_FILE_SIZE) {
            component.set('v.showLoadingSpinner', false);
            var formattedMaxFileSize = this.formatBytes(this.MAX_FILE_SIZE, 0);
            var formattedFileSize = this.formatBytes(file.size, 0);
            component.set('v.toastMessage', 'File size cannot exceed '
                + formattedMaxFileSize + '.\n'
                + ' Selected file size: ' + formattedFileSize);
            component.set('v.toastMessageType', 'error');
            var fileName = $A.get("$Label.c.Wish_Form_No_File_Selected");
            component.set("v.fileName", fileName);
            component.set("v.files", null);
            component.set('v.showToast', true);
            event.preventDefault();
        } else {
            // Create a FileReader object
            var objFileReader = new FileReader();
            // Set onload function of FileReader object
            objFileReader.onload = $A.getCallback(function () {
                var fileContents = objFileReader.result;
                var base64 = 'base64,';
                var dataStart = fileContents.indexOf(base64) + base64.length;
                fileContents = fileContents.substring(dataStart);
                // Call the uploadProcess method
                self.uploadProcess(component, file, fileContents, helper);
            });
            objFileReader.readAsDataURL(file);
            event.preventDefault();
        }
    },

    formatBytes: function (bytes) {
        var neg = bytes < 0;
        var units = ['B', 'KB', 'MB', 'GB', 'TB', 'PB', 'EB', 'ZB', 'YB'];
        if (neg) {
            bytes = -bytes;
        }
        if (bytes < 1) {
            return (neg ? '-' : '') + bytes + ' B';
        }
        var exponent = Math.min(Math.floor(Math.log(bytes) / Math.log(1000)), units.length - 1);
        bytes = Number((bytes / Math.pow(1000, exponent)).toFixed(2));
        var unit = units[exponent];
        return (neg ? '-' : '') + bytes + ' ' + unit;
    },

    uploadProcess: function (component, file, fileContents, helper) {
        // Set a default size or startpostiton as 0
        var startPosition = 0;
        // Calculate the end size or endPostion using Math.min() function which is return the min. value
        var endPosition = Math.min(fileContents.length, startPosition + this.CHUNK_SIZE);
        // Start with the initial chunk, and set the attachId(last parameter)is null in begin
        this.uploadInChunk(component, file, fileContents, startPosition, endPosition, '', helper);
    },

    uploadInChunk: function (component, file, fileContents, startPosition, endPosition, attachId, helper, description) {
        // Call the apex method 'saveChunk'
        var getChunk = fileContents.substring(startPosition, endPosition);
        var action = component.get("c.saveChunk");
        action.setParams({
            parentId: component.get("v.parentId"),
            fileName: file.name,
            base64Data: encodeURIComponent(getChunk),
            contentType: file.type,
            fileId: attachId,
            // Set the file description equal to what the user entered
            description: component.find("fileDescription").get("v.value"),
        });
        // set call back
        action.setCallback(this, function (response) {
            // Store the response / Attachment Id
            attachId = response.getReturnValue();
            var state = response.getState();
            if (state === "SUCCESS") {
                // Update the start position with end postion
                startPosition = endPosition;
                endPosition = Math.min(fileContents.length, startPosition + this.CHUNK_SIZE);
                // check if the start postion is still less then end postion
                // then call again 'uploadInChunk' method,
                // else, display alert msg and hide the loading spinner
                if (startPosition < endPosition) {
                    this.uploadInChunk(component, file, fileContents, startPosition, endPosition, attachId);
                } else {
                    var existingFiles = component.get("v.fileList");
                    existingFiles.push(file.name + ' - ' +  component.get("v.fileDescriptionNew"));
                    component.set("v.fileList", existingFiles);
                    component.set("v.showLoadingSpinner", false);
                    var fileName = $A.get("$Label.c.Wish_Form_No_File_Selected");
                    component.set("v.fileName", fileName);
                    component.set("v.description", '');
                    component.set("v.fileDescriptionNew", '');
                    component.set("v.isButtonActive", true);
                    component.set('v.toastMessage', 'File Uploaded');
                    component.set('v.toastMessageType', 'success');
                    component.set('v.showToast', true);

                }
                // Handle the response errors
            } else if (state === "INCOMPLETE") {
                component.set('v.toastMessage', response.getReturnValue());
                component.set('v.toastMessageType', 'error');
                component.set('v.showToast', true);
            } else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        component.set('v.toastMessage', "Error message: " + errors[0].message);
                        component.set('v.toastMessageType', 'error');
                        component.set('v.showToast', true);
                    }
                } else {
                    component.set('v.toastMessage', 'There was an error, please contact your administrator');
                    component.set('v.toastMessageType', 'error');
                    component.set('v.showToast', true);
                }
            }
        });
        // enqueue the action
        $A.enqueueAction(action);
    }
});