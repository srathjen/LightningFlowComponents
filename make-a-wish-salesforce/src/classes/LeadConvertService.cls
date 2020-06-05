/**
 * Created by gmayer on 05-Mar-20.
 */

public class LeadConvertService {

    private final static String MEDICAL_PROFESSIONAL_LABEL = Constant_AC.MEDICAL_PROFESSIONAL_RT_LABEL;
    private final static Id WISH_FAMILY_ID = Constant_AC.WISH_FAMILY_RT_ID;
    private final static Id DIAGNOSIS_ID = Constant_AC.DIAGNOSIS_RT_ID;
    private final static Id HOSPITAL_TREATMENT_ID = Constant_AC.HOSPITAL_TREATMENT_ID;
    private static final String LEAD_DV_FORM_TYPE_TREATING_MEDICAL_PROFESSIONAL = Constant_AC.LEAD_DV_FORM_TYPE_TREATING_MEDICAL_PROFESSIONAL;
    private static final String LEAD_DV_FORM_TYPE_BEST_CONTACT = Constant_AC.LEAD_DV_FORM_TYPE_BEST_CONTACT;
    private static final String LEAD_DV_FORM_TYPE_ALTERNATE_1_MEDICAL_PROFESSIONAL = Constant_AC.LEAD_DV_FORM_TYPE_ALTERNATE_1_MEDICAL_PROFESSIONAL;
    private static final String LEAD_DV_FORM_TYPE_ALTERNATE_2_MEDICAL_PROFESSIONAL = Constant_AC.LEAD_DV_FORM_TYPE_ALTERNATE_2_MEDICAL_PROFESSIONAL;
    private static final String SUBJECT_DIAGNOSIS_VERIFICATION = Constant_AC.DOCUSIGN_SUBJECT_DIAGNOSIS_VERIFICATION_FORM;
    private static final String MEDICAL_REASON_MOVING_QUICKLY_YES = Constant_AC.LEAD_MEDICAL_REASON_FOR_MOVING_QUICKLY_YES;
    private static final String AFFILIATION_STATUS_ACTIVE = Constant_AC.ORG_AFFILIATION_STATUS_ACTIVE;
    private static final String DASH = '-';

    /**
     * Convert the "Qualified" leads
     * @param qualifiedLeadMap
     * @return Map By Lead Id and Contact Id
     */
    public static Map<Id, Id> convertLead(Map<Id, Lead> qualifiedLeadMap) {
        RecursiveTriggerHandler.isFirstTime = false;
        Map<Id, Id> leadIdConvertedByContactIdMap = new Map<Id, Id>();
        List<Database.LeadConvert> leadConverts = new List<Database.LeadConvert>();
        LeadStatus convertStatus = [
                SELECT MasterLabel
                FROM LeadStatus
                WHERE IsConverted = TRUE
                LIMIT 1
        ];
        for (Lead lead : qualifiedLeadMap.values()) {
            // Add all updated leads to the LeadConvert object
            Database.LeadConvert lc = new Database.LeadConvert();
            lc.setLeadId(lead.Id);
            lc.setDoNotCreateOpportunity(true);
            lc.setConvertedStatus(convertStatus.MasterLabel);
            leadConverts.add(lc);
        }
        if (!leadConverts.isEmpty()) {
            List<Database.LeadConvertResult> convertResults = Database.convertLead(leadConverts);
            for (Database.LeadConvertResult leadResult : convertResults) {
                leadIdConvertedByContactIdMap.put(leadResult.getLeadId(), leadResult.getContactId());
            }
        }
        return leadIdConvertedByContactIdMap;
    }

