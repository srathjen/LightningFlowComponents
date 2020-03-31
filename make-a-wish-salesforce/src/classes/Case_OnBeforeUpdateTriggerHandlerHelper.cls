/*****************************************************************************************************************
Author      : MST Solutions
Date        : 5/26/2016
Description : When a new case record updated then it will update the values to corresponding fields and also
it update the field values to related objects like Account, contact, VolunteerOpportunity.
*******************************************************************************************************************/

public class Case_OnBeforeUpdateTriggerHandlerHelper {
	private static final Id WISH_RECORDTYPE_ID = Constant_AC.WISH_RT_ID;
	private static final Id WISH_CHILD_RECORDTYPE_ID = Constant_AC.CONTACT_WISH_CHILD_RT_ID;

	private static final Map<Schema.SObjectField,String> MAP_OF_CASE_LABELS_BY_FIELDS =
		Utils.mapOfSObjectLabelsByFields(Schema.SObjectType.Case);

	/*
     * @description     This method is used to display the error message when the region code is entered incorrectly.
     *
     * @author          MST Solutions
     * @createdDate     unknown
    */
	public static void wishChildRegionValidation(Map<Id, Case> parentCaseMap, Set<Id> contactSet) {
		Map<Id, Contact> wishChildMap = new Map<Id, Contact>();

		if (contactSet.size() > 0) {
			for (Contact wishChild : [
				SELECT Id, Region_Code__c, County__c
				FROM Contact
				WHERE RecordTypeId = :WISH_CHILD_RECORDTYPE_ID
				AND Id IN :contactSet
				LIMIT 50000
			]) {
				if (wishChild.Region_Code__c == null || wishChild.County__c == null) {
					wishChildMap.put(wishChild.Id, wishChild);
				}
			}

			if (wishChildMap.size() > 0) {
				for (Case parentCase : parentCaseMap.values()) {
					if (wishChildMap.containsKey(parentCase.ContactId)) {
						if (wishChildMap.get(parentCase.ContactId).Region_Code__c == null
							&& wishChildMap.get(parentCase.ContactId).County__c == null
							&& Bypass_Triggers__c.getValues(Utils.currentUser.Id) == null) {

							parentCase.addError(Label.CaseTrigger_Add_Region_County);
						} else if (wishChildMap.get(parentCase.ContactId).Region_Code__c == null
							&& Bypass_Triggers__c.getValues(Utils.currentUser.Id) == null) {

							parentCase.addError(Label.CaseTrigger_Add_Region);
						} else if (wishChildMap.get(parentCase.ContactId).County__c == null
							&& Bypass_Triggers__c.getValues(Utils.currentUser.Id) == null) {

							parentCase.addError(Label.CaseTrigger_Add_County);
						}

					}
				}
			}
		}
	}

