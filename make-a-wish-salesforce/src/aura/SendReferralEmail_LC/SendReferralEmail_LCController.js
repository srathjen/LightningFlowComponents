({
    doInit : function(component, event, helper) {
        
        component.set('v.columns', [
            {label: 'Office Name', fieldName: 'Name', type: 'text'},
            {label: 'Referral Email Address', fieldName: 'Referral_Email_Address__c', type: 'text'}]);
         
        helper.processLead(component);
    },
    goBack : function(component, event, helper) {
        helper.goBack(component);
    },
    handleEmail : function(component, event, helper){
        var email = component.get("v.email");
        if(email){
            component.set("v.msg", "Sending non-onboarded referral email to "+ component.get("v.email"));
            helper.sendEmail(component);
        }else{
            component.set("v.msg", "Please select office record/Email address not found");
        }  
    },
    updateSelectedEmail: function (component, event) {
        var selectedRows = event.getParam('selectedRows');
        component.set("v.email", selectedRows[0].Referral_Email_Address__c);
    }
})