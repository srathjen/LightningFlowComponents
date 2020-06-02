/**
 * @description WishExpenseController_AC is used to fetch GKTW Inkind value from WishBudgetform.
 * @author MST Solutions
 * @date 04/23/2018
 **/
public class WishExpenseHandler_AC {
    /*
     * @description		This method is to fetch GKTW Inkind value from WishBudgetform
     *
     * @author			MST Solutions
     * @date			2020-03-19
    */
    public static void updatewishExpense(List<Wish_Expense__c> wishExpenseList) {
        Map<Id, Wish_Expense_Transaction_Code__c> wishmap = new Map<Id, Wish_Expense_Transaction_Code__c>();
        List<Id> wishTransactioncodeIdList = new List<Id>();

        for (Wish_Expense__c exp : wishExpenseList) {
            if (exp.Wish_Expense_Transaction_Code__c != null) {
                wishTransactioncodeIdList.add(exp.Wish_Expense_Transaction_Code__c);
            }
        }

        if (wishTransactioncodeIdList.size() > 0) {
            for (Wish_Expense_Transaction_Code__c wish : [
                    SELECT Id, Name
                    FROM Wish_Expense_Transaction_Code__c
                    WHERE Id IN :wishTransactioncodeIdList
            ]) {
                wishmap.put(wish.Id, wish);
            }

            for (Wish_Expense__c exp : wishExpenseList) {
                if (wishmap.containsKey(exp.Wish_Expense_Transaction_Code__c)) {
                    exp.Hidden_Wish_Expense_Type__c = wishmap.get(exp.Wish_Expense_Transaction_Code__c).Name;
                }
            }
        }
    }

    /**
     * @description Populate Wish Budget/Case fields when Expense is created or updated
     * @param wishExpenseList
     */
    public static void populateWishBudget(List<Wish_Expense__c> wishExpenseList) {
        Set<Id> wishes = new Set<Id>();
        Set<Id> budgetIds = new Set<Id>();
        Map<Id, Id> caseToBudgetId = new Map<Id, Id>();
        Map<Id, Id> budgetToCaseId = new Map<Id, Id>();

        for (Wish_Expense__c currentExpense : wishExpenseList) {
            if (currentExpense.Wish_Budget__c == null && currentExpense.Case__c != null) {
                wishes.add(currentExpense.Case__c);
            } else if (currentExpense.Wish_Budget__c != null && currentExpense.Case__c == null) {
                budgetIds.add(currentExpense.Wish_Budget__c);
            }
        }

        // Map of Budget to it Case Id to populate on Expenses where Case = null
        for (Wish_Budget__c objBudget : [
                SELECT Id, Wish_Case__c
                FROM Wish_Budget__c
                WHERE Id IN :budgetIds
        ]) {
            if (!budgetToCaseId.containsKey(objBudget.Id)) {
                budgetToCaseId.put(objBudget.Id, objBudget.Wish_Case__c);
            }
        }

        // Map of Case to an Active budget Id under it
        Set<Id> caseIds = new Set<Id>();
        for (Case objCase : [
                SELECT Id, (
                        SELECT Id
                        FROM Wish_Budget__r
                        WHERE Is_Active_Budget__c = TRUE
                        LIMIT 1
                )
                FROM Case
                WHERE Id IN :wishes
        ]) {
            if (objCase.Wish_Budget__r.size() > 0) {
                if (!caseToBudgetId.containsKey(objCase.Id)) {
                    caseToBudgetId.put(objCase.Id, objCase.Wish_Budget__r[0].Id);
                }
            } else {
                caseIds.add(objCase.Id);
            }
        }

        // Map of Case to Budget Id and creating Budgets for Cases that have no Budgets yet.
        List<Wish_Budget__c> insertBudgets = new List<Wish_Budget__c>();
        for (Case objCase : [
                SELECT Id, (
                        SELECT Id
                        FROM Wish_Budget__r
                        ORDER BY CreatedDate DESC
                        LIMIT 1
                )
                FROM Case
                WHERE Id IN :wishes
        ]) {
            if (objCase.Wish_Budget__r.size() > 0) {
                if (!caseToBudgetId.containsKey(objCase.Id)) {
                    caseToBudgetId.put(objCase.Id, objCase.Wish_Budget__r[0].Id);
                }
            } else {
                Wish_Budget__c newBudget = new Wish_Budget__c();
                newBudget.Wish_Case__c = objCase.Id;
                newBudget.Is_Active_Budget__c = true;
                insertBudgets.add(newBudget);
            }
        }

        insert insertBudgets;

        // Map of Case to newly created Budgets Ids.
        for (Wish_Budget__c objBudget : [
                SELECT Id, Wish_Case__c
                FROM Wish_Budget__c
                WHERE Id IN :insertBudgets
        ]) {
            if (!caseToBudgetId.containsKey(objBudget.Wish_Case__c)) {
                caseToBudgetId.put(objBudget.Wish_Case__c, objBudget.Id);
            }
        }

        // Putting in Budget Ids and case Ids where they are NULL
        for (Wish_Expense__c wishExp : wishExpenseList) {
            if (caseToBudgetId.containsKey(wishExp.Case__c)) {
                wishExp.Wish_Budget__c = caseToBudgetId.get(wishExp.Case__c);
            }
            if (budgetToCaseId.containsKey(wishExp.Wish_Budget__c)) {
                wishExp.Case__c = budgetToCaseId.get(wishExp.Wish_Budget__c);
            }
        }
    }
}