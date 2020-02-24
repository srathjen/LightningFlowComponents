/**
 * @description Controller class for Wish Budget component
 * @author Mitali Nahar, Traction on Demand
 * @createdDate 8/28/2019
 */
public with sharing class wishBudgetsController {

	/**
	 * Get the Parent Case Id for a Budget
	 * @param budgetId
	 * @return Id
	 */
	@AuraEnabled
	public static Id getWishId(Id budgetId) {
		try {
			if (budgetId != null) {
				Wish_Budget__c budget = [
						SELECT Wish_Case__c
						FROM Wish_Budget__c
						WHERE Id = :budgetId
				];
				return budget.Wish_Case__c;
			}
			return null;
		} catch (Exception e) {
			throw new AuraHandledException(e.getMessage());
		}
	}

	/**
	 * Get the Org Base URL
	 * @return String
	 */
	@AuraEnabled
	public static String getBaseOrgURL() {
		return URL.getSalesforceBaseUrl().toExternalForm();
	}
}