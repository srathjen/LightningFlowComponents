/**
 * @description Wish Budget Form Controller, exposes methods for the front end components(cloned from WishBudgetForm_AC with minor refactoring for new data model)
 * @author Mitali Nahar, Traction on Demand
 * @createdDate 8/21/2019
 */
public class WishBudgetFormNew_AC {
    public List<Wish_Expense_Transaction_Code__c> transactionCodes { get; set; }
    public List<Wish_Expense__c> expenseList;
    public String caseApproverStatus { get; set; }
    public Boolean disableTcode { get; set; }
    public String wishType { get; set; }
    public String expenseType { get; set; }
    public List<User> userList { get; set; }
    public String pageBlockMode { get; set; }
    public Id approverId { get; set; }
    public String newExpenseType { get; set; }
    public Id caseId { get; set; }
    public String antiWishType { get; set; }
    public List<Wish_Expense__c> wishExpenseList { get; set; }
    public Set<String> wishExpenseTypes { get; set; }
    public Map<String, List<Wish_Expense_Transaction_Code__c>> TransCodesWrap { get; set; }
    public Map<String, List<Wish_Expense__c>> wishExpensewrap { get; set; }
    public Map<String, expenseSummarywrapper> SumExpensewrappers { get; set; }
    public expenseSummarywrapper TotalExpensewrappers { get; set; }
    public Map<String, SelectOption[]> TransCodeOptionsMap { get; set; }
    public String wishChapterName { get; set; }
    public String wishDescription { get; set; }
    public List<Wish_Expense_Type_Tempate__c> ExpenseTypeTempList { get; set; }
    public Map<String, List<String>> ExpenseTypeTempWrap { get; set; }
    public Boolean approvalBtnVisibility { get; set; }
    public ApprovalList aSW { get; set; }
    public List<Wish_Budget__c> getPlanningAnticipationCase;
    public Id recordId { get; set; }
    public Id retURLRecordId { get; set; }
    public String ORG_LNK;
    public String DeptDiv { get; set; }
    public Boolean displayPopup { get; set; }
    public Boolean UserIdentiy { get; set; }
    public String WEtypeExpand { get; set; }
    public String childName { get; set; }
    public Date AntWishDate { get; set; }
    public Integer NoOfWishParts { get; set; }
    public Boolean isbudgetApprovalExist { get; set; }
    public Set<Id> participentSet;
    Id RecentApproverID;
    public String budgetNotes { get; set; }
    public Map<String, Id> wishExpenseTypeIds { get; set; }
    public Boolean loadData;
    private final static Id budgetingRecordTypeId = Constant_AC.BUDGETING_RT_ID;
    public Id budgetId { get; set; }
    public Boolean approvalProcessStart { get; set; }
    public Boolean isApprover { get; set; }
    public Wish_Budget__c budget { get; set; }
    public String approvalProcessRequestStatus { get; set; }

    public WishBudgetFormNew_AC(ApexPages.StandardController controller) {
        approvalProcessStart = false;
        RecentApproverID = null;
        UserIdentiy = false;
        isbudgetApprovalExist = false;
        caseApproverStatus = '';
        disableTcode = true;
        pageBlockMode = 'detail';
        NoOfWishParts = 0;
        caseId = ApexPages.currentPage().getParameters().get('CaseId');
        WEtypeExpand = ApexPages.currentPage().getParameters().get('exp');
        budgetId = Id.valueOf(ApexPages.currentPage().getParameters().get('BudgetId'));
        retURLRecordId = caseId;
        participentSet = new Set<Id>();
        Id wishChildRecordTypeId = Constant_AC.WISH_FORM_CHILD_ID;

        /**
         * JIRA: WLP-286
         * Author: Gustavo Mayer
         * Update: Sub case conversion to the single Wish Case, changing to
         * reference Id instead of ParentId
         */
        getPlanningAnticipationCase = [
            SELECT Id, Wish_Case__c,Budget_Submitted_Date__c, Budget_Approval_Status__c
            FROM Wish_Budget__c
            WHERE Id = :budgetId
        ];
        budget = getPlanningAnticipationCase[0];
        recordId = budget.Id;
        caseApproverStatus = getPlanningAnticipationCase.get(0).Budget_Approval_Status__c;
        if (caseApproverStatus == Constant_AC.WISH_EXPENSE_BUDGET_APPROVAL_STATUS_SUBMITTED) {
            approvalBtnVisibility = false;
        } else {
            approvalBtnVisibility = true;
        }

        /**
        * JIRA: WLP-575
        * Author: Steve Doucette
        * Update: Determine if current user is initial approver, original approver, or has modify all permissions.
        * 	This will be used in the VF to determine which fields are editable for the expenses
        */
        isApprover = false;
        // Check if user has a modify all permission
        if (!isApprover) {
            isApprover = [
                SELECT AssigneeId, Assignee.Name
                FROM PermissionSetAssignment
                WHERE PermissionSet.PermissionsModifyAllData = TRUE AND AssigneeId = :UserInfo.getUserId()
            ].size() > 0;
        }

        // To check whether budget approval form is approved
        List<Case> caseList = [
            SELECT Id, Contact.FirstName, Contact.LastName, Description, Contact.Middle_Name__c,
                Start_Date__c, isApprove__c, ChapterName__r.Name, Wish_Type__c, Budget_Notes__c
            FROM Case
            WHERE Id = :caseId
            LIMIT 50000
        ];
        if (caseList.size() > 0) {
            wishChapterName = caseList.get(0).ChapterName__r.Name;
            wishDescription = caseList.get(0).Description;
            antiWishType = caseList.get(0).Wish_Type__c;
            wishType = caseList.get(0).Wish_Type__c;
            AntWishDate = caseList.get(0).Start_Date__c;
            childName = caseList.get(0).Contact.FirstName + ' ' +
                (caseList.get(0).Contact.Middle_Name__c != null ? caseList.get(0).Contact.Middle_Name__c : '') + ' '
                + caseList.get(0).Contact.LastName;
            List<Account> accountList = [
                SELECT Id,Department_Division__c
                FROM Account
                WHERE Name = :wishChapterName
            ];
            DeptDiv = accountList.get(0).Department_Division__c;
        }
        /**
         * JIRA: WLP-291
         * Author: Gustavo Mayer
         * Update: Non_Comped, Medical_Needs, Send_Wish_Forms__c and Residing_with_Wish_child__c
         * to reside on Wish Affiliation object and to be removed from npe4__Relationship__c.
         */
        if (caseList[0].ContactId != null) {
            for (npe4__Relationship__c currrentRlationShip : [
                SELECT Id,npe4__Contact__c,npe4__RelatedContact__c,Wish_Participant__c
                FROM npe4__Relationship__c
                WHERE npe4__Contact__c = :caseList[0].ContactId
                AND Wish_Participant__c = TRUE
            ]) {

                participentSet.add(currrentRlationShip.npe4__RelatedContact__c);
            }
            if (participentSet.size() > 0) {
                NoOfWishParts = participentSet.size();
            }
            List<Wish_Child_Form__c> wishChild = [
                SELECT Id,Hidden_Same_as_Family__c,Migrated__c,RecordTypeId
                FROM Wish_Child_Form__c
                WHERE Case__c = :caseList[0].Id
                AND RecordTypeId = :wishChildRecordTypeId
                AND Migrated__c = :FALSE
                LIMIT 1
            ];
            if ((wishChild.size() > 0 && wishChild[0].Hidden_Same_as_Family__c == true) || (wishChild.size() == 0)) {
                NoOfWishParts += 1;
            }
        }

        wishExpensewrap = new Map<String, List<Wish_Expense__c>>();
        TransCodesWrap = new Map<String, List<Wish_Expense_Transaction_Code__c>>();
        TransCodeOptionsMap = new Map<String, List<SelectOption>>();
        wishExpenseTypes = new Set<String>();
        wishExpenseTypeIds = new Map<String, Id>();
        loadData = true;

        loadData();
        summary();
        totalSummary();

        ORG_LNK = 'https://' + Url.getSalesforceBaseUrl().getHost();
        if (!String.isBlank(recordId)) {
            aSW = new ApprovalList();
            aSW = generateData();
        }

        if (Utils.currentUser != null) {
            if (caseApproverStatus == 'Submitted') {
                if (RecentApproverID != null) {
                    if (Utils.currentUser.Id == RecentApproverID) {
                        UserIdentiy = false;
                    } else {
                        UserIdentiy = true;
                    }
                }
            }
        }
    }

