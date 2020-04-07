/**
 * @author Steve Doucette, Traction on Demand 
 * @date 9/30/2019
 *
 * Created to cover any code from the Contact_OnBeforeUpdateTriggerHandler code that isn't covered by other test classes
 * NOTE: This will have NO assertions
 */

@IsTest
private class Contact_OnBeforeUpdateTriggerHandlerTest {
	@IsTest
	static void coverChangedICDFields() {
		List<ICD_Codes__c> icdCodes = TestDataFactory.createIcdCode(2);
		insert icdCodes;

		Contact c = TestDataFactory.createContact(1)[0];
		c.SD1_ICD_Code__c = icdCodes[0].Id;
		c.SD2_ICD_Code__c = icdCodes[0].Id;
		c.SD3_ICD_Code__c = icdCodes[0].Id;
		c.SD4_ICD_Code__c = icdCodes[0].Id;
		c.ICD_10_Code__c = icdCodes[0].Id;
		insert c;
		c.SD1_ICD_Code__c = icdCodes[1].Id;
		c.SD2_ICD_Code__c = icdCodes[1].Id;
		c.SD3_ICD_Code__c = icdCodes[1].Id;
		c.SD4_ICD_Code__c = icdCodes[1].Id;
		c.ICD_10_Code__c = icdCodes[1].Id;
		update c;
	}

	@IsTest
	static void coverChangedBirthdayFields() {
		ICD_Codes__c icdCode = TestDataFactory.createIcdCode(1)[0];
		insert icdCode;

		List<Contact> contacts = TestDataFactory.createContact(3);
		Contact birthdayChange = contacts[0];
		Contact birthdayChangeNull = contacts[1];
		Contact birthdayCustomChange = contacts[2];

		birthdayChange.RecordTypeId = Constant_AC.CONTACT_WISH_CHILD_RT_ID;
		birthdayChange.SD1_ICD_Code__c = icdCode.Id;
		birthdayChange.SD2_ICD_Code__c = icdCode.Id;
		birthdayChange.SD3_ICD_Code__c = icdCode.Id;
		birthdayChange.SD4_ICD_Code__c = icdCode.Id;
		birthdayChange.ICD_10_Code__c = icdCode.Id;
		birthdayChange.Birthdate = System.now().date();

		birthdayChangeNull.Birthdate = System.now().date();
		birthdayChangeNull.RecordTypeId = Constant_AC.CONTACT_WISH_CHILD_RT_ID;
		birthdayChangeNull.SD1_ICD_Code__c = icdCode.Id;
		birthdayChangeNull.SD2_ICD_Code__c = icdCode.Id;
		birthdayChangeNull.SD3_ICD_Code__c = icdCode.Id;
		birthdayChangeNull.SD4_ICD_Code__c = icdCode.Id;
		birthdayChangeNull.ICD_10_Code__c = icdCode.Id;

		birthdayCustomChange.RecordTypeId = Constant_AC.CONTACT_WISH_CHILD_RT_ID;
		birthdayCustomChange.SD1_ICD_Code__c = icdCode.Id;
		birthdayCustomChange.SD2_ICD_Code__c = icdCode.Id;
		birthdayCustomChange.SD3_ICD_Code__c = icdCode.Id;
		birthdayCustomChange.SD4_ICD_Code__c = icdCode.Id;
		birthdayCustomChange.ICD_10_Code__c = icdCode.Id;
		birthdayCustomChange.Birth_Year__c = '1';
		birthdayCustomChange.Birth_Month__c = 'January';
		//birthdayCustomChange.Birth_Day__c = '1';
		insert contacts;
		birthdayChange.Birthdate = birthdayChange.Birthdate.addDays(1);
		birthdayChangeNull.Birthdate = null;
		birthdayCustomChange.Birth_Year__c = '2';
		update contacts;
	}

	@IsTest
	static void coverHiddenFields() {
		ICD_Codes__c icdCode = TestDataFactory.createIcdCode(1)[0];
		insert icdCode;

		Contact c = TestDataFactory.createContact(1)[0];
		c.RecordTypeId = Constant_AC.CONTACT_WISH_CHILD_RT_ID;
		c.SD1_ICD_Code__c = icdCode.Id;
		c.SD2_ICD_Code__c = icdCode.Id;
		c.SD3_ICD_Code__c = icdCode.Id;
		c.SD4_ICD_Code__c = icdCode.Id;
		c.ICD_10_Code__c = icdCode.Id;
		insert c;

		npe4__Relationship__c newRlet = new npe4__Relationship__c();
		newRlet.npe4__RelatedContact__c = c.Id;
		newRlet.npe4__Status__c = 'Active';
		newRlet.npe4__Contact__c = c.Id;
		insert newRlet;

		c.Hidden_First_Name__c = 'FirstTest';
		c.Hidden_Last_Name__c = 'LastTest';
		c.Hidden_Phone__c = '1234567890';
		c.HiddenOtherPhone__c = '1234567890';
		c.HiddenMobilePhone__c = '1234567890';
		c.Hidden_Email__c = 'Test@test.com';
		c.Hidden_Street__c = 'Test Street';
		c.Hidden_Zip_Code__c = '12345';
		c.Hidden_city__c = 'Test';
		c.Hidden_State__c = 'Arizona';
		c.Hidden_Preferred_Contact_Rel_Id__c = newRlet.Id;
		update c;
		c.IsContactInfoUpdated__c = true;
		update c;
		c.IsRejected_Contact_Info__c = true;
		c.Hidden_Preferred_Contact_Rel_Id__c = 'Remove';
		c.Hidden_First_Name__c = null;
		c.Hidden_Last_Name__c = null;
		c.Hidden_Phone__c = null;
		c.HiddenOtherPhone__c = null;
		c.HiddenMobilePhone__c = null;
		c.Hidden_Email__c = null;
		c.Hidden_Street__c = null;
		c.Hidden_Zip_Code__c = null;
		c.Hidden_city__c = null;
		c.Hidden_State__c = null;
		update c;
	}
}