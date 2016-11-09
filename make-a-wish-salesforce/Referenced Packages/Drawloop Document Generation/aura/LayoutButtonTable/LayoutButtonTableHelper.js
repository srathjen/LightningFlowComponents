({
    setAllObjectGroups : function(component, groups) {
        var layoutMetadata = {};
        var allGroups = [];
        for (var i in groups) {
            var group = groups[i];
            allGroups.push(group);
            for (var j in group.objectItems) {
                var item = group.objectItems[j];
                allGroups.push({
                    id: item.id,
                    name: item.name,
                    multiple: false,
                    page: item.page,
                    obj: item.obj,
                    objClass: item.objClass,
                    enabled: item.hasButton,
                    isGroup: false,
                    index: (parseInt(j) + 1)
                });
                layoutMetadata[item.id] = item.metadata;
            }
        }
        
        component.set("v.allObjectGroups", allGroups);
        component.set("v.layoutMetadata", JSON.stringify(layoutMetadata));
    },
    setCustomObjectSelectOptions : function(component, customObjects) {
        var optionsArray = [];
        optionsArray.push({
            text: '',
            label: 'Select a custom object'
        });
        for (var i = Object.keys(customObjects).length - 1; i > -1; i--) {
            var customObjectKey = Object.keys(customObjects)[i];
            optionsArray.push({
                text: customObjectKey,
                label: customObjects[customObjectKey]
            });
        }
        
        component.set("v.customObjectSelectOptions", optionsArray);
    },
    updateObjectGroups : function(component) {
        var allGroups = component.get("v.allObjectGroups");
        var filteredGroups = this.filterObjectGroups(component, allGroups);

        var selectedCount = 0;
        var checkedExist = false;
        var uncheckedExist = false;
        for (var i = filteredGroups.length - 1; i > -1; i--) {
            var group = filteredGroups[i];
			
            if (group.isGroup) {
                if (checkedExist) {
                    group.enabled = true;
                    if (uncheckedExist) {
                        group.tristate = true;
                    }
                }
                checkedExist = false;
                uncheckedExist = false;
            } else {
                if (group.enabled) {
                    checkedExist = true;
                } else {
                    uncheckedExist = true;
                }
            } 
            
            selectedCount += ((!group.isGroup && group.enabled) ? 1 : 0);
        }        
        
        component.set("v.objectGroups", filteredGroups);
        component.set("v.enabledCount", selectedCount > 0 ? ' (' + selectedCount + ')' : '');
        
        var noRecordRow = component.find("noRecordRow");
        if (filteredGroups.length === 0) {
            var spinner = noRecordRow.getElement().getElementsByTagName('div')[0];
            if (spinner) {
				spinner.remove();
            }
            noRecordRow.getElement().getElementsByTagName('span')[0].innerHTML = 'There are no records to display.';
			$A.util.removeClass(noRecordRow, "rowHidden");
        } else {
            $A.util.addClass(noRecordRow, "rowHidden");
        }
    },
	getObjectGroups : function(component) {
		var action = component.get("c.getObjectGroups");
        action.setParams({
            sessionId: component.get("v.sessionId"),
            domain: component.get('v.apiUrl')
        });
        action.setCallback(this, function(response) {
            if (response.getState() === "SUCCESS") {
                var parsedResponse = response.getReturnValue();
                if (parsedResponse.isSuccess) {
                    this.setAllObjectGroups(component, parsedResponse.objectGroups);
                }
                else {
                    this.fireErrorEvent(component, parsedResponse.errorMessage);
                }
            }
            else {
                this.fireErrorEvent(component, 'There was a problem retrieving layout metadata.');
            }
        });
        $A.enqueueAction(action);
    },
    filterObjectGroups : function(component, allGroups) {
		var searchText = component.get("v.searchText");

        var filteredGroups = {};
        for (var i in allGroups) {
            var group = allGroups[i];
            if (group.isGroup) {
                var subGroups = [group];
                filteredGroups[group.obj] = subGroups;
                continue;
            } else {
                if (searchText) {
                    var values = '';
                    for (var key in group) {
                        if (['obj', 'page'].indexOf(key) >= 0) {
	                        values += group[key];
                        }
                    }
                    var escapedSearchText = this.escapeRegExp(searchText);
                    var re = new RegExp(escapedSearchText, 'i');
                    if (!values.match(re) || values.match(re).length === 0) {
                        continue;
                    }
                }
                filteredGroups[group.obj].push(group);
            }
        }

        var groupsWithSubgroups = [];
        var fgKeys = Object.keys(filteredGroups);
        for (var j in fgKeys) {
            var filteredGroup = filteredGroups[fgKeys[j]];
            if (filteredGroup.length > 1) { // The first item is the grouping (header), not a ddp
                groupsWithSubgroups = groupsWithSubgroups.concat(filteredGroup);
            }
        }
        return groupsWithSubgroups;
    },
    findAncestorWithName : function(el, name) {
        while((el = el.parentElement) && el.nodeName !== name);
        return el;
    },
    toggleLinkAndSpinner : function(component, showLink) {
        if (!showLink) {
            component.find('addButtonLink').getElement().style.display = 'none';
            component.find('addButtonSpinner').getElement().style.display = '';
        } else {
            component.find('addButtonLink').getElement().style.display = '';
            component.find('addButtonSpinner').getElement().style.display = 'none';
        }
    },
    expandGroup : function(row, industry) {
        row.setAttribute('data-expanded', 'true');
        
        // Update icon
        var div = row.childNodes[0].childNodes[0];
        $A.util.addClass(div, 'divHidden');
        $A.util.removeClass(div.nextSibling, 'divHidden');
        
        // Update rows
        while(row.nextSibling && row.nextSibling.id === industry) {
            $A.util.removeClass(row.nextSibling, 'rowHidden');
            $A.util.addClass(row.nextSibling, 'slds-hint-parent');
            row = row.nextSibling;
        }
    },
    retractGroup : function(row, industry) {
        row.setAttribute('data-expanded', 'false');
        
        // Update icon
        var div = row.childNodes[0].childNodes[1];
        $A.util.addClass(div, 'divHidden');
        $A.util.removeClass(div.previousSibling, 'divHidden');
        
        // Update rows
        while(row.nextSibling && row.nextSibling.id === industry) {
            $A.util.removeClass(row.nextSibling, 'slds-hint-parent');
            $A.util.addClass(row.nextSibling, 'rowHidden');
            row = row.nextSibling;
        }        
    },
    escapeRegExp : function(str) {
        return str.replace(/[\-\[\]\/\{\}\(\)\*\+\?\.\\\^\$\|]/g, "\\$&");
	},
    fireErrorEvent : function(component, message) {
        component.getEvent('showError').setParams({
            message: message
        }).fire();
    }
})