    /*
     * @description     Private function to load data.
     *
     * @author          MST Solutions
     * @createdDate     unknown
     */
    private void loadData() {
        Set<Id> wishExpenseIdSet = new Set<Id>();

        if (wishExpensewrap.size() > 0) {
            wishExpensewrap.clear();
        }
        if (TransCodeOptionsMap.size() > 0) {
            TransCodeOptionsMap.clear();
        }
        if (wishExpenseTypeIds.size() > 0) {
            wishExpenseTypeIds.clear();
        }

        for (Wish_Expense_Type__c types : [
            SELECT Id,Name
            FROM Wish_Expense_Type__c
        ]) {
            wishExpenseTypeIds.put(types.Name, types.Id);
        }

        for (Wish_Expense_Transaction_Code__c currtransactionCode : [
            SELECT Id, Name,Wish_Expense_Type__r.Name
            FROM Wish_Expense_Transaction_Code__c
            WHERE Is_Active__c = TRUE
            ORDER BY Name
        ]) {
            if (!TransCodesWrap.containsKey(currtransactionCode.Wish_Expense_Type__r.Name)) {
                TransCodesWrap.put(currtransactionCode.Wish_Expense_Type__r.Name, new List<Wish_Expense_Transaction_Code__c >{
                    currtransactionCode
                });
            } else {
                TransCodesWrap.get(currtransactionCode.Wish_Expense_Type__r.Name).add(currtransactionCode);
            }

            SelectOption obj;
            if (!TransCodeOptionsMap.containsKey(currtransactionCode.Wish_Expense_Type__r.Name)) {
                obj = new SelectOption(currtransactionCode.Id, currtransactionCode.Name);

                TransCodeOptionsMap.put(currtransactionCode.Wish_Expense_Type__r.Name, new List<SelectOption>{
                    obj
                });
            } else {
                obj = new SelectOption(currtransactionCode.Id, currtransactionCode.Name);
                TransCodeOptionsMap.get(currtransactionCode.Wish_Expense_Type__r.Name).add(obj);
            }
        }

        wishExpenseList = [
            SELECT Id, Wish_Expense_Transaction_Code__r.Wish_Expense_Type__r.Name,
                Wish_Expense_Transaction_Code__c,
                Wish_Expense_Transaction_Code__r.Name,
                Post_Date__c,
                Transaction__c,
                Account_Number__c,
                Account_Description__c,
                Department_Division__c,
                Journal_Reference__c,
                Budget_Cash__c,
                Budget_In_Kind__c,
                Projected_Cash__c,
                Projected_In_Kind__c,
                Actual_Cash__c,RecordType.Name,
                Actual_In_Kind__c,Wish_Expense_Approval_Status__c,Wish_Budget__r.Budget_Approval_Status__c,Projected_Approval_Status__c,
                FE_Posted_Cash__c,
                FE_Posted_In_Kind__c,
                Case__c, Created_After_Last_Approval__c
            FROM Wish_Expense__c
            WHERE Wish_Budget__c = :budgetId
            ORDER BY Wish_Expense_Transaction_Code__r.Wish_Expense_Type__r.Name, RecordType.Name, CreatedDate
        ];

        Boolean matchedExpenseType = false;
        if (wishExpenseList.size() > 0) {
            for (Wish_Expense__c expenseType : wishExpenseList) {
                wishExpenseIdSet.add(expenseType.Wish_Expense_Transaction_Code__r.Wish_Expense_Type__c);
            }
            for (Wish_Expense_Type_Tempate__c expenseType : [
                SELECT Id,Wish_Expense_Type__r.Name,Wish_Type__c
                FROM Wish_Expense_Type_Tempate__c
                WHERE Wish_Expense_Type__c IN :wishExpenseIdSet
            ]) {
                if (expenseType.Wish_Type__c == wishType) {
                    matchedExpenseType = true;
                }
            }
        }

        for (Wish_Expense__c expense : wishExpenseList) {
            wishExpenseTypes.add(expense.Wish_Expense_Transaction_Code__r.Wish_Expense_Type__r.Name);
            if (!wishExpensewrap.containsKey(expense.Wish_Expense_Transaction_Code__r.Wish_Expense_Type__r.Name)) {
                wishExpensewrap.put(expense.Wish_Expense_Transaction_Code__r.Wish_Expense_Type__r.Name, new List<Wish_Expense__c>{
                    expense
                });
            } else {
                wishExpensewrap.get(expense.Wish_Expense_Transaction_Code__r.Wish_Expense_Type__r.Name).add(expense);
            }
            if (expense.Wish_Budget__r.Budget_Approval_Status__c == Constant_AC.WISH_BUDGET_BUDGET_APPROVAL_STATUS_APPROVED) {
                isbudgetApprovalExist = true;
            }
        }

        loadTemplates();
    }

