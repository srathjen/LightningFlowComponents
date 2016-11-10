public class TestBudgetRemove_AC {
    public String newExpenseType {get;set;}
    Map<String, List<String>> expenseTransCodeMap = new Map<String, List<String>>();
    Map<String, List<SelectOption>> expenseTransPicklistMap = new Map<String, List<SelectOption>>();
    
    public TestBudgetRemove_AC() {
        for(Wish_Expense_Transaction_Code__c generateExpenseTransPicklist : [SELECT Id,Name,Wish_Expense_Type__c, Wish_Expense_Type__r.Name FROM Wish_Expense_Transaction_Code__c]) {
            if(expenseTransCodeMap.containsKey(generateExpenseTransPicklist.Wish_Expense_Type__r.Name)) {
                
            }
        }
        
    }
    
    
    public List<SelectOption> getWishExpenceTypes() {    
        List<SelectOption> options =  new List<SelectOption>();    
        options.add(new selectOption('','Please Select'));
        for(Wish_Expense_Type__c getWishExpenseType : [SELECT Id, Name FROM Wish_Expense_Type__c] ) {
            options.add(new selectOption(getWishExpenseType.Name,getWishExpenseType.Name));                    
        }    
        return Options;    
    }
    
    public void addNewExpenseType() {
        
    }
}