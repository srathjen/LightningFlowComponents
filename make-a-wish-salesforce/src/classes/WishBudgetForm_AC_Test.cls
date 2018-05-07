@isTest
public class WishBudgetForm_AC_Test{
   
    public static testMethod void testmethodLoad(){
        Contact wishChild = OrientationandTrainingUtil.CreateWishChild();
        Case parentCase = OrientationandTrainingUtil.CreateParentCase(wishChild.Id);
        Case planAntiCase = OrientationandTrainingUtil.createWishPlanningCase(wishChild.Id, parentCase.Id);
        Wish_Expense__c obj = OrientationandTrainingUtil.createWishExpenceRecord(parentCase.Id);
        insert obj;
        PageReference pageRef = Page.WishBudgetForm_VF;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('CaseId',parentCase.Id);
        ApexPages.StandardController sc = new ApexPages.StandardController(obj);
        WishBudgetForm_AC wishBudget = new WishBudgetForm_AC(sc);
        wishBudget.DeptDiv='10,20,30';
        wishBudget.getWishExpenceTypes();
        wishBudget.getDeptDivisions();
        wishBudget.getAccountDescs();
        wishBudget.showDeptDiv();
        wishBudget.closePopup();
        wishBudget.closePopup1();        
        WishBudgetForm_AC.ApprovalStepWrapper appStep= new WishBudgetForm_AC.ApprovalStepWrapper ();
        System.assertEquals(parentCase.Id,planAntiCase.ParentId,'Planning case does not a parent Id');
        System.assert(parentCase.ContactId != Null,'wish does not have child recored');
    }
    /************************************************************
    This methos is used to cover the unit test and incease the code coverage for add the wish type in budget form.
    *************************************************************/
     public static testMethod void testmethodAddExpenseType(){      
        
        Contact wishChild = OrientationandTrainingUtil.CreateWishChild();
        Case parentCase = OrientationandTrainingUtil.CreateParentCase(wishChild.Id);
        Case planAntiCase = OrientationandTrainingUtil.createWishPlanningCase(wishChild.Id, parentCase.Id);
        Wish_Expense__c expense = OrientationandTrainingUtil.createWishExpenceRecord(parentCase.Id);
        insert expense;
        ApexPages.StandardController sc = new ApexPages.StandardController(expense);
        PageReference pageRef = Page.WishBudgetForm_VF;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('CaseId',expense.Case__c);
        WishBudgetForm_AC wishBudget = new WishBudgetForm_AC(sc);
        Wish_Expense_Type__c wishExpenseType= OrientationandTrainingUtil.CreateWishExpenseTypeRecord();
        insert wishExpenseType;
        Wish_Expense_Transaction_Code__c currtransactionCode = OrientationandTrainingUtil.CreateWishExpenseTransactionCodeRecord(wishExpenseType.Id);
        insert currtransactionCode;
        wishBudget.TransCodesWrap.put('Airfare', new List<Wish_Expense_Transaction_Code__c>{currtransactionCode});
        wishBudget.newExpenseType ='Airfare';
        wishBudget.addExpenseType();
        System.assertEquals(wishBudget.newExpenseType,'Airfare','Wish expese type is mismatched');
        System.assert(wishBudget.newExpenseType == 'Airfare','Wish expese type is mismatched');  
   }
   
