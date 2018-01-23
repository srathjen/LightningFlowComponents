/* Created By : MST Solutions
Description:This Class is used to Merge the two contact and add the related list based on the user selection */
public  class ContactMergeController_AC {
    
    Public Contact con{get;set;}
    public  Set<Id> conIdList = new Set<Id>(); 
    public List<AffiliationWrapper> Affiliations {get;set;}
    public List<relationshipWrapper> relationshipList{get;set;}
    public List<VolunteerOTWrapper> volunteerOTList{get;set;}
    public List<VolunteerRoleWrapper> volunteerRoleList{get;set;}
    public List<VolunteerOpportunityWrapper> volunteerOppList{get;set;}
    public List<BackgroundCheckWrapper> backgroundcheckList{get;set;}
    public List<ConflictOfInterestWrapper> conflictofInterestList{get;set;}
    public List<AwardsRecognitionWrapper> awardsRecognitionList{get;set;}
    public List<InkindDonationWrapper> inkindDonationList{get;set;}
    private integer list_size=20; //sets the page size or number of rows
    private integer counter=0;  //keeps track of the offset
    Public Integer size{get;set;}
    Public Integer noOfRecords{get; set;}
    public List<SelectOption> paginationSizeOptions{get;set;}
    public static final Integer QUERY_LIMIT = 10000;
    public Integer setPageSize {get;set;}
    public Boolean newSearch;
    public Boolean searchNewResult;
    public String birthDate{get;set;}
    
    //list of contactWrapper objects for display in search results pane
    public List<ContactWrapper> searchResults {get; private set;}
    Map<Id, ContactWrapper> mapHoldingSelectedRecords{get;set;}
    
