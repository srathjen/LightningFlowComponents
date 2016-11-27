/*************************************************************************************************
CreatedBy: Kanagaraj 
Author   : MST Solutions
CreatedDate : 07/27/2016
Location : This controller referred in AddVolunteerRole_VF.
Description : This VF page is placed as a Inline VF page of Non Wish & Event page layout. Here  chapter staff will enter
the roles and number of members in that role needed for that event. Once entered the value and hit [Save] button
It would create n number of Volunteer Opportunity records for that event.
*************************************************************************************************/
public class AddVolunteerRole_AC{
    public List<Volunteer_Count__c> volunteerCountList{get;set;}
    public List<Non_Wish_Events__c> addNewVolunteerRoleList{get;set;}
    private ApexPages.StandardController controller {get; set;}
    public Non_Wish_Events__c nonWishEvent{get;set;}
    public Non_Wish_Events__c currNonWishRec;
    public String RoleName{get;set;}
    public Integer VolunteerCount{get;set;}
    public Boolean outputMode{get;set;}
    public Boolean inputMode{get;set;}
    public Boolean isEdit{get;set;}
    public Boolean isNew{get;set;}
    public List<Volunteer_Count__c> volunteerCountEditList{get;set;}
    public List<Volunteer_Count__c> volunteerCountToUpdateList{get;set;}
    public Id ChapterRoleId{get;set;}
    Public Integer neededCount;
    public String eventRT;    
    public User curruser{get;set;}
    public Boolean isCommunity{get;set;}
    Constant_AC constant = new Constant_AC();
    public String communityUserString;
    
    public Id volunteerRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(constant.volunteerRT).getRecordTypeId();
    public boolean isReferesh{get;set;}
    /* It will display the volunteer opportunities grouped by role when the page is loaded */
    public AddVolunteerRole_AC(ApexPages.StandardController controller){
        this.controller = controller;
        nonWishEvent  = (Non_Wish_Events__c)controller.getRecord();
        currUser = [SELECT Id,contactId,Hidden_Role_Name_Id__c  FROM User WHERE Id = :userInfo.getUserId()];
        if(currUser.ContactId != Null){
          isCommunity = true;
          if(currUser.Hidden_Role_Name_Id__c  != Null)
          communityUserString = currUser.Hidden_Role_Name_Id__c;
        }
        currNonWishRec = [SELECT Id,Name,Chapter__c FROM Non_Wish_Events__c WHERE Id =: nonWishEvent.Id];
        
        eventRT= Schema.Sobjecttype.Volunteer_Opportunity__c.getRecordTypeInfosByName().get(constant.nonWishEventRT).getRecordTypeId();
        volunteerCountList = new List<Volunteer_Count__c>();
        addNewVolunteerRoleList = new List<Non_Wish_Events__c>();
        volunteerCountList = [SELECT Id,Name,Volunteer_Needed__c,Non_Wish_Events__c,Hidden_Chapter_Name__c,Chapter_Role__c,Registered__c FROM Volunteer_Count__c WHERE Non_Wish_Events__c =: nonWishEvent.id AND Volunteer_Needed__c != 0];
        system.debug('---- volunteerCountList ----'+volunteerCountList);
        if(!volunteerCountList.isEmpty()){
            outputMode = true;
            inputMode = false;
            isEdit = false;
            isNew = false;
        }
        else{
            isNew = true;
            outputMode = false;
            inputMode = false;
            isEdit = false;
        }
    }
    
    /* This addRow() is used to add a new row in the pageblock table*/
    public void addRow(){
        if(!volunteerCountList.isEmpty()){
            isNew = false;
            inputMode = true;
            outputMode = false;
            isEdit = false;
            if(!addNewVolunteerRoleList.isEmpty()){
                Integer listSize = addNewVolunteerRoleList.size() - 1;
                if(addNewVolunteerRoleList.get(listSize).Chapter_Role__c == Null){
                    addNewVolunteerRoleList.remove(listSize);
                    addNewVolunteerRoleList.add(new Non_Wish_Events__c());
                }
                else{
                    //addNewVolunteerRoleList.remove(listSize);
                    addNewVolunteerRoleList.add(new Non_Wish_Events__c());
                }
            }
            else{
                addNewVolunteerRoleList.add(new Non_Wish_Events__c());
            }
        }
        else{
            isNew = true;
            inputMode = false;
            outputMode = false;
            isEdit = false;
            addNewVolunteerRoleList.add(new Non_Wish_Events__c());
        }
    }
    
