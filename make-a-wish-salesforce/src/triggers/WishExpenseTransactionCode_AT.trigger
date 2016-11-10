trigger WishExpenseTransactionCode_AT on Wish_Expense_Transaction_Code__c (after insert, after update) {
    if((Trigger.isInsert || Trigger.isUpdate) && Trigger.isAfter){
        List<Wish_Expense_Transaction_Code__c> newTransList = new List<Wish_Expense_Transaction_Code__c>();
        for(Wish_Expense_Transaction_Code__c newTrans : Trigger.New) {
            newTrans.External_Id__c=newTrans.Name;
            newTransList .add(newTrans);
        }
        update newTransList ;
    }

}