({
    isLockerServiceActive : function() {
        try {
            // 'use strict' is enforced when LockerService is activated so the following undeclared variable should throw an exception.
            x = 3.14;
            return false;
        } catch (ex) {
            return true;
        }
    },
    searchHelper : function(component) {
        var searchString = document.getElementById("search").value;
        document.getElementById("noResults").setAttribute("data-hidden", "true");
        if (!searchString) {
            var branches = ["buttonToggle", "configuration", "users"];
            for (var i = 0; i < branches.length; i++) {
                var br = component.find(branches[i] + "-Node");
                var icon = component.find(branches[i] + "-icon");
                document.getElementById(branches[i]).setAttribute("data-hidden", "false");
                $A.util.addClass(br, "slds-collapsed");
                $A.util.removeClass(icon, "icon-on");
            }
            var branchItems = ["classicExperienceButtons", "buttonWizard", 
                               "edition", "thirdpartyIntegrations", "jobQueueStatus", "settings", "sampleDdps", 
                               "testUserConfiguration", "userPermissions"];
            for (var j = 0; j < branchItems.length; j++) {
                document.getElementById(branchItems[j]).setAttribute("data-hidden", "false");
            }
        } else {
            this.searchHeaders(component, searchString.toLowerCase());
        }
    },
    searchHeaders : function(component, searchString) {
        var escapedSearchString = this.escapeRegExp(searchString);
        var re = new RegExp(escapedSearchString, 'i');
        var buttonCount = 0;
        var buttonHeader = 0;
        var configCount = 0;
        var configHeader = 0;
        var usersCount = 0;
        var usersHeader = 0;
        
        if ("classic buttons".match(re) || "classic experience buttons".match(re) || "button wizard".match(re)) {
            buttonCount++;
            if ("classic buttons".match(re)) {
                buttonHeader++;
            }
        }
        if ("configuration".match(re) || "edition".match(re) || "third-party integrations".match(re) || 
            "job queue status".match(re) || "settings".match(re) || "sample ddps".match(re)) {
            configCount++;
            if ("configuration".match(re)) {
                configHeader++
            }
        }
    	if ("users".match(re) || "test user configuration".match(re) || "user permissions".match(re)) {
    		usersCount++;
            if ("users".match(re)) {
                usersHeader++;
            }
        }
        this.searchHeadersResults(component, buttonCount, configCount, usersCount);
        this.searchItemsResults(component, escapedSearchString, buttonCount, configCount, usersCount, buttonHeader, configHeader, usersHeader);
        if ((buttonCount + configCount + usersCount) === 0) {
            document.getElementById("noResults").setAttribute("data-hidden", "false");
        } else {
            document.getElementById("noResults").setAttribute("data-hidden", "true");
        }
    },
    searchHeadersResults : function(component, buttonCount, configCount, usersCount) {
        var showBranches = [];
        var hideBranches = [];
        if (buttonCount > 0) {
            showBranches.push("buttonToggle");
        } else {
            hideBranches.push("buttonToggle");
        }
        if (configCount > 0) {
            showBranches.push("configuration");
        } else {
            hideBranches.push("configuration");
        }
        if (usersCount > 0) {
            showBranches.push("users");
        } else {
            hideBranches.push("users");
        }
        for (var i = 0; i < showBranches.length; i++) {
            var branchToShow = document.getElementById(showBranches[i]);
            var brToExpand = component.find(showBranches[i] + "-Node");
            var iconToExpand = component.find(showBranches[i]+ "-icon");
            
            if (branchToShow.getAttribute("data-hidden") !== "false") {
            	branchToShow.setAttribute("data-hidden", "false");
            }
            if ($A.util.hasClass(brToExpand, "slds-collapsed")) {
                $A.util.removeClass(brToExpand, "slds-collapsed");
            }
            if (!$A.util.hasClass(iconToExpand, "icon-on")) {
                $A.util.addClass(iconToExpand, "icon-on");
            }
        }
        for (var j = 0; j < hideBranches.length; j++) {
            var branchToHide = document.getElementById(hideBranches[j]);
            var brToCollapse = component.find(hideBranches[j] + "-Node");
            var iconToCollapse = component.find(hideBranches[j]+ "-icon");
            
            if (branchToHide.getAttribute("data-hidden") !== "true") {
            	branchToHide.setAttribute("data-hidden", "true");
                $A.util.removeClass(component.find(hideBranches[j] + "-icon"), "icon-on");
            }
            if (!$A.util.hasClass(brToCollapse, "slds-collapsed")) {
                $A.util.addClass(brToCollapse, "slds-collapsed");
            }
            if ($A.util.hasClass(iconToCollapse, "icon-on")) {
                $A.util.removeClass(iconToCollapse, "icon-on");
            }
        }
    },
    searchItemsResults : function(component, escapedSearchString, buttonCount, configCount, usersCount, buttonHeader, configHeader, usersHeader) {
        var re = new RegExp(escapedSearchString, 'i');
        
        if (buttonCount > 0 && buttonHeader === 0) {
            var buttonItems = [{option:"classic experience buttons", element:"classicExperienceButtons"}, 
                               {option:"button wizard", element:"buttonWizard"}];
            for (var i = 0; i < buttonItems.length; i++) {
                var buttonElement = document.getElementById(buttonItems[i].element);
                if (buttonItems[i].option.match(re)) {
                    if (buttonElement.getAttribute("data-hidden") !== "false") {
            			buttonElement.setAttribute("data-hidden", "false");
                    }
                } else {
                    if (buttonElement.getAttribute("data-hidden") !== "true") {
            			buttonElement.setAttribute("data-hidden", "true");
                    }
                }
            }
        }
        if (configCount > 0 && configHeader === 0) {
            var configItems = [{option:"edition", element:"edition"},
                               {option:"third-party integrations", element:"thirdpartyIntegrations"},
                               {option:"job queue status", element:"jobQueueStatus"},
                               {option:"settings", element:"settings"},
                               {option:"sample ddps", element:"sampleDdps"}];
            for (var j = 0; j < configItems.length; j++) {
                var configElement = document.getElementById(configItems[j].element);
                if (configItems[j].option.match(re)) {
                    if (configElement.getAttribute("data-hidden") !== "false") {
            			configElement.setAttribute("data-hidden", "false");
                    }
                } else {
                    if (configElement.getAttribute("data-hidden") !== "true") {
            			configElement.setAttribute("data-hidden", "true");
                    }
                }
            }
        }
        if (usersCount > 0 && usersHeader === 0) {
            var usersItems = [{option:"test user configuration", element:"testUserConfiguration"},
                              {option:"user permissions", element:"userPermissions"}];
            for (var k = 0; k < usersItems.length; k++) {
                var userElement = document.getElementById(usersItems[k].element);
                if (usersItems[k].option.match(re)) {
                    if (userElement.getAttribute("data-hidden") !== "false") {
            			userElement.setAttribute("data-hidden", "false");
                    }
                } else {
                    if (userElement.getAttribute("data-hidden") !== "true") {
            			userElement.setAttribute("data-hidden", "true");
                    }
                }
            }
        }
    },
    toggleBranch : function(component, branchName) {
        var element = component.find(branchName);
        $A.util.toggleClass(element, "slds-collapsed");
    },
    isSelected : function(component, event) {
        var elements = document.getElementsByClassName('slds-is-selected');
        var id = event.target.getAttribute("id");
        if (!elements) {
            return;
        }
        for ( var i = 0; i < elements.length; i++) {
            var element = elements[i].getAttribute("id")
            $A.util.removeClass(component.find(element), "slds-is-selected");
        }
        $A.util.addClass(component.find(id), "slds-is-selected");
    },
    escapeRegExp : function(str) {
    	return str.replace(/[\-\[\]\/\{\}\(\)\*\+\?\.\\\^\$\|]/g, "\\$&");
	}
})