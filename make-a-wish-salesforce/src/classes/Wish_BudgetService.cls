/**
 * @description Service class for the Wish Budget trigger
 * @author Mitali Nahar, Traction on Demand
 * @date 8/22/2019
 */
public with sharing class Wish_BudgetService {
    /**
     * @description Clone wish expense of Active Wish Budget
     * @param newBudgets :	List of new Budgets inserted
     */
    public static void updateWishExpense(List<Wish_Budget__c> newBudgets) {
        Map<Id, Id> caseTobudgetMap = new Map<Id, Id>();
        for (Wish_Budget__c objBudget : newBudgets) {
            if (objBudget.Is_Active_Budget__c) {
                if (!caseTobudgetMap.containsKey(objBudget.Wish_Case__c)) {
                    caseTobudgetMap.put(objBudget.Wish_Case__c, objBudget.Id);
                }
            }
        }

        if (caseTobudgetMap.isEmpty()) {
            return;
        }

        Map<Id, List<Wish_Expense__c>> caseToWishExpenses = new Map<Id, List<Wish_Expense__c>>();
        for (Wish_Expense__c objExpense : [
                SELECT Id, Wish_Budget__c, Case__c
                FROM Wish_Expense__c
                WHERE RecordTypeId = :Constant_AC.WISH_EXPENSE_RT_FINANCE AND Case__c IN :caseTobudgetMap.keySet()
                ORDER BY CreatedDate
        ]) {
            if (!caseToWishExpenses.containsKey(objExpense.Case__c)) {
                caseToWishExpenses.put(objExpense.Case__c, new List<Wish_Expense__c>());
            }
            caseToWishExpenses.get(objExpense.Case__c).add(objExpense);
        }

        if (caseToWishExpenses.isEmpty()) {
            return;
        }

        List<Wish_Expense__c> wishExpensesToUpdate = new List<Wish_Expense__c>();
        for (Id caseId : caseTobudgetMap.keySet()) {
            if (caseToWishExpenses.containsKey(caseId)) {
                for (Wish_Expense__c objExpense : caseToWishExpenses.get(caseId)) {
                    objExpense.Wish_Budget__c = caseTobudgetMap.get(caseId);
                    objExpense.Transferred_from_Previous_Budget__c = true;
                    wishExpensesToUpdate.add(objExpense);
                }
            }
        }

        update wishExpensesToUpdate;
    }

    /**
     * @description Deactivate wish Budgets when new Active Budget is created
     * @param newBudgets : List of new Budgets inserted
     */
    public static void deActivateBudgets(List<Wish_Budget__c> newBudgets) {
        Map<Id, List<Wish_Budget__c>> wishBudgetsByCase = new Map<Id, List<Wish_Budget__c>>();
        Set<Id> activeBudgets = new Set<Id>();
        for (Wish_Budget__c objBudget : newBudgets) {
            if (objBudget.Is_Active_Budget__c) {
                if (!wishBudgetsByCase.containsKey(objBudget.Wish_Case__c)) {
                    wishBudgetsByCase.put(objBudget.Wish_Case__c, new List<Wish_Budget__c>());
                }
                wishBudgetsByCase.get(objBudget.Wish_Case__c).add(objBudget);
                activeBudgets.add(objBudget.Id);
            }
        }

        List<Wish_Budget__c> inactiveBudgets = new List<Wish_Budget__c>();
        for (Wish_Budget__c objBudget : [
                SELECT Id,Wish_Case__c
                FROM Wish_Budget__c
                WHERE Wish_Case__c IN :wishBudgetsByCase.keySet() AND Id NOT IN :activeBudgets AND Is_Active_Budget__c = TRUE
        ]) {
            objBudget.Is_Active_Budget__c = false;
            inactiveBudgets.add(objBudget);
        }

        update inactiveBudgets;
    }

    /**
     * @description Update Expenses status to Approved when Budget Status is Approved
     * @param newBudgets : List of Budgets updated
     */
    public static void updateExpensesToApproved(List<Wish_Budget__c> newBudgets) {
        List<Wish_Budget__c> approvedBudgets = new List<Wish_Budget__c>();
        List<Case> updateCaseList = new List<Case>();
        List<Wish_Expense__c> updateExpenses = new List<Wish_Expense__c>();
        String projectedStatus = '';

        for (Wish_Budget__c currentBudget : newBudgets) {
            if (currentBudget.Budget_Approval_Status__c == Constant_AC.WISH_BUDGET_BUDGET_APPROVAL_STATUS_APPROVED) {
                approvedBudgets.add(currentBudget);
            }
        }

        for (Wish_Expense__c childExpense : [
                SELECT Id, Wish_Expense_Approval_Status__c,Wish_Budget__r.Budget_Approval_Status__c, Projected_Approval_Status__c,
                        Budget_Cash__c, Budget_In_Kind__c, Projected_Cash__c, Projected_In_Kind__c, Actual_Cash__c,
                        Actual_In_Kind__c,Case__c, Case__r.Budget_Approved_Date__c,Case__r.Status
                FROM Wish_Expense__c
                WHERE Wish_Budget__c IN :approvedBudgets
        ]) {
            if (childExpense.Projected_Cash__c == 0) {
                childExpense.Projected_Cash__c = childExpense.Budget_Cash__c;
            }
            if (childExpense.Projected_In_Kind__c == 0) {
                childExpense.Projected_In_Kind__c = childExpense.Budget_In_Kind__c;
            }
            if (childExpense.Projected_Approval_Status__c == Constant_AC.WISH_EXPENSE_BUDGET_APPROVAL_STATUS_SUBMITTED) {
                childExpense.Projected_Approval_Status__c = Constant_AC.WISH_EXPENSE_BUDGET_APPROVAL_STATUS_APPROVED;
                projectedStatus = Constant_AC.WISH_EXPENSE_BUDGET_APPROVAL_STATUS_APPROVED;
            }

            updateExpenses.add(childExpense);

            if (childExpense != null) {
                Case updateCase = new Case();
                updateCase.Id = childExpense.Case__c;

                if (projectedStatus == Constant_AC.WISH_EXPENSE_BUDGET_APPROVAL_STATUS_APPROVED) {
                    updateCase.Projected_Status__c = projectedStatus;
                }
                if (!updateCaseList.contains(updateCase)) {
                    updateCaseList.add(updateCase);
                }
            }
        }

        update updateExpenses;
        update updateCaseList;
    }
}