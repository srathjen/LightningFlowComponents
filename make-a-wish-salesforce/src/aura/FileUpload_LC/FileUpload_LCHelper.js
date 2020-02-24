/*
 * Date : 06/28/2018
 * Locker Service Ready code.
 */
({
    MAX_FILE_SIZE: 4500000, //Max file size 4.5 MB 
    CHUNK_SIZE: 4500000,      //Chunk Max size 4.5 MB 
    
    uploadHelper: function(component, event, helper) {
        // start/show the loading spinner   
        component.set("v.showLoadingSpinner", true);
        // get the selected files using aura:id [return array of files]
        var fileInput = component.find("fileId").get("v.files");
        // get the first file using array index[0]  
        var file = fileInput[0];
        var self = this;
        // check the selected file size, if select file size greter then MAX_FILE_SIZE,
        // then show a alert msg to user,hide the loading spinner and return from function  
        if (file.size > self.MAX_FILE_SIZE) {
            component.set("v.showLoadingSpinner", false);
            component.set("v.fileName", 'Alert : File size cannot exceed ' + self.MAX_FILE_SIZE + ' bytes.\n' + ' Selected file size: ' + file.size);
            return;
        }
        
        // create a FileReader object 
        var objFileReader = new FileReader();
        // set onload function of FileReader object   
        objFileReader.onload = $A.getCallback(function() {
            var fileContents = objFileReader.result;
            var base64 = 'base64,';
            var dataStart = fileContents.indexOf(base64) + base64.length;
            
            fileContents = fileContents.substring(dataStart);
            // call the uploadProcess method 
            self.uploadProcess(component, file, fileContents,event, helper);
        });
        
        objFileReader.readAsDataURL(file);
    },
    
    uploadProcess: function(component, file, fileContents,event, helper) {
        // set a default size or startpostiton as 0 
        var startPosition = 0;
        // calculate the end size or endPostion using Math.min() function which is return the min. value   
        var endPosition = Math.min(fileContents.length, startPosition + this.CHUNK_SIZE);
        
        // start with the initial chunk, and set the attachId(last parameter)is null in begin
        this.uploadInChunk(component, file, fileContents, startPosition, endPosition, '',event, helper);
    },
    
    
    uploadInChunk: function(component, file, fileContents, startPosition, endPosition, attachId,event, helper) {
        // call the apex method 'saveChunk'
        var getchunk = fileContents.substring(startPosition, endPosition);
        var action = component.get("c.saveFileAttachment");
        var pageSrc = component.get("v.queryParams").pageSrc;
        var paramObj = {
                "parentId": component.get("v.parentId"),
                "fileName": file.name,
                "base64Data": encodeURIComponent(getchunk),
                "contentType": file.type,
                "fileId": attachId,
                "currentpageName" : component.get("v.queryParams").currentpageName,
                "MinorparticipantName" : component.get("v.queryParams").MinorparticipantName,
                "MinorparticipantEmail" : component.get("v.queryParams").MinorparticipantEmail,
                "FormName" : component.get("v.queryParams").FormName,
                "documentTitle" : component.get("v.queryParams").documentTitle,
                "associated" : component.get("v.queryParams").associated,
                "selectedFormat" : component.get("v.queryParams").selectedFormat,
                "recordId": component.get("v.queryParams").recordId,
                "pageSrc" : component.get("v.queryParams").pageSrc
        };

       if(pageSrc == 'upload'){
            paramObj.minorparticipantrecId = component.get("v.queryParams").minorparticipantrecId;
        }   
      
        var params = {
            config : JSON.stringify(paramObj)
        }
      
        action.setParams(params);
       
        // set call back 
        action.setCallback(this, function(response) {
            // store the response / Attachment Id   
            attachId = response.getReturnValue();
            var state = response.getState();
            if (state === "SUCCESS") {
                // update the start position with end postion
                startPosition = endPosition;
                endPosition = Math.min(fileContents.length, startPosition + this.CHUNK_SIZE);
                // check if the start postion is still less then end postion 
                // then call again 'uploadInChunk' method , 
                // else, diaply alert msg and hide the loading spinner
                if (startPosition < endPosition) {
                    this.uploadInChunk(component, file, fileContents, startPosition, endPosition, attachId);
                } else {
                   
                    component.set("v.fileName", 'No File Selected..');
                    commonJS.ShowSuccessMsg('Your File has been uploaded successfully. This process can take some time to complete the synchronization with S-Drive. Please click the attachment icon below to see the recently uploaded files.');
                    commonJS.clearIntervalMessage(2500);
                     window.setTimeout(helper.refreshComponent(component, event, helper),4000);
                    //commonJS.setCookie('counter');
                    component.set("v.showNav", true);
                    component.set("v.isUploaded", true);
                    component.set("v.showLoadingSpinner", false);
                    
                }
                // handel the response errors        
            } else if (state === "INCOMPLETE") {
                alert("From server: " + response.getReturnValue());
            } else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });
        // enqueue the action
        $A.enqueueAction(action);
    },
    
    refreshComponent: function(component, event, helper) {
        var appEvent = $A.get("e.c:FormTrackerAttachment_LE");
        appEvent.setParams({
            "notifymessage" : "fileupload" });
        appEvent.fire(); 
    },
    
    syncAttachment: function(component, event, helper) {
        var action = component.get("c.syncFileAttachment"),
            params = {
                currentPageId:  component.get("v.queryParams").recordId
            };
        action.setParams(params);
        // set call back 
        action.setCallback(this, function(response) {
            // store the response / Attachment Id   
            var result = response.getReturnValue();
            var state = response.getState();
            if (state === "SUCCESS") {
                if(result == 'success'){
                    commonJS.ShowSuccessMsg('Your file sync successfully with S-Drive');
                    commonJS.clearIntervalMessage(4500);
                }
                // handel the response errors        
            } else if (state === "INCOMPLETE") {
                alert("From server: " + response.getReturnValue());
            } else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });
        // enqueue the action
        $A.enqueueAction(action);
    },
    
    showErrorToast : function(component, event, helper) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title : 'Error Message',
            message:'Mode is pester ,duration is 5sec and Message is not overrriden because messageTemplateData is not specified',
            messageTemplate: 'Mode is pester ,duration is 5sec and Message is overrriden',
            duration:' 5000',
            key: 'info_alt',
            type: 'error',
            mode: 'pester'
        });
        toastEvent.fire();
    },
    
    checkUpload: function(component, event, helper){
        if(event.getParam("notifymessage") != 'remove' && event.getParam("notifymessage") != undefined){
            component.set("v.isUploaded", true);
            component.set("v.showNav", true);
        }else{
            component.set("v.isUploaded", false);  
            component.set("v.showNav", false);
        }
    },

    openModal: function(component, event, helper) {
        var modalId = event.target.getAttribute("data-label");
        component.find(modalId).open();
    }
})