({
    redirectPage : function(component, event) {
        var label = event.target.getAttribute("data-data");
        var redirectEvent = component.getEvent("redirectPage");
        redirectEvent.setParams({
            "buttonName" : label
        });
        redirectEvent.fire();
    }
})