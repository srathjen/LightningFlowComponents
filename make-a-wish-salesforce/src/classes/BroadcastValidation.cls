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
		User user = Utils.currentUser;
		for (Account account : [
				SELECT Id,Name
				FROM Account
				WHERE Id IN :chapterIds
		]) {
			chapterNameMap.put(account.Id, account.Name);
		}
		for (Chapter_Vs_Role__c chapterVsRole : [
				SELECT Chapter_Name__c, Role_Name__c
				FROM Chapter_Vs_Role__c
				WHERE Chapter_Name__c IN :chapterNameMap.values()
		]) {
			chapterRoleMap.put(chapterVsRole.Chapter_Name__c, chapterVsRole.Role_Name__c);
		}
		for (Broadcast__c broadcast : newBroadcastList) {
			if (user.UserRole.Name != chapterRoleMap.get(chapterNameMap.get(broadcast.Chapter_Name__c))
					&& Bypass_Triggers__c.getValues(user.Id) == null && !Test.isRunningTest()) {
				broadcast.addError(Label.Broadcast_Create_Chapter_Denied);
			}
		}
	}
}