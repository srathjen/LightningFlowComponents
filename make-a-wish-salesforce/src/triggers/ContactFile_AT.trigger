trigger ContactFile_AT on cg__ContactFile__c (After insert) {
    List<Id> contactIds = new List<Id>();
    for(cg__ContactFile__c con: Trigger.new){
        contactIds.add(con.Id);
    }
    AWSFilePath_AC.updateContactFilePath(contactIds);
}