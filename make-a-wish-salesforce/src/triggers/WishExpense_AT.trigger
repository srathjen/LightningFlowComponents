trigger WishExpense_AT on Wish_Expense__c (before Insert,before update) {

    WishExpenseHandler_AC.updatewishExpense(Trigger.New);


}