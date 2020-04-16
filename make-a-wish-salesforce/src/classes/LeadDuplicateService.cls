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
        Id wishFamilyRT = Constant_AC.WISH_FAMILY_RT_ID;
        Id medicalProfessionalRT = Constant_AC.MEDICAL_PROFESSIONAL_RT_ID;
        String LogValue;
        Lead currLead = [
                SELECT Id, FirstName,Name,Of_Times_Email_Sent__c,LastName,Parent_Last_Name__c,Parent_First_Name__c,
                        Email, DOB__c,Phone,ChapterName__c, Using_Paper_Process_For_DV__c,
                        City, State, Street, PostalCode, Medical_Professional_First_Name__c, Medical_Professional_Last_Name__c,
                        Medical_Professional_Phone__c, Medical_Professional_Email__c, Treating_Medical_Professional_First_Name__c,
                        Treating_Medical_Professional_Last_Name__c,Treating_Medical_Professional_Phone__c,
                        Treating_Medical_Professional_Email__c, Best_contact_for_Physician_Email__c,
                        Best_Contact_for_Physician_Last_Name__c,Best_Contact_for_Physician_First_Name__c,
                        Additional_Parent_City__c,Additional_Parent_Email__c,Alternate2MedProfessionalLastName__c,
                        Alternate2MedProfessionalPhone__c,Additional_Parent_First_Name__c,Additional_Parent_Last_Name__c,
                        Additional_Parent_Phone__c,Alternate2MedProfessionalEmail__c,Alternate2MedProfessionalFirstName__c,
                        Alternate1MedicalProfessionalEmail__c,Alternate1MedProfessionalPhone__c,
                        Alternate1MedProfessionalLastName__c,Alternate1MedProfessionalFirstName__c,
                        Additional_Parent_Postal_Code__c,Additional_Parent_State__c,Additional_Parent_Street__c
                FROM Lead
                WHERE Id = :leadId
                AND RecordTypeId = :Constant_AC.LEAD_RT_WISH_CHILD
        ];
        LogValue = String.valueOf(currLead);
        List<Contact> dupMedicalContacts = ContactService.findDuplicatedContacts(
                currLead.Medical_Professional_First_Name__c,
                currLead.Medical_Professional_Last_Name__c,
                currLead.Medical_Professional_Phone__c,
                currLead.Medical_Professional_Email__c,
                new List<Id>{
                        medicalProfessionalRT
                }
        );
        List<Contact> dupTreatingContacts = ContactService.findDuplicatedContacts(
                currLead.Treating_Medical_Professional_First_Name__c,
                currLead.Treating_Medical_Professional_Last_Name__c,
                currLead.Treating_Medical_Professional_Phone__c,
                currLead.Treating_Medical_Professional_Email__c,
                new List<Id>{
                        medicalProfessionalRT
                }
        );
        List<Contact> dupBestContactPhysicians = ContactService.findDuplicatedContacts(
                currLead.Best_Contact_for_Physician_First_Name__c,
                currLead.Best_Contact_for_Physician_Last_Name__c,
                null,
                currLead.Best_contact_for_Physician_Email__c,
                new List<Id>{
                        medicalProfessionalRT
                }
        );
        List<Contact> alternate1MedProfessional = ContactService.findDuplicatedContacts(
                currLead.Alternate1MedProfessionalFirstName__c,
                currLead.Alternate1MedProfessionalLastName__c,
                '',
                currLead.Alternate1MedicalProfessionalEmail__c,
                new List<Id>{
                        medicalProfessionalRT
                }
        );
        List<Contact> alternate2MedProfessional = ContactService.findDuplicatedContacts(
                currLead.Alternate2MedProfessionalFirstName__c,
                currLead.Alternate2MedProfessionalLastName__c,
                '',
                currLead.Alternate2MedProfessionalEmail__c,
                new List<Id>{
                        medicalProfessionalRT
                }
        );
        List<Contact> dupFamilyContacts = ContactService.findFamilyDuplicatedContacts(
                currLead.Parent_First_Name__c, currLead.Parent_Last_Name__c,
                currLead.Phone, currLead.Email, currLead.Street,
                currLead.City, currLead.State, currLead.PostalCode,
                new List<Id>{
                        wishFamilyRT
                }
        );
        List<Contact> dupAdditionalFamilyContacts = ContactService.findFamilyDuplicatedContacts(
                currLead.Additional_Parent_First_Name__c, currLead.Additional_Parent_Last_Name__c,
                currLead.Additional_Parent_Phone__c, currLead.Additional_Parent_Email__c,
                currLead.Additional_Parent_Street__c, currLead.Additional_Parent_City__c,
                currLead.Additional_Parent_State__c, currLead.Additional_Parent_Postal_Code__c,
                new List<Id>{
                        wishFamilyRT
                }
        );
        if ((!dupMedicalContacts.isEmpty()
                || !dupTreatingContacts.isEmpty()
                || !alternate1MedProfessional.isEmpty()
                || !alternate2MedProfessional.isEmpty()) && (!dupFamilyContacts.isEmpty()
                || !dupAdditionalFamilyContacts.isEmpty())) {
            return String.format(Label.Existing_Record, new List<String>{
                    'Wish Family and Medical Professional'
            });
        } else if (!dupMedicalContacts.isEmpty()
                || !dupTreatingContacts.isEmpty()
                || !alternate1MedProfessional.isEmpty()
                || !alternate2MedProfessional.isEmpty()) {
            return String.format(Label.Existing_Record, new List<String>{
                    'Medical Professional'
            });
        } else if (!dupFamilyContacts.isEmpty()) {
            return String.format(Label.Existing_Record, new List<String>{
                    'Wish Family'
            });
        } else if (!dupAdditionalFamilyContacts.isEmpty()) {
            return String.format(Label.Existing_Record, new List<String>{
                    'Additional Parent/Guardian'
            });
        } else if (!dupBestContactPhysicians.isEmpty()) {
            return String.format(Label.Existing_Record, new List<String>{
                    'Best Physician Contact'
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
                            Email, DOB__c,Phone,ChapterName__c, City, State, Street, PostalCode,
                            Medical_Professional_First_Name__c, Medical_Professional_Last_Name__c,
                            Medical_Professional_Phone__c, Medical_Professional_Email__c,
                            Treating_Medical_Professional_First_Name__c, Treating_Medical_Professional_Last_Name__c,
                            Treating_Medical_Professional_Phone__c, Treating_Medical_Professional_Email__c
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

    webService static String resetDVMedicalSummary(Id leadId) {
        try {
            LeadService.resetLeadDvMedicalSummary(leadId);
            DiagnosisVerificationService.deleteByLeadId(leadId);
            DocuSignService.deleteByLeadIdAndDeleteRelatedAttachments(leadId);
            CaseService.deleteByLeadIdAndRecordTypeNames(leadId, new List<String>{
                    Constant_AC.DIAGNOSIS_RT_ID
            });
            LeadFileService.deleteNonFolderByLeadId(leadId);
        } catch (Exception ex) {
            String recId = leadId;
            new ApexDebugLog().createLog(new ApexDebugLog.Error('LeadWishFamilyDupe', 'resetDVMedicalSummary', recId, ex, String.valueOf(leadId)));
            return Label.Debug_log_error_message;
        }
        return null;
    }
}