	/*
     * @description     Display error message when the parent case status is updated as completed with budget values null
     *
     * @author          MST Solutions
     * @createdDate     unknown
    */
	public static void checkBudgetActuals(List<Case> budgetCaseList) {
		Set<Id> ActualsMatch = new Set<Id>();
		Set<Id> budgetIds = new Set<Id>();
		Map<Id, List<String>> pandaCase = new Map<Id, List<String>>();
		Map<Id, List<Wish_Expense__c>> wishExpenseListbyId = new Map<Id, List<Wish_Expense__c>>();

		for (Case caseTemp : budgetCaseList) {
			budgetIds.add(caseTemp.Id);
		}

		List<Wish_Expense__c> wishExpenseList = [
			SELECT Id, Budget_Cash__c, Budget_In_Kind__c, Projected_Cash__c, Projected_In_Kind__c,
				Actual_Cash__c,Actual_In_Kind__c,FE_Posted_Cash__c, FE_Posted_In_Kind__c, Case__c
			FROM Wish_Expense__c
			WHERE Case__c IN :budgetIds
			LIMIT 50000
		];

		for (Id caseId : budgetIds) {
			for (Wish_Expense__c wishExpense : wishExpenseList) {
				if (caseId == wishExpense.Case__c) {
					if (!wishExpenseListbyId.containsKey(caseId)) {
						wishExpenseListbyId.put(caseId, new List<Wish_Expense__c>{
							wishExpense
						});
					} else {
						wishExpenseListbyId.get(caseId).add(wishExpense);
					}
				}
			}
		}

		Decimal totalBudCash = 0;
		Decimal totalBudInKind = 0;
		Decimal totalProjCash = 0;
		Decimal totalProjInKind = 0;
		Decimal totalActCash = 0;
		Decimal totalActInKind = 0;
		Decimal totalFECash = 0;
		Decimal totalFEInkind = 0;

		for (Id IdStatus : wishExpenseListbyId.keySet()) {
			for (Wish_Expense__c expenseSatus : wishExpenseListbyId.get(IdStatus)) {
				if (expenseSatus.Budget_Cash__c != null) {
					totalBudCash = totalBudCash + expenseSatus.Budget_Cash__c;
				}
				if (expenseSatus.Budget_In_Kind__c != null) {
					totalBudInKind = totalBudInKind + expenseSatus.Budget_In_Kind__c;
				}
				if (expenseSatus.Projected_Cash__c != null) {
					totalProjCash = totalProjCash + expenseSatus.Projected_Cash__c;
				}
				if (expenseSatus.Projected_In_Kind__c != null) {
					totalProjInKind = totalProjInKind + expenseSatus.Projected_In_Kind__c;
				}
				if (expenseSatus.Actual_Cash__c != null) {
					totalActCash = totalActCash + expenseSatus.Actual_Cash__c;
				}
				if (expenseSatus.Actual_In_Kind__c != null) {
					totalActInKind = totalActInKind + expenseSatus.Actual_In_Kind__c;
				}
				if (expenseSatus.FE_Posted_Cash__c != null) {
					totalFECash = totalFECash + expenseSatus.FE_Posted_Cash__c;
				}
				if (expenseSatus.FE_Posted_In_Kind__c != null) {
					totalFEInkind = totalFEInkind + expenseSatus.FE_Posted_In_Kind__c;
				}
			}

			if (totalBudCash + totalBudInKind > 0 || totalBudInKind + totalProjInKind > 0) {
				if ((totalActCash + totalActInKind == 0 || totalFECash + totalFEInkind == 0)
					|| (totalActCash != totalFECash || totalActInKind != totalFEInkind)) {
					ActualsMatch.add(IdStatus);
				}
			} else if (totalBudCash + totalBudInKind == 0 && totalBudInKind + totalProjInKind == 0) {
				if (totalActCash != totalFECash || totalActInKind != totalFEInkind) {
					ActualsMatch.add(IdStatus);
				}
			}

			totalBudCash = 0;
			totalBudInKind = 0;
			totalProjCash = 0;
			totalProjInKind = 0;
			totalActCash = 0;
			totalActInKind = 0;
			totalFECash = 0;
			totalFEInkind = 0;
		}

		for (Case caseTemp : budgetCaseList) {
			if (ActualsMatch.contains(caseTemp.Id) && Bypass_Triggers__c.getValues(Utils.currentUser.Id) == null) {
				caseTemp.addError(Label.CaseTrigger_Budget_Posted_Match);
			}

			for (Id pandaItem : pandaCase.keySet()) {
				if (caseTemp.Id == pandaItem && Bypass_Triggers__c.getValues(Utils.currentUser.Id) == null) {
					for (String str : pandaCase.get(pandaItem)) {
						caseTemp.addError(str);
					}
				}
			}
		}
	}

	/*
     * @description     Check if any date fields in planning case are null.
     *
     * @author          MST Solutions
     * @createdDate     unknown
    */
	public static void checkReceivedDates(List<Case> receiveDateCaseList) {
		String message = '';
		Set<Id> budgetIds = new Set<Id>();

		for (Case caseTemp : receiveDateCaseList) {
			budgetIds.add(caseTemp.Id);
		}

		List<Case> pandACaseList = [
			SELECT Id,ParentId, Communication_Profile__c,
				Date_Received_for_Communication_Profile__c,
				Passports__c,Visas__c,Wish_Child_Form__c,
				Wish_Safety_Authorization_Part_B_Form__c
			FROM Case
			WHERE Id IN :budgetIds
			AND RecordTypeId = :WISH_RECORDTYPE_ID
			LIMIT 50000
		];

		for (Case panda : pandACaseList) {
			if (panda.Communication_Profile__c == true && panda.Date_Received_for_Communication_Profile__c == null) {
				if (message == '' || message == null) {
					message = MAP_OF_CASE_LABELS_BY_FIELDS.get(Case.Communication_Profile__c);
				} else {
					message = message + ',' + MAP_OF_CASE_LABELS_BY_FIELDS.get(Case.Communication_Profile__c);
				}
			}
		}

		if (!String.isBlank(message)) {
			for (Case caseTemp : receiveDateCaseList) {
				if (budgetIds.contains(caseTemp.Id) && Bypass_Triggers__c.getValues(UserInfo.getUserId()) == null) {
					caseTemp.addError(Label.CaseTrigger_Enter_Received_Date + ' ' + message);
				}
			}
		}
	}

	/*
     * @description     This method is used to update the Wish Clearance Needed field when the National Type is changed.
     *
     * @author          MST Solutions
     * @createdDate     unknown
    */
	public static void updateWishClearanceNeeded(Map<Id, Case> changedNationaltypeCaseMap) {
		Map<String, String> wishclearanceMap = new Map<String, String>();

		for (Wish_Clearance_Needed_and_National_type__mdt nationaltype : [
			SELECT MasterLabel,Wish_Clearance_Needed__c
			FROM Wish_Clearance_Needed_and_National_type__mdt
			LIMIT 50000
		]) {
			wishclearanceMap.put(nationaltype.MasterLabel, nationaltype.Wish_Clearance_Needed__c);
		}

		for (Case currCase : changedNationaltypeCaseMap.values()) {
			if (wishclearanceMap.containsKey(currCase.Wish_Type__c)) {
				currCase.Wish_Clearance_Needed__c = wishclearanceMap.get(currCase.Wish_Type__c);
			}
		}
	}
}