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
        var lookupId = cmp.get('v.lookupId');
        var clearEvent = cmp.getEvent('lookupSObjectClear');
        clearEvent.setParams({
            'lookupId': lookupId
        });
        clearEvent.fire(); 
        helper.doSearch(cmp);
    },
    // Hide lookup list when focus is lost
    blur : function(cmp, event, helper) {
        setTimeout(
            $A.getCallback(function() {
                // This will be an asynchronous call, so we have to test component validity
                if (cmp.isValid()) {
                    helper.showLookupList(cmp, false);
                }
            }), 150
        );
    }
});