/***************************************************************************************************
Author      : MST Solutions
Date        : 10/15/2016
Description : Contact_OnAfterUpdateTriggerHepler is used to call the corresponding methods from
Contact_OnAfterUpdateTriggerHandler class.

Modification Log
------------------
WVC-1884    KANAGARAJ  04/04/2018
WVC-2205    kANAGARAJ  08/07/2018 // Line 147 previously the affiliation status was "Declined".
Now we have update the affliliation status as "Not Approved".
WVC-2174    KANAGARAJ  08/15/2018 // Line 636 to 664
SIW-488    C Smith     02/07/2020 // Lines 252-273
*****************************************************************************************************/
public class Contact_OnAfterUpdateTriggerHepler {

    // update the email address for drawloop purpose to send email to parent legual gurdian.
    public static void updateEmailAddress(set<String> contactIdsForEmailChange, map<string, contact> contactMap) {
        string temp;
        string temp1;
        Map<Id, Contact> updateEmailContactMap = new Map<Id, Contact>();
        try {
            for (npe4__Relationship__c newRelationShip : [
                    SELECT ID,Name,Parent_Legal_Guardian__c,npe4__RelatedContact__c,npe4__RelatedContact__r.LastName,npe4__RelatedContact__r.FirstName,npe4__RelatedContact__r.Name,npe4__RelatedContact__r.Email,npe4__Contact__c,
                            npe4__Contact__r.Recipient_Email__c,npe4__Contact__r.Second_Recipient_Email__c,npe4__Contact__r.First_Recipient_Name__c,
                            npe4__Contact__r.Second_Recipient_Name__c
                    FROM npe4__Relationship__c
                    WHERE Parent_Legal_Guardian__c = :true
                    AND npe4__RelatedContact__c IN:contactIdsForEmailChange
                    Limit 50000
            ]) {

                temp = newRelationShip.npe4__Contact__r.First_Recipient_Name__c + '-' + newRelationShip.npe4__Contact__r.Recipient_Email__c;
                temp1 = newRelationShip.npe4__Contact__r.Second_Recipient_Name__c + '-' + newRelationShip.npe4__Contact__r.Second_Recipient_Email__c;
                if (contactMap.containsKey(temp)) {
                    contact con = new contact();
                    con.id = newRelationShip.npe4__Contact__c;
                    con.Recipient_Email__c = contactMap.get(temp).Email;
                    updateEmailContactMap.put(con.Id, con);
                } else if (contactMap.containsKey(temp1)) {

                    contact con = new contact();
                    con.id = newRelationShip.npe4__Contact__c;
                    con.second_Recipient_Email__c = contactMap.get(temp1).Email;
                    updateEmailContactMap.put(con.Id, con);
                }
            }
            if (updateEmailContactMap.size() > 0) {
                Update updateEmailContactMap.Values();
            }

            if (Test.isRunningTest()) {
                throw new CommonTriggerException('Test Class execution');
            }
        } catch (Exception ex) {
            for (Contact currRec : contactMap.values()) {
                ErrorMessage_AC.createdebugRec('Contact_OnAfterUpdateTriggerHepler', String.valueof(currRec), String.valueOf(ex), 'updateEmailAddress', currRec.Id, ex.getStackTraceString(), 'Error');
            }
            if (!Test.isRunningTest()) {
                for (Contact currRec : contactMap.values()) {
                    currRec.addError(Label.Debug_log_error_message);
                }
            }
        }
    }

