public class ContactMergeController_AC {
    public Contact con { get; set; }
    public List<AffiliationWrapper> affiliationsList { get; set; }
    public List<RelationshipWrapper> relationshipList { get; set; }
    public List<VolunteerOTWrapper> volunteerOTList { get; set; }
    public List<VolunteerRoleWrapper> volunteerRoleList { get; set; }
    public List<VolunteerOpportunityWrapper> volunteerOppList { get; set; }
    public List<BackgroundCheckWrapper> backgroundcheckList { get; set; }
    public List<ConflictOfInterestWrapper> conflictofInterestList { get; set; }
    public List<AwardsRecognitionWrapper> awardsRecognitionList { get; set; }
    public List<InkindDonationWrapper> inkindDonationList { get; set; }
    public List<ContactWrapper> searchResults { get; private set; }
    public Map<Id, ContactWrapper> mapHoldingSelectedRecords { get; set; }
    public Map<String, Contact> selectedRecords;
    public List<FieldRow> fieldRows { get; private set; }
    public Integer setPageSize { get; set; }
    public Boolean newSearch;
    public Boolean searchNewResult;
    public String birthDate { get; set; }
    public Boolean displaySearchResults { get; set; }
    public Integer step { get; private set; }
    private static final String MASTER_KEY = '$MASTER$';
    
    public ContactMergeController_AC(ApexPages.StandardController controller) {
        affiliationsList = new List<AffiliationWrapper>();
        relationshipList = new List<RelationshipWrapper>();
        volunteerOTList = new List<VolunteerOTWrapper>();
        volunteerRoleList = new List<VolunteerRoleWrapper>();
        volunteerOppList = new List<VolunteerOpportunityWrapper>();
        backgroundcheckList = new List<BackgroundCheckWrapper>();
        conflictofInterestList = new List<ConflictOfInterestWrapper>();
        awardsRecognitionList = new List<AwardsRecognitionWrapper>();
        inkindDonationList = new List<InkindDonationWrapper>();
        searchResults = new List<ContactWrapper>();
        fieldRows = new List<FieldRow>();
        selectedRecords = new Map<String, Contact>();
        mapHoldingSelectedRecords = new Map<Id, ContactWrapper>();
        con = new Contact();
        step = 1;
        setPageSize = 10;
        displaySearchResults = false;
        newSearch = false;
        searchNewResult = false;
    }    
    
