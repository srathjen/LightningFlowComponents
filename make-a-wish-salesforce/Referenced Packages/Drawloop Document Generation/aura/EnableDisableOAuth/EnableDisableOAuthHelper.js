({
 	enable : function(cmp, selection, disable) {
        var button = cmp.find(selection);
        var element = button.getElement().childNodes[0];
       	element.removeAttribute('disabled', 'disabled');
        $A.util.removeClass(element, 'slds-button--brand');
        button.set("v.label", selection);
    },
    disable : function(cmp, selection) {
        var button = cmp.find(selection);
        var element = button.getElement().childNodes[0];
        element.setAttribute('disabled', 'disabled');
        $A.util.addClass(element, 'slds-button--brand');
        button.set("v.label", selection + "d");
    }
})