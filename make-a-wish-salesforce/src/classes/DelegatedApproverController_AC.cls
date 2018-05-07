/**************************************************************************************
Author : MST Solutions
Description : This class referred in the DelegatedApprover_VF. It display the all record approval processes . 
This will allow chapter staff to see visibility into their colleagues approval's needed when they are covering for each other.
****************************************************************************************/

global class DelegatedApproverController_AC{
    
    // Used to collect the list of approval process records
    @RemoteAction
    @readOnly
    public static String getAppList() {
        
        Constant_AC  constant = new Constant_Ac();   
        Id parentWishRecordTypeId = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get(constant.parentWishRT).getRecordTypeId();
        Id wishPlanningRecordTypeId = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get(constant.wishPlanningAnticipationRT).getRecordTypeId();
        Id volunteerRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(constant.volunteerRT).getRecordTypeId();
        Id wichChildRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(constant.contactWishChildRT).getRecordTypeId();
        Id inKindDonorsAccountRecordTypeId = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get(constant.inKindAccount).getRecordTypeId();
        Id boardMemberRT = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(constant.boardMemberRT).getRecordTypeId();
        
        Set<Id> volOppIdSet = new Set<Id>(); // Used to hold Volunteer Opportunity records Ids
        Set<Id> conIdSet = new Set<Id>();  // Used to hold Contact records Ids
        Set<Id> caseIdSet = new Set<Id>();  // Used to hold Case records Ids
        Set<Id> accIdSet = new Set<Id>();  // Used to hold Account records Ids
        Set<Id> inKindSet = new Set<Id>();  // Used to hold Inkind Account records Ids
        Map<Id, String> chapterMap = new Map<Id, String>();
        Map<Id,String> wishChildNameMap = new Map<Id,String>();
        
        List<ApprovalWrapper> approvalWrapperList = new List<ApprovalWrapper>();
        Map<Id, ApprovalWrapper> approvalWrapperMap = new Map<Id, ApprovalWrapper>();
        for(ProcessInstance process : [SELECT Id,status,ProcessDefinition.Name,TargetObject.Name,TargetObject.Id,SubmittedBy.userRole.Name,TargetObject.Type,CreatedBy.Name,SubmittedBy.Account.Name,SubmittedBy.Name,completedDate,CreatedDate
                                       , (SELECT Id,Actor.Name,OriginalActor.Name,ActorId FROM StepsandWorkItems order by Id desc LIMIT 1)FROM ProcessInstance WHERE ProcessDefinition.Name != 'KBWorkflow' Order by CreatedDate Desc]){
                                           ApprovalWrapper wrap = new ApprovalWrapper();
                                           wrap.processName = process.ProcessDefinition.Name;
                                           wrap.targetObjectId = process.TargetObject.Id;
                                           wrap.recordName = process.TargetObject.Name;
                                           wrap.status = process.status;
                                           wrap.createdBy = process.CreatedBy.Name;
                                           wrap.submittedBy = process.SubmittedBy.Name;
                                           wrap.approvedBy = process.StepsandWorkItems[0].Actor.Name;
                                           wrap.assignedTo = process.StepsandWorkItems[0].OriginalActor.Name;
                                           wrap.submittedDate = String.valueOf(process.CreatedDate.format('MM/dd/yyyy'));
                                           
                                           if(process.completedDate != NULL) {
                                               wrap.completedDate = String.valueOf(process.completedDate.format('MM/dd/yyyy'));
                                           } else {
                                               wrap.completedDate = String.valueOf(process.completedDate);
                                           }
                                           
                                           wrap.objectType = process.TargetObject.Type;
                                           approvalWrapperMap.put(wrap.targetObjectId,wrap);
                                           approvalWrapperList.add(wrap);
                                          
                                           if(process.TargetObject.Type == 'Volunteer_Opportunity__c') {
                                               volOppIdSet.add(process.TargetObject.Id);
                                           }
                                           if(process.TargetObject.Type == 'Case') {
                                               caseIdSet.add(process.TargetObject.Id);
                                           }
                                           if(process.TargetObject.Type == 'Contact') {
                                               conIdSet.add(process.TargetObject.Id);
                                           }
                                           if(process.TargetObject.Type == 'Account') {
                                               accIdSet.add(process.TargetObject.Id);
                                           }
                                           if(process.TargetObject.Type == 'In_Kind_Donation_Reimbursement__c') {
                                               inKindSet.add(process.TargetObject.Id);
                                           }
                                           
                                       }
        
        
        // Used to get Wish Child Name and Chapter Name for the the approval records
        for(Contact conInfo : [SELECT Id, RecordTypeId, Account.Name, Region_Chapter__r.Name FROM Contact WHERE Id IN : conIdSet]) {
            if(conInfo.RecordTypeId == volunteerRecordTypeId) {
                if(conInfo.Account.Name != null) {
                    chapterMap.put(conInfo.Id,conInfo.Account.Name);
                }
            } else if(conInfo.RecordTypeId == wichChildRecordTypeId || conInfo.RecordTypeId == boardMemberRT) {
                
                if(conInfo.Region_Chapter__r.Name != null) {
                    chapterMap.put(conInfo.Id,conInfo.Region_Chapter__r.Name);
                }
            }
        }
        
        
        // Used to get the wish child name and Chapter name for the volunteer Opportunity object related records
        for(Volunteer_Opportunity__c volOpp : [SELECT Id, Chapter_Name__r.Name,Wish__C,Wish__r.Contact.Name FROM Volunteer_Opportunity__c WHERE Id IN : volOppIdSet]) {
            
            if(volOpp.Chapter_Name__r.Name != null) {
                chapterMap.put(volOpp.Id, volOpp.Chapter_Name__r.Name);
            }
            if(volOpp.Wish__c != Null){
                wishChildNameMap.put(volOpp.Id,volOpp.Wish__r.Contact.Name);      
            }
        }
        
        // Used to collecct the wish child name and the chapter name form the case object
        for(Case caseInfo : [SELECT Id, ChapterName__r.Name, Parent.ChapterName__r.Name,Contact.Name,Parent.Contact.Name,RecordTypeId FROM Case WHERE Id IN : caseIdSet]) {
            if(caseInfo.RecordTypeId == wishPlanningRecordTypeId) {
                if(caseInfo.Parent.ChapterName__r.Name != null) {
                    chapterMap.put(caseInfo.Id,caseInfo.Parent.ChapterName__r.Name);
                }
                wishChildNameMap.put(caseInfo.Id,caseInfo.Parent.Contact.Name);
                
            } else if(caseInfo.RecordTypeId == parentWishRecordTypeId) {
                if(caseInfo.ChapterName__r.Name != null) {
                    chapterMap.put(caseInfo.Id,caseInfo.ChapterName__r.Name);
                }
                wishChildNameMap.put(caseInfo.Id,caseInfo.Contact.Name);
            }
        }
        
        
        for(Account inkaccinfo : [SELECT Id, Chapter_Name__r.Name FROM Account WHERE Id IN : accIdSet]) {
            
            if(inkaccinfo.Chapter_Name__r.Name != null && inkaccinfo.RecordTypeId == inKindDonorsAccountRecordTypeId) {
                chapterMap.put(inkaccinfo.Id,inkaccinfo.Chapter_Name__r.Name);
            }
        }
        
        for(In_Kind_Donation_Reimbursement__c ikRemInfo : [SELECT Id, Wish__c,Wish__r.Contact.Name, Wish__r.ChapterName__r.Name FROM In_Kind_Donation_Reimbursement__c WHERE Id IN : inKindSet ]) {
            
            if(ikRemInfo.Wish__r.ChapterName__r.Name != null) {
                chapterMap.put(ikRemInfo.Id,ikRemInfo.Wish__r.ChapterName__r.Name);
            }
            if(ikRemInfo.Wish__c != Null){
                wishChildNameMap.put(ikRemInfo.Id,ikRemInfo.Wish__r.Contact.Name);
            }
        }
        
        for(ApprovalWrapper apprvalWrapper : approvalWrapperMap.values()) {
            if(wishChildNameMap.containsKey(apprvalWrapper.targetObjectId)) {
                approvalWrapperMap.get(apprvalWrapper.targetObjectId).wishChild = wishChildNameMap.get(apprvalWrapper.targetObjectId);
            }
            if(chapterMap.containsKey(apprvalWrapper.targetObjectId)) {
                approvalWrapperMap.get(apprvalWrapper.targetObjectId).chapterName = chapterMap.get(apprvalWrapper.targetObjectId);
            }
        }
        String s = JSON.serialize(approvalWrapperMap.values());
        return s;
    }
    
    // Wrapper class to hold approval process records
    public class ApprovalWrapper {
        public string processName {get;set;}
        public String targetObjectId {get;set;}
        public string chapterName {get;set;}
        public string recordName {get;set;}
        public string wishChild {get;set;}
        public string status {get;set;}
        public string createdBy {get;set;}
        public string submittedBy {get;set;}
        public string approvedBy {get;set;}
        public string assignedTo {get;set;}
        public string submittedDate {get;set;}
        public string completedDate {get;set;}
        public string objectType {get;set;}
    }
    
}