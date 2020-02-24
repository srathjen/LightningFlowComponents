/*******************************************************************************************************************************************
Description : Its Update the volunteer 
********************************************************************************************************************************************/
/**
 * JIRA: WLP-422
 * Author: Gustavo Mayer
 * Update: Changing the Volunteer_Roles status from 'Trained' to 'Active'
 */
global class Batch_UpdateVolunteerStatus_AC implements Database.Batchable<SObject> {
//  private final static String VOLUNTEER_ROLE_STATUS_ACTIVE = Constant_AC.VOLUNTEER_ROLE_STATUS_ACTIVE;
	global static List<Contact> start(Database.BatchableContext bc) {
		Id boardMemberRecordTypeId = Constant_AC.BOARD_MEMBER_RT_ID;
		Id volunteerRecordTypeId = Constant_AC.VOLUNTEER_RT_ID;
		return [
				SELECT Id,Active_Board_Member__c,Active_Wish_Granter__c,
						Active_Non_Wish_Granter__c,B_C_Expiration_Date__c,
						COI_Expiration_Date__c
				FROM Contact
				WHERE RecordTypeId IN (:volunteerRecordTypeId, :boardMemberRecordTypeId)
		];
	}
	global static void execute(Database.BatchableContext bc, List<Contact> contactList) {
		/**
		*  WLP-619
		*  Copying the code here to a central Class so it can be reused
		*/
		if (!contactList.isEmpty()) {
			Map<Id, Contact> contactMap = new Map<Id, Contact>(contactList);
			ContactService.setVolunteerContactActive(contactMap);
		}
//      Map<Id, Contact> contactMap = new Map<Id, Contact>();
//      Set<Id> activeConIdSet = new Set<Id>();
//      Map<Id, Contact> updateContactMap = new Map<Id, Contact>();
//      Set<Id> wishConId = new Set<Id>();
//      Map<Id, Date> volunteerLastComDate = New Map<Id, Date>();
//      Map<Id, String> affiliationStatusMap = New Map<Id, String>();
//      Contact updateCon;
//      Boolean boardMember, wish, nonWish, singleDay;
//      //Id WishRT = Schema.SObjectType.Volunteer_Opportunity__c.getRecordTypeInfosByName().get(constant.volunteerRT).getRecordTypeId();
//      for (Contact currRec : contactList) {
//          contactMap.put(currRec.Id, currRec);
//      }
//      for (npe5__Affiliation__c currAff : [
//              SELECT Id,npe5__Contact__c,npe5__Status__c
//              FROM npe5__Affiliation__c
//              WHERE npe5__Contact__c IN:contactMap.keySet()
//      ]) {
//          activeConIdSet.add(currAff.npe5__Contact__c);
//          if (affiliationStatusMap.containsKey(currAff.npe5__Contact__c)) {
//              if (currAff.npe5__Status__c == 'Active'
//                      && affiliationStatusMap.get(currAff.npe5__Contact__c) != 'Active') {
//                  affiliationStatusMap.put(currAff.npe5__Contact__c, currAff.npe5__Status__c);
//              }
//          } else {
//              affiliationStatusMap.put(currAff.npe5__Contact__c, currAff.npe5__Status__c);
//          }
//      }
//      for (Volunteer_Opportunity__c currRec : [
//              SELECT Volunteer_Name__c,Event_Date__c,Wish__r.Contact.Hidden_Granted_Date__c,RecordTypeId
//              FROM Volunteer_Opportunity__c
//              WHERE Volunteer_Name__c IN:activeConIdSet AND Role__C = 'Single Day Event Volunteer'
//      ]) {
//          if (volunteerLastComDate.containsKey(currRec.Volunteer_Name__c)) {
//              if (volunteerLastComDate.get(currRec.Volunteer_Name__c) < currRec.Event_Date__c) {
//                  volunteerLastComDate.put(currRec.Volunteer_Name__c, currRec.Event_Date__c);
//              } else if (volunteerLastComDate.get(currRec.Volunteer_Name__c) < currRec.Wish__r.Contact.Hidden_Granted_Date__c) {
//                  volunteerLastComDate.put(currRec.Volunteer_Name__c, currRec.Wish__r.Contact.Hidden_Granted_Date__c);
//              }
//          } else {
//              if (currRec.Event_Date__c == null && currRec.Wish__r.Contact.Hidden_Granted_Date__c != null) {
//                  volunteerLastComDate.put(currRec.Volunteer_Name__c, currRec.Wish__r.Contact.Hidden_Granted_Date__c);
//              } else if (currRec.Event_Date__c != null && currRec.Wish__r.Contact.Hidden_Granted_Date__c == null) {
//                  volunteerLastComDate.put(currRec.Volunteer_Name__c, currRec.Event_Date__c);
//              }
//          }
//      }
//      for (Volunteer_Roles__c currVolRole : [
//              SELECT id,Role_Name__c,Status__c,Volunteer_Name__c,Chapter_Role__r.Background_Check_Required__c
//              FROM Volunteer_Roles__c
//              WHERE Volunteer_Name__c IN:activeConIdSet
//      ]) {
//          if (currVolRole.Role_Name__c == Constant_AC.BOARD_MEMBER_RT_LABEL
//                  && affiliationStatusMap.get(currVolRole.Volunteer_Name__c) == 'Active'
//                  && currVolRole.Status__c == VOLUNTEER_ROLE_STATUS_ACTIVE
//                  && contactMap.get(currVolRole.Volunteer_Name__c).B_C_Expiration_Date__c > Date.Today()
//                  && contactMap.get(currVolRole.Volunteer_Name__c).COI_Expiration_Date__c > Date.Today()) {
//              boardMember = True;
//          } else {
//              if (updateContactMap.containsKey(currVolRole.Volunteer_Name__c)) {// && updateContactMap.get(currVolRole.Volunteer_Name__c).Active_Board_Member__c != True)
//                  boardMember = updateContactMap.get(currVolRole.Volunteer_Name__c).Active_Board_Member__c;
//              } else {
//                  boardMember = False;
//              }
//          }
//          /* if(!updateContactMap.containsKey(currVolRole.Volunteer_Name__c)){
//                  updateCon = new Contact();
//                  updateCon.Id = currVolRole.Volunteer_Name__c;
//
//              }
//              else
//                  updateCon = updateContactMap.get(currVolRole.Volunteer_Name__c);
//
//              updateCon.Active_Board_Member__c = True;
//              updateContactMap.put(currVolRole.Volunteer_Name__c,updateCon);*/
//
//          if ((currVolRole.Role_Name__c == 'Wish Granter'
//                  || currVolRole.Role_Name__c == 'Wish Granter Mentor')
//                  && affiliationStatusMap.get(currVolRole.Volunteer_Name__c) == 'Active'
//                  && currVolRole.Status__c == VOLUNTEER_ROLE_STATUS_ACTIVE
//                  && contactMap.get(currVolRole.Volunteer_Name__c).B_C_Expiration_Date__c > Date.Today()
//                  && contactMap.get(currVolRole.Volunteer_Name__c).COI_Expiration_Date__c > Date.Today()) {
//              wish = True;
//          } else {
//              if (updateContactMap.containsKey(currVolRole.Volunteer_Name__c)) {// && updateContactMap.get(currVolRole.Volunteer_Name__c).Active_Wish_Granter__c != True)
//                  wish = updateContactMap.get(currVolRole.Volunteer_Name__c).Active_Wish_Granter__c;
//              } else {
//                  wish = False;
//              }
//          }
//
//          /* if(!updateContactMap.containsKey(currVolRole.Volunteer_Name__c)){
//                  updateCon = new Contact();
//                  updateCon.Id = currVolRole.Volunteer_Name__c;
//
//              }
//              else
//                  updateCon = updateContactMap.get(currVolRole.Volunteer_Name__c);
//
//              updateCon.Active_Wish_Granter__c = True;
//              updateContactMap.put(currVolRole.Volunteer_Name__c,updateCon);*/
//
//          if (currVolRole.Status__c == VOLUNTEER_ROLE_STATUS_ACTIVE
//                  && affiliationStatusMap.get(currVolRole.Volunteer_Name__c) == 'Active'
//                  && contactMap.get(currVolRole.Volunteer_Name__c).COI_Expiration_Date__c > Date.Today()
//                  && ((currVolRole.Role_Name__c != Constant_AC.BOARD_MEMBER_RT_LABEL
//                  && currVolRole.Role_Name__c != 'Wish Granter'
//                  && currVolRole.Role_Name__c != 'Wish Granter Mentor')
//                  && ((currVolRole.Chapter_Role__r.Background_Check_Required__c == True
//                  && contactMap.get(currVolRole.Volunteer_Name__c).B_C_Expiration_Date__c > Date.Today())
//                  || currVolRole.Chapter_Role__r.Background_Check_Required__c == False))) {
//              /* if(!updateContactMap.containsKey(currVolRole.Volunteer_Name__c)){
//                    updateCon = new Contact();
//                    updateCon.Id = currVolRole.Volunteer_Name__c;
//                }
//                else
//                    updateCon = updateContactMap.get(currVolRole.Volunteer_Name__c);
//
//                updateCon.Active_Non_Wish_Granter__c = True;
//                updateContactMap.put(currVolRole.Volunteer_Name__c,updateCon); */
//              nonWish = True;
//          } else {
//              if (updateContactMap.containsKey(currVolRole.Volunteer_Name__c)) {// && updateContactMap.get(currVolRole.Volunteer_Name__c).Active_Non_Wish_Granter__c != True)
//                  nonwish = updateContactMap.get(currVolRole.Volunteer_Name__c).Active_Non_Wish_Granter__c;
//              } else {
//                  nonWish = False;
//              }
//          }
//
//          if (currVolRole.Role_Name__c == 'Single Day Event Volunteer'
//                  && affiliationStatusMap.get(currVolRole.Volunteer_Name__c) == 'Active'
//                  && volunteerLastComDate.containsKey(currVolRole.Volunteer_Name__c)
//                  && volunteerLastComDate.get(currVolRole.Volunteer_Name__c) > system.Today() - 365) {
//              /*  if(!updateContactMap.containsKey(currVolRole.Volunteer_Name__c)){
//                    updateCon = new Contact();
//                    updateCon.Id = currVolRole.Volunteer_Name__c;
//
//                }
//                else
//                    updateCon = updateContactMap.get(currVolRole.Volunteer_Name__c);
//
//                updateCon.Active_Single_Day_Event_Volunteer__c = True;
//                updateContactMap.put(currVolRole.Volunteer_Name__c,updateCon);   */
//              singleDay = True;
//          } else {
//              if (updateContactMap.containsKey(currVolRole.Volunteer_Name__c)) {
//                  singleDay = updateContactMap.get(currVolRole.Volunteer_Name__c).Active_Single_Day_Event_Volunteer__c ;
//              } else {
//                  singleDay = False;
//              }
//          }
//
//          if (!updateContactMap.containsKey(currVolRole.Volunteer_Name__c)) {
//              updateCon = new Contact();
//              updateCon.Id = currVolRole.Volunteer_Name__c;
//          } else {
//              updateCon = updateContactMap.get(currVolRole.Volunteer_Name__c);
//          }
//          updateCon.Active_Board_Member__c = boardmember;
//          updateCon.Active_Wish_Granter__c = wish;
//          updateCon.Active_Non_Wish_Granter__c = nonWish;
//          updateCon.Active_Single_Day_Event_Volunteer__c = singleDay;
//          updateContactMap.put(currVolRole.Volunteer_Name__c, updateCon);
//      }
//
//      if (updateContactMap.size() > 0) {
//          update updateContactMap.values();
//      }
	}
	global static void finish(Database.BatchableContext bc) {
	}
}