    /************************************************************
    This methos is used to cover the unit test and incease the code coverage for add the wish expense data.
    *************************************************************/
    public static testMethod void testmethodAddExpense(){
       
        //Contact wishChild = OrientationandTrainingUtil.CreateWishChild();
        Contact wishChild = OrientationandTrainingUtil.CreateWishChild();
        Case parentCase = OrientationandTrainingUtil.CreateParentCase(wishChild.Id);
        Case planAntiCase = OrientationandTrainingUtil.createWishPlanningCase(wishChild.Id, parentCase.Id);
        Wish_Expense__c expense = OrientationandTrainingUtil.createWishExpenceRecord(parentCase.Id);
        insert expense;
        ApexPages.StandardController sc = new ApexPages.StandardController(expense);
        
        PageReference pageRef = Page.WishBudgetForm_VF;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('CaseId',expense.Case__c);
        WishBudgetForm_AC wishBudget = new WishBudgetForm_AC(sc);
        Wish_Expense_Type__c wishExpenseType= OrientationandTrainingUtil.CreateWishExpenseTypeRecord();
        insert wishExpenseType;
        Wish_Expense_Transaction_Code__c currtransactionCode = OrientationandTrainingUtil.CreateWishExpenseTransactionCodeRecord(wishExpenseType.Id);
        insert currtransactionCode;
        wishBudget.TransCodesWrap.put('Airfare', new List<Wish_Expense_Transaction_Code__c>{currtransactionCode});
        Wish_Expense__c expenseData = new Wish_Expense__c();
        expenseData.Wish_Expense_Transaction_Code__c=currtransactionCode.Id;
        expenseData.Budget_Cash__c=10;
        expenseData.Budget_In_Kind__c=20;
        wishBudget.wishExpensewrap.put('Airfare', new List<Wish_Expense__c>{expenseData});
        wishBudget.expenseType ='Airfare';
        wishBudget.addExpense();
        System.assertEquals(wishBudget.expenseType ,'Airfare','Wish expese type is mismatched');
        System.assert(expenseData.Budget_Cash__c != 20,'Expense data is mismatched');    
   }
    /**************************************************************************************************************************
    This methos is used to cover the unit test and incease the code coverage for submit the approval process for wish budget form.
    ******************************************************************************************************************************/
    public static testMethod void testmethodsubmitForApproval(){       
        //Contact wishChild = OrientationandTrainingUtil.CreateWishChild();
        Contact wishChild = OrientationandTrainingUtil.CreateWishChild();
        Case parentCase = OrientationandTrainingUtil.CreateParentCase(wishChild.Id);
        Case planAntiCase = OrientationandTrainingUtil.createWishPlanningCase(wishChild.Id, parentCase.Id);
        Wish_Expense__c expense = OrientationandTrainingUtil.createWishExpenceRecord(parentCase.Id);
        insert expense;
        ApexPages.StandardController sc = new ApexPages.StandardController(expense);
        PageReference pageRef = Page.WishBudgetForm_VF;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('CaseId',expense.Case__c);
        WishBudgetForm_AC wishBudget = new WishBudgetForm_AC(sc);
        Wish_Expense_Type__c wishExpenseType= OrientationandTrainingUtil.CreateWishExpenseTypeRecord();
        insert wishExpenseType;
        Wish_Expense_Transaction_Code__c currtransactionCode = OrientationandTrainingUtil.CreateWishExpenseTransactionCodeRecord(wishExpenseType.Id);
        insert currtransactionCode;
        wishBudget.TransCodesWrap.put('Airfare', new List<Wish_Expense_Transaction_Code__c>{currtransactionCode});
        Wish_Expense__c expenseData = new Wish_Expense__c();
        expenseData.Wish_Expense_Transaction_Code__c=currtransactionCode.Id;
        expenseData.Budget_Cash__c=10;
        expenseData.Budget_In_Kind__c=20;
        wishBudget.wishExpensewrap.put('Airfare', new List<Wish_Expense__c>{expenseData});
        wishBudget.expenseType ='Airfare';
        //User userInfo=OrientationandTrainingUtil.createrSystemAdminUser();
        wishBudget.approverId = userInfo.getUserId();
        wishBudget.getPlanningAnticipationCase.add(planAntiCase) ;
        wishBudget.submitForApproval(); 
        System.assertEquals(wishBudget.approverId ,userInfo.getUserId(),'Approver is not a active user');
        System.assert(expenseData.Budget_Cash__c != 20,'Expense data is mismatched');   
   } 
    /**************************************************************************************************************************
    This methos is used to cover the unit test and incease the code coverage for display the approval process list for wish budget form for corressponding wish.
    ******************************************************************************************************************************/
   public static testMethod void testmethodUserListForApproval(){
        Contact wishChild = OrientationandTrainingUtil.CreateWishChild();
        Case parentCase = OrientationandTrainingUtil.CreateParentCase(wishChild.Id);
        Case planAntiCase = OrientationandTrainingUtil.createWishPlanningCase(wishChild.Id, parentCase.Id);
        Wish_Expense__c obj = OrientationandTrainingUtil.createWishExpenceRecord(parentCase.Id);
        insert obj;
        PageReference pageRef = Page.WishBudgetForm_VF;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('CaseId',parentCase.Id);
        ApexPages.StandardController sc = new ApexPages.StandardController(obj);
        WishBudgetForm_AC wishBudget = new WishBudgetForm_AC(sc);
        wishBudget.getUserListForApproval();
        System.assertEquals(wishBudget.CaseId,parentCase.Id,'Budget form does not equal to wish');
        System.assert(wishBudget.getUserListForApproval().size() != 0,'No Approval is available');
    }
    /**************************************************************************************************************************
    This methos is used to cover the unit test and incease the code coverage for load the templates from the wish budget form.
    ******************************************************************************************************************************/
     public static testMethod void testmethodLoadTemplates(){
        Contact wishChild = OrientationandTrainingUtil.CreateWishChild();
        Case parentCase = OrientationandTrainingUtil.CreateParentCase(wishChild.Id);
        Case planAntiCase = OrientationandTrainingUtil.createWishPlanningCase(wishChild.Id, parentCase.Id);
        Wish_Expense__c obj = OrientationandTrainingUtil.createWishExpenceRecord(parentCase.Id);
        insert obj;
        PageReference pageRef = Page.WishBudgetForm_VF;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('CaseId',parentCase.Id);
        ApexPages.StandardController sc = new ApexPages.StandardController(obj);
        WishBudgetForm_AC wishBudget = new WishBudgetForm_AC(sc);
         Wish_Expense_Type__c wishExpenseType= OrientationandTrainingUtil.CreateWishExpenseTypeRecord();
        insert wishExpenseType;
        Wish_Expense_Transaction_Code__c currtransactionCode = OrientationandTrainingUtil.CreateWishExpenseTransactionCodeRecord(wishExpenseType.Id);
        insert currtransactionCode;
        wishBudget.TransCodesWrap.put('Airfare', new List<Wish_Expense_Transaction_Code__c>{currtransactionCode});
        wishBudget.LoadTemplates();
        System.assertEquals(wishBudget.CaseId,parentCase.Id,'Budget form does not equal to wish');
        System.assert(wishBudget.CaseId == parentCase.Id,'Budget form does not equal to wish');
    } 
    /**************************************************************************************************************************
    This methos is used to cover the unit test and incease the code coverage for save the wish expenses.
    ******************************************************************************************************************************/
    public static testMethod void testmethodSaveExpenses(){
        Contact wishChild = OrientationandTrainingUtil.CreateWishChild();
        Case parentCase = OrientationandTrainingUtil.CreateParentCase(wishChild.Id);
        Case planAntiCase = OrientationandTrainingUtil.createWishPlanningCase(wishChild.Id, parentCase.Id);
        Wish_Expense__c obj = OrientationandTrainingUtil.createWishExpenceRecord(parentCase.Id);
        insert obj;
        PageReference pageRef = Page.WishBudgetForm_VF;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('CaseId',parentCase.Id);
        ApexPages.StandardController sc = new ApexPages.StandardController(obj);
        WishBudgetForm_AC wishBudget = new WishBudgetForm_AC(sc);
        Wish_Expense_Type__c wishExpenseType= OrientationandTrainingUtil.CreateWishExpenseTypeRecord();
        insert wishExpenseType;
        Wish_Expense_Transaction_Code__c currtransactionCode = OrientationandTrainingUtil.CreateWishExpenseTransactionCodeRecord(wishExpenseType.Id);
        insert currtransactionCode;
        wishBudget.TransCodesWrap.put('Airfare', new List<Wish_Expense_Transaction_Code__c>{currtransactionCode});
        Wish_Expense__c expenseData = new Wish_Expense__c();
        expenseData.Wish_Expense_Transaction_Code__c=currtransactionCode.id;
        expenseData.Budget_Cash__c=10;
        expenseData.Budget_In_Kind__c=20;
        wishBudget.wishExpensewrap.put('Airfare', new List<Wish_Expense__c>{expenseData});
        wishBudget.expenseType ='Airfare';
        wishBudget.SaveExpenses();
        System.assertEquals(wishBudget.expenseType ,'Airfare','Wish expese type is mismatched');
        System.assert(expenseData.Budget_Cash__c != 20,'Expense data is mismatched');  
    }
    /**************************************************************************************************************************
    This methos is used to cover the unit test and incease the code coverage for remove the expenses from the list.
    ******************************************************************************************************************************/
    public static testMethod void testmethodRemoveExpense(){
        Contact wishChild = OrientationandTrainingUtil.CreateWishChild();
        Case parentCase = OrientationandTrainingUtil.CreateParentCase(wishChild.Id);
        Case planAntiCase = OrientationandTrainingUtil.createWishPlanningCase(wishChild.Id, parentCase.Id);
        Wish_Expense__c obj = OrientationandTrainingUtil.createWishExpenceRecord(parentCase.Id);
        insert obj;
        PageReference pageRef = Page.WishBudgetForm_VF;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('CaseId',parentCase.Id);
        ApexPages.currentPage().getParameters().put('index','0');
        ApexPages.currentPage().getParameters().put('expenType','Airfare');
        ApexPages.StandardController sc = new ApexPages.StandardController(obj);
        WishBudgetForm_AC wishBudget = new WishBudgetForm_AC(sc);
        Wish_Expense_Type__c wishExpenseType= OrientationandTrainingUtil.CreateWishExpenseTypeRecord();
        insert wishExpenseType;
        Wish_Expense_Transaction_Code__c currtransactionCode = OrientationandTrainingUtil.CreateWishExpenseTransactionCodeRecord(wishExpenseType.Id);
        insert currtransactionCode;
        wishBudget.TransCodesWrap.put('Airfare', new List<Wish_Expense_Transaction_Code__c>{currtransactionCode});
        Wish_Expense__c expenseData = new Wish_Expense__c();
        expenseData.Wish_Expense_Transaction_Code__c=currtransactionCode.Id;
        expenseData.Budget_Cash__c=10;
        expenseData.Budget_In_Kind__c=20;
        wishBudget.wishExpensewrap.put('Airfare', new List<Wish_Expense__c>{expenseData});
        wishBudget.expenseList= wishBudget.wishExpensewrap.get('Airfare');
        wishBudget.removeExpense();
        System.assert(currtransactionCode.Wish_Expense_Type__c == wishExpenseType.Id,'Wish Expense Type is mismatched in Wish Expense Transaction Code');
        System.assertEquals(currtransactionCode.Wish_Expense_Type__c, wishExpenseType.Id,'Wish Expense Type is mismatched in Wish Expense Transaction Code');
    }
    
}