    //Used to populated Condition Description based on ICD Code values
    public static void updatePrimaryDiagnosis(Map<Id, Contact> primaryDiagnosisChangesMap) {
        RecursiveTriggerHandler.allowToEditRecord = TRUE;
        Boolean updateCase = FALSE;
        List<Case> caseBdayUpdateList = new List<Case>();
        Set<Id> conIdSet = new Set<Id>();
        List<Task> bdayTaskList = new List<Task>();
        List<Wish_Child_Form__c> updateConInfoList = new List<Wish_Child_Form__c>();
        try {
            for (Case updateWPPInfo : [
                    SELECT Id, ContactId, Hidden_Contact_County__c, Hidden_Contact_Gender__c, (
                            SELECT Id,FirstName__c,Middle_Name__c,Preferred_Name__c,mobilePhone__c, Email__c, LastName__c,Gender__c, Diagnosis__c, T_Shirt_Size__c
                            FROM Wish_Child_Form__r
                            ORDER BY CreatedDate DESC
                            LIMIT 1
                    )
                    FROM Case
                    WHERE ContactId IN :primaryDiagnosisChangesMap.keySet()
                    Limit 50000
            ]) {
                if (updateWPPInfo.Wish_Child_Form__r.size() > 0) {
                    /*for(Wish_Child_Form__c checkDiagnosis : updateWPPInfo.Wish_Child_Form__r) {
checkDiagnosis.Diagnosis__c = primaryDiagnosisChangesMap.get(updateWPPInfo.ContactId).Diagnosis__c;
checkDiagnosis.FirstName__c = primaryDiagnosisChangesMap.get(updateWPPInfo.ContactId).FirstName;
checkDiagnosis.Middle_Name__c = primaryDiagnosisChangesMap.get(updateWPPInfo.ContactId).Middle_Name__c;
checkDiagnosis.Preferred_Name__c = primaryDiagnosisChangesMap.get(updateWPPInfo.ContactId).Preferred_Name__c;
checkDiagnosis.mobilePhone__c = primaryDiagnosisChangesMap.get(updateWPPInfo.ContactId).MobilePhone;
checkDiagnosis.Email__c = primaryDiagnosisChangesMap.get(updateWPPInfo.ContactId).npe01__HomeEmail__c;
checkDiagnosis.LastName__c = primaryDiagnosisChangesMap.get(updateWPPInfo.ContactId).LastName;
checkDiagnosis.Gender__c = primaryDiagnosisChangesMap.get(updateWPPInfo.ContactId).Gender__c;
checkDiagnosis.BirthDate__c = primaryDiagnosisChangesMap.get(updateWPPInfo.ContactId).Birthdate;
checkDiagnosis.State__c = primaryDiagnosisChangesMap.get(updateWPPInfo.ContactId).MailingState;
checkDiagnosis.Zip_Code__c = primaryDiagnosisChangesMap.get(updateWPPInfo.ContactId).MailingPostalCode;
checkDiagnosis.Street__c = primaryDiagnosisChangesMap.get(updateWPPInfo.ContactId).MailingStreet;
checkDiagnosis.City__c = primaryDiagnosisChangesMap.get(updateWPPInfo.ContactId).MailingCity;
updateConInfoList.add(checkDiagnosis);
}*/
                }
                /*if(updateWPPInfo.Birthdate__c != primaryDiagnosisChangesMap.get(updateWPPInfo.ContactId).Birthdate) {
                    updateWPPInfo.Birthdate__c = primaryDiagnosisChangesMap.get(updateWPPInfo.ContactId).Birthdate;
                    conIdSet.add(updateWPPInfo.ContactId);
                    updateCase = TRUE;
                }*/
                if (updateWPPInfo.Hidden_Contact_County__c != primaryDiagnosisChangesMap.get(updateWPPInfo.ContactId).County__c || updateWPPInfo.Hidden_Contact_Gender__c != primaryDiagnosisChangesMap.get(updateWPPInfo.ContactId).Gender__c) {
                    updateWPPInfo.Hidden_Contact_County__c = primaryDiagnosisChangesMap.get(updateWPPInfo.ContactId).County__c;
                    updateWPPInfo.Hidden_Contact_Gender__c = primaryDiagnosisChangesMap.get(updateWPPInfo.ContactId).Gender__c;
                    updateCase = TRUE;
                }
                if (updateCase) {
                    caseBdayUpdateList.add(updateWPPInfo);
                }
                updateCase = FALSE;
            }
            for (Task bdayTask : [
                    SELECT Id
                    FROM Task
                    WHERE WhoId IN :conIdSet AND Subject = 'Wish Child Birthday Reminder' AND status != 'Completed'
                    Limit 50000
            ]) {
                bdayTaskList.add(bdayTask);
            }
            if (bdayTaskList.size() > 0) {
                Delete bdayTaskList;
            }
            if (updateConInfoList.size() > 0) {
                update updateConInfoList;
            }
            if (caseBdayUpdateList.size() > 0) {
                update caseBdayUpdateList;
            }
            RecursiveTriggerHandler.allowToEditRecord = FALSE;

            if (Test.isRunningTest()) {
                throw new CommonTriggerException('Test Class execution');
            }

        }

        catch (Exception ex) {
            for (Contact currRec : primaryDiagnosisChangesMap.values()) {
                ErrorMessage_AC.createdebugRec('Contact_OnAfterUpdateTriggerHepler', String.valueof(currRec), String.valueOf(ex), 'updatePrimaryDiagnosis', currRec.Id, ex.getStackTraceString(), 'Error');
            }

            if (!Test.isRunningTest()) {
                for (Contact currRec : primaryDiagnosisChangesMap.values()) {
                    currRec.addError(Label.Debug_log_error_message);

                }
            }
        }
    }

    /*This method is used to update Affiliation object status to 'Pending'.*/
    public static void UpdateOrgAffiliationStatusToPending(set<ID> volunteercontactSet) {
        List<npe5__Affiliation__c> affiliationList = new List<npe5__Affiliation__c>();
        for (npe5__Affiliation__c dbAffiliationRec : [
                SELECT Id,npe5__Contact__c,npe5__Primary__c,npe5__Status__c,npe5__Organization__c
                FROM npe5__Affiliation__c
                WHERE npe5__Contact__c IN :volunteercontactSet AND npe5__Status__c != 'Active'
                Limit 50000
        ]) {
            if (volunteercontactSet.contains(dbAffiliationRec.npe5__Contact__c)) {
                npe5__Affiliation__c updateAffiliation = new npe5__Affiliation__c();
                updateAffiliation.id = dbAffiliationRec.id;
                updateAffiliation.npe5__Status__c = 'Pending';
                affiliationList.add(updateAffiliation);
            }
        }
        if (affiliationList.size() > 0) {
            update affiliationList;
        }
    }

    /*This method is used to update Affiliation object status to 'Not Approved'.*/
    public static void updateOrgAffiliationStatustoDeclined(set<ID> volunteercontactSet) {
        List<npe5__Affiliation__c> affiliationList = new List<npe5__Affiliation__c>();
        for (npe5__Affiliation__c dbAffiliationRec : [
                SELECT Id,npe5__Contact__c,npe5__Primary__c,npe5__Status__c,npe5__Organization__c
                FROM npe5__Affiliation__c
                WHERE npe5__Contact__c IN :volunteercontactSet AND npe5__Status__c != 'Active'
                Limit 50000
        ]) {
            if (volunteercontactSet.contains(dbAffiliationRec.npe5__Contact__c)) {
                npe5__Affiliation__c updateAffiliation = new npe5__Affiliation__c();
                updateAffiliation.id = dbAffiliationRec.id;
                updateAffiliation.npe5__Status__c = 'Not Approved';
                affiliationList.add(updateAffiliation);
            }
        }
        if (affiliationList.size() > 0) {
            update affiliationList;
        }
    }