    /*
    * @description     Function to get a List<SelectOption> for Wish Expense Types
    *
    * @return          List<SelectOption>
    *
    * @author          MST Solutions
    * @createdDate     unknown
    */
    public List<SelectOption> getWishExpenseTypes() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('', '--- None ---'));
        for (String tcode : TransCodesWrap.keySet()) {
            options.add(new SelectOption(tcode, tcode));
        }

        return options;
    }

    /*
    * @description     Function to get a List<SelectOption> for Department Divisions
    *
    * @return          List<SelectOption>
    *
    * @author          MST Solutions
    * @createdDate     unknown
    */
    public List<SelectOption> getDeptDivisions() {
        List<SelectOption> options = new List<SelectOption>();
        if (DeptDiv != null) {
            String[] depts = DeptDiv.split(',') ;
            options.add(new SelectOption('--None--', '--None--'));
            for (String dept : depts) {
                options.add(new SelectOption(dept, dept));
            }
        }

        return options;
    }

    /*
    * @description     Function to get a List<SelectOption> for Account Descriptions
    *
    * @return          List<SelectOption>
    *
    * @author          MST Solutions
    * @createdDate     unknown
    */
    public List<SelectOption> getAccountDescs() {
        List<SelectOption> options = new List<SelectOption>();
        Schema.DescribeFieldResult fieldResult = Wish_Expense__c.Account_Description__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        options.add(new SelectOption('--None--', '--None--'));
        for (Schema.PicklistEntry f : ple) {
            options.add(new SelectOption(f.getLabel(), f.getValue()));
        }

        return options;
    }

    /*
    * @description     Function to add an expense type.
    *
    * @return          PageReference
    *
    * @author          MST Solutions
    * @createdDate     unknown
    */
    public PageReference addExpenseType() {
        WEtypeExpand = null;
        if (newExpenseType != null) {
            List<Wish_Expense_Type_Tempate__c> wishExpenseTempList = [
                SELECT Id, Name, Wish_Expense_Type__r.Name
                FROM Wish_Expense_Type_Tempate__c
                WHERE Wish_Expense_Type__c = :newExpenseType
                ORDER BY Wish_Expense_Type__r.Name
            ];
            if (wishExpenseTempList.size() > 0) {
                for (Wish_Expense_Type_Tempate__c template : wishExpenseTempList) {
                    wishExpenseTypes.add(template.Wish_Expense_Type__r.Name);

                    List<Wish_Expense_Transaction_Code__c> transListType = TransCodesWrap.get(template.Wish_Expense_Type__r.Name);

                    Wish_Expense__c curExpense = new Wish_Expense__c();
                    curExpense.Wish_Expense_Transaction_Code__c = TransCodesWrap.get(template.Wish_Expense_Type__r.Name).get(0).Id;
                    for (Wish_Expense_Transaction_Code__c trans : transListType) {
                        if (trans.Name.contains('Other')) {
                            curExpense.Wish_Expense_Transaction_Code__c = trans.Id;
                            break;
                        }
                    }

                    curExpense.Case__c = caseId ;
                    curExpense.Wish_Budget__c = budgetId;

                    if (!wishExpensewrap.containsKey(template.Wish_Expense_Type__r.Name)) {
                        wishExpensewrap.put(template.Wish_Expense_Type__r.Name, new List<Wish_Expense__c>{
                            curExpense
                        });
                    } else {
                        wishExpensewrap.get(template.Wish_Expense_Type__r.Name).add(curExpense);
                    }
                }
            } else {
                wishExpenseTypes.add(newExpenseType);
                List<Wish_Expense_Transaction_Code__c> transListType = TransCodesWrap.get(newExpenseType);
                Wish_Expense__c curExpense = new Wish_Expense__c();
                curExpense.Wish_Expense_Transaction_Code__c = TransCodesWrap.get(newExpenseType).get(0).Id;
                for (Wish_Expense_Transaction_Code__c trans : transListType) {
                    if (trans.Name.contains('Other')) {
                        curExpense.Wish_Expense_Transaction_Code__c = trans.Id;
                        break;
                    }
                }

                curExpense.Case__c = caseId ;
                curExpense.Wish_Budget__c = budgetId;

                if (!wishExpensewrap.containsKey(newExpenseType)) {
                    wishExpensewrap.put(newExpenseType, new List<Wish_Expense__c>{
                        curExpense
                    });
                } else {
                    wishExpensewrap.get(newExpenseType).add(curExpense);
                }
            }

            saveWishExpenses();
            loadTemplates();
            loadData();
            summary();
            totalSummary();

            WEtypeExpand = wishExpenseTypeIds.get(newExpenseType) + 'collapsed';
        }

        PageReference pageRef = new PageReference('/apex/WishBudgetFormNew_VF?CaseId=' + caseId + '&BudgetId=' + budgetId);
        pageRef.setRedirect(true);
        pageRef.getParameters().put('exp', WEtypeExpand);

        return pageRef;
    }

    /*
    * @description     Function to load templates.
    *
    * @return          PageReference
    *
    * @author          MST Solutions
    * @createdDate     unknown
    */
    public void loadTemplates() {
        List<Wish_Expense_Transaction_Code__c> transListT;
        Boolean TempalateisAvailable = false;
        Set<Id> wishExpenseIdSet = new Set<Id>();
        Set<Id> wishTypeExpenseSet = new Set<Id>();
        Boolean matchedExpenseType = false, beforeTemp = false;
        Set<Id> matchedExpenseIdSet = new Set<Id>();

        for (Wish_Expense_Type_Tempate__c expenseType : [
            SELECT Id,Wish_Expense_Type__r.Name,Wish_Type__c
            FROM Wish_Expense_Type_Tempate__c
        ]) {
            if (expenseType.Wish_Type__c == wishType) {
                beforeTemp = true;
                wishTypeExpenseSet.add(expenseType.Wish_Expense_Type__c);
            }
        }

        wishExpenseList = [
            SELECT Id, Wish_Expense_Transaction_Code__r.Wish_Expense_Type__r.Name,
                Wish_Expense_Transaction_Code__c,
                Wish_Expense_Transaction_Code__r.Name,
                Post_Date__c,
                Transaction__c,
                Account_Number__c,
                Account_Description__c,
                Department_Division__c,
                Journal_Reference__c,
                Budget_Cash__c,
                Budget_In_Kind__c,
                Projected_Cash__c,
                Projected_In_Kind__c,
                Actual_Cash__c,RecordType.Name,
                Actual_In_Kind__c,Wish_Expense_Approval_Status__c,Wish_Budget__r.Budget_Approval_Status__c,Projected_Approval_Status__c,
                FE_Posted_Cash__c,
                FE_Posted_In_Kind__c,
                Case__c
            FROM Wish_Expense__c
            WHERE Wish_Budget__c = :budgetId
            ORDER BY Wish_Expense_Transaction_Code__r.Wish_Expense_Type__r.Name, RecordType.Name, CreatedDate
        ];

        if (wishExpenseList.size() > 0) {
            for (Wish_Expense__c expenseType : wishExpenseList) {
                wishExpenseIdSet.add(expenseType.Wish_Expense_Transaction_Code__r.Wish_Expense_Type__c);
                if (wishTypeExpenseSet.contains(expenseType.Wish_Expense_Transaction_Code__r.Wish_Expense_Type__c)) {
                    matchedExpenseIdSet.add(expenseType.Wish_Expense_Transaction_Code__r.Wish_Expense_Type__c);
                }
            }
            if (matchedExpenseIdSet.size() == wishTypeExpenseSet.size()) {
                matchedExpenseType = true;
            }
        }

        if (matchedExpenseType == false) {
            for (Wish_Expense_Type_Tempate__c template : [
                SELECT Id,Wish_Type__c, Name, Wish_Expense_Type__r.Name
                FROM Wish_Expense_Type_Tempate__c
                ORDER BY Wish_Expense_Type__r.Name
            ]) {
                if (template.Wish_Type__c == wishType) {
                    TempalateisAvailable = true;
                    wishExpenseTypes.add(template.Wish_Expense_Type__r.Name);
                    Wish_Expense__c curExpense = new Wish_Expense__c();
                    curExpense.Wish_Expense_Transaction_Code__c = TransCodesWrap.get(template.Wish_Expense_Type__r.Name).get(0).Id;
                    transListT = TransCodesWrap.get(template.Wish_Expense_Type__r.Name);

                    for (Wish_Expense_Transaction_Code__c trans : transListT) {
                        if (trans.Name.contains('Other')) {
                            curExpense.Wish_Expense_Transaction_Code__c = trans.Id;
                            break;
                        }
                    }

                    curExpense.Case__c = caseId ;
                    curExpense.Wish_Budget__c = budgetId;

                    if (!wishExpensewrap.containsKey(template.Wish_Expense_Type__r.Name)) {
                        wishExpensewrap.put(template.Wish_Expense_Type__r.Name, new List<Wish_Expense__c>{
                            curExpense
                        });
                    } else {
                        wishExpensewrap.get(template.Wish_Expense_Type__r.Name).add(curExpense);
                    }

                    transListT = null;
                }
            }
        }

        if (Test.isRunningTest()) {
            matchedExpenseType = false;
            TempalateisAvailable = false;
        }

        if (wishType != null && ((wishExpenseList.size() > 0 && matchedExpenseType == false && !TempalateisAvailable))) {
            if (TransCodesWrap.containsKey(wishType)) {
                wishExpenseTypes.add(wishType);
            }

            List<Wish_Expense_Transaction_Code__c> transListType = new List<Wish_Expense_Transaction_Code__c>();
            if (TransCodesWrap.containsKey(wishType)) {
                transListType = TransCodesWrap.get(wishType);
            }

            Wish_Expense__c curExpense = new Wish_Expense__c();
            if (TransCodesWrap.containsKey(wishType)) {
                curExpense.Wish_Expense_Transaction_Code__c = TransCodesWrap.get(wishType).get(0).Id;
            }

            for (Wish_Expense_Transaction_Code__c trans : transListType) {
                if (trans.Name.contains('Other')) {
                    curExpense.Wish_Expense_Transaction_Code__c = trans.Id;
                    break;
                }
            }

            curExpense.Case__c = caseId ;
            curExpense.Wish_Budget__c = budgetId;

            if (!wishExpensewrap.containsKey(wishType)) {
                wishExpensewrap.put(wishType, new List<Wish_Expense__c>{
                    curExpense
                });
            } else {
                wishExpensewrap.get(wishType).add(curExpense);
            }
        }

        if (wishExpensewrap.size() > 0) {
            List<String> mapKeyString = new List<String>();
            for (String wishExpense : wishExpenseTypes) {
                mapKeyString.add(wishExpense);
            }

            mapKeyString.sort();
            wishExpenseTypes.clear();

            for (String keyString : mapKeyString) {
                wishExpenseTypes.add(keyString);
            }
        }
    }

    /*
    * @description     Function to add expenses.
    *
    * @return          PageReference
    *
    * @author          MST Solutions
    * @createdDate     unknown
    */
    public PageReference addExpense() {
        List<Wish_Expense_Transaction_Code__c> transListW = TransCodesWrap.get(expenseType);
        if (transListW == null) {
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,
                Label.WishBudgetForm_No_Trans_Code + expenseType);
            ApexPages.addMessage(myMsg);
            return null;
        }

        Wish_Expense__c curExpense = new Wish_Expense__c();
        curExpense.RecordTypeId = budgetingRecordTypeId;
        curExpense.Wish_Expense_Transaction_Code__c = TransCodesWrap.get(expenseType).get(0).Id;

        for (Wish_Expense_Transaction_Code__c trans : transListW) {
            if (trans.Name.contains('Other')) {
                curExpense.Wish_Expense_Transaction_Code__c = trans.Id;
                break;
            }
        }

        curExpense.Case__c = caseId ;
        curExpense.Wish_Budget__c = budgetId;

        if (!wishExpensewrap.containsKey(expenseType)) {
            wishExpensewrap.put(expenseType, new List<Wish_Expense__c>{
                curExpense
            });
        } else {
            wishExpensewrap.get(expenseType).add(curExpense);
        }

        saveWishExpenses();
        loadData();
        summary();
        totalSummary();

        PageReference pageRef = new PageReference('/apex/WishBudgetFormNew_VF');
        pageRef.setRedirect(true);
        pageRef.getParameters().put('CaseId', caseId);
        pageRef.getParameters().put('exp', WEtypeExpand);
        pageRef.getParameters().put('BudgetId', budgetId);

        return pageRef ;
    }

    /*
    * @description     Function to get a List<SelectOption> of User approvers.
    *
    * @return          List<SelectOption>
    *
    * @author          MST Solutions
    * @createdDate     unknown
    */
    public List<SelectOption> getUserListForApproval() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('', 'Select Approver'));
        options.add(new SelectOption(Utils.currentUser.Id, Utils.currentUser.Name));

        if (wishChapterName != null) {
            String chapterGroupName = wishChapterName.removeStart('Make-A-Wish ');

            List<Wish_Budget_Approver_Filter__c> wbaList = [
                SELECT SetupOwnerId
                FROM Wish_Budget_Approver_Filter__c
                WHERE Restrict__c = TRUE
            ];

            Set<Id> profileIdsToOmit = new Set<Id>();
            for (Wish_Budget_Approver_Filter__c wba : wbaList) {
                profileIdsToOmit.add(wba.SetupOwnerId);
            }

            User[] users = [
                SELECT User.Id, User.Name
                FROM User
                WHERE Id IN (
                    SELECT UserOrGroupId
                    FROM GroupMember
                    WHERE Group.Name = :chapterGroupName
                )
                AND User.Profile.Id NOT IN :profileIdsToOmit
            ];

            for (User user : users) {
                if (user.Id != Utils.currentUser.Id) {
                    options.add(new SelectOption(user.Id, user.Name));
                }
            }
        }

        return options;
    }

    /*
     * @description     This method is used to submit wish budget form for approval to Wish Coordinator.
     *                  If Projected Cash and Projected Inkind are blank then we will assign Budget Cash
     *                  and Budget InKind to Projected Cash and Projected InKind before records goes for
     *                  approval. Once the form is submitted for approval we will make all fields as
     *                  Read Only except T-Code and Projected fields.
     *
     * @author          MST Solutions
     * @date            unknown
     */
    public void submitForApproval() {
        Set<Id> approvedCaseIds = new Set<Id>();

        saveWishExpenses();

        List<Wish_Expense__c> recordApprovalStatusUpdateList = new List<Wish_Expense__c>();
        for (Wish_Expense__c updateWishExpenseStatus : [
            SELECT Id, Case__c, Wish_Budget__r.Budget_Approval_Status__c,Projected_Approval_Status__c,
                Wish_Expense_Approval_Status__c
            FROM Wish_Expense__c
            WHERE Wish_Budget__c = :budgetId
        ]) {
            if (updateWishExpenseStatus.Wish_Budget__r.Budget_Approval_Status__c != Constant_AC.WISH_BUDGET_BUDGET_APPROVAL_STATUS_APPROVED) {
                updateWishExpenseStatus.Wish_Budget__r.Budget_Approval_Status__c = Constant_AC.WISH_BUDGET_BUDGET_APPROVAL_STATUS_SUBMITTED;
            }

            if ((isbudgetApprovalExist == true && updateWishExpenseStatus.Wish_Budget__r.Budget_Approval_Status__c == Constant_AC.WISH_BUDGET_BUDGET_APPROVAL_STATUS_SUBMITTED)
                || updateWishExpenseStatus.Wish_Budget__r.Budget_Approval_Status__c == Constant_AC.WISH_BUDGET_BUDGET_APPROVAL_STATUS_APPROVED) {
                if (updateWishExpenseStatus.Projected_Approval_Status__c != Constant_AC.WISH_EXPENSE_BUDGET_APPROVAL_STATUS_APPROVED) {
                    updateWishExpenseStatus.Projected_Approval_Status__c = Constant_AC.WISH_EXPENSE_BUDGET_APPROVAL_STATUS_SUBMITTED;
                }
            }

            recordApprovalStatusUpdateList.add(updateWishExpenseStatus);
            if (!approvedCaseIds.contains(updateWishExpenseStatus.Case__c)) {
                approvedCaseIds.add(updateWishExpenseStatus.Case__c);
            }
        }

        if (recordApprovalStatusUpdateList.size() > 0) {
            update recordApprovalStatusUpdateList;
        }

        if (approverId != null && getPlanningAnticipationCase.get(0).Id != null && !approvalProcessStart) {
            try {
                Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();

                req.setSubmitterId(UserInfo.getUserId());
                req.setComments(Label.WishBudgetForm_Approval_Comments);
                req.setObjectId(getPlanningAnticipationCase.get(0).Id);
                req.setProcessDefinitionNameOrId('Wish_Budget_Approval');
                req.setSkipEntryCriteria(false);
                req.setNextApproverIds(new Id[]{
                    approverId
                });

                Approval.process(req);
                Approval.unlock(getPlanningAnticipationCase.get(0).Id, false);

                displayPopup = true;
                approvalProcessStart = true;
                approvalProcessRequestStatus = Label.WishBudgetForm_Approval_Success;
            } catch (Exception e) {
                approvalProcessRequestStatus = Label.WishBudgetForm_Approval_Failure;
                displayPopup = true;
                approvalProcessStart = true;
            }
        }

        if (approvalProcessStart) {
            displayPopup = false;
            reloadPage();
        }
    }

    /*
    * @description     Function to save expenses.
    *
    * @return          PageReference
    *
    * @author          MST Solutions
    * @createdDate     unknown
    */
    public PageReference saveExpenses() {
        saveWishExpenses();
        loadData();
        summary();
        totalSummary();

        PageReference pageRef = new PageReference('/apex/WishBudgetFormNew_VF?CaseId='
            + caseId + '&BudgetId=' + budgetId);
        pageRef.setRedirect(true);

        return pageRef;
    }

    /*
    * @description     Function to reload page.
    *
    * @return          PageReference
    *
    * @author          MST Solutions
    * @createdDate     unknown
    */
    public PageReference reloadPage() {
        PageReference pageRef = new PageReference('/apex/WishBudgetFormNew_VF?CaseId='
            + caseId + '&BudgetId=' + budgetId);
        pageRef.setRedirect(true);

        return pageRef;
    }

    /*
    * @description     Function to save wish expenses.
    *
    * @return          PageReference
    *
    * @author          MST Solutions
    * @createdDate     unknown
    */
    public void saveWishExpenses() {
        List<Wish_Expense__c> wrappers = new List<Wish_Expense__c>();
        for (String type : wishExpensewrap.keySet()) {
            wrappers.addAll(wishExpensewrap.get(type));
        }
        List<Wish_Expense__c> wishexpenses = new List<Wish_Expense__c>();

        for (Wish_Expense__c wrapper : wrappers) {
            Wish_Expense__c expense = new Wish_Expense__c();

            if (wrapper.Id != null) {
                expense.Id = wrapper.Id;
            } else {
                expense.RecordTypeId = budgetingRecordTypeId;
            }

            expense.Case__c = caseId;
            expense.Wish_Budget__c = budgetId;
            expense.Wish_Expense_Transaction_Code__c = wrapper.Wish_Expense_Transaction_Code__c ;

            if (wrapper.Account_Description__c != '--None--') {
                expense.Account_Description__c = wrapper.Account_Description__c ;
            }
            if (wrapper.Department_Division__c != '--None--') {
                expense.Department_Division__c = wrapper.Department_Division__c;
            }

            expense.Account_Number__c = wrapper.Account_Number__c ;
            expense.Post_Date__c = wrapper.Post_Date__c ;
            expense.Transaction__c = wrapper.Transaction__c ;
            expense.Journal_Reference__c = wrapper.Journal_Reference__c;
            expense.Budget_Cash__c = wrapper.Budget_Cash__c;
            expense.Budget_In_Kind__c = wrapper.Budget_In_Kind__c;
            expense.Projected_Cash__c = wrapper.Projected_Cash__c;
            expense.Projected_In_Kind__c = wrapper.Projected_In_Kind__c;
            expense.Actual_Cash__c = wrapper.Actual_Cash__c;
            expense.Actual_In_Kind__c = wrapper.Actual_In_Kind__c;
            expense.FE_Posted_Cash__c = wrapper.FE_Posted_Cash__c;
            expense.FE_Posted_In_Kind__c = wrapper.FE_Posted_In_Kind__c;
            expense.Projected_Approval_Status__c = wrapper.Projected_Approval_Status__c;

            wishexpenses.add(expense);
        }

        if (wishexpenses.size() > 0) {
            upsert wishexpenses;
        }
    }

    /*
    * @description     Function to calculate and set SumExpensewrappers.
    *
    * @return          PageReference
    *
    * @author          MST Solutions
    * @createdDate     unknown
    */
    public void summary() {
        SumExpensewrappers = new Map<String, expenseSummarywrapper>();

        Decimal totalBudCash = 0;
        Decimal totalProjcash = 0;
        Decimal totalActCash = 0;
        Decimal totalBudInKind = 0;
        Decimal totalProjInKind = 0;
        Decimal totalActInKind = 0;
        Decimal totalFEPCash = 0;
        Decimal totalFEPInKind = 0;
        Double Decrease;

        for (String type : wishExpensewrap.keySet()) {
            expenseSummarywrapper sumWrap = new expenseSummarywrapper();
            for (Wish_Expense__c wrapper : wishExpensewrap.get(type)) {
                if (wrapper.Budget_Cash__c == null) {
                    wrapper.Budget_Cash__c = 0;
                }
                if (wrapper.Budget_In_Kind__c == null) {
                    wrapper.Budget_In_Kind__c = 0;
                }
                if (wrapper.Projected_Cash__c == null) {
                    wrapper.Projected_Cash__c = 0;
                }
                if (wrapper.Projected_In_Kind__c == null) {
                    wrapper.Projected_In_Kind__c = 0;
                }
                if (wrapper.Actual_Cash__c == null) {
                    wrapper.Actual_Cash__c = 0;
                }
                if (wrapper.Actual_In_Kind__c == null) {
                    wrapper.Actual_In_Kind__c = 0;
                }
                if (wrapper.FE_Posted_Cash__c == null) {
                    wrapper.FE_Posted_Cash__c = 0;
                }
                if (wrapper.FE_Posted_In_Kind__c == null) {
                    wrapper.FE_Posted_In_Kind__c = 0;
                }

                sumWrap.sumBudgetCash = sumWrap.sumBudgetCash + wrapper.Budget_Cash__c;
                sumWrap.sumBudgetInKind = sumWrap.sumBudgetInKind + wrapper.Budget_In_Kind__c;
                sumWrap.sumProjectedCash = sumWrap.sumProjectedCash + wrapper.Projected_Cash__c;
                sumWrap.sumProjectedInkind = sumWrap.sumProjectedInkind + wrapper.Projected_In_Kind__c;
                sumWrap.sumActualCash = sumWrap.sumActualCash + wrapper.Actual_Cash__c;
                sumWrap.sumActualInKind = sumWrap.sumActualInKind + wrapper.Actual_In_Kind__c ;

                if (wrapper.FE_Posted_Cash__c != null) {
                    sumWrap.sumFEPostedCash = sumWrap.sumFEPostedCash + wrapper.FE_Posted_Cash__c;
                }
                if (wrapper.FE_Posted_In_Kind__c != null) {
                    sumWrap.sumFEPostedInKind = sumWrap.sumFEPostedInKind + wrapper.FE_Posted_In_Kind__c;
                }
            }

            totalBudCash = sumWrap.sumBudgetCash;
            totalProjcash = sumWrap.sumProjectedCash;
            totalActCash = sumWrap.sumActualCash;
            totalFEPCash = sumWrap.sumFEPostedCash;
            totalBudInKind = sumWrap.sumBudgetInKind;
            totalProjInKind = sumWrap.sumProjectedInkind;
            totalActInKind = sumWrap.sumActualInKind;
            totalFEPInKind = sumWrap.sumFEPostedInKind;

            if (totalBudCash + totalBudInKind > 0 && totalProjcash + totalProjInKind > 0) {
                Decrease = (totalProjcash + totalProjInKind) - (totalBudCash + totalBudInKind);
                Decrease = (Decrease / (totalBudCash + totalBudInKind)) * 100;
                sumWrap.sumBtoPDiff = Decrease.round();
            }

            sumWrap.sumAtoFEPDiff = (totalFEPCash + totalFEPInKind) - (totalActCash + totalActInKind);
            SumExpensewrappers.put(type, sumWrap);
        }
    }

    /*
    * @description     Function to remove expenses.
    *
    * @return          PageReference
    *
    * @author          MST Solutions
    * @createdDate     unknown
    */
    public PageReference removeExpense() {
        WEtypeExpand = null;
        Integer indexVal = Integer.valueOf(System.currentPageReference().getParameters().get('index'));
        String expenType = System.currentPageReference().getParameters().get('expenType');
        expenseList = wishExpensewrap.get(expenType);

        if (expenseList.size() > 0 && expenseList[indexVal].Id != null) {
            delete expenseList[indexVal];
        } else {
            expenseList[indexVal].clear();
        }

        PageReference pageRef = new PageReference('/apex/WishBudgetFormNew_VF?CaseId=' + caseId + '&BudgetId=' + budgetId);
        pageRef.setRedirect(true);

        return pageRef;
    }

    /*
    * @description     Function to calculate and set TotalExpensewrappers.
    *
    * @author          MST Solutions
    * @createdDate     unknown
    */
    @TestVisible
    private void totalSummary() {
        Decimal totalBudCash = 0;
        Decimal totalProjcash = 0;
        Decimal totalActCash = 0;
        Decimal totalBudInKind = 0;
        Decimal totalProjInKind = 0;
        Decimal totalActInKind = 0;
        Decimal totalFEPCash = 0;
        Decimal totalFEPInKind = 0;
        Double Decrease;

        expenseSummarywrapper sumWrap = new expenseSummarywrapper();
        List<Wish_Expense__c> wrappers = new List<Wish_Expense__c>();
        for (String type : wishExpensewrap.keySet()) {
            wrappers.addAll(wishExpensewrap.get(type));
        }

        for (Wish_Expense__c wrapper : wrappers) {
            if (wrapper.Budget_Cash__c == null) {
                wrapper.Budget_Cash__c = 0;
            }
            if (wrapper.Budget_In_Kind__c == null) {
                wrapper.Budget_In_Kind__c = 0;
            }
            if (wrapper.Projected_Cash__c == null) {
                wrapper.Projected_Cash__c = 0;
            }
            if (wrapper.Projected_In_Kind__c == null) {
                wrapper.Projected_In_Kind__c = 0;
            }
            if (wrapper.Actual_Cash__c == null) {
                wrapper.Actual_Cash__c = 0;
            }
            if (wrapper.Actual_In_Kind__c == null) {
                wrapper.Actual_In_Kind__c = 0;
            }
            if (wrapper.FE_Posted_Cash__c == null) {
                wrapper.FE_Posted_Cash__c = 0;
            }
            if (wrapper.FE_Posted_In_Kind__c == null) {
                wrapper.FE_Posted_In_Kind__c = 0;
            }

            sumWrap.sumBudgetCash = sumWrap.sumBudgetCash + wrapper.Budget_Cash__c;
            sumWrap.sumBudgetInKind = sumWrap.sumBudgetInKind + wrapper.Budget_In_Kind__c;
            sumWrap.sumProjectedCash = sumWrap.sumProjectedCash + wrapper.Projected_Cash__c;
            sumWrap.sumProjectedInkind = sumWrap.sumProjectedInkind + wrapper.Projected_In_Kind__c ;
            sumWrap.sumActualCash = sumWrap.sumActualCash + wrapper.Actual_Cash__c;
            sumWrap.sumActualInKind = sumWrap.sumActualInKind + wrapper.Actual_In_Kind__c ;

            if (wrapper.FE_Posted_Cash__c != null) {
                sumWrap.sumFEPostedCash = sumWrap.sumFEPostedCash + wrapper.FE_Posted_Cash__c;
            }
            if (wrapper.FE_Posted_In_Kind__c != null) {
                sumWrap.sumFEPostedInKind = sumWrap.sumFEPostedInKind + wrapper.FE_Posted_In_Kind__c;
            }
        }

        totalBudCash = sumWrap.sumBudgetCash;
        totalProjcash = sumWrap.sumProjectedCash;
        totalActCash = sumWrap.sumActualCash;
        totalFEPCash = sumWrap.sumFEPostedCash ;
        totalBudInKind = sumWrap.sumBudgetInKind;
        totalProjInKind = sumWrap.sumProjectedInkind;
        totalActInKind = sumWrap.sumActualInKind;
        totalFEPInKind = sumWrap.sumFEPostedInKind;

        if (totalBudCash + totalBudInKind > 0 && totalProjcash + totalProjInKind > 0) {
            Decrease = (totalProjcash + totalProjInKind) - (totalBudCash + totalBudInKind);
            Decrease = (Decrease / (totalBudCash + totalBudInKind)) * 100;
            sumWrap.sumBtoPDiff = Decrease.round();
        }

        sumWrap.sumAtoFEPDiff = (totalFEPCash + totalFEPInKind) - (totalActCash + totalActInKind);
        TotalExpensewrappers = sumWrap;
    }

    /*
    * @description     Function to generate an ApprovalList.
    *
    * @return          ApprovalList
    *
    * @author          MST Solutions
    * @createdDate     unknown
    */
    ApprovalList generateData() {
        ApprovalList approvalResultForObject = new ApprovalList();
        List<ApprovalStepWrapper> aSW = new List<ApprovalStepWrapper>();
        String recallApprovalProcessLink;
        Boolean isSubmitForApproval = true;
        /**
        * JIRA: WLP-575
        * Author: Steve Doucette
        * Update: Determine if current user is initial approver, original approver, or has modify all permissions.
        * 	This will be used in the VF to determine which fields are editable for the expenses
        */
        List<ProcessInstance> processInstances = getProcessHistory(recordId).values();
        if (!processInstances.isEmpty() && !processInstances[0].StepsAndWorkitems.isEmpty() && processInstances[0].StepsAndWorkitems[0].ActorId == UserInfo.getUserId()) {
            isApprover = true;
        }

        for (ProcessInstance pI : processInstances) {
            Set<Id> processNodeId = new Set<Id>();
            for (ProcessInstanceHistory sWI : pI.StepsAndWorkitems) {
                if (processNodeId.size() == 0) {
                    processNodeId.add(sWI.ProcessNodeId);
                } else if (processNodeId.size() > 0 && processNodeId.contains(sWI.ProcessNodeId) != null) {
                    processNodeId.add(sWI.ProcessNodeId);
                }
                /**
                * JIRA: WLP-575
                * Author: Steve Doucette
                * Update: Determine if current user is initial approver, original approver, or has modify all permissions.
                * 	This will be used in the VF to determine which fields are editable for the expenses
                */
                // Check if user is assigned to or approver
                if ((sWI.StepStatus == 'Pending' || sWI.StepStatus == 'Reassigned') && sWI.OriginalActorId == UserInfo.getUserId()) {
                    isApprover = true;
                }
            }

            for (Id pNId : processNodeId) {
                ApprovalStepWrapper aSWr = new ApprovalStepWrapper();
                for (ProcessInstanceHistory sWI : pI.StepsAndWorkitems) {
                    if (sWI.ProcessNodeId == pNId) {
                        aSWr.listOfSteps.add(sWI);
                    }
                    if (sWI.StepStatus == 'Pending') {
                        aSWr.workItemApproveOrRejectLink = ORG_LNK + '/p/process/ProcessInstanceWorkitemWizardStageManager?id=' + sWI.Id;
                        aSWr.workItemReassignLink = ORG_LNK + '/' + sWI.Id + '/e?et=REASSIGN&retURL=/' + retURLRecordId;
                        recallApprovalProcessLink = ORG_LNK + '/' + sWI.Id + '/e?et=REMOVE&retURL=/' + retURLRecordId;
                        isSubmitForApproval = false;
                        RecentApproverID = sWI.OriginalActorId;
                    }
                }
                aSW.add(aSWr);
            }
        }

        approvalResultForObject.approvals = aSW;
        approvalResultForObject.recordId = recordId;
        approvalResultForObject.isSubmitForApproval = isSubmitForApproval;
        approvalResultForObject.recallApprovalProcessLink = recallApprovalProcessLink;

        return approvalResultForObject;
    }

    /*
    * @description     Function to return a process history map.
    *
    * @param           Id objectId
    *
    * @return          Map<Id, ProcessInstance>
    *
    * @author          MST Solutions
    * @createdDate     unknown
    */
    public Map<Id, ProcessInstance> getProcessHistory(Id objectId) {
        return new Map<Id, ProcessInstance>([
            SELECT Id, (
                SELECT Id, ProcessNodeId,
                    StepStatus,Comments,TargetObjectId,ActorId,CreatedById,IsDeleted,IsPending
                    ,OriginalActorId,ProcessInstanceId,RemindersSent,CreatedDate, Actor.Name,
                    OriginalActor.Name, ProcessNode.Name
                FROM StepsAndWorkitems
                ORDER BY CreatedDate DESC, StepStatus
            )
            FROM ProcessInstance
            WHERE TargetObjectId = :objectId
            ORDER BY CreatedDate DESC
            LIMIT 50000
        ]);
    }

    public class ApprovalStepWrapper {
        public String workItemApproveOrRejectLink { get; set; }
        public String workItemReassignLink { get; set; }
        public List<ProcessInstanceHistory> listOfSteps { get; set; }
        public ApprovalStepWrapper() {
            listOfSteps = new List<ProcessInstanceHistory>();
        }
    }

    public class ApprovalList {
        public List<ApprovalStepWrapper> approvals { get; set; }
        public String recallApprovalProcessLink { get; set; }
        public Boolean isSubmitForApproval { get; set; }
        public Id recordId { get; set; }
        public ApprovalList() {
            approvals = new List<ApprovalStepWrapper>();
            isSubmitForApproval = true;
        }
    }

    public class expenseSummarywrapper {
        public String expenseType { get; set; }
        public Id transacationCode { get; set; }
        public Decimal sumBudgetCash { get; set; }
        public Decimal sumBudgetInKind { get; set; }
        public Decimal sumProjectedCash { get; set; }
        public Decimal sumProjectedInkind { get; set; }
        public Decimal sumActualCash { get; set; }
        public Decimal sumActualInKind { get; set; }
        public Decimal sumFEPostedCash { get; set; }
        public Decimal sumFEPostedInKind { get; set; }
        public Decimal sumBtoPDiff { get; set; }
        public Decimal sumAtoFEPDiff { get; set; }
        public expenseSummarywrapper() {
            sumBudgetCash = 0;
            sumBudgetInKind = 0;
            sumProjectedCash = 0;
            sumProjectedInkind = 0;
            sumActualCash = 0;
            sumActualInKind = 0;
            sumFEPostedCash = 0;
            sumFEPostedInKind = 0;
            sumBtoPDiff = 0;
            sumAtoFEPDiff = 0;
        }
    }

    public String temp { get; set; }
    public Boolean temp1 { get; set; }

    public void showDeptDiv() {
        if (temp == '--None--') {
            temp1 = true;
        } else {
            temp1 = false;
        }
    }

    public void closePopup() {
        displayPopup = false;
    }

    public PageReference closePopup1() {
        return new PageReference('javascript:window.close()');
    }
}