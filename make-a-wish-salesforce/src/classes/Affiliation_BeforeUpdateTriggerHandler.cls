/**************************************************************************************
Author       : MST Solutions
Created Date : 08/11/2016
Description  : This class is used as handler to AffiliationReviewTrigger_AT for updating 
               Primary as True when affiliation record is creating for contact as a first record
               and used to add user to chatter group when the user becomes active for the chapter
***************************************************************************************/
public class Affiliation_BeforeUpdateTriggerHandler
{
     /* This method will be called before record is updated and it is fired, this used to get affiliation's
       crossponding user name and email to merge in active user welcome email template*/
    public static void OnBeforeUpdate(List<npe5__Affiliation__c> beforeUpdateList,Map<Id,npe5__Affiliation__c> oldMapBeforeUpdate)
    {
        Set<Id> contactIdsSet = new Set<Id>();
        List<npe5__Affiliation__c> UpdateAffiliationList = new List<npe5__Affiliation__c>();
        Map<Id,User>volunteerUserMap = new map<Id,User>();
        for(npe5__Affiliation__c currRec : beforeUpdateList)
        {
            if((currRec.npe5__Status__c != Null && currRec.npe5__Status__c == 'Active') && (oldMapBeforeUpdate.get(currRec.id).npe5__Status__c != currRec.npe5__Status__c))
            {
                contactIdsSet.add(currRec.npe5__Contact__c);
            }
        }
        for(User currUser : [SELECT ID,Username,ContactId,Email FROM User WHERE ContactId IN:contactIdsSet])
        {
            if(contactIdsSet.contains(currUser.ContactId))
            {
                volunteerUserMap.put(currUser.ContactId, currUser);
            }
        }
        
        for(npe5__Affiliation__c currRec : beforeUpdateList)
        {
            if((currRec.npe5__Status__c != Null && currRec.npe5__Status__c == 'Active') && (volunteerUserMap.containsKey(currRec.npe5__Contact__c)))
            {
                currRec.User_Name_Hidden__c = volunteerUserMap.get(currRec.npe5__Contact__c).Username;
                currRec.User_Email_Hidden__c = volunteerUserMap.get(currRec.npe5__Contact__c).Email;
            }
        }
    }
}