({
    //Fetch the accounts from the Apex controller
    getIntegrationsList: function(component) {

        var action = component.get("c.getIntegrations");
        action.setCallback(this, function(actionResult) {
            var jsonString = actionResult.getReturnValue();
            var jsonObjects = JSON.parse(jsonString);
            component.set("v.integrations", this.sortIntegrations(jsonObjects));

            var loadingRow = component.find('loadingRow').getElement();
            $A.util.addClass(loadingRow, 'hidden');

            var emptyRow = component.find('emptyRow').getElement();
            if (jsonObjects.length > 0) {
	            $A.util.addClass(emptyRow, 'hidden');
            } else {
	            $A.util.removeClass(emptyRow, 'hidden');
            }
        });
        $A.enqueueAction(action);
    },
    sortIntegrations : function(integrations) {
        var sorted = integrations.sort(function(a, b) {
            if (a.ServiceName.toLowerCase() < b.ServiceName.toLowerCase()) {
                return -1;
            } else if (a.ServiceName.toLowerCase() > b.ServiceName.toLowerCase()) {
                return 1;
            } else {
                if (a.Name.toLowerCase() < b.Name.toLowerCase()) {
                    return -1;
                } else if (a.Name.toLowerCase() > b.Name.toLowerCase()) {
                    return 1;
                } else {
                    return 0;
                }
            }
        });
        return sorted;
    },
    replaceLinkWithSpinner : function(component, event) {
        var link = event.target.parentElement;
        link.style.display = 'none';
        var spinner = event.target.parentElement.nextSibling;
        $A.util.removeClass(spinner, 'hidden');
        $A.util.addClass(spinner, 'inlineBlock');
    }
})