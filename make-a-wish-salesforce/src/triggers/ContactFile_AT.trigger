trigger ContactFile_AT on cg__ContactFile__c (After insert) {
    List<Id> contactIds = new List<Id>();
    for(cg__ContactFile__c con: Trigger.new){
        contactIds.add(con.Id);
    }
    if(contactIds.size() >0)
        AWSFilePath_AC.updateContactFilePath(contactIds);
}