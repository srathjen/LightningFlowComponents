/*
Modification Log:
1. 03/28/2018 - Yuvraj - IME-59 - Line No: 48, 70, 95, 112-116
2. 25/04/2018 - Vignesh SM - IME 131 - Line No. 73, 100, 103-106
3. 12/07/2018 - Vignesh SM - IME 231
4. 06/01/2020- Brittany SIW-543
*/({
    globalParams:{            
    },
    processLeadForDV : function(component) {
        //Get Lead information and send for further processing
        
        var _this = this;
        var actionName = "c.getLeadInformation";
        var params = {
            "leadId": component.get("v.recordId")
        };
        _this.callAction(component, actionName, params, function(response){
            component.set("v.leadData", response);
            _this.handleDiagnosisVerficationProcess(response, component);
        });                     
    },
    handleDiagnosisVerficationProcess: function(lead, component){
        //Handle diagnosis verfication - checking criteria and send to appropriate processing
        
        var _this = this,
            leadId = component.get("v.recordId"),
            descIcd_criteria = lead.PD_Condition_Description__c || lead.PD_ICD_Code__c,
            statusCriteria = lead.Sub_Status__c == 'Pending Diagnosis Verification' || lead.Status == 'Eligibility Review';

        if(descIcd_criteria){            
            
            if(statusCriteria){
                _this.handleMediProfessional(lead, component);
            }else if(lead.Status != 'Referred'){
                _this.handleReferredLead(lead.Status, component);                               
            }else{
                _this.handleLeadDupe(lead, component);
            }
        }else {
            _this.handleConfirmation(false, component, "Please Enter ICD Code or Condition Description", function(){
                _this.closeQuickAction();
            }, true);
        }        
    },
    handleLeadDupe: function(lead, component){
        //find for lead dupe
        
        var _this = this,
            paperDVProcess = lead.Using_Paper_Process_For_DV__c;
        //IME 272
        var leadDupe;
        var familyContactDupe;
        var notBlocked = lead.Dup_Check__c != 'Block Lead Dup';
        var notBlockedContact = lead.Contact_Dup_Check__c != 'Block Contact Dup';
        var priorWish = lead.Has_this_child_ever_received_prior_wish__c;
        var medProfessionalEmail = lead.Treating_Medical_Professional_Email__c || lead.Best_contact_for_Physician_Email__c || lead.Alternate1MedicalProfessionalEmail__c || lead.Alternate2MedProfessionalEmail__c;
        var params = {
            "leadId": lead.Id
        };
        //IME 272/**/
        _this.callAction(component, "c.findLeadDupe", params, function(response){
            leadDupe = response;
            
            if(leadDupe && notBlocked) {
                _this.handleConfirmation(false, component, leadDupe, function(){
                    _this.navigateTo("/apex/LeadDuplicate_VF?id=" + lead.Id);    
                }, false);
            }else if(!leadDupe || !notBlocked){
                if(priorWish && priorWish.toLowerCase().indexOf('yes') !=-1 ) {
                    _this.handleConfirmation(false, component, "Diagnosis verification cannot be sent as this child has received prior wish.", function(){
                        _this.closeQuickAction();
                    }, true);
                }else if(!medProfessionalEmail && !paperDVProcess) { //Modified as per IME 131
                    _this.handleConfirmation(false, component, "Please provide Treating/Best physician/Alternate Medical Professional Email or Using Paper Process for DV.", function(){
                        _this.closeQuickAction();
                    }, true);
                }else {
                    //IME 272
                    _this.callAction(component, "c.findFamilyContactDupe", params, function(response){
                        familyContactDupe = response;
                        if(familyContactDupe && notBlockedContact){
                            _this.handleConfirmation(false, component, familyContactDupe, function(){
                                _this.navigateTo("/apex/LeadDuplicate_VF?id=" + lead.Id + "&wishFamily=true");
                            }, false);                     
                        } else if(!familyContactDupe || !notBlockedContact) { 
                            _this.handleMediProfessional(lead, component);
                        } 
                    });                   
                } 
            }
        });
    },
    handleMediProfessional: function(lead, component){
        //Check for medical professional
        
        var _this = this,
            paperDVProcess = lead.Using_Paper_Process_For_DV__c,
            AgeRequirementNotMet = lead.Child_Age__c == 'Under 2.5' || lead.Child_Age__c == '18 & Above'; 
          
        if(!paperDVProcess){
            var verificationMessage = "Are you sure you want to submit Diagnosis Verification?";
            if (AgeRequirementNotMet){
                verificationMessage = "This child did not meet our referral age. A DV should not be sent for this child unless your chapter has received a waiver from the Chapter Performance Committee. " + verificationMessage;
            }
            _this.handleConfirmation(false, component, verificationMessage, function(){
               var checkMedProf = lead.Treating_Medical_Professional_Email__c, 
                   checkAltProf = lead.Best_contact_for_Physician_Email__c || lead.Alternate1MedicalProfessionalEmail__c || lead.Alternate2MedProfessionalEmail__c,
                   mediProf_criteria =  checkMedProf || checkAltProf;
  
                
                if(checkAltProf || checkMedProf) {                                
                    _this.navigateTo("/apex/LeadSelectMedEmail_VF?id=" + lead.Id);      
                }else {
                    _this.handleConfirmation(false, component, "Please provide Treating/Best physician/Alternate Medical Professional Email or Using Paper Process for DV.", function(){
                        _this.closeQuickAction();
                    }, true);
                } 
                         
            }, false);
        } else {
            _this.handleConfirmation(false, component, "No potential duplicates found. Please send the Paper Diagnosis Verification Form manually.", function(){
                _this.closeQuickAction();
            }, true);
        }       
    },    
    handleReferredLead:function(leadStatus, component){
        //Check lead in referred status
        
        var _this = this;
        var msg = "Diagnosis verification cannot be sent when lead is in " + leadStatus + " status.";
        _this.handleConfirmation(false, component, msg, function(){
            _this.closeQuickAction();
        }, true);
    },
    /*IME 231
     * updateLeadRec: function(medProfType, lead, component){
        //Update/Reset Lead Record with appropriate values when sending DV
        
        var _this = this;
        var params = {
            leadId: lead.Id
        };
        //Modified as per IME 122
        if(lead.Part_A_Sent__c) { //has it sent before
            var err_PartARecieved = "Are you sure you want to proceed? A Diagnosis Verification has already been sent and signed. Clicking Yes will reset all values in the DV form, and archive previous signed versions (in Docusign Status section) which cannot be undone.",
                err_PartASentOnly = "Are you sure you want to proceed? A Diagnosis Verification has already been sent for this wish child.",
                confirmationMsg = lead.Part_A_Received__c? err_PartARecieved:err_PartASentOnly;
            
            _this.handleConfirmation(false, component, confirmationMsg, function(){
                try {
                    
                    _this.callAction(component, "c.resetDVMedicalSummary", params, function(){                        
                        _this.handleConfirmation(false, component, "Diagnosis Verification sent successfully.", function(){
                            _this.refreshPage(lead.Id);
                        }, true);
                    });
                } catch(e) {
                    _this.handleConfirmation(false, component, "An unexpected error has occurred. The system administrator has been alerted.", function(){
                        _this.closeQuickAction();
                    }, true);
                } 
            }, false); 
        } else { 
           _this.sendToTreatingMedProf(medProfType, lead, component); 
        } 
    },*/
    /*IME 231
     * sendToTreatingMedProf : function(medProfType, lead, component){
        var _this = this;
        var leadToUpdate = {            
            "leadId": lead.Id,
            "HiddenDVformMedicalprofessionalType": medProfType,
            "OfTimesEmailSent": lead.Of_Times_Email_Sent__c? (parseInt(lead.Of_Times_Email_Sent__c) + 1) : 0,
            "HiddenMedicalProfessionalEmail":  lead.Treating_Medical_Professional_Email__c,
            "SubStatus": "Pending Diagnosis Verification"
        };
        
        _this.callAction(component, "c.updateLead", leadToUpdate, function(){
            _this.handleConfirmation(false, component, "Diagnosis Verification sent successfully.", function(){
                _this.refreshPage(lead.Id);
            }, true);
        });       
    },*/
    refreshPage: function(Id){
        //Refresh current lead record page
        
        var _this = this;        
        var navEvt = $A.get("e.force:navigateToSObject");
        
        _this.closeQuickAction();
        navEvt.setParams({
            "recordId": Id
        });
        navEvt.fire();
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
        var _this = this;
        var action = component.get(actionName);
        
        action.setParams(params);
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                callback(response.getReturnValue());                
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                var toastEvent = $A.get("e.force:showToast");
                var message = "Failed to process data";
                
                if (errors && errors[0] && (errors[0].message || (errors[0].pageErrors[0] && errors[0].pageErrors[0].message))) {                           
                    message = errors[0].message || errors[0].pageErrors[0].message;                                        
                } 
                toastEvent.setParams({
                    "title": "Failure!",
                    "message": message,
                    "type": "error"
                });
                toastEvent.fire();
                _this.closeQuickAction();
            }
        });
        $A.enqueueAction(action);
    }
})