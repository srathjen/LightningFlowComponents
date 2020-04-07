/*****************************************************************************************************************
Author      : MST Solutions
Date        : 8/23/2016
Description : This Class is used for volunteers to  share the wish family contact to volunteers
*******************************************************************************************************************/
public class Hidden_ContactShareController_AC {

    Contact con;
    public Hidden_ContactShareController_AC(ApexPages.StandardController controller) {
        con = (Contact) controller.getRecord();
    }

    //Share contact with read access to volunteer.
    public void shareContact() {
        User currentUser = Utils.currentUser;
        if (currentUser.ContactId != null) {
            Set<Id> conIdSet = new Set<Id>();
            conIdSet.add(con.Id);
            for (npe4__Relationship__c currRel : [
                    SELECT Id,npe4__RelatedContact__c
                    FROM npe4__Relationship__c
                    WHERE npe4__Contact__c = :con.Id
            ]) {
                conIdSet.add(currRel.npe4__RelatedContact__c);
            }

            Set<Id> sharedRecIdSet = new Set<Id>();
            for (UserRecordAccess userAccess : [
                    SELECT RecordId
                    FROM UserRecordAccess
                    WHERE UserId = :currentUser.Id AND RecordId IN :conIdSet
                    AND HasReadAccess = TRUE
            ]) {
                sharedRecIdSet.add(userAccess.RecordId);
            }

            try {
                List<ContactShare> contactToShareList = new List<ContactShare>();
                for (Id conId : conIdSet) {
                    if (!sharedRecIdSet.contains(conId)) {
                        ContactShare shareContact = new ContactShare();
                        shareContact.ContactId = conId;
                        shareContact.ContactAccessLevel = Constant_AC.RECORD_SHARE_READ;
                        shareContact.UserOrGroupId = currentUser.Id;
                        contactToShareList.add(shareContact);
                    }
                }
                insert contactToShareList;
            } catch (Exception ex) {
                System.debug(ex);
            }
        }
    }
}