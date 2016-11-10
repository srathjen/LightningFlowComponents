public class WishJourneyController{
    public Case currCase{get;set;}
    String wishRecTypeId = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get('Wish').getRecordTypeId();
    public Map<string, string> caseWithStatusMap{get;set;} 
    public Map<string, string> recordTypeWithDaysMap{get;set;} 
    public Map<string,string> caseRecTypeAndIds{get;set;}
    public Map<String,String> mapofCaseRecordTypeIDandName{get;set;}
    public boolean rushWish{get;set;}
    public string parentCaseID{get;set;}
    
    public string wishId{get;set;}
    public string grantId{get;set;}
    public string assitId{get;set;}
    public string anticipationId{get;set;}
    public string determinationId{get;set;}
    public string effectId{get;set;}
    
    public boolean inActive{get;set;}
    public boolean escalated{get;set;}
    public boolean onHold{get;set;}

    public boolean granted{get;set;} 
    public boolean qualified{get;set;}
    public boolean readytoAssign{get;set;}
    public boolean wishDetermined{get;set;}

    public boolean newStatus{get;set;} 
    public boolean completed{get;set;} 
    public boolean closed{get;set;}
    
    
    public WishJourneyController(ApexPages.StandardController stdController) 
    {
        currCase = (Case)stdController.getRecord();
        currCase = [SELECT Id,RecordType.name,Contact.FirstName,Contact.LastName,status,Days_in_stage__c,Rush__c, 
                    Parent.Rush__c,contactId FROM CASE WHERE Id = :currCase.id];
        caseWithStatusMap = new Map<string, string>();
        recordTypeWithDaysMap = new Map<string, string>();
        caseRecTypeAndIds = new Map<string, string>();
        mapofCaseRecordTypeIDandName = new Map<String,String>();
        String objectAPIName = 'Case' ; //any object api to which dynamically retriving the record type infos
        Schema.DescribeSObjectResult sobjectResult = Schema.getGlobalDescribe().get(objectAPIName).getDescribe();
        List<Schema.RecordTypeInfo> recordTypeInfo = sobjectResult.getRecordTypeInfos();        
        for(Schema.RecordTypeInfo info : recordTypeInfo)
        {
            mapofCaseRecordTypeIDandName.put(info.getRecordTypeId(), info.getName());
        }
        
        if(currCase != Null)
        {
           caseWithStatusMap.put(currCase.Recordtype.Name,currcase.status);
           if(String.valueOf(currCase.Days_in_stage__c) != Null)
               recordTypeWithDaysMap.put(currCase.Recordtype.Name,String.valueOf(currCase.Days_in_stage__c));
           
           if(CurrCase.RecordType.name == 'Wish')
           {
               rushWish = currCase.Rush__c;
               parentCaseID = currCase.id;
           }
           else if(currCase.ParentId != Null)
           {
               rushWish = currCase.Parent.Rush__c;
               parentCaseID = currCase.ParentId;
           }
               
            if(!caseRecTypeAndIds.containsKey(CurrCase.recordType.Name))
            {
                        caseRecTypeAndIds.put(CurrCase.recordType.Name, CurrCase.id);
            }
            
            
            if(currCase.Status == 'Inactive')
                inActive = True;
            if(currCase.Status == 'On Hold')
                onHold = True;
            if(currCase.status == 'Escalated')
                escalated=True;
            if(currCase.status == 'Granted')
                granted = True;
            if(currCase.status == 'Qualified')
                qualified = True;
            if(currCase.status == 'Ready to Assign')
                readytoAssign = True;
            if(currCase.status == 'Wish Determined')
                wishDetermined = True;    
            if(currCase.status == 'New')
                newStatus = True; 
            if(currCase.status == 'Completed')
                completed = True; 
            if(currCase.status == 'Closed')
                closed = True;            
                 

        }
        
        getCases();
     }
    
     public void getCases()
     {
        if(currCase.ContactId != Null)
        {
           
          
           for(Case getCase : [SELECT Id,RecordType.name,status,Days_in_stage__c,Rush__c, Parent.Rush__c,
                               Contact.FirstName,Contact.LastName,contactId FROM CASE WHERE (ParentId = :parentCaseID or id = :parentCaseID )])
           {
             if(!caseWithStatusMap.containsKey(getCase.RecordType.name))
             {
                caseWithStatusMap.put(getCase.Recordtype.Name,getCase.status);
             }
             if(!recordTypeWithDaysMap.containsKey(getCase.RecordType.name))
             {
              if(String.valueOf(getCase.Days_in_stage__c) != Null)
               recordTypeWithDaysMap.put(getCase.Recordtype.Name,String.valueOf(getCase.Days_in_stage__c));
             }
             if(getCase.Recordtype.Name == 'Wish')
                parentCaseID = currCase.id;
            if(!caseRecTypeAndIds.containsKey(getCase.recordType.Name))
            {
                caseRecTypeAndIds.put(getCase.recordType.Name,getCase.id);
            }
           }
           
        }
     
       if(!caseWithStatusMap.containsKey('Wish'))
       {
          caseWithStatusMap.put('Wish','Not Started');
       }
       if(!caseWithStatusMap.containsKey('Wish Assist'))
       {
          caseWithStatusMap.put('Wish Assist','Not Started');
       }
       if(!caseWithStatusMap.containsKey('Wish Determination'))
       {
          caseWithStatusMap.put('Wish Determination','Not Started');
       }
       if(!caseWithStatusMap.containsKey('Wish Effect'))
       {
          caseWithStatusMap.put('Wish Effect','Not Started');
       }
       if(!caseWithStatusMap.containsKey('Wish Granted'))
       {
          caseWithStatusMap.put('Wish Granted','Not Started');
       }
       if(!caseWithStatusMap.containsKey('Wish Planning & Anticipation'))
       {
          caseWithStatusMap.put('Wish Planning & Anticipation','Not Started');
       }
       
        if(caseRecTypeAndIds.containsKey('Wish'))
             wishId = caseRecTypeAndIds.get('Wish');
         if(caseRecTypeAndIds.containsKey('Wish Assist'))
             assitId = caseRecTypeAndIds.get('Wish Assist');
         if(caseRecTypeAndIds.containsKey('Wish Determination'))
             determinationId = caseRecTypeAndIds.get('Wish Determination');
         if(caseRecTypeAndIds.containsKey('Wish Effect'))
             effectId = caseRecTypeAndIds.get('Wish Effect');  
         if(caseRecTypeAndIds.containsKey('Wish Granted'))
             grantId= caseRecTypeAndIds.get('Wish Granted');  
         if(caseRecTypeAndIds.containsKey('Wish Planning & Anticipation'))
             anticipationId = caseRecTypeAndIds.get('Wish Planning & Anticipation'); 
      
       if(!recordTypeWithDaysMap.containsKey('Wish'))
       {
          recordTypeWithDaysMap.put('Wish','');
       }
       if(!recordTypeWithDaysMap.containsKey('Wish Assist'))
       {
          recordTypeWithDaysMap.put('Wish Assist','');
       }
       if(!recordTypeWithDaysMap.containsKey('Wish Determination'))
       {
          recordTypeWithDaysMap.put('Wish Determination','');
       }
       if(!recordTypeWithDaysMap.containsKey('Wish Effect'))
       {
          recordTypeWithDaysMap.put('Wish Effect','');
       }
       if(!recordTypeWithDaysMap.containsKey('Wish Granted'))
       {
          recordTypeWithDaysMap.put('Wish Granted','');
       }
       if(!recordTypeWithDaysMap.containsKey('Wish Planning & Anticipation'))
       {
          recordTypeWithDaysMap.put('Wish Planning & Anticipation','');
       }
     }
  
   
}