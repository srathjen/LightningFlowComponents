({
    doInit : function(cmp, event, helper) {
        helper.doInit(cmp);
    },
    // Placeholder action just to fire Clear Event
    clear : function(cmp, event, helper) {
    },
    // Handle selection from child component
    select : function(cmp, event, helper) {
        helper.handleSelection(cmp, event);
    },
    // Search an SObject for matches
    search : function(cmp, event, helper) {
        let lookupId = cmp.get('v.lookupId');
        let clearEvent = cmp.getEvent('lookupSObjectClear');
        clearEvent.setParams({
            'lookupId': lookupId
        });
        helper.doSearch(cmp);
        clearEvent.fire();
    },
    // Hide lookup list when focus is lost
    blur : function(cmp, event, helper) {
        setTimeout(
            $A.getCallback(function() {
                // This will be an asynchronous call, so we have to test component validity
                if (cmp.isValid()) {
                    helper.showLookupList(cmp, false);
                }
            }), 1000
        );
    }
});