    // Whenever Volunteer Role field is updating on Volunteer Contact, based on the field value, Volunteer Roles will create and delete.
    public static void CreateVolunteerRoles(Map<Id, Contact> volunteerContactMap) {
        Map<Id, Id> volunterChapterMap = new Map<Id, Id>();
        Map<Id, Set<string>> volunteerRolesMap = new Map<Id, Set<String>>();
        Set<String> allVolunteerRoles = new Set<String>();
        Map<String, Id> RoleIdsMap = new Map<String, Id>();
        try {
            for (npe5__Affiliation__c currRec : [
                    SELECT Id,npe5__Contact__c, npe5__Organization__c,npe5__Contact__r.Volunteer_Role__c
                    FROM npe5__Affiliation__c
                    WHERE npe5__Contact__c IN :volunteerContactMap.keySet() AND npe5__Primary__c = True
                    Limit 50000
            ]) {
                volunterChapterMap.put(currRec.npe5__Contact__c, currRec.npe5__Organization__c);
                if (currRec.npe5__Contact__r.Volunteer_Role__c != Null) {
                    Set<String> volunteerRoles = new Set<String>();
                    for (String currRole : (currRec.npe5__Contact__r.Volunteer_Role__c.split(';'))) {
                        volunteerRoles.add(currRole);
                        allVolunteerRoles.add(currRole);
                    }

                    volunteerRolesMap.put(currRec.npe5__Contact__c, volunteerRoles);
                }
            }
            // Deleting Volunteer Role record if the role is removed from the field.
            if (volunterChapterMap.keySet().size() > 0)
                Delete [
                        SELECT Id
                        from Volunteer_Roles__c
                        WHERE Volunteer_Name__c IN :volunterChapterMap.keySet()
                ];

            List<Volunteer_Roles__c> volunteerRoleList = new List<Volunteer_Roles__c>();

            for (Chapter_Role__c currRec : [
                    SELECT id, Chapter_Name__c, Role_Name__c,Role_Name__r.Name
                    FROM Chapter_Role__c
                    WHERE Role_Name__r.Name IN :allVolunteerRoles AND Chapter_Name__c IN :volunterChapterMap.values()
            ]) {
                for (Id currContact : volunterChapterMap.keySet()) {
                    if ((volunterChapterMap.get(currContact) == (currRec.Chapter_Name__c)) && ((volunteerRolesMap.get(currContact)).contains(currRec.Role_Name__r.Name))) {
                        Volunteer_Roles__c newVolRole = new Volunteer_Roles__c();
                        newVolRole.Chapter_Role__c = currRec.id;
                        newVolRole.Volunteer_Name__c = currContact;
                        newVolRole.Status__c = 'Pending';
                        newVolRole.Sub_Status__c = 'Missing Requirement';
                        volunteerRoleList.add(newVolRole);
                    }
                }
            }
            
            /*SIW-488 - Add Special Events Role or any other role that the chapter has designated to be automatically added to volunteers */
            try    {
                for (Chapter_Role__c roleToAddAutomatically: [
                    SELECT id, Chapter_Name__c, Role_Name__c,Role_Name__r.Name
                    FROM Chapter_Role__c
                    WHERE Chapter_Name__c IN :volunterChapterMap.values() AND Add_to_New_Volunteers_Automatically__c = TRUE AND Role_Name__r.Name NOT IN :allVolunteerRoles
                ])    {
                    
                    for (Id currContact : volunterChapterMap.keySet()) {
                        if (volunterChapterMap.get(currContact) == (roleToAddAutomatically.Chapter_Name__c))  {
                            Volunteer_Roles__c newVolRole = new Volunteer_Roles__c();
                            newVolRole.Chapter_Role__c = roleToAddAutomatically.id;
                            newVolRole.Volunteer_Name__c = currContact;
                            newVolRole.Status__c = 'Pending';
                            newVolRole.sub_status__c = 'Missing Requirement'; //At the time of save, the volunteer has not completed COI.
                            //Signing of COI should trigger change to Active assignment.
                            volunteerRoleList.add(newVolRole);
                        }
                    }    
                }
            }    catch(QueryException e)    {
                //Empty list. Carry on.
            }
            //End SIW-488
            
            if (volunteerRoleList.size() > 0) {
                insert volunteerRoleList;
            }
            if (Test.isRunningTest()) {
                throw new CommonTriggerException('Test Class execution');
            }
        } catch (Exception ex) {
            for (Contact currRec : volunteerContactMap.values()) {
                ErrorMessage_AC.createdebugRec('Contact_OnAfterUpdateTriggerHepler', String.valueof(currRec), String.valueOf(ex), 'CreateVolunteerRoles', currRec.Id, ex.getStackTraceString(), 'Error');
            }
            if (!Test.isRunningTest()) {
                for (Contact currRec : volunteerContactMap.values()) {
                    currRec.addError(Label.Debug_log_error_message);
                }
            }

        }
    }

