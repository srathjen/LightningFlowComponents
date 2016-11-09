({
    onInit : function(component, event, helper) {
        var records = component.get("v.records");
        if (records && records.length) {
        	var maxRecords = 50;
            if (records.length > maxRecords) {
                component.set("v.maxRecordsExceeded", true);
                var recordType = component.get("v.recordType");
                var text;
                if (recordType === "ddp") {
                    text = "ddps";
                }
                else if (recordType === "contact") {
                    text = "contacts";
                }
                else if (recordType === "delivery") {
                    text = "delivery options";
                }
                else if (recordType === "document") {
                    text = "optional documents";
                }
                
                component.set("v.warningMessage", "The search returned more than the maximum number of " + text + ": " + maxRecords + ". Please refine your search criteria.");
            }
            
            var filteredRecords = [];
            for (var i = 0; i < maxRecords && records[i]; i++) {
                filteredRecords.push(records[i]);
            }
            
            component.set("v.filteredRecords", filteredRecords);
        }
    },
    handleTileClicked : function(component, event) {
        var clickedTile = {
            tileGlobalId: event.getParam("globalId"),
            id: event.getParam("id"),
            name: event.getParam("name"),
            attachToRecord: event.getParam("attachToRecord"),
            selectedContentLibrary: event.getParam("selectedContentLibrary"),
            emailSubject: event.getParam("emailSubject"),
            emailBody: event.getParam("emailBody"),
            reminderDelay: event.getParam("reminderDelay"),
            reminderFrequency: event.getParam("reminderFrequency"),
            expireAfter: event.getParam("expireAfter"),
            expireWarn : event.getParam("expireWarn")
        };
        
        component.set("v.clickedTile", clickedTile);
    },
    selectTilesClicked : function(component, event, helper) {
        //selectedTiles holds Tiles that have already been selected.
        var selectedTiles = component.get("v.selectedTiles");
        
        //clickedTile holds infomation on the tile that has just been clicked.
        var clickedTile = component.get("v.clickedTile");
        
        if (clickedTile) {
            var tileGlobalId = clickedTile.tileGlobalId;
            
            if (component.get("v.isMultiSelect")) {
                //Handle UI
                $A.getComponent(tileGlobalId).toggle();
                
                //Handle data
                var addToSelectedTiles = true;
                for (var i = 0; i < selectedTiles.length; i++) {
                    if (selectedTiles[i].tileGlobalId === tileGlobalId) {
                        addToSelectedTiles = false;
                        selectedTiles.splice(i, 1);
                        break;
                    }
                }
                
                if (addToSelectedTiles) {
                    selectedTiles.push(clickedTile);
                }
            }
            else {
                //Handle UI
                var tiles = component.find("tile");
                if (tiles.length) {
                    for (var j = 0; j < tiles.length; j++) {
                        if (tiles[j].getGlobalId() === tileGlobalId) {
                            $A.getComponent(tiles[j].getGlobalId()).open();
                        }
                        else {
                            $A.getComponent(tiles[j].getGlobalId()).close();
                        }
                    }
                }
                else {
                    $A.getComponent(tileGlobalId).open();
                }

                //Handle data
                selectedTiles = [clickedTile];
            }
            component.set("v.selectedTiles", selectedTiles);
            helper.recordSelected(component);
            
            component.set("v.clickedTile", "");
        }
    },
    onRecordsChange : function(component, event) {
        component.set("v.filteredRecords", component.get("v.records"));
    },
    search : function(component, event) {
        var searchString = event.getParams().arguments.searchString;
        if (searchString.length > 0) {
            var searchNames = component.get("v.records");
            var filteredRecords = [];
            for (var i = 0; i < searchNames.length; i++) {
                if (searchNames[i].Name.toLowerCase().indexOf(searchString.toLowerCase()) > -1) {
                    filteredRecords.push(searchNames[i]);
                }
            }
            component.set("v.filteredRecords", filteredRecords);
        }
        else {
            component.set("v.filteredRecords", component.get("v.records"));
        }
    },
    deselectTiles : function(component, event, helper) {
        var allTiles = component.find("tile");
        for (var i = 0; i < allTiles.length; i++) {
            if ($A.util.hasClass(allTiles[i], "slds-is-selected")) {
            	allTiles[i].forcedDeselect();   
            }
        }
    },
    passEmailDataToTile : function(component, event, helper) {
        var id = event.getParams().arguments.id;
        var subject = event.getParams().arguments.emailSubject;
        var body = event.getParams().arguments.emailBody;
        
        var tiles = component.find("tile");
        if (tiles) {
            if (tiles.length > 0) {
                for (var i = 0; i < tiles.length; i++) {
                    if (tiles[i].getElement().id === id) {
                        tiles[i].updateEmailData(subject, body);
                    }
                }
            } else {
                if (tiles.getElement().id === id) {
                    tiles.updateEmailData(subject, body);
                }
            }
        }
    },
    passDocuSignReminderDataToTile : function(component, event, helper) {
        var id = event.getParams().arguments.id;
        var reminderDelay = event.getParams().arguments.reminderDelay;
        var daysTillSigningExpires = event.getParams().arguments.daysTillSigningExpires;
        var reminderFrequency = event.getParams().arguments.reminderFrequency;
        var warnOfExpiration = event.getParams().arguments.warnOfExpiration;
        
        var tiles = component.find("tile");
        if (tiles) {
            if (tiles.length > 0) {
                for (var i = 0; i < tiles.length; i++) {
                    if (tiles[i].getElement().id === id) {
                        tiles[i].updateDocuSignReminderData(reminderDelay, daysTillSigningExpires, reminderFrequency, warnOfExpiration);
                    }
                }
            } else {
                if (tiles.getElement().id === id) {
                    tiles.updateDocuSignReminderData(reminderDelay, daysTillSigningExpires, reminderFrequency, warnOfExpiration);
                }
            }
        }
    },
    passSelectedAttachmentsToAttachmentTile : function(component, event, helper) {
        var selectedAttachments = event.getParams().arguments.selectedAttachments;
        component.find('attachmentsTile').updateSelectedAttachments(selectedAttachments);
    }
})