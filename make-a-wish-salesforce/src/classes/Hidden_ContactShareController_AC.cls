/*****************************************************************************************************************
Author      : MST Solutions
Date        : 8/23/2016
Description : This Class is used for volunteers to  share the wish family contact to volunteers
*******************************************************************************************************************/
 

public class Hidden_ContactShareController_AC {
    public String test{get;set;}
    Contact con;
    public Hidden_ContactShareController_AC(ApexPages.StandardController controller) {
        con =(Contact) controller.getRecord();
    }
    //Share contact with read access to volunteer.
    public void shareContact(){        
        Set<Id> conIdSet = new Set<Id>();
        test = con.Id;
        List<contactShare> contactToShareList  = new List<contactShare>();
        conIdSet.add(con.Id);
        User currentUser = [SELECT Id FROM User WHERE Id =: UserInfo.getUserId() AND ContactId != Null LIMIT 1];
        if(currentUser != Null){
        Set<Id> sharedRecIdSet = new Set<Id>();
        for(npe4__Relationship__c currRel : [SELECT Id,npe4__RelatedContact__c FROM npe4__Relationship__c WHERE npe4__Contact__c =: con.Id]){
            conIdSet.add(currRel.npe4__RelatedContact__c);
        }
        for(UserRecordAccess userAccess: [SELECT RecordId FROM UserRecordAccess WHERE UserId =: UserInfo.getUserId() AND RecordId IN :conIdSet AND HasReadAccess = True]){
        //for(ContactShare userAccess :  [SELECT ContactId FROM ContactShare WHERE UserOrGroupId =: UserInfo.getUserId() AND ContactId IN :conIdSet ]){
            sharedRecIdSet.add(userAccess.RecordId);
        }
       
        for(Id conId : conIdSet ){
            
            if(!sharedRecIdSet.Contains(conId)){
                  ContactShare shareContact = new ContactShare();
                  shareContact.ContactAccessLevel = 'Read';   
                  shareContact.ContactId = conId;
                  shareContact.UserOrGroupId = UserInfo.getUserId();
                  contactToShareList.add(shareContact);
                  system.debug('shareContact ******'+shareContact);
            }
            
        }
       
     
        If(contactToShareList.Size() > 0){
            Insert contactToShareList;
            system.debug('contactToShareList******'+contactToShareList);
        }    
       }
    
    }

}