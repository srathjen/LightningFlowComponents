/**
 * @author Steve Doucette, Traction on Demand 
 * @date 3/16/2020
 */
public with sharing class BackgroundCheckFileService {

    /**
     * @param newBackgroundCheckFiles
     */
    public static void updateBackgroundCheckFilePath(List<Background_Check_File__c> newBackgroundCheckFiles){
        List<Id> bcIds = new List<Id>();
        Map<Id,String> BCFileMap = new Map<Id,String>();
        for(Background_Check_File__c bc: newBackgroundCheckFiles){
            bcIds.add(bc.Id);
            BCFileMap.put(bc.Id,String.valueOf(bc));
        }
        AWSFilePathService.updateBackgroundCheckFilePath(bcIds,BCFileMap);
    }
}