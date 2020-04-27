/**
 * @description Broadcast Service, centralizes Broadcast business rules.
 * @author Gustavo Mayer, Traction on Demand
 * @createdDate 3/19/2020
 */
public class BroadcastService {

	private final static String ROLE_NATIONAL_STAFF = Constant_AC.ROLE_NATIONAL_STAFF;

	public static Set<Id> buildChapterNames(List<Broadcast__c> newBroadcastList) {
		Set<Id> chapterIdSet = new Set<Id>();
		String userRole = Utils.currentUser.UserRole.Name;
		if (!ROLE_NATIONAL_STAFF.equals(userRole)) {
			for (Broadcast__c currBroadcast : newBroadcastList) {
				if (currBroadcast.Chapter_Name__c != null) {
					chapterIdSet.add(currBroadcast.Chapter_Name__c);
				}
			}
		}
		return chapterIdSet;
	}

	public static Set<Id> buildChapterNames(List<Broadcast__c> newBroadcastList, Map<Id, Broadcast__c> oldBroadcastMap) {
		Set<Id> chapterIdSet = new Set<Id>();
		String userRole = Utils.currentUser.UserRole.Name;
		if (!ROLE_NATIONAL_STAFF.equals(userRole)) {
			for (Broadcast__c currBroadcast : newBroadcastList) {
				if (currBroadcast.Chapter_Name__c != null
						&& currBroadcast.Chapter_Name__c != oldBroadcastMap.get(currBroadcast.Id).Chapter_Name__c) {
					chapterIdSet.add(currBroadcast.Chapter_Name__c);
				}
			}
		}
		return chapterIdSet;
	}

	public static Map<String, List<Broadcast__c>> buildBroadcastShare(Map<Id, Broadcast__c> newBroadcastMap) {
		Map<String, List<Broadcast__c>> broadcastShareMap = new Map<String, List<Broadcast__c>>();
		if (newBroadcastMap.isEmpty()) {
			return broadcastShareMap;
		}
		for (Broadcast__c broadcast : [
				SELECT Id, Chapter_Name__c,Chapter_Name__r.Name,OwnerId, Owner.UserRoleId, Owner.UserRole.Name
				FROM Broadcast__c
				WHERE Id IN :newBroadcastMap.keySet()
		]) {
			if (ROLE_NATIONAL_STAFF.equals(broadcast.Owner.UserRole.Name)) {
				if (!broadcastShareMap.containsKey(broadcast.Chapter_Name__r.Name)) {
					broadcastShareMap.put(broadcast.Chapter_Name__r.Name, new List<Broadcast__c>{});
				}
				broadcastShareMap.get(broadcast.Chapter_Name__r.Name).add(broadcast);
			}
		}
		return broadcastShareMap;
	}

	public static Map<String, List<Broadcast__c>> buildBroadcastShare(Map<Id, Broadcast__c> newBroadcastMap,
			Map<Id, Broadcast__c> oldBroadcastMap) {
		Map<String, List<Broadcast__c>> broadcastShareMap = new Map<String, List<Broadcast__c>>();
		if (newBroadcastMap.isEmpty()) {
			return broadcastShareMap;
		}
		for (Broadcast__c currRec : [
				SELECT Id, Chapter_Name__c,Chapter_Name__r.Name,OwnerId, Owner.UserRoleId, Owner.UserRole.Name
				FROM Broadcast__c
				WHERE Id IN :Trigger.newMap.keySet()
		]) {
			if (currRec.OwnerId != oldBroadcastMap.get(currRec.Id).OwnerId) {
				if (ROLE_NATIONAL_STAFF.equals(currRec.Owner.UserRole.Name)) {
					if (!broadcastShareMap.containsKey(currRec.Chapter_Name__r.Name)) {
						broadcastShareMap.put(currRec.Chapter_Name__r.Name, new List<Broadcast__c>{});
					}
					broadcastShareMap.get(currRec.Chapter_Name__r.Name).add(currRec);
				}
			}
		}
		return broadcastShareMap;
	}
}