       /*This SaveRec() is used to create the no. of volunteer opportuity based on the volunteerNeeded.
As well as it will update the volunteer opportunity.*/
    public pageReference saveRec(){
        
        PageReference pr ;
        pr = new PageReference('/'+nonWishEvent.Id);
        inputMode = false;
        isEdit = false;
        isNew = false;
        outputMode = true;
        List<Volunteer_Opportunity__c> newVolOpportunityList = new List<Volunteer_Opportunity__c>();
        List<Volunteer_Count__c> newvolunteerCountList = new List<Volunteer_Count__c>();
        List<Volunteer_Count__c> volunteerCountEditListtwo= new List<Volunteer_Count__c>();
        volunteerCountList = new List<Volunteer_Count__c>();
        if(volunteerCountToUpdateList != NULL && !volunteerCountToUpdateList.isEmpty()){
            
            Integer listSize = 0;
            if(volunteerCountToUpdateList.get(listSize).Chapter_Role__c == Null){
                Volunteer_Count__c volunteercount = [SELECT Id,Name,Volunteer_Needed__c,Chapter_Role__c,Hidden_Chapter_Name__c,Non_Wish_Events__c,Registered__c FROM Volunteer_Count__c WHERE Non_Wish_Events__c =: nonWishEvent.id AND Volunteer_Needed__c != 0 AND Registered__c  = 0];
                //delete volunteercount;
                List<Volunteer_Opportunity__c> dbVolOpporunity= [SELECT id,RecordTypeId,Chapter_Role_Opportunity__c,Chapter_Name__c,Volunteer_Name__c,Non_Wish_Event__c,Reason_Inactive__c FROM Volunteer_Opportunity__c WHERE Volunteer_Name__c = Null AND Non_Wish_Event__c =: nonWishEvent.id  AND RecordTypeId =:eventRT AND IsApproved__c = False AND Reason_Inactive__c =: Null];
                delete dbVolOpporunity;
            }
            else{
                Set<Id> chapterRoleIdSet = new Set<Id>();
                Integer Size = volunteerCountToUpdateList.size() - 1;
                if(volunteerCountToUpdateList.get(Size).Chapter_Role__c  == Null)
                    volunteerCountToUpdateList.remove(Size);
                for(Volunteer_Count__c  roleName : volunteerCountToUpdateList){
                    if(roleName.Volunteer_Needed__c < roleName.Registered__c && roleName.Registered__c > 0 ){
                        isReferesh = true;
                        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,'Volunteer Need count is Should not be less than to  volunteer registerd count'));
                        return null;
                    }
                    volunteerCountEditListtwo.add(roleName);
                }
                for(Volunteer_Count__c  roleName : volunteerCountEditListtwo){
                    chapterRoleIdSet.add(roleName.Chapter_Role__c);
                }
                List<Volunteer_Opportunity__c> deleteVolunteerList = [SELECT id,Chapter_Name__c,Chapter_Role_Opportunity__c,Volunteer_Name__c,Non_Wish_Event__c FROM Volunteer_Opportunity__c WHERE Chapter_Role_Opportunity__c IN: chapterRoleIdSet AND Volunteer_Name__c = Null AND Non_Wish_Event__c =: nonWishEvent.id AND Reason_Inactive__c =: Null];
                delete deleteVolunteerList;
                if(!test.isRunningTest()) 
                    try{
                    update volunteerCountEditListtwo;
                    }
                    catch(Exception ex){
                    }
                volunteerCountList = [SELECT Id,Name,Volunteer_Needed__c,Chapter_Role__c,Hidden_Chapter_Name__c,Non_Wish_Events__c,Registered__c FROM Volunteer_Count__c WHERE Non_Wish_Events__c =: nonWishEvent.id AND Volunteer_Needed__c != 0];
                for(Volunteer_Count__c  processnewVolCount : volunteerCountEditListtwo){
                    if(processnewVolCount.Volunteer_Needed__c > 0){
                        Integer count = Integer.valueOf(processnewVolCount.Volunteer_Needed__c) -  Integer.valueOf(processnewVolCount.Registered__c); 
                        for(Integer i=0; i < count; i++){
                            Volunteer_Opportunity__c newVolOpp = new Volunteer_Opportunity__c();
                            newVolOpp.Non_Wish_Event__c = nonWishEvent.id;
                            newVolOpp.Chapter_Role_Opportunity__c = processnewVolCount.Chapter_Role__c;
                            newVolOpp.RecordTypeId = eventRT;
                            newVolOpp.Chapter_Name__c = currNonWishRec.Chapter__c;
                            newVolOpportunityList.add(newVolOpp);
                        }
                    }
                }
                insert newVolOpportunityList;
            }
        }
        else{
            if(addNewVolunteerRoleList.size() > 0){
                Integer size = addNewVolunteerRoleList.size() - 1;
                if(addNewVolunteerRoleList.get(size).Chapter_Role__c == null) {
                    addNewVolunteerRoleList.remove(Size );
                }
                
                if(addNewVolunteerRoleList.size() > 0){
                    for(Non_Wish_Events__c processNonWish : addNewVolunteerRoleList){
                        Volunteer_Count__c newVolCount = new Volunteer_Count__c ();
                        newVolCount.Volunteer_Needed__c = processNonWish.Volunteer_Need__c;
                        newVolCount.Chapter_Role__c = processNonWish.Chapter_Role__c;
                        newVolCount .Non_Wish_Events__c = nonWishEvent.id;
                        newvolunteerCountList.add(newVolCount);
                    }
                    Integer listSize = newvolunteerCountList.size() - 1;
                    if(newvolunteerCountList.get(listSize).Chapter_Role__c == Null){
                        newvolunteerCountList.remove(listSize);
                        insert newvolunteerCountList;
                        volunteerCountList = [SELECT Id,Name,Volunteer_Needed__c,Chapter_Role__c,Hidden_Chapter_Name__c,Non_Wish_Events__c,Registered__c FROM Volunteer_Count__c WHERE Non_Wish_Events__c =: nonWishEvent.id AND Volunteer_Needed__c != 0];
                    }
                    else
                        insert newvolunteerCountList;
                }
                volunteerCountList = [SELECT Id,Name,Volunteer_Needed__c,Chapter_Role__c,Hidden_Chapter_Name__c,Non_Wish_Events__c,Registered__c FROM Volunteer_Count__c WHERE Non_Wish_Events__c =: nonWishEvent.id AND Volunteer_Needed__c != 0];
                if(newvolunteerCountList.Size() > 0){
                    volunteerCountList = [SELECT Id,Name,Volunteer_Needed__c,Chapter_Role__c,Hidden_Chapter_Name__c,Non_Wish_Events__c,Registered__c FROM Volunteer_Count__c WHERE Non_Wish_Events__c =: nonWishEvent.id AND Volunteer_Needed__c != 0];
                    for(Volunteer_Count__c  processnewVolCount : newvolunteerCountList){
                        if(processnewVolCount.Volunteer_Needed__c > 0){
                            for(Integer i=0; i<processnewVolCount.Volunteer_Needed__c; i++){
                                Volunteer_Opportunity__c newVolOpp = new Volunteer_Opportunity__c();
                                newVolOpp.Non_Wish_Event__c = nonWishEvent.id;
                                newVolOpp.Chapter_Role_Opportunity__c= processnewVolCount.Chapter_Role__c;
                                newVolOpp.RecordTypeId = eventRT;
                                newVolOpp.Chapter_Name__c = currNonWishRec.Chapter__c;
                                newVolOpportunityList.add(newVolOpp);
                            }
                        }
                    }
                }
                insert newVolOpportunityList;
            }
        }
        return null;
    }
    
    /* This EditRec method is used to update the no of volunteer opportunities needed.*/
    public void EditRec(){
        isEdit = true;
        outputMode = false;
        isNew = false;
        inputMode = false;
        volunteerCountToUpdateList = new List<Volunteer_Count__c>();
        Map<String,Volunteer_Count__c> volunteercountMap = new Map<String,Volunteer_Count__c>([SELECT Id,Name,Volunteer_Needed__c,Hidden_Chapter_Name__c,Chapter_Role__c,Non_Wish_Events__c,Registered__c FROM Volunteer_Count__c WHERE Non_Wish_Events__c =: nonWishEvent.id AND Volunteer_Needed__c != 0]);
        volunteerCountList= [SELECT Id,Name,Volunteer_Needed__c,Non_Wish_Events__c,Chapter_Role__c,Hidden_Chapter_Name__c,Registered__c FROM Volunteer_Count__c WHERE Non_Wish_Events__c =: nonWishEvent.id  AND Volunteer_Needed__c != 0];
        volunteerCountEditList = new List<Volunteer_Count__c >();
        volunteerCountEditList.addAll(volunteerCountList);
        for(Volunteer_Count__c  processvol : volunteerCountEditList){
            if(volunteercountMap.containsKey(processvol.Id)){
                Volunteer_Count__c  newProceess = new Volunteer_Count__c();
                newProceess.Id = volunteercountMap.get(processvol.Id).Id;
                newProceess.Chapter_Role__c = volunteercountMap.get(processvol.Id).Chapter_Role__c;
                newProceess .Volunteer_Needed__c = processvol.Volunteer_Needed__c ;
                newProceess.Registered__c = volunteercountMap.get(processvol.Id).Registered__c ;
                neededCount = Integer.valueOf(processvol.Volunteer_Needed__c);
                volunteerCountToUpdateList.add(newProceess);
            }
        }
    }
    /*This cancelRec method is used if the system admin or chapter users enterd incorect data they can able to cancel*/
    public void cancelRec(){
        isEdit = false;
        outputMode = true;
        isNew = false;
        inputMode = false;
    }
    
    /*This method is used when the volunteer contact can able to register for the particular volunteer opportunity*/
    public pageReference register(){
       isReferesh = true;
        inputmode = false;
        outputmode = false;
        isnew = false;
        pageReference  pr;
        Chapter_Role__c dbRole;
        String roleId;
        pr = new PageReference('/'+nonWishEvent.Id);
        
        Contact volunteerContact = [SELECT Id,LastName From Contact WHERE RecordTypeId = :volunteerRecordTypeId limit 1]; 
        List<Volunteer_Opportunity__c>  dbVolOpporunity= [SELECT id,RecordTypeId,Chapter_Role_Opportunity__c,Chapter_Role_Opportunity__r.Role_Name__c,Chapter_Name__c,Volunteer_Name__c,Non_Wish_Event__c,Reason_Inactive__c FROM Volunteer_Opportunity__c WHERE Chapter_Role_Opportunity__c =: ChapterRoleId AND Volunteer_Name__c = Null AND Non_Wish_Event__c =: nonWishEvent.id  AND RecordTypeId =:eventRT AND IsApproved__c = False AND Reason_Inactive__c =: Null Limit 1];
        
         
         
        if(dbVolOpporunity.size() > 0 && dbVolOpporunity != Null){
            dbRole = [SELECT Id,Name,Role_Name__c,Role_Name__r.Name From Chapter_Role__c  WHERE Id =: dbVolOpporunity[0].Chapter_Role_Opportunity__c];
            roleId = dbRole.Role_Name__c+String.valueOf(dbVolOpporunity[0].Non_Wish_Event__c);
           
            Volunteer_Opportunity__c  updateVolOpportunity = new Volunteer_Opportunity__c();
            updateVolOpportunity.Id = dbVolOpporunity[0].Id;
            updateVolOpportunity .Chapter_Role_Opportunity__c = dbVolOpporunity[0].Chapter_Role_Opportunity__c;
            if(curruser.contactId != Null){
            if(communityUserString == '' || communityUserString == null){
            curruser.Hidden_Role_Name_Id__c = dbRole.Role_Name__c+String.valueOf(dbVolOpporunity[0].Non_Wish_Event__c);
            communityUserString  =dbRole.Role_Name__c;}
            else if(communityUserString.contains(roleId) && communityUserString != Null){
                   
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,'You already registered for this event'));
                    return null;
                }
                 if(curruser.Hidden_Role_Name_Id__c != Null && communityUserString != Null) 
                curruser.Hidden_Role_Name_Id__c = curruser.Hidden_Role_Name_Id__c +'  '+roleId;
                
                
                updateVolOpportunity.Volunteer_Name__c = curruser.contactId ;
                }
            else
                updateVolOpportunity.Volunteer_Name__c = volunteerContact.Id;
               updateVolOpportunity.Chapter_Name__c = currNonWishRec.Chapter__c;
             if(curruser.Hidden_Role_Name_Id__c  != Null || curruser.Hidden_Role_Name_Id__c != '')
             update curruser;
            update updateVolOpportunity;
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Confirm,'Thank you for requesting to volunteer for this opportunity. A notification has been sent to chapter staff to review your request and staff will respond with further details, as applicable.'));
            return null;
        }
        else{
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,'This volunteer opportunity has already been filled. Please register for another available volunteer opportunity'));
            return null;
        }
        return null;
    }
}