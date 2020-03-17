/**
 * @description Lead Service, centralizes Lead business rules.
 * @author Gustavo Mayer, Traction on Demand
 * @createdDate 2/27/2020
 */
public class ContactFileService {

    private final static String CONTACT_FILE_CONTENT_TYPE_FOLDER = Constant_AC.CONTACT_FILE_CONTENT_TYPE_FOLDER;
    private final static String CONTACT_DOCUMENTS_FOLDER = Constant_AC.CONTACT_FILE_NAME_DOCUMENTS;
    private static final String CONTACT_PHOTOS_FOLDER = Constant_AC.CONTACT_FILE_NAME_PHOTOS;
    private static final String CONTACT_VIDEOS_FOLDER = Constant_AC.CONTACT_FILE_NAME_VIDEOS;

    public static List<cg__ContactFile__c> buildFileFoldersLeadConvert(Id contactId) {
        List<cg__ContactFile__c> leadConvertFileFolders = new List<cg__ContactFile__c>();
        cg__ContactFile__c picFolder = new cg__ContactFile__c();
        picFolder.cg__Contact__c = contactId;
        picFolder.cg__Content_Type__c = CONTACT_FILE_CONTENT_TYPE_FOLDER;
        picFolder.cg__File_Name__c = CONTACT_PHOTOS_FOLDER;
        picFolder.cg__WIP__c = false;
        leadConvertFileFolders.add(picFolder);
        cg__ContactFile__c docFolder = new cg__ContactFile__c();
        docFolder.cg__Contact__c = contactId;
        docFolder.cg__Content_Type__c = CONTACT_FILE_CONTENT_TYPE_FOLDER;
        docFolder.cg__File_Name__c = CONTACT_DOCUMENTS_FOLDER;
        docFolder.cg__WIP__c = false;
        leadConvertFileFolders.add(docFolder);
        cg__ContactFile__c videosFolder = new cg__ContactFile__c();
        videosFolder.cg__Contact__c = contactId;
        videosFolder.cg__Content_Type__c = CONTACT_FILE_CONTENT_TYPE_FOLDER;
        videosFolder.cg__File_Name__c = CONTACT_VIDEOS_FOLDER;
        videosFolder.cg__WIP__c = false;
        leadConvertFileFolders.add(videosFolder);
        return leadConvertFileFolders;
    }

    /**
     *
     * @param contactIds
     * @param convertedLeadIds
     * @param leadMap
     *
     * @return
     */
    public static List<cg__ContactFile__c> buildFilesLeadConvert(Map<Id, Lead> leadMap) {
        Set<Id> wishChildIds = new Set<Id>();
        for (Lead lead : leadMap.values()) {
            wishChildIds.add(lead.ConvertedContactId);
        }
        Map<Id, Id> docFolderContactsMAP = new Map<Id, Id>();
        for (cg__ContactFile__c contactFile : [
                SELECT Id, cg__Contact__c
                FROM cg__ContactFile__c
                WHERE cg__File_Name__c = :CONTACT_DOCUMENTS_FOLDER
                AND cg__Contact__c IN :wishChildIds
        ]) {
            docFolderContactsMAP.put(contactFile.cg__Contact__c, contactFile.Id);
        }
        List<cg__ContactFile__c> contactFiles = new List<cg__ContactFile__c>();
        for (cg__Lead_File__c leadFile : [
                SELECT Id, cg__Content_Type__c, cg__Description__c, cg__File_Name__c, cg__File_Size__c,
                        cg__Is_Latest_Version__c, cg__Key__c, cg__Lead__c, cg__Parent_Folder_Id__c,
                        Private__c, cg__Version_Description__c, cg__Version_Id__c, cg__WIP__c
                FROM cg__Lead_File__c
                WHERE cg__Lead__c IN :leadMap.keySet()
        ]) {
            cg__ContactFile__c ctcFile = new cg__ContactFile__c();
            ctcFile.cg__Contact__c = leadMap.get(leadFile.cg__Lead__c).ConvertedContactId;
            ctcFile.cg__Content_Type__c = leadFile.cg__Content_Type__c;
            ctcFile.cg__Description__c = leadFile.cg__Description__c;
            ctcFile.cg__File_Name__c = leadFile.cg__File_Name__c;
            ctcFile.cg__Is_Latest_Version__c = leadFile.cg__Is_Latest_Version__c;
            ctcFile.cg__Key__c = leadFile.cg__Key__c;
            ctcFile.cg__Parent_Folder_Id__c = docFolderContactsMAP.get(leadMap.get(leadFile.cg__Lead__c).ConvertedContactId);
            ctcFile.cg__Private__c = leadFile.Private__c;
            ctcFile.cg__Version_Description__c = leadFile.cg__Version_Description__c;
            ctcFile.cg__Version_Id__c = leadFile.cg__Version_Id__c;
            ctcFile.cg__WIP__c = leadFile.cg__WIP__c;
            contactFiles.add(ctcFile);
        }
        return contactFiles;
    }

