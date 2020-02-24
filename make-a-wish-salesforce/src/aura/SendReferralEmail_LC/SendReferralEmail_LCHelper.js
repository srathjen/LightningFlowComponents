({
    processLead : function(component) {
        //Get Lead information and send for further processing
        
        var _this = this;
        var actionName = "c.getOfficeViaLead"; 
        var params = {
            "leadId": component.get("v.recordId")
        };
        
        _this.callAction(component, actionName, params, function(response){
            if(response.length>0){
                var isNonOnBoarded = response[0].Chapter__r.Onboarded_on_SF__c;
                component.set("v.isNonOnBoarded", isNonOnBoarded);
                if(!isNonOnBoarded){
                    if(response.length > 1){
                        component.set("v.officeData", response);  
                    }else if(response.length == 1){
                        component.set("v.email", response[0].Referral_Email_Address__c);
                        component.set("v.msg", "Sending non-onboarded referral email to "+ response[0].Name + "(" + response[0].Referral_Email_Address__c +")");
                        _this.sendEmail(component);
                    }else{
                        component.set("v.msg", "No office records found");
                    }
                }  
            }else{
                component.set("v.msg", "No office records found to send non-onboarded referral email");
            }
            
        }); 
    },
    sendEmail: function(component){
        var _this = this;
        var actionName = "c.triggerEmail";
        var recordId = component.get("v.recordId");
        var params = {
            "leadId": recordId,
            "emailId": component.get("v.email")
        };
        if(component.get("v.email")){
            _this.callAction(component, actionName, params, function(response){
                setTimeout(function(){
                    component.set("v.msg", "Non-onboarded referral email sent successfully");
                    setTimeout(function(){ _this.goBack(component);}, 3000);
                }, 3000);                                
            });   
        }else{
            component.set("v.msg", "Email address not found");
        }     
    },
    goBack: function(component){
        $A.get("e.force:navigateToSObject").setParams({"recordId": component.get("v.recordId")}).fire();
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