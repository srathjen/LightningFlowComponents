/**
 * @description Domain class for Wish Domain Trigger
 * @author Mitali Nahar, Traction on Demand
 * @createdDate 9/9/2019
 */
public class Wish_ExpenseDomain extends trac_TriggerHandlerBase {
	private List<Wish_Expense__c> newWishExpensesList = (List<Wish_Expense__c>) newRecordsList;
	private List<Wish_Expense__c> oldWishExpensesList = (List<Wish_Expense__c>) oldRecordsList;
	private Map<Id, Wish_Expense__c> newWishExpensesMap = (Map<Id, Wish_Expense__c>) newRecordsMap;
	private Map<Id, Wish_Expense__c> oldWishExpensesMap = (Map<Id, Wish_Expense__c>) oldRecordsMap;

	/**
	 * @description		Before inserting Wish Expense, populate Wish Budget
	 *
	 * @author 			Mitali Nahar, Traction on Demand
	 * @createdDate		2019-09-09
	 */
	public override void handleBeforeInsertIgnoreBypass() {
		WishExpenseHandler_AC.populateWishBudget(newRecordsList);
	}

	/**
	 * @description		Before inserting Wish Expense, update Wish Expense
	 *
	 * @author 			Mitali Nahar, Traction on Demand
	 * @createdDate		2019-09-09
	 */
	public override void handleBeforeInsert() {
		WishExpenseHandler_AC.updatewishExpense(newRecordsList);
	}

	/**
	 * @description 	Before updating Wish Expense, update Wish Expense and populate Wish Budget
	 *
	 * @author 			Mitali Nahar, Traction on Demand
	 * @createdDate		2019-09-09
	 */
	public override void handleBeforeUpdate() {
		WishExpenseHandler_AC.updatewishExpense(newRecordsList);
		WishExpenseHandler_AC.populateWishBudget(newRecordsList);
	}
}