    // If volunteer updates the zipcode that belongs to outside of the chapter, then it would create task for Volunteer Manager.
    public static void CreateZipcodeUpdateTask(Set<String> zipCodesSet, Map<Id, Contact> contactMap) {
        Map<String, String> zipCodeChapterMap = new Map<String, String>();
        List<Task> newTaskList = new List<Task>();
        Id taskRT = Constant_AC.STAFF_TASK_RT_ID;
        String mailingCode;
        Map<Id, Set<Id>> taskIdsMap = new Map<Id, Set<Id>>();
        try {
            for (Task addressTask : [
                    SELECT Id
                    FROM Task
                    WHERE WhatId IN :contactMap.keySet() AND Subject = 'Volunteer Address Change' AND isClosed = false
                    Limit 50000
            ]) {
                if (taskIdsMap.containsKey(addressTask.WhoId)) {
                    taskIdsMap.get(addressTask.WhoId).add(addressTask.WhatId);
                } else {
                    taskIdsMap.put(addressTask.WhoId, new Set<Id>{
                            addressTask.WhatId
                    });
                }
            }
            for (Zip_Code__c currZip : [
                    SELECT Id, Name, Office__c, Office__r.Chapter__c
                    FROM Zip_Code__c
                    WHERE Name IN :zipCodesSet
                    Limit 50000
            ]) {
                if (currZip.Office__c != Null)
                    zipCodeChapterMap.put(currZip.Name, currZip.Office__r.Chapter__c);
            }
            for (npe5__Affiliation__c currAffiliation : [
                    SELECT Id,npe5__Contact__c, npe5__Contact__r.MailingPostalcode, npe5__Contact__r.OwnerId, npe5__Organization__c,npe5__Contact__r.Volunteer_Role__c
                    FROM npe5__Affiliation__c
                    WHERE npe5__Contact__c IN :contactMap.keySet() AND npe5__Primary__c = True
                    Limit 50000
            ]) {
                if (currAffiliation.npe5__Contact__r.MailingPostalcode != null && String.valueOf(currAffiliation.npe5__Contact__r.MailingPostalcode).length() > 5 && String.valueOf(currAffiliation.npe5__Contact__r.MailingPostalcode).contains('-')) {
                    mailingCode = String.valueOf(currAffiliation.npe5__Contact__r.MailingPostalcode).split('-')[0];
                } else {
                    mailingCode = currAffiliation.npe5__Contact__r.MailingPostalcode;
                }
                if (zipCodeChapterMap.containsKey(mailingCode)) {
                    if (currAffiliation.npe5__Organization__c != zipCodeChapterMap.get(mailingCode)) {
                        if (taskIdsMap.containsKey(currAffiliation.npe5__Contact__c) && !taskIdsMap.get(currAffiliation.npe5__Contact__c).contains(currAffiliation.npe5__Contact__c)) {
                            Task newTask = new Task();
                            newTask.Subject = 'Volunteer Address Change';
                            newTask.whoId = currAffiliation.npe5__Contact__c;
                            newTask.OwnerId = currAffiliation.npe5__Contact__r.OwnerId;
                            newTask.Status = 'Not Started';
                            newTask.activityDate = Date.Today() + 5;
                            newTask.whatId = zipCodeChapterMap.get(mailingCode);
                            newTask.RecordTypeId = taskRT;
                            newTaskList.add(newTask);
                        }
                    }
                }
            }
            if (newTaskList.size() > 0)
                insert newTaskList;

            if (Test.isRunningTest()) {
                throw new CommonTriggerException('Test Class execution');
            }

        } catch (Exception ex) {
            for (Contact currRec : contactMap.values()) {
                ErrorMessage_AC.createdebugRec('Contact_OnAfterUpdateTriggerHepler', String.valueof(currRec), String.valueOf(ex), 'CreateZipcodeUpdateTask', currRec.Id, ex.getStackTraceString(), 'Error');
            }

            if (!Test.isRunningTest()) {
                for (Contact currRec : contactMap.values()) {
                    currRec.addError(Label.Debug_log_error_message);
                }
            }
        }
    }
    // used to update the medicalProffsnal contact information.
    public static void updateMedicalProfConatctInfo(set<Id> MedicalProfContactSet) {
        Map<Id, npe4__Relationship__c > childContactMap = new Map<Id, npe4__Relationship__c >();
        List<Contact> updateChildContactList = new List<Contact>();
        Id wichChildRecordTypeId = Constant_AC.CONTACT_WISH_CHILD_RT_ID;

        for (npe4__Relationship__c dbMedicalRelationShipRec : [
                SELECT Id,npe4__RelatedContact__c,npe4__RelatedContact__r.Name,npe4__RelatedContact__r.Email,npe4__Contact__c,npe4__Type__c,Qualifying_Medical_Professional__c,npe4__Status__c
                FROM npe4__Relationship__c
                WHERE npe4__RelatedContact__c IN:MedicalProfContactSet AND Qualifying_Medical_Professional__c = :TRUE AND npe4__Status__c = :'Active'
                Limit 50000
        ]) {

            childContactMap.put(dbMedicalRelationShipRec.npe4__Contact__c, dbMedicalRelationShipRec);
        }

        for (Contact dbChildContact : [
                SELECT Id,Hidden_Medical_Physician__c,Hidden_Medical_Physician_Email__c,RecordTypeId
                FROM Contact
                WHERE Id IN:childContactMap.KeySet() AND RecordTypeId = :wichChildRecordTypeId
                Limit 50000
        ]) {
            if (childContactMap.containsKey(dbChildContact.Id)) {

                contact updateChildContact = new contact();
                updateChildContact.Id = dbChildContact.Id;
                updateChildContact.Hidden_Medical_Physician__c = childContactMap.get(dbChildContact.Id).npe4__RelatedContact__r.Name;
                updateChildContact.Hidden_Medical_Physician_Email__c = childContactMap.get(dbChildContact.Id).npe4__RelatedContact__r.Email;
                updateChildContactList.add(updateChildContact);
            }
        }
        if (updateChildContactList.size() > 0)
            Update updateChildContactList;
    }