    /**
     * Process the "Qualified" leads, create a new wish child, wish family and medical professionals contact
     * checking for any potential duplicate records.
     * @param leadIdConvertedByContactIdMap
     */
    public static void processConvertedLead(Map<Id, Id> leadIdConvertedByContactIdMap) {
        Map<Id, Account> accountMap = new Map<Id, Account>();
        String convertedAccId;
        Map<String, Account> medicalAccountMap = new Map<String, Account>();
        Map<Id, Case> caseMap = new Map<Id, Case>();
        List<Case>caseList = new List<Case>();
        Map<Id, Contact> wishChildContactMap = new Map<Id, Contact>();
        List<Contact> leadNewContacts = new List<Contact>();
        List<cg__ContactFile__c> contactFiles = new List<cg__ContactFile__c>();
        Map<Id, Lead> convertedAccountMap = new Map<Id, Lead>();
        Map<Id, Lead> existingMedicalProfIdMap = new Map<Id, Lead>();
        Map<Id, Lead> convertedLeadsById = new Map<Id, Lead>();
        Map<Id, Lead> contactIdByLeadMap = new Map<Id, Lead>();
        Set<Id> leadCases = new Set<Id>();
        Set<Id> allLeadContacts = new Set<Id>();
        List<Case> partACaseList = new List<Case>();
        List<dsfs__DocuSign_Status__c > dsfsList = new List<dsfs__DocuSign_Status__c>();
        Map<Id, npe4__Relationship__c> relationshipMap = new Map<Id, npe4__Relationship__c>();
        List<Task> rushReminderList = new List<Task>();
        try {
            if (!leadIdConvertedByContactIdMap.isEmpty()) {
                for (Lead convertedLead : [
                        SELECT Id, Name, DOB__c, FirstName, Why_do_you_feel_would_be_eligible_Wish__c, LastName, CreatedDate, Migrated_Record__c,
                                I_am_Recognized_To_Practice_As_a__c, Sibling_Detail__c, Medical_Provider_Category__c,
                                ChapterName__r.Name, ChapterName__c, Treating_Medical_Professional_First_Name__c, ConvertedContactId, ConvertedAccountId,
                                Other_Relationship_To_Child__c, Relationship_to_child__c, LeadSource, Treating_Medical_Professional_Phone__c,
                                Treating_Medical_Professional_Email__c, is_Family_Aware_of_Referral__c, Treating_Medical_Professional_Last_Name__c, Referrer_City__c,
                                Referrer_Email__c, Referrer_FirstName__c, Referrer_Last_Name__c, Referrer_Phone__c, Referrer_Zip__c,
                                Parent_First_Name__c, Alternate1MedProfessionalPhone__c, Alternate1MedicalProfessionalEmail__c,
                                Alternate1MedProfessionalFirstName__c, Alternate1MedProfessionalLastName__c,
                                What_is_the_family_s_primary_spoken_lang__c, Parent_Last_Name__c, Email,
                                Phone, City, Alternate2MedProfessionalFirstName__c, Alternate2MedProfessionalEmail__c,
                                Alternate2MedProfessionalLastName__c, Alternate2MedProfessionalPhone__c,
                                CountryCode, PostalCode, State, StateCode, Street, Treating_Medical_Professional_Contact_Id__c,
                                Medical_Professional_ContactId__c, Wish_Family_ContactId__c, Best_contact_for_Physician_Email__c,
                                Best_Contact_for_Physician_First_Name__c, Best_Contact_for_Physician_Last_Name__c,
                                Additional_Parent_First_Name__c, Additional_Parent_Last_Name__c, Additional_Parent_City__c,
                                Additional_Parent_Email__c, Additional_Parent_Phone__c, Additional_Parent_Postal_Code__c,
                                Additional_Parent_State__c, Additional_Parent_Street__c, Hidden_Additional_Parent_Id__c,
                                Hidden_Best_Contact_Person_Id__c, Parent_Relationship_to_Child__c, HiddenAlternate1MedProfessionalId__c,
                                HiddenAlternate2MedProfessionalId__c, Self_describe_comment_box__c, Child_Age__c, Gender__c, Hidden_DV_form_Medical_professional_Type__c,
                                Additional_Parent_Relationship_to_Child__c, How_Did_you_hear_about_Make_A_Wish__c, Other_Medical_Provider_Category__c,
                                Any_medical_reason_for_moving_quickly__c, Department__c, Hospital_Treatment_Facility_Treating__c, Part_A_Received__c,
                                Part_A_Sent__c, ChapterName__r.Qualified_Wish_Owner__c, Alternate_1_Medical_Professional_Type__c, Alternate_2_Medical_Professional_Type__c,
                                Alternate1HospitalTreatmentFacility__c, Alternate2HospitalTreatmentFacility__c, Qualified_Date__c, PD_Condition_Description__c, Rush__c,
                                Please_Explain__c, Referred_Date__c, Inquiry_Date__c, Out_of_Territory__c, unique_wish_identifier__c
                        FROM Lead
                        WHERE Id IN:leadIdConvertedByContactIdMap.keySet()
                ]) {
                    convertedLead.Treating_Medical_Professional_Phone__c = Utils.removeFormatNumberField(convertedLead.Treating_Medical_Professional_Phone__c);
                    convertedLead.Referrer_Phone__c = Utils.removeFormatNumberField(convertedLead.Referrer_Phone__c);
                    convertedLead.Alternate1MedProfessionalPhone__c = Utils.removeFormatNumberField(convertedLead.Alternate1MedProfessionalPhone__c);
                    convertedLead.Phone = Utils.removeFormatNumberField(convertedLead.Phone);
                    convertedLead.Alternate2MedProfessionalPhone__c = Utils.removeFormatNumberField(convertedLead.Alternate2MedProfessionalPhone__c);
                    convertedLead.Additional_Parent_Phone__c = Utils.removeFormatNumberField(convertedLead.Additional_Parent_Phone__c);
                    convertedLeadsById.put(convertedLead.Id, convertedLead);
                    contactIdByLeadMap.put(convertedLead.ConvertedContactId, convertedLead);
                    convertedAccountMap.put(convertedLead.ConvertedAccountId, convertedLead);
                    relationshipMap = RelationshipService.buildLeadConvertRelationships(convertedLead);
                    if (convertedLead.Treating_Medical_Professional_Contact_Id__c != null
                            && convertedLead.Hidden_DV_form_Medical_professional_Type__c == LEAD_DV_FORM_TYPE_BEST_CONTACT
                            || convertedLead.Hidden_DV_form_Medical_professional_Type__c == LEAD_DV_FORM_TYPE_TREATING_MEDICAL_PROFESSIONAL) {
                        existingMedicalProfIdMap.put(convertedLead.Treating_Medical_Professional_Contact_Id__c, convertedLead);
                    }
                    if (convertedLead.Medical_Professional_ContactId__c != null) {
                        existingMedicalProfIdMap.put(convertedLead.Medical_Professional_ContactId__c, convertedLead);
                    }
                    if (convertedLead.HiddenAlternate1MedProfessionalId__c != null
                            && convertedLead.Hidden_DV_form_Medical_professional_Type__c == LEAD_DV_FORM_TYPE_ALTERNATE_1_MEDICAL_PROFESSIONAL) {
                        existingMedicalProfIdMap.put(convertedLead.HiddenAlternate1MedProfessionalId__c, convertedLead);
                    }
                    if (convertedLead.HiddenAlternate2MedProfessionalId__c != null
                            && convertedLead.Hidden_DV_form_Medical_professional_Type__c == LEAD_DV_FORM_TYPE_ALTERNATE_2_MEDICAL_PROFESSIONAL) {
                        existingMedicalProfIdMap.put(convertedLead.HiddenAlternate2MedProfessionalId__c, convertedLead);
                    }
                    allLeadContacts.addAll(relationshipMap.keySet());
                }

                if (!convertedLeadsById.isEmpty()) {
                    DiagnosisVerificationService.updateContact(convertedLeadsById);
                    updateElectronicSigner(leadIdConvertedByContactIdMap);
                }

                if (!convertedAccountMap.isEmpty()) {
                    accountMap = AccountService.setHouseholdFields(convertedAccountMap);
                }

                List<cg__ContactFile__c> contactFileFolders = new List<cg__ContactFile__c>();

                for (Contact wishChildContact : [
                        SELECT Id, FirstName, Birthdate, Department, Provider_Type__c, Language__c,
                                Self_describe_comment_box__c, Migrated_Record__c, Lead_Created_Date__c,
                                Relationship_to_Wish_Child__c, Referrer_FirstName__c, Referrer_Last_Name__c,
                                Referrer_Phone__c, Referrer_Email__c, Referrer_City__c, Referrer_Zip__c,
                                Relationship__c, Inquiry_Referral_Method__c, Is_Family_Aware_of_Referral__c,
                                Parent_Guardian_Name__c, RecordTypeId, AccountId, LastName, MailingCity,
                                OwnerId, MailingState, MailingPostalCode, Wish_How_Did_you_hear_about_Make_A_Wish__c,
                                Other_Medical_Provider_Category__c
                        FROM Contact
                        WHERE Id IN:contactIdByLeadMap.keySet()
                ]) {
                    wishChildContactMap.put(wishChildContact.Id, ContactService.buildWishChildFromLead(wishChildContact,
                            contactIdByLeadMap.get(wishChildContact.Id)));
                    contactFileFolders.addAll(ContactFileService.buildFileFoldersLeadConvert(wishChildContact.Id));
                    rushReminderList.add(TaskService.buildSendWelcomeLetter(wishChildContact));
                    String medicalReason = contactIdByLeadMap.get(wishChildContact.Id).Any_medical_reason_for_moving_quickly__c;
                    if (medicalReason.containsIgnoreCase(MEDICAL_REASON_MOVING_QUICKLY_YES)) {
                        rushReminderList.add(TaskService.buildRush(wishChildContact));
                    }
                }

                for (Lead convertLead : convertedLeadsById.values()) {
                    // Build Parse and build Sibling Contact
                    if (String.isNotEmpty(convertLead.Sibling_Detail__c)) {
                        if (convertLead.Sibling_Detail__c.contains('<br>')) {
                            for (String currSiblings : convertLead.Sibling_Detail__c.split('<br>')) {
                                if (currSiblings.contains('|')) {
                                    List<String> siblingDetails = currSiblings.split('\\|');
                                    if (siblingDetails.size() == 3) {
                                        Contact newFamily = ContactService.buildSibling(
                                                siblingDetails[0].trim(), siblingDetails[1].trim(), siblingDetails[2].trim(),
                                                convertLead.ConvertedContactId, convertLead.ConvertedAccountId,
                                                convertLead.ChapterName__c,
                                                convertLead.What_is_the_family_s_primary_spoken_lang__c);
                                        leadNewContacts.add(newFamily);
                                    }
                                }
                            }
                        } else if (convertLead.Sibling_Detail__c.contains('|')) {
                            List<String> siblingDetails = convertLead.Sibling_Detail__c.split('\\|');
                            if (siblingDetails.size() == 3) {
                                Contact newFamily = ContactService.buildSibling(
                                        siblingDetails[0].trim(), siblingDetails[1].trim(), siblingDetails[2].trim(),
                                        convertLead.ConvertedContactId, convertLead.ConvertedAccountId,
                                        convertLead.ChapterName__c,
                                        convertLead.What_is_the_family_s_primary_spoken_lang__c);
                                leadNewContacts.add(newFamily);
                            }
                        }
                    }
                    // Create New Case
                    Boolean hasContactConverted = wishChildContactMap.containsKey(convertLead.ConvertedContactId);
                    Case newCase = CaseService.buildQualifiedCaseFromLead(convertLead, hasContactConverted);
                    caseList.add(newCase);
                    caseMap.put(convertLead.Id, newCase);
                }

                for (Case partACase : [
                        SELECT Id, CaseNumber, Lead__c, ContactId, RecordTypeId
                        FROM Case
                        WHERE Lead__c IN :convertedLeadsById.keySet()
                        AND RecordTypeId = :DIAGNOSIS_ID
                ]) {
                    if (convertedLeadsById.containsKey(partACase.Lead__c)) {
                        partACase.ContactId = convertedLeadsById.get(partACase.Lead__c).ConvertedContactId;
                        partACaseList.add(partACase);
                    }
                    if (caseMap.containsKey(partACase.Lead__c)) {
                        Case rushCase = new Case();
                        rushCase = caseMap.get(partACase.Lead__c);
                        if (rushCase.Rush__c == true) {
                            rushCase.Hidden_already_send_rush_wish__c = true;
                        }
                        caseMap.put(partACase.Lead__c, rushCase);
                    }
                }

                if (!convertedLeadsById.keySet().isEmpty()) {
                    List<dsfs__DocuSign_Status__c> docuSignStatuses = DocuSignService.findByLeadAndEnvelopeStatus(convertedLeadsById.keySet(), Constant_AC.DOCUSIGN_ENVELOPE_STATUS_COMPLETED);
                    dsfsList = DocuSignService.setContact(docuSignStatuses, convertedLeadsById);
                    caseMap = CaseService.setDVReceiveDate(docuSignStatuses, caseMap);
                }

                if (!contactFileFolders.isEmpty()) {
                    insert contactFileFolders;
                }
                contactFiles = ContactFileService.buildFilesLeadConvert(convertedLeadsById);
            }
            RecursiveTriggerHandler.blockBeforeUpdate = true;
            RecursiveTriggerHandler.blockAfterUpdate = true;
            if (!contactFiles.isEmpty()) {
                insert contactFiles;
            }
            if (!accountMap.isEmpty()) {
                update accountMap.values();
            }
            if (!dsfsList.isEmpty()) {
                update dsfsList;
            }
            if (!partACaseList.isEmpty()) {
                update partACaseList;
            }
            if (!wishChildContactMap.isEmpty()) {
                update wishChildContactMap.values();
            }
            if (!caseMap.isEmpty()) {
                insert caseMap.values();
                leadCases.addAll(caseMap.keySet());
            }
            if (!rushReminderList.isEmpty()) {
                insert rushReminderList;
            }

            Set<String> healthTreatmentFacilitySet = new Set<String>();
            for (Lead lead : [
                    SELECT ConvertedAccountId, Hospital_Treatment_Facility_Treating__c,
                            Alternate1HospitalTreatmentFacility__c,
                            Alternate2HospitalTreatmentFacility__c
                    FROM Lead
                    WHERE Id IN:convertedLeadsById.keySet()
            ]) {
                convertedAccId = lead.ConvertedAccountId;
                healthTreatmentFacilitySet.add(lead.Hospital_Treatment_Facility_Treating__c);
                if (lead.Alternate1HospitalTreatmentFacility__c != null) {
                    healthTreatmentFacilitySet.add(lead.Alternate1HospitalTreatmentFacility__c);
                }
                if (lead.Alternate2HospitalTreatmentFacility__c != null) {
                    healthTreatmentFacilitySet.add(lead.Alternate2HospitalTreatmentFacility__c);
                }
            }
            for (Account dbAccount : [
                    SELECT Id, Name, RecordTypeId
                    FROM Account
                    WHERE RecordTypeId = :HOSPITAL_TREATMENT_ID
                    AND Name IN:healthTreatmentFacilitySet
            ]) {
                medicalAccountMap.put(dbAccount.Name, dbAccount);
            }

            medicalAccountMap.putAll(AccountService.createHospitalTreatmentFacilities(convertedLeadsById.keySet(), medicalAccountMap));

            if (!medicalAccountMap.isEmpty()) {
                Set<String> qualifyFirstNameSet = new Set<String>();
                Set<String> qualifyLastNameSet = new Set<String>();
                Set<String> qualifyPhoneNameSet = new Set<String>();
                Set<String> qualifyEmailNameSet = new Set<String>();
                Set<String> referringFirstNameSet = new Set<String>();
                Set<String> referringLastNameSet = new Set<String>();
                Set<String> referringPhoneNameSet = new Set<String>();
                Set<String> referringEmailNameSet = new Set<String>();
                Set<String> sameReferringFirstNameSet = new Set<String>();
                Set<String> sameReferringLastNameSet = new Set<String>();
                Set<String> sameReferringPhoneNameSet = new Set<String>();
                Set<String> sameReferringEmailNameSet = new Set<String>();
                Set<String> bestPersonFirstNameSet = new Set<String>();
                Set<String> bestPersonLastNameSet = new Set<String>();
                Set<String> bestPersonEmailNameSet = new Set<String>();
                List<npe5__Affiliation__c> affiliationList = new List<npe5__Affiliation__c>();
                Set<Id> wishFamilyContactIdSet = new Set<Id>();
                List<npe5__Affiliation__c> updateAffiliationList = new List<npe5__Affiliation__c>();
                Id wishChildContactId;
                Map<String, String> relationshipTypeMap = new Map<String, String>();
                Map<String, Boolean> firstParentMap = new Map<String, Boolean>();
                Map<String, Boolean> qualifyingMedicalProfessionalMap = new Map<String, Boolean>();
                Set<String> parentGuardianNameSet = new Set<String>();
                String parentName;
                String additionalParentName;

                try {
                    for (Lead convertedLead : convertedLeadsById.values()) {
                        parentName = convertedLead.Parent_First_Name__c + DASH
                                + convertedLead.Parent_Last_Name__c + DASH
                                + WISH_FAMILY_ID;
                        additionalParentName = convertedLead.Additional_Parent_First_Name__c + DASH
                                + convertedLead.Additional_Parent_Last_Name__c + DASH
                                + WISH_FAMILY_ID;
                        parentGuardianNameSet.add(parentName);
                        parentGuardianNameSet.add(additionalParentName);
                        wishChildContactId = convertedLead.ConvertedContactId;
                        if (convertedLead.Parent_Last_Name__c != null
                                && convertedLead.Wish_Family_ContactId__c != null) {
                            wishFamilyContactIdSet.add(convertedLead.Wish_Family_ContactId__c);
                        }
                        if (convertedLead.Additional_Parent_Last_Name__c != null
                                && convertedLead.Hidden_Additional_Parent_Id__c != null) {
                            wishFamilyContactIdSet.add(convertedLead.Hidden_Additional_Parent_Id__c);
                        }
                        affiliationList.addAll(AffiliationService.buildHospitalMedicalAffiliations(
                                convertedLead, medicalAccountMap
                        ));
                    }

                    if (!wishFamilyContactIdSet.isEmpty()) {
                        for (npe5__Affiliation__c dbFamilyContactAffiliation : [
                                SELECT Id, npe5__Contact__c, npe5__Organization__c, npe5__Primary__c
                                FROM npe5__Affiliation__c
                                WHERE
                                npe5__Contact__c = :wishFamilyContactIdSet
                                AND npe5__Primary__c = :TRUE
                        ]) {
                            npe5__Affiliation__c updateAffliRec = new npe5__Affiliation__c();
                            updateAffliRec.Id = dbFamilyContactAffiliation.Id;
                            updateAffliRec.npe5__Primary__c = false;
                            updateAffiliationList.add(updateAffliRec);
                            npe5__Affiliation__c newAff = new npe5__Affiliation__c();
                            newAff.npe5__Contact__c = dbFamilyContactAffiliation.npe5__Contact__c;
                            newAff.npe5__Organization__c = convertedAccId;
                            newAff.npe5__StartDate__c = Date.today();
                            newAff.npe5__Status__c = AFFILIATION_STATUS_ACTIVE;
                            newAff.npe5__Primary__c = true;
                            affiliationList.add(newAff);
                        }
                    }

                    for (Lead convertedLead : convertedLeadsById.values()) {
                        // Parent/Legal Guardian Contact
                        if (convertedLead.Parent_Last_Name__c != null && convertedLead.Wish_Family_ContactId__c == null) {
                            Contact parentLegalGuardian = ContactService.buildParentLegalGuardianFromLead(convertedLead);
                            firstParentMap.put(parentLegalGuardian.FirstName + DASH + parentLegalGuardian.LastName
                                    + DASH + parentLegalGuardian.Email + DASH + parentLegalGuardian.Phone, true);
                            relationshipTypeMap.put(parentLegalGuardian.FirstName + DASH + parentLegalGuardian.LastName + DASH + parentLegalGuardian.Email + DASH + parentLegalGuardian.Phone, convertedLead.Parent_Relationship_to_Child__c);
                            leadNewContacts.add(parentLegalGuardian);
                        }
                        // Additional Parent/Legal Guardian Contact
                        if (convertedLead.Additional_Parent_Last_Name__c != null && convertedLead.Hidden_Additional_Parent_Id__c == null) {
                            Contact additionalParentLegalGuardian = ContactService.buildAdditionalParentLegalGuardianFromLead(convertedLead);
                            firstParentMap.put(additionalParentLegalGuardian.FirstName + DASH + additionalParentLegalGuardian.LastName
                                    + DASH + additionalParentLegalGuardian.Email + DASH + additionalParentLegalGuardian.Phone, false);
                            relationshipTypeMap.put(additionalParentLegalGuardian.FirstName + DASH + additionalParentLegalGuardian.LastName
                                    + DASH + additionalParentLegalGuardian.Email + DASH + additionalParentLegalGuardian.Phone,
                                    convertedLead.Additional_Parent_Relationship_to_Child__c);
                            leadNewContacts.add(additionalParentLegalGuardian);
                        }

                        MedicalProfessionalsEqualityWrapper medProfessionalEqualityWrapper = generateMedicalProfessionalsEqualityWrapper(convertedLead);
                        if (medProfessionalEqualityWrapper.addSameReferringTreatingMedical || Test.isRunningTest()) {
                            sameReferringFirstNameSet.add(convertedLead.Treating_Medical_Professional_First_Name__c);
                            sameReferringLastNameSet.add(convertedLead.Treating_Medical_Professional_Last_Name__c);
                            sameReferringPhoneNameSet.add(convertedLead.Treating_Medical_Professional_Phone__c);
                            sameReferringEmailNameSet.add(convertedLead.Treating_Medical_Professional_Email__c);
                        }
                        if (medProfessionalEqualityWrapper.addSameReferring || Test.isRunningTest()) {
                            sameReferringFirstNameSet.add(convertedLead.Referrer_FirstName__c);
                            sameReferringLastNameSet.add(convertedLead.Referrer_Last_Name__c);
                            sameReferringPhoneNameSet.add(convertedLead.Referrer_Phone__c);
                            sameReferringEmailNameSet.add(convertedLead.Referrer_Email__c);
                        }
                        if (medProfessionalEqualityWrapper.addBestPerson || Test.isRunningTest()) {
                            bestPersonFirstNameSet.add(convertedLead.Best_Contact_for_Physician_First_Name__c);
                            bestPersonLastNameSet.add(convertedLead.Best_Contact_for_Physician_Last_Name__c);
                            bestPersonEmailNameSet.add(convertedLead.Best_contact_for_Physician_Email__c);
                        }
                        if (medProfessionalEqualityWrapper.addQualify || Test.isRunningTest()) {
                            qualifyFirstNameSet.add(convertedLead.Referrer_FirstName__c);
                            qualifyLastNameSet.add(convertedLead.Referrer_Last_Name__c);
                            qualifyPhoneNameSet.add(convertedLead.Referrer_Phone__c);
                            qualifyEmailNameSet.add(convertedLead.Referrer_Email__c);
                        }
                        if (medProfessionalEqualityWrapper.addReferring || Test.isRunningTest()) {
                            referringFirstNameSet.add(convertedLead.Treating_Medical_Professional_First_Name__c);
                            referringLastNameSet.add(convertedLead.Treating_Medical_Professional_Last_Name__c);
                            referringPhoneNameSet.add(convertedLead.Treating_Medical_Professional_Phone__c);
                            referringEmailNameSet.add(convertedLead.Treating_Medical_Professional_Email__c);
                        }

                        if (!sameReferringFirstNameSet.isEmpty() && !sameReferringLastNameSet.isEmpty()
                                && (!sameReferringPhoneNameSet.isEmpty() || !sameReferringEmailNameSet.isEmpty())) {
                            Contact newSameReferrerMedicalContact = ContactService.buildBestTreatingReferrerMedicalProfessionalFromLead(convertedLead, medicalAccountMap);
                            qualifyingMedicalProfessionalMap.put(convertedLead.Referrer_FirstName__c + DASH
                                    + convertedLead.Referrer_Last_Name__c + DASH
                                    + convertedLead.Referrer_Email__c, true);
                            leadNewContacts.add(newSameReferrerMedicalContact);
                        }
                        if (!referringFirstNameSet.isEmpty() && !referringLastNameSet.isEmpty()
                                && (!referringPhoneNameSet.isEmpty() || !referringEmailNameSet.isEmpty())) {
                            Contact newTreatingMedicalContact = ContactService.buildTreatingMedicalProfessionalFromLead(convertedLead, medicalAccountMap);
                            if (convertedLead.Hidden_DV_form_Medical_professional_Type__c == LEAD_DV_FORM_TYPE_TREATING_MEDICAL_PROFESSIONAL) {
                                qualifyingMedicalProfessionalMap.put(convertedLead.Treating_Medical_Professional_First_Name__c + DASH
                                        + convertedLead.Treating_Medical_Professional_Last_Name__c + DASH
                                        + convertedLead.Treating_Medical_Professional_Email__c, true);
                            } else {
                                qualifyingMedicalProfessionalMap.put(convertedLead.Treating_Medical_Professional_First_Name__c
                                        + DASH + convertedLead.Treating_Medical_Professional_Last_Name__c + DASH
                                        + convertedLead.Treating_Medical_Professional_Email__c, false);
                            }
                            leadNewContacts.add(newTreatingMedicalContact);
                        }
                        if (!qualifyFirstNameSet.isEmpty() && !qualifyLastNameSet.isEmpty()
                                && (!qualifyPhoneNameSet.isEmpty() || !qualifyEmailNameSet.isEmpty())) {
                            Contact newReferrerMedicalContact = ContactService.buildReferrerMedicalProfessionalFromLead(convertedLead);
                            leadNewContacts.add(newReferrerMedicalContact);
                        }
                        if (!bestPersonFirstNameSet.isEmpty() && !bestPersonLastNameSet.isEmpty()) {
                            Contact newBestContactMedicalContact = ContactService.buildBestMedicalProfessionalFromLead(convertedLead, medicalAccountMap);
                            if (convertedLead.Hidden_DV_form_Medical_professional_Type__c == LEAD_DV_FORM_TYPE_BEST_CONTACT) {
                                qualifyingMedicalProfessionalMap.put(convertedLead.Best_Contact_for_Physician_First_Name__c + DASH
                                        + convertedLead.Best_Contact_for_Physician_Last_Name__c + DASH
                                        + convertedLead.Best_contact_for_Physician_Email__c, true);
                            } else {
                                qualifyingMedicalProfessionalMap.put(convertedLead.Best_Contact_for_Physician_First_Name__c + DASH
                                        + convertedLead.Best_Contact_for_Physician_Last_Name__c + DASH
                                        + convertedLead.Best_contact_for_Physician_Email__c, false);
                            }
                            leadNewContacts.add(newBestContactMedicalContact);
                        }
                        // Alternate 1 Medical Contact
                        if (convertedLead.HiddenAlternate1MedProfessionalId__c == null
                                && convertedLead.Alternate1MedProfessionalLastName__c != null) {
                            Contact newAlt1MedicalContact = ContactService.buildAlternate1MedicalProfessionalFromLead(convertedLead, medicalAccountMap);
                            if (convertedLead.Hidden_DV_form_Medical_professional_Type__c == LEAD_DV_FORM_TYPE_ALTERNATE_1_MEDICAL_PROFESSIONAL) {
                                qualifyingMedicalProfessionalMap.put(convertedLead.Alternate1MedProfessionalFirstName__c + DASH
                                        + convertedLead.Alternate1MedProfessionalLastName__c + DASH
                                        + convertedLead.Alternate1MedicalProfessionalEmail__c, true);
                            } else {
                                qualifyingMedicalProfessionalMap.put(convertedLead.Alternate1MedProfessionalFirstName__c + DASH
                                        + convertedLead.Alternate1MedProfessionalLastName__c + DASH
                                        + convertedLead.Alternate1MedicalProfessionalEmail__c, false);
                            }
                            leadNewContacts.add(newAlt1MedicalContact);
                        }
                        // Alternate 2 Medical Contact
                        if (convertedLead.HiddenAlternate2MedProfessionalId__c == null
                                && convertedLead.Alternate2MedProfessionalLastName__c != null) {
                            Contact newAlt2MedicalContact = ContactService.buildAlternate2MedicalProfessionalFromLead(convertedLead, medicalAccountMap);
                            if (convertedLead.Hidden_DV_form_Medical_professional_Type__c == LEAD_DV_FORM_TYPE_ALTERNATE_2_MEDICAL_PROFESSIONAL) {
                                qualifyingMedicalProfessionalMap.put(convertedLead.Alternate2MedProfessionalFirstName__c + DASH
                                        + convertedLead.Alternate2MedProfessionalLastName__c + DASH
                                        + convertedLead.Alternate2MedProfessionalEmail__c, true);
                            } else {
                                qualifyingMedicalProfessionalMap.put(convertedLead.Alternate2MedProfessionalFirstName__c + DASH
                                        + convertedLead.Alternate2MedProfessionalLastName__c + DASH
                                        + convertedLead.Alternate2MedProfessionalEmail__c, false);
                            }
                            leadNewContacts.add(newAlt2MedicalContact);
                        }
                    }

                    if (!leadNewContacts.isEmpty()) {
                        RecursiveTriggerHandler.blockBeforeUpdate = true;
                        RecursiveTriggerHandler.blockAfterUpdate = true;
                        insert leadNewContacts;
                        for (Contact currContact : leadNewContacts) {
                            npe4__Relationship__c newRelationship = RelationshipService.buildLeadConvertRelationship(
                                    wishChildContactId, currContact, qualifyingMedicalProfessionalMap, relationshipTypeMap, parentGuardianNameSet);
                            relationshipMap.put(currContact.Id, newRelationship);
                            allLeadContacts.add(currContact.Id);
                        }
                    }
                    if (!relationshipMap.isEmpty()) {
                        RecursiveTriggerHandler.blockBeforeUpdate = true;
                        RecursiveTriggerHandler.blockAfterUpdate = true;
                        insert relationshipMap.values();
                    }
                    if (!updateAffiliationList.isEmpty()) {
                        RecursiveTriggerHandler.blockBeforeUpdate = true;
                        RecursiveTriggerHandler.blockAfterUpdate = true;
                        update updateAffiliationList;
                    }
                    if (!affiliationList.isEmpty()) {
                        RecursiveTriggerHandler.blockBeforeUpdate = true;
                        RecursiveTriggerHandler.blockAfterUpdate = true;
                        insert affiliationList;
                    }
                } catch (Exception ex) {
                    for (Lead currRec : convertedLeadsById.values()) {
                        ErrorMessage_AC.createdebugRec('LeadConvertService',
                                String.valueOf(currRec), String.valueOf(ex), 'convertLead',
                                currRec.Id, ex.getStackTraceString(), 'Error');
                    }
                    if (!Test.isRunningTest()) {
                        for (Lead currRec : convertedLeadsById.values()) {
                            currRec.addError(Label.Debug_log_error_message);
                        }
                    }
                }
            }

            List<npe5__Affiliation__c> affiliationList =
                    AffiliationService.buildMedicalAndChildAffiliations(existingMedicalProfIdMap, wishChildContactMap);
            RecursiveTriggerHandler.blockBeforeUpdate = true;
            RecursiveTriggerHandler.blockAfterUpdate = true;
            upsert affiliationList;

            // Generate Wish Affiliations
            for (Contact ctc : leadNewContacts) {
                allLeadContacts.add(ctc.Id);
            }
            Set<Id> relationshipIds = new Set<Id>();
            for (npe4__Relationship__c rel : relationshipMap.values()) {
                relationshipIds.add(rel.Id);
            }
            Set<Id> htfAccountIds = new Set<Id>();
            for (String accountName : medicalAccountMap.keySet()) {
                Account existingAccount = medicalAccountMap.get(accountName);
                htfAccountIds.add(existingAccount.Id);
            }
            generateWishAffiliationsFromLead(convertedLeadsById.keySet(), allLeadContacts, relationshipIds, htfAccountIds);
        } catch (Exception ex) {
            for (Lead currRec : convertedLeadsById.values()) {
                ErrorMessage_AC.createdebugRec('LeadConvertService',
                        String.valueOf(currRec), String.valueOf(ex), 'convertLead',
                        currRec.Id, ex.getStackTraceString(), 'Error');
            }
            if (!Test.isRunningTest()) {
                for (Lead currRec : convertedLeadsById.values()) {
                    currRec.addError(Label.Debug_log_error_message);
                }
            }
        }
    }