    /**
     * @param newAccountFiles
     */
    public static void updateContactFilePath(List<cg__ContactFile__c> newContactFiles) {
        List<Id> contactIds = new List<Id>();
        Map<Id, String> contactFileMap = new Map<Id, String>();

        for (cg__ContactFile__c con : newContactFiles) {
            contactIds.add(con.Id);
            contactFileMap.put(con.Id, String.valueOf(con));
        }
        if (contactIds.size() > 0) {
            AWSFilePathService.updateContactFilePath(contactIds, contactFileMap);
        }
    }

    /**
     * @param newAccountFiles
     */
    public static void updateContactFileFolderId(List<cg__ContactFile__c> newContactFiles) {
		Map<Id, cg__ContactFile__c> newFileMap = new Map<Id, cg__ContactFile__c>();
		Map<Id, Id> contactFileMap = new Map<Id, Id>();
		Set<Id> conId = new Set<Id>();
		Map<Id, cg__ContactFile__c > folderIdsMap = new Map<Id, cg__ContactFile__c>();
		for (cg__ContactFile__c conFile : newContactFiles) {
			newFileMap.put(conFile.Id, conFile);
			conId.add(conFile.cg__Contact__c);
		}

		if (conId.size() > 0) {
			for (cg__ContactFile__c contactFile : [
					SELECT Id, cg__Content_Type__c, cg__File_Name__c, cg__Contact__c, cg__Contact__r.Name, cg__Parent_Folder_Id__c
					FROM cg__ContactFile__c
					WHERE cg__Contact__c IN :conId AND cg__Content_Type__c = :Constant_AC.CONTACT_FILE_CONTENT_TYPE_FOLDER
			]) {
				if (contactFile.cg__File_Name__c == Constant_AC.CONTACT_FILE_NAME_DOCUMENTS) {
					contactFileMap.put(contactFile.cg__Contact__c, contactFile.Id);
				}
				folderIdsMap.put(contactFile.Id, contactFile);
			}
			for (cg__ContactFile__c conFile1 : newContactFiles) {
				if (folderIdsMap.containsKey(conFile1.cg__Parent_Folder_Id__c)) {
					conFile1.Parent_Folder_Name__c = folderIdsMap.get(conFile1.cg__Parent_Folder_Id__c).cg__File_Name__c;
				}
			}
			if (contactFileMap.size() > 0) {
				List<cg__ContactFile__c> updateContactFileList = new List<cg__ContactFile__c>();
				for (cg__ContactFile__c newConFile : newFileMap.values()) {
					if (contactFileMap.containsKey(newConFile.cg__Contact__c)) {
						if (newConFile.cg__Content_Type__c != Constant_AC.CONTACT_FILE_CONTENT_TYPE_FOLDER) {
							newConFile.cg__Parent_Folder_Id__c = contactFileMap.get(newConFile.cg__Contact__c);
							updateContactFileList.add(newConFile);
						}
					}
				}
			}
		}
    }
}