/**
 * @description Lead Service, centralizes Lead business rules.
 * @author Gustavo Mayer, Traction on Demand
 * @createdDate 2/27/2020
 */
public class LeadFileService {

	/**
	 * Delete Lead File found by Lead Id
	 * @param leadFileIds
	 * @return map of Delete Results
	 */
	public static Map<Id, Database.DeleteResult> deleteById(List<Id> leadFileIds) {
		List<cg__Lead_File__c> leadFiles = [
				SELECT Id
				FROM cg__Lead_File__c
				WHERE Id = :leadFileIds
		];
		List<Database.DeleteResult> results = Database.delete(leadFiles, false);
		Map<Id, Database.DeleteResult> mapDeleteResults = new Map<Id, Database.DeleteResult>();
		for (Database.DeleteResult result : results) {
			mapDeleteResults.put(result.id, result);
		}
		return mapDeleteResults;
	}

	/**
	 * Delete Non Folder Lead Files found by Lead Id
	 * @param leadId
	 */
	public static void deleteNonFolderByLeadId(Id leadId) {
		delete [
				SELECT Id
				FROM cg__Lead_File__c
				WHERE cg__Lead__c = :leadId
				AND cg__Content_Type__c != :Constant_AC.FILE_CONTENT_TYPE_FOLDER
		];
	}
}