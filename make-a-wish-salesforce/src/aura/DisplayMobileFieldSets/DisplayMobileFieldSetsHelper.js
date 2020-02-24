/**
 * @description Javascript helper for the DisplayMobileFieldSets lightning component
 * @author      Mason Buhler, Traction on Demand
 * @date        2019-07-25
 */
({
    /**
     * Load data for the component
     *
     * @param component                    Component reference
     */
    fetchData: function (component) {
        let action = component.get('c.getFieldSets');

        action.setParams({
            sObjectName: component.get('v.sObjectName')
        });

        action.setCallback(this, function (response) {

            if (response.getState() === "SUCCESS") {
                let returnValue = response.getReturnValue();
                component.set("v.fieldSetsList", returnValue);
            } else {
                let toastEvent = $A.get("e.force:showToast");
                let errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log('Error: ' + errors[0].message);
                    }
                }
                toastEvent.fire();
            }
        });
        $A.enqueueAction(action);
    }
});