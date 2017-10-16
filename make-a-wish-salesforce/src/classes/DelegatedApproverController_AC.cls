/**************************************************************************************
Author : MST Solutions
Description : This class referred in the DelegatedApprover_VF. It display the all record approval processes . 
This will allow chapter staff to see visibility into their colleagues approval's needed when they are covering for each other.
****************************************************************************************/

public class DelegatedApproverController_AC{
    Constant_AC  constant = new Constant_Ac();   
    Id parentWishRecordTypeId = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get(constant.parentWishRT).getRecordTypeId();
    Id wishPlanningRecordTypeId = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get(constant.wishPlanningAnticipationRT).getRecordTypeId();
    Id volunteerRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(constant.volunteerRT).getRecordTypeId();
    Id wichChildRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(constant.contactWishChildRT).getRecordTypeId();
    Id inKindDonorsAccountRecordTypeId = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get(constant.inKindAccount).getRecordTypeId();
    Id boardMemberRT = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(constant.boardMemberRT).getRecordTypeId();
    
    Public Boolean isErrorFree{get;set;}
    Transient public Map<String,List<ProcessInstance>> approvalMap{get;set;}
    public Transient  String selectedprocessName{get;set;}
    public Transient  String selectedChapter{get;set;}
    public Transient  String selectedApprover{get;set;}
    public Transient  String selectedStatus{get;set;}
    public Transient  String selectedCompltedBy{get;set;}
    public Transient  Set<String> StringSet;
    public List<SelectOption> processItems {get;set;}
    public List<SelectOption> chapterItems {get;set;}   
    public List<SelectOption> approvedByItems {get;set;}  
    //public List<SelectOption> completedByItems {get;set;}
    public List<SelectOption> statusItems {get;set;}   
    Public Transient Map<Id, String> chapterMap {get;set;}
    Set<Id> volOppIdSet;
    Set<Id> conIdSet;
    Set<Id> caseIdSet;
    Set<Id> accIdSet;
    Set<Id> inKindSet;
    Set<String> approverSet;
    public DelegatedApproverController_AC(){
        isErrorFree = true;
        volOppIdSet = new Set<Id>();
        conIdSet = new Set<Id>();
        caseIdSet = new Set<Id>();
        accIdSet = new Set<Id>();
        inKindSet = new Set<Id>();
        chapterMap = new Map<Id, String>();
        approverSet = new Set<String>();
        approvedByItems = new List<SelectOption>();
        approvedByItems.add(new selectOption('','--Select--'));
        processItems= new List<SelectOption>();
        processItems.add(new SelectOption('','--Select--'));
        chapterItems = new List<SelectOption>();
        chapterItems.add(new SelectOption('','--Select--'));
        statusItems = new List<SelectOption>();
        statusItems.add(new SelectOption('','--Select--'));
        statusItems.add(new SelectOption('Approved','Approved'));
        statusItems.add(new SelectOption('Pending','Pending'));       
        statusItems.add(new SelectOption('Rejected','Rejected'));   
        statusItems.sort();    
        approvalMap = new Map<String,List<ProcessInstance>>();
        
        //This get all chapter name from custom setting.
        //for(Chapter_Vs_Role__c currChapter :Chapter_Vs_Role__c.getAll().values()){
        //if(currChapter.Chapter_Name__c != 'Make-A-Wish America')
        //chapterItems.add( new SelectOption(currChapter.Role_Name__c,currChapter.Chapter_Name__c));
        //chapterItems.add( new SelectOption(currChapter.Role_Name__c,currChapter.Chapter_Name__c));
        //}
        for(Account chapterAccount : [SELECT Id, Name FROM Account WHERE RecordType.Name = 'Chapter']) {
            chapterItems.add( new SelectOption(chapterAccount.Name,chapterAccount.Name));
        }
        chapterItems.sort();
        
        loadData();
    }
    
