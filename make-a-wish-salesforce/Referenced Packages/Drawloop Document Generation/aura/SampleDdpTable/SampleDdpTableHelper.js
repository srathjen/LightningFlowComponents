({
    updateDdpGroups : function(component) {
        var allGroups = component.get("v.allDdpGroups");
        var filteredGroups = this.filterDdpGroups(component, allGroups);
        component.set("v.ddpGroups", filteredGroups);

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
	getDdpGroups : function(component) {
		var action = component.get("c.getDdps");
        action.setParams({
            sessionId: component.get('v.sessionId'),
            domain: component.get('v.loopUrl')
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var groupsJson = response.getReturnValue();
                var groups = JSON.parse(groupsJson);

                var allGroups = [];
                if ('error' in groups) {
                    component.getEvent('showError').setParams({
                        message: groups.error
                    }).fire();
                    return;
                }
                
                for (var i in groups.ddpGroups) {
                    var group = groups.ddpGroups[i];
                    allGroups.push(group);
                    for (var j in group.ddpItems) {
                        var item = group.ddpItems[j];
                        var buString = item.businessUsers.join(', ');
                        var dtString = item.documentTypes.join(', ');
                        
                        allGroups.push({
                            id: item.id,
                            name: item.name,
                            className: item.className,
                            multiple: false,
                            mainObjects: item.mainObject,
                            industry: item.industry,
                            industryClass: item.industryClass,
                            enabled: null,
                            documentTypes: dtString,
                            ddps: item.name,
                            businessUsers: buString,
                            isGroup: false,
                            index: (parseInt(j, 10) + 1)
                        });
                    }
                }        
                
                component.set("v.allDdpGroups", allGroups);
            } else if (state === "ERROR") {
                component.getEvent('showError').setParams({
                    message: 'There was a problem retrieving DDPs.'
                }).fire();
            }
        });
        $A.enqueueAction(action);
    },
    filterDdpGroups : function(component, allGroups) {
		var searchText = component.get("v.searchText");
		var businessUser = component.get("v.businessUser");

        var filteredGroups = {};
        for (var i in allGroups) {
            var group = allGroups[i];
            if (group.isGroup) {
                var subGroups = [group];
                filteredGroups[group.industry] = subGroups;
                continue;
            } else {
                if (searchText) {
                    var values = '';
                    for (var key in group) {
                        if (['businessUsers', 'className', 'ddps', 'documentTypes', 'industry', 'mainObjects', 'name'].indexOf(key) >= 0) {
	                        values += group[key];
                        }
                    }
                    var escapedSearchText = this.escapeRegExp(searchText);
                    var re = new RegExp(escapedSearchText, 'i');
                    if (!values.match(re) || values.match(re).length === 0) {
                        continue;
                    }
                }
                if (businessUser && allGroups[i].businessUsers.split(', ').indexOf(businessUser) < 0) {
                    continue;
                }
                filteredGroups[group.industry].push(group);
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
    expandGroup : function(component, selectedRow) {
		selectedRow.setAttribute('data-expanded', 'true');

        // Update icon
        var div = selectedRow.childNodes[0].childNodes[0];
        var divNextSibling = selectedRow.childNodes[0].childNodes[1];
        $A.util.addClass(div, 'divHidden');
        $A.util.removeClass(divNextSibling, 'divHidden');
        
        // Update rows
        var rows = component.find('row');
        for (var i = 0; i < rows.length; i++) {
            var row = rows[i].getElement();
            if (row.getAttribute('data-is-group') === "false" && row.id === selectedRow.id) {
                $A.util.removeClass(row, 'rowHidden');
                $A.util.addClass(row, 'slds-hint-parent');
            }
        }
    },
    retractGroup : function(component, selectedRow) {
        selectedRow.setAttribute('data-expanded', 'false');

        // Update icon
        var div = selectedRow.childNodes[0].childNodes[1];
        var divPreviousSibling = selectedRow.childNodes[0].childNodes[0];
        $A.util.addClass(div, 'divHidden');
        $A.util.removeClass(divPreviousSibling, 'divHidden');
        
        // Update rows
        var rows = component.find('row');
        for (var i = 0; i < rows.length; i++) {
            var row = rows[i].getElement();
            if (row.getAttribute('data-is-group') === "false" && row.id === selectedRow.id) {
                $A.util.addClass(row, 'rowHidden');
                $A.util.removeClass(row, 'slds-hint-parent');
            }
        }     
    },
    escapeRegExp : function(str) {
    	return str.replace(/[\-\[\]\/\{\}\(\)\*\+\?\.\\\^\$\|]/g, "\\$&");
	}
})