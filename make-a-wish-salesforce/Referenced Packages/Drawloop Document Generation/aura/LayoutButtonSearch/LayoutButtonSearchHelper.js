({
	filterObjects : function(component) {
		var event = component.getEvent("filterObjects");
        event.setParams({
            searchText: component.find("searchText").get("v.value")
        });
        event.fire();
	}
})