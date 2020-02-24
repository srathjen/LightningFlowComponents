({
    toggleModal : function(cmp, event, helper) {
        if(cmp.get('v.modal-size')) $A.util.toggleClass(cmp.find("modal"),'slds-modal_medium');        
        if(cmp.get('v.confirmboxActive')) $A.util.toggleClass(cmp.find("modal"),'slds-modal-alertbox');
        $A.util.toggleClass(cmp.find("modal"),'slds-fade-in-open');
        $A.util.toggleClass(cmp.find("modal-backdrop"),'slds-backdrop--open');
    },
})