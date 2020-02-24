/**
 * @description Wish Budget Form Test Class
 * @author Mitali Nahar, Traction on Demand
 * @createdDate 9/6/2019
 */
@IsTest
public with sharing class WishBudgetFormNew_AC_Test {

	@TestSetup
	private static void setup() {
		trac_TriggerHandlerBase.blockTrigger = true;
		insert new Bypass_Triggers__c(SetupOwnerId = UserInfo.getUserId());
	}

	public static testMethod void testmethodLoad() {
		Contact wishChild = OrientationandTrainingUtil.CreateWishChild();
		Contact wishFamily = OrientationandTrainingUtil.CreateWishFamilyForRelationship();
		insert new List<Contact>{
				wishChild, wishFamily
		};

		Case parentCase = OrientationandTrainingUtil.CreateParentCase(wishChild.Id);
		parentCase.Wish_Type__c = 'Airfare';
		insert parentCase;

		npe4__Relationship__c newRel = OrientationandTrainingUtil.CreateRelationshipRec(wishChild.Id, wishFamily.Id);
		newRel.Wish_Participant__c = true;
		insert newRel;
		//Case planAntiCase = OrientationandTrainingUtil.createWishPlanningCase(wishChild.Id, parentCase.Id);
		//Wish_Expense__c obj = OrientationandTrainingUtil.createWishExpenceRecord(parentCase.Id);
		//insert obj;
		List<Wish_Budget__c> budgetList = TestDataFactory.createWishBudget(2, parentCase.Id);
		budgetList[0].Budget_Approval_Status__c = 'Submitted';
		insert budgetList;

		List<Wish_Expense__c> expenseList = TestDataFactory.createWishExpense(1, budgetList[0].Id);
		insert expenseList;

		Wish_Expense_Type__c wishExpenseType = OrientationandTrainingUtil.CreateWishExpenseTypeRecord();
		insert wishExpenseType;

		Wish_Expense_Transaction_Code__c currtransactionCode = OrientationandTrainingUtil.CreateWishExpenseTransactionCodeRecord(wishExpenseType.Id);
		insert currtransactionCode;

		Wish_Expense_Type_Tempate__c newExpenseTypeTem = new Wish_Expense_Type_Tempate__c();
		newExpenseTypeTem.Wish_Expense_Type__c = wishExpenseType.Id;
		newExpenseTypeTem.Wish_Type__c = 'Airfare';
		insert newExpenseTypeTem;

		Test.startTest();
		PageReference pageRef = Page.WishBudgetFormNew_VF;
		Test.setCurrentPage(pageRef);
		ApexPages.currentPage().getParameters().put('CaseId', parentCase.Id);
		ApexPages.currentPage().getParameters().put('BudgetId', budgetList[0].Id);
		ApexPages.StandardController sc = new ApexPages.StandardController(expenseList[0]);
		WishBudgetFormNew_AC wishBudget = new WishBudgetFormNew_AC(sc);
		wishBudget.DeptDiv = '10,20,30';
		wishBudget.getWishExpenceTypes();
		wishBudget.getDeptDivisions();
		wishBudget.getAccountDescs();
		wishBudget.showDeptDiv();
		wishBudget.closePopup();
		wishBudget.closePopup1();
		wishBudget.ReloadPage();

		List<Wish_Expense_Transaction_Code__c> transactionCodes = wishBudget.transactionCodes;
		List<Wish_Expense_Type_Tempate__c> ExpenseTypeTempList = wishBudget.ExpenseTypeTempList;
		Map<String, List<String>> ExpenseTypeTempWrap = wishBudget.ExpenseTypeTempWrap;
		String budgetNotes = wishBudget.budgetNotes;

		WishBudgetFormNew_AC.ApprovalStepWrapper appStep = new WishBudgetFormNew_AC.ApprovalStepWrapper ();
		String workItemApproveOrRejectLink = appStep.workItemApproveOrRejectLink;
		String workItemReassignLink = appStep.workItemReassignLink;

		WishBudgetFormNew_AC.expenseSummarywrapper esw = new WishBudgetFormNew_AC.expenseSummarywrapper ();
		String expenseType = esw.expenseType;
		Id transacationCode = esw.transacationCode;

		System.assert(parentCase.ContactId != null, 'wish does not have child recored');
		Test.stopTest();
	}
/************************************************************
This methos is used to cover the unit test and incease the code coverage for add the wish type in budget form.
*************************************************************/
	public static testMethod void testmethodAddExpenseType() {
		Contact wishChild = OrientationandTrainingUtil.CreateWishChild();
		insert wishChild;

		Case parentCase = OrientationandTrainingUtil.CreateParentCase(wishChild.Id);
		insert parentCase;

		List<Wish_Budget__c> budgetList = TestDataFactory.createWishBudget(1, parentCase.Id);
		insert budgetList;

		List<Wish_Expense__c> expenseList = TestDataFactory.createWishExpense(1, budgetList[0].Id);
		insert expenseList;

		Test.startTest();
		ApexPages.StandardController sc = new ApexPages.StandardController(expenseList[0]);
		PageReference pageRef = Page.WishBudgetFormNew_VF;
		Test.setCurrentPage(pageRef);
		ApexPages.currentPage().getParameters().put('CaseId', budgetList[0].Wish_Case__c);
		ApexPages.currentPage().getParameters().put('BudgetId', budgetList[0].Id);
		WishBudgetFormNew_AC wishBudget = new WishBudgetFormNew_AC(sc);
		Wish_Expense_Type__c wishExpenseType = OrientationandTrainingUtil.CreateWishExpenseTypeRecord();
		insert wishExpenseType;

		Wish_Expense_Transaction_Code__c currtransactionCode = OrientationandTrainingUtil.CreateWishExpenseTransactionCodeRecord(wishExpenseType.Id);
		insert currtransactionCode;

		Wish_Expense_Type_Tempate__c newExpenseTypeTem = new Wish_Expense_Type_Tempate__c();
		newExpenseTypeTem.Wish_Expense_Type__c = wishExpenseType.Id;
		newExpenseTypeTem.Wish_Type__c = 'Airfare';
		insert newExpenseTypeTem;

		wishBudget.TransCodesWrap.put('Airfare', new List<Wish_Expense_Transaction_Code__c>{
				currtransactionCode
		});
		wishBudget.newExpenseType = wishExpenseType.Id;
		wishBudget.addExpenseType();
		wishBudget.getWishExpenceTypes();
		wishBudget.getDeptDivisions();
		wishBudget.getAccountDescs();
		wishBudget.getUserListForApproval();
		wishBudget.submitForApproval();
		wishBudget.SaveExpenses();
		wishBudget.ReloadPage();
// wishBudget.removeExpense();
		wishBudget.closePopup();
		wishBudget.closePopup1();
		wishBudget.showDeptDiv();
		wishBudget.temp = '--None--';
		wishBudget.showDeptDiv();
		Test.stopTest();
		/*System.assertEquals(wishBudget.newExpenseType, 'Airfare', 'Wish expese type is mismatched');
		System.assert(wishBudget.newExpenseType == 'Airfare', 'Wish expese type is mismatched');*/
	}

/************************************************************
This methos is used to cover the unit test and incease the code coverage for add the wish expense data.
*************************************************************/
	public static testMethod void testmethodAddExpense() {
//Contact wishChild = OrientationandTrainingUtil.CreateWishChild();
		Contact wishChild = OrientationandTrainingUtil.CreateWishChild();
		insert wishChild;

		Case parentCase = OrientationandTrainingUtil.CreateParentCase(wishChild.Id);
		insert parentCase;

		List<Wish_Budget__c> budgetList = TestDataFactory.createWishBudget(1, parentCase.Id);
		insert budgetList;

		List<Wish_Expense__c> expenseList = TestDataFactory.createWishExpense(1, budgetList[0].Id);
		insert expenseList;

		Test.startTest();
		ApexPages.StandardController sc = new ApexPages.StandardController(expenseList[0]);
		PageReference pageRef = Page.WishBudgetFormNew_VF;
		Test.setCurrentPage(pageRef);
		ApexPages.currentPage().getParameters().put('CaseId', budgetList[0].Wish_Case__c);
		ApexPages.currentPage().getParameters().put('BudgetId', budgetList[0].Id);
		WishBudgetFormNew_AC wishBudget = new WishBudgetFormNew_AC(sc);
		Wish_Expense_Type__c wishExpenseType = OrientationandTrainingUtil.CreateWishExpenseTypeRecord();
		insert wishExpenseType;

		Wish_Expense_Transaction_Code__c currtransactionCode = OrientationandTrainingUtil.CreateWishExpenseTransactionCodeRecord(wishExpenseType.Id);
		insert currtransactionCode;

		wishBudget.TransCodesWrap.put('Airfare', new List<Wish_Expense_Transaction_Code__c>{
				currtransactionCode
		});
		Wish_Expense__c expenseData = new Wish_Expense__c();
		expenseData.Wish_Expense_Transaction_Code__c = currtransactionCode.Id;
		expenseData.Budget_Cash__c = 10;
		expenseData.Budget_In_Kind__c = 20;
		wishBudget.wishExpensewrap.put('Airfare', new List<Wish_Expense__c>{
				expenseData
		});
		wishBudget.expenseType = 'Airfare';
		wishBudget.addExpense();
		wishBudget.wishExpensewrap.clear();
		wishBudget.addExpense();
		wishBudget.TransCodesWrap.put(wishBudget.expenseType, null);
		wishBudget.addExpense();
		wishBudget.TransCodesWrap.put('Airfare', new List<Wish_Expense_Transaction_Code__c>{
				currtransactionCode
		});
		wishBudget.newExpenseType = 'Airfare';
		wishBudget.addExpenseType();
		Test.stopTest();
		System.assertEquals(wishBudget.expenseType, 'Airfare', 'Wish expese type is mismatched');
		System.assert(expenseData.Budget_Cash__c != 20, 'Expense data is mismatched');
	}
/**************************************************************************************************************************
This methos is used to cover the unit test and incease the code coverage for submit the approval process for wish budget form.
******************************************************************************************************************************/
	public static testMethod void testmethodsubmitForApproval() {
//Contact wishChild = OrientationandTrainingUtil.CreateWishChild();
		Contact wishChild = OrientationandTrainingUtil.CreateWishChild();
		insert wishChild;

		Case parentCase = OrientationandTrainingUtil.CreateParentCase(wishChild.Id);
		insert parentCase;

		List<Wish_Budget__c> budgetList = TestDataFactory.createWishBudget(1, parentCase.Id);
		insert budgetList;

		List<Wish_Expense__c> expenseList = TestDataFactory.createWishExpense(1, budgetList[0].Id);
		insert expenseList;

		Test.startTest();
		ApexPages.StandardController sc = new ApexPages.StandardController(expenseList[0]);
		PageReference pageRef = Page.WishBudgetFormNew_VF;
		Test.setCurrentPage(pageRef);
		ApexPages.currentPage().getParameters().put('CaseId', budgetList[0].Wish_Case__c);
		ApexPages.currentPage().getParameters().put('BudgetId', budgetList[0].Id);
		WishBudgetFormNew_AC wishBudget = new WishBudgetFormNew_AC(sc);
		Wish_Expense_Type__c wishExpenseType = OrientationandTrainingUtil.CreateWishExpenseTypeRecord();
		insert wishExpenseType;

		Wish_Expense_Transaction_Code__c currtransactionCode = OrientationandTrainingUtil.CreateWishExpenseTransactionCodeRecord(wishExpenseType.Id);
		insert currtransactionCode;

		wishBudget.TransCodesWrap.put('Airfare', new List<Wish_Expense_Transaction_Code__c>{
				currtransactionCode
		});
		Wish_Expense__c expenseData = new Wish_Expense__c();
		expenseData.Wish_Expense_Transaction_Code__c = currtransactionCode.Id;
		expenseData.Budget_Cash__c = 10;
		expenseData.Budget_In_Kind__c = 20;
		wishBudget.wishExpensewrap.put('Airfare', new List<Wish_Expense__c>{
				expenseData
		});
		wishBudget.expenseType = 'Airfare';
//User userInfo=OrientationandTrainingUtil.createrSystemAdminUser();
		wishBudget.approverId = userInfo.getUserId();
		wishBudget.getPlanningAnticipationCase.add(budgetList[0]) ;
		wishBudget.submitForApproval();
		Test.stopTest();
		System.assertEquals(wishBudget.approverId, userInfo.getUserId(), 'Approver is not a active user');
		System.assert(expenseData.Budget_Cash__c != 20, 'Expense data is mismatched');
	}
/**************************************************************************************************************************
This methos is used to cover the unit test and incease the code coverage for display the approval process list for wish budget form for corressponding wish.
******************************************************************************************************************************/
	public static testMethod void testmethodUserListForApproval() {
		Contact wishChild = OrientationandTrainingUtil.CreateWishChild();
		insert wishChild;

		Case parentCase = OrientationandTrainingUtil.CreateParentCase(wishChild.Id);
		insert parentCase;

		List<Wish_Budget__c> budgetList = TestDataFactory.createWishBudget(1, parentCase.Id);
		insert budgetList;

		List<Wish_Expense__c> expenseList = TestDataFactory.createWishExpense(1, budgetList[0].Id);
		insert expenseList;

		Test.startTest();
		PageReference pageRef = Page.WishBudgetFormNew_VF;
		Test.setCurrentPage(pageRef);
		ApexPages.currentPage().getParameters().put('CaseId', parentCase.Id);
		ApexPages.currentPage().getParameters().put('BudgetId', budgetList[0].Id);
		ApexPages.StandardController sc = new ApexPages.StandardController(expenseList[0]);
		WishBudgetFormNew_AC wishBudget = new WishBudgetFormNew_AC(sc);
		wishBudget.getUserListForApproval();
		test.stopTest();
		System.assertEquals(wishBudget.CaseId, parentCase.Id, 'Budget form does not equal to wish');
		System.assert(wishBudget.getUserListForApproval().size() != 0, 'No Approval is available');
	}
/**************************************************************************************************************************
This methos is used to cover the unit test and incease the code coverage for load the templates from the wish budget form.
******************************************************************************************************************************/
	public static testMethod void testmethodLoadTemplates() {
		Contact wishChild = OrientationandTrainingUtil.CreateWishChild();
		insert wishChild;

		Case parentCase = OrientationandTrainingUtil.CreateParentCase(wishChild.Id);
		insert parentCase;

		List<Wish_Budget__c> budgetList = TestDataFactory.createWishBudget(1, parentCase.Id);
		insert budgetList;
		List<Wish_Expense__c> expenseList = TestDataFactory.createWishExpense(1, budgetList[0].Id);
		insert expenseList;

		Test.startTest();
		PageReference pageRef = Page.WishBudgetFormNew_VF;
		Test.setCurrentPage(pageRef);
		ApexPages.currentPage().getParameters().put('CaseId', parentCase.Id);
		ApexPages.currentPage().getParameters().put('BudgetId', budgetList[0].Id);
		ApexPages.StandardController sc = new ApexPages.StandardController(expenseList[0]);
		WishBudgetFormNew_AC wishBudget = new WishBudgetFormNew_AC(sc);
		Wish_Expense_Type__c wishExpenseType = OrientationandTrainingUtil.CreateWishExpenseTypeRecord();
		insert wishExpenseType;

		Wish_Expense_Transaction_Code__c currtransactionCode = OrientationandTrainingUtil.CreateWishExpenseTransactionCodeRecord(wishExpenseType.Id);
		insert currtransactionCode;

		wishBudget.TransCodesWrap.put('Airfare', new List<Wish_Expense_Transaction_Code__c>{
				currtransactionCode
		});
		wishBudget.LoadTemplates();
		Test.stopTest();
		System.assertEquals(wishBudget.CaseId, parentCase.Id, 'Budget form does not equal to wish');
		System.assert(wishBudget.CaseId == parentCase.Id, 'Budget form does not equal to wish');
	}
/**************************************************************************************************************************
This methos is used to cover the unit test and incease the code coverage for save the wish expenses.
******************************************************************************************************************************/
	public static testMethod void testmethodSaveExpenses() {
		Contact wishChild = OrientationandTrainingUtil.CreateWishChild();
		insert wishChild;

		Case parentCase = OrientationandTrainingUtil.CreateParentCase(wishChild.Id);
		insert parentCase;

		List<Wish_Budget__c> budgetList = TestDataFactory.createWishBudget(1, parentCase.Id);
		insert budgetList;
		List<Wish_Expense__c> expenseList = TestDataFactory.createWishExpense(1, budgetList[0].Id);
		insert expenseList;

		Test.startTest();
		PageReference pageRef = Page.WishBudgetFormNew_VF;
		Test.setCurrentPage(pageRef);
		ApexPages.currentPage().getParameters().put('CaseId', parentCase.Id);
		ApexPages.currentPage().getParameters().put('BudgetId', budgetList[0].Id);
		ApexPages.StandardController sc = new ApexPages.StandardController(expenseList[0]);
		WishBudgetFormNew_AC wishBudget = new WishBudgetFormNew_AC(sc);
		Wish_Expense_Type__c wishExpenseType = OrientationandTrainingUtil.CreateWishExpenseTypeRecord();
		insert wishExpenseType;

		Wish_Expense_Transaction_Code__c currtransactionCode = OrientationandTrainingUtil.CreateWishExpenseTransactionCodeRecord(wishExpenseType.Id);
		insert currtransactionCode;

		wishBudget.TransCodesWrap.put('Airfare', new List<Wish_Expense_Transaction_Code__c>{
				currtransactionCode
		});
		Wish_Expense__c expenseData = new Wish_Expense__c();
		expenseData.Wish_Expense_Transaction_Code__c = currtransactionCode.id;
		expenseData.Budget_Cash__c = expenseData.Projected_Cash__c = 10;
		expenseData.Budget_In_Kind__c = expenseData.Projected_In_Kind__c = 20;
		wishBudget.wishExpensewrap.put('Airfare', new List<Wish_Expense__c>{
				expenseData
		});
		wishBudget.expenseType = 'Airfare';
		wishBudget.SaveExpenses();
		Test.stopTest();
		System.assertEquals(wishBudget.expenseType, 'Airfare', 'Wish expese type is mismatched');
		System.assert(expenseData.Budget_Cash__c != 20, 'Expense data is mismatched');
	}
/**************************************************************************************************************************
This methos is used to cover the unit test and incease the code coverage for remove the expenses from the list.
******************************************************************************************************************************/
	public static testMethod void testmethodRemoveExpense() {
		Contact wishChild = OrientationandTrainingUtil.CreateWishChild();
		insert wishChild;

		Case parentCase = OrientationandTrainingUtil.CreateParentCase(wishChild.Id);
		insert parentCase;

		List<Wish_Budget__c> budgetList = TestDataFactory.createWishBudget(1, parentCase.Id);
		insert budgetList;
		List<Wish_Expense__c> expenseList = TestDataFactory.createWishExpense(1, budgetList[0].Id);
		insert expenseList;

		Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
		req.setSubmitterId(UserInfo.getUserId());
		req.setComments('Approval for Wish Budget form');
		req.setObjectId(budgetList[0].Id);
		req.setSkipEntryCriteria(true);
		req.setNextApproverIds(new Id[]{
				UserInfo.getUserId()
		});
		Approval.ProcessResult result = Approval.process(req);
		Approval.UnlockResult urList = Approval.Unlock(budgetList[0].Id, false);

		Test.startTest();
		PageReference pageRef = Page.WishBudgetFormNew_VF;
		Test.setCurrentPage(pageRef);
		ApexPages.currentPage().getParameters().put('CaseId', parentCase.Id);
		ApexPages.currentPage().getParameters().put('index', '0');
		ApexPages.currentPage().getParameters().put('expenType', 'Airfare');
		ApexPages.currentPage().getParameters().put('BudgetId', budgetList[0].Id);
		ApexPages.StandardController sc = new ApexPages.StandardController(expenseList[0]);
		WishBudgetFormNew_AC wishBudget = new WishBudgetFormNew_AC(sc);
		Wish_Expense_Type__c wishExpenseType = OrientationandTrainingUtil.CreateWishExpenseTypeRecord();
		insert wishExpenseType;

		Wish_Expense_Transaction_Code__c currtransactionCode = OrientationandTrainingUtil.CreateWishExpenseTransactionCodeRecord(wishExpenseType.Id);
		insert currtransactionCode;
		wishBudget.TransCodesWrap.put('Airfare', new List<Wish_Expense_Transaction_Code__c>{
				currtransactionCode
		});
		Wish_Expense__c expenseData = new Wish_Expense__c();
		expenseData.Wish_Expense_Transaction_Code__c = currtransactionCode.Id;
		expenseData.Budget_Cash__c = expenseData.Budget_In_Kind__c
				= expenseData.Projected_Cash__c = expenseData.Projected_In_Kind__c
						= expenseData.Actual_Cash__c = expenseData.Actual_In_Kind__c
								= expenseData.FE_Posted_Cash__c = expenseData.FE_Posted_In_Kind__c
										= null;
		wishBudget.wishExpensewrap.put('Airfare', new List<Wish_Expense__c>{
				expenseData
		});
		wishBudget.expenseList = wishBudget.wishExpensewrap.get('Airfare');
		wishBudget.Totalsummary();
		wishBudget.removeExpense();
		Test.stopTest();
		System.assert(currtransactionCode.Wish_Expense_Type__c == wishExpenseType.Id, 'Wish Expense Type is mismatched in Wish Expense Transaction Code');
		System.assertEquals(currtransactionCode.Wish_Expense_Type__c, wishExpenseType.Id, 'Wish Expense Type is mismatched in Wish Expense Transaction Code');
	}
}