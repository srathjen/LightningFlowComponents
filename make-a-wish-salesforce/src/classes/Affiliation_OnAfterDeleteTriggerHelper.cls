/**************************************************************************************
Author       : MST Solutions
Created Date : 08/11/2016
Description  : 
***************************************************************************************/
public class Affiliation_OnAfterDeleteTriggerHelper 
{
      // Used to remove a user from group based on their affilaition when the affilaition deleted.    
    @future 
    public static void removeMemberFromGroup(Set<string> vlounteerNameSet,Set<String> chapterNameSet,set<id> affiliationSet,Map<Id,String> exceptionMap)
    {
        try{
            map<string,id> publicGroupMap = new map<string,id>();
            Map<id,id> userMap = new Map<id,id>();
            Map<id,String> groupNameMap = new Map<id,String>();
            List<GroupMember> grpList = new List<GroupMember>();
            for(Account chapterName : [SELECT ID,Name FROM Account WHERE ID IN: chapterNameSet])
            {
                String groupNameTrim = chapterName.Name.removeStart('Make-A-Wish ');
                groupNameMap.put(chapterName.id,groupNameTrim);
            }
            for(User currentuser : [SELECT ID,ContactID FROM User WHERE ContactID IN: vlounteerNameSet])
            {
                userMap.put(currentuser.ContactID, currentuser.Id);
            }
            
            for(Group currentGroup : [SELECT Id, Name FROM Group WHERE Type = 'Regular' AND Name IN: groupNameMap.values()])
            {
                publicGroupMap.put(currentGroup.Name, currentGroup.id);
            }
            for(GroupMember currentmember :[SELECT ID,GroupId,UserOrGroupId  FROM GroupMember WHERE GroupId IN: publicGroupMap.values() AND UserOrGroupId IN: userMap.values()])
            {
                grpList.add(currentmember);
            }
            if(grpList.size() > 0)
            {
                delete grpList;
            }  
        }
    
     catch(Exception ex){
            for(Id currRec : exceptionMap.keyset()){
            ErrorMessage_AC.createdebugRec('Affiliation_OnAfterDeleteTriggerHelper',exceptionMap.get(currRec),String.valueOf(ex.getCause()),'removeMemberFromGroup',currRec,ex.getStackTraceString()+'   '+ex.getMessage(),'Error');
            }
            for(npe5__Affiliation__c currRec : [SELECT Id FROM npe5__Affiliation__c WHERE Id IN :exceptionMap.keyset()]){
                currRec.addError(Label.Debug_log_error_message);
            } 
        }
  }      
}