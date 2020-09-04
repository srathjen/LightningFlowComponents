({
    doInit: function(cmp) {
        var recordId = cmp.get('v.recordId');

        if (recordId == null) {
            return;
        }

        if (recordId.length == 15 || recordId.length == 18) {
            var sObjectAPIName = cmp.get('v.sObjectAPIName');
            var fieldsToReturn = cmp.get('v.fieldsToReturn');
            var formattedOutput = cmp.get('v.formattedOutput');

            // Create an Apex action
            var action = cmp.get('c.loadObjectDescription');

            // Set the parameters
            action.setParams({
                "recordId": recordId,
                "sObjectAPIName": sObjectAPIName,
                "fieldsToReturn": fieldsToReturn,
                "formattedOutput": formattedOutput
            });

            // Define the callback
            action.setCallback(this, function(response) {
                var state = response.getState();
                // Callback succeeded
                if (state === "SUCCESS") {
                    var result = response.getReturnValue();

                    // Error checking
                    if (result.indexOf('406!!ERROR') !== -1) {
                        // error
                        console.error('406');
                        this.setToast('406 Error');
                    } else if (result.indexOf('ERROR') !== -1) {
                        // error
                        console.error('error');
                        this.setToast('Error');
                    } else if (result !== '[]') {
                        var match = JSON.parse(result);
                        cmp.set('v.searchString', match['Description']);
                    }

                } else if (state === "ERROR") {
                    // Handle any error by reporting it
                    var errors = response.getError();

                    if (errors) {

                        if (errors[0] && errors[0].message) {
                            this.displayToast('Error', errors[0].message);
                        }

                    } else {
                        this.displayToast('Error', 'Unknown error.');
                    }
                }
            });

            // Enqueue the action
            $A.enqueueAction(action);
        }
    },

    /**
     * Handle the Selection of an Item
     */
    handleSelection: function(cmp, event) {
        // Populate record id (used for binding to a parent component)
        cmp.set('v.recordId', event.getParam('recordId'));
        // Populate input with record name
        cmp.set('v.searchString', event.getParam('recordName'));
        // Hide the lookup list
        this.showLookupList(cmp, false);
    },

    /**
     * Perform the SObject search via an Apex Controller
     */
    doSearch: function(cmp) {
        cmp.set('v.recordId', null);

        // Get the search string, input element and the selection container
        var searchString = cmp.get('v.searchString');

        // Get the filter string, input element and the selection container
        var filter = cmp.get('v.filter');

        // We need at least 2 characters for an effective search
        if (typeof searchString === 'undefined' || searchString.length < 2) {
            // Hide the listbox
            $A.util.removeClass(cmp.find('lookup-div'), 'slds-is-open');
            $A.util.addClass(cmp.find('lookup-div'), 'slds-combobox-lookup');
            return;
        }

        // Show the lookup list
        this.showLookupList(cmp, true);

        var sObjectAPIName = cmp.get('v.sObjectAPIName');
        var fieldsToReturn = cmp.get('v.fieldsToReturn');
        var formattedOutput = cmp.get('v.formattedOutput');
        var isExternalLookup = cmp.get('v.isExternalLookup');

        // Create an Apex action
        var action = cmp.get('c.lookup');

        // Mark the action as abortable, this is to prevent multiple events from the keyup executing
        action.setAbortable();

        // Set the parameters
        action.setParams({
            "searchString": searchString,
            "sObjectAPIName": sObjectAPIName,
            "fieldsToReturn": fieldsToReturn,
            "formattedOutput": formattedOutput,
            "filter": filter,
            "isExternalLookup": isExternalLookup
        });

        // Define the callback
        action.setCallback(this, function(response) {
            var state = response.getState();
            // Callback succeeded
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                // Error checking
                if (result.indexOf('406!!ERROR') !== -1) {
                    // error
                    console.error('406');
                    this.setToast('406 Error');
                } else if (result.indexOf('ERROR') !== -1) {
                    // error
                    console.error('error');
                    this.setToast('Error');
                } else if (result !== '[]') {
                    // results returned
                    var matches = JSON.parse(result);
                    cmp.set('v.matches', matches);
                } else {
                    cmp.set('v.matches', null);
                    return;
                }
            } else if (state === "ERROR") {
                // Handle any error by reporting it 
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        this.displayToast('Error', errors[0].message);
                    }
                } else {
                    this.displayToast('Error', 'Unknown error.');
                }
            }
        });
        // Enqueue the action
        $A.enqueueAction(action);
    },

    /**
     * Show/hide the listbox div (lookup list)
     */
    showLookupList: function(cmp, doShow) {
        if (doShow) {
            // Reveal the listbox
            $A.util.addClass(cmp.find('lookup-div'), 'slds-is-open');
            $A.util.removeClass(cmp.find('lookup-div'), 'slds-combobox-lookup');
        } else {
            // Hide the listbox
            $A.util.removeClass(cmp.find('lookup-div'), 'slds-is-open');
            $A.util.addClass(cmp.find('lookup-div'), 'slds-combobox-lookup');
        }
    },

    /**
     * Display a message
     */
    displayToast: function(title, message) {
        var toast = $A.get("e.force:showToast");
        // For lightning1 show the toast
        if (toast) {
            //fire the toast event in Salesforce1
            toast.setParams({
                "title": title,
                "message": message
            });
            toast.fire();
        } else // otherwise throw an alert
        {
            alert(title + ': ' + message);
        }
    }
});