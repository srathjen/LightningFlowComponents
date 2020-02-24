({
    select : function(cmp, event, helper) {
        var lookupId = cmp.get('v.lookupId');
        var record = cmp.get('v.record');
        var selectEvent = cmp.getEvent('lookupSObjectSelect');

        selectEvent.setParams({
            'lookupId': lookupId,
            'recordId': record['Id'],
            'recordName': record['Description']
        });

        selectEvent.fire();
    }
});