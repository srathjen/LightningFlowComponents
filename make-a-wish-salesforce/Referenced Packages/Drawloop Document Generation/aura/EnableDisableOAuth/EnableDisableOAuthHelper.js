({
    toggleOAuthButtons : function(component) {
        if (component.get('v.oAuthEnabled')) {
            $A.util.addClass(component.find('enabledButton'), 'slds-button--brand');
            $A.util.removeClass(component.find('disabledButton'), 'slds-button--brand');
            component.find('enabledButton').getElement().disabled = true;
            component.find('disabledButton').getElement().disabled = false;
        } else {
            $A.util.addClass(component.find('disabledButton'), 'slds-button--brand');
            $A.util.removeClass(component.find('enabledButton'), 'slds-button--brand');
            component.find('disabledButton').getElement().disabled = true;
            component.find('enabledButton').getElement().disabled = false;
        }
    }
})