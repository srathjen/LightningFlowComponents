/**
 * @description Validation class for Broadcast
 * @author	Gustavo Mayer, Traction on Demand
 * @createdDate	4/15/2020
 */
public class BroadcastValidation extends trac_TriggerHandlerBase {

	public static void validatePermission(Set<Id> chapterIds, List<Broadcast__c> newBroadcastList) {
		if (chapterIds.isEmpty()) {
			return;
		}
		Map<String, String> chapterRoleMap = new Map<String, String>();
		Map<Id, String> chapterNameMap = new Map<Id, String>();
		String userRole = [
				SELECT UserRole.Name
				FROM User
				WHERE Id = :UserInfo.getUserId()
		].UserRole.Name;
		for (Account currAcc : [
				SELECT Id,Name
				FROM Account
				WHERE Id IN :chapterIds
		]) {
			chapterNameMap.put(currAcc.Id, currAcc.Name);
		}
		for (Chapter_Vs_Role__c currChapterRole : [
				SELECT Chapter_Name__c, Role_Name__c
				FROM Chapter_Vs_Role__c
				WHERE Chapter_Name__c IN :chapterNameMap.values()
		]) {
			chapterRoleMap.put(currChapterRole.Chapter_Name__c, currChapterRole.Role_Name__c);
		}
		for (Broadcast__c currBroadcast : newBroadcastList) {
			if (userRole != chapterRoleMap.get(chapterNameMap.get(currBroadcast.Chapter_Name__c))
					&& Bypass_Triggers__c.getValues(UserInfo.getUserId()) == null && !Test.isRunningTest()) {
				currBroadcast.addError(Label.Broadcast_Create_Chapter_Denied);
			}
		}
	}
}