/**
 * Created by mnahar on 8/20/2019.
 */
({
    createRecord: function (component, event) {
        var windowHash = window.location.hash;
        var createRecordEvent = $A.get("e.force:createRecord");
        createRecordEvent.setParams({
            "entityApiName": "Wish_Budget__c",
            "defaultFieldValues": {
                'Wish_Case__c': component.get("v.recordId")
            },
            "panelOnDestroyCallback": function (event) {
                console.log('Inside');
                //window.history.go(-2); 

            }
        });
        createRecordEvent.fire();
    },

})