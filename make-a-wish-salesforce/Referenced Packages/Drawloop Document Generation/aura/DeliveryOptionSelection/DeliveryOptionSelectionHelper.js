({
    fireErrorEvent : function(component, message) {
        var errorEvent = component.getEvent("error");
        errorEvent.setParams({
            message: message
        });
        errorEvent.fire();
    },
    slideIn : function(component, height) {
        component.find("tileContainer").getElement().style.maxHeight = component.find("tileContainer").getElement().clientHeight + 'px';
        window.setTimeout(
            $A.getCallback(function() {
                component.find("slideContainer").getElement().style.transform = 'translateX(-50%)';
                component.find("contentContainer").getElement().style.maxHeight = height;
                component.find("tileContainer").getElement().style.maxHeight = height;
            }), 10
        );
    },
    slideOut : function(component) {
        component.find("tileContainer").getElement().style.maxHeight = component.find("deliveryTiles").getElement().clientHeight + 'px';
        component.find("contentContainer").getElement().style.maxHeight = component.find("deliveryTiles").getElement().clientHeight + 'px';
        component.find("slideContainer").getElement().style.transform = 'translateX(0)';
        window.setTimeout(
            $A.getCallback(function() {
                component.find("tileContainer").getElement().style.maxHeight = '';
                component.find("contentContainer").getElement().style.maxHeight = '72px';
            }), 400
        );
    },
    hideEmailContainer : function(component) {
        component.find("emailContainer").getElement().hidden = true;
    },
    hideReminderContainer : function(component) {
        component.find("reminderContainer").getElement().hidden = true;
    },
    disableAccordions : function(component, disable) {
        var disableAccordions = component.getEvent("disableAccordions");
        disableAccordions.setParams({
            disable: disable
        }).fire();
    },
    disableRunDdpButtons : function(component, disable) {
        var disableRunDdpButtons = component.getEvent("disableRunDdpButtons");
        disableRunDdpButtons.setParams({
            disable: disable
        }).fire();
    }
})