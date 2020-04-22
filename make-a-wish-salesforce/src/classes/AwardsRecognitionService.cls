/**
* @description Centralizes business rules for Awards and Recognition
* @author Michelle Cominotto, Make-A-Wish
* @createdDate 4/20/2020
*/
public class AwardsRecognitionService {
  
    private final static String ROLE_NATIONAL_STAFF = Constant_AC.ROLE_NATIONAL_STAFF;
    private final static String PROFILE_INTEGRATION = Constant_AC.PROFILE_INTEGRATION;
    private final static String PROFILE_SYSTEM_ADMINISTRATOR = Constant_AC.PROFILE_SYSTEM_ADMINISTRATOR;
    
    /**
    * Check if current user has privileges to update record based on chapter and role
    * @param awardsRecognitionList
    */
    public static void checkChapterRolePermission(List<Awards_Recognition__c> awardsRecognitionList) {
        User currentUser = Utils.currentUser;
        Map<Id, Awards_Recognition__c> awardsRecognitionMap = new Map<Id, Awards_Recognition__c>();
        Set<String> chapterNameSet = new Set<String>();
        Map<Id, String> chapterNameMap = new Map<Id, String>();
        Map<String, String> chapterRoleMap = new Map<String, String>();
        
        for(Awards_Recognition__c award : awardsRecognitionList) {
            if(award.Chapter_Name__c != null) {
                awardsRecognitionMap.put(award.Id, award);
            }
        }
        if(awardsRecognitionMap.isEmpty() 
           || currentUser.UserRole.Name == ROLE_NATIONAL_STAFF 
           || currentUser.Profile.Name == PROFILE_SYSTEM_ADMINISTRATOR 
           || currentUser.Profile.Name == PROFILE_INTEGRATION) {
               return;
           }
        try {
            for(Awards_Recognition__c award : [
                SELECT Id, OwnerId, Owner.UserRoleId, Owner.UserRole.Name, Chapter_Name__c, Chapter_Name__r.Name
                FROM Awards_Recognition__c
                WHERE Id IN :awardsRecognitionMap.keySet() 
                AND Chapter_Name__c != null
            ]) {
                chapterNameSet.add(award.Chapter_Name__r.Name);
                chapterNameMap.put(award.Id, award.Chapter_Name__r.Name);
            }
            if(!chapterNameSet.isEmpty()) {
                chapterRoleMap = ChapterStaffRecordSharing_AC.findChapterRole(chapterNameSet);
                for(Awards_Recognition__c award : awardsRecognitionMap.values()) {
                    if(chapterRoleMap.get(chapterNameMap.get(award.Id)) != currentUser.UserRole.Name) {
                        award.addError('Insufficient previlege to update this record. Please contact system administrator.');
                    }
                }
            }
        } catch(Exception ex) {
            for(Awards_Recognition__c award : awardsRecognitionMap.values()) {
                ErrorMessage_AC.createdebugRec('AwardsRecognitionService', String.valueOf(award), String.valueOf(ex), 
                                               'showErrorMismatchedRole', award.Id, ex.getStackTraceString() + '   ' + ex.getMessage(), 'Error');
                award.addError(Label.Debug_log_error_message);
            }
        }
    }
    
    /**
    * Check if current user has privileges to update record based on chapter and role
    * @param newAwardsRecognitionList
    * @param oldAwardsRecognitionMap
    */
    public static void checkChapterRolePermission(List<Awards_Recognition__c> newAwardsRecognitionList, Map<Id, Awards_Recognition__c> oldAwardsRecognitionMap) {
        List<Awards_Recognition__c> awardsRecognitionList = new List<Awards_Recognition__c>();
        for(Awards_Recognition__c newAward : newAwardsRecognitionList) {
            if(newAward.Chapter_Name__c != oldAwardsRecognitionMap.get(newAward.Id).Chapter_Name__c) {
                awardsRecognitionList.add(newAward);
            }
        }
        if(!awardsRecognitionList.isEmpty()) {
            checkChapterRolePermission(awardsRecognitionList);
        }
    }
}
