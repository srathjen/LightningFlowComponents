/**************************************************************************************
Author       : MST Solutions
Created Date : 08/11/2016
Description  : 
***************************************************************************************/
public class Affiliation_OnAfterDeleteTriggerHandler
{
    /* This method will be called after record is deleted and it is fired,
       to remove the user to the public group to restrict the approved In-Kind donor account record based on the affiliation record*/   
    public static void OnAfterDelete(List<npe5__Affiliation__c> deletelist)
    {
        Set<String> vlounteerNameSet = new Set<String>();
        Set<String> chapterNameSet = new Set<String>();
        Set<Id> affiliationSet = new Set<Id>();
        Map<Id,String> affliationRecMap = new Map<Id,String>();
        for(npe5__Affiliation__c currentRecord : deletelist)
        {
            vlounteerNameSet.add(currentRecord.npe5__Contact__c);
            chapterNameSet.add(currentRecord.npe5__Organization__c);  
            affiliationSet.add(currentRecord.id);
            affliationRecMap.put(currentRecord.id,String.valueOf(currentRecord));
        }
        
        if(vlounteerNameSet.size() > 0 && chapterNameSet.size() > 0 && affiliationSet.size() > 0)
        {
            Affiliation_OnAfterDeleteTriggerHelper.removeMemberFromGroup(vlounteerNameSet,chapterNameSet,affiliationSet,affliationRecMap);
        }
    }
}