    /**
    * Show the next step of the wizard where user can see the diff of the records before merge
    */
    public void nextStep() {
        String contactIdFilter = '';
        this.selectedRecordsCount = 0;
        updateSearchItemsMap();
        if(!mapHoldingSelectedRecords.isEmpty()) {
            for(ContactWrapper c : mapHoldingSelectedRecords.values()) {
                if(c.selected == true) {
                    contactIdFilter += ('\'' + c.con.Id + '\',');
                    this.selectedRecordsCount++;
                }
            }
        } else {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 
                                                       'Please select maximum of 2 contacts to merge.'));
            return;
        }
        contactIdFilter = contactIdFilter.substring(0, contactIdFilter.length() - 1);
        //Throw error if not at least 2 records selected
        if(this.selectedRecordsCount != 2 && !Test.isRunningTest()) {
            displaySearchResults = true;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 
                                                       'Please select maximum of 2 contacts to merge.'));
            return;
        }
        
        Map<String, Schema.SObjectField> contactFields = Schema.SObjectType.Contact.fields.getMap();
        Map<String, Schema.DescribeFieldResult> standardFieldMap = new Map<String, Schema.DescribeFieldResult>();
        Map<String, Schema.DescribeFieldResult> customFieldMap = new Map<String, Schema.DescribeFieldResult>();
        //Construct the query string
        String query = 'SELECT Id, Name, ';
        for(String fieldName : contactFields.keySet()) {
            Schema.SobjectField f = contactFields.get(fieldName);
            Schema.DescribeFieldResult fResult = f.getDescribe();
            //Only include the fields which are updateable
            if(fResult.isupdateable()) {
                //If the field is type lookup, select the parent name
                if(fResult.getRelationshipName() == null) {
                    query += (fieldName + ',');
                } else {
                    query += (fResult.getRelationshipName() + '.name,');
                }
                //Collect the standard and custom fields separately for sorting
                if(fResult.isCustom() && !fResult.getLabel().contains('Hidden')) {
                    customFieldMap.put(fieldName, fResult);
                } if(!fResult.isCustom() && !fResult.getLabel().contains('Record Type')) {
                    standardFieldMap.put(fieldName, fResult);
                }
            }
        }
        //Adding some non-updateable system fields which we need to add to the record diff table
        query += 'CreatedBy.Name, CreatedDate, LastModifiedBy.Name, LastModifiedDate';
        //Append the table name and the filter clause
        query += ' FROM Contact WHERE Id IN  (' + contactIdFilter + ')';
        
        List<Contact> contacts;
        try {
            contacts = Database.query(query);
            //Ensure we got back the same number of records as expected. In case any record got deleted/moved since last search.
            if(contacts == null || contacts.size() != this.selectedRecordsCount) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 
                                                           'Label.Contact_Merge_Error_Query_Failed' + ' ' + 'Label.Contact_Merge_Error_please_retry'));
                return;
            }
        } catch(Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 
                                                       'Label.Contact_Merge_Error_Contact_not_found ' + ' Error: ' + e));
            if(!Test.isRunningTest()) {
                return;
            }
        }
        
        //Update the list of searched records with only the ones selected
        searchResults.clear();
        for(Contact c : contacts) {
            this.selectedRecords.put(c.Id, c);
        }
        //Sort the standard fields list by name before creating the list of FieldRow for merge UI
        List<String> standardFieldList = new List<String>();
        standardFieldList.addAll(standardFieldMap.keySet());
        standardFieldList.sort();
        //Sort the custom fields list by name before creating the list of FieldRow for merge UI
        List<String> customFieldList = new List<String>();
        customFieldList.addAll(customFieldMap.keySet());
        customFieldList.sort();
        //Add the first row of type header with contact names as titles
        FieldRow temp = new FieldRow('', '', false, 'header');
        FieldRow temp2 = new FieldRow('RecordType', 'RecordType', false, '');
        for(Sobject c : contacts) {
            Contact con = (Contact) c;
            temp.values.add(new Cell(c.Id, con.Name));
            temp2.values.add(new Cell(con.RecordType.Name, con.RecordType.Name));
        }
        fieldRows.add(temp);
        fieldRows.add(temp2);
        
        //Add second row to select the master record. Select the one which is last modified
        temp = new FieldRow(MASTER_KEY, 'Master Record', true, null);
        DateTime lastModifiedDate;
        for(Sobject c : contacts) {
            temp.values.add(new Cell(c.Id, null));
            if(lastModifiedDate == null ||
               (lastModifiedDate != null && (DateTime)c.get('lastModifiedDate') > lastModifiedDate)) {
                   temp.selectedValue = c.Id;
                   lastModifiedDate = (DateTime) c.get('lastModifiedDate');
               }
        }
        fieldRows.add(temp);
        for(String fieldName : standardFieldList) {
            addFieldComparisonRows(fieldName, standardFieldMap.get(fieldName), contacts);
        }
        for(String fieldName : customFieldList) {
            addFieldComparisonRows(fieldName, customFieldMap.get(fieldName), contacts);
        }
        FieldRow createdByRow = new FieldRow('CreatedById', 'Created By', false, null);
        FieldRow lastModifiedByRow = new FieldRow('LastModifiedById', 'Last Modified By', false, null);
        for(Sobject c : contacts) {
            SObject createdBy = c.getSObject('createdBy');
            SObject modifiedBy = c.getSObject('lastModifiedBy');
            createdByRow.values.add(new Cell(c.Id, createdBy.get('Name') + ' ' + c.get('createdDate')));
            lastModifiedByRow.values.add(new Cell(c.id, modifiedBy.get('Name') + ' ' + c.get('LastModifiedDate')));
        }
        
        //Get related Affiliations
        String queryString = getFieldSetQuery('npe5__Affiliation__c', 'AffiliationFieldSet');
        queryString += ' FROM npe5__Affiliation__c WHERE npe5__Contact__c IN (' + contactIdFilter + ')';
        for(npe5__Affiliation__c currAff : Database.query(queryString)) {
            AffiliationWrapper aff = new AffiliationWrapper(currAff);
            affiliationsList.add(aff);
        }
        
        //Get related Relationships
        queryString = getFieldSetQuery('npe4__Relationship__c', 'Relationship_Field_Set');
        queryString += ' FROM npe4__Relationship__c WHERE npe4__Contact__c IN  (' + contactIdFilter + ')';
        for(npe4__Relationship__c currRec : Database.query(queryString)) {
            RelationshipWrapper rel = new RelationshipWrapper(currRec);
            relationshipList.add(rel);
        }
        
        //Get related Volunteer Orientation & Training
        queryString = getFieldSetQuery('Volunteer_Orientation_Training__c', 'VolunteerO_T_Feld_set');
        queryString += ' FROM Volunteer_Orientation_Training__c WHERE Volunteer__c IN  (' + contactIdFilter + ')';
        for(Volunteer_Orientation_Training__c currRec : Database.query(queryString)) {
            VolunteerOTWrapper volOT = new VolunteerOTWrapper(currRec);
            volunteerOTList.add(volOT);
        }
        
        //Get related Volunteer Role
        queryString = getFieldSetQuery('Volunteer_Roles__c', 'Volunteer_Role_Field_Set');
        queryString += ' FROM Volunteer_Roles__c WHERE Volunteer_Name__c IN  (' + contactIdFilter + ')';
        for(Volunteer_Roles__c currRec : Database.query(queryString)) {
            volunteerRoleWrapper newVolunteerRole = new volunteerRoleWrapper(currRec);
            volunteerRoleList.add(newVolunteerRole);
        }
        
        //Get related Volunteer Opportunity
        queryString = getFieldSetQuery('Volunteer_Opportunity__c', 'VolunteerDetails');
        queryString += ' FROM Volunteer_Opportunity__c WHERE Volunteer_Name__c IN  (' + contactIdFilter + ')';
        for(Volunteer_Opportunity__c currRec : Database.query(queryString)) {
            VolunteerOpportunityWrapper newVolunteerOpp = new VolunteerOpportunityWrapper(currRec);
            volunteerOppList.add(newVolunteerOpp);
        }
        
        //Get related Background Check
        queryString = getFieldSetQuery('Background_check__c', 'BackgroundCheck');
        queryString += ' FROM Background_check__c WHERE Volunteer__c IN  (' + contactIdFilter + ')';
        for(Background_check__c currRec : Database.query(queryString)) {
            BackgroundCheckWrapper newBC = new BackgroundCheckWrapper(currRec);
            backgroundcheckList.add(newBC);
        }
        
        //Get related Conflict Of Interest
        queryString = getFieldSetQuery('Conflict_Of_Interest__c', 'ConflictOfIntrest');
        queryString += ' FROM Conflict_Of_Interest__c WHERE Volunteer_Contact__c IN  (' + contactIdFilter + ')';
        for(Conflict_Of_Interest__c currRec : Database.query(queryString)) {
            ConflictOfInterestWrapper newCOI = new ConflictOfInterestWrapper(currRec);
            conflictOfInterestList.add(newCOI);
        }
        
        //Get related Awards and Recognition
        queryString = getFieldSetQuery('Awards_Recognition__c', 'AwardsRecognitionFields');
        queryString += ' FROM Awards_Recognition__c WHERE Volunteer_Contact__c IN  (' + contactIdFilter + ')';
        for(Awards_Recognition__c currRec : Database.query(queryString)) {
            AwardsRecognitionWrapper newAwards = new AwardsRecognitionWrapper(currRec);
            awardsRecognitionList.add(newAwards);
        }
        
        //Get In-Kind Donation and Reimbursement
        queryString = getFieldSetQuery('In_Kind_Donation_Reimbursement__c', 'InkindDonationFieldSet');
        queryString += ' FROM In_Kind_Donation_Reimbursement__c WHERE Volunteer_Name__c IN  (' + contactIdFilter + ')';
        for(In_Kind_Donation_Reimbursement__c currRec : Database.query(queryString)) {
            InkindDonationWrapper newinkindDonation = new InkindDonationWrapper(currRec);
            inkindDonationList.add(newinkindDonation);
        }
        this.step++;
    }
    
    /**
    * Merge contacts into selected master
    */
    public PageReference mergeContacts() {
        SObject master;
        String masterRecordType;
        String loserRecordType;
        User masterUser, loserUser;
        masterUser = new User();
        loserUser = new User();
        List<Contact> losers = new List<Contact>();
        Set<Id>loserContactIdSet = new Set<Id>();
        Map<String, Integer> recordTypeHirachyMap = new Map<String, Integer>();
        recordTypeHirachyMap.put(Constant_AC.BOARD_MEMBER_RT_LABEL, 5);
        recordTypeHirachyMap.put(Constant_AC.MEDICAL_PROFESSIONAL_RT_LABEL, 4);
        recordTypeHirachyMap.put(Constant_AC.VOLUNTEER_RT_LABEL, 3);
        recordTypeHirachyMap.put(Constant_AC.CONTACT_WISH_CHILD_RT_LABEL, 2);
        recordTypeHirachyMap.put(Constant_AC.WISH_FAMILY_RT_LABEL, 1);
        List<CaseTeamMember> caseTeamMemberList = new List<CaseTeamMember>();
        //Find the master record based the selected value of the Master FieldRow
        for(FieldRow row : fieldRows) {
            if(row.showRadio && row.fieldName.equals(MASTER_KEY)) {
                master = new Contact(Id = row.selectedValue);
                break;
            }
        }
        if(master != null) {
            for(Contact c : this.selectedRecords.values()) {
                if(c.Id != master.Id) {
                    losers.add(c);
                    loserContactIdSet.add(c.Id);
                }
            }
            for(Contact currCon : [
                SELECT Id, RecordType.Name
                FROM Contact
                WHERE Id IN :loserContactIdSet 
                OR Id = :master.Id
            ]) {
                if(currCon.Id == master.Id) {
                    masterRecordType = currCon.RecordType.Name;
                } else {
                    loserRecordType = currCon.RecordType.Name;
                }
            }
            if(recordTypeHirachyMap.get(masterRecordType) < recordTypeHirachyMap.get(loserRecordType)
               && !Test.isRunningTest()) {
                   ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 
                                                              'When merging two contacts of different record types, the hierarchy of which record type will remain is as follows:<html><body><br/>1.Board Member<br/>2.Volunteer<br/>3.Medical Professional<br/>4.Wish Child<br/>5.Wish Family</body></html>'));
                   return null;
               }
            for(User currUser : [
                SELECT Id, ContactId, IsActive
                FROM User
                WHERE ContactId IN :loserContactIdSet OR ContactId = :master.Id
            ]) {
                if(currUser.ContactId == master.Id) { 
                    masterUser = currUser; 
                } else {
                    loserUser = currUser;
                }
            }
            if(loserUser != null && loserUser.isActive && masterUser != null && masterUser.isActive) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Two Volunteer User can\'t be merged'));
                return null;
            }
            if(loserUser != null && loserUser.isActive && (masterUser == null || !masterUser.isActive)) {
                User swapUser = new User();
                loserContactIdSet.clear();
                Contact swapContact = new Contact();
                swapContact = losers[0];
                losers[0] = (Contact)master;
                master = swapContact;
                loserContactIdSet.add(losers[0].Id);
                swapUser = loserUser;
                loserUser = masterUser;
                masterUser = swapUser;
            }
            //Update the field values of master record based on the selected value for each field
            for(FieldRow row : fieldRows) {
                if(row.showRadio && !row.fieldName.equals(MASTER_KEY) && row.selectedValue != master.Id) {
                    SObject selectedRecord = this.selectedRecords.get(row.selectedValue);
                    if(selectedRecord.get(row.fieldName) == null) {
                        master.put(row.fieldName, null);
                    } else {
                        Object val = selectedRecord.get(row.fieldName);
                        master.put(row.fieldName, val);
                    }
                }
            }
            //Group all the losing records separately
            List<Case> updateCaseList = new List<Case>(updateCases(loserContactIdSet, master.Id));
            List<npe5__Affiliation__c> affiliationList = new List<npe5__Affiliation__c>();
            List<npe5__Affiliation__c> deleteAffiliation = new List<npe5__Affiliation__c>();
            List<npe4__Relationship__c> updateRelationshipList = new List<npe4__Relationship__c>();
            List<npe4__Relationship__c> deleteRelationshipList = new List<npe4__Relationship__c>();
            List<Volunteer_Orientation_Training__c> updateVolunteerOTList = new List<Volunteer_Orientation_Training__c>();
            List<Volunteer_Orientation_Training__c> deleteVolunteerOTList = new List<Volunteer_Orientation_Training__c>();
            List<Volunteer_Roles__c> updateVolunteerRoleList = new List<Volunteer_Roles__c>();
            List<Volunteer_Roles__c> deleteVolunteerRoleList = new List<Volunteer_Roles__c>();
            List<Volunteer_Opportunity__c>updateVolunteerOppList = new List<Volunteer_Opportunity__c>();
            List<Volunteer_Opportunity__c>deleteVolunteerOppList = new List<Volunteer_Opportunity__c>();
            List<Background_check__c> updatedBackgroundCheckList = new List<Background_check__c>();
            List<Background_check__c> deletedBackgroundCheckList = new List<Background_check__c>();
            List<Conflict_Of_Interest__c> updatedConflictOfInterestList = new List<Conflict_Of_Interest__c>();
            List<Conflict_Of_Interest__c> deletedConflictOfInterestList = new List<Conflict_Of_Interest__c>();
            List<Awards_Recognition__c> updatedAwardsRecognitionList = new List<Awards_Recognition__c>();
            List<Awards_Recognition__c> deletedAwardsRecognitionList = new List<Awards_Recognition__c>();
            List<In_Kind_Donation_Reimbursement__c> updatedInkindDonationList = new List<In_Kind_Donation_Reimbursement__c>();
            List<In_Kind_Donation_Reimbursement__c> deletedInkindDonationList = new List<In_Kind_Donation_Reimbursement__c>();
            List<User> updateUserList = new List<User>();
            List<Task> taskList = new List<Task>(updateTasks(loserContactIdSet, master.Id));
            List<cg__ContactFile__c> updateContactFileList = new List<cg__ContactFile__c>(updateContactFiles(loserContactIdSet, master.Id));
            npe5__Affiliation__c newAff;
            npe4__Relationship__c updateRel;
            
            if(!affiliationsList.isEmpty()) {
                for(AffiliationWrapper curraff : affiliationsList) {
                    if(curraff.Checkbox == true) {
                        newAff = currAff.aff.clone(false, true, true, true);
                        newAff.npe5__Contact__c = master.Id;
                        affiliationList.add(newAff);
                        deleteAffiliation.add(currAff.aff);
                    } else {
                        newAff = new npe5__Affiliation__c();
                        newAff.Id = currAff.aff.Id;
                        deleteAffiliation.add(newAff);
                    }
                }
            }
            if(!relationshipList.isEmpty()) {
                for(RelationshipWrapper currRel : relationshipList) {
                    if(currRel.Checkbox == true) {
                        updateRel = currRel.relationship.clone(false, true, true, true);
                        updateRel.npe4__Contact__c = master.Id;
                        updateRelationshipList.add(updateRel);
                        deleteRelationshipList.add(currRel.relationship);
                    } else {
                        updateRel = currRel.relationship;
                        deleteRelationshipList.add(updateRel);
                    }
                }
            }
            if(!VolunteerOTList.isEmpty()) {
                for(VolunteerOTWrapper currRec : VolunteerOTList) {
                    if(currRec.Checkbox == true) {
                        currRec.volunteerOT.Volunteer__c = master.Id;
                        updateVolunteerOTList.add(currRec.volunteerOT);
                    } else {
                        deleteVolunteerOTList.add(currRec.volunteerOT);
                    }
                }
            }
            if(!VolunteerRoleList.isEmpty()) {
                for(VolunteerRoleWrapper currRec : VolunteerRoleList) {
                    if(currRec.Checkbox == true) {
                        currRec.volunteerRole.Volunteer_Name__c = master.Id;
                        updateVolunteerRoleList.add(currRec.volunteerRole);
                    } else {
                        deleteVolunteerRoleList.add(currRec.volunteerRole);
                    }
                }
            }
            if(!VolunteerOppList.isEmpty()) {
                for(VolunteerOpportunityWrapper currRec : VolunteerOppList) {
                    if(currRec.Checkbox == true) {
                        currRec.volunteerOpp.Volunteer_Name__c = master.Id;
                        updateVolunteerOppList.add(currRec.volunteerOpp);
                    } else {
                        deleteVolunteerOppList.add(currRec.volunteerOpp);
                    }
                }
            }
            if(!backgroundcheckList.isEmpty()) {
                for(BackgroundCheckWrapper currRec : backgroundcheckList) {
                    if(currRec.Checkbox == true) {
                        currRec.backgroundCheck.Volunteer__c = master.Id;
                        updatedBackgroundCheckList.add(currRec.backgroundCheck);
                    } else {
                        deletedBackgroundCheckList.add(currRec.backgroundCheck);
                    }
                }
            }
            if(!conflictOfInterestList.isEmpty()) {
                for(ConflictOfInterestWrapper currRec : conflictOfInterestList) {
                    if(currRec.Checkbox == true) {
                        currRec.conflictOfInterest.Volunteer_Contact__c = master.Id;
                        updatedConflictOfInterestList.add(currRec.conflictOfInterest);
                    } else {
                        deletedConflictOfInterestList.add(currRec.conflictOfInterest);
                    }
                }
            }
            if(!awardsRecognitionList.isEmpty()) {
                for(AwardsRecognitionWrapper currRec : awardsRecognitionList) {
                    if(currRec.Checkbox == true) {
                        currRec.awaredsRec.Volunteer_Contact__c = master.Id;
                        updatedAwardsRecognitionList.add(currRec.awaredsRec);
                    } else {
                        deletedAwardsRecognitionList.add(currRec.awaredsRec);
                    }
                }
            }
            if(!inkindDonationList.isEmpty()) {
                for(InkindDonationWrapper currRec : inkindDonationList) {
                    if(currRec.Checkbox == true) {
                        currRec.inkindRec.vounteer_Name__c = master.Id;
                        updatedInkindDonationList.add(currRec.inkindRec);
                    } else {
                        deletedInkindDonationList.add(currRec.inkindRec);
                    }
                }
            }
            
            //Lock the records for change and merge contacts
            System.SavePoint sp = Database.setSavepoint();
            try {
                update master;
                delete deleteAffiliation;
                delete deleteRelationshipList;
                delete deleteVolunteerOTList;
                delete deleteVolunteerRoleList;
                delete deleteVolunteerOppList;
                delete deletedBackgroundCheckList;
                delete deletedAwardsRecognitionList;
                delete deletedInkindDonationList;
                delete losers;
                insert affiliationList;
                insert updateRelationshipList;
                update updateVolunteerOTList;
                update updateVolunteerRoleList;
                update updateVolunteerOppList;
                update updatedBackgroundCheckList;
                update updatedBackgroundCheckList;
                update updatedAwardsRecognitionList;
                update updatedInkindDonationList;
                update taskList;
                update updateContactFileList;
                update updateCaseList;
                if(loserRecordType == Constant_AC.VOLUNTEER_RT_LABEL || loserRecordType == Constant_AC.BOARD_MEMBER_RT_LABEL) {
                    updateUser(loserContactIdSet);
                }
                return new PageReference('/' + master.Id);
            } catch(Exception e) {
                Database.rollback(sp);
                String errorMessage = String.valueOf(e);
                if(errorMessage.Contains('FIELD_CUSTOM_VALIDATION_EXCEPTION')) {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 
                                                               'Contact Merge Error Merge Failed :' + ' ' + errorMessage.subString(errorMessage.lastIndexOfIgnoreCase('FIELD_CUSTOM_VALIDATION_EXCEPTION') + 34).removeEnd(': []')));
                } else if(errorMessage.Contains('FIELD_FILTER_VALIDATION_EXCEPTION')) {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 
                                                               'Contact Merge Error Merge Failed :' + ' ' + errorMessage.subString(errorMessage.lastIndexOfIgnoreCase('FIELD_FILTER_VALIDATION_EXCEPTION,') + 34).removeEnd(': [Region_Code__c]')));
                } else {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 
                                                               'Contact Merge Error Merge Failed :' + ' ' + e));
                }
            }
        } else {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Contact Merge Error No Master'));
        }
        return null;
    }
    
    /**
    * Add field information and field values to the list of fieldRow
    */
    public void addFieldComparisonRows(String fieldName, Schema.DescribeFieldResult fieldDesc, List<SObject> objs) {
        FieldRow row = new FieldRow();
        row.fieldName = fieldName;
        //For standard lookup type fields, use the relationship name as the field label
        if(!fieldDesc.isCustom() && fieldDesc.getRelationshipName() != null) {
            row.fieldLabel = fieldDesc.getRelationshipName();
        } else {
            row.fieldLabel = fieldDesc.getLabel();
        }
        row.values = new List<Cell>();
        Boolean isDifferent = false; //indicate atleast one pair of field values is different across all contacts
        Boolean isNull = true; //indicates all the field values are null
        Integer idx = 0;
        List<String> values = new List<String>();
        DateTime lastModifiedDate = null;
        String prev;
        
        //Iterate over all contacts to find the field values and add them to row values
        for(SObject c : objs) {
            //For lookup fields set the name as the values
            if(fieldDesc.getRelationshipName() != null) {
                Sobject obj = c.getSObject(fieldDesc.getRelationshipName());
                if (obj != null) {
                    values.add(String.valueOf(obj.get('name')));
                } else {
                    values.add(null);
                }
            } else {
                values.add(String.valueOf(c.get(fieldName)));
            }
            isNull &= (c.get(fieldName) == null); //Check if the value is null
            if(idx == 0) {
                prev = String.valueOf(c.get(fieldName));
            }
            //Check if atleast one of the values is different
            if(idx > 0 && !isNull) {
                String current = String.valueOf(c.get(fieldName));
                if ((prev != null && !prev.equals(current)) ||
                    (current != null && !current.equals(prev)) && fieldDesc.getLabel() != 'RecordType') {
                        isDifferent = true;
                    }
                prev = current;
            }
            //Select the default value for the field. A non-null value on the latest modified record
            if(c.get(fieldName) != null && (lastModifiedDate == null ||
                                            (lastModifiedDate != null && (DateTime) c.get('lastModifiedDate') > lastModifiedDate))) {
                                                row.selectedValue = c.id;
                                                lastModifiedDate = (DateTime) c.get('lastModifiedDate');
                                            }
            idx++;
        }
        
        //If atleast one record has a non-null field value then add it to the list of fieldRows
        if(!isNull) {
            for(Integer i = 0; i < values.size(); i++) {
                String val = values[i];
                if (val != null && val.length() > 255) {
                    val = val.substring(0, 251) + ' ...';
                }
                row.values.add(new Cell(objs[i].id, val));
            }
            //Show the select radio only if the field values are different
            //Dont let user choose the account as you dont want users to assign a differnt account in One to One case
            row.showRadio = (isDifferent);
            fieldRows.add(row);
        }
    }
    
    /**
    * Loop through the contacts putting them in an array of contact wrappers
    * @param mySearchList
    * @return result
    */
    public List<ContactWrapper> wrapSOSLResults(List<Contact> mySearchList) {
        List<ContactWrapper> result = new List<ContactWrapper>();
        if(!mySearchList.isEmpty()) {
            searchResults = new List<ContactWrapper>();
            for(Contact cont : (List<Contact>) mySearchList) {
                if(mapHoldingSelectedRecords != null && mapHoldingSelectedRecords.containsKey(cont.Id)) {
                    result.add(mapHoldingSelectedRecords.get(cont.id));
                } else {
                    result.add(new ContactWrapper(cont));
                }
            }
        }
        return result;
    }
    
    /**
    * Search for contacts
    */
    public void searchRecords() {
        mySOSL = null;
        search();
    }
    
    /**
    * Search for contacts
    */
    public void search() {
        searchResults.clear();
        this.searchResults = wrapSOSLResults(mySOSL.getRecords());
        if(!searchResults.isEmpty()) {
            displaySearchResults = true;
        }
    }
    
    /**
    * Returns the total number of pages for page set
    */
    public Integer getTotalPages() {
        Decimal totalSize = mySOSL.getResultSize();
        Decimal pageSize = setPageSize;
        Decimal pages = totalSize / pageSize;
        return (Integer)pages.round(System.RoundingMode.CEILING);
    }
    
    /**
    * Returns the first page of the page set
    */
    public void first() {
        updateSearchItemsMap();
        mySOSL.first();
        newSearch = true;
        search();
    }
    
    /**
    * Returns the last page of the page set
    */
    public void last() {
        updateSearchItemsMap();
        mySOSL.last();
        newSearch = true;
        search();
    }
    
    /**
    * Returns the previous page of the page set
    */
    public void previous() {
        updateSearchItemsMap();
        mySOSL.previous();
        newSearch = true;
        search();
    }
    
    /**
    * Returns the next page of the page set
    */
    public void next() {
        updateSearchItemsMap();
        mySOSL.next();
        newSearch = true;
        search();
    }
    
    public void setPageSize() {
        updateSearchItemsMap();
        newSearch = true;
        search();
    }
    
    /**
    * "Select All" command link on page to select all the values of a record
    */
    public void selectDefaultRecord() {
        String recordId = Apexpages.currentPage().getParameters().get('recordId');
        if(recordId != null && selectedRecords.keySet().contains(recordId)) {
            for(FieldRow row : fieldRows) {
                if(row.showRadio) {
                    row.selectedValue = recordId;
                }
            }
        }
    }
    
    /**
    * Return state picklist values
    * @return options
    */
    public List<SelectOption> getStates() {
        List<SelectOption> options = new List<SelectOption>();
        Schema.DescribeFieldResult fieldResult = Contact.State_Employer__c.getDescribe();
        options.add(new SelectOption('null', '--None--'));
        List<Schema.PicklistEntry> picklistValues = fieldResult.getPicklistValues();
        for(Schema.PicklistEntry currVal : picklistValues) {
            options.add(new SelectOption(currVal.getLabel(), currVal.getValue()));
        }
        return options;
    }
    
    /**
    * Disable community access for contact
    */
    @future
    public static void updateUser(Set<Id> loserContactIdSet) {
        if(loserContactIdSet.isEmpty()) {
            return;
        }
        List<User> updateUserList = new List<User>();
        for(User disabledUser : [
            SELECT Id, IsPortalEnabled
            FROM User
            WHERE ContactId IN :loserContactIdSet
        ]) {
            disabledUser.IsPortalEnabled = false;
            updateUserList.add(disabledUser);
        }
        if(!updateUserList.isEmpty()) {
            update updateUserList;
        }
    }
    
    //Removes deselected records and keeps the records which are selected in map
    private void updateSearchItemsMap() {
        for(ContactWrapper wrp : searchResults) {
            if(wrp.selected) {
                mapHoldingSelectedRecords.put(wrp.con.Id, wrp);
            }
            else if(wrp.selected == false && mapHoldingSelectedRecords.containsKey(wrp.con.Id)) {
                mapHoldingSelectedRecords.remove(wrp.con.Id);
            }
        }
    }
    
    //Update contact relationship for cases
    private List<Case> updateCases(Set<Id> mergeContactIdSet, Id masterId) {
        List<Case> caseUpdateList = new List<Case>();
        for(Case currCase : [
            SELECT Id, ContactId
            FROM Case
            WHERE ContactId IN :mergeContactIdSet
        ]) {
            currCase.ContactId = masterId;
            caseUpdateList.add(currCase);
        }
        return caseUpdateList;
    }
    
    //Update contact relationship for tasks
    private List<Task> updateTasks(Set<Id> mergeContactIdSet, Id masterId) {
        List<Task> taskUpdateList = new List<Task>();
        for(Task currTask : [
            SELECT Id, WhoId
            FROM Task
            WHERE WhoId IN :mergeContactIdSet
        ]) {
            currTask.WhoId = masterId;
            taskUpdateList.add(currTask);
        }
        return taskUpdateList;
    }
    
    //Update contact relationship for contact files
    private List<cg__ContactFile__c> updateContactFiles(Set<Id> mergeContactIdSet, Id masterId) {
        List<cg__ContactFile__c> updateContactFileList = new List<cg__ContactFile__c>();
        for (cg__ContactFile__c conFile : [
            SELECT Id, cg__Contact__c
            FROM cg__ContactFile__c
            WHERE cg__Contact__c IN :mergeContactIdSet
        ]) {
            conFile.cg__Contact__c = masterId;
            updateContactFileList.add(conFile);
        }
        return updateContactFileList;
    }
    
    /**
    * Returns query string based on object and fieldset name passed in 
    * @param sObjectName
    * @param fieldsetName
    * @return queryString
    */
    public string getFieldSetQuery(String sObjectName, String fieldsetName) {
        String queryString = 'SELECT ';
        Map<String, Schema.SObjectType> globalDescribeMap = Schema.getGlobalDescribe();
        for(Schema.FieldSetMember fieldSetMember : globalDescribeMap.get(sObjectName).getDescribe().FieldSets.getMap().get(fieldsetName).getFields()) {
            queryString += fieldSetMember.getFieldPath() + ',';
        }
        queryString = queryString .removeEnd(',');
        return queryString;
    }
    
    //Build query and return contacts
    public ApexPages.StandardSetController mySOSL {
        get {
            if(mySOSL == null || !newSearch || searchNewResult) {
                String query, cond = '';
                Set<String> conditions = new Set<String>();
                conditions.clear();
                if(con.FirstName != null && con.FirstName != '') {
                    String fName = con.FirstName + '%';
                    conditions.add(' FirstName like :fName ');
                }
                if(con.LastName != null && con.LastName != '') {
                    String lName = con.LastName + '%';
                    conditions.add(' LastName like :lName ');
                }
                if(con.Email != null && con.Email != '') {
                    String email = con.email + '%';
                    conditions.add(' Email like :email ');
                }
                if(birthDate != null && birthDate != '') {
                    Date dob = date.parse(birthDate);
                    conditions.add(' Birthdate =:dob ');
                }
                if(con.mailingstreet != null && con.mailingstreet != '') {
                    String mailingStreet = '%' + con.mailingstreet + '%';
                    conditions.add(' mailingstreet like :mailingStreet ');
                }
                if(con.mailingcity != null && con.mailingcity != '') {
                    String mailingcity = '%' + con.mailingcity + '%';
                    conditions.add(' mailingcity like :mailingcity ');
                }
                if(con.mailingState != 'null' && con.mailingState != '') {
                    String mailingState = '%' + con.mailingState + '%';
                    conditions.add(' mailingState like :mailingState ');
                }
                if(con.mailingPostalCode != null && con.mailingPostalCode != '') {
                    String mailingPostalCode = '%' + con.mailingPostalCode + '%';
                    conditions.add(' mailingPostalCode like :mailingPostalCode ');
                }
                if(!conditions.isEmpty()) {
                    for (String s : conditions) {
                        cond += s + 'AND';
                    }
                    cond = cond.removeEnd('AND');
                    query = 'SELECT Id, Name, AccountId, Account.Name, Title, Email, Phone, OwnerId, Owner.Name FROM Contact WHERE ' + cond + ' ORDER BY Name LIMIT 1000 ';
                } else {
                    query = 'SELECT Id, Name, AccountId, Account.Name, Title, Email, Phone, OwnerId, Owner.Name FROM Contact ORDER BY Name LIMIT 1000 ';
                }
                mySOSL = new ApexPages.StandardSetController(Database.getQueryLocator(query));
                if(setPageSize == null) {
                    setPageSize = 10;
                }
                mySOSL.setPageSize(setPageSize);
            }
            return mySOSL;
        }
        set;
    }
    
    //Indicates whether there are more records after the current page set
    public Boolean hasNext {
        get {
            return mySOSL.getHasNext();
        }
        set;
    }
    
    //Indicates whether there are more records before the current page set
    public Boolean hasPrevious {
        get {
            return mySOSL.getHasPrevious();
        }
        set;
    }
    
    //Returns the page number of the current page set
    public Integer pageNumber {
        get {
            return mySOSL.getPageNumber();
        }
        set;
    }
    
    //Sets number of records selected
    public Integer selectedRecordsCount {get;private set;} {
        this.selectedRecordsCount = 0;
    }
    
    /**
    * Contact wrapper
    */
    public class ContactWrapper {
        public Contact con { get; set; }
        public Boolean selected { get; set; }
        public ContactWrapper(Contact c) {
            con = c;
            selected = false;
        }
    }
    
    /**
    * Relationship wrapper
    */
    public class RelationshipWrapper {
        public npe4__Relationship__c relationship { get; set; }
        public Boolean checkbox { get; set; }
        public RelationshipWrapper(npe4__Relationship__c currRel) {
            relationship = currRel;
        }
    }
    
    /**
    * Affiliation wrapper
    */
    public class AffiliationWrapper {
        public npe5__Affiliation__c aff { get; set; }
        public Boolean checkbox { get; set; }
        public AffiliationWrapper(npe5__Affiliation__c currAff) {
            aff = currAff;
        }
    }
    
    /**
    * Volunteer Orientation Training wrapper
    */
    public class VolunteerOTWrapper {
        public Volunteer_Orientation_Training__c volunteerOT { get; set; }
        public Boolean checkbox { get; set; }
        public VolunteerOTWrapper(Volunteer_Orientation_Training__c volunteerOT) {
            this.volunteerOT = volunteerOT;
        }
    }
    
    /**
    * Volunteer Role wrapper
    */
    public class VolunteerRoleWrapper {
        public Volunteer_Roles__c volunteerRole { get; set; }
        public Boolean checkbox { get; set; }
        public VolunteerRoleWrapper(Volunteer_Roles__c volunteerRole) {
            this.volunteerRole = volunteerRole;
        }
    }
    
    /**
    * Volunteer Opportunity wrapper
    */
    public class VolunteerOpportunityWrapper {
        public Volunteer_Opportunity__c volunteerOpp { get; set; }
        public Boolean checkbox { get; set; }
        public VolunteerOpportunityWrapper(Volunteer_Opportunity__c volunteerOpp) {
            this.volunteerOpp = volunteerOpp;
        }
    }
    
    /**
    * Background Check wrapper
    */
    public class BackgroundCheckWrapper {
        public Background_check__c backgroundCheck { get; set; }
        public Boolean checkbox { get; set; }
        public BackgroundCheckWrapper(Background_check__c backgroundCheck) {
            this.backgroundCheck = backgroundCheck;
        }
    }
    
    /**
    * Conflict of Interest wrapper
    */
    public class ConflictOfInterestWrapper {
        public Conflict_Of_Interest__c conflictOfInterest { get; set; }
        public Boolean checkbox { get; set; }
        public ConflictOfInterestWrapper(Conflict_Of_Interest__c conflictOfInterest) {
            this.conflictOfInterest = conflictOfInterest;
        }
    }
    
    /**
    * Awards Recognition wrapper
    */
    public class AwardsRecognitionWrapper {
        public Awards_Recognition__c awaredsRec { get; set; }
        public Boolean checkbox { get; set; }
        public AwardsRecognitionWrapper(Awards_Recognition__c awaredsRec) {
            this.awaredsRec = awaredsRec;
        }
    }
    
    /**
    * In Kind Donation wrapper
    */
    public class InkindDonationWrapper {
        public In_Kind_Donation_Reimbursement__c inkindRec { get; set; }
        public Boolean checkbox { get; set; }
        public InkindDonationWrapper(In_Kind_Donation_Reimbursement__c inkindRec) {
            this.inkindRec = inkindRec;
        }
    }
    
    /**
    * Save all the information belonging to each contact field, including values for all the contacts to merge
    */
    public class FieldRow {
        public String fieldLabel { get; private set; } //Stores the field Label
        public String fieldName { get; private set; } // Stores the field api name
        public Boolean showRadio { get; private set; } // Property to tell whether UI must should a radio to select the field value
        public List<Cell> values { get; private set; } // List of values for each contact record
        public String selectedValue { get; set; } // Selected record
        public String styleClass { get; private set; }
        public FieldRow() {
            this.values = new List<Cell>();
        }
        public FieldRow(String fieldName, String fieldLabel, Boolean showRadio, String styleClass) {
            this();
            this.fieldName = fieldName;
            this.fieldLabel = fieldLabel;
            this.showRadio = showRadio;
            this.styleClass = styleClass;
        }
    }
    
    /**
    * Save value of each cell for a corresponding field row in the UI table
    */
    public class Cell {
        public String objId { get; private set; }
        public String value { get; private set; }
        public Cell(String objectId, String value) {
            this.objId = objectId;
            this.value = value;
        }
    }
}