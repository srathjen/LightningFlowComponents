/**
 * @description New Wish Budget Controller, exposes methods for the front end components.
 * @author Mitali Nahar, Traction on Demand
 * @createdDate 8/20/2019
 */
public with sharing class NewWishBudgetController {

	/**
	 * Finds Wish Budget records
	 * @param caseId
	 * @return Case
	 */
	@AuraEnabled
	public static Case getWishBudgets(Id caseId) {
		return [
				SELECT Id, Status, (
						SELECT Id, Budget_Approval_Status__c
						FROM Wish_Budget__r
						WHERE Is_Active_Budget__c = TRUE
				)
				FROM Case
				WHERE Id = :caseId
		];
	}
}