    public void loadData() {
        
        for(ProcessInstance process : [SELECT Id,status,ProcessDefinition.Name,TargetObject.Name,TargetObject.Id,SubmittedBy.userRole.Name,TargetObject.Type,CreatedBy.Name,SubmittedBy.Account.Name,SubmittedBy.Name,completedDate,CreatedDate
                                       , (SELECT Id,Actor.Name,OriginalActor.Name,ActorId FROM StepsandWorkItems order by Id desc LIMIT 1)FROM ProcessInstance WHERE ProcessDefinition.Name != 'KBWorkflow' Order by CreatedDate Desc LIMIT 10000]){
                                           
                                           if(approvalMap.containsKey(process.ProcessDefinition.Name))
                                               approvalMap.get(process.ProcessDefinition.Name).add(process);
                                           else{
                                               approvalMap.put(process.ProcessDefinition.Name,new List<ProcessInstance>{process});   
                                               processItems.add(new SelectOption(process.ProcessDefinition.Name,process.ProcessDefinition.Name));
                                           }
                                           
                                           if(!approverSet.Contains(process.StepsandWorkItems[0].Actor.Name) && (!Test.isRunningTest())){
                                               approverSet.add(process.StepsandWorkItems[0].Actor.Name);
                                               approvedByItems.add(new SelectOption(process.StepsandWorkItems[0].Actor.Name,process.StepsandWorkItems[0].Actor.Name));
                                           }
                                           if(!approverSet.Contains(process.StepsandWorkItems[0].OriginalActor.Name) && (!Test.isRunningTest())){
                                               approverSet.add(process.StepsandWorkItems[0].OriginalActor.Name);
                                               approvedByItems.add(new SelectOption(process.StepsandWorkItems[0].OriginalActor.Name,process.StepsandWorkItems[0].OriginalActor.Name));
                                           }
                                           
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
        approvedByItems.sort();
        processItems.Sort();
        //recChapterInfo();
        for(Volunteer_Opportunity__c volOpp : [SELECT Id, Chapter_Name__r.Name FROM Volunteer_Opportunity__c WHERE Id IN : volOppIdSet]) {
            
            if(volOpp.Chapter_Name__r.Name != null) {
                chapterMap.put(volOpp.Id, volOpp.Chapter_Name__r.Name);
            } else {
                chapterMap.put(volOpp.Id, '-');
            }
        }
        
        for(Case caseInfo : [SELECT Id, ChapterName__r.Name, Parent.ChapterName__r.Name, RecordTypeId FROM Case WHERE Id IN : caseIdSet]) {
            if(caseInfo.RecordTypeId == wishPlanningRecordTypeId) {
                if(caseInfo.Parent.ChapterName__r.Name != null) {
                    chapterMap.put(caseInfo.Id,caseInfo.Parent.ChapterName__r.Name);
                } else {
                    chapterMap.put(caseInfo.Id, '-');
                }
                
            } else if(caseInfo.RecordTypeId == parentWishRecordTypeId) {
                if(caseInfo.ChapterName__r.Name != null) {
                    chapterMap.put(caseInfo.Id,caseInfo.ChapterName__r.Name);
                } else {
                    chapterMap.put(caseInfo.Id, '-');
                }
                
            }
        }
        
        for(Contact conInfo : [SELECT Id, RecordTypeId, Account.Name, Region_Chapter__r.Name FROM Contact WHERE Id IN : conIdSet]) {
            if(conInfo.RecordTypeId == volunteerRecordTypeId) {
                if(conInfo.Account.Name != null) {
                    chapterMap.put(conInfo.Id,conInfo.Account.Name);
                } else {
                    chapterMap.put(conInfo.Id,'-');
                }
                
            } else if(conInfo.RecordTypeId == wichChildRecordTypeId || conInfo.RecordTypeId == boardMemberRT) {
                
                if(conInfo.Region_Chapter__r.Name != null) {
                    chapterMap.put(conInfo.Id,conInfo.Region_Chapter__r.Name);
                } else {
                    chapterMap.put(conInfo.Id,'-');
                }
            }
        }
        
        for(Account inkaccinfo : [SELECT Id, Chapter_Name__r.Name FROM Account WHERE RecordTypeId =: inKindDonorsAccountRecordTypeId AND Id IN : accIdSet]) {
            
            if(inkaccinfo.Chapter_Name__r.Name != null) {
                chapterMap.put(inkaccinfo.Id,inkaccinfo.Chapter_Name__r.Name);
            } else {
                chapterMap.put(inkaccinfo.Id, '-');
            }
        }
        
        for(In_Kind_Donation_Reimbursement__c ikRemInfo : [SELECT Id, Wish__c, Wish__r.ChapterName__r.Name FROM In_Kind_Donation_Reimbursement__c WHERE Id IN : inKindSet ]) {
            
            if(ikRemInfo.Wish__r.ChapterName__r.Name != null) {
                chapterMap.put(ikRemInfo.Id,ikRemInfo.Wish__r.ChapterName__r.Name);
            } else {
                chapterMap.put(ikRemInfo.Id, '-');
            }
        }
        if(chapterMap.size() != approvalMap.size()) {
            System.debug(chapterMap.size() +'>>>>>>'+approvalMap.size());
            isErrorFree = false;
        }
    }
    public void recChapterInfo() {
        
        
    }
    
    public void viewProcess(){
         approvalMap = new Map<String,List<ProcessInstance>>();
        chapterMap = new Map<Id, String>();
        processItems.clear();
        processItems.add(new SelectOption('','--Select--'));
        loadData();
        /*    String Query ='SELECT Id,status,ProcessDefinition.Name,TargetObject.Name,SubmittedBy.userRole.Name,TargetObject.Type,CreatedBy.Name,SubmittedBy.Account.Name,SubmittedBy.Name,completedDate,CreatedDate,(SELECT Id,Actor.Name,ActorId FROM StepsandWorkItems)FROM ProcessInstance';
// List<sObject> processList =  Database.query(Query );
for(ProcessInstance process :  Database.query(Query)){
if(approvalMap.containsKey(process.ProcessDefinition.Name))
approvalMap.get(process.ProcessDefinition.Name).add(process);
else{
approvalMap.put(process.ProcessDefinition.Name,new List<ProcessInstance>{process});   
// Items.add(new SelectOption(process.ProcessDefinition.Name,process.ProcessDefinition.Name));
}                        
}*/
    }
}