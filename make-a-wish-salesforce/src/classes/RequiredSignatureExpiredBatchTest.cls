/**
 * Created by mbuhler on 7/9/2019.
 */
@IsTest
public class RequiredSignatureExpiredBatchTest {

	private static final String CRON_STRING = '0 0 0 15 3 ? 2022';

	@TestSetup
	public static void setup() {
		List<Wish_Required_Signature__c> sigs = TestClassUtil.createWishRequiredSignatures(10);
		insert sigs;
	}

	@IsTest
	public static void runBatch() {
		List<Wish_Required_Signature__c> sigs = [
				SELECT Id, Status__c
				FROM Wish_Required_Signature__c
		];
		for (Wish_Required_Signature__c sig : sigs) {
			sig.Signed_Date__c = Date.today().addDays(-1);
			sig.Days_From_Signature_to_Expiry__c = 1;
			sig.Status__c = Constant_AC.WISH_REQUIRED_SIGNATURE_STATUS_SENT;
		}
		update sigs;

		Test.startTest();
		RequiredSignatureExpiredBatch batch = new RequiredSignatureExpiredBatch();
		System.schedule('RequiredSignatureExpiredBatchTest', CRON_STRING, batch);
		batch.execute(null);
		Test.stopTest();

		List<Wish_Required_Signature__c> updatedSigs = [
				SELECT Id, Status__c
				FROM Wish_Required_Signature__c
		];
		for (Wish_Required_Signature__c sig : updatedSigs) {
			System.assertEquals(Constant_AC.WISH_REQUIRED_SIGNATURE_STATUS_EXPIRED, sig.Status__c, 'Status should be ' + Constant_AC.WISH_REQUIRED_SIGNATURE_STATUS_EXPIRED);
		}
	}

	@IsTest
	public static void runBatchInvalidStatus() {
		List<Wish_Required_Signature__c> sigs = [
				SELECT Id, Status__c
				FROM Wish_Required_Signature__c
		];
		for (Wish_Required_Signature__c sig : sigs) {
			sig.Signed_Date__c = Date.today().addDays(-2);
			sig.Days_From_Signature_to_Expiry__c = 1;
			sig.Status__c = Constant_AC.WISH_REQUIRED_SIGNATURE_STATUS_VOIDED;
		}
		update sigs;

		Test.startTest();
		RequiredSignatureExpiredBatch batch = new RequiredSignatureExpiredBatch();
		System.schedule('RequiredSignatureExpiredBatchTest', CRON_STRING, batch);
		batch.execute(null);
		Test.stopTest();

		List<Wish_Required_Signature__c> updatedSigs = [
				SELECT Id, Status__c
				FROM Wish_Required_Signature__c
		];
		for (Wish_Required_Signature__c sig : updatedSigs) {
			System.assertEquals(Constant_AC.WISH_REQUIRED_SIGNATURE_STATUS_VOIDED, sig.Status__c, 'Status should be ' + Constant_AC.WISH_REQUIRED_SIGNATURE_STATUS_VOIDED);
		}
	}

	@IsTest
	public static void runBatchInvalidDate() {
		List<Wish_Required_Signature__c> sigs = [
				SELECT Id, Status__c
				FROM Wish_Required_Signature__c
		];
		for (Wish_Required_Signature__c sig : sigs) {
			sig.Signed_Date__c = Date.today();
			sig.Days_From_Signature_to_Expiry__c = 10;
		}
		update sigs;

		Test.startTest();
		RequiredSignatureExpiredBatch batch = new RequiredSignatureExpiredBatch();
		System.schedule('RequiredSignatureExpiredBatchTest', CRON_STRING, batch);
		batch.execute(null);
		Test.stopTest();

		List<Wish_Required_Signature__c> updatedSigs = [
				SELECT Id, Status__c
				FROM Wish_Required_Signature__c
		];
		for (Wish_Required_Signature__c sig : updatedSigs) {
			System.assertNotEquals(Constant_AC.WISH_REQUIRED_SIGNATURE_STATUS_EXPIRED, sig.Status__c, 'Status should NOT be ' + Constant_AC.WISH_REQUIRED_SIGNATURE_STATUS_EXPIRED);
		}
	}
}