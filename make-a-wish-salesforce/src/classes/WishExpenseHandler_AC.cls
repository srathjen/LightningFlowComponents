/***************************************************************************************************
Author      : MST Solutions
CreatedBy   : 
Date        : 04/23/2018
Description : WishExpenseController_AC is used to fetch GKTW Inkind value from WishBudgetform.
*****************************************************************************************************/
public class WishExpenseHandler_AC{
    //This method is to fetch GKTW Inkind value from WishBudgetform      
    /*
            This Method is related to WVC-1856.
    */
    public static void updatewishExpense(List<Wish_Expense__c> wishExpenseList)
    {
        Map<Id,Wish_Expense_Transaction_Code__c> wishmap = new Map<Id,Wish_Expense_Transaction_Code__c>();
        List<Id> wishTransactioncodeIdList = new List<Id>();
        system.debug('wishExpenseList'+wishExpenseList);
        for(Wish_Expense__c exp : wishExpenseList)
        {
            If(exp.Wish_Expense_Transaction_Code__c != Null)
                wishTransactioncodeIdList.add(exp.Wish_Expense_Transaction_Code__c);
        }
        system.debug('wishTransactioncodeIdList'+wishTransactioncodeIdList);
        If(wishTransactioncodeIdList.Size() > 0)
        {
            For(Wish_Expense_Transaction_Code__c wish :[ select id , name from Wish_Expense_Transaction_Code__c where ID IN : wishTransactioncodeIdList])
            {
                wishmap.put(wish.Id,wish);
            }
            system.debug('wishmap'+wishmap);
            
            for(Wish_Expense__c exp : wishExpenseList)
            {
                If(wishmap.containsKey(exp.Wish_Expense_Transaction_Code__c))
                    exp.Hidden_Wish_Expense_Type__c= wishmap.get(exp.Wish_Expense_Transaction_Code__c).name;
                
            }
        }
    }
}