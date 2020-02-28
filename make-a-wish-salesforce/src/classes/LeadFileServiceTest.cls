/**
 * @description Lead Service Test
 * @author Gustavo Mayer, Traction on Demand
 * @createdDate 2/27/2020
 */
@IsTest
public class LeadFileServiceTest {

	@TestSetup
	public static void setup() {
		List<cg__Lead_File__c> leadFilesDataFactory = TestDataFactory.createLeadFile(1);
		cg__Lead_File__c leadFile = leadFilesDataFactory.get(0);
		leadFile.cg__Description__c = 'Attachment01';
		insert leadFilesDataFactory;
	}

	@IsTest
	public static void shouldDeleteAttachments() {
		cg__Lead_File__c leadFile = [
				SELECT Id
				FROM cg__Lead_File__c
				WHERE cg__Description__c = 'Attachment01'
		];
		List<Id> leadFileIds = new List<Id>{
				leadFile.Id
		};

		Test.startTest();
		Map<Id, Database.DeleteResult> mapDeleteResults = LeadFileService.deleteById(leadFileIds);
		Test.stopTest();

		System.assertEquals(1, mapDeleteResults.size());
		System.assert(mapDeleteResults.get(leadFile.Id).isSuccess());
	}
}