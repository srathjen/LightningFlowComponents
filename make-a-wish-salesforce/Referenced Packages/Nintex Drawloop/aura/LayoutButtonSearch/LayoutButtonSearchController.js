({
	filterObjects : function(component, event, helper) {
        helper.filterObjects(component);
	},
    detectEnter : function(component, event, helper) {
        if (window.event && window.event.keyCode && window.event.keyCode === 13) {
	        helper.filterObjects(component);
        }
    }
})