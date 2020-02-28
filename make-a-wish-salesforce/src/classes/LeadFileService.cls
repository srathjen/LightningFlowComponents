/**
 * @description Lead Service, centralizes Lead business rules.
 * @author Gustavo Mayer, Traction on Demand
 * @createdDate 2/27/2020
 */
public class LeadFileService {

	public static Map<Id, Database.DeleteResult> deleteById(List<Id> leadFileIds) {
		List<cg__Lead_File__c> leadFiles = [
				SELECT Id
				FROM cg__Lead_File__c
				WHERE Id = :leadFileIds
		];
		List<Database.DeleteResult> results = Database.delete(leadFiles, false);
		Map<Id, Database.DeleteResult> mapDeleteResults = new Map<Id, Database.DeleteResult>();
		for(Database.DeleteResult result : results){
			mapDeleteResults.put(result.id, result);
		}
		return mapDeleteResults;
	}

	public static void deleteNonFolderByLeadId(Id leadId){
		List<cg__Lead_File__c> leadFiles = [
				SELECT Id
				FROM cg__Lead_File__c
				WHERE cg__Lead__c = :leadId
				AND cg__Content_Type__c != :Constant_AC.LEAD_FILE_CONTENT_TYPE_FOLDER
		];
		if (!leadFiles.isEmpty()) {
			delete leadFiles;
		}
	}
}