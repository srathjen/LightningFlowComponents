({
	filterDdps : function(component) {
		var event = component.getEvent("filterDdps");
        event.setParams({
            searchText: component.find("searchText").get("v.value"),
            businessUser: component.find("businessUser").get("v.value")
        });
        event.fire();
	}
})