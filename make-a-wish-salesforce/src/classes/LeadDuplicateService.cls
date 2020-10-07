/******************************************************
Modification Log:
1. 12/04/2018 - Yuvraj - IME-77 Line No: 237
2. 10/05/2018 - Yuvraj - IME-126 Line No: 290
3. 09/10/2019 - Manik - WLP-423
4. 01/03/2020 - C Smith - SIW-342 - field name changes reverted
5. 04/08/2020 - BMAC - SIW-546-Custom-Dup-Fire Line No: 178,183,188,202 207
*******************************************************/
    global class LeadDuplicateService {

    @TestVisible
    private static final String DUPE_MESSAGE = String.format(Label.Duplicate_Record, new List<String>{
            'Wish Child'
    });

    webService static String FindFamilyContactDupe(Id leadId) {
        String LogValue;
        Lead currLead = [
                SELECT Id, FirstName,Name,Of_Times_Email_Sent__c,LastName,Parent_Last_Name__c,Parent_First_Name__c,
                        Email, DOB__c,Phone,ChapterName__c, Using_Paper_Process_For_DV__c,
                        City, State, Street, PostalCode, Additional_Parent_City__c,
                        Additional_Parent_Email__c, Additional_Parent_First_Name__c,Additional_Parent_Last_Name__c,
                        Additional_Parent_Phone__c, Additional_Parent_Postal_Code__c,Additional_Parent_State__c,Additional_Parent_Street__c
                FROM Lead
                WHERE Id = :leadId
                AND RecordTypeId = :Constant_AC.LEAD_RT_WISH_CHILD
        ];
        LogValue = String.valueOf(currLead);
        List<Contact> dupFamilyContacts = ContactService.findFamilyDuplicatedContacts(
                currLead.Parent_First_Name__c, currLead.Parent_Last_Name__c,
                currLead.Phone, currLead.Email, currLead.Street,
                currLead.City, currLead.State, currLead.PostalCode,
                new List<Id>{
                        Constant_AC.WISH_FAMILY_RT_ID
                }
        );
        List<Contact> dupAdditionalFamilyContacts = ContactService.findFamilyDuplicatedContacts(
                currLead.Additional_Parent_First_Name__c, currLead.Additional_Parent_Last_Name__c,
                currLead.Additional_Parent_Phone__c, currLead.Additional_Parent_Email__c,
                currLead.Additional_Parent_Street__c, currLead.Additional_Parent_City__c,
                currLead.Additional_Parent_State__c, currLead.Additional_Parent_Postal_Code__c,
                new List<Id>{
                        Constant_AC.WISH_FAMILY_RT_ID
                }
        );
        if (!dupFamilyContacts.isEmpty()) {
            return String.format(Label.Existing_Record, new List<String>{
                    'Wish Family'
            });
        } else if (!dupAdditionalFamilyContacts.isEmpty()) {
            return String.format(Label.Existing_Record, new List<String>{
                    'Additional Parent/Guardian'
            });
        } else {
            return null;
        }
    }

    webService static String FindLeadDupe(Id leadId) {
        String LogValue;
        Id wishChild = Constant_AC.CONTACT_WISH_CHILD_RT_ID;
        try {
            List<Lead> leadList = [
                    SELECT Id, FirstName,Name,Of_Times_Email_Sent__c,LastName,Parent_Last_Name__c,Parent_First_Name__c,
                            Email, DOB__c,Phone,ChapterName__c, City, State, Street, PostalCode
                    FROM Lead
                    WHERE Id = :leadId
                    AND IsConverted = FALSE
                    AND RecordTypeId = :Constant_AC.LEAD_RT_WISH_CHILD
            ];
            LogValue = String.valueOf(leadList);
            List<Lead> exLeads = [
                    SELECT Id,LastName,Street,FirstName, Email, ChapterName__c,Phone, DOB__c,
                            City,State,PostalCode
                    FROM Lead
                    WHERE (LastName = :leadList[0].LastName OR FirstName = :leadList[0].FirstName
                    OR DOB__c = :leadList[0].DOB__c OR Phone = :leadList[0].Phone
                    OR Email = :leadList[0].Email OR (State = :leadList[0].State
                    AND PostalCode = :leadList[0].PostalCode AND City = :leadList[0].City))
                    AND Id != :leadList[0].Id AND IsConverted = FALSE
                    AND RecordTypeId = :Constant_AC.LEAD_RT_WISH_CHILD
            ];
            List<Contact> exContacts = [
                    SELECT Id, LastName,AccountId,MailingStreet,FirstName, Email, Phone, Birthdate,Region_Chapter__r.Name,
                            MailingCity, MailingState, MailingPostalCode
                    FROM Contact
                    WHERE (LastName = :leadList[0].LastName OR FirstName = :leadList[0].FirstName
                    OR Birthdate = :leadList[0].DOB__c OR ((MailingState = :leadList[0].State
                    AND MailingPostalCode = :leadList[0].PostalCode AND MailingCity = :leadList[0].City)
                    OR Phone = :leadList[0].Phone OR Email = :leadList[0].Email))
                    AND Region_Chapter__c = :leadList[0].ChapterName__c
                    AND RecordTypeId = :wishChild
            ];
            for (Lead currLead : leadList) {
                for (Lead exLead : exLeads) {
                    if (currLead.FirstName == exLead.FirstName && currLead.LastName == exLead.LastName) {
                        return DUPE_MESSAGE;
                    } else if (currLead.FirstName == exLead.FirstName &&
                            ((currLead.Street == exLead.Street && currLead.State == exLead.State
                                    && currLead.City == exLead.City && currLead.PostalCode == exLead.PostalCode)
                                    || currLead.Phone == exLead.Phone || (currLead.Email  != null && currLead.Email == exLead.Email))) {
                        return DUPE_MESSAGE;
                    } else if (currLead.LastName == exLead.LastName &&
                            ((currLead.Street == exLead.Street && currLead.State == exLead.State
                                    && currLead.City == exLead.City && currLead.PostalCode == exLead.PostalCode)
                                    || (currLead.Email  != null && currLead.Email == exLead.Email))) {
                        return DUPE_MESSAGE;
                    } else if ((currLead.DOB__c == exLead.DOB__c) &&
                            ((currLead.Street == exLead.Street && currLead.State == exLead.State
                                    && currLead.City == exLead.City && currLead.PostalCode == exLead.PostalCode)
                                    || (currLead.Email  != null && currLead.Email == exLead.Email))) {
                        return DUPE_MESSAGE;
                    } else if ((currLead.DOB__c == exLead.DOB__c) && (currLead.FirstName == exLead.FirstName
                            || currLead.LastName == exLead.LastName)) {
                        return DUPE_MESSAGE;
                    }
                }
                for (Contact exCon : exContacts) {
                    if (currLead.ChapterName__c == exCon.Region_Chapter__c) {
                        if (currLead.FirstName == exCon.FirstName && currLead.LastName == exCon.LastName) {
                            return DUPE_MESSAGE;
                        } else if ((currLead.FirstName == exCon.FirstName || currLead.LastName == exCon.LastName)
                                && ((currLead.Street == exCon.MailingStreet && currLead.State == exCon.MailingState
                                && currLead.City == exCon.MailingCity && currLead.PostalCode == exCon.MailingPostalCode)
                                || currLead.Phone == exCon.Phone || (currLead.Email  != null && currLead.Email == exCon.Email))) {
                            return DUPE_MESSAGE;
                        } else if ((currLead.DOB__c == exCon.Birthdate)
                                && ((currLead.Street == exCon.MailingStreet && currLead.State == exCon.MailingState
                                && currLead.City == exCon.MailingCity && currLead.PostalCode == exCon.MailingPostalCode)
                                || currLead.Phone == exCon.Phone || (currLead.Email  != null && currLead.Email == exCon.Email))) {
                            return DUPE_MESSAGE;
                        } else if ((currLead.DOB__c == exCon.Birthdate) && (currLead.FirstName == exCon.FirstName
                                || currLead.LastName == exCon.LastName)) {
                            return DUPE_MESSAGE;
                        }
                    }
                }
            }
        } catch (Exception ex) {
            String recId = leadId;
            new ApexDebugLog().createLog(new ApexDebugLog.Error(
                    'LeadWishFamilyDupe', 'FindLeadDupe', recId, ex, LogValue));
            return Label.Debug_log_error_message;
        }
        return null;
    }
}