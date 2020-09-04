/**
 * Created by gmayer on 26-Aug-20.
 */

({
    handleLookupSelectedEvent: function (component, event) {
        if (event.getParam("recordId")) {
            let externalLookupEvent = $A.get("e.c:ExternalLookupEvent");
            externalLookupEvent.setParams({
                EventData: {
                    lookupId: event.getParam("lookupId"),
                    recordId: event.getParam("recordId"),
                    eventType: "select"
                }
            });
            externalLookupEvent.fire();
        }
    },

    handleLookupClearedEvent: function (component, event) {
        let externalLookupEvent = $A.get("e.c:ExternalLookupEvent");
        externalLookupEvent.setParams({
            EventData: {
                lookupId: event.getParam("lookupId"),
                eventType: "clear"
            }
        });
        externalLookupEvent.fire();
    }
});