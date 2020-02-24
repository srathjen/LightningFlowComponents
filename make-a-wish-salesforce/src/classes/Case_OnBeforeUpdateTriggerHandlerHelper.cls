/*****************************************************************************************************************
Author      : MST Solutions
Date        : 5/26/2016
Description : When a new case record updated then it will update the values to corresponding fields and also
it update the field values to related objects like Account, contact, VolunteerOpportunity.
*******************************************************************************************************************/

public class Case_OnBeforeUpdateTriggerHandlerHelper {

	private final static Id wishRecordTypeId = Constant_AC.WISH_RT_ID;

	/*********************************************************************************************************************
	This method is used to display the error message when the region code is entered incorrectly.
	*******************************************************************************************************************/
	public static void wishChildRegionValidation(Map<Id, Case> parentCaseMap, Set<Id> contactSet) {
		Id wishChildRecordTypeId = Constant_AC.CONTACT_WISH_CHILD_RT_ID;
		Map<Id, Contact> wishChildMap = new Map<Id, Contact>();
		if (contactSet.size() > 0) {
			//try{
			for (Contact wishChild : [
					SELECT Id, Region_Code__c, County__c
					FROM Contact
					WHERE RecordTypeId = :wishChildRecordTypeId
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
								&& Bypass_Triggers__c.getValues(UserInfo.getUserId()) == null) {
							parentCase.addError('Please add region and county on the wish child\'s contact record.');
						} else if (wishChildMap.get(parentCase.ContactId).Region_Code__c == null
								&& Bypass_Triggers__c.getValues(UserInfo.getUserId()) == null) {
							parentCase.addError('Please add region on the wish child\'s contact record.');
						} else if (wishChildMap.get(parentCase.ContactId).County__c == null
								&& Bypass_Triggers__c.getValues(UserInfo.getUserId()) == null) {
							parentCase.addError('Please add county on the wish child\'s contact record.');
						}

					}
				}
			}
			/*}
			 catch(Exception e){
				 for(case newCase : parentCaseMap.values()){
					 newCase.addError(e.getMessage());
				 }
			 }*/
		}
	}

	/*********************************************************************************************************************
This method will fire when the parent case status is updated as completed and if budget values is null then it will
display error message.
*******************************************************************************************************************/
	public static void checkBudgetActuals(List<Case> budgetCaseList) {
		Set<Id> ActualsMatch = new Set<Id>();
		Set<Id> budgetIds = new Set<Id>();
		String message = '';
		Map<Id, List<String>> pandaCase = new Map<Id, List<String>>();
		Map<Id, List<Wish_Expense__c>> wishExpenseListbyId = new Map<Id, List<Wish_Expense__c>>();
		//try{
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
			if (ActualsMatch.contains(caseTemp.Id) && Bypass_Triggers__c.getValues(UserInfo.getUserId()) == null) {
				caseTemp.addError('The Wish Budget Actual and FE Posted total values should match.');
			}
			for (Id pandaItem : pandaCase.keySet()) {
				if (caseTemp.Id == pandaItem && Bypass_Triggers__c.getValues(UserInfo.getUserId()) == null) {
					for (String str : pandaCase.get(pandaItem)) {
						caseTemp.addError(str);
					}
				}
			}
		}
		/*}
		catch(Exception e){
			for(case newCase : budgetCaseList){
				newCase.addError(e.getMessage());
			}
		} */
	}

	/*********************************************************************************************************************
	This method will fire when the parent case status is updated as completed or colsed or DNQ then it will check if any date
	fields in planing case is null or not. If it is null then it will display error message.
	*******************************************************************************************************************/
	public static void checkReceivedDates(List<Case> receiveDateCaseList) {
		String message = '';
		Set<Id> budgetIds = new Set<Id>();
		//try{
		for (Case caseTemp : receiveDateCaseList) {
			budgetIds.add(caseTemp.Id);
		}
		/**
		 * JIRA: WLP-286
		 * Author: Gustavo Mayer
		 * Update: Sub case conversion to the single Wish Case, finding the
		 * case by Id and not ParentId
		 */
		/**
		 * JIRA: WLP-556
		 * Author: Gustavo Mayer
		 * Update: Deprecating fields
		 */
		List<Case> pandACaseList = [
				SELECT Id,ParentId, Communication_Profile__c,
//						Date_Liability_Release_Authorization__c,
						Date_Received_for_Communication_Profile__c,
//						Date_Received_for_Passports__c,
//						Date_Received_for_Visas__c,
						Passports__c,Visas__c,Wish_Child_Form__c,
						Wish_Safety_Authorization_Part_B_Form__c
				FROM Case
				WHERE Id IN :budgetIds
				AND RecordTypeId = :wishRecordTypeId
				LIMIT 50000
		];
		for (Case panda : pandACaseList) {
// 			if (panda.Wish_Child_Form__c == true && panda.Date_Wish_Child_Form__c == null) {
// 				if (message == '' || message == null)
// 					message = 'Wish Child Form';
// 			}
// 			if (panda.Wish_Family_Form__c == true && panda.Date_Wish_Family_Form__c == null) {
// 				if (message == '' || message == null)
// 					message = 'Wish Family Form'; else
// 						message = message + ',' + 'Wish Family Form';
// 			}
// 			if (panda.Wish_Information_Form__c == true && panda.Date_Wish_Information_Form__c == null) {
// 				if (message == '' || message == null)
// 					message = 'Wish Information Form'; else
// 						message = message + ',' + 'Wish Information Form';
// 			}
//			if (panda.Date_Liability_Release_Authorization__c == null) {
//				if (message == '' || message == null)
//					message = 'Liability Release And Authorization'; else
//						message = message + ',' + 'Liability Release And Authorization';
//			}
			if (panda.Communication_Profile__c == true && panda.Date_Received_for_Communication_Profile__c == null) {
				if (message == '' || message == null)
					message = 'Communication Profile'; else
						message = message + ',' + 'Communication Profile';
			}
// 			if (panda.Guardianship_Document__c == true && panda.Date_Received_for_Guardianship_Document__c == null) {
// 				if (message == '' || message == null)
// 					message = 'Guardianship Document'; else
// 						message = message + ',' + 'Guardianship Document';
// 			}
// 			if (panda.Absent_Parent_Form__c == true && panda.Date_Received_for_Absent_Parent_Form__c == null) {
// 				if (message == '' || message == null)
// 					message = 'Absent Parent Form'; else
// 						message = message + ',' + 'Absent Parent Form';
// 			}
// 			if (panda.Single_Parent_Form__c == true && panda.Date_Received_for_Single_Parent_Form__c == null) {
// 				if (message == '' || message == null)
// 					message = 'Single Parent Form'; else
// 						message = message + ',' + 'Single Parent Form';
// 			}
			/*if (panda.Wish_Safety_Authorization_Part_B_Form__c == true) {
				if (message == '' || message == null)
					message = 'Wish Clearance Form'; else
						message = message + ',' + 'Wish Clearance Form';
			}*/
// 			if (panda.Child_s_Medical_Summary_Form__c == true && panda.Date_Received_for_Child_s_Medical_Summar__c == null) {
// 				if (message == '' || message == null)
// 					message = 'Child’s Medical Summary Form'; else
// 						message = message + ',' + 'Child’s Medical Summary Form';
// 			}
//			if (panda.Passports__c == true && panda.Date_Received_for_Passports__c == null) {
//				if (message == '' || message == null)
//					message = 'Passports'; else
//						message = message + ',' + 'Passports';
//			}
//			if (panda.Visas__c == true && panda.Date_Received_for_Visas__c == null) {
//				if (message == '' || message == null)
//					message = 'Visas'; else
//						message = message + ',' + 'Visas';
//			}
// 			if (panda.Entertainment_Sports_Wish_LOU__c == true && panda.Date_Received_for_Entertainment_Sports__c == null) {
// 				if (message == '' || message == null)
// 					message = 'Entertainment & Sports Wish LOU'; else
// 						message = message + ',' + 'Entertainment & Sports Wish LOU';
// 			}
		}
		if (!String.isBlank(message)) {
			for (Case caseTemp : receiveDateCaseList) {
				if (budgetIds.contains(caseTemp.Id) && Bypass_Triggers__c.getValues(UserInfo.getUserId()) == null) {
					caseTemp.addError('Please enter the received date for the following forms -' + message);
				}
			}
		}
		/*}
		catch(Exception e){
			for(case newCase : receiveDateCaseList){
				newCase.addError(e.getMessage());
			}
		}*/
	}

	/************************************************************************************
	 *This method is used to update the Wish Clearance Needed field when the National Type is changed.
	 * ***********************************************************************************/
	public static void updateWishClearanceNeeded(Map<Id, Case> changedNationaltypeCaseMap) {
		Map<String, String> wishclearanceMap = new Map<String, String>();
		//Query the meta data type for all national type and wish crearance needed.
		for (Wish_Clearance_Needed_and_National_type__mdt nationaltype : [
				SELECT MasterLabel,Wish_Clearance_Needed__c
				FROM Wish_Clearance_Needed_and_National_type__mdt
				LIMIT 50000
		]) {
			wishclearanceMap.put(nationaltype.MasterLabel, nationaltype.Wish_Clearance_Needed__c);
		}
		for (Case currCase : changedNationaltypeCaseMap.values()) {
			if (wishclearanceMap.containsKey(currCase.Wish_type__C)) {
				currCase.Wish_Clearance_Needed__c = wishclearanceMap.get(currCase.Wish_type__C);
			}
		}
	}
}