({
    doInit: function (component, event, helper) {
        helper.getDataCase(component, event);
        helper.getDataHelper(component, event);
    },

    handleRefresh: function (component, event, helper) {
        let compParam = event.getParam("childCmp");
        if (compParam == 'DeleteWishSignatures') {
            component.set("v.showDeleteModal", false);
        } else if (compParam == 'ChangeForm') {
            component.set("v.showChangeFormModal", false);
        } else if (compParam == 'ChangeSigner') {
            component.set("v.showChangeSignerModal", false);
        } else if (compParam == 'UploadSignedCopy') {
            component.set("v.showUploadFileModal", false);
        } else if (compParam == 'SendForSignature') {
            component.set("v.showESendSignModal", false);
        } else if (compParam == 'PrintForOffline') {
            component.set("v.showPrintOfflineModal", false);
        } else if (compParam == 'FileUpload') {
            component.set("v.showUploadFileModal", false);
            //component.set("v.showESendSignModal", false);
        }
        let action = component.get("c.doInit");
        $A.enqueueAction(action);
    },

    updateColumnSorting: function (cmp, event, helper) {
        var fieldName = event.getParam('fieldName');
        var sortDirection = event.getParam('sortDirection');
        cmp.set("v.sortedBy", fieldName);
        cmp.set("v.sortedDirection", sortDirection);
        helper.sortData(cmp, fieldName, sortDirection);
    },


    handleError: function (cmp, event, helper) {
        helper.handleErrors(cmp.get("v.errors"));
    },

    handleRowAction: function (cmp, event, helper) {
        var action = event.getParam('action');
        var row = event.getParam('row');

        switch (action.name) {
            case 'view_details':
                var workspaceAPI = cmp.find("workspace");
                workspaceAPI.isConsoleNavigation().then(function (response) {
                    console.log('Isconsole' + response);
                    if (response) {
                        cmp.set("v.rowId", row.Id);
                        //var workspaceAPI = cmp.find("workspace");
                        var caseRecordId = cmp.get('v.caseId');
                        var wishSignatureRecordId = cmp.get('v.rowId');
                        var urlCase = '/lightning/r/Case/' + caseRecordId + '/view';
                        var urlWishSiganture = '/lightning/r/Wish_Required_Signature__c/' + wishSignatureRecordId + '/view';
                        workspaceAPI.openTab({
                            url: urlCase,
                            focus: true
                        }).then(function (response) {
                            workspaceAPI.openSubtab({
                                parentTabId: response,
                                url: urlWishSiganture,
                                focus: true
                            });
                        }).catch(function (error) {
                            console.log(error);
                        });
                    } else {
                        window.open(window.location.origin + '/' + row.Id);
                    }
                })
                break;
            case 'view':
                helper.getFilePath(cmp, event, row.Id);
                break;
            case 'delete':
                cmp.set("v.rowId", row.Id);
                cmp.set("v.showDeleteModal", true);
                break;
            case 'change_form':
                cmp.set("v.rowId", row.Id);
                cmp.set("v.showChangeFormModal", true);
                break;
            case 'change_signer':
                cmp.set("v.rowId", row.Id);
                cmp.set("v.showChangeSignerModal", true);
                break;
            case 'upload_copy':
                cmp.set("v.uploadSpinner", true);
                cmp.set("v.showUploadFileModal", true);
                cmp.set("v.rowId", row.Id);
                cmp.set("v.wishReqSignRecord.Id", row.Id);
                cmp.set("v.wishReqSignRecord.Status__c", 'Completed');
                var today = new Date();
                var dd = String(today.getDate()).padStart(2, '0');
                var mm = String(today.getMonth() + 1).padStart(2, '0'); //January is 0!
                var yyyy = today.getFullYear();
                today = yyyy + '-' + mm + '-' + dd;
                cmp.set("v.wishReqSignRecord.Signed_Date__c", today);
                break;
            case 'send_signature':
                cmp.set("v.rowId", row.Id);
                cmp.set("v.rowStatus", row.Status__c);
                cmp.set("v.wishReqSignRecord", row);
                cmp.set("v.showESendSignModal", true);
                break;
            case 'print_offline':
                cmp.set("v.rowId", row.Id);
                cmp.set("v.showPrintOfflineModal", true);
                break;
        }
    },
})