/**************************************************************************************
Author : MST Solutions
Description : This class referred in the LeadDuplicate_VF. If the users tries to created a duplicate or potentially 
duplicate lead manually in Salesforce, system should not allow them to create/update a lead. It should display 
error message along with duplicate page link. If the user clicks that link, it would redirect the user to 
duplicate page and will display all the duplicate records related with current record. 
Here, User can merge the records.

Modification Log:
1. 03/28/2018 - Yuvraj - IME-59 - LINE NO: 41, 56, 112-114
2. 04/12/2018 - Yuvraj - IME-77 - LINE NO: 531
3 .07/10/2018 - Vignesh SM  - IME 213
4. 09/10/2019 - Manik - WLP-423
5. 01/10/2020 - Brittany - SIW-147
6. 04/24/2020 - Chris Smith - SIW-507 - correct logic to show only fields on merge page that
							are members of the merge_fields fieldset
****************************************************************************************/
public class LeadDuplicate_AC {
	public String currId { get; set; }
	public Lead currLead { get; set; }
	public Integer selectedRecordsCount { get; private set; } {
		this.selectedRecordsCount = 0;
	}
	public List<FieldRow> fieldRows { get; private set; }
	private static final String MASTER_KEY = '$MASTER$';
	public List<leadWrapper> wrapperList = new List<leadWrapper>();
	private Map<String, Lead> selectedRecords;
	public Integer step { get; private set; }
	public Boolean isFamilyInfo { get; set; }
	public String contactId { get; set; }
	public Boolean displayPartASuccess { get; set; }
	public Boolean noDuplicate { get; set; }
	public Boolean noDuplicateBtm { get; set; }
	public String masterLeadId;
	public Boolean displayLeadDupPopup { get; set; }
	public String additionalParentId { get; set; }
	public String render { get; set; }
	private final Id wishFamilyRT = Constant_AC.WISH_FAMILY_RT_ID;
	public Boolean hideTreatingSection { get; set; }
	public Boolean paperDVProcess { get; set; }
	public List<Lead> masterLeadList { get; set; }
	public Boolean displayModalWarning { get; set; }
	public Boolean displayMergeWarning { get; set; }
	public Boolean displayQualifiedWarning { get; set; }
	public String warningMsg { get; set; }

	/**
	 * Standard set controller for displaying matching duplicates
	 * @param controller
	 */
	public LeadDuplicate_AC(ApexPages.StandardSetController controller) {
		selectedRecords = new Map<String, Lead>();
		fieldRows = new List<FieldRow>();
		step = 2;
		isFamilyInfo = false;
		noDuplicate = false;
		noDuplicateBtm = false;
		displayLeadDupPopup = false;
		hideTreatingSection = false;
		paperDVProcess = false;
		displayModalWarning = false;
		displayMergeWarning = false;
		displayQualifiedWarning = false;
		warningMsg = '';
		if (ApexPages.currentPage().getParameters().get('wishFamily') != null) {
			isFamilyInfo = Boolean.valueOf(ApexPages.currentPage().getParameters().get('wishFamily'));
		}
		if (ApexPages.currentPage().getParameters().get('Id') != null) {
			currId = ApexPages.currentPage().getParameters().get('Id');
		}
		if (currId != null) {
			currLead = findLead(currId);
			masterLeadList = new List<Lead>();
			masterLeadList.add(currLead);
		} else {
			currLead = new Lead();
		}
		if (currLead.Id != null) {
			if (currLead.Using_Paper_Process_For_DV__c) {
				paperDVProcess = true;
			}
		}
	}

	/**
	 * Fetching all duplicate lead records related with current lead id.
	 * @return List of Lead Wrapper
	 */
	public List<leadWrapper> getdupLeadList() {
		List<Lead> dupLeads = new List<Lead>();
		if (currLead.Id != null) {
			dupLeads = LeadService.findLeadDuplicates(currLead.FirstName, currLead.LastName, currLead.Phone,
					currLead.Email, currLead.Street, currLead.City, currLead.State, currLead.PostalCode, currLead.DOB__c,
					new List<Id>{
							masterLeadList[0].Id
					});
		}
		if (wrapperList.isEmpty()) {
			if (!dupLeads.isEmpty()) {
				for (Lead currDup : dupLeads) {
					leadWrapper newWrapper = new leadWrapper(currDup);
					wrapperList.add(newWrapper);
				}
			}
		}
		return wrapperList;
	}

