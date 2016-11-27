/***************************************************************************************************
Author      : MST Solutions
CreatedBy   : Kanagaraj
Date        : 12/07/2016
Description : DocusignStatusTrigger_AT  is used when the docusign status record is created and its status
is completed then it will create a new conflict of interest records.
*****************************************************************************************************/

Trigger DocusignStatusTrigger_AT  on dsfs__DocuSign_Status__c (before update) {
    List<Contact> contactList = New List<Contact>();
    List<Contact> confilictContactList = New List<Contact>(); 
    List<Conflict_Of_Interest__c> conflictList = New List<Conflict_Of_Interest__c>();
    List<dsfs__DocuSign_Status__c > docusignList = new List<dsfs__DocuSign_Status__c>();
    Set<Id> leadIdSet = new Set<Id>();
    List<Lead> leadList = new List<Lead>();
    set<Id> volunteercontactIdSet = new Set<Id>();
   
    Set<Id> dstsIds = new Set<Id>();
    
    for(dsfs__DocuSign_Status__c dsts:Trigger.new)
    {
    
        system.debug('@@@@@@@@@@@ dsts @@@@@@@@@@@@@'+dsts);
        if(dsts.dsfs__Envelope_Status__c == 'Completed' && Trigger.oldMap.get(dsts.id).dsfs__Envelope_Status__c  != 'Completed')
        {
           dstsIds.add(dsts.id);
        }
        if(dsts.dsfs__Envelope_Status__c == 'Completed' && Trigger.oldMap.get(dsts.id).dsfs__Envelope_Status__c  != 'Completed' && dsts.isConflict__c == true){
            Conflict_Of_Interest__c newconflict = new Conflict_Of_Interest__c();
            newconflict.Volunteer_Contact__c = dsts.Docusign_Hidden_Contact__c ;
            newconflict.Signed_Date__c = system.today();
            newconflict.Expiration_Date__c = system.today() + 365;
            newconflict.Active__c = true;
            conflictList.add(newconflict); 
            volunteercontactIdSet.add(dsts.Docusign_Hidden_Contact__c);
            system.debug('newconflict id'+dsts.Id+'||'+newconflict.Id
                        );
        }
        if(dsts.dsfs__Envelope_Status__c == 'Completed' && Trigger.oldMap.get(dsts.id).dsfs__Envelope_Status__c  != 'Completed' && dsts.dsfs__Lead__c != Null)
        {
            system.debug('@@@@@@@@@@@ Enter If @@@@@@@@@@@@@'+dsts);
            leadIdSet.add(dsts.dsfs__Lead__c);
        }
    }
    
   
    if(leadIdSet.size() > 0)
    {
        for(Lead dbLead : [SELECT Id,isSign__c,Status,RFI_Form_Info_Hidden__c from Lead WHERE Id in:leadIdSet AND Status = :'Referred' AND Sub_Status__c = 'Pending Diagnosis Verification']){
            if(dbLead.RFI_Form_Info_Hidden__c  == 'Qualified'){
                dbLead.Status = 'Qualified';
            }
            if(dbLead.RFI_Form_Info_Hidden__c  == 'Not Qualified'){
                dbLead.Status = 'Eligibility Review';
            }
            dbLead.isSign__c = true;
        leadList.add(dbLead);
        }
        if(leadList.size() > 0){
       
         update leadList;
       }
    }
    if(conflictList.size() > 0)
    {
        Insert conflictList;
        List<Conflict_Of_Interest__c> dbconflictRec = [SELECT Id,Name,Expiration_Date__c,Signed_Date__c,Volunteer_Contact__c,Active__c FROM  Conflict_Of_Interest__c WHERE Volunteer_Contact__c  IN: volunteercontactIdSet  AND Active__c = TRUE Order by CreatedDate DESC];
         
        if(dbconflictRec[1].Id != Null){
            dbconflictRec[1].Active__c = FALSE;
            
            update dbconflictRec;
        } 
        
        if(dbconflictRec.size() > 1){
        if(dbconflictRec[0].Id != Null){
            for(dsfs__DocuSign_Status__c dsts:Trigger.new){
                Contact con = New Contact();
                 con.Id =  dsts.Docusign_Hidden_Contact__c;
                 con.isApplication__c= false;
                 confilictContactList.add(con);
                
                dsts.Conflict_Of_Interest__c = dbconflictRec[0].Id;
                dsts.Docusign_Hidden_Contact__c = null;
                
                 
            }
            
            update confilictContactList ;
        }
       }
    }
    
    Map<Id,dsfs__DocuSign_Status__c> dstsStatusRecMap = new  Map<Id,dsfs__DocuSign_Status__c>();
    if(dstsIds.size() > 0)
    {
        dstsStatusRecMap.putAll([SELECT id, dsfs__Contact__c,dsfs__Contact__r.Account.Volunteer_Manager__c,
                                 dsfs__Contact__r.OwnerId FROM dsfs__DocuSign_Status__c WHERE id IN :dstsIds]);    
    }
    
    List<Approval.ProcessSubmitRequest> approvalReqList=new List<Approval.ProcessSubmitRequest>();
    for(dsfs__DocuSign_Status__c dsts:Trigger.new)
    {
        if(dsts.dsfs__Envelope_Status__c == 'Completed'&& dsts.isConflict__c == false && dsts.dsfs__Lead__c == Null && dsts.dsfs__Case__c == Null){
          
            Approval.ProcessSubmitRequest approvalreq = new Approval.ProcessSubmitRequest();
            approvalreq.setComments('Submitting request for approval.');
            approvalreq.setObjectId(dsts.dsfs__Contact__c);
            approvalreq.setProcessDefinitionNameOrId('Volunteer_Contact_Process');
            approvalreq.setSkipEntryCriteria(true);
            if(dstsStatusRecMap.size() > 0)
            {
              if(dstsStatusRecMap.get(dsts.id).dsfs__Contact__r.Account.Volunteer_Manager__c != Null)
                approvalreq.setNextApproverIds(new Id[]{dstsStatusRecMap.get(dsts.id).dsfs__Contact__r.Account.Volunteer_Manager__c});
              else 
                approvalreq.setNextApproverIds(new Id[]{dstsStatusRecMap.get(dsts.id).dsfs__Contact__r.OwnerId});
            }
            approvalReqList.add(approvalreq);
            
           
            Contact con = New Contact();
            con.is_Application__c= 'Complete';
            con.Id = dsts.dsfs__Contact__c;
            ContactList.add(con);
        }
    }
    // Creating COI recod once docusign status has been changed to completed.
    if(ContactList.size() > 0 ){
     set<Id>volunteercontactSet = new Set<Id>();
        for(Contact cons:ContactList){
            Conflict_Of_Interest__c newconflict = new Conflict_Of_Interest__c();
            newconflict.Volunteer_Contact__c = cons.Id;
            newconflict.Signed_Date__c = system.today();
            newconflict.Expiration_Date__c = system.today() + 365;
            newconflict.Active__c = true;
            conflictList.add(newconflict); 
            volunteercontactSet.add(cons.Id);
        }
        
        if(conflictList.size() > 0)
        {
            update ContactList;
            Insert conflictList;
            
            List<Conflict_Of_Interest__c> dbconflictRec = [SELECT Id,Name,Expiration_Date__c,Signed_Date__c,Volunteer_Contact__c,Active__c FROM  Conflict_Of_Interest__c WHERE Active__c = TRUE AND Volunteer_Contact__c IN: volunteercontactSet Order by CreatedDate DESC];
            if(dbconflictRec.size() > 1){
            if(dbconflictRec[1].Id != Null){
            dbconflictRec[1].Active__c = FALSE;
             if(!Test.isRunningTest())
             update dbconflictRec;
           }
          }
        }
        
    }
    
    if(approvalReqList.size() > 0)
    {
       List<Approval.ProcessResult> resultList = Approval.process(approvalReqList);
    }
}