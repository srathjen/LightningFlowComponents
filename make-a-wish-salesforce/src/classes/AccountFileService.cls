/**
 * @author Steve Doucette, Traction on Demand 
 * @date 3/16/2020
 */
public with sharing class AccountFileService {
    /**
     * @param newAccountFiles
     */
    public static void updateAccountFilePath(List<cg__AccountFile__c> newAccountFiles) {
        List<Id> accountFileIds = new List<Id>();
        Map<Id, String> accountFileMap = new Map<Id, String>();
        for (cg__AccountFile__c accountFile : newAccountFiles) {
            accountFileIds.add(accountFile.Id);
            accountFileMap.put(accountFile.Id, String.valueOf(accountFile));
        }
        AWSFilePathService.updateAccountFilePath(accountFileIds, accountFileMap);
    }
}