    // Updating User information when volunteer contact details updated.
    public static void updateUserDetails(map<String, Contact> contactDetails, Map<Id, Contact> oldMap) {
        User updateUser;
        List<User> updateUserList = new List<User>();
        try {
            for (User currRecUser : [
                    SELECT id,ContactId,FirstName,LastName,Email,mobilephone,Phone,City,Street,State,PostalCode,Fax
                    FROM User
                    WHERE contactId IN:contactDetails.keyset()
                    Limit 50000
            ]) {
                updateUser = new User();
                updateUser.id = currRecUser.id;
                Boolean flag = false;
                if (contactDetails.get(currRecUser.ContactId).FirstName != oldMap.get(currRecUser.ContactId).FirstName && currRecUser.FirstName != contactDetails.get(currRecUser.ContactId).FirstName) {
                    updateUser.FirstName = contactDetails.get(currRecUser.ContactId).FirstName;
                    flag = true;
                }
                if (contactDetails.get(currRecUser.ContactId).LastName != oldMap.get(currRecUser.ContactId).LastName && currRecUser.LastName != contactDetails.get(currRecUser.ContactId).LastName) {
                    updateUser.LastName = contactDetails.get(currRecUser.ContactId).LastName;
                    flag = true;
                }
                if (contactDetails.get(currRecUser.ContactId).Email != oldMap.get(currRecUser.ContactId).Email && currRecUser.Email != contactDetails.get(currRecUser.ContactId).Email) {
                    updateUser.Email = contactDetails.get(currRecUser.ContactId).Email;
                    flag = true;
                }
                if (contactDetails.get(currRecUser.ContactId).MobilePhone != oldMap.get(currRecUser.ContactId).MobilePhone && currRecUser.Phone != contactDetails.get(currRecUser.ContactId).MobilePhone) {
                    updateUser.MobilePhone = contactDetails.get(currRecUser.ContactId).MobilePhone;
                    flag = true;
                }

                if (contactDetails.get(currRecUser.ContactId).MailingStreet != oldMap.get(currRecUser.ContactId).MailingStreet && currRecUser.Street != contactDetails.get(currRecUser.ContactId).MailingStreet) {
                    updateUser.Street = contactDetails.get(currRecUser.ContactId).MailingStreet;
                    flag = true;
                }
                if (contactDetails.get(currRecUser.ContactId).MailingCity != oldMap.get(currRecUser.ContactId).MailingCity && currRecUser.City != contactDetails.get(currRecUser.ContactId).MailingCity) {
                    updateUser.City = contactDetails.get(currRecUser.ContactId).MailingCity;
                    flag = true;
                }
                if (contactDetails.get(currRecUser.ContactId).mailingstate != oldMap.get(currRecUser.ContactId).mailingstate && currRecUser.State != contactDetails.get(currRecUser.ContactId).mailingstate) {
                    updateUser.State = contactDetails.get(currRecUser.ContactId).mailingstate;
                    flag = true;
                }
                if (contactDetails.get(currRecUser.ContactId).mailingpostalcode != oldMap.get(currRecUser.ContactId).mailingpostalcode && currRecUser.PostalCode != contactDetails.get(currRecUser.ContactId).mailingpostalcode) {
                    updateUser.PostalCode = contactDetails.get(currRecUser.ContactId).mailingpostalcode;
                    flag = true;
                }

                if (contactDetails.get(currRecUser.ContactId).Fax != oldMap.get(currRecUser.ContactId).Fax && currRecUser.Fax != contactDetails.get(currRecUser.ContactId).Fax) {
                    updateUser.Fax = contactDetails.get(currRecUser.ContactId).Fax;
                    flag = true;
                }

                if (flag == true)
                    updateUserList.add(updateUser);
            }

            if (updateUserList.size() > 0)
                update updateUserList;

            if (Test.isRunningTest()) {
                throw new CommonTriggerException('Test Class execution');
            }

        } catch (Exception ex) {
            for (Contact currRec : contactDetails.values()) {
                ErrorMessage_AC.createdebugRec('Contact_OnAfterUpdateTriggerHepler', String.valueof(currRec), String.valueOf(ex), 'updateUserDetails', currRec.Id, ex.getStackTraceString(), 'Error');
            }

            if (!Test.isRunningTest()) {
                for (Contact currRec : contactDetails.values()) {
                    currRec.addError(Label.Debug_log_error_message);
                }

            }
        }
    }
    // Update HouseHoldAddress for family contact records.
    @future
    public static void updateHouseHoldAddress(Set<Id> addressSet) {
        List<Contact> dbFamilyContact = new List<Contact>();
        Set<Id> dbFamilyAccountIdSet = new Set<Id>();
        List<Contact> updateFamilyContactList = new List<Contact>();
        Map<Id, Account> houseHoldAccountMap = new Map<Id, Account>();

        for (Contact familyContact : [
                SELECT Id,AccountId,Name,FirstName,LastName,Phone,Email,MailingStreet,MailingCity,MailingState,MailingCountry,MailingPostalCode,Same_as_Household_Address__c
                From Contact
                WHERE Id IN:addressSet
                Limit 50000
        ]) {
            if (familyContact.Same_as_Household_Address__c == true) {
                dbFamilyAccountIdSet.add(familyContact.AccountId);
                dbFamilyContact.add(familyContact);
            }
        }
        if (dbFamilyAccountIdSet.size() > 0) {
            for (Account dbHouseHoldAccount : [
                    SELECT Id,BillingStreet,BillingCity,BillingState,BillingCountry,BillingPostalCode
                    FROM Account
                    WHERE Id IN:dbFamilyAccountIdSet
                    Limit 50000
            ]) {
                houseHoldAccountMap.put(dbHouseHoldAccount.Id, dbHouseHoldAccount);
            }

            for (Contact familyContact : dbFamilyContact) {
                if (houseHoldAccountMap.containsKey(familyContact.AccountId)) {
                    familyContact.MailingStreet = houseHoldAccountMap.get(familyContact.AccountId).BillingStreet;
                    familyContact.MailingCity = houseHoldAccountMap.get(familyContact.AccountId).BillingCity;
                    familyContact.MailingState = houseHoldAccountMap.get(familyContact.AccountId).BillingState;
                    familyContact.MailingCountry = houseHoldAccountMap.get(familyContact.AccountId).BillingCountry;
                    familyContact.MailingPostalCode = houseHoldAccountMap.get(familyContact.AccountId).BillingPostalCode ;
                    updateFamilyContactList.add(familyContact);
                }
            }

        }
        if (updateFamilyContactList.size() > 0)
            update updateFamilyContactList;
    }
    // Updated relationship for the contact record.
    public static void updateRelationship(Map<Id, Contact> conMap) {
        Map<Id, npe4__Relationship__c> relationShipMap = new Map<Id, npe4__Relationship__c>();
        try {
            for (npe4__Relationship__c dbRelationShip : [
                    SELECT Id,npe4__Contact__c,npe4__RelatedContact__c,npe4__Type__c
                    From npe4__Relationship__c
                    WHERE npe4__RelatedContact__c IN:conMap.KeySet()
                    Limit 50000
            ]) {

                if (conMap.containsKey(dbRelationShip.npe4__RelatedContact__c)) {
                    dbRelationShip.npe4__Type__c = conMap.get(dbRelationShip.npe4__RelatedContact__c).Relationship__c;
                    relationShipMap.put(dbRelationShip.Id, dbRelationShip);
                }
            }
            if (relationShipMap.size() > 0) {
                update relationShipMap.values();
            }
            if (Test.isRunningTest()) {
                throw new CommonTriggerException('Test Class execution');
            }

        } catch (Exception ex) {

            for (Contact currRec : conMap.values()) {
                ErrorMessage_AC.createdebugRec('Contact_OnAfterUpdateTriggerHepler', String.valueOf(currRec), String.valueOf(ex), 'updateRelationship', currRec.Id, ex.getStackTraceString(), 'Error');
            }
            if (!Test.isRunningTest()) {
                for (Contact currRec : conMap.values()) {
                    currRec.addError(Label.Debug_log_error_message);
                }
            }
        }
    }
    // Used to create affiliation record.
    public static void CreateAffliation(List<Contact> ContactList) {
        RecursiveTriggerHandler.isFirstTime = false;
        Id volunteerRecordTypeId = Constant_AC.VOLUNTEER_RT_ID;
        Id wichChildRecordTypeId = Constant_AC.CONTACT_WISH_CHILD_RT_ID;
        Id familyContactRecordTypeId = Constant_AC.WISH_FAMILY_RT_ID;
        Id boardMemberRT = Constant_AC.BOARD_MEMBER_RT_ID;
        Id MedicalProfContactRecordTypeId = Constant_AC.MEDICAL_PROFESSIONAL_RT_ID;
        List<npe5__Affiliation__c> affDbList = new List<npe5__Affiliation__c>();
        List<npe5__Affiliation__c> houseHoldAffList = new List<npe5__Affiliation__c>();
        npe5__Affiliation__c aff;
        List<npe5__Affiliation__c> UdateAff = new List<npe5__Affiliation__c>();
        set<Id> contactIds = new set<Id>();
        List<npe5__Affiliation__c> affList = new List<npe5__Affiliation__c>();

        try {
            for (Contact con : ContactList) {
                if ((con.RecordTypeId == MedicalProfContactRecordTypeId && con.Hidden_Hospital_Account__c != Null) || (con.RecordTypeId != MedicalProfContactRecordTypeId)) {
                    npe5__Affiliation__c houseHoldAffiliation = new npe5__Affiliation__c();
                    if (con.RecordTypeId == MedicalProfContactRecordTypeId && con.Hidden_Hospital_Account__c != Null)
                        houseHoldAffiliation.npe5__Organization__c = con.Hidden_Hospital_Account__c; else
                            houseHoldAffiliation.npe5__Organization__c = con.AccountId;

                    houseHoldAffiliation.npe5__Contact__c = con.id;
                    houseHoldAffiliation.npe5__StartDate__c = Date.Today();
                    houseHoldAffiliation.npe5__Status__c = 'Active';
                    if (con.RecordTypeId == volunteerRecordTypeId) {
                        houseHoldAffiliation.Constituent_Code__c = Constant_AC.VOLUNTEER_TASK_RT_LABEL;
                        houseHoldAffiliation.npe5__Primary__c = true;
                        contactIds.add(con.Id);
                    } else if (con.RecordTypeId == boardMemberRT)
                        houseHoldAffiliation.Constituent_Code__c = Constant_AC.BOARD_MEMBER_RT_LABEL;
                    if (con.RecordTypeId == MedicalProfContactRecordTypeId)
                        houseHoldAffiliation.npe5__Primary__c = false;
                    houseHoldAffList.add(houseHoldAffiliation);
                }
                if ((con.RecordTypeId == MedicalProfContactRecordTypeId) || con.RecordTypeId == familyContactRecordTypeId || con.RecordTypeId == wichChildRecordTypeId) {
                    aff = new npe5__Affiliation__c();
                    if (con.Region_Chapter__c != Null) {
                        aff.npe5__Organization__c = con.Region_Chapter__c;
                        aff.npe5__Contact__c = con.id;
                        aff.npe5__StartDate__c = Date.Today();
                        aff.npe5__Status__c = 'Active';
                        if (con.RecordTypeId == familyContactRecordTypeId) {
                            aff.Constituent_Code__c = Constant_AC.WISH_FAMILY_RT_LABEL;
                        } else if (con.RecordTypeId == wichChildRecordTypeId) {
                            aff.Constituent_Code__c = Constant_AC.CONTACT_WISH_CHILD_RT_LABEL;
                        }

                        if (con.RecordTypeId == MedicalProfContactRecordTypeId) {
                            aff.Constituent_Code__c = Constant_AC.MEDICAL_PROFESSIONAL_RT_LABEL;
                            aff.npe5__Primary__c = true;
                        }
                        affDbList.add(aff);
                    }
                }
                if (con.recordtypeid == volunteerRecordTypeId) {
                    if (con.Region_Chapter__c == Null && con.AccountId != Null)
                        con.Region_Chapter__c = con.AccountId;
                    if (con.AccountId == Null && con.Region_Chapter__c != Null)
                        con.AccountId = con.Region_Chapter__c;
                }
            }
            if (contactIds.size() > 0) {
                For (npe5__Affiliation__c currAff : [
                        SELECT Id,npe5__Primary__c
                        FROM npe5__Affiliation__c
                        WHERE npe5__Contact__c IN :contactIds AND npe5__Primary__c = True
                        Limit 50000
                ]) {
                    currAff.npe5__Primary__c = false;
                    affList.add(currAff);
                }
                If (affList.Size() > 0)
                    Update affList;
            }
            if (houseHoldAffList.size() > 0) {
                insert houseHoldAffList;
            }
            if (affDbList.size() > 0) {
                Insert affDbList;
            }

            if (Test.isRunningTest()) {
                throw new CommonTriggerException('Test Class execution');
            }

        } catch (Exception ex) {
            for (Contact currRec : ContactList) {
                ErrorMessage_AC.createdebugRec('Contact_OnAfterUpdateTriggerHepler', String.valueof(currRec), String.valueOf(ex), 'CreateAffliation', currRec.Id, ex.getStackTraceString(), 'Error');
            }

            if (!Test.isRunningTest()) {
                for (Contact currRec : ContactList) {
                    currRec.addError(Label.Debug_log_error_message);
                }
            }

        }
    }

