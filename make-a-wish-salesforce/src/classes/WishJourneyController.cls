/*****************************************************************
Description : It will display the Wish and Child Wish status along with period of time.
*****************************************************************/
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
    
    public integer referredDays{get;set;}
    public integer qualifiedDays{get;set;}
    public integer determinationDays{get;set;}
    public integer anticipationDays{get;set;}
    public integer effectDays{get;set;}
    public string contactFName{get;set;}
    public string contactLName{get;set;}
    public string contactId{get;set;}
    
    public boolean blkGrantingOver{get;set;}
    
    public WishJourneyController(ApexPages.StandardController stdController) 
    {
        currCase = (Case)stdController.getRecord();
        currCase = [SELECT Id,RecordType.name,Contact.FirstName,Contact.LastName,status,Days_in_stage__c,Rush__c, 
                    End_Date__c, Parent.End_Date__c, Referral_Date__c, Parent.Referral_Date__c,
                    Qualified_Date__c, Parent.Qualified_Date__c,Anticipated_Wish_Date__c,Parent.ContactId,
                    parent.Contact.FirstName,Parent.Contact.LastName,Anticipated_Start_Date__c,Parent.Anticipated_Start_Date__c,
                    Parent.Anticipated_Wish_Date__c,Wish_Determined_Date__c, Parent.Wish_Determined_Date__c,
                    Parent.Rush__c,contactId FROM CASE WHERE Id = :currCase.id];
                    
                    
                    
        caseWithStatusMap = new Map<string, string>();
        recordTypeWithDaysMap = new Map<string, string>();
        caseRecTypeAndIds = new Map<string, string>();
        mapofCaseRecordTypeIDandName = new Map<String,String>();
        String objectAPIName = 'Case' ; //any object api to which dynamically retriving the record type infos
        Schema.DescribeSObjectResult sobjectResult = Schema.getGlobalDescribe().get(objectAPIName).getDescribe();
        List<Schema.RecordTypeInfo> recordTypeInfo = sobjectResult.getRecordTypeInfos();
        referredDays =0;
        qualifiedDays =0;
        determinationDays = 0;
        anticipationDays =0;
        effectDays =0;
        
                
        for(Schema.RecordTypeInfo info : recordTypeInfo)
        {
            mapofCaseRecordTypeIDandName.put(info.getRecordTypeId(), info.getName());
        }
        
        if(currCase != Null)
        {
           caseWithStatusMap.put(currCase.Recordtype.Name,currcase.status);
           Date currDate = Date.Today();
           
           if(String.valueOf(currCase.Days_in_stage__c) != Null)
               recordTypeWithDaysMap.put(currCase.Recordtype.Name,String.valueOf(currCase.Days_in_stage__c));
           
           if(CurrCase.RecordType.name == 'Wish')
           {
               rushWish = currCase.Rush__c;
               parentCaseID = currCase.id;
               if(currCase.Referral_Date__c != Null)
                   referredDays = (currCase.Referral_Date__c).daysBetween(currDate);
               if(currCase.Qualified_Date__c!= Null)
                   qualifiedDays =(currCase.Qualified_Date__c).daysBetween(currDate);
               if(currCase.Wish_Determined_Date__c!= Null)
                   determinationDays = (currCase.Wish_Determined_Date__c).daysBetween(currDate);
               if(currCase.Anticipated_Start_Date__c!= Null)
               {
                   anticipationDays =(currCase.Anticipated_Start_Date__c).daysBetween(currDate);
                   blkGrantingOver = true;
               }
               if(currCase.Anticipated_Start_Date__c == Null || currCase.Anticipated_Start_Date__c > Date.Today())
               {
                   blkGrantingOver = false;
               }
             
              if(currCase.End_Date__c!= Null)
               effectDays =(currCase.End_Date__c).daysBetween(currDate);
               
               if(currCase.ContactId != Null)
               {
                   contactFName = currCase.Contact.FirstName;
                   contactLName = currCase.Contact.LastName;
                   contactId = currCase.ContactId;
               }
               
           }
           else if(currCase.ParentId != Null)
           {
           
               rushWish = currCase.Parent.Rush__c;
               
            if(currCase.Parent.Referral_Date__c!= Null)
               referredDays = (currCase.Parent.Referral_Date__c).daysBetween(currDate);
               
           if(currCase.Parent.Qualified_Date__c!= Null)
               qualifiedDays =(currCase.Parent.Qualified_Date__c).daysBetween(currDate);
               
            if(currCase.Parent.Wish_Determined_Date__c!= Null)
               determinationDays = (currCase.Parent.Wish_Determined_Date__c).daysBetween(currDate);

            if(currCase.Parent.Anticipated_Start_Date__c!= Null)
            {
               anticipationDays =(currCase.Parent.Anticipated_Start_Date__c).daysBetween(currDate);
               blkGrantingOver = true;
            } 
            if(currCase.Parent.Anticipated_Start_Date__c== Null || currCase.Parent.Anticipated_Start_Date__c> Date.Today())
            {
                   blkGrantingOver = false;
            }
               
            if(currCase.Parent.End_Date__c!= Null)
               effectDays =(currCase.Parent.End_Date__c).daysBetween(currDate);
               
               parentCaseID = currCase.ParentId;
               
               if(currCase.Parent.ContactId != Null)
               {
                   contactFName = currCase.Parent.Contact.FirstName;
                   contactLName = currCase.Parent.Contact.LastName;
                   contactId = currCase.Parent.ContactId;
               }
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
       
           for(Case getCase : [SELECT Id,RecordType.name,status,Days_in_stage__c,Rush__c, Parent.Rush__c,
                               Contact.FirstName,Contact.LastName,contactId FROM CASE WHERE ((ParentId = :parentCaseID AND parentId != Null ) 
                               or id = :parentCaseID )])
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
       if(!caseWithStatusMap.containsKey('Wish Impact'))
       {
          caseWithStatusMap.put('Wish Impact','Not Started');
       }
       if(!caseWithStatusMap.containsKey('Wish Granting'))
       {
          caseWithStatusMap.put('Wish Granting','Not Started');
       }
       if(!caseWithStatusMap.containsKey('Wish Planning'))
       {
          caseWithStatusMap.put('Wish Planning','Not Started');
       }
       
        if(caseRecTypeAndIds.containsKey('Wish'))
             wishId = caseRecTypeAndIds.get('Wish');
         if(caseRecTypeAndIds.containsKey('Wish Assist'))
             assitId = caseRecTypeAndIds.get('Wish Assist');
         if(caseRecTypeAndIds.containsKey('Wish Determination'))
             determinationId = caseRecTypeAndIds.get('Wish Determination');
         if(caseRecTypeAndIds.containsKey('Wish Impact'))
             effectId = caseRecTypeAndIds.get('Wish Impact');  
         if(caseRecTypeAndIds.containsKey('Wish Granting'))
             grantId= caseRecTypeAndIds.get('Wish Granting');  
         if(caseRecTypeAndIds.containsKey('Wish Planning'))
             anticipationId = caseRecTypeAndIds.get('Wish Planning'); 
      
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
       if(!recordTypeWithDaysMap.containsKey('Wish Impact'))
       {
          recordTypeWithDaysMap.put('Wish Impact','');
       }
       if(!recordTypeWithDaysMap.containsKey('Wish Granting'))
       {
          recordTypeWithDaysMap.put('Wish Granting','');
       }
       if(!recordTypeWithDaysMap.containsKey('Wish Planning'))
       {
          recordTypeWithDaysMap.put('Wish Planning','');
       }
     }
   
   
}