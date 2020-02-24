global class CreateWishFormRecords_AC implements Database.Batchable<sObject> {

	global Database.QueryLocator start(Database.BatchableContext BC) {

		return Database.getQueryLocator([
				SELECT Id, ContactId, (
						SELECT Id
						FROM Wish_Child_Form__r
				)
				FROM Case
				WHERE RecordType.Name = 'Wish' AND Status != 'Completed'
		]);
	}

	global void execute(Database.BatchableContext BC, List<Case > caseList) {
		Id ContactRecordTypeId = Constant_AC.WISH_FAMILY_RT_ID;
		Id wichChildRecordTypeId = Constant_AC.WISH_FORM_CHILD_ID;
		Id familyContactRecordTypeId = Constant_AC.WISH_FORM_FAMILY_ID;
		List<Wish_Child_Form__c> newWishChildFormINfoList = new List<Wish_Child_Form__c>();
		Map<String, List<npe4__Relationship__c>> wishFamilyMap = new Map<String, List<npe4__Relationship__c>>();
		Set<Id> contactIdSet = new Set<Id>();
		Map<Id, Id> contactCaseMap = new Map<Id, Id>();
		for (Case caseWithoutWishForm : caseList) {
			if (caseWithoutWishForm.Wish_Child_Form__r.size() == 0) {
				contactIdSet.add(caseWithoutWishForm.ContactId);
				contactCaseMap.put(caseWithoutWishForm.ContactId, caseWithoutWishForm.Id);
			}
		}
		/**
		 * JIRA: WLP-291
		 * Author: Gustavo Mayer
		 * Update: Non_Comped, Medical_Needs, Send_Wish_Forms__c and Residing_with_Wish_child__c
		 * to reside on Wish Affiliation object and to be removed from npe4__Relationship__c.
		 */
		if (contactIdSet.size() > 0) {
			Map<Id, Contact> contactInfoMap = new Map<Id, Contact>();
			for (npe4__Relationship__c currRel : [
					SELECT id, npe4__RelatedContact__c, npe4__Contact__c, Parent_Legal_Guardian__c,
							Wish_Participant__c, npe4__RelatedContact__r.FirstName, npe4__RelatedContact__r.LastName,
							npe4__RelatedContact__r.Email, Hidden_isparentFirst__c, npe4__RelatedContact__r.Phone,
							npe4__RelatedContact__r.Middle_Name__c, npe4__RelatedContact__r.Mailingcity,
							npe4__RelatedContact__r.Mailingstreet, npe4__RelatedContact__r.MailingState,
							npe4__RelatedContact__r.MailingPostalCode, npe4__Type__c, npe4__RelatedContact__r.HomePhone,
							npe4__RelatedContact__r.npe01__WorkPhone__c, npe4__RelatedContact__r.MobilePhone,
							npe4__RelatedContact__r.BirthDate,
//							npe4__RelatedContact__r.Residing_with_Wish_child__c,
							npe4__RelatedContact__r.T_Shirt_Size__c
					FROM npe4__Relationship__c
					WHERE npe4__Contact__c IN :contactIdSet AND npe4__RelatedContact__r.RecordTypeId = :ContactRecordTypeId
			]) {
				if (!wishFamilyMap.containsKey(currRel.npe4__Contact__c)) {
					wishFamilyMap.put(currRel.npe4__Contact__c, new List<npe4__Relationship__c>{
							currRel
					});
				} else {
					wishFamilyMap.get(currRel.npe4__Contact__c).add(currRel);
				}
			}

			for (Contact wishChildCon : [
					SELECT Id, FirstName, LastName, Middle_Name__c, Social_Media_Link__c, Already_wish_granted_by_MAW_Other_Org__c, If_yes_Enter_Org_Name_Wish_Date_it_was__c, Gender__c, Self_describe_comment_box__c, BirthDate, T_Shirt_Size__c, Diagnosis__c, Primary_Address__c, mobilePhone, Email, Color__c, Music_Singer__c, Book_Story__c, Hobby__c, Game__c, Movie__c, Food__c, TV_Show__c, Restaurant__c, Actor_Actress__c, Cake_Candy__c, Sport_Athlete__c, Snack_Food__c, Pet_Animal__c, Class_in_School__c, Other__c, When_I_m_outside_I_like_to__c, When_I_m_inside_I_like_to__c, Electronics_Games_that_I_like_to_play__c, When_I_m_with_my_family_I_like_to__c, When_I_m_with_my_friends_I_like_to__c, Region_Chapter__c, Parent_Legal_Guardian__c, RelatedContacts__c, MyWishIsTo__c, When_I_think_about_my_wish_I_imagine__c, This_is_my_wish_because__c, To_me_the_most_important_part_of_my_wish__c, Wish_Notes__c, When_thinking_some_of_my_wish_ideas_were__c, Race_Ethnicity__c, Race_Ethnicity_Details__c, Preferred_Name__c, MailingStreet, MailingCity, MailingState, MailingPostalcode
					FROM Contact
					WHERE Id IN :contactIdSet
			]) {
				contactInfoMap.put(wishChildCon.Id, wishChildCon);
			}

			if (contactInfoMap.size() > 0) {
				for (Contact currContact : contactInfoMap.values()) {
					Wish_Child_Form__c currWishChildForm = new Wish_Child_Form__c();
					currWishChildForm.Contact__c = currContact.Id;
					currWishChildForm.FirstName__c = currContact.FirstName;
					currWishChildForm.LastName__c = currContact.LastName;
					currWishChildForm.Middle_Name__c = currContact.Middle_Name__c;
					currWishChildForm.Social_Media_Link__c = currContact.Social_Media_Link__c;
					currWishChildForm.Already_wish_granted_by_MAW_Other_Org__c = currContact.Already_wish_granted_by_MAW_Other_Org__c;
					currWishChildForm.If_yes_Enter_Org_Name_Wish_Date_it_wa__c = currContact.If_yes_Enter_Org_Name_Wish_Date_it_was__c;
					currWishChildForm.Preferred_Name__c = currContact.Preferred_Name__c;
					currWishChildForm.Gender__c = currContact.Gender__c;
					currWishChildForm.Self_describe_comment_box__c = currContact.Self_describe_comment_box__c;
					currWishChildForm.BirthDate__c = currContact.BirthDate;
					currWishChildForm.T_Shirt_Size__c = currContact.T_Shirt_Size__c;
					currWishChildForm.Diagnosis__c = currContact.Diagnosis__c;
					//currWishChildForm.PrimaryAddreess__c = currContact.Primary_Address__c;
					currWishChildForm.mobilePhone__c = currContact.mobilePhone;
					currWishChildForm.Email__c = currContact.Email;
					currWishChildForm.Case__c = contactCaseMap.get(currContact.Id);
					currWishChildForm.Color__c = currContact.Color__c;
					currWishChildForm.Music_Singer__c = currContact.Music_Singer__c;
					currWishChildForm.Book_Story__c = currContact.Book_Story__c;
					currWishChildForm.Hobby__c = currContact.Hobby__c;
					currWishChildForm.Game__c = currContact.Game__c;
					currWishChildForm.Food__c = currContact.Food__c;
					currWishChildForm.Movie__c = currContact.Movie__c;
					currWishChildForm.TVShow__c = currContact.TV_Show__c;
					currWishChildForm.Restaurant__c = currContact.Restaurant__c;
					currWishChildForm.Actor_Actress__c = currContact.Actor_Actress__c;
					currWishChildForm.Cake_Candy__c = currContact.Cake_Candy__c;
					currWishChildForm.Sport_Athlete__c = currContact.Sport_Athlete__c;
					currWishChildForm.Snack_Food__c = currContact.Snack_Food__c;
					currWishChildForm.Pet_Animal__c = currContact.Pet_Animal__c;
					currWishChildForm.ClassinSchool__c = currContact.Class_in_School__c;
					currWishChildForm.Other__c = currContact.Other__c;
					currWishChildForm.When_I_m_outside_I_like_to__c = currContact.When_I_m_outside_I_like_to__c;
					currWishChildForm.When_I_m_inside_I_like_to__c = currContact.When_I_m_inside_I_like_to__c;
					currWishChildForm.Electronics_Games_that_I_like_to_play__c = currContact.Electronics_Games_that_I_like_to_play__c;
					currWishChildForm.When_I_m_with_my_family_I_like_to__c = currContact.When_I_m_with_my_family_I_like_to__c;
					currWishChildForm.When_I_m_with_my_friends_I_like_to__c = currContact.When_I_m_with_my_friends_I_like_to__c;
					currWishChildForm.RelatedContact__c = currContact.Parent_Legal_Guardian__c;
					currWishChildForm.RelatedContact__c = currContact.RelatedContacts__c;
					currWishChildForm.MY_WISH_IS_TO__c = currContact.MyWishIsTo__c;
					currWishChildForm.When_I_think_about_my_wish_I_imagine__c = currContact.When_I_think_about_my_wish_I_imagine__c;
					currWishChildForm.This_is_my_wish_because__c = currContact.This_is_my_wish_because__c;
					currWishChildForm.To_me_the_most_important_part_of_my_wish__c = currContact.To_me_the_most_important_part_of_my_wish__c;
					currWishChildForm.Wish_Notes__c = currContact.Wish_Notes__c;
					currWishChildForm.When_thinking_some_of_my_wish_ideas_were__c = currContact.When_thinking_some_of_my_wish_ideas_were__c;
					currWishChildForm.Race_Ethnicity__c = currContact.Race_Ethnicity__c;
					currWishChildForm.Race_Ethnicity_Details__c = currContact.Race_Ethnicity_Details__c;
					currWishChildForm.Preferred_Name__c = currContact.Preferred_Name__c;
					currWishChildForm.Street__c = currContact.MailingStreet;
					currWishChildForm.City__c = currContact.MailingCity;
					currWishChildForm.State__c = currContact.MailingState;
					currWishChildForm.Zip_code__c = currContact.MailingPostalcode;
					currWishChildForm.RecordTypeId = wichChildRecordTypeId;
					newWishChildFormINfoList.add(currWishChildForm);
				}
			}
			/**
			 * JIRA: WLP-291
			 * Author: Gustavo Mayer
			 * Update: Non-Comped, Medical_Needs, Send_Wish_Forms__c and Residing_with_Wish_child__c
			 * to reside on Wish Affiliation object and to be removed from npe4__Relationship__c.
			 */
			if (wishFamilyMap.size() > 0) {
				System.debug('>>>>>>>>');
				for (Id conIds : wishFamilyMap.keySet()) {
					System.debug('>>>>>>>>1');
					for (npe4__Relationship__c wishFamilyRel : wishFamilyMap.get(conIds)) {
						System.debug('>>>>>>>>2');
						Wish_Child_Form__c currWishChildForm = new Wish_Child_Form__c();
						currWishChildForm.RecordTypeId = familyContactRecordTypeId;
						currWishChildForm.Contact__c = wishFamilyRel.npe4__RelatedContact__c;
						currWishChildForm.FirstName__c = wishFamilyRel.npe4__RelatedContact__r.FirstName;
						currWishChildForm.Middle_Name__c = wishFamilyRel.npe4__RelatedContact__r.Middle_Name__c;
						currWishChildForm.LastName__c = wishFamilyRel.npe4__RelatedContact__r.LastName;
						currWishChildForm.Emergency_Relationship__c = wishFamilyRel.npe4__Type__c;
						currWishChildForm.Home_Phone__c = wishFamilyRel.npe4__RelatedContact__r.HomePhone;
						currWishChildForm.TelePhone__c = wishFamilyRel.npe4__RelatedContact__r.npe01__WorkPhone__c;
						currWishChildForm.mobilePhone__c = wishFamilyRel.npe4__RelatedContact__r.MobilePhone;
						currWishChildForm.Email__c = wishFamilyRel.npe4__RelatedContact__r.Email;
						currWishChildForm.BirthDate__c = wishFamilyRel.npe4__RelatedContact__r.BirthDate;
						currWishChildForm.Case__c = contactCaseMap.get(wishFamilyRel.npe4__Contact__c);
						System.debug('>>contactCaseMap.get(wishFamilyRel.npe4__RelatedContact__c);>>>' + contactCaseMap.get(wishFamilyRel.npe4__Contact__c));
						if (wishFamilyRel.Wish_Participant__c == true && wishFamilyRel.Parent_Legal_Guardian__c == true) {
							currWishChildForm.Hidden_Same_as_Family__c = true;
						} else if (wishFamilyRel.Wish_Participant__c == true) {
							currWishChildForm.IsParticipant__c = true;
							currWishChildForm.Hidden_Same_as_Family__c = false;
						}
						currWishChildForm.Street__c = wishFamilyRel.npe4__RelatedContact__r.Mailingstreet;
						currWishChildForm.City__c = wishFamilyRel.npe4__RelatedContact__r.Mailingcity;
						currWishChildForm.State__c = wishFamilyRel.npe4__RelatedContact__r.MailingState;
						currWishChildForm.Zip_code__c = wishFamilyRel.npe4__RelatedContact__r.MailingPostalCode;
//						currWishChildForm.Residing_With_Wish_Child__c = wishFamilyRel.npe4__RelatedContact__r.Residing_with_Wish_child__c;
						currWishChildForm.T_Shirt_Size__c = wishFamilyRel.npe4__RelatedContact__r.T_Shirt_Size__c;
						newWishChildFormINfoList.add(currWishChildForm);
					}
				}

			}
		}
		if (newWishChildFormINfoList.size() > 0) {
			insert newWishChildFormINfoList;
		}
	}

	global void finish(Database.BatchableContext BC) {

	}
}