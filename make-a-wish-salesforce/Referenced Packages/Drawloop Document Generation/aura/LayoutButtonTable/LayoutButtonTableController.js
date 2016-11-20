({
    onInit : function(component, event, helper) {
        var sessionId = component.get("v.sessionId");
        var domain = component.get("v.apiUrl");
        
        var load = component.get("c.load");
        load.setParams({
            sessionId: sessionId,
            domain: domain
        });
        load.setCallback(this, function(response) {
            if (response.getState() === "SUCCESS") {
                var parsedResponse = JSON.parse(response.getReturnValue());
                if (parsedResponse.isSuccess) {
                    helper.setAllObjectGroups(component, parsedResponse.layouts);
                    helper.updateObjectGroups(component);
                    
                    var customObjects = parsedResponse.customObjects;
                    if (Object.keys(customObjects).length > 0) {
        				component.set('v.availableCustomObjects', customObjects);
                    	helper.setCustomObjectSelectOptions(component, parsedResponse.customObjects);
                    }
                }
                else {
                    helper.fireErrorEvent(component, parsedResponse.errorMessage);
                }
            }
            else {
                helper.fireErrorEvent(component, 'There was a problem retrieving layout metadata.');
            }
            
            component.set("v.isTableLoading", false);
        });
        
        $A.enqueueAction(load);
    },
    toggleGroup : function(component, event, helper) {
        var selectedRow = event.currentTarget;

        var isGroup = selectedRow.getAttribute('data-is-group');
        if (isGroup === 'true') {
            var expanded = selectedRow.getAttribute('data-expanded');
            if (expanded === 'false') {
                helper.expandGroup(component, selectedRow);
            } else {
                helper.retractGroup(component, selectedRow);
            }
        }        
    },
    updateCheckboxes : function(component, event, helper) {
		var checkbox = event.source.getElement();
        var groupCheckboxes = document.getElementsByClassName(checkbox.classList[0]);
        var groupCheckboxesClassList = groupCheckboxes[0].closest('.slds-checkbox').classList;
        var isGroup = checkbox === groupCheckboxes[0];
        
        var selectedCountString = component.get("v.enabledCount");
        var selectedMatches = selectedCountString.match(/ \((\d+)\)/i);
        var selectedCount = (selectedMatches && selectedMatches.length === 2) ? parseInt(selectedMatches[1], 10) : 0;
        
        if (isGroup) {
            for (var i = 0; i < groupCheckboxes.length; i++) {
                if (groupCheckboxes[i].checked !== checkbox.checked) {
	                groupCheckboxes[i].checked = checkbox.checked;
		            selectedCount += checkbox.checked ? 1 : -1;
                }
            }
            if (groupCheckboxesClassList.contains('tristate')) {
                groupCheckboxesClassList.remove('tristate');
            }
        } else if (!checkbox.checked) {
            var checkedExists = false;
            for (var j = 1; j < groupCheckboxes.length; j++) {
                if (groupCheckboxes[j].checked) {
                    checkedExists = true;
                    break;
                }
            }
            
            if (checkedExists) {
                if (!groupCheckboxesClassList.contains('tristate')) {
                    groupCheckboxesClassList.add('tristate');
                }
            } else {
            	groupCheckboxes[0].checked = false;
                if (groupCheckboxesClassList.contains('tristate')) {
                    groupCheckboxesClassList.remove('tristate');
                }
            }
            selectedCount -= 1;
        } else if (checkbox.checked) {
            // groupCheckbox is the checkbox on the "header" row that represents the following rows in the "group"; this checkbox holds the "tristate" when necessary
            var groupCheckbox = groupCheckboxes[0];
            var uncheckedExists = false;
            for (var k = 1; k < groupCheckboxes.length; k++) {
                if (!groupCheckboxes[k].checked) {
                    uncheckedExists = true;
                    break;
                }
            }
            
            groupCheckbox.checked = true;
            if (uncheckedExists) {
                if (!groupCheckboxesClassList.contains('tristate')) {
                    groupCheckboxesClassList.add('tristate');
                }
            } else {
                if (groupCheckboxesClassList.contains('tristate')) {
                    groupCheckboxesClassList.remove('tristate');
                }
            }
            selectedCount += 1;
        }
        // Updated selected count with javascript so table is not rerendered
        component.set("v.enabledCount", selectedCount > 0 ? ' (' + selectedCount + ')' : '');
    },
    save : function(component, event, helper) {
        var moveToNextStep = component.getEvent("moveToNextStep");
        var objectIds = [];
        var objects = component.get("v.objectGroups");

		var objectTypeMap = {};
        if (objects && objects.length > 0) {
            for (var i in objects) {
                if (!objects[i].isGroup) {
                    objectIds.push(objects[i].id);
                    objectTypeMap[objects[i].id] = objects[i].obj;
                }
            }
            var checkedIds = [];
            var checkedObjectTypes = [];
            for (var j in objectIds) {
                var label = document.getElementById(objectIds[j]);
                if (label.firstChild.checked) {
                    checkedIds.push(objectIds[j]);
                    var objectType = objectTypeMap[objectIds[j]];
                    if (checkedObjectTypes.indexOf(objectType) < 0) {
	                    checkedObjectTypes.push(objectType);
                    }
                }
            }
            
            var action = component.get("c.saveLayouts");
            action.setParams({
                sessionId: component.get("v.sessionId"),
                checkedLayoutIds: JSON.stringify(checkedIds),
                layoutMetadataJson: component.get("v.layoutMetadata"),
                domain: component.get('v.apiUrl')
            });
            action.setCallback(this, function(response) {
                if (response.getState() === "SUCCESS") {
                    var parsedResponse = JSON.parse(response.getReturnValue())
                    if (parsedResponse.isSuccess) {
                        component.getEvent('setSampleObjects').setParams({
                            sampleType: 'layoutButtons',
                            objectTypes: checkedObjectTypes
                        }).fire();
                        moveToNextStep.setParams({success: true}).fire();
                    }
                    else {
                    	helper.fireErrorEvent(component, parsedResponse.errorMessage);
                    }
                }
                else {
                    helper.fireErrorEvent(component, 'There was a problem modifying layouts.');
                }
            });
            $A.enqueueAction(action);
        } else {
            moveToNextStep.fire();
        }
    },
    createButton : function(component, event, helper) {
        var objectType = component.find('customObjectSelect').get('v.value');
        var cmp = component;
        var help = helper;
        if (objectType) {
        	helper.toggleLinkAndSpinner(component, false);
            
            var action = component.get("c.createWeblink");
            action.setParams({
                sessionId: component.get("v.sessionId"),
                objectType: objectType,
                domain: component.get('v.apiUrl')
            });
            action.setCallback(this, function(response) {
                if (response.getState() === "SUCCESS") {
                    var parsedResponse = JSON.parse(response.getReturnValue());
                    if (parsedResponse.isSuccess) {
                        // re-fetch groups to get updates and rerender
                        help.getObjectGroups(cmp);
                    }
                    else {
                    	helper.fireErrorEvent(component, parsedResponse.errorMessage);
                    }
                }
                else {
                    helper.fireErrorEvent(component, 'There was a problem creating this button.');
                }
            });
            $A.enqueueAction(action);
        } else {
            helper.fireErrorEvent(component, 'This object type could not be found.');
        }
    }
})