    public ContactMergeController_AC(ApexPages.StandardController controller) {
        Affiliations=new List<AffiliationWrapper>();
        relationshipList=new List<relationshipWrapper>();
        volunteerOTList=new List<VolunteerOTWrapper>();
        volunteerRoleList=new List<VolunteerRoleWrapper>();
        volunteerOppList=new List<VolunteerOpportunityWrapper>();
        backgroundcheckList=new List<BackgroundCheckWrapper>();
        conflictofInterestList=new List<ConflictOfInterestWrapper>();
        awardsRecognitionList=new  List<AwardsRecognitionWrapper>();
        inkindDonationList=new List<InkindDonationWrapper>();
        con = new Contact();
        searchText='';
        searchResults = new List<contactWrapper>();
        selectedRecords = new Map<String, Contact>();
        displaySearchResults = false;
        step = 1;
        fieldRows = new List<FieldRow>();
        mapHoldingSelectedRecords = new Map<Id, contactWrapper>();
        setPageSize =10;
        newSearch=False;
        searchNewResult = False; 
        
    }
    //Capturing State Picklist values.   
    public List<SelectOption> getStates() {
        List<SelectOption> options = new List<SelectOption>();
        Schema.DescribeFieldResult fieldResult =  Contact.State_Employer__c.getDescribe();
        options.add(new SelectOption('Null', '--None--')); 
        List<Schema.PicklistEntry> picklistValues = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry currVal : picklistValues){
            options.add(new SelectOption(currVal.getLabel(), currVal.getValue())); 
            
        }  
        return options;
    }
    
    
    public ContactMergeController_AC(){
        
    }
    
    private static final String MASTER_KEY = '$MASTER$';
    
    public boolean displaySearchResults {get; set;} 
    
    //string of search text entered by user
    public String searchText { get { return searchText; } set { searchText = value; } }
    
    
    
    
    //list of contactWrapper objects for display in search results pane
    public Map<String, Contact> selectedRecords;
    
    public Integer selectedRecordsCount {get; private set;} {this.selectedRecordsCount = 0;}
    
    //max number of Contacts returned by a query
    private final Integer SOSL_LIMIT = 20;
    
    public Integer step {get; private set;}
    
    //class to hold a contact and checkbox so we can select each contact
    public class contactWrapper {
        //the contact
        public Contact con {get; set;}
        //the checkbox variable
        public Boolean selected {get; set;}
        
        //constructor for contactWrapper class
        public contactWrapper(Contact c) {
            con = c;
            selected = false;
        }
    }
    
    public List<FieldRow> fieldRows {get; private set;}
    
    /**
* The struct to save all the information belonging to each contact field, including values for all the contacts to merge.
*/
    public class FieldRow {
        public String fieldLabel {get;  private set;} //Stores the field Label
        public String fieldName {get;   private set;} // Stores the field api name
        public boolean showRadio {get;  private set;} // Property to tell whether UI must should a radio to select the field value
        public List<Cell> values {get;  private set;} // List of values for each contact record
        public String selectedValue {get; set;} // Selected record
        public String styleClass {get;  private set;}
        
        public FieldRow() {
            this.values = new List<Cell>();
        }
        public FieldRow(String fieldName, String fieldLabel, boolean showRadio, String styleClass) {
            this();
            this.fieldName = fieldName;
            this.fieldLabel = fieldLabel;
            this.showRadio = showRadio;
            this.styleClass = styleClass;
        }
    }
    
    /**
* The struct to save value of each cell for a corresponding field row in the UI table.
*/
    public class Cell {
        public String objId {get; private set;} // Id of the record to which this value belongs.
        public String value {get; private set;} // Actual value
        
        public Cell (String objectId, String value) {
            this.objId = objectId;
            this.value = value;
        }
    }
    
    // This is an action method for the "Select All" command link on the page to select all the values of a certain record.
    public void selectDefaultRecord() {
        String recordId = Apexpages.currentPage().getParameters().get('recordId');
        System.debug('Selected Record: ' + recordId);
        if (recordId != null && selectedRecords.keySet().contains(recordId)) {
            for (FieldRow row : fieldRows) {
                if (row.showRadio) {
                    row.selectedValue = recordId; 
                }
            }
        }
    }
    
    // Action method to show the next step of the wizard where user can see the diff of the records before merge
    public void nextStep() {
        
        String contactIdFilter = ''; // String to create a list of contact Ids to query
        this.selectedRecordsCount = 0;
        updateSearchItemsMap();
        if(mapHoldingSelectedRecords.Size() > 0){
            for (ContactWrapper c : mapHoldingSelectedRecords.Values()) {
                if (c.selected == True) {
                    contactIdFilter += ('\'' + c.con.Id + '\',');
                    this.selectedRecordsCount++;
                    conIdList.add(c.con.Id);
                }
            }
        }
        else{
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Please select maximum of 2 contacts to merge.'));
            return;
        }
        
        contactIdFilter = contactIdFilter.substring(0, contactIdFilter.length() - 1);
        // Check we have atleast 2 records selected for merge. If not throw an error. 
        if (this.selectedRecordsCount != 2) {
            //searchResults.Clear();
            displaySearchResults=True;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Please select maximum of 2 contacts to merge.'));
            return;
        }
        
        
        Map<String, Schema.SObjectField> contactFields = Schema.SObjectType.Contact.fields.getMap();
        Map<String, Schema.DescribeFieldResult> standardFieldMap = new Map<String, Schema.DescribeFieldResult>();
        Map<String, Schema.DescribeFieldResult> customFieldMap = new Map<String, Schema.DescribeFieldResult>();
        
        // Construct the query string
        String query = 'Select id, name, ';
        for (String fieldName : contactFields.keySet()) {
            Schema.SobjectField f = contactFields.get(fieldName);
            Schema.DescribeFieldResult fResult = f.getDescribe();
            
            // Only include the fields which are updateable
            if (fResult.isUpdateable()) {
                // If the field is type lookup, select the parent name  
                if (fResult.getRelationshipName() == null) {
                    query += (fieldName + ',');
                } else {
                    query += (fResult.getRelationshipName() + '.name,');
                }
                // Collect the standard and custom fields separately for sorting
                if(fResult.isCustom() && !fResult.getLabel().contains('Hidden') /*&& !fResult.getLabel().contains('Wish Child Photo')*/) {
                    customFieldMap.put(fieldName, fResult);
                } if(!fResult.isCustom() && !fResult.getLabel().contains('Record Type')){
                    standardFieldMap.put(fieldName, fResult);
                }
            }
        }
        // Adding some non-updateable system fields which we need to add to the record diff table.
        query +=  'createdby.name, createddate, LastModifiedBy.name, LastModifiedDate';
        // Finally completing the query by appending the table name and the filter clause
        query += ' from Contact where id IN  (' + contactIdFilter + ')';
        
        System.debug('The contact query is: ' + query);
        
        List<Contact> contacts;
        try {
            // contacts = new List<Sobject>();
            //  contacts.Clear();
            contacts = Database.query(query); // Query the records
            // Ensure we got back the same number of records as expected. In case any record got deleted/moved since last search.
            if (contacts == null || contacts.size() != this.selectedRecordsCount) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,' Label.Contact_Merge_Error_Query_Failed' + ' ' + 'Label.Contact_Merge_Error_please_retry'));
                return;
            }
        } catch (Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Label.Contact_Merge_Error_Contact_not_found '+ ' Error: ' + e));
            return;
        }
        
        // Update the list of searched records with only the ones selected
        searchResults.clear();
        for (Contact c : contacts) {
            this.selectedRecords.put(c.id, c);    
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
        FieldRow temp = new FieldRow('', '', False, 'header');
        FieldRow temp2 = new FieldRow('RecordType', 'RecordType', False, '');
        for (Sobject c: contacts) {
            Contact con = (Contact) c;
            temp.values.add(new Cell(c.id, con.name));
            temp2.values.add(new Cell(con.RecordType.Name, con.RecordType.Name));  
        }
        fieldRows.add(temp);
        fieldRows.add(temp2);
        
        // Add second row to select the master record. Select the one which is last modified
        temp = new FieldRow(MASTER_KEY, 'Master Record', true, null);
        {
            DateTime lastModifiedDate;
            for (Sobject c: contacts) {
                temp.values.add(new Cell(c.id, null));
                if (lastModifiedDate == null || 
                    (lastModifiedDate != null && (DateTime)c.get('lastModifiedDate') > lastModifiedDate)) {
                        temp.selectedValue = c.id;
                        lastModifiedDate = (DateTime)c.get('lastModifiedDate');
                    }   
            }
        }
        fieldRows.add(temp);
        
        
        for (String fieldName: standardFieldList) {
            addFieldComparisonRows(fieldName, standardFieldMap.get(fieldName), contacts);
        }
        
        
        for (String fieldName: customFieldList) {
            addFieldComparisonRows(fieldName, customFieldMap.get(fieldName), contacts);
        }
        
        
        FieldRow createdByRow = new FieldRow('CreatedById', 'Created By', false, null), 
            lastModifiedByRow = new FieldRow('LastModifiedById', 'Last Modified By', false, null);
        for (Sobject c: contacts) {
            SObject createdBy = c.getSObject('createdby');
            SObject modifiedBy = c.getSObject('lastModifiedBy');
            createdByRow.values.add(new Cell(c.id, createdBy.get('name') + ' ' + c.get('createdDate')));
            lastModifiedByRow.values.add(new Cell(c.id, modifiedBy.get('name') + ' ' + c.get('LastModifiedDate'))); 
        }
        
        
        //Select all related records based on the contact.
        
        affiliations = new List<affiliationWrapper>();
        affiliationWrapper aff;
        
        String queryString = 'SELECT ';
        for(Schema.FieldSetMember affiliationField :SObjectType.npe5__Affiliation__c.FieldSets.AffiliationFieldSet.getFields()) {
            queryString += affiliationField.getFieldPath()+',';
        }
        queryString = queryString .removeEnd(',');
        queryString += ' FROM npe5__Affiliation__c WHERE npe5__Contact__c IN (' + contactIdFilter + ')';
        for(npe5__Affiliation__c currAff: Database.query(queryString )){// [SELECT Id,npe5__Contact__c,npe5__Organization__r.Name,npe5__Primary__c,npe5__Status__c,Constituent_Code__c,npe5__Contact__r.Name FROM npe5__Affiliation__c WHERE npe5__Contact__c IN :conIdList]){
            aff = new affiliationWrapper(currAff);
            affiliations.add(aff);
        }
        
        //Relationship
        queryString = 'SELECT ';
        for(Schema.FieldSetMember relationshipField :SObjectType.npe4__Relationship__c.FieldSets.Relationship_Field_Set.getFields()) {
            queryString += relationshipField.getFieldPath()+',';
        }
        queryString = queryString .removeEnd(',');
        queryString += ' FROM npe4__Relationship__c WHERE npe4__Contact__c IN  (' + contactIdFilter + ')';
        
        relationshipList= new List<relationshipWrapper>();
        relationshipWrapper rel;
        for(npe4__Relationship__c  currRec: Database.query(queryString) ){
            rel= new relationshipWrapper(currRec);
            relationshipList.add(rel);
        }
        
        
        
        //Volunteer Orientation & Training 
        queryString = 'SELECT ';
        for(Schema.FieldSetMember volunteerOTField :SObjectType.Volunteer_Orientation_Training__c.FieldSets.VolunteerO_T_Feld_set.getFields()) {
            queryString += volunteerOTField.getFieldPath()+',';
        }
        queryString = queryString .removeEnd(',');
        queryString += ' FROM Volunteer_Orientation_Training__c WHERE Volunteer__c IN  (' + contactIdFilter + ')';
        
        volunteerOTList= new List<VolunteerOTWrapper>();
        VolunteerOTWrapper volOT;
        for(Volunteer_Orientation_Training__c  currRec : Database.query(queryString)){
            volOT= new VolunteerOTWrapper(currRec);
            volunteerOTList.add(volOT);
        }
        
        //Volunteer Role        
        queryString = 'SELECT ';
        for(Schema.FieldSetMember volunteerOTField :SObjectType.Volunteer_Roles__c.FieldSets.Volunteer_Role_Field_Set.getFields()) {
            queryString += volunteerOTField.getFieldPath()+',';
        }
        queryString = queryString .removeEnd(',');
        queryString += ' FROM Volunteer_Roles__c WHERE Volunteer_Name__c IN  (' + contactIdFilter + ')';
        
        volunteerRoleList = new List<volunteerRoleWrapper>();
        volunteerRoleWrapper newVolunteerRole;
        for(Volunteer_Roles__c  currRec : Database.query(queryString)){
            newVolunteerRole= new volunteerRoleWrapper(currRec);
            volunteerRoleList.add(newVolunteerRole);
        }
        
        //Volunteer Opportunity
        queryString = 'SELECT ';
        for(Schema.FieldSetMember volunteerOTField :SObjectType.Volunteer_Opportunity__c.FieldSets.VolunteerDetails.getFields()) {
            queryString += volunteerOTField.getFieldPath()+',';
        }
        queryString = queryString .removeEnd(',');
        queryString += ' FROM Volunteer_Opportunity__c WHERE Volunteer_Name__c IN  (' + contactIdFilter + ')';
        
        volunteerOppList = new List<VolunteerOpportunityWrapper>();
        VolunteerOpportunityWrapper newVolunteerOpp;
        for(Volunteer_Opportunity__c currRec : Database.query(queryString)){
            newVolunteerOpp= new VolunteerOpportunityWrapper(currRec);
            volunteerOppList.add(newVolunteerOpp);
        }
        
        //BackgroundCheck
        
        queryString = 'SELECT ';
        for(Schema.FieldSetMember backgroundCheckField :SObjectType.Background_check__c.FieldSets.BackgroundCheck.getFields()) {
            queryString += backgroundCheckField.getFieldPath()+',';
        }
        queryString = queryString .removeEnd(',');
        queryString += ' FROM Background_check__c WHERE Volunteer__c IN  (' + contactIdFilter + ')';
        
        backgroundcheckList = new List<BackgroundCheckWrapper>();
        BackgroundCheckWrapper newBC;
        for(Background_check__c currRec : Database.query(queryString)){
            newBC = new BackgroundCheckWrapper(currRec);
            backgroundcheckList.add(newBC);
        }
        
        //Conflict Of Interest
        
        queryString = 'SELECT ';
        for(Schema.FieldSetMember conflictofInterestField :SObjectType.Conflict_Of_Interest__c.FieldSets.ConflictOfIntrest.getFields()) {
            queryString += conflictofInterestField.getFieldPath()+',';
        }
        queryString = queryString .removeEnd(',');
        queryString += ' FROM Conflict_Of_Interest__c WHERE Volunteer_Contact__c IN  (' + contactIdFilter + ')';               
        conflictOfInterestList = new List<ConflictOfInterestWrapper>();
        ConflictOfInterestWrapper newCOI;
        for(Conflict_Of_Interest__c  currRec : Database.query(queryString)){
            newCOI = new ConflictOfInterestWrapper(currRec);
            conflictOfInterestList.add(newCOI);
        }
        
        //Awards & Recognition.
        queryString = 'SELECT ';
        for(Schema.FieldSetMember awardsRecognitionField :SObjectType.Awards_Recognition__c.FieldSets.AwardsRecognitionFields.getFields()) {
            queryString += awardsRecognitionField.getFieldPath()+',';
        }
        queryString = queryString .removeEnd(',');
        queryString += ' FROM Awards_Recognition__c WHERE Volunteer_Contact__c IN  (' + contactIdFilter + ')';               
        awardsRecognitionList = new List<AwardsRecognitionWrapper>();
        AwardsRecognitionWrapper newAwards;
        for(Awards_Recognition__c  currRec : Database.query(queryString)){
            newAwards = new AwardsRecognitionWrapper(currRec);
            awardsRecognitionList.add(newAwards);
        }
        
        //In-Kind Donation & Reimbursement 
        queryString = 'SELECT ';
        for(Schema.FieldSetMember inkindDonationField :SObjectType.In_Kind_Donation_Reimbursement__c.FieldSets.InkindDonationFieldSet.getFields()) {
            queryString += inkindDonationField.getFieldPath()+',';
        }
        queryString = queryString .removeEnd(',');
        queryString += ' FROM In_Kind_Donation_Reimbursement__c WHERE Volunteer_Name__c IN  (' + contactIdFilter + ')';               
        inkindDonationList = new List<InkindDonationWrapper>();
        InkindDonationWrapper newinkindDonation;
        for(In_Kind_Donation_Reimbursement__c currRec : Database.query(queryString)){
            newinkindDonation = new InkindDonationWrapper(currRec);
            inkindDonationList.add(newinkindDonation);
        }
        
        this.step++;
        
    }
    
    /**
* Method to add field information and field values to the list of fieldRow
*/
    public void addFieldComparisonRows(String fieldName, Schema.DescribeFieldResult fieldDesc, List<SObject> objs) {
        // Create a new FieldRow item
        FieldRow row = new FieldRow();
        row.fieldName = fieldName;
        
        // For standrd lookup type fields, use the relationship name as the field label
        if (!fieldDesc.isCustom() && fieldDesc.getRelationshipName() != null) {
            row.fieldLabel = fieldDesc.getRelationshipName();
        } else {
            row.fieldLabel = fieldDesc.getLabel();
        }
        
        row.values = new List<Cell>();
        
        boolean isDifferent = false; // flag to indicate whether atleast one pair of field values is different across all contacts
        boolean isNull = true; // flag to indicate whether all the field values are null
        Integer idx = 0;
        
        List<String> values = new List<String>();
        DateTime lastModifiedDate = null;
        String prev;
        
        // Iterate over all contacts to find the field values and add them to row values
        for (SObject c : objs) {
            // For lookup fields set the name as the values
            if (fieldDesc.getRelationshipName() != null) {
                Sobject obj = c.getSObject(fieldDesc.getRelationshipName());
                if (obj != null) {
                    values.add(String.valueOf(obj.get('name')));
                } else {
                    values.add(null);
                }   
            } else {
                values.add(String.valueOf(c.get(fieldName)));
            }
            
            isNull &= (c.get(fieldName) == null); // Check if the value is null
            
            if (idx == 0) {
                prev = String.valueOf(c.get(fieldName));
            }
            if (idx > 0 && !isNull) {
                // Check if atleast one of the values is different. If yes then update the isDifferent flag
                String current = String.valueOf(c.get(fieldName));
                if ((prev != null && !prev.equals(current)) || 
                    (current != null && !current.equals(prev)) && fieldDesc.getLabel() != 'RecordType' ) {
                        isDifferent = true;
                    }
                
                prev = current;
            }
            
            // Select the default value for the field. A non-null value on the latest modified record 
            if (c.get(fieldName) != null && (lastModifiedDate == null || 
                                             (lastModifiedDate != null && (DateTime)c.get('lastModifiedDate') > lastModifiedDate))) {
                                                 row.selectedValue = c.id;
                                                 lastModifiedDate = (DateTime)c.get('lastModifiedDate');
                                             }
            
            idx++;
        }
        
        // If atleast one record has a non-null field value, then add it to the list of fieldRows.
        if (!isNull) {
            for (Integer i=0; i < values.size(); i++) {
                String val = values[i];
                if (val != null && val.length() > 255) {
                    val = val.substring(0, 251) + ' ...';
                }
                row.values.add(new Cell(objs[i].id, val));
            }
            // Show the select radio only if the field values are different. 
            // Dont let user choose the account as you dont want users to assign a differnt account in One to One case.
            row.showRadio = (isDifferent);
            fieldRows.add(row);
        }
    }
    
    public void searchRecords(){
        mySOSL =Null;
        search();
    }
    //search for contacts
    public void search() {
        searchResults.clear();  
        // mySOSL =Null;    
        // mySOSL = new  ApexPages.StandardSetController(); 
        //String searchnewRes = ApexPages.currentPage().getParameters().get('searchNewResult');
        this.searchResults = wrapSOSLResults(mySOSL.getRecords());
        if (searchResults.size() > 0) {
            displaySearchResults = true;
        }
        
    }
    
    //run the SOSL
    public ApexPages.StandardSetController  mySOSL
    {
        
        /*   String Fname=  '%' + con.FirstName+ '%';
String Lname= '%' + con.LastName+ '%';
String email = '%' + con.Email+ '%'; */
        
        
        
        // List<Contact> contactList =  [SELECT id, name, accountId, account.name, title, email, phone,ownerId, owner.name FROM Contact WHERE firstName Like :Fname AND lastName Like:Lname ];
        get {
            if(mySOSL == Null || !newSearch || searchNewResult){
                String query,cond='';
                Set<String> conditions = new Set<String>();
                conditions.clear(); 
                 if(con.FirstName != Null && con.FirstName != ''){
                    String fName=  con.FirstName+ '%';
                    conditions.add(' firstName like :fName ');
                }
                if(con.LastName != Null && con.LastName != ''){
                    String lName = con.LastName + '%';
                    conditions.add(' LastName like :lName ');
                }
                if(con.Email != Null && con.Email != ''){
                    String email = con.email + '%';
                    conditions.add(' Email like :email ');
                }
                /*if(con.Birthdate != Null && con.Email != ''){
                    String dob = '%' + con.Birthdate+ '%';
                    conditions.add(' Birthdate like :dob');
                }*/
                
                if(birthDate != Null && birthDate != ''){
                    Date dob = date.parse(birthDate);
                    conditions.add(' Birthdate =:dob' );
                }
                if(con.mailingstreet != Null && con.mailingstreet != ''){
                    String mailingStreet = '%' + con.mailingstreet + '%';
                    conditions.add(' mailingstreet like :mailingStreet ');
                }
                
                if(con.mailingcity != Null && con.mailingcity != ''){
                    String mailingcity = '%' + con.mailingcity + '%';
                    conditions.add(' mailingcity like :mailingcity ');
                }
                
                if(con.mailingState != 'Null' && con.mailingState != ''){
                    String mailingState = '%' + con.mailingState + '%';
                    conditions.add(' mailingState like :mailingState ');
                }
                
                if(con.mailingPostalCode != Null && con.mailingPostalCode != ''){
                    String mailingPostalCode = '%' + con.mailingPostalCode + '%';
                    conditions.add(' mailingPostalCode like :mailingPostalCode ');
                }
                
                if(conditions.Size() > 0 ){
                    for(String s : conditions){
                        cond+=s+'AND';
                    }
                    
                    
                    cond = cond.removeEnd('AND');
                    System.debug('con.FirstName'+con.firstname);
                    System.debug('condition **********'+cond);
                    
                    query = 'SELECT id, name, accountId, account.name, title, email, phone,ownerId, owner.name FROM Contact WHERE '+cond+' ORDER BY Name LIMIT 1000 ';
                }
                else
                    query = 'SELECT id, name, accountId, account.name, title, email, phone,ownerId, owner.name FROM Contact   ORDER BY Name LIMIT 1000 ';
                System.debug('QUERY :::::: '+query);
                
                mySOSL= new ApexPages.StandardSetController(Database.getQueryLocator(query));
                if(setPageSize == Null)
                    setPageSize =10;
                mySOSL.setPageSize(setPageSize );
            }
            return mySOSL;
        }
        set;
        
        
    }
    
    
    
    
    
    public List<ContactWrapper> wrapSOSLResults(List<Contact> mySearchList){
        
        List<ContactWrapper> res = new List<ContactWrapper>();
        //loop through the contacts putting them in an array of wrappers
        if(mySearchList.size()>0){
            /* for (Contact returnedObjects : mySearchList) {


contactWrapper thisResult = new contactWrapper(returnedObjects);   
System.debug('Contact Id: ' + returnedObjects.id);
System.debug('Contact: ' + returnedObjects);         
res.add(thisResult);   

}*/
            
            searchResults = new List<contactWrapper>();
            for (Contact cont : (List<Contact>) mySearchList) {
                if(mapHoldingSelectedRecords != Null && mapHoldingSelectedRecords.containsKey(cont.id)){
                    res.add(mapHoldingSelectedRecords.get(cont.id));
                    
                }
                else{
                    res.add(new ContactWrapper(cont));
                }
            }
        }
        System.debug('Search Results Map Size: ' + res.size());
        return res;       
    }
    
    
    
    //method to merge the winner and losers
    public PageReference mergeContacts() {
        SObject master;
        String masterRecordType;
        String loserRecordType;
        User masterUser,loserUser;
        masterUser = new User();
        loserUser = new User();
        List<Contact> losers = new List<Contact>();
        Set<Id>loserContactIdSet = new Set<Id>();
        Map<String,Integer> recordTypeHirachyMap = new Map<String,Integer>();
        recordTypeHirachyMap.put('Board Member',5);
        recordTypeHirachyMap.put('Medical Professional',4);
        recordTypeHirachyMap.put('Volunteer Contact',3);
        recordTypeHirachyMap.put('Wish Child',2);
        recordTypeHirachyMap.put('Wish Family',1);
        List<CaseTeamMember> caseTeamMemberList = new List<CaseTeamMember>();
        // Find the master record based the selected value of the Master FieldRow
        for (FieldRow row : fieldRows) {
            if (row.showRadio && row.fieldName.equals(MASTER_KEY)) {                
                
                master = new Contact(id = row.selectedValue);                
                break;
            }
        }
        
        if (master != null) {
            for (Contact c : this.selectedRecords.values()) {
                if (c.id != master.id) {
                    losers.add(c);
                    loserContactIdSet.add(c.Id);
                }   
            }
            
            for(Contact currCon : [SELECT Id,RecordType.Name FROM Contact WHERE Id IN :loserContactIdSet OR Id =: master.Id ]){
                if(currCon.Id == master.Id)
                    masterRecordType = currCon.RecordType.Name;
                else
                    loserRecordType = currCon.RecordType.Name;
            }
            
            if(recordTypeHirachyMap.get(masterRecordType) < recordTypeHirachyMap.get(loserRecordType) ){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'When merging two contacts of different record types, the hierarchy of which record type will remain is as follows:<html><body><br/>1.Board Member<br/>2.Volunteer<br/>3.Medical Professional<br/>4.Wish Child<br/>5.Wish Family</body></html>'));
                return Null;
            }
            
            for(User currUser : [SELECT Id,contactId,IsActive FROM User Where contactId IN :loserContactIdSet OR contactId =: master.Id]){
                if(currUser.contactId == master.Id)
                    masterUser = currUser;
                else
                    loserUser = currUser;
            }
            
            if(loserUser != Null && loserUser.isActive && masterUser != Null && masterUser.isActive){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Two Volunteer User can\'t be merged'));
                return Null;
            }
            
            if(loserUser != Null && loserUser.isActive && ( masterUser == Null || !masterUser.isActive)){
                User swapUser = new User();
                loserContactIdSet.Clear();
                Contact swapContact= new Contact();
                swapContact = losers[0];
                losers[0] =(Contact) master;
                master = swapContact;
                loserContactIdSet.add(losers[0].Id);
                //master = losers[0];
                
                swapUser = loserUser;
                loserUser = masterUser;
                masterUser = swapUser;
                System.debug('loserCon'+loserContactIdSet);
            }
            /* for(CaseTeamMember dbCaseTeamMember : [SELECT Id,MemberId,Member.FirstName,Member.LastName,ParentId,Parent.RecordTypeId,TeamRoleId,TeamRole.Name FROM CaseTeamMember  WHERE MemberId =: loserUser.Id]){
dbCaseTeamMember.MemberId = masterUser.Id;
caseTeamMemberList.add(dbCaseTeamMember);
}
if(caseTeamMemberList.Size() > 0)
Update caseTeamMemberList;*/
            
            // Update the field values of master record based on the selected value for each field.
            for (FieldRow row : fieldRows) {
                if (row.showRadio && !row.fieldName.equals(MASTER_KEY) && row.selectedValue != master.id) {
                    SObject selectedRecord = this.selectedRecords.get(row.selectedValue);
                    
                    System.debug('Assigning field: ' + row.fieldName);
                    
                    // Sobject.put is not happy when sobject.get returns null. It throws an exception System.SObjectException: Illegal assignment from Object to String.
                    // But instead when you pass a null directly to put, it works fine. And hence, this if statement.
                    if (selectedRecord.get(row.fieldName) == null) {
                        master.put(row.fieldName, null);    
                    } else {
                        Object val = selectedRecord.get(row.fieldName);
                        System.debug('Setting value: ' + val);
                        master.put(row.fieldName, val);
                        System.debug('Set value: ' + master.get(row.fieldName));
                    }
                }
            }
            
            // Group all the loosing records separately.
            
            List<case> updateCaseList = new List<case>();
            List<npe5__Affiliation__c> affiliationList= new List<npe5__Affiliation__c>();
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
            npe5__Affiliation__c newAff;
            npe4__Relationship__c updateRel;
            
            System.debug('loserCon'+loserContactIdSet);
            
            for(Case currCase: [SELECT Id,ContactId FROM Case WHERE ContactId IN :loserContactIdSet]){
                currCase.contactId = master.Id;
                updateCaseList.add(currCase);
            }
            if(loserRecordType == 'Volunteer Contact' || loserRecordType == 'Board Member')
                for(User disabledUser : [select id,IsPortalEnabled from User where ContactId IN :loserContactIdSet]){
                    System.debug('inside Loop'+disabledUser.Id);
                    updateUserList.add(disabledUser);
                }
            if(updateUserList.Size() > 0)
                updateUser(loserContactIdSet);
            
            
            
            /* if(inactiveUserList.Size() > 0)
System.enqueueJob(new userAsInactive(inactiveUserList[0].Id));*/
            
            if(updateCaseList.Size()> 0)
                Update updateCaseList;
            
            //Update Affiliation Records
            if(Affiliations.Size() > 0){
                for(AffiliationWrapper curraff: Affiliations){
                    if(curraff.Checkbox == True){
                        //newAff = new npe5__Affiliation__c();
                        newAff = currAff.aff.clone(false,true,true,true);
                        newAff.npe5__Contact__c = master.Id;
                        affiliationList.add(newAff);
                        deleteAffiliation.add(currAff.aff);
                    }
                    else{
                        newAff = new npe5__Affiliation__c();
                        newAff.Id = currAff.aff.Id;
                        deleteAffiliation.add(newAff);
                    }
                }
            }
            if(relationshipList.Size () > 0){
                for(RelationshipWrapper currRel: relationshipList){
                    if(currRel.Checkbox == True){
                        //newAff = new npe5__Affiliation__c();
                        updateRel= currRel.relationship.clone(false,true,true,true);
                        updateRel.npe4__Contact__c = master.Id;
                        updateRelationshipList.add(updateRel);
                        deleteRelationshipList.add(currRel.relationship);
                    }
                    else{
                        updateRel = currRel.relationship;
                        //updateRel.npe4__Contact__c = '';
                        deleteRelationshipList.add(updateRel);
                    }
                }
            }
            
            //Volunteer Orientation and Training.
            if(VolunteerOTList.Size() > 0) {
                for(VolunteerOTWrapper currRec: VolunteerOTList){
                    if(currRec.Checkbox == True){
                        
                        currRec.volunteerOT.Volunteer__c= master.Id;
                        updateVolunteerOTList.add(currRec.volunteerOT);
                    }
                    else{
                        
                        deleteVolunteerOTList .add(currRec.volunteerOT);
                    }
                }
            }
            
            
            //Volunteer Role
            if(VolunteerRoleList.Size() > 0){
                for(VolunteerRoleWrapper currRec: VolunteerRoleList){
                    if(currRec.Checkbox == True){
                        
                        currRec.volunteerRole.Volunteer_Name__c= master.Id;
                        updateVolunteerRoleList.add(currRec.volunteerRole);
                    }
                    else{
                        
                        deleteVolunteerRoleList .add(currRec.volunteerRole);
                    }
                }
            }
            
            //Volunteer Opportunity
            if(VolunteerOppList.Size() > 0){
                for(VolunteerOpportunityWrapper currRec: VolunteerOppList){
                    if(currRec.Checkbox == True){
                        
                        currRec.volunteerOpp.Volunteer_Name__c= master.Id;
                        updateVolunteerOppList.add(currRec.volunteerOpp);
                    }
                    else{
                        
                        deleteVolunteerOppList.add(currRec.volunteerOpp);
                    }
                }
            }
            
            //Background Check
            if(backgroundcheckList.Size() > 0){
                for(BackgroundCheckWrapper currRec: backgroundcheckList){
                    if(currRec.Checkbox == True){
                        
                        currRec.backgroundCheck.Volunteer__c= master.Id;
                        updatedBackgroundCheckList.add(currRec.backgroundCheck);
                    }
                    else{
                        
                        deletedBackgroundCheckList.add(currRec.backgroundCheck);
                    }
                }
            }
            
            //Conflict Of Interest
            if(conflictOfInterestList.Size() > 0){
                for(ConflictOfInterestWrapper currRec: conflictOfInterestList){
                    if(currRec.Checkbox == True){
                        
                        currRec.conflictOfInterest.Volunteer_Contact__c= master.Id;
                        updatedConflictOfInterestList.add(currRec.conflictOfInterest);
                    }
                    else{
                        
                        deletedConflictOfInterestList.add(currRec.conflictOfInterest);
                    }
                }
            }
            
            
            //Awads & Recognition
            if(awardsRecognitionList.Size() > 0){
                for(AwardsRecognitionWrapper currRec: awardsRecognitionList){
                    if(currRec.Checkbox == True){
                        
                        currRec.awaredsRec.Volunteer_Contact__c= master.Id;
                        updatedAwardsRecognitionList.add(currRec.awaredsRec);
                    }
                    else{
                        
                        deletedAwardsRecognitionList.add(currRec.awaredsRec);
                    }
                }
            }
            
            
            //In-Kind Donation & Reimbursement 
            if(inkindDonationList.Size() > 0){
                for(InkindDonationWrapper currRec: inkindDonationList){
                    if(currRec.Checkbox == True){
                        
                        currRec.inkindRec.vounteer_Name__c = master.Id;
                        updatedInkindDonationList.add(currRec.inkindRec);
                    }
                    else{
                        
                        deletedInkindDonationList.add(currRec.inkindRec);
                    }
                }
            }
            
            //Select and update all loser contact open activities to master contact.
            List<Task> taskList = new List<Task>();
            for(Task currTask: [SELECT id,Whoid FROM Task WHERE WhoId IN: loserContactIdSet ]){
                currTask.WhoId = master.Id;
                taskList.add(currTask);
            }
            
            List<cg__ContactFile__c> updateContactFileList = new List<cg__ContactFile__c>();
            for(cg__ContactFile__c conFile : [SELECT Id,cg__Contact__c FROM cg__ContactFile__c WHERE cg__Contact__c IN :loserContactIdSet ]){
                conFile.cg__Contact__c = master.Id;
                updateContactFileList.add(conFile);
            }
            if(updateContactFileList.Size() > 0)
                Update updateContactFileList;
            // Now merge the contacts
            // ContactMerge merger = new ContactMerge((Contact)master, losers);
            
            // before proceeding further first lock the records for change
            List<Contact> allContacts = new List<Contact>();
            allContacts.add((Contact)master);
            allContacts.addAll(losers);
            /* List<Contact> lock = [Select id from Contact where id IN :allContacts for update];

if (lock == null || lock.size() != allContacts.size()) {
ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Contact Merge Error Lock failed '+ ' ' + 'Contact Merge Error please retry'));
return null;
}*/
            
            System.SavePoint sp = Database.setSavepoint();
            try {
                update master; // Update the master with the selected values before calling merge.
                
                if(affiliationList.Size() > 0)
                    Insert affiliationList; 
                if(updateRelationshipList.Size() > 0)               
                    Insert updateRelationshipList; 
                if(updateVolunteerOTList.Size() > 0)               
                    Update updateVolunteerOTList;
                if(updateVolunteerRoleList.Size() > 0)
                    Update updateVolunteerRoleList;
                if(updateVolunteerOppList.Size() > 0)
                    Update updateVolunteerOppList;
                if(updatedBackgroundCheckList.Size() > 0)
                    Update updatedBackgroundCheckList;
                if(updatedBackgroundCheckList.Size() > 0)
                    Update updatedBackgroundCheckList;
                if(updatedAwardsRecognitionList.Size() > 0)
                    Update updatedAwardsRecognitionList;
                if(updatedInkindDonationList.Size() > 0)
                    Update updatedInkindDonationList;
                if(taskList.Size() > 0)
                    Update taskList;
                
                
                if(deleteAffiliation.Size() > 0)
                    Delete deleteAffiliation;
                if(deleteRelationshipList.Size() > 0)
                    Delete deleteRelationshipList;
                if(deleteVolunteerOTList.Size() > 0)
                    Delete deleteVolunteerOTList;
                if(deleteVolunteerRoleList.Size() > 0)
                    Delete deleteVolunteerRoleList;
                if(deleteVolunteerOppList.Size() > 0)
                    Delete deleteVolunteerOppList;
                if(deletedBackgroundCheckList.Size() > 0)
                    Delete deletedBackgroundCheckList;
                
                if(deletedAwardsRecognitionList.Size() > 0)
                    Delete deletedAwardsRecognitionList;
                if(deletedInkindDonationList.Size() > 0)
                    Delete deletedInkindDonationList;
                
                
                Delete losers;
                
                // if(merger.mergeContacts()) {
                
                return new PageReference('/' + master.id);
                //} else {
                Database.rollback(sp);
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Label.Contact_Merge_Error_Merge_Failed '+ ' ' + 'Label.Contact_Merge_Error_please_retry'));
                // }
            } catch (Exception e) {
                Database.rollback(sp);
                String errorMessage = String.valueOf(e);
                
                if(errorMessage.Contains('FIELD_CUSTOM_VALIDATION_EXCEPTION'))
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Contact Merge Error Merge Failed :' + ' ' + errorMessage.subString(errorMessage.lastIndexOfIgnoreCase('FIELD_CUSTOM_VALIDATION_EXCEPTION')+34).removeEnd(': []')));
                else if(errorMessage.Contains('FIELD_FILTER_VALIDATION_EXCEPTION'))
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Contact Merge Error Merge Failed :' + ' ' + errorMessage.subString(errorMessage.lastIndexOfIgnoreCase('FIELD_FILTER_VALIDATION_EXCEPTION,')+34).removeEnd(': [Region_Code__c]')));
                else
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Contact Merge Error Merge Failed :' + ' ' + e));
            }
        } else {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Contact Merge Error No Master'));
        }
        
        return null;
    }
    
    
    public class relationshipWrapper{
        
        public npe4__Relationship__c relationship{get;set;}
        public Boolean checkbox{get;set;}
        
        public  relationshipWrapper( npe4__Relationship__c currRel){
            relationship=currRel;
            
        }
        
    }
    public class affiliationWrapper{
        
        public npe5__Affiliation__c aff{get;set;}
        public Boolean checkbox{get;set;}
        
        public  affiliationWrapper( npe5__Affiliation__c currAff){
            aff=currAff;
            
        }
        
    }
    
    public class VolunteerOTWrapper{      
        public Volunteer_Orientation_Training__c volunteerOT{get;set;}
        public Boolean checkbox{get;set;}       
        public  VolunteerOTWrapper( Volunteer_Orientation_Training__c volunteerOT){
            this.volunteerOT = volunteerOT;
            
        }      
    }
    
    public class VolunteerRoleWrapper{      
        public Volunteer_Roles__c volunteerRole{get;set;}
        public Boolean checkbox{get;set;}       
        public  VolunteerRoleWrapper( Volunteer_Roles__c volunteerRole){
            this.volunteerRole = volunteerRole;
            
        }      
    }
    public class VolunteerOpportunityWrapper{      
        public Volunteer_Opportunity__c volunteerOpp{get;set;}
        public Boolean checkbox{get;set;}       
        public  VolunteerOpportunityWrapper( Volunteer_Opportunity__c volunteerOpp){
            this.volunteerOpp = volunteerOpp;
            
        }      
    }
    
    public class BackgroundCheckWrapper {      
        public Background_check__c backgroundCheck{get;set;}
        public Boolean checkbox{get;set;}       
        public  BackgroundCheckWrapper( Background_check__c backgroundCheck){
            this.backgroundCheck = backgroundCheck;
            
        }      
    }
    
    public class ConflictOfInterestWrapper {      
        public Conflict_Of_Interest__c conflictOfInterest{get;set;}
        public Boolean checkbox{get;set;}       
        public  ConflictOfInterestWrapper (Conflict_Of_Interest__c conflictOfInterest){
            this.conflictOfInterest= conflictOfInterest;
            
        }      
    }
    
    public class AwardsRecognitionWrapper{      
        public Awards_Recognition__c awaredsRec{get;set;}
        public Boolean checkbox{get;set;}       
        public  AwardsRecognitionWrapper(Awards_Recognition__c awaredsRec){
            this.awaredsRec= awaredsRec;
            
        }      
    }
    
    public class InkindDonationWrapper{      
        public In_Kind_Donation_Reimbursement__c inkindRec{get;set;}
        public Boolean checkbox{get;set;}       
        public  InkindDonationWrapper(In_Kind_Donation_Reimbursement__c inkindRec){
            this.inkindRec= inkindRec;
            
        }      
    }
    
    
    public Boolean hasNext {
        get {
            return mySOSL.getHasNext();
        }
        set;
    }
    
    /** indicates whether there are more records before the current page set.*/
    public Boolean hasPrevious {
        get {
            return mySOSL.getHasPrevious();
        }
        set;
    }
    
    /** returns the page number of the current page set*/
    public Integer pageNumber {
        get {
            return mySOSL.getPageNumber();
        }
        set;
    }
    
    /** return total number of pages for page set*/
    Public Integer getTotalPages(){
        Decimal totalSize = mySOSL.getResultSize();
        Decimal pageSize = setPageSize;
        Decimal pages = totalSize/pageSize;
        return (Integer)pages.round(System.RoundingMode.CEILING);
    }
    
    /** returns the first page of the page set*/
    public void first() {
        updateSearchItemsMap();
        mySOSL.first();
        newSearch=True;
        search();
        
    }
    
    /** returns the last page of the page set*/
    public void last() {
        updateSearchItemsMap();
        mySOSL.last();
        newSearch=True;
        search();
        
    }
    /** returns the previous page of the page set*/
    public void previous() {
        updateSearchItemsMap();
        mySOSL.previous();
        newSearch=True;
        search();
        
    }
    
    //This is the method which manages to remove the deselected records, and keep the records which are selected in map.
    private void updateSearchItemsMap() {
        for(ContactWrapper wrp : searchResults){
            if(wrp.selected){
                mapHoldingSelectedRecords.put(wrp.con.id, wrp);
            }
            if(wrp.selected == false && mapHoldingSelectedRecords.containsKey(wrp.con.id)){
                mapHoldingSelectedRecords.remove(wrp.con.id);
            }
        }
    }    
    
    /** returns the next page of the page set*/
    public void next() {
        updateSearchItemsMap();
        mySOSL.next();
        newSearch=True;
        search();
    }
    public void setPageSize() {
        updateSearchItemsMap();
        newSearch=True;
        search();
    }
    
    @future
    public static void updateUser(Set<Id> loserContactIdSet)
    {
        List<User> updateUserList = new List<User>();
        for(User disabledUser : [select id,IsPortalEnabled from User where ContactId IN :loserContactIdSet]){
            disabledUser.IsPortalEnabled = False;
            updateUserList.add(disabledUser);
        }
        if(updateUserList.Size() > 0)
            update updateUserList;
    }
}