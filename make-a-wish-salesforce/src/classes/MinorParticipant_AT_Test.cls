@isTest
public class MinorParticipant_AT_Test {

	@testSetup
	static void methodName() {
		Id wishClearenceRecordTypeId = Constant_AC.WISH_CLEARANCE_ATTACHMENT_ID;
		Contact wishChildCon = OrientationandTrainingUtil.CreateWishChild();
		insert wishChildCon;
		Case parentCase = OrientationandTrainingUtil.CreateParentCase(wishChildCon.Id);
		insert parentCase;
		Minor_Participant__c newParticipant = new Minor_Participant__c(Associated_Childeren__c = 'Test',
				AttachmentId__c = 'Test', RecordTypeId = wishClearenceRecordTypeId, Case__c = parentCase.Id);
		insert newParticipant;
	}

	static testMethod void createNewCase() {
		Id wishClearenceRecordTypeId = Constant_AC.WISH_CLEARANCE_ATTACHMENT_ID;
		Case parentCase = [
				SELECT Id
				FROM Case
				LIMIT 1
		];
		Minor_Participant__c newParticipant = new Minor_Participant__c(Associated_Childeren__c = 'Test', AttachmentId__c = 'Test', RecordTypeId = wishClearenceRecordTypeId, Case__c = parentCase.Id);
		insert newParticipant;
		Contact wishChildCon = OrientationandTrainingUtil.CreateWishChild();
		insert wishChildCon;
		Minor_Participant__c updatePart = new Minor_Participant__c();
		updatePart.Id = newParticipant.Id;
		updatePart.Associated_Childeren__c = 'Test2';
		update updatePart;
	}

	static testMethod void createMinorRec() {
		Id comboRecordTypeId = Constant_AC.COMBO_RECORD_ID;
		Contact wishChildCon = OrientationandTrainingUtil.CreateWishChild();
		insert wishChildCon;
		Case parentCase = [
				SELECT Id
				FROM Case
				LIMIT 1
		];
		Minor_Participant__c createcomboRec = new Minor_Participant__c();
		createcomboRec.Hidden_Combo_FirstName__c = 'TesFirstName';
		createcomboRec.Hidden_Combo_MiddleName__c = 'MiddleName';
		createcomboRec.Hidden_Combo_LastName__c = 'TestLastName';
		createcomboRec.Hidden_Combo_Relationship__c = 'father';
		createcomboRec.Hidden_Combo_DOB__c = system.today() - 1232;
		createcomboRec.Hidden_Combo_Street__c = 'TestStreet';
		createcomboRec.Hidden_Combo_City__c = 'Trichy';
		createcomboRec.Hidden_Combo_State__c = 'Arizona';
		createcomboRec.Hidden_Combo_HomePhone__c = '9600467559';
		createcomboRec.Hidden_Combo_MobilePhone__c = '8056913402';
		createcomboRec.Hidden_Combo_TelePhone__c = '9003910426';
		createcomboRec.Hidden_Combo_Email__c = 'test@gmail.com';
		createcomboRec.Hidden_Combo_ContactId__c = wishChildCon.Id;
		createcomboRec.Hidden_Combo_Zipcode__c = '621010';
		createcomboRec.RecordTypeId = comboRecordTypeId;
		createcomboRec.Case__c = parentCase.Id;
		insert createcomboRec;

		Minor_Participant__c updatePart = new Minor_Participant__c();
		updatePart.Id = createcomboRec.Id;
		updatePart.Hidden_Combo_City__c = 'Covai';
		update updatePart;
	}
}