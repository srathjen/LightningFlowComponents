({
    
    getAttachmentList : function(component,event,helper) {
        var self = this;
        var actionName = "c.attachmentLists";
        var actions = [
            { label: 'Download', name: 'download' },
            { label: 'Delete', name: 'delete' }
        ];
        
        // callback binding
        var taskColumns = [
            {type:  'action', typeAttributes: { rowActions: actions } },
            {label: 'File Name', fieldName: 'AttachmentId__c', type: 'text'}
        ];
        
        var params = {"currentPageId" : component.get("v.recordId")};
        self.callAction(component, actionName, params, function(response){
            //pass the records to be displayed
            if(response != 'error') {
                //pass the column information
                component.set("v.democolumns",taskColumns);
                component.set("v.demodata",response);
            }
        });                     
    },
    
    removeAttachment : function(component,event,helper,attachmentId) {
        component.set('v.showComponent', false);
        var self = this;
        var actionName = "c.removeAttachment";
        var params = {
            "currentPageId" : component.get("v.recordId"),
            "attachmentId" : attachmentId
        };	
        self.callAction(component, actionName, params, function(response){
            //pass the records to be displayed
            if(response == 'success') {
                //pass the column information
                commonJS.deleteStorage();

                commonJS.ShowSuccessMsg('Your File has been deleted successfully.');
                commonJS.clearIntervalMessage();
                var appEvent = $A.get("e.c:FormTrackerAttachment_LE");
        appEvent.setParams({
            "notifymessage" : "remove" });
        appEvent.fire(); 
                //helper.getAttachmentList(component, event, helper);
            }
        });                     
    },
    
    refreshAttachment: function(component,event,helper){
        helper.getAttachmentList(component, event, helper);
    },
    
    navigateToDashboard: function(component,event,helper){
        window.location.href = '/apex/wishFormDashboard_VF?Id='+component.get("v.recordId");
    },
    
    
    downloadAttachment : function(component,event,helper,attachment) {
        var self = this;
        var actionName = "c.attachmentLists";
        var params = {"currentPageId" : component.get("v.recordId")};
        
        self.callAction(component, actionName, params, function(response){
            //pass the records to be displayed
            if(response != 'error') {
                debugger;
                 window.open(response[0].File_Path__c,'_blank'); 
            }
        });                       
    },
    
    callAction: function(component, actionName, params, callback){        
        var action = component.get(actionName);
        action.setParams(params);
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                callback(response.getReturnValue());                
            }else{
                callback('error'); 
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Failure!",
                    "message": "Failed to process data",
                    "type": "error"
                });
                toastEvent.fire();
            }
        });
        $A.enqueueAction(action);
    },
})