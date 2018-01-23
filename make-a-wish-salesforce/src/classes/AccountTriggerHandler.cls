public class AccountTriggerHandler {
    // This method is used to update garntingcase devstaffemail field whenever cpateraccount devstaffemail filed is changed
    public static void updateGrantingCaseDevStaffEmai(map<id,string> chapterEmailmap){
        
        Constant_AC constant = new Constant_Ac();
        String wishGrantRecordTypeId = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get(constant.wishGrantRT).getRecordTypeId();
        String parentWishRecordTypeId = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get(constant.parentWishRT).getRecordTypeId();
        list<Case> upadteCaseList = new list<Case>();
        
        for(Case grantingCase :[SELECT ID,RecordTypeId,ParentId,Parent.ChapterName__c,Dev_Staff_Email__c FROM Case WHERE Parent.ChapterName__c IN: chapterEmailmap.keySet() AND RecordTypeId =: wishGrantRecordTypeId AND isClosed = false]){
            if(chapterEmailmap.containsKey(grantingCase.Parent.ChapterName__c)){
                grantingCase.Dev_Staff_Email__c = chapterEmailmap.get(grantingCase.Parent.ChapterName__c);
                upadteCaseList.add(grantingCase);
            }
        }
        
        if(upadteCaseList.size() > 0){
            update upadteCaseList;
        }
    }
    
    //Used to populate chaptername and chapter email
    public static void matchChapterForInkindAccount(Set<Id> ownerIdSet, List<Account> newInkAccountList) {
        Map<Id, Account> chapterMap = new Map<Id, Account>();
        Map<Id, Id> ownerChapterMap = new Map<Id, Id>();
        Map<String, Id> nonPortalChapterMap = new Map<String, Id>();
        Map<Id, String> ownerNoPortalMap = new Map<Id, String>();
        for(Account chapterInfo : [SELECT Id, Name, Wish_Co_ordinator__r.Email FROM Account WHERE RecordType.Name = 'Chapter']) {
            chapterMap.put(chapterInfo.Id, chapterInfo);
            nonPortalChapterMap.put(chapterInfo.Name.remove('Make-A-Wish ')+' - Chapter', chapterInfo.Id);
        }
        
        for(User checkUserType : [SELECT Id, ContactId, UserRole.Name, contact.AccountId FROM User WHERE Id IN : ownerIdSet]) {
            if(checkUserType.ContactId != NULL) {
                //For portal user
                ownerChapterMap.put(checkUserType.Id, checkUserType.Contact.AccountId);
            } else if(checkUserType.UserRole.Name != NULL && checkUserType.UserRole.Name != 'National Staff') {
                //For non portal user
                ownerNoPortalMap.put(checkUserType.Id, checkUserType.UserRole.Name);
            }
            
        }
        
        for(Account matchChapter : newInkAccountList) {
            if(ownerChapterMap.containsKey(matchChapter.OwnerId)) {
                if(chapterMap.containsKey(ownerChapterMap.get(matchChapter.OwnerId))) {
                    matchChapter.Wish_Co_ordinator_Hidden_Email__c = chapterMap.get(ownerChapterMap.get(matchChapter.OwnerId)).Wish_Co_ordinator__r.Email;
                    matchChapter.Chapter_Name__c = chapterMap.get(ownerChapterMap.get(matchChapter.OwnerId)).Id;
                }
            } else if(ownerNoPortalMap.containsKey(matchChapter.OwnerId)) {
                if(nonPortalChapterMap.containsKey(ownerNoPortalMap.get(matchChapter.OwnerId))) {
                    if(chapterMap.containsKey(nonPortalChapterMap.get(ownerNoPortalMap.get(matchChapter.OwnerId)))){
                        matchChapter.Wish_Co_ordinator_Hidden_Email__c = chapterMap.get(nonPortalChapterMap.get(ownerNoPortalMap.get(matchChapter.OwnerId))).Wish_Co_ordinator__r.Email;
                    }
                    matchChapter.Chapter_Name__c = nonPortalChapterMap.get(ownerNoPortalMap.get(matchChapter.OwnerId));
                }
            } else if(matchChapter.Chapter_Name__c == NULL && !ownerNoPortalMap.containsKey(matchChapter.OwnerId) && !ownerChapterMap.containsKey(matchChapter.OwnerId)) {
                matchChapter.addError('Please select Chapter Name');
            }
        }
    }
}