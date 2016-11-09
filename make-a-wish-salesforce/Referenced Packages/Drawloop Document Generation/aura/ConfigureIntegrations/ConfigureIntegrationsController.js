({
    initializeIntegrations : function(component, event, helper) {
        // Get Integration Infos and Rows
        helper.getAvailableIntegrations(component);
        
        var action = component.get("c.fetchBoxIntegrationData");
        action.setParams({
            domain: component.get("v.loopUrl")
        });
        action.setCallback(this, function(response) {
            if (response.getState() === "SUCCESS") {
                var parsedResponse = JSON.parse(response.getReturnValue());
                if (parsedResponse.Success) {
                    component.set('v.boxOAuthUrl', parsedResponse.BoxOAuthUrl);
                }
            }
        });
        $A.enqueueAction(action);        
    },
    saveIntegration : function(component, event, helper) {
        component.set('v.errors', []);
        if (event.getName && event.getName() === 'keyup' && event.getParam('keyCode') !== 13) {
            return true;
        }
        
        var type = component.get("v.selectedIntegration");
        if (type === "Box") {
            window.open(component.get('v.boxOAuthUrl'), "Authorize Box", "height=750,width=500,location=0,status=0,titlebar=0");
        }
        else {
            component.set("v.modalBusy", true);
            var id = component.find("id");
            var name = component.find("name");
            var apiKey = component.find("apiKey");
            var baseUrl = component.find("baseUrl");
            var tagSourceUrl = component.find("tagSourceUrl");
            var paths = component.find("path");
            var pathIds = component.find("pathId");
            var sitePaths = helper.getSitePaths(paths);
            var sitePathIds = helper.getSitePaths(pathIds);
            var values = {
                type: type,
                id: id ? id.get("v.value") : '',
                name: name ? name.get("v.value") : '',
                apiKey: apiKey ? apiKey.get("v.value") : '',
                baseUrl: baseUrl ? baseUrl.get("v.value") : '',
                tagSourceUrl: tagSourceUrl ? tagSourceUrl.get("v.value") : '',
            };
            if (sitePaths.length > 0) {
                values.sitePaths = JSON.stringify(sitePaths);
                values.pathIds = JSON.stringify(sitePathIds);
            }
            
            // Field validation
            var errors = [];
            var singleInputFields = [name, apiKey, baseUrl, tagSourceUrl];
            var invalidSingleInputFields = helper.validateFields(type, singleInputFields);
            var sitePathFields = helper.getSitePathFields(paths);
            var invalidSitePathFields = helper.validateFields(type, sitePathFields);
            if (invalidSingleInputFields.length + invalidSitePathFields.length > 0) {
                var labels = [];
                for (var i in invalidSingleInputFields) {
                    var field = invalidSingleInputFields[i];
                    labels.push(field.getElement().parentElement.childNodes[0].innerHTML);
                }
                if (invalidSitePathFields.length > 0) {
                    labels.push('Site Paths');
                }
                errors.splice(0, 0, 'These following fields have errors: ' + labels.join(', '));
            }
            
            if (errors.length > 0) {
                component.set("v.errors", errors);
                component.set("v.modalBusy", false);
            } else {
                // Validation Success
                if (type === 'Office 365') {
                    helper.oAuthOffice365(component, values);
                } else {
                    helper.upsertIntegrationInfos(component, type, values);
                }
            }
        }
    },
    changeSelectedOption : function(component, event, helper) {
        var selectedOptionValue = event.source.get("v.value");
        (selectedOptionValue === 'Box' || selectedOptionValue === 'Office 365') ? component.set("v.saveButtonText", "Authorize") : component.set("v.saveButtonText", "Save");
        helper.updateFields(component, selectedOptionValue);
        if (selectedOptionValue === 'DocuSign') {
            var action = component.get("c.getDocuSignAccountConfiguration");
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    var dsObjJson = response.getReturnValue();
                    if (dsObjJson) {
                        var dsObj = JSON.parse(dsObjJson);
                        if (dsObj && dsObj[0].dsfs__UseSendOnBehalfOf__c) {
                            var ds = dsObj[0];
                            var values = {};
                            values.Name = 'DocuSign';
                            values.Loop__Type__c = 'DocuSign';
                            values.Loop__API_Key__c = ds.dsfs__AccountId__c;
                            values.Loop__Base_URL__c = ds.dsfs__DocuSignBaseURL__c;
                            helper.updateValues(component, [values]);
                        }
                    }
                }
            });
            $A.enqueueAction(action);
        }
        helper.resetValues(component);
    },
    hideModal : function(component, event, helper) {
        helper.hideModal(component);
        helper.resetFields(component);
    },
    integrationDeleted : function(component, event, helper) {
        component.find("selectedOption").set("v.value", "");
        helper.getAvailableIntegrations(component);
    },
    addSitePath : function(component, event, helper) {
        var paths = component.get("v.sitePaths");
        paths.push('');
        component.set("v.sitePaths", paths);
    },
    removeSitePath : function(component, event, helper) {
        var rowContainer = event.target.closest('div.slds-grid');
        var removeIndex = event.target.closest('.slds-col--padded').id;
        var newPaths = [];
        for (var i = 0; i < rowContainer.parentNode.children.length; i++) {
            if (removeIndex && i === parseInt(removeIndex, 10)) {
                continue;
            }
            var row = rowContainer.parentNode.children[i];
            newPaths.push(row.children[1].children[0].value);
        }
        component.set("v.sitePaths", newPaths);
    },
    editIntegration : function(component, event, helper) {
        var id = event.getParam("id");
        var action = component.get("c.getIntegrationInfo");
        action.setParams({value: id});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var integrationsJson = response.getReturnValue();
                var integrations = JSON.parse(integrationsJson);
                if (integrations !== null && integrations.length > 0) {
                    helper.updateFields(component, integrations[0].Loop__Type__c);
                    helper.updateValues(component, integrations);
                    if (integrations[0].Loop__Type__c === 'Box' || integrations[0].Loop__Type__c === 'Office 365') {
                        component.set("v.saveButtonText", "Reauthorize");
                    } else {
                        component.set("v.saveButtonText", "Save");
                    }
                }
            } else {
                helper.handleErrorResponse(response);
            }

            var integrationsList = component.find('integrationsList');
            integrationsList.replaceSpinnersWithLinks();
        });
        $A.enqueueAction(action);
    },
    handleBoxOAuthSuccessful : function(component, event, helper) {
        var isSuccess = event.getParam("success");
        if (!isSuccess) {
            var errorDescription = "Error: " + event.getParam("errorDescription").replace(/\+/g, " ");
            component.set("v.boxError", errorDescription);
        }
        else {
            helper.hideModal(component);
            helper.getAvailableIntegrations(component);
            component.find("selectedOption").set("v.value", "");
            helper.resetFields(component);
            component.find("integrationsList").refreshList();
        }
    },
    handleOffice365OAuthCompleted : function(component, event, helper) {
        if (event.getParam("isSuccess")) {
            var type = 'Office 365';
            var id = component.find("id");
            var name = component.find("name");
            var baseUrl = component.find("baseUrl");
            var paths = component.find("path");
            var sitePaths = helper.getSitePaths(paths);
            var values = {
                type: type,
                id: id ? id.get("v.value") : '',
                name: name ? name.get("v.value") : '',
                baseUrl: baseUrl ? baseUrl.get("v.value") : ''
            };
            if (sitePaths.length > 0) {
                values.sitePaths = JSON.stringify(sitePaths);
            }
            helper.upsertIntegrationInfos(component, type, values);
        }
        else {
            var errorDescription = event.getParam("errorDescription");
            component.getEvent('showError').setParams({
                message: errorDescription
            }).fire();
        }
    }
})