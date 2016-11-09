({
    openLookupMenu : function(component) {
        component.set("v.recordsFound", []);
        $A.util.addClass(component.find("lookupMenu"), "show");
    },
    closeLookupMenu : function(component, event, helper) {
        helper.closeLookupMenu(component);
    },
    blurLookupMenu : function(component, event, helper) {
        var lookupMenu = component.find('lookupMenu') && component.find('lookupMenu').getElement && component.find('lookupMenu').getElement();
        if (lookupMenu && event.relatedTarget !== lookupMenu && !lookupMenu.contains(event.relatedTarget)) {
            helper.closeLookupMenu(component);
        }
    },
    updateSearchString : function(component, event, helper) {
        component.set("v.searchString", event.target.value);
        helper.resetSelectedRecordId(component, null);
    },
	search : function(component, event, helper) {
        var searchString = component.get('v.searchString');
        var executeSearch = false;
        if ((event.type === "keydown" && event.keyCode === 13) || event.type === "click") {
            executeSearch = true;
        }
        if (executeSearch && searchString) {
        	$A.util.removeClass(component.find("searchResultsLoading"), 'hidden');
            var searchResults = component.find("searchResults");
            if (searchResults) {
                for (var i = 0; i < searchResults.length; i++) {
                    //If .find() returns a list, for some reason, the elements in the list don't have a .getElement() function. Hence we use .addClass here
                    $A.util.addClass(searchResults[i], "hidden");
                }
            }
            
            var objectType = component.get("v.objectType");
            var action = component.get("c.searchForRecords");
            action.setParams({
                objectType: objectType,
                searchString: searchString
            });
            action.setCallback(this, function(response) {
                if (response.getState() === "SUCCESS") {
                    var parsedResponse = JSON.parse(response.getReturnValue());
                    if (parsedResponse.isSuccess) {
                        component.set("v.recordsFound", parsedResponse.records);
                    }
                    else {
                        component.set("v.recordsFound", []);
                    }
                }
                else {
                    component.set("v.recordsFound", []);
                }
                
                $A.util.addClass(component.find("searchResultsLoading"), 'hidden');
                var searchResults = component.find("searchResults");
                if (searchResults) {
                    for (var i = 0; i < searchResults.length; i++) {
                        //If .find() returns a list, for some reason, the elements in the list don't have a .getElement() function. Hence we use .removeClass here
                        $A.util.removeClass(searchResults[i], "hidden");
                    }
                }
            });
            
            $A.enqueueAction(action);
        }
	},
    recordSelected : function(component, event, helper) {
        var selectedId = event.currentTarget.id;
        var recordsList = component.get("v.recordsFound");
        var selectedRecord;
        if (recordsList.length) {
            for (var i = 0; i < recordsList.length; i++) {
                if (recordsList[i].Id === selectedId) {
                    selectedRecord = recordsList[i];
                    break;
                }
            }
        }
        else {
            selectedRecord = recordsList;
        }
        
        component.set("v.searchString", selectedRecord.Name);
        component.set("v.recordsFound", []);
        helper.closeLookupMenu(component);
        
        helper.resetSelectedRecordId(component, selectedRecord);
    }
})