({
    select : function(cmp, event, helper) {
        let lookupId = cmp.get('v.lookupId');
        let record = cmp.get('v.record');
        let selectEvent = cmp.getEvent('lookupSObjectSelect');
        selectEvent.setParams({
            'lookupId': lookupId,
            'recordId': record['Id'],
            'recordName': record['Description']
        });
        selectEvent.fire();
    }
});