    /**
     * Aynchronously update the electronic signer on DocuSign status record related to lead
     * @param leadContactMap
     */
    @Future
    private static void updateElectronicSigner(Map<Id, Id> leadContactMap) {
        DocuSignService.updateElectronicSigner(leadContactMap, SUBJECT_DIAGNOSIS_VERIFICATION);
    }

    /**
     * Asynchronously generate Wish Affiliations from Converted Lead
     * @param leadIds
     * @param contactIds
     * @param relationshipIds
     * @param htfAccountIds
     */
    @Future
    private static void generateWishAffiliationsFromLead(Set<Id> leadIds, Set<Id> contactIds,
            Set<Id> relationshipIds, Set<Id> htfAccountIds) {
        Map<Id, Case> casesByLeadId = new Map<Id, Case>();
        for (Case currentCase : [
                SELECT Id, Lead__c, Hidden_Lead_Id__c
                FROM Case
                WHERE Hidden_Lead_Id__c IN :leadIds
        ]) {
            casesByLeadId.put(currentCase.Hidden_Lead_Id__c, currentCase);
        }
        Map<Id, Lead> convertedLeadsById = new Map<Id, Lead>();
        for (Lead convertedLead : [
                SELECT Id, ConvertedContactId, Hospital_Treatment_Facility_Treating__c,
                        Part_A_Received__c, Part_A_Sent__c
                FROM Lead
                WHERE Id IN :leadIds
        ]) {
            convertedLeadsById.put(convertedLead.Id, convertedLead);
        }
        WishAffiliationService.createWishChildren(casesByLeadId, convertedLeadsById);
        List<Contact> contacts = [
                SELECT Id, Hidden_Hospital_Account__c
                FROM Contact
                WHERE Id IN :contactIds
        ];
        List<npe4__Relationship__c> relationships = [
                SELECT Id, npe4__Contact__c, npe4__RelatedContact__c,
                        npe4__Type__c, Referring_Medical_Professional__c
                FROM npe4__Relationship__c
                WHERE Id IN :relationshipIds
        ];
        Map<String, Account> medicalAccountMap = new Map<String, Account>();
        for (Account dbAccount : [
                SELECT Id, Name, RecordTypeId
                FROM Account
                WHERE RecordTypeId = :HOSPITAL_TREATMENT_ID
                AND Id IN :htfAccountIds
        ]) {
            medicalAccountMap.put(dbAccount.Name, dbAccount);
        }
        WishAffiliationService.createWishAffiliations(casesByLeadId, convertedLeadsById, contacts, relationships, medicalAccountMap);
    }