	/**
	 * Fetching Duplicate Wish Child based on the current lead.
	 * @return List of Contacts
	 */
	public List<Contact> getdupContactList() {
		List<Contact> dupContacts = new List<Contact>();
		if (currLead.Id != null) {
			dupContacts = ContactService.findChildDuplicatedContacts(
					currLead.FirstName, currLead.LastName,
					currLead.Phone, currLead.Email, currLead.Street,
					currLead.City, currLead.State, currLead.PostalCode, currLead.DOB__c,
					new List<Id>{
							wishFamilyRT
					}
			);
		}
		return dupContacts;
	}

	/**
	 * Querying duplicate Wish Family based on the current lead
	 * @return List of Contacts
	 */
	public List<Contact> getdupParentContactList() {
		List<Contact> dupContacts = new List<Contact>();
		if (currLead.Id != null) {
			dupContacts = ContactService.findFamilyDuplicatedContacts(
					currLead.Parent_First_Name__c, currLead.Parent_Last_Name__c,
					currLead.Phone, currLead.Email, currLead.Street,
					currLead.City, currLead.State, currLead.PostalCode,
					new List<Id>{
							wishFamilyRT
					}
			);
		}
		return dupContacts;
	}

	/**
	 * Querying duplicate Additional Wish Family based on the current lead
	 * @return List of Contacts
	 */
	public List<Contact> getAdditionalParentContactList() {
		List<Contact> dupContacts = new List<Contact>();
		if (currLead.Id != null) {
			dupContacts = ContactService.findFamilyDuplicatedContacts(
					currLead.Additional_Parent_First_Name__c, currLead.Additional_Parent_Last_Name__c,
					currLead.Additional_Parent_Phone__c, currLead.Additional_Parent_Email__c,
					currLead.Additional_Parent_Street__c, currLead.Additional_Parent_City__c,
					currLead.Additional_Parent_State__c, currLead.Additional_Parent_Postal_Code__c,
					new List<Id>{
							wishFamilyRT
					}
			);
		}
		return dupContacts;
	}

	/**
	 * Mark the Master record by default for merging. If user want to change, then can change it using radio button
	 */
	public void selectDefaultRecord() {
		String recordId = ApexPages.currentPage().getParameters().get('recordId');
		if (recordId != null && selectedRecords.keySet().contains(recordId)) {
			for (FieldRow row : fieldRows) {
				if (row.showRadio) {
					row.selectedValue = recordId;
				}
			}
		}
	}

