({
    globalParams:{     
    },
    processLeadForDV : function(component) {
        //Get Lead information and send for futher processing
        var _this = this;
        var actionName = "c.getMedicalInformation";
        var params = {
            "caseId": component.get("v.recId")
        };
        
        _this.callAction(component, actionName, params, function(response){
            component.set("v.leadData", response);            
        });                     
    },
    
    validateFormElements: function(component, event,helper){
        var _this = this;
        var lookupSelectedId = component.find("ICDLookup").get("v.selectedRecord.Id");
        if(event.currentTarget) {
            var selectedVal = event.currentTarget.value;
            component.set('v.radiochoice',selectedVal);
        }
        //if(lookupSelectedId != null){
            component.find('ICDLookup').set("v.disabledAttr","false");
            _this.resetLookupComponent(component, event,'ICDLookup');
            _this.resetLookupComponent(component, event, 'ConditionDescriptionLookup');
            component.find('ConditionDescriptionLookup').set("v.disabledAttr","false");

            // _this.refreshComponent(component, event, helper);
            component.set('v.optionSelection','radio');
            
       // }
    },
    
    resetLookupComponent: function(component,event,objName){
        var pillTarget =  component.find(objName).find("lookup-pill");
        var lookUpTarget =  component.find(objName).find("lookupField"); 
        var searchRes =  component.find(objName).find("searchRes");
        
        $A.util.addClass(pillTarget, 'slds-hide');
        $A.util.removeClass(pillTarget, 'slds-show');
        
        $A.util.addClass(lookUpTarget, 'slds-show');
        $A.util.removeClass(lookUpTarget, 'slds-hide');
        
        component.find(objName).set("v.SearchKeyWord",null);
        component.find(objName).set("v.listOfSearchRecords", null );
        
        component.find(objName).set("v.selectedRecord", {} ); 
        
    },
    
    
    mapLookupComponentSelection: function(component,objName,selectedObject) {
        var pillTarget =  component.find(objName).find("lookup-pill");
        var lookUpTarget =  component.find(objName).find("lookupField"); 
        var searchRes =  component.find(objName).find("searchRes");
        var selectedQualifyingValues;
        
        $A.util.addClass(pillTarget, 'slds-show');
        $A.util.removeClass(pillTarget, 'slds-hide');
        
        $A.util.addClass(searchRes, 'slds-is-close');
        $A.util.removeClass(searchRes, 'slds-is-open');
        
        $A.util.addClass(lookUpTarget, 'slds-hide');
        $A.util.removeClass(lookUpTarget, 'slds-show');  
        
        component.find(objName).set("v.SearchKeyWord","");
        var getSelectedRecord = component.get("v.selectedRecord");
        if(objName != 'ICDLookup'){
            selectedQualifyingValues = {
                'icdCodeId' : getSelectedRecord.Id,
                'icdCodeName' : getSelectedRecord.Name,
                'condDescriptionName' : (getSelectedRecord.Condition_Description__r) ? getSelectedRecord.Condition_Description__r.Name  : null
            }
        }else{
            var getSelectedRecord = component.get("v.conditionDescselectedRecord");
            selectedQualifyingValues = {
                'icdCodeId' : null,
                'icdCodeName' : (selectedObject.Name) ? selectedObject.Name : null,
                'condDescriptionName' : getSelectedRecord.Name
            }
        }
        component.set("v.qualifyingRecordObject", selectedQualifyingValues);
        component.find(objName).set("v.selectedRecord", selectedObject);   
    },
    
    resetLookupValues: function(component, event){
        var _this = this;
        if(event.getParam('compmessage') == 'icdcode'){
            component.find('ConditionDescriptionLookup').set("v.disabledAttr","false");
            $A.util.removeClass(component.find('ConditionDescriptionLookup'),'pillDisabled');
            _this.resetLookupComponent(component, event, 'ConditionDescriptionLookup');
        }else{
            component.find('ICDLookup').set("v.disabledAttr","false");
            $A.util.removeClass(component.find('ICDLookup'),'pillDisabled');
            _this.resetLookupComponent(component, event,'ICDLookup');
        }
    },
    
    resetRadioButtonValues: function(component,event,helper) {
        var radioSelection = component.get('v.radiochoice'),
            _this = this,
            selectedRecordObject,
            selectedMapObject,
            selectedQualifyingValues,
            condLookup = component.find('ConditionDescriptionLookup'),
            icdcodeLookup = component.find('ICDLookup'),
            compMessage = event.getParam('compmessage');
        if(radioSelection != null){
            var radioElement = document.getElementById('radio-' + radioSelection).checked;
            if(radioElement) document.getElementById('radio-' + radioSelection).checked = false;
            
            $A.util.removeClass(condLookup.find('light-pill'),'pillDisabled');
            $A.util.removeClass(icdcodeLookup.find('light-pill'),'pillDisabled');
            
            if(compMessage == 'icdcode'){
                component.set("v.lookupSelection", false);
                selectedRecordObject = component.get('v.selectedRecord');
                if(selectedRecordObject.Condition_Description__r){
                    selectedMapObject = {
                        'Id' : selectedRecordObject.Condition_Description__r.Id,
                        'Name' : selectedRecordObject.Condition_Description__r.Name
                    }
                    _this.mapLookupComponentSelection(component,'ConditionDescriptionLookup',selectedMapObject);
                    $A.util.addClass(condLookup.find('light-pill'),'pillDisabled');
                    $A.util.removeClass(icdcodeLookup.find('light-pill'),'pillDisabled');
                }else {
                    selectedQualifyingValues = {
                        'icdCodeId' :  selectedRecordObject.Id,
                        'icdCodeName' : selectedRecordObject.Name,
                        'condDescriptionName' : null
                    }
                    component.set("v.qualifyingRecordObject", selectedQualifyingValues);
                    condLookup.set("v.disabledAttr","true");
                }
            }else{
                selectedRecordObject = component.get('v.conditionDescselectedRecord');
                if(selectedRecordObject.Code_To_Use__c){
                    selectedMapObject = {
                        'Name' : selectedRecordObject.Code_To_Use__c
                    }
                    _this.mapLookupComponentSelection(component,'ICDLookup',selectedMapObject);
                    component.set("v.lookupSelection", true);
                    $A.util.addClass(icdcodeLookup.find('light-pill'),'pillDisabled');
                    $A.util.removeClass(condLookup.find('light-pill'),'pillDisabled');
                }else{
                    component.set("v.lookupSelection", false);
                    selectedQualifyingValues = {
                        'icdCodeId' : null,
                        'icdCodeName' : null,
                        'condDescriptionName' : selectedRecordObject.Name
                    }
                    component.set("v.qualifyingRecordObject", selectedQualifyingValues);
                    icdcodeLookup.set("v.disabledAttr","true");
                }
            }
            
            component.set('v.optionSelection','lookup');
        }
    },
    
    getIcdCode: function(component,event,Name){
        var _this = this,
            Qualifying_Diagnosis = '',
            Qualifying_ICD = '',
            leadData,qualifyingDiagonsisValues,
            actionName = "c.getIcdCodeInfo",
            params = {
                "icdCodeName": Name
            };
        _this.callAction(component, actionName, params, function(response){
            leadData = component.get("v.leadData");
            qualifyingDiagonsisValues  = component.get('v.qualifyingRecordObject');
            Qualifying_Diagnosis = (qualifyingDiagonsisValues.condDescriptionName) ? qualifyingDiagonsisValues.condDescriptionName : null;
            Qualifying_ICD = response;
            component.set("v.ICDCodeId", response);     
            _this.processDiagnosis(leadData,component,Qualifying_Diagnosis,Qualifying_ICD);
        });               
    },
    
    updateQualifyingDiagnosis: function(component,event){
        var _this = this,
            Qualifying_Diagnosis = '',
            Qualifying_ICD = '',
            selectedValue,
            leadData = component.get("v.leadData"),
            optionSelection = component.get('v.optionSelection');
        
        if(optionSelection == 'lookup'){
            var selectedRecordObject = component.get('v.selectedRecord'),
                lookupSelection = component.get("v.lookupSelection"),
                qualifyingDiagonsisValues  = component.get('v.qualifyingRecordObject');
            Qualifying_Diagnosis = (qualifyingDiagonsisValues.condDescriptionName) ? qualifyingDiagonsisValues.condDescriptionName : null;
            if(lookupSelection){
                _this.getIcdCode(component,event,selectedRecordObject.Name,leadData,Qualifying_Diagnosis);
            }else{
                Qualifying_ICD = qualifyingDiagonsisValues.icdCodeId;
                _this.processDiagnosis(leadData,component,Qualifying_Diagnosis,Qualifying_ICD);
            }
            
        }else{
            var selectedValue = component.get("v.radiochoice");
            if(leadData && leadData.Lead__r){
                var leadRelation = leadData.Lead__r,
                    PDConDescription = (leadRelation.PD_Condition_Description__c) ? leadRelation.PD_Condition_Description__c : null,
                    PDICD_code = (leadRelation.PD_ICD_Code__r) ? leadRelation.PD_ICD_Code__r.Id : null,
                    SDConDescription = (leadRelation["SD" + selectedValue + "_Condition_Description__c"]) ? leadRelation["SD" + selectedValue + "_Condition_Description__c"] : null,
                    SDICD_code = (leadRelation["SD" + selectedValue + "_ICD_Code__r"]) ? leadRelation["SD" + selectedValue + "_ICD_Code__r"].Id : null,
                    Qualifying_Diagnosis = (selectedValue == 0) ? PDConDescription : SDConDescription,
                    Qualifying_ICD = (selectedValue == 0) ? PDICD_code : SDICD_code ;
                _this.processDiagnosis(leadData,component,Qualifying_Diagnosis,Qualifying_ICD);
            }
        }
        
    },
    
    processDiagnosis: function(leadData,component,Qualifying_Diagnosis,Qualifying_ICD){
        var _this = this,
          leadToUpdate = {            
            "Qualifying_Diagnosis" : Qualifying_Diagnosis,
            "Qualifying_ICD" : Qualifying_ICD,
             "leadId": leadData.Lead__c,
        };
        
        var actionName = "c.updateQualifyingDiagnosis";
        _this.callAction(component, actionName, leadToUpdate, function(response){
            _this.refreshPage(leadData.Id,component);
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": "Success!",
                "message": "Qualifying diagnosis was successfully updated.",
                "type": "success"
            });
            toastEvent.fire();
            component.set("v.ICDCodeId",null);
        });
    },
    
    refreshPage: function(Id,component){
        //Refresh current lead record page
        var _this = this;        
        var navEvt = $A.get("e.force:navigateToSObject");
        var createEvent = component.getEvent("onchange");
        createEvent.fire();
    },
    navigateTo: function(url){
        //utility - navigate to specified URL
        $A.get("e.force:navigateToURL").setParams({"url": url}).fire();
    },
    handleConfirmation: function(isBtnAction, component, msgToDisplay, callback, isAlert){ 
        //Confirmation box handler
        var _this = this;        
        if(isBtnAction){
            component.set("v.showLoader", true);
            _this.globalParams.confHandler();
        }else{
            component.set("v.showCancelBtn", !isAlert)
            component.set("v.dispMsg", msgToDisplay);
            component.set("v.showLoader", false);
            _this.globalParams.confHandler = callback;
        }
    },
    closeQuickAction: function(){
        //utility - Close the current quick action
        $A.get("e.force:closeQuickAction").fire();
    },
    callAction: function(component, actionName, params, callback){        
        var action = component.get(actionName);
        action.setParams(params);
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                callback(response.getReturnValue());                
            }else{
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Failure!",
                    "message": "Failed to process data",
                    "type": "error"
                });
                toastEvent.fire();
            }
        });
        $A.enqueueAction(action);
    }
})