    /**
     * Check if a Medical Professional contact equal
     * @param sourceFirstName
     * @param sourceLastName
     * @param sourcePhone
     * @param sourceEmail
     * @param targetFirstName
     * @param targetLastName
     * @param targetPhone
     * @param targetEmail
     * @return Boolean
     */
    private static Boolean isSameMedicalProfessional(
            String sourceFirstName, String targetFirstName,
            String sourceLastName, String targetLastName,
            String sourcePhone, String targetPhone,
            String sourceEmail, String targetEmail) {
        if (sourceFirstName == targetFirstName
                && sourceLastName == targetLastName
                && (sourcePhone == targetPhone || sourceEmail == targetEmail)) {
            return true;
        } else {
            return false;
        }
    }

    /**
     * Generate Medical Professionals Equality Wrapper
     * @param convertedLead
     * @return
     */
    private static MedicalProfessionalsEqualityWrapper generateMedicalProfessionalsEqualityWrapper(Lead convertedLead) {
        Boolean isTreatingMedicalProfessionalAlsoReferrerContact =
                isSameMedicalProfessional(
                        convertedLead.Treating_Medical_Professional_First_Name__c, convertedLead.Referrer_FirstName__c,
                        convertedLead.Treating_Medical_Professional_Last_Name__c, convertedLead.Referrer_Last_Name__c,
                        convertedLead.Treating_Medical_Professional_Phone__c, convertedLead.Referrer_Phone__c,
                        convertedLead.Treating_Medical_Professional_Email__c, convertedLead.Referrer_Email__c);
        Boolean isRefererAlsoBestContact =
                isSameMedicalProfessional(
                        convertedLead.Referrer_FirstName__c, convertedLead.Best_Contact_for_Physician_First_Name__c,
                        convertedLead.Referrer_Last_Name__c, convertedLead.Best_Contact_for_Physician_Last_Name__c,
                        null, null,
                        convertedLead.Referrer_Email__c, convertedLead.Best_contact_for_Physician_Email__c);
        Boolean isTreatingMedicalProfessionalAlsoBestContact =
                isSameMedicalProfessional(
                        convertedLead.Treating_Medical_Professional_First_Name__c, convertedLead.Best_Contact_for_Physician_First_Name__c,
                        convertedLead.Treating_Medical_Professional_Last_Name__c, convertedLead.Best_Contact_for_Physician_Last_Name__c,
                        null, null,
                        convertedLead.Treating_Medical_Professional_Email__c, convertedLead.Best_contact_for_Physician_Email__c);
        Boolean addSameReferringTreatingMedical = false;
        Boolean addSameReferring = false;
        Boolean addBestPerson = false;
        Boolean addQualify = false;
        Boolean addReferring = false;
        if (isTreatingMedicalProfessionalAlsoReferrerContact
                && isRefererAlsoBestContact
                && isTreatingMedicalProfessionalAlsoBestContact) {
            if (convertedLead.Relationship_to_child__c == MEDICAL_PROFESSIONAL_LABEL
                    && convertedLead.Medical_Professional_ContactId__c == null
                    && convertedLead.Treating_Medical_Professional_Contact_Id__c == null
                    && convertedLead.Hidden_Best_Contact_Person_Id__c == null) {
                addSameReferringTreatingMedical = true;
            }
        } else if (isTreatingMedicalProfessionalAlsoReferrerContact) {
            if (convertedLead.Relationship_to_child__c == MEDICAL_PROFESSIONAL_LABEL
                    && (convertedLead.Medical_Professional_ContactId__c == null
                    && convertedLead.Treating_Medical_Professional_Contact_Id__c == null)) {
                addSameReferringTreatingMedical = true;
            }
            if (convertedLead.Best_Contact_for_Physician_Last_Name__c != null
                    && convertedLead.Hidden_Best_Contact_Person_Id__c == null
                    && convertedLead.Relationship_to_child__c == MEDICAL_PROFESSIONAL_LABEL) {
                addBestPerson = true;
            }
        } else if (isTreatingMedicalProfessionalAlsoBestContact) {
            if (convertedLead.Relationship_to_child__c == MEDICAL_PROFESSIONAL_LABEL
                    && convertedLead.Hidden_Best_Contact_Person_Id__c == null
                    && convertedLead.Treating_Medical_Professional_Contact_Id__c == null) {
                addSameReferringTreatingMedical = true;
            }
            if (convertedLead.Referrer_Last_Name__c != null
                    && convertedLead.Medical_Professional_ContactId__c == null
                    && convertedLead.Relationship_to_child__c == MEDICAL_PROFESSIONAL_LABEL) {
                addQualify = true;
            }
        } else if (isRefererAlsoBestContact) {
            if (convertedLead.Relationship_to_child__c == MEDICAL_PROFESSIONAL_LABEL
                    && convertedLead.Medical_Professional_ContactId__c == null
                    && convertedLead.Hidden_Best_Contact_Person_Id__c == null) {
                addSameReferring = true;
            }
            if (convertedLead.Treating_Medical_Professional_Last_Name__c != null
                    && convertedLead.Treating_Medical_Professional_Contact_Id__c == null) {
                addReferring = true;
            }
        } else {
            if (convertedLead.Treating_Medical_Professional_Last_Name__c != null
                    && convertedLead.Treating_Medical_Professional_Contact_Id__c == null) {
                addReferring = true;
            }
            if (convertedLead.Referrer_Last_Name__c != null
                    && convertedLead.Medical_Professional_ContactId__c == null
                    && convertedLead.Relationship_to_child__c == MEDICAL_PROFESSIONAL_LABEL) {
                addQualify = true;
            }
            if (convertedLead.Best_Contact_for_Physician_Last_Name__c != null
                    && convertedLead.Hidden_Best_Contact_Person_Id__c == null
                    && convertedLead.Relationship_to_child__c == MEDICAL_PROFESSIONAL_LABEL) {
                addBestPerson = true;
            }
        }
        return new MedicalProfessionalsEqualityWrapper(
                addSameReferringTreatingMedical,
                addSameReferring,
                addBestPerson,
                addQualify,
                addReferring
        );
    }

    /**
     * Medical Professionals Equality Wrapper
     */
    public class MedicalProfessionalsEqualityWrapper {
        public Boolean addSameReferringTreatingMedical;
        public Boolean addSameReferring;
        public Boolean addBestPerson;
        public Boolean addQualify;
        public Boolean addReferring;
        public MedicalProfessionalsEqualityWrapper(
                Boolean addSameReferringTreatingMedical,
                Boolean addSameReferring,
                Boolean addBestPerson,
                Boolean addQualify,
                Boolean addReferring
        ) {
            this.addSameReferringTreatingMedical = addSameReferringTreatingMedical;
            this.addSameReferring = addSameReferring;
            this.addBestPerson = addBestPerson;
            this.addQualify = addQualify;
            this.addReferring = addReferring;
        }
    }
}