	/**
	 * Its redirect the user to Merge page once they choosen duplicates.
	 * If user checks no duplicate checkbox, then it will update the record as
	 * No Duplicate Found and allowed as a duplicate record.
	 * @return Page Reference
	 */
	public PageReference nextStep() {
		Set<Id> mergeIds = new Set<Id>();
		String LogValue;
		String recId;
		try {
			for (leadWrapper c : wrapperList) {
				if (c.selected) {
					mergeIds.add(c.currentLead.Id);
				}
			}
			if ((noDuplicate == true || noDuplicateBtm == true) && !mergeIds.isEmpty()) {
				ApexPages.addMessage(new ApexPages.Message(
						ApexPages.Severity.ERROR, Label.Duplicate_Lead_Message_1));
				return null;
			} else if (noDuplicate == true || noDuplicateBtm == true) {
				Lead updateLead = new Lead();
				updateLead.Id = currLead.Id;
				updateLead.Override_Dupe_Check__c = true;
				updateLead.Dup_Check__c = Constant_AC.LEAD_DUP_CHECK_BLOCK_LEAD_DUP;
				update updateLead;
				PageReference reference = new PageReference('/' + currLead.Id);
				reference.setRedirect(true);
				return reference;
			} else {
				mergeIds.add(masterLeadList[0].Id);
				loadMergeCandidates(mergeIds);
			}
		} catch (Exception ex) {
			LogValue = String.valueOf(currLead);
			recId = ApexPages.currentPage().getParameters().get('Id');
			new ApexDebugLog().createLog(new ApexDebugLog.Error('LeadDuplicate_AC', 'nextStep', recId, ex, LogValue));
			ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, Label.Debug_log_error_message);
			ApexPages.addMessage(myMsg);
		}
		return null;
	}

	/**
	 * Submitting for Diagnosis Verification.
	 * @return Page Reference
	 */
	public PageReference ContinuePartAForm() {
		String LogValue;
		String recId;
		try {
			Lead updateLead = new Lead();
			updateLead.Id = currLead.Id;
			updateLead.Sub_Status__c = Constant_AC.LEAD_SUB_STATUS_PENDING_DIAGNOSIS_VERIFICATION;
			updateLead.Pending_Diagnosis_Date__c = Date.today();
			updateLead.Override_Dupe_Check__c = true;
			updateLead.Wish_Family_ContactId__c = contactId;
			updateLead.Hidden_Additional_Parent_Id__c = additionalParentId;
			updateLead.Contact_Dup_Check__c = Constant_AC.LEAD_DUP_CHECK_BLOCK_CONTACT_DUP;
			updateLead.Dup_Check__c = Constant_AC.LEAD_DUP_CHECK_BLOCK_LEAD_DUP;
			update updateLead;
			PageReference reference = new PageReference('/apex/LeadSelectMedEmail_VF?id=' + currLead.Id);
			reference.setRedirect(true);
			return reference;
		} catch (Exception ex) {
			LogValue = String.valueOf(currLead);
			recId = ApexPages.currentPage().getParameters().get('Id');
			new ApexDebugLog().createLog(new ApexDebugLog.Error('LeadDuplicate_AC',
					'ContinuePartAForm', recId, ex, LogValue));
			ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, Label.Debug_log_error_message);
			ApexPages.addMessage(myMsg);
		}
		return null;
	}

	/**
	 * Completing dupcheck
	 * @return Page Reference
	 */
	public PageReference CompleteDupeCheck() {
		String LogValue;
		String recId;
		try {
			render = 'frm';
			Lead updateLead = new Lead();
			updateLead.Id = currLead.Id;
			updateLead.Override_Dupe_Check__c = true;
			updateLead.Wish_Family_ContactId__c = contactId;
			updateLead.Hidden_Additional_Parent_Id__c = additionalParentId;
			updateLead.Contact_Dup_Check__c = Constant_AC.LEAD_DUP_CHECK_BLOCK_CONTACT_DUP;
			updateLead.Dup_Check__c = Constant_AC.LEAD_DUP_CHECK_BLOCK_LEAD_DUP;
			update updateLead;
			PageReference reference = new PageReference('/' + currLead.Id);
			reference.setRedirect(true);
			return reference;
		} catch (Exception ex) {
			render = 'msg';
			LogValue = String.valueOf(currLead);
			recId = ApexPages.currentPage().getParameters().get('Id');
			new ApexDebugLog().createLog(new ApexDebugLog.Error('LeadDuplicate_AC', 'CompleteDupeCheck', recId, ex, LogValue));
			ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, Label.Debug_log_error_message);
			ApexPages.addMessage(myMsg);
			return null;
		}
	}

	/**
	 * Redirecting to Lead Detail page
	 * @return Page Reference
	 */
	public PageReference GoToLeadViewPage() {
		displayPartASuccess = false;
		PageReference reference = new PageReference('/' + currLead.Id);
		reference.setRedirect(true);
		return reference;
	}

	/**
	 * Merge Contacts
	 * @return Page Reference
	 */
	public PageReference mergeContacts() {
		SObject master;
		String LogValue;
		String recId;
		// Find the master record based the selected value of the Master FieldRow
		try {
			for (FieldRow row : fieldRows) {
				if (row.showRadio && row.fieldName.equals(MASTER_KEY)) {
					master = new Lead(Id = row.selectedValue, Override_Dupe_Check__c = true);
					break;
				}
			}
			if (master != null) {
				// Update the field values of master record based on the selected value for each field.
				for (FieldRow row : fieldRows) {
					if (row.showRadio && !row.fieldName.equals(MASTER_KEY) && row.selectedValue != master.Id) {
						SObject selectedRecord = this.selectedRecords.get(row.selectedValue);
						// Sobject.put is not happy when sobject.get returns null.
						// It throws an exception System.SObjectException: Illegal assignment from Object to String.
						// But instead when you pass a null directly to put, it works fine. And hence, this if statement.
						if (selectedRecord.get(row.fieldName) == null) {
							master.put(row.fieldName, null);
						} else {
							Object val = selectedRecord.get(row.fieldName);
							master.put(row.fieldName, val);
						}
					}
				}
				// Group all the loosing records separately.
				List<Lead> losers = new List<Lead>();
				Set<Id> loserIdSet = new Set<Id>();
				for (Lead c : this.selectedRecords.values()) {
					if (c.Id != master.Id) {
						c.Override_Dupe_Check__c = true;
						losers.add(c);
						loserIdSet.add(c.Id);
					}
				}
				List<cg__Lead_File__c> leadFileList = new List<cg__Lead_File__c>();
				for (cg__Lead_File__c currRec : [
						SELECT Id, cg__Lead__c
						FROM cg__Lead_File__c
						WHERE cg__Lead__c IN :loserIdSet
				]) {
					currRec.cg__Lead__c = master.Id;
					leadFileList.add(currRec);
				}
				if (!leadFileList.isEmpty()) {
					update leadFileList;
				}
				// Before proceeding further first lock the records for change
				List<Lead> allContacts = new List<Lead>();
				allContacts.add((Lead) master);
				allContacts.addAll(losers);
				List<Lead> lock = [
						SELECT Id
						FROM Lead
						WHERE Id IN :allContacts
						AND RecordTypeId = :Constant_AC.LEAD_RT_WISH_CHILD
						FOR UPDATE
				];
				if (lock == null || lock.size() != allContacts.size()) {
					ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,
							Label.npe01.Contact_Merge_Error_Lock_failed
									+ ' ' + Label.npe01.Contact_Merge_Error_please_retry));
					return null;
				}
				System.Savepoint sp;
				if (!Test.isRunningTest()) {
					sp = Database.setSavepoint();
				}
				try {
					Database.DMLOptions dml = new Database.DMLOptions();
					dml.duplicateRuleHeader.allowSave = true;
					Database.SaveResult sr;
					if (!Test.isRunningTest()) {
						sr = Database.update(master, dml);
					}
					if (!sr.isSuccess()) {
						String strErr = Label.npe01.Contact_Merge_Error_Merge_Failed + ' Error: ';
						for (Database.Error err : sr.getErrors()) {
							strErr += err.getMessage() + '\n';
						}
						if (!Test.isRunningTest()) {
							Database.rollback(sp);
						}
						ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, strErr));
						return null;
					}
					LeadService.mergeLeads((Lead) master, losers);
					masterLeadId = master.Id;
					Lead currLead = [
							SELECT Id,FirstName, Name, LastName, Email, Phone,
									City, DOB__c,State, PostalCode, Street,
									ChapterName__r.Name, ChapterName__c
							FROM Lead
							WHERE Id = :master.Id
							AND RecordTypeId = :Constant_AC.LEAD_RT_WISH_CHILD
					];
					// Checking duplicates again.
					List<Lead> duplicateLeadList = LeadService.findLeadDuplicatesWithChapter(
							currLead.FirstName, currLead.LastName, currLead.Phone, currLead.Email,
							currLead.Street, currLead.City, currLead.State, currLead.PostalCode,
							currLead.DOB__c, new List<Id>{
									currLead.Id
							}, currLead.ChapterName__c
					);
					if (!duplicateLeadList.isEmpty()) {
						displayLeadDupPopup = true;
						render = 'mergeForm';
					} else {
						Lead updateLead = new Lead();
						updateLead.Id = masterLeadId;
						updateLead.Dup_Check__c = Constant_AC.LEAD_DUP_CHECK_BLOCK_LEAD_DUP;
						update updateLead;
						render = 'mergeForm';
						return new PageReference('/' + updateLead.Id);
					}
					// update the master with the selected values
				} catch (Exception e) {
					Database.rollback(sp);
					render = 'msg';
					ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,
							Label.npe01.Contact_Merge_Error_Merge_Failed + ' Error: ' + e));
				}
			} else {
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,
						Label.npe01.Contact_Merge_Error_No_Master));
			}
		} catch (Exception ex) {
			LogValue = String.valueOf(currLead);
			render = 'msg';
			recId = ApexPages.currentPage().getParameters().get('Id');
			new ApexDebugLog().createLog(new ApexDebugLog.Error('LeadDuplicate_AC', 'mergeContacts', recId, ex, LogValue));
			ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, Label.Debug_log_error_message);
			ApexPages.addMessage(myMsg);
		}
		return null;
	}

	/**
	 * Continue Merging Lead
	 * @return PageReference
	 */
	public PageReference isYes() {
		PageReference pr = new PageReference('/apex/LeadDuplicate_VF?id=' + masterLeadId);
		pr.setRedirect(true);
		return pr;
	}

	/**
	 * Stop Merging Lead
	 * @return PageReference
	 */
	public PageReference isNo() {
		String LogValue;
		String recId;
		try {
			Lead updateLead = new Lead();
			updateLead.Id = masterLeadId;
			updateLead.Dup_Check__c = Constant_AC.LEAD_DUP_CHECK_BLOCK_LEAD_DUP;
			update updateLead;
			return new PageReference('/' + updateLead.Id);
		} catch (Exception ex) {
			LogValue = String.valueOf(currLead);
			recId = ApexPages.currentPage().getParameters().get('Id');
			new ApexDebugLog().createLog(new ApexDebugLog.Error('LeadDuplicate_AC', 'isNo', recId, ex, LogValue));
			ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, Label.Debug_log_error_message);
			ApexPages.addMessage(myMsg);
			return null;
		}
	}

	/**
	 * Get Merge Fields
	 * @return List of FieldSetMember
	 */
	public List<Schema.FieldSetMember> getMergeFields() {
		return SObjectType.Lead.fieldSets.Merge_Fields.getFields();
	}

	/**
	 * Shows the next step of the wizard where user can see the diff of the records before merge.
	 * @param mergeCandidates
	 */
	@TestVisible
	private void loadMergeCandidates(Set<Id> mergeCandidates) {
		String LogValue;
		String recId;
		Boolean preventMerge = false;
		try {
			Boolean flag = true;
			// Check we have atleast 2 and not more than 3 records selected for merge. If not throw an error.
			if (mergeCandidates.size() <= 1) {
				flag = false;
				ApexPages.addMessage(new ApexPages.Message(
						ApexPages.Severity.ERROR, Label.Duplicate_Lead_Message_2));
				return;
			}
			if (mergeCandidates.size() > 3) {
				flag = false;
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,
						Label.Duplicate_Lead_Message_3));
				return;
			}
			if (flag == true) {
				selectedRecordsCount = mergeCandidates.size();
				Set<String> fieldsSet = new Set<String>();
				for (Schema.FieldSetMember f : getMergeFields()) {
					fieldsSet.add((f.getFieldPath()).toLowerCase());
				}
				Map<String, Schema.SObjectField> leadFields = Schema.SObjectType.Lead.fields.getMap();
				Map<String, Schema.DescribeFieldResult> standardFieldMap = new Map<String, Schema.DescribeFieldResult>();
				Map<String, Schema.DescribeFieldResult> customFieldMap = new Map<String, Schema.DescribeFieldResult>();
				// Construct the query string
				String query = 'Select id, name, ';
				for (String fieldName : leadFields.keySet()) {
					Schema.SObjectField f = leadFields.get(fieldName);
					Schema.DescribeFieldResult fResult = f.getDescribe();
					// Only include the fields which are updateable and accessible
					if (fResult.isUpdateable() && fResult.isAccessible()) {
						// If the field is type lookup, select the parent name
						String relName = fResult.getRelationshipName();
						if (String.isBlank(relName)) {
							query += (fieldName + ',');
						} else {
							// Find the Name field for the related object
							String nameField = getRelatedObjNameField(fResult);
							if (nameField != null) {
								query += (relName + '.' + nameField + ',');
							}
						}
						// Collect the standard and custom fields separately for sorting
						// Only include fields that are in fieldset.
						if (fieldsSet.contains(fieldName)) {
							if (fResult.isCustom()) {
								customFieldMap.put(fieldName, fResult);
							} else {
								standardFieldMap.put(fieldName, fResult);
							}
						}
					}
				}
				// Adding some non-updateable system fields which we need to add to the record diff table.
				query += 'createdby.name, createddate, LastModifiedBy.name, LastModifiedDate';
				//Store Record Type ID locally to provide proper scope for Database.query()
				String localWishRTid = Constant_AC.LEAD_RT_WISH_CHILD;
				// Finally completing the query by appending the table name and the filter clause
				query += ' from Lead where id IN :mergeCandidates and RecordTypeId = :localWishRTid';
				List<Lead> leads;
				try {
					leads = Database.query(query); // Query the records
					// Ensure we got back the same number of records as expected. In case any record got deleted/moved since last search.
					if (leads == null || leads.size() != mergeCandidates.size()) {
						ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,
								Label.npe01.Contact_Merge_Error_Query_Failed
										+ ' ' + Label.npe01.Contact_Merge_Error_please_retry));
						return;
					}
				} catch (Exception e) {
					ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,
							Label.npe01.Contact_Merge_Error_Contact_not_found + ' Error: ' + e));
					if (!Test.isRunningTest()) {
						return;
					}
				}
				// Update the list of searched records with only the ones selected
				wrapperList.clear();
				for (Lead c : leads) {
					this.selectedRecords.put(c.Id, c);
					if (c.Status == Constant_AC.LEAD_STATUS_QUALIFIED) {
						preventMerge = true;
					}
				}
				// Sort the standard fields list by name before creating the list of FieldRow for merge UI
				List<String> standardFieldList = new List<String>();
				standardFieldList.addAll(standardFieldMap.keySet());
				standardFieldList.sort();
				// Sort the custom fields list by name before creating the list of FieldRow for merge UI
				List<String> customFieldList = new List<String>();
				customFieldList.addAll(customFieldMap.keySet());
				customFieldList.sort();

				// Add the first row of type header with contact names as titles
				FieldRow temp = new FieldRow('', '', false, 'header');
				for (SObject c : leads) {
					Lead leadRec = (Lead) c;
					temp.values.add(new Cell(leadRec.Id, leadRec.Name));
				}
				fieldRows.add(temp);

				// Add second row to select the master record. Select the one which is last modified
				temp = new FieldRow(MASTER_KEY, 'Master Record', true, null);
				{
					Datetime lastModifiedDate;
					for (SObject c : leads) {
						temp.values.add(new Cell(c.Id, null));
						if (lastModifiedDate == null ||
								(lastModifiedDate != null && (Datetime) c.get('lastModifiedDate') > lastModifiedDate)) {
							temp.selectedValue = c.Id;
							lastModifiedDate = (Datetime) c.get('lastModifiedDate');
						}
					}
				}
				fieldRows.add(temp);

				// Add a dummy row to add a 'Standard Fields' header before the list of standard fields
				fieldRows.add(new FieldRow('Standard Fields', 'Standard Fields', false, 'separator'));

				// Add all standard fields to the list of FieldRow in sorted manner
				for (String fieldName : standardFieldList) {
					addFieldComparisonRows(fieldName, standardFieldMap.get(fieldName), leads);
				}

				// Add a dummy row to add a 'Custom Fields' header before the list of custom fields
				fieldRows.add(new FieldRow('Custom Fields', 'Custom Fields', false, 'separator'));

				// Add all custom fields to the list of FieldRow in sorted manner
				for (String fieldName : customFieldList) {
					addFieldComparisonRows(fieldName, customFieldMap.get(fieldName), leads);
				}

				// Add a dummy row to add a 'System Fields' header before the list of system fields
				fieldRows.add(new FieldRow('System Fields', 'System Fields', false, 'separator'));

				// Add created by and last modified by system fields to the list of FieldRow
				FieldRow createdByRow = new FieldRow('CreatedById', 'Created By', false, null),
						lastModifiedByRow = new FieldRow('LastModifiedById', 'Last Modified By', false, null);
				for (SObject c : leads) {
					SObject createdBy = c.getSObject('createdby');
					SObject modifiedBy = c.getSObject('lastModifiedBy');
					createdByRow.values.add(new Cell(c.Id, (createdBy != null ? createdBy.get('name') : '') + ' ' + c.get('createdDate')));
					lastModifiedByRow.values.add(new Cell(c.Id, (modifiedBy != null ? modifiedBy.get('name') : '') + ' ' + c.get('LastModifiedDate')));
				}
				fieldRows.add(createdByRow);
				fieldRows.add(lastModifiedByRow);
				// If everything looks good go to "choose winning contact" step
				this.step = 3;
				// If any selected lead is Qualified display error
				if (preventMerge == true) {
					warningMsg = Label.Duplicate_Lead_Merge_Restrict;
					displayQualifiedWarning = true;
					displayModalWarning = true;
				}
			}
		} catch (Exception ex) {
			LogValue = String.valueOf(currLead);
			recId = ApexPages.currentPage().getParameters().get('Id');
			new ApexDebugLog().createLog(new ApexDebugLog.Error('LeadDuplicate_AC', 'loadMergeCandidates', recId, ex, LogValue));
			ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, Label.Debug_log_error_message);
			ApexPages.addMessage(myMsg);

		}
	}

	/**
	* Show warning message to user when Merge button is clicked
	*/
	public void showModalWarning() {
		warningMsg = Label.Duplicate_Lead_Merge_Warning;
		displayMergeWarning = true;
		displayModalWarning = true;
	}

	/**
	* Close modal warning message
	*/
	public void closeModalWarning() {
		displayModalWarning = false;
	}

	/**
	* Return to original lead record
	*/
	public PageReference returnToLead() {
		return new PageReference('/' + currLead.Id);
	}

	/**
	 * @param fieldDesc
	 * @return
	 */
	private String getRelatedObjNameField(Schema.DescribeFieldResult fieldDesc) {
		String nameField = 'Name';
		Map<String, Schema.SObjectField> mapRelatedObjectFields = fieldDesc.getReferenceTo()[0].getDescribe().fields.getMap();
		//if Name isn't the correct name field, find it
		if (!mapRelatedObjectFields.containsKey(nameField)) {
			nameField = null;
			for (String relatedFieldName : mapRelatedObjectFields.keySet()) {
				if (mapRelatedObjectFields.get(relatedFieldName).getDescribe().isNameField()) {
					return relatedFieldName;
				}
			}
		}
		return nameField;
	}

	/**
	 * Add Field Comparison Rows
	 * @param fieldName
	 * @param fieldDesc
	 * @param objs
	 */
	private void addFieldComparisonRows(String fieldName, Schema.DescribeFieldResult fieldDesc, List<SObject> objs) {
		// Create a new FieldRow item
		String LogValue;
		String recId;
		try {
			FieldRow row = new FieldRow();
			row.fieldName = fieldName;
			// For standrd lookup type fields, use the relationship name as the field label
			if (!fieldDesc.isCustom() && fieldDesc.getRelationshipName() != null) {
				row.fieldLabel = fieldDesc.getRelationshipName();
			} else {
				row.fieldLabel = fieldDesc.getLabel();
			}
			row.values = new List<Cell>();
			// flag to indicate whether at least one pair of field values is different across all contacts
			Boolean isDifferent = false;
			// flag to indicate whether all the field values are null
			Boolean isnull = true;
			Integer idx = 0;
			List<String> values = new List<String>();
			Datetime lastModifiedDate = null;
			String prev;
			// Iterate over all contacts to find the field values and add them to row values
			for (SObject c : objs) {
				// For lookup fields set the name as the values
				if (fieldDesc.getRelationshipName() != null) {
					SObject obj = c.getSObject(fieldDesc.getRelationshipName());
					if (obj != null) {
						values.add(String.valueOf(obj.get(getRelatedObjNameField(fieldDesc))));
					} else {
						values.add(null);
					}
				} else {
					if (fieldName != 'DOB__c') {
						values.add(String.valueOf(c.get(fieldName)));
					} else {
						if (!String.isBlank(String.valueOf(c.get(fieldName)))) {
							Date dt = Date.valueOf(c.get(fieldName));
							values.add(dt.month() + '/' + dt.day() + '/' + dt.year());
						}
					}
				}
				isnull &= (c.get(fieldName) == null); // Check if the value is null
				if (idx == 0) {
					prev = String.valueOf(c.get(fieldName));
				}
				if (idx > 0 && !isnull) {
					// Check if atleast one of the values is different. If yes then update the isDifferent flag
					String current = String.valueOf(c.get(fieldName));
					if ((prev != null && !prev.equals(current)) ||
							(current != null && !current.equals(prev))) {
						isDifferent = true;
					}
					prev = current;
				}
				// Select the default value for the field. A non-null value on the latest modified record
				if (c.get(fieldName) != null && (lastModifiedDate == null ||
						(lastModifiedDate != null && (Datetime) c.get('lastModifiedDate') > lastModifiedDate))) {
					row.selectedValue = c.Id;
					lastModifiedDate = (Datetime) c.get('lastModifiedDate');
				}
				idx++;
			}

			// If atleast one record has a non-null field value, then add it to the list of fieldRows.
			if (!isnull) {
				for (Integer i = 0; i < values.size(); i++) {
					String val = values[i];
					if (val != null && val.length() > 255) {
						val = val.substring(0, 251) + ' ...';
					}
					row.values.add(new Cell(objs[i].Id, val));
				}
				// Show the select radio only if the field values are different.
				// Dont let user choose the account as you dont want users to assign a differnt account in One to One case.
				row.showRadio = (isDifferent && !fieldName.equalsIgnoreCase('accountId'));
				fieldRows.add(row);
			}
		} catch (Exception ex) {
			LogValue = String.valueOf(currLead);
			recId = ApexPages.currentPage().getParameters().get('Id');
			new ApexDebugLog().createLog(new ApexDebugLog.Error('LeadDuplicate_AC', 'addFieldComparisonRows', recId, ex, LogValue));
			ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, Label.Debug_log_error_message);
			ApexPages.addMessage(myMsg);
		}
	}

	private static Lead findLead(Id leadId) {
		return [
				SELECT Id, FirstName,Name,Of_Times_Email_Sent__c, Hidden_DV_form_Medical_professional_Type__c,
						LastName,Parent_Last_Name__c,Parent_First_Name__c, Email, DOB__c,Phone,
						ChapterName__c,ChapterName__r.Name, City, State, Street, PostalCode, Medical_Professional_First_Name__c,
						Medical_Professional_Last_Name__c, Medical_Professional_Phone__c,
						Medical_Professional_Email__c,Additional_Parent_City__c,Additional_Parent_Email__c,
						Additional_Parent_First_Name__c,
						Additional_Parent_Last_Name__c,Additional_Parent_Phone__c,Additional_Parent_Postal_Code__c,
						Additional_Parent_State__c,Additional_Parent_Street__c, Using_Paper_Process_For_DV__c
				FROM Lead
				WHERE Id = :leadId
				AND RecordTypeId = :Constant_AC.LEAD_RT_WISH_CHILD
		];
	}

	/**
	 *  Cell Wrapper class
	 */
	public class Cell {
		public String objId { get; private set; }
		public String value { get; private set; }
		public Cell(String objectId, String value) {
			this.objId = objectId;
			this.value = value;
		}
	}

	/**
	 *  Lead Wrapper class
	 */
	public class leadWrapper {
		public Lead currentLead { get; set; }
		public Boolean selected { get; set; }
		public leadWrapper(Lead currLead) {
			currentLead = currLead;
			selected = false;
		}
	}

	/**
	 *  Wrapper class for displaying selected records for merge with radio button
	 */
	public class FieldRow {
		public String fieldLabel { get; private set; }
		public String fieldName { get; private set; }
		public Boolean showRadio { get; private set; }
		public List<Cell> values { get; private set; }
		public String selectedValue { get; set; }
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
}