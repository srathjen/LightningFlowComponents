/**
 * @description Domain class for Wish Domain Trigger
 * @author Mitali Nahar, Traction on Demand
 * @createdDate 9/9/2019
 */
public with sharing class Wish_ExpenseDomain extends trac_TriggerHandlerBase {

	private List<Wish_Expense__c> newWishExpensesList = (List<Wish_Expense__c>) newRecordsList;

	/**
	 * Before inserting Wish Expense, update Wish Expense and populate Wish Budget
	 */
    public override void handleBeforeInsertIgnoreBypass() {
        WishExpenseHandler_AC.populateWishBudget(newRecordsList);
    }
	public override void handleBeforeInsert() {
		WishExpenseHandler_AC.updatewishExpense(newRecordsList);
	}

	/**
	 * Before updating Wish Expense, update Wish Expense and populate Wish Budget
	 */
	public override void handleBeforeUpdate() {
		WishExpenseHandler_AC.updatewishExpense(newRecordsList);
		WishExpenseHandler_AC.populateWishBudget(newRecordsList);
	}
}