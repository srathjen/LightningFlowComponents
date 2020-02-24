({
    handleChange : function(component, event, helper) {
        // Check validity of all required fields whose auraId is called 'input'.
        
        let isAllValid = component.find('input').reduce(function(isValidSoFar, inputCmp)
                                                        {
                                                            //Error messages should display at field level.
                                                            inputCmp.reportValidity();
                                                            //check if validity conditions are met or not.
                                                            return isValidSoFar && inputCmp.checkValidity();
                                                        },
                                                        true);
        
        console.log('All required fields are valid: ' + isAllValid);
        
        if(isAllValid){ 
            var response = event.getSource().getLocalId();
            component.set("v.formValue", response); 
            var navigate = component.get("v.navigateFlow");
            navigate("NEXT");
        }

    },
    
})