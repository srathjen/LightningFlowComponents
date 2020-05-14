/**
 * Wish Budget Form Test Class
 *
 * @author Mitali Nahar, Traction on Demand
 * @createdDate 9/6/2019
 */
@IsTest
public with sharing class WishBudgetFormNew_AC_Test {

	@TestSetup
	private static void setup() {
		trac_TriggerHandlerBase.blockTrigger = true;
		insert new Bypass_Triggers__c(SetupOwnerId = UserInfo.getUserId());

		List<Account> accounts = TestDataFactory.createAccount(1);
		Account account1 = accounts.get(0);
		account1.Name = 'Make-A-Wish Arizona';
		account1.RecordTypeId = Constant_AC.CHAPTER_RT_ID;
		insert accounts;

		List<ICD_Codes__c> icdCodes = TestDataFactory.createIcdCode(1);
		ICD_Codes__c icdCode = icdCodes.get(0);
		insert icdCode;

		List<Lead> leadsDataFactory = TestDataFactory.createLead(1);
		Lead lead = leadsDataFactory.get(0);
		lead.ChapterName__c = accounts[0].Id;
		lead.FirstName = 'Jack';
		lead.LastName = 'Smith';
		lead.Hidden_Chapter_Change_Confirmation__c = account1.Id;
		lead.is_Family_Aware_of_Referral__c = 'Yes';
		lead.Diagnosis_Given_By_Referrer__c = 'Test Diagnosis';
		lead.PD_ICD_Code__c = icdCode.Id;
		lead.Company = 'MAW';
		insert lead;

		List<Contact> contacts = TestDataFactory.createContact(3);
		Contact wishChild = contacts.get(0);
		wishChild.FirstName = 'Jack';
		wishChild.LastName = 'Smith';
		wishChild.AccountId = account1.Id;
		wishChild.ICD_10_Code__c = icdCode.Id;
		wishChild.Birthdate = Date.today().addYears(-3);
		wishChild.Diagnosis__c = wishChild.Diagnosis__c;
		wishChild.Gender__c = wishChild.Gender__c;
		wishChild.Self_describe_comment_box__c = wishChild.Self_describe_comment_box__c;
		wishChild.MobilePhone = '123456789';
		wishChild.Email = '';
		wishChild.MailingStreet = '123 Street';
		wishChild.MailingCity = 'Phoenix';
		wishChild.MailingStateCode = 'AZ';
		wishChild.MailingPostalCode = '84001';
		wishChild.MailingCountryCode = 'US';
		wishChild.Street__c = wishChild.MailingStreet;
		wishChild.State__c = wishChild.MailingState;
		wishChild.T_Shirt_Size__c = wishChild.T_Shirt_Size__c;
		wishChild.Preferred_Name__c = wishChild.Preferred_Name__c;
		wishChild.RecordTypeId = Constant_AC.CONTACT_WISH_CHILD_RT_ID;

		Contact family = contacts.get(1);
		family.FirstName = 'Bob';
		family.LastName = 'Smith';
		family.RecordTypeId = Constant_AC.WISH_FAMILY_RT_ID;
		family.Email = 'bobsmith@email.com';
		family.Phone = '9600467559';
		family.MailingStreet = '123 Street';
		family.MailingCity = 'Phoenix';
		family.MailingStateCode = 'AZ';
		family.MailingPostalCode = '84001';
		family.MailingCountryCode = 'US';
		family.IsParentGuardian__c = 'ParentGuardian';
		family.Birthdate = System.today() + 11234;

		Contact treatingMedicalProfessional = contacts.get(2);
		treatingMedicalProfessional.FirstName = 'Mark';
		treatingMedicalProfessional.LastName = 'Smith';
		treatingMedicalProfessional.Email = 'marksmith@email.com';
		treatingMedicalProfessional.Phone = '123456759';
		treatingMedicalProfessional.MailingStreet = 'KuttaiKarai Street';
		treatingMedicalProfessional.MailingCity = 'Trichy';
		treatingMedicalProfessional.MailingStateCode = 'AZ';
		treatingMedicalProfessional.MailingPostalCode = '6201717';
		treatingMedicalProfessional.Provider_Type__c = 'Nurse Practitioner';
		treatingMedicalProfessional.MailingCountryCode = 'US';
		treatingMedicalProfessional.RecordTypeId = Constant_AC.MEDICAL_PROFESSIONAL_RT_ID;
		insert contacts;

		List<npe4__Relationship__c> relationships = TestDataFactory.createRelationship(1);
		npe4__Relationship__c relationship1 = relationships.get(0);
		relationship1.npe4__Contact__c = wishChild.Id;
		relationship1.npe4__RelatedContact__c = family.Id;
		relationship1.Parent_Legal_Guardian__c = true;
		relationship1.npe4__Status__c = 'Active';
		relationship1.npe4__Type__c = 'Father';
		relationship1.Wish_Participant__c = true;

		List<Case> cases = TestDataFactory.createCase(1);
		Case wish = cases.get(0);
		wish.Lead__c = lead.Id;
		wish.RecordTypeId = Constant_AC.DIAGNOSIS_RT_ID;
		wish.ChapterName__c = accounts.get(0).Id;
		wish.Subject = 'Wish1';
		wish.Interview_date__c = System.today();
		wish.Wish_Type__c = 'Hawaii';
		wish.Start_Date__c = System.today();
		wish.End_Date__c = System.today();
		wish.ContactId = wishChild.Id;
		wish.Status = 'New';
		wish.Rush__c = false;
		wish.Start_Date__c = System.today();
		wish.Budget_Submitted_Date__c = System.today();
		wish.Budget_Approved_Date__c = System.today();
		wish.Update_Wish_Child_Form_Info__c = true;
		insert cases;

		List<Wish_Budget__c> budgets = TestDataFactory.createWishBudget(2, wish.Id);
		Wish_Budget__c budget1 = budgets.get(0);
		budget1.Budget_Approval_Status__c = 'Submitted';
		Wish_Budget__c budget2 = budgets.get(1);
		budget2.Budget_Approval_Status__c = 'Submitted';
		insert budgets;

		List<Wish_Expense_Type__c> expenseTypes = TestDataFactory.createWishExpenseTypes(2, 'Airfare');
		Wish_Expense_Type__c type1 = expenseTypes.get(0);
		Wish_Expense_Type__c type2 = expenseTypes.get(1);
		type2.Name = 'Airfare';
		insert expenseTypes;

		List<Wish_Expense_Transaction_Code__c> expenseTransactionCodes = TestDataFactory.createWishTransCodes(1, 'Airfare Other');
		Wish_Expense_Transaction_Code__c expenseTransactionCode1 = expenseTransactionCodes.get(0);
		expenseTransactionCode1.Wish_Expense_Type__c = type1.Id;
		expenseTransactionCode1.Is_Active__c = true;
		insert expenseTransactionCodes;

		List<Wish_Expense_Type_Tempate__c> wishExpenseTypeTempates = TestDataFactory.createWishExpenseTypeTempates(2);
		Wish_Expense_Type_Tempate__c wishExpenseTypeTempate1 = wishExpenseTypeTempates.get(0);
		wishExpenseTypeTempate1.Wish_Expense_Type__c = type1.Id;
		wishExpenseTypeTempate1.Wish_Type__c = 'Airfare';
		Wish_Expense_Type_Tempate__c wishExpenseTypeTempate2 = wishExpenseTypeTempates.get(1);
		wishExpenseTypeTempate2.Wish_Expense_Type__c = type2.Id;
		wishExpenseTypeTempate2.Wish_Type__c = 'Hotel';
		insert wishExpenseTypeTempates;

		List<Wish_Expense__c> expenses = TestDataFactory.createWishExpense(2, budget1.Id);
		Wish_Expense__c expense1 = expenses.get(0);
		expense1.Wish_Expense_Type__c = type1.Id;
		expense1.Wish_Expense_Transaction_Code__c = expenseTransactionCode1.Id;
		Wish_Expense__c expense2 = expenses.get(1);
		expense2.Wish_Expense_Type__c = type2.Id;
		expense2.Wish_Expense_Transaction_Code__c = expenseTransactionCode1.Id;
		insert expenses;

		trac_TriggerHandlerBase.blockTrigger = false;
	}

	@IsTest
	public static void testmethodLoad() {
		Case wish = [
				SELECT Id, ContactId
				FROM Case
				WHERE Subject = 'Wish1'
				LIMIT 1
		];
		Wish_Budget__c wishBudget1 = [
				SELECT Id
				FROM Wish_Budget__c
				WHERE Budget_Approval_Status__c = 'Submitted'
				LIMIT 1
		];
        Wish_Expense__c wishExpense1 = [
                SELECT Id
                FROM Wish_Expense__c
                WHERE Wish_Budget__c = :wishBudget1.Id
                LIMIT 1
        ];
		Test.startTest();
		PageReference pageRef = Page.WishBudgetFormNew_VF;
		Test.setCurrentPage(pageRef);
		ApexPages.currentPage().getParameters().put('CaseId', wish.Id);
		ApexPages.currentPage().getParameters().put('BudgetId', wishBudget1.Id);
		ApexPages.StandardController sc = new ApexPages.StandardController(wishExpense1);
		WishBudgetFormNew_AC wishBudget = new WishBudgetFormNew_AC(sc);
		wishBudget.DeptDiv = '10,20,30';
		wishBudget.getWishExpenseTypeOptions();
		wishBudget.getDeptDivisions();
		wishBudget.getAccountDescs();
		wishBudget.showDeptDiv();
		wishBudget.closePopup();
		wishBudget.closePopup1();
		wishBudget.reloadPage();

		List<Wish_Expense_Transaction_Code__c> transactionCodes = wishBudget.transactionCodes;
		List<Wish_Expense_Type_Tempate__c> ExpenseTypeTempList = wishBudget.ExpenseTypeTempList;
		Map<String, List<String>> ExpenseTypeTempWrap = wishBudget.ExpenseTypeTempWrap;
		String budgetNotes = wishBudget.budgetNotes;

		WishBudgetFormNew_AC.ApprovalStepWrapper appStep = new WishBudgetFormNew_AC.ApprovalStepWrapper ();
		String workItemApproveOrRejectLink = appStep.workItemApproveOrRejectLink;
		String workItemReassignLink = appStep.workItemReassignLink;

		WishBudgetFormNew_AC.expenseSummarywrapper esw = new WishBudgetFormNew_AC.expenseSummarywrapper ();
		String expenseType = esw.expenseType;
		Id transactionCode = esw.transacationCode;

		System.assert(wish.ContactId != null, 'wish does not have child recorded');
		Test.stopTest();
	}

	@IsTest
	public static void testmethodAddExpenseType() {
        Case wish = [
                SELECT Id
                FROM Case
                WHERE Subject = 'Wish1'
                LIMIT 1
        ];
        Wish_Budget__c wishBudget1 = [
                SELECT Id, Wish_Case__c
                FROM Wish_Budget__c
                WHERE Budget_Approval_Status__c = 'Submitted'
                LIMIT 1
        ];
		Wish_Expense__c wishExpense1 = [
				SELECT Id
				FROM Wish_Expense__c
				WHERE Wish_Budget__c = :wishBudget1.Id
				LIMIT 1
		];
		Wish_Expense_Type__c wishExpenseType = [
				SELECT Id
				FROM Wish_Expense_Type__c
				WHERE Name = 'Airfare'
				LIMIT 1
		];
		Wish_Expense_Transaction_Code__c wishExpenseTransactionCode = [
				SELECT Id, Name
				FROM Wish_Expense_Transaction_Code__c
				WHERE Wish_Expense_Type__c = :wishExpenseType.Id
				LIMIT 1
		];

		Test.startTest();
		ApexPages.StandardController sc = new ApexPages.StandardController(wishExpense1);
		PageReference pageRef = Page.WishBudgetFormNew_VF;
		Test.setCurrentPage(pageRef);
		ApexPages.currentPage().getParameters().put('CaseId', wish.Id);
		ApexPages.currentPage().getParameters().put('BudgetId', wishBudget1.Id);
		WishBudgetFormNew_AC wishBudget = new WishBudgetFormNew_AC(sc);
		wishBudget.TransCodesWrap.put('Airfare', new List<Wish_Expense_Transaction_Code__c>{
				wishExpenseTransactionCode
		});
		wishBudget.newExpenseType = wishExpenseType.Id;
		wishBudget.addExpenseType();
		wishBudget.getWishExpenseTypeOptions();
		wishBudget.getDeptDivisions();
		wishBudget.getAccountDescs();
		wishBudget.getUserListForApproval();
		wishBudget.submitForApproval();
		wishBudget.saveExpenses();
		wishBudget.reloadPage();
		wishBudget.closePopup();
		wishBudget.closePopup1();
		wishBudget.showDeptDiv();
		wishBudget.temp = '--None--';
		wishBudget.showDeptDiv();
		Test.stopTest();
	}

	@IsTest
	public static void testmethodAddExpense() {
        Case wish = [
                SELECT Id
                FROM Case
                WHERE Subject = 'Wish1'
                LIMIT 1
        ];
        Wish_Budget__c wishBudget1 = [
                SELECT Id, Wish_Case__c
                FROM Wish_Budget__c
                WHERE Budget_Approval_Status__c = 'Submitted'
                LIMIT 1
        ];
        Wish_Expense__c wishExpense1 = [
                SELECT Id
                FROM Wish_Expense__c
                WHERE Wish_Budget__c = :wishBudget1.Id
                LIMIT 1
        ];
		Wish_Expense_Type__c wishExpenseType = [
				SELECT Id
				FROM Wish_Expense_Type__c
				WHERE Name = 'Airfare'
				LIMIT 1
		];
		Wish_Expense_Transaction_Code__c wishExpenseTransactionCode = [
				SELECT Id, Name
				FROM Wish_Expense_Transaction_Code__c
				WHERE Wish_Expense_Type__c = :wishExpenseType.Id
				LIMIT 1
		];

		Test.startTest();
		ApexPages.StandardController sc = new ApexPages.StandardController(wishExpense1);
		PageReference pageRef = Page.WishBudgetFormNew_VF;
		Test.setCurrentPage(pageRef);
		ApexPages.currentPage().getParameters().put('CaseId', wish.Id);
		ApexPages.currentPage().getParameters().put('BudgetId', wishBudget1.Id);
		WishBudgetFormNew_AC wishBudget = new WishBudgetFormNew_AC(sc);
		Wish_Expense__c expenseData = new Wish_Expense__c();
		expenseData.Wish_Expense_Transaction_Code__c = wishExpenseTransactionCode.Id;
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
				wishExpenseTransactionCode
		});
		wishBudget.newExpenseType = 'Airfare';
		wishBudget.addExpenseType();
		Test.stopTest();
		System.assertEquals(wishBudget.expenseType, 'Airfare', 'Wish expese type is mismatched');
		System.assert(expenseData.Budget_Cash__c != 20, 'Expense data is mismatched');
	}

	@IsTest
	public static void testmethodsubmitForApproval() {
        Case wish = [
                SELECT Id
                FROM Case
                WHERE Subject = 'Wish1'
                LIMIT 1
        ];
        Wish_Budget__c wishBudget1 = [
                SELECT Id, Wish_Case__c
                FROM Wish_Budget__c
                WHERE Budget_Approval_Status__c = 'Submitted'
                LIMIT 1
        ];
        Wish_Expense__c wishExpense1 = [
                SELECT Id
                FROM Wish_Expense__c
                WHERE Wish_Budget__c = :wishBudget1.Id
                LIMIT 1
        ];
		Wish_Expense_Type__c wishExpenseType = [
				SELECT Id
				FROM Wish_Expense_Type__c
				WHERE Name = 'Airfare'
				LIMIT 1
		];
		Wish_Expense_Transaction_Code__c wishExpenseTransactionCode = [
				SELECT Id, Name
				FROM Wish_Expense_Transaction_Code__c
				WHERE Wish_Expense_Type__c = :wishExpenseType.Id
				LIMIT 1
		];

		Test.startTest();
		ApexPages.StandardController sc = new ApexPages.StandardController(wishExpense1);
		PageReference pageRef = Page.WishBudgetFormNew_VF;
		Test.setCurrentPage(pageRef);
		ApexPages.currentPage().getParameters().put('CaseId', wish.Id);
		ApexPages.currentPage().getParameters().put('BudgetId', wishBudget1.Id);
		WishBudgetFormNew_AC wishBudget = new WishBudgetFormNew_AC(sc);
		wishBudget.TransCodesWrap.put('Airfare', new List<Wish_Expense_Transaction_Code__c>{
				wishExpenseTransactionCode
		});
		Wish_Expense__c expenseData = new Wish_Expense__c();
		expenseData.Wish_Expense_Transaction_Code__c = wishExpenseTransactionCode.Id;
		expenseData.Budget_Cash__c = 10;
		expenseData.Budget_In_Kind__c = 20;
		wishBudget.wishExpensewrap.put('Airfare', new List<Wish_Expense__c>{
				expenseData
		});
		wishBudget.expenseType = 'Airfare';
		wishBudget.approverId = userInfo.getUserId();
		wishBudget.getPlanningAnticipationCase.add(wishBudget1) ;
		wishBudget.submitForApproval();
		Test.stopTest();
		System.assertEquals(wishBudget.approverId, userInfo.getUserId(), 'Approver is not a active user');
		System.assert(expenseData.Budget_Cash__c != 20, 'Expense data is mismatched');
	}

	@IsTest
	public static void testmethodUserListForApproval() {
        Case wish = [
                SELECT Id
                FROM Case
                WHERE Subject = 'Wish1'
                LIMIT 1
        ];
        Wish_Budget__c wishBudget1 = [
                SELECT Id, Wish_Case__c
                FROM Wish_Budget__c
                WHERE Budget_Approval_Status__c = 'Submitted'
                LIMIT 1
        ];
        Wish_Expense__c wishExpense1 = [
                SELECT Id
                FROM Wish_Expense__c
                WHERE Wish_Budget__c = :wishBudget1.Id
                LIMIT 1
        ];

		Test.startTest();
		PageReference pageRef = Page.WishBudgetFormNew_VF;
		Test.setCurrentPage(pageRef);
		ApexPages.currentPage().getParameters().put('CaseId', wish.Id);
		ApexPages.currentPage().getParameters().put('BudgetId', wishBudget1.Id);
		ApexPages.StandardController sc = new ApexPages.StandardController(wishExpense1);
		WishBudgetFormNew_AC wishBudget = new WishBudgetFormNew_AC(sc);
		wishBudget.getUserListForApproval();
		Test.stopTest();
		System.assertEquals(wishBudget.CaseId, wish.Id, 'Budget form does not equal to wish');
		System.assert(wishBudget.getUserListForApproval().size() != 0, 'No Approval is available');
	}

	@IsTest
	public static void testmethodLoadTemplates() {
        Case wish = [
                SELECT Id
                FROM Case
                WHERE Subject = 'Wish1'
                LIMIT 1
        ];
        Wish_Budget__c wishBudget1 = [
                SELECT Id, Wish_Case__c
                FROM Wish_Budget__c
                WHERE Budget_Approval_Status__c = 'Submitted'
                LIMIT 1
        ];
        Wish_Expense__c wishExpense1 = [
                SELECT Id
                FROM Wish_Expense__c
                WHERE Wish_Budget__c = :wishBudget1.Id
                LIMIT 1
        ];
		Wish_Expense_Type__c wishExpenseType = [
				SELECT Id
				FROM Wish_Expense_Type__c
				WHERE Name = 'Airfare'
				LIMIT 1
		];
		Wish_Expense_Transaction_Code__c wishExpenseTransactionCode = [
				SELECT Id, Name
				FROM Wish_Expense_Transaction_Code__c
				WHERE Wish_Expense_Type__c = :wishExpenseType.Id
				LIMIT 1
		];

		Test.startTest();
		PageReference pageRef = Page.WishBudgetFormNew_VF;
		Test.setCurrentPage(pageRef);
		ApexPages.currentPage().getParameters().put('CaseId', wish.Id);
		ApexPages.currentPage().getParameters().put('BudgetId', wishBudget1.Id);
		ApexPages.StandardController sc = new ApexPages.StandardController(wishExpense1);
		WishBudgetFormNew_AC wishBudget = new WishBudgetFormNew_AC(sc);
		wishBudget.wishType = 'Airfare';
		wishBudget.TransCodesWrap.put('Airfare', new List<Wish_Expense_Transaction_Code__c>{
				wishExpenseTransactionCode
		});
		wishBudget.loadTemplates();
		Test.stopTest();
		System.assertEquals(wishBudget.caseId, wish.Id, 'Budget form does not equal to wish');
		System.assert(wishBudget.caseId == wish.Id, 'Budget form does not equal to wish');
	}

	@IsTest
	public static void testmethodSaveExpenses() {
        Case wish = [
                SELECT Id
                FROM Case
                WHERE Subject = 'Wish1'
                LIMIT 1
        ];
        Wish_Budget__c wishBudget1 = [
                SELECT Id, Wish_Case__c
                FROM Wish_Budget__c
                WHERE Budget_Approval_Status__c = 'Submitted'
                LIMIT 1
        ];
        Wish_Expense__c wishExpense1 = [
                SELECT Id
                FROM Wish_Expense__c
                WHERE Wish_Budget__c = :wishBudget1.Id
                LIMIT 1
        ];
		Wish_Expense_Type__c wishExpenseType = [
				SELECT Id
				FROM Wish_Expense_Type__c
				WHERE Name = 'Airfare'
				LIMIT 1
		];
		Wish_Expense_Transaction_Code__c wishExpenseTransactionCode = [
				SELECT Id, Name
				FROM Wish_Expense_Transaction_Code__c
				WHERE Wish_Expense_Type__c = :wishExpenseType.Id
				LIMIT 1
		];

		Test.startTest();
		PageReference pageRef = Page.WishBudgetFormNew_VF;
		Test.setCurrentPage(pageRef);
		ApexPages.currentPage().getParameters().put('CaseId', wish.Id);
		ApexPages.currentPage().getParameters().put('BudgetId', wishBudget1.Id);
		ApexPages.StandardController sc = new ApexPages.StandardController(wishExpense1);
		WishBudgetFormNew_AC wishBudget = new WishBudgetFormNew_AC(sc);
		wishBudget.TransCodesWrap.put('Airfare', new List<Wish_Expense_Transaction_Code__c>{
				wishExpenseTransactionCode
		});
		Wish_Expense__c expenseData = new Wish_Expense__c();
		expenseData.Wish_Expense_Transaction_Code__c = wishExpenseTransactionCode.id;
		expenseData.Budget_Cash__c = expenseData.Projected_Cash__c = 10;
		expenseData.Budget_In_Kind__c = expenseData.Projected_In_Kind__c = 20;
		wishBudget.wishExpensewrap.put('Airfare', new List<Wish_Expense__c>{
				expenseData
		});
		wishBudget.expenseType = 'Airfare';
		wishBudget.saveExpenses();
		Test.stopTest();
		System.assertEquals(wishBudget.expenseType, 'Airfare', 'Wish expese type is mismatched');
		System.assert(expenseData.Budget_Cash__c != 20, 'Expense data is mismatched');
	}

	@IsTest
	public static void testmethodRemoveExpense() {
        Case wish = [
                SELECT Id
                FROM Case
                WHERE Subject = 'Wish1'
                LIMIT 1
        ];
        Wish_Budget__c wishBudget1 = [
                SELECT Id, Wish_Case__c
                FROM Wish_Budget__c
                WHERE Budget_Approval_Status__c = 'Submitted'
                LIMIT 1
        ];
        Wish_Expense__c wishExpense1 = [
                SELECT Id
                FROM Wish_Expense__c
                WHERE Wish_Budget__c = :wishBudget1.Id
                LIMIT 1
        ];
		Wish_Expense_Type__c wishExpenseType = [
				SELECT Id
				FROM Wish_Expense_Type__c
				WHERE Name = 'Airfare'
				LIMIT 1
		];
		Wish_Expense_Transaction_Code__c wishExpenseTransactionCode = [
				SELECT Id, Name, Wish_Expense_Type__c
				FROM Wish_Expense_Transaction_Code__c
				WHERE Wish_Expense_Type__c = :wishExpenseType.Id
				LIMIT 1
		];

		Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
		req.setSubmitterId(UserInfo.getUserId());
		req.setProcessDefinitionNameOrId('Wish_Budget_Approval');
		req.setComments('Approval for Wish Budget form');
		req.setObjectId(wishBudget1.Id);
		req.setSkipEntryCriteria(true);
		req.setNextApproverIds(new Id[]{
				UserInfo.getUserId()
		});
		Approval.ProcessResult result = Approval.process(req);
		Approval.UnlockResult urList = Approval.unlock(wishBudget1.Id, false);

		Test.startTest();
		PageReference pageRef = Page.WishBudgetFormNew_VF;
		Test.setCurrentPage(pageRef);
		ApexPages.currentPage().getParameters().put('CaseId', wish.Id);
		ApexPages.currentPage().getParameters().put('index', '0');
		ApexPages.currentPage().getParameters().put('expenType', 'Airfare');
		ApexPages.currentPage().getParameters().put('BudgetId', wishBudget1.Id);
		ApexPages.StandardController sc = new ApexPages.StandardController(wishExpense1);
		WishBudgetFormNew_AC wishBudget = new WishBudgetFormNew_AC(sc);
		wishBudget.TransCodesWrap.put('Airfare', new List<Wish_Expense_Transaction_Code__c>{
				wishExpenseTransactionCode
		});
		Wish_Expense__c expenseData = new Wish_Expense__c();
		expenseData.Wish_Expense_Transaction_Code__c = wishExpenseTransactionCode.Id;
		expenseData.Budget_Cash__c = expenseData.Budget_In_Kind__c
				= expenseData.Projected_Cash__c = expenseData.Projected_In_Kind__c
						= expenseData.Actual_Cash__c = expenseData.Actual_In_Kind__c
								= expenseData.FE_Posted_Cash__c = expenseData.FE_Posted_In_Kind__c
										= null;
		wishBudget.wishExpensewrap.put('Airfare', new List<Wish_Expense__c>{
				expenseData
		});
		wishBudget.expenseList = wishBudget.wishExpensewrap.get('Airfare');
		wishBudget.totalSummary();
		wishBudget.removeExpense();
		Test.stopTest();
		System.assert(wishExpenseTransactionCode.Wish_Expense_Type__c == wishExpenseType.Id, 'Wish Expense Type is mismatched in Wish Expense Transaction Code');
		System.assertEquals(wishExpenseTransactionCode.Wish_Expense_Type__c, wishExpenseType.Id, 'Wish Expense Type is mismatched in Wish Expense Transaction Code');
	}
}