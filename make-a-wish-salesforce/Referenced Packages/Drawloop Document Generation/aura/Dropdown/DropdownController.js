({
    openDropdown : function(component) {
        component.find("dropdown").getElement().hidden = false;
    },
    closeDropdown : function(component) {
        component.find("dropdown").getElement().hidden = true;
    },
    toggleDropdown : function(component) {
        var isHidden = component.find("dropdown").getElement().hidden;
        
        if (isHidden) {
            component.find("dropdown").getElement().hidden = false;
        }
        else {
            component.find("dropdown").getElement().hidden = true;
        }
    },
	optionClicked : function(component, event, helper) {
        var selectedItem;
        var dropdownList = component.get("v.dropdownList");
        var showTitles = component.get('v.showTitles');
        
        for (var i = 0; i < dropdownList.length; i++) {
            if (event.currentTarget.id === dropdownList[i].Id) {
                selectedItem = dropdownList[i];
                break;
            }
        }
        
        component.find("selectedValue").getElement().innerText = event.target.textContent;
        
        component.find("dropdown").getElement().hidden = true;
        
        component.getEvent("recipientSelected").setParams({
            id: selectedItem.Id
        }).fire();
	}
})