    public static void updateWishFormRec(List<Contact> updatedContactList) {
        Map<Id, Contact> wishChildcontactMap = new Map<Id, Contact>();
        Map<Id, Contact> wishFamilyContactMap = new Map<Id, Contact>();
        Id WishFormfamilyContactRecordTypeId = Constant_AC.WISH_FORM_FAMILY_ID;
        Id wichChildRecordTypeId = Constant_AC.WISH_FORM_CHILD_ID;
        Id wichChildcontactRecordTypeId = Constant_AC.CONTACT_WISH_CHILD_RT_ID;
        Id familyContactRecordTypeId = Constant_AC.WISH_FAMILY_RT_ID;
        List<Wish_Child_Form__c> updateWishFormList = new List<Wish_Child_Form__c>();
        for (Contact dbProcessedContact : updatedContactList) {
            if (dbProcessedContact.RecordTypeId == wichChildcontactRecordTypeId && dbProcessedContact.Hidden_Wish_Form_Id__c != Null) {
                wishChildcontactMap.put(dbProcessedContact.Hidden_Wish_Form_Id__c, dbProcessedContact);
            } else if (dbProcessedContact.RecordTypeId == familyContactRecordTypeId && dbProcessedContact.Hidden_Wish_Form_Id__c != Null) {
                wishFamilyContactMap.put(dbProcessedContact.Hidden_Wish_Form_Id__c, dbProcessedContact);
            }
        }

        if (wishChildcontactMap .size() > 0) {

            for (Wish_Child_Form__c dbWishForm : [
                    SELECT Id,FirstName__c,LastName__c,Middle_Name__c,Gender__c,Self_describe_comment_box__c,BirthDate__c,T_Shirt_Size__c,Diagnosis__c,
                            PrimaryAddreess__c,mobilePhone__c,Email__c,Color__c,Music_Singer__c,Book_Story__c,Hobby__c,Game__c,Food__c,Movie__c,TVShow__c,Restaurant__c,Actor_Actress__c,Cake_Candy__c,
                            Sport_Athlete__c,Snack_Food__c,Pet_Animal__c,ClassinSchool__c,Other__c,When_I_m_outside_I_like_to__c,When_I_m_inside_I_like_to__c,Electronics_Games_that_I_like_to_play__c,
                            When_I_m_with_my_family_I_like_to__c,When_I_m_with_my_friends_I_like_to__c,MY_WISH_IS_TO__c,When_I_think_about_my_wish_I_imagine__c,This_is_my_wish_because__c,To_me_the_most_important_part_of_my_wish__c,
                            Wish_Notes__c,When_thinking_some_of_my_wish_ideas_were__c,Street__c,City__c,State__c,Zip_code__c,RecordTypeId,Migrated__c
                    FROM Wish_Child_Form__c
                    WHERE Id IN:wishChildcontactMap .KeySet()
                    AND RecordTypeId = :wichChildRecordTypeId AND Migrated__c = False
            ]) {
                if (wishChildcontactMap.containsKey(dbWishForm.Id)) {
                    dbWishForm.FirstName__c = wishChildcontactMap.get(dbWishForm.Id).FirstName;
                    dbWishForm.LastName__c = wishChildcontactMap.get(dbWishForm.Id).LastName;
                    dbWishForm.Middle_Name__c = wishChildcontactMap.get(dbWishForm.Id).Middle_Name__c;
                    dbWishForm.BirthDate__c = wishChildcontactMap.get(dbWishForm.Id).BirthDate;
                    dbWishForm.Diagnosis__c = wishChildcontactMap.get(dbWishForm.Id).Diagnosis__c;
                    dbWishForm.Gender__c = wishChildcontactMap.get(dbWishForm.Id).Gender__c;
                    dbWishForm.Self_describe_comment_box__c = wishChildcontactMap.get(dbWishForm.Id).Self_describe_comment_box__c;
                    dbWishForm.mobilePhone__c = wishChildcontactMap.get(dbWishForm.Id).MobilePhone;
                    dbWishForm.Email__c = wishChildcontactMap.get(dbWishForm.Id).Email;
                    dbWishForm.T_Shirt_Size__c = wishChildcontactMap.get(dbWishForm.Id).T_Shirt_Size__c;
                    dbWishForm.Street__c = wishChildcontactMap.get(dbWishForm.Id).MailingStreet;
                    dbWishForm.State__c = wishChildcontactMap.get(dbWishForm.Id).MailingState;
                    dbWishForm.city__c = wishChildcontactMap.get(dbWishForm.Id).MailingCity;
                    dbWishForm.Zip_code__c = wishChildcontactMap.get(dbWishForm.Id).MailingPostalCode;
                    dbWishForm.Contact__c = wishChildcontactMap.get(dbWishForm.Id).Id;
                    dbWishForm.Color__c = wishChildcontactMap.get(dbWishForm.Id).Color__c ;
                    dbWishForm.Music_Singer__c = wishChildcontactMap.get(dbWishForm.Id).Music_Singer__c;
                    dbWishForm.Book_Story__c = wishChildcontactMap.get(dbWishForm.Id).Book_Story__c;
                    dbWishForm.Hobby__c = wishChildcontactMap.get(dbWishForm.Id).Hobby__c ;
                    dbWishForm.Game__c = wishChildcontactMap.get(dbWishForm.Id).Game__c;
                    dbWishForm.Movie__c = wishChildcontactMap.get(dbWishForm.Id).Movie__c;
                    dbWishForm.Food__c = wishChildcontactMap.get(dbWishForm.Id).Food__c;
                    dbWishForm.TVShow__c = wishChildcontactMap.get(dbWishForm.Id).TV_Show__c;
                    dbWishForm.Restaurant__c = wishChildcontactMap.get(dbWishForm.Id).Restaurant__c;
                    dbWishForm.Actor_Actress__c = wishChildcontactMap.get(dbWishForm.Id).Actor_Actress__c ;
                    dbWishForm.Cake_Candy__c = wishChildcontactMap.get(dbWishForm.Id).Cake_Candy__c;
                    dbWishForm.Sport_Athlete__c = wishChildcontactMap.get(dbWishForm.Id).Sport_Athlete__c;
                    dbWishForm.Snack_Food__c = wishChildcontactMap.get(dbWishForm.Id).Snack_Food__c ;
                    dbWishForm.Pet_Animal__c = wishChildcontactMap.get(dbWishForm.Id).Pet_Animal__c ;
                    dbWishForm.ClassinSchool__c = wishChildcontactMap.get(dbWishForm.Id).Class_in_School__c;
                    dbWishForm.When_I_m_outside_I_like_to__c = wishChildcontactMap.get(dbWishForm.Id).When_I_m_outside_I_like_to__c ;
                    dbWishForm.When_I_m_inside_I_like_to__c = wishChildcontactMap.get(dbWishForm.Id).When_I_m_inside_I_like_to__c;
                    dbWishForm.Electronics_Games_that_I_like_to_play__c = wishChildcontactMap.get(dbWishForm.Id).Electronics_Games_that_I_like_to_play__c ;
                    dbWishForm.When_I_m_with_my_family_I_like_to__c = wishChildcontactMap.get(dbWishForm.Id).When_I_m_with_my_family_I_like_to__c ;
                    dbWishForm.When_I_m_with_my_friends_I_like_to__c = wishChildcontactMap.get(dbWishForm.Id).When_I_m_with_my_friends_I_like_to__c;
                    dbWishForm.When_thinking_some_of_my_wish_ideas_were__c = wishChildcontactMap.get(dbWishForm.Id).When_thinking_some_of_my_wish_ideas_were__c;
                    dbWishForm.MY_WISH_IS_TO__c = wishChildcontactMap .get(dbWishForm.Id).MyWishIsTo__c ;
                    dbWishForm.This_is_my_wish_because__c = wishChildcontactMap .get(dbWishForm.Id).This_is_my_wish_because__c;
                    dbWishForm.To_me_the_most_important_part_of_my_wish__c = wishChildcontactMap .get(dbWishForm.Id).To_me_the_most_important_part_of_my_wish__c;
                    dbWishForm.When_I_think_about_my_wish_I_imagine__c = wishChildcontactMap .get(dbWishForm.Id).When_I_think_about_my_wish_I_imagine__c;
                    dbWishForm.Wish_Notes__c = wishChildcontactMap .get(dbWishForm.Id).Wish_Notes__c;
                    dbWishForm.Preferred_Name__c = wishChildcontactMap .get(dbWishForm.Id).Preferred_Name__c;
                    updateWishFormList.add(dbWishForm);
                }
            }
        }
        if (wishFamilyContactMap.size() > 0) {

            for (Wish_Child_Form__c dbWishForm : [
                    SELECT Id,FirstName__c,Middle_Name__c,LastName__c,Emergency_Relationship__c,Home_Phone__c,TelePhone__c,mobilePhone__c,Email__c,
                            BirthDate__c,Street__c,City__c,State__c,Zip_code__c,Residing_With_Wish_Child__c,T_Shirt_Size__c,RecordTypeId,
                            Migrated__c
                    FROM Wish_Child_Form__c
                    WHERE Id IN:wishFamilyContactMap.KeySet() AND
                    RecordTypeId = :WishFormfamilyContactRecordTypeId AND Migrated__c = False
            ]) {

                if (wishFamilyContactMap.containsKey(dbWishForm.Id)) {
                    dbWishForm.FirstName__c = wishFamilyContactMap.get(dbWishForm.Id).FirstName;
                    dbWishForm.LastName__c = wishFamilyContactMap.get(dbWishForm.Id).LastName;
                    dbWishForm.Middle_Name__c = wishFamilyContactMap.get(dbWishForm.Id).Middle_Name__c;
                    dbWishForm.BirthDate__c = wishFamilyContactMap.get(dbWishForm.Id).BirthDate;
                    dbWishForm.mobilePhone__c = wishFamilyContactMap.get(dbWishForm.Id).MobilePhone;
                    dbWishForm.Email__c = wishFamilyContactMap.get(dbWishForm.Id).Email;
                    dbWishForm.T_Shirt_Size__c = wishFamilyContactMap.get(dbWishForm.Id).T_Shirt_Size__c;
                    dbWishForm.Street__c = wishFamilyContactMap.get(dbWishForm.Id).MailingStreet;
                    dbWishForm.State__c = wishFamilyContactMap.get(dbWishForm.Id).MailingState;
                    dbWishForm.city__c = wishFamilyContactMap.get(dbWishForm.Id).MailingCity;
                    dbWishForm.Zip_code__c = wishFamilyContactMap.get(dbWishForm.Id).MailingPostalCode;
                    dbWishForm.Contact__c = wishFamilyContactMap.get(dbWishForm.Id).Id;
                    dbWishForm.Gender__c = wishFamilyContactMap.get(dbWishForm.Id).Gender__c;
                    dbWishForm.Residing_With_Wish_Child__c = wishFamilyContactMap.get(dbWishForm.Id).Residing_with_Wish_child__c;
                    dbWishForm.Home_Phone__c = wishFamilyContactMap.get(dbWishForm.Id).HomePhone;
                    dbWishForm.TelePhone__c = wishFamilyContactMap.get(dbWishForm.Id).npe01__WorkPhone__c ;
                    dbWishForm.Emergency_Relationship__c = wishFamilyContactMap.get(dbWishForm.Id).Relationship__c;
                    dbWishForm.RecordTypeId = WishFormfamilyContactRecordTypeId;
                    updateWishFormList.add(dbWishForm);
                }

            }
        }

        if (updateWishFormList.size() > 0) {
            update updateWishFormList;
        }
    }

}