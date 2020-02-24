({

    getDataCase: function (component, event) {
        var action = component.get("c.getWish");
        action.setParams({
            caseId: component.get("v.caseId"),
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === 'SUCCESS') {
                component.set('v.wish', response.getReturnValue());
            } else if (state === 'ERROR') {
                this.handleErrors(response.getError());
            }
        });
        $A.enqueueAction(action);
    },


    getFilePath: function (component, event, rowId) {
        var action = component.get("c.getWishFilePath");
        action.setParams({
            wrsId: rowId
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === 'SUCCESS') {
                let filePath = response.getReturnValue().File_Path__c;
                if ($A.util.isEmpty(filePath)) {
                    let errList = [];
                    let err = {message: "No document found"};
                    errList.push(err);
                    this.handleErrors(errList);
                } else {
                    window.location.href = filePath;
                }

            } else if (state === 'ERROR') {
                this.handleErrors(response.getError());
            }
        });
        $A.enqueueAction(action);
    },

    getDataHelper: function (component, event) {
        component.set("v.Spinner", true);
        var action = component.get("c.getRecords");
        //Set the Object parameters and Field Set name
        action.setParams({
            strObjectName: component.get("v.objectName"),
            strFieldSetName: component.get("v.fieldsetName"),
            strTypeOfSignature: component.get("v.typeOfSignature"),
            caseRecordId: component.get("v.caseId"),
            showVoid: component.get("v.showVoidedForms")
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === 'SUCCESS') {
                component.set("v.Spinner", false);
                var actions = this.getRowActions.bind(this, component);

                //Iterate on Table Columns to make them click-able
                response.getReturnValue().lstDataTableColumns.forEach(function (column) {
                    column.sortable = true;
                    switch (column.fieldName) {
                        case 'Wish_Case__c':
                            column.type = 'String';
                            column.label = 'On Behalf Of';
                            column.fieldName = 'OnBehalfOf';
                            break;
                        case 'Signed_Date__c':
                            column.type = 'date-local';
                            column.label = 'Signed Date';
                            break;
                        case 'Sent_Date__c':
                            column.type = 'date-local';
                            column.label = 'Sent Date';
                            break;
                        case 'Wish_Signature_Form__r.Name':
                            column.type = 'text';
                            column.label = 'Form Name';
                            column.fieldName = 'SignatureFormName';
                            break;
                        case 'Wish_Affiliation__r.Contact__c':
                            column.type = 'url';
                            column.label = 'Signer';
                            column.fieldName = 'SignerName';
                            column['typeAttributes'] = {label: {fieldName: 'SignerParentName'}, target: '_self'};
                            break;
                        default:
                            break;
                    }
                });
                //Adding Actions Column in the end
                let column = {};
                column["label"] = '';
                column["type"] = 'action';
                column['typeAttributes'] = {rowActions: actions};
                response.getReturnValue().lstDataTableColumns.push(column);
                component.set("v.mycolumns", response.getReturnValue().lstDataTableColumns);

                //Iterate on Table Rows to make modifications
                var rows = response.getReturnValue().lstDataTableData;
                for (var i = 0; i < rows.length; i++) {
                    //var row = rows[i];
                    if (!$A.util.isEmpty(rows[i].Wish_Signature_Form__r)) {
                        rows[i].SignatureFormName = rows[i].Wish_Signature_Form__r.Name;
                    }
                    if (!$A.util.isEmpty(rows[i].Wish_Affiliation__r) && !$A.util.isEmpty(rows[i].Wish_Affiliation__r.Contact__r)) {
                        rows[i].SignerParentName = rows[i].Wish_Affiliation__r.Contact__r.Name;
                        rows[i].SignerName = '/' + rows[i].Wish_Affiliation__r.Contact__c;
                    }
                    if (rows[i].Guardian_Signatures__r) {
                        var guardians = rows[i].Guardian_Signatures__r;
                        var guards = [];
                        for (var guardian in guardians) {
                            if (!$A.util.isEmpty(guardians[guardian].Signing_on_Behalf_Of__r) && !$A.util.isEmpty(guardians[guardian].Signing_on_Behalf_Of__r.Contact__r)) {
                                guards.push(guardians[guardian].Signing_on_Behalf_Of__r.Contact__r.Name);
                            }
                        }
                        rows[i].OnBehalfOf = guards.join(',');
                    }
                }
                component.set("v.mydata", rows);
            } else if (state === 'ERROR') {
                this.handleErrors(response.getError());
            }
        });
        $A.enqueueAction(action);
    },

    //Sorting Functions Begin
    sortData: function (cmp, fieldName, sortDirection) {
        var data = cmp.get("v.mydata");
        var reverse = sortDirection !== 'asc';
        if (fieldName == 'SignatureFormName') {
            fieldName = 'Wish_Signature_Form__r.Name';
            this.sortByParent(cmp, fieldName, reverse);
        } else if (fieldName == 'SignerName') {
            fieldName = 'Wish_Affiliation__r.Contact__r.Name';
            this.sortByParent(cmp, fieldName, reverse);
        } else {
            data.sort(this.sortBy(fieldName, reverse))
            cmp.set("v.mydata", data);
        }
    },

    sortBy: function (field, reverse, primer) {
        var key = primer ?
            function (x) {
                return primer(x.hasOwnProperty(field) ? (typeof x[field] === 'string' ? x[field].toLowerCase() : x[field]) : 'aaa')
            } :
            function (x) {
                return x.hasOwnProperty(field) ? (typeof x[field] === 'string' ? x[field].toLowerCase() : x[field]) : 'aaa'
            };
        reverse = !reverse ? 1 : -1;
        return function (a, b) {
            return a = key(a), b = key(b), reverse * ((a > b) - (b > a));
        }
    },

    sortByParent: function (component, field, reverse) {
        var sortField = field,
            records = component.get("v.mydata"),
            fieldPath = field.split(/\./),
            fieldValue = this.fieldValue;

        records.sort(function (a, b) {
            var aValue = fieldValue(a, fieldPath),
                bValue = fieldValue(b, fieldPath),
                t1 = aValue == bValue,
                t2 = (!aValue && bValue) || (aValue < bValue);
            return t1 ? 0 : (!reverse ? -1 : 1) * (t2 ? 1 : -1);
        });
        component.set("v.mydata", records);
    },

    fieldValue: function (object, fieldPath) {
        var result = object;
        fieldPath.forEach(function (field) {
            if (result) {
                result = result[field];
            }
        });
        return result;
    },
    //Sorting Functions End

    getRowActions: function (cmp, row, doneCallback) {
        var status = row.Status__c;
        var showSignature = ['Not Sent', 'Sent', 'Completed', 'Delivered', 'Delivery Failure', 'Declined', 'Not Sent - Pending']
        var actions = [];
        actions.push(
            {'label': 'View Details', 'name': 'view_details'},
            {'label': 'Delete', 'name': 'delete'},
            {'label': 'Print for Offline', 'name': 'print_offline'},
            {'label': 'View Document', 'name': 'view'});

        if (status == 'Not Sent') {
            actions.push(
                {'label': 'Change Form', 'name': 'change_form'},
                {'label': 'Change Signer', 'name': 'change_signer'});
        }

        if (showSignature.includes(status)) {
            actions.push(
                {'label': 'E-Signature Actions', 'name': 'send_signature'},
                {'label': 'Upload Signed Copy', 'name': 'upload_copy'});
        }

        // simulate a trip to the server
        setTimeout($A.getCallback(function () {
            doneCallback(actions);
        }), 200);
    },

    handleErrors: function (errors) {
        // Configure error toast
        let toastParams = {
            title: "Error",
            message: "Unknown error", // Default error message
            type: "error"
        };
        // Pass the error message if any
        if (errors && Array.isArray(errors) && errors.length > 0) {
            toastParams.message = errors[0].message;
        }
        // Fire error toast
        let toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams(toastParams);
        toastEvent.fire();
    },
})