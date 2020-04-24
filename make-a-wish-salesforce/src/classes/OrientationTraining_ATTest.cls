/**************************************************************
CreatedBy: Vennila Paramasivam
CreatedDate : 06/27/2016
Author : MST Solutions
Description : This test class written for OrientationTraining_AT trigger.
**************************************************************/
@IsTest(SeeAllData = false)
public class OrientationTraining_ATTest {

	@IsTest
	public static void createOrientation() {
		Orientation_Training__c currRec = new Orientation_Training__c();
		currRec.Name = 'Test 1';
		currRec.Start_Time__c = '1:00:PM';
		currRec.End_Time__c = '12:30:PM';
		Database.SaveResult result = Database.insert(currRec, false);
	}

	@IsTest
	public static void createValidOrientation() {
		Orientation_Training__c currRec = new Orientation_Training__c();
		currRec.Name = 'Test 2';
		currRec.Start_Time__c = '1:00:PM';
		currRec.End_Time__c = '1:30:PM';
		Database.SaveResult result = Database.insert(currRec, false);
		if (result.isSuccess()) {
			System.debug('Successfully inserted Orientation. Orientation ID: ' + result.getId());
		}

	}

	@IsTest
	public static void createInValidOrientation() {
		Orientation_Training__c currRec = new Orientation_Training__c();
		currRec.Name = 'Test 3';
		currRec.Start_Time__c = '7:00:PM';
		currRec.End_Time__c = '1:30:PM';
		Database.SaveResult result = Database.insert(currRec, false);
	}
}