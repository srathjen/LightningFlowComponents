/**
 * @description Domain class for Wish Budget Trigger
 * @author Mitali Nahar, Traction on Demand
 * @createdDate 8/22/2019
 */
public with sharing class Wish_BudgetDomain extends trac_TriggerHandlerBase {

	private List<Wish_Budget__c> newWishBudgetsList = (List<Wish_Budget__c>) newRecordsList;

	/**
	 * Handles logic to perform after Wish Budget records are inserted
	 */
	public override void handleAfterInsertIgnoreBypass() {
		Wish_BudgetService.updateWishExpense(newRecordsList);
	}
	public override void handleAfterInsert() {
		Wish_BudgetService.deActivateBudgets(newRecordsList);
	}

	/**
	 *  Handles logic to perform after Wish Budget records are updated
	 */
	public override void handleAfterUpdate() {
		Wish_BudgetService.updateExpensesToApproved(newRecordsList);
	}

	/**
	 *  Handles logic to perform before Wish Budget records are updated
	 */
	public override void handleBeforeUpdate() {
		//Wish_BudgetService.wishIsEditable(newRecordsList);
	}
}