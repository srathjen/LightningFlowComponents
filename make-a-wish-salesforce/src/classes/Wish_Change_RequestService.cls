/**
 * @description Service class for Wish_Change_Request
 * @author		Gustavo Mayer, Traction on Demand
 * @date 		9/11/2019
 */
public with sharing class Wish_Change_RequestService {

	private final static String WISH_CHANGE_REQUEST_STATUS_APPROVED = Constant_AC.WISH_CHANGE_REQUEST_STATUS_APPROVED;
	private final static String WISH_CHANGE_REQUEST_STATUS_PROPOSED = Constant_AC.WISH_CHANGE_REQUEST_STATUS_PROPOSED;

	/**
	 * WLP-363
	 * Find the Wish Change Requests that have been changed from Proposed to Approved,
	 * group the change requests by Wish Affiliation and send for update.
	 * @param updatedWishChangeRequestsList
	 * @param oldWishChangeRequestsMap
	 */
	public static Map<Id, List<Wish_Change_Request__c>> processApprovedChangeRequests(List<Wish_Change_Request__c> updatedWishChangeRequestsList,
			Map<Id, Wish_Change_Request__c> oldWishChangeRequestsMap) {
		Map<Id, List<Wish_Change_Request__c>> wishCRsMapByWishAffiliationId
				= new Map<Id, List<Wish_Change_Request__c>>();
		if (oldWishChangeRequestsMap != null) {
			for (Wish_Change_Request__c updatedWishCR : updatedWishChangeRequestsList) {
				Wish_Change_Request__c oldWishCR = oldWishChangeRequestsMap.get(updatedWishCR.Id);
				if (oldWishCR != null) {
					if (WISH_CHANGE_REQUEST_STATUS_PROPOSED.equals(oldWishCR.Status__c)
							&& WISH_CHANGE_REQUEST_STATUS_APPROVED.equals(updatedWishCR.Status__c)) {
						if (wishCRsMapByWishAffiliationId.get(updatedWishCR.Wish_Affiliation__c) == null) {
							List<Wish_Change_Request__c> crs = new List<Wish_Change_Request__c>();
							crs.add(updatedWishCR);
							wishCRsMapByWishAffiliationId.put(updatedWishCR.Wish_Affiliation__c, crs);
						} else {
							wishCRsMapByWishAffiliationId.get(updatedWishCR.Wish_Affiliation__c).add(updatedWishCR);
						}
					}
				}
			}
		}
		WishAffiliationService.updateWishAffiliationOfApprovedWishChangeRequests(wishCRsMapByWishAffiliationId);
		return wishCRsMapByWishAffiliationId;
	}
}