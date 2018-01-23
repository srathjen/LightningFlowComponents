/***********************************************************************************************
Created by : Vennila Paramsivam
Author : MST Solutions
Description : Its updating Affiliation status based on the Orientation Registration, Completed. Similary 
Training Registration and Completed. Once Chapter Role based training has been completed for Volunteer,
then volunteer is going to update as a Active Volunteer.
************************************************************************************************/
Public class VolunteerOandTTriggerHandler
{
    // Updating Affiliation status as Active.
    public static void UpdateAffiliationStatusAsActive(Set<Id> volnteerContactIdSet)
    {
        Set<Id> backGroundContactIdsSet = new Set<Id>();
        Set<Id> coiContactIdsSet = new Set<Id>();
        Set<Id> activeContactIdsSet = new Set<Id>();
        List<npe5__Affiliation__c> affiliationList = new List<npe5__Affiliation__c>();
        Set<Id> chapterRoleIds = new Set<Id>();
        Map<Id,Set<Id>> contactChapterRolesMap = new Map<Id, Set<Id>>();
        Map<Id,Set<Id>> chapterRoleOandTMap = new Map<Id,Set<Id>>();
        Set<Id> orientationIds = new Set<Id>();
        Set<Id> contactIds = new Set<Id>();
        Set<String> activeChapterRoleIds = new Set<String>();
        Map<String,Id> volunteerRoleMap = new Map<String,Id>();
        Constant_Ac constant = new Constant_Ac();
        Id trainingRecordTypeId = Schema.Sobjecttype.Orientation_Training__c.getRecordTypeInfosByName().get(constant.trainingRT).getRecordTypeId();
        Map<Id, List<Volunteer_Orientation_Training__c>> volunteerTrainingMap = new Map<Id, List<Volunteer_Orientation_Training__c>>();
        
        for(Background_check__c dbbackgroundCheckRec : [SELECT Id,current__c,Date__c,Volunteer__c FROM Background_check__c  WHERE Volunteer__c IN: volnteerContactIdSet AND Date__c >: Date.Today() ])
        {
            backGroundContactIdsSet.add(dbbackgroundCheckRec.Volunteer__c);
        }
        
        for(Conflict_Of_Interest__c dbconflictInterestRec : [SELECT Id,Expiration_Date__c,Volunteer_Contact__c FROM Conflict_Of_Interest__c  WHERE Volunteer_Contact__c IN: volnteerContactIdSet AND Expiration_Date__c >: Date.Today()])
        {
            coiContactIdsSet.add(dbconflictInterestRec.Volunteer_Contact__c);
        } 
        
        for(Volunteer_Roles__c currRec : [SELECT id, chapter_role__c,Volunteer_Name__c  FROM Volunteer_Roles__c WHERE Volunteer_Name__c IN :volnteerContactIdSet])
        {
            chapterRoleIds.add(currRec.chapter_Role__c);
            if(contactChapterRolesMap.containsKey(currRec.Volunteer_Name__c))
                contactChapterRolesMap.get(currRec.Volunteer_Name__c).add(currRec.chapter_role__c);
            else
                contactChapterRolesMap.put(currRec.Volunteer_Name__c,new Set<Id>{currRec.chapter_role__c});
            
            volunteerRoleMap.put(currRec.Volunteer_Name__c+'-'+currRec.chapter_role__c,currRec.id);
        } 
        
        for(Class_Offering__c currRec : [SELECT Id, Chapter_Role_O_T__r.Chapter_Role__c,Date__c,End_Time__c,Location__c,Chapter_Role_O_T__r.Orientation_Training__c FROM Class_Offering__c WHERE Chapter_Role_O_T__r.Chapter_Role__c IN :chapterRoleIds AND (Date__c > :Date.Today() OR Date__c = Null) AND Chapter_Role_O_T__r.Required__c = True AND Chapter_Role_O_T__r.Orientation_Training__r.RecordTypeId =: trainingRecordTypeId])
        {
            orientationIds.add(currRec.Chapter_Role_O_T__r.Orientation_Training__c);
            if(chapterRoleOandTMap.containsKey(currRec.Chapter_Role_O_T__r.Chapter_Role__c))
            {
                chapterRoleOandTMap.get(currRec.Chapter_Role_O_T__r.Chapter_Role__c).add(currRec.Chapter_Role_O_T__r.Orientation_Training__c);
            }
            else
            {
                chapterRoleOandTMap.put(currRec.Chapter_Role_O_T__r.Chapter_Role__c,new Set<Id>{currRec.Chapter_Role_O_T__r.Orientation_Training__c});
            }
        }
        
        /* for(Chapter_Role_O_T__c currRec : [SELECT Id, Orientation_Training__c, Chapter_Role__c FROM Chapter_Role_O_T__c  WHERE Chapter_Role__c IN :chapterRoleIds AND Orientation_Training__r.Date__c > :Date.Today()])
{
orientationIds.add(currRec.Orientation_Training__c);
if(chapterRoleOandTMap.containsKey(currRec.Chapter_Role__c))
{
chapterRoleOandTMap.get(currRec.Chapter_Role__c).add(currRec.Orientation_Training__c);
}
else
{
chapterRoleOandTMap.put(currRec.Chapter_Role__c,new Set<Id>{currRec.Orientation_Training__c});
}
} */
        
        for(Volunteer_Orientation_Training__c currTraining : [SELECT id, Volunteer__c,Hidden_O_T_Id__c FROM Volunteer_Orientation_Training__c WHERE Volunteer__c IN :volnteerContactIdSet AND Hidden_O_T_Id__c IN :orientationIds AND Type__c = 'Training' AND Volunteer_Attendance__c = 'Completed'])
        {
            if(volunteerTrainingMap.containsKey(currTraining.Hidden_O_T_Id__c))
                volunteerTrainingMap.get(currTraining.Hidden_O_T_Id__c).add(currTraining);
            else
                volunteerTrainingMap.put(currTraining.Hidden_O_T_Id__c, new List<Volunteer_Orientation_Training__c>{currTraining});
        }
        
        
        
        for(Id currConId : volnteerContactIdSet)
        {
            for(Id currChapRolId : contactChapterRolesMap.get(currConId))
            { 
                Integer trainingSize = 0;
                if(chapterRoleOandTMap.containsKey(currChapRolId))
                {
                    for(Id currOrientationId : chapterRoleOandTMap.get(currChapRolId)) 
                    {
                        
                        if(volunteerTrainingMap.containsKey(currOrientationId))
                        {
                            for(Volunteer_Orientation_Training__c Training : volunteerTrainingMap.get(currOrientationId))
                            {
                                trainingSize = trainingSize + 1;
                                
                            }
                        }
                        
                    }
                }
                
                if( chapterRoleOandTMap.containsKey(currChapRolId))
                {
                    if(trainingSize == (chapterRoleOandTMap.get(currChapRolId).size()))
                    {
                        contactIds.add(currConId);
                        activeChapterRoleIds.add(currConId+'-'+currChapRolId);
                    }
                }
            }
            
        }
        
        
        for(npe5__Affiliation__c dbAffiliationRec : [SELECT Id,npe5__Contact__c,npe5__Primary__c,npe5__Status__c,npe5__Organization__c FROM npe5__Affiliation__c WHERE npe5__Contact__c IN: contactIds]){
            
            if(coiContactIdsSet.contains(dbAffiliationRec.npe5__Contact__c))
            {
                npe5__Affiliation__c updateAff = new npe5__Affiliation__c();
                updateAff.id = dbAffiliationRec.id;
                updateAff.npe5__Status__c = 'Active';
                affiliationList.add(updateAff);
                activeContactIdsSet.add(dbAffiliationRec.npe5__Contact__c);
            }
            
            
        }
        
        List<Volunteer_Roles__c> volRoleList  = new List<Volunteer_Roles__c>();
        for(String currString  : activeChapterRoleIds)
        {
            if(volunteerRoleMap.containsKey(currString))
            {
                Volunteer_Roles__c updateRec = new Volunteer_Roles__c();
                updateRec.id = volunteerRoleMap.get(currString);
                updateRec.status__c = 'Trained';
                volRoleList.add(updateRec);
            }
            
        }
        
        if(affiliationList.size() > 0)
        {
            update affiliationList;
            if(activeContactIdsSet.size() > 0)
            {
                VolunteerOandTHandler.updateUser(activeContactIdsSet);
            }
            if(volRoleList.size() > 0)
                update volRoleList;
        }  
        
        List<Contact> updateContactList = new List<Contact>();
        
        for(Id currContactId : volnteerContactIdSet)
        {
            
            Contact updatecon = new Contact();
            updateCon.id = currContactId;
            updateCon.Last_Continuing_Edu_Date__c= Date.Today();
            updateCon.Date_of_last_engagement__c = Date.Today();
            if(activeContactIdsSet.size() > 0)
            {
                if(activeContactIdsSet.contains(currContactId))
                {
                    //   updateCon.is_Active_Volunteer__c = True;
                }
            }
            updateContactList.add(updateCon);
        }
        
        if(updateContactList.size() > 0)
            update updateContactList;
    }
    
    //This method is used to update the volunteer contact field to send an email to volunteer.
    public static void UpdateContactRec(List<Volunteer_Orientation_Training__c >volunteerOrientationTrainingList)
    {    
        Map<Id,Id>volunteerOandTMap= new Map<Id,Id>();
        Map<Id,Class_Offering__c> classOffringMap = new Map<Id,Class_Offering__c>();
        Map<Id,Volunteer_Orientation_Training__c > volunteerTrainingMap = new Map<Id,Volunteer_Orientation_Training__c >();
        Map<Id,User> UserMap = new Map<Id,User>();
        Constant_Ac constant = new Constant_Ac();
        boolean isCanceled = false;
        Set<Id> dbSet = new Set<Id>();
        String status;
        Set<Id> volunteerIdSet = new Set<Id>();
        Set<Id> currentId = new Set<Id>();
        Id selfbasedRecType = Schema.Sobjecttype.Class_Offering__c .getRecordTypeInfosByName().get(constant.selfBased).getRecordTypeId();
        Id VolunteerConRecType = Schema.Sobjecttype.Contact.getRecordTypeInfosByName().get(constant.volunteerRT).getRecordTypeId();
        for(Volunteer_Orientation_Training__c processVolunteerOpp : volunteerOrientationTrainingList){
            volunteerOandTMap.put(processVolunteerOpp.Class_Offering__c,processVolunteerOpp.Volunteer__c);
            volunteerIdSet.add(processVolunteerOpp.Volunteer__c);
            status = processVolunteerOpp.Volunteer_Attendance__c;
            IF(processVolunteerOpp.Id != Null){
                currentId.add(processVolunteerOpp.Id);
            }
            
        }
        if(volunteerOandTMap.size() > 0){
            for(Class_Offering__c dbClassOffering : [SELECT Id,Chapter_Role_O_T__c,RecordTypeId FROM Class_Offering__c  WHERE Id IN: volunteerOandTMap.KeySet() AND RecordTypeId =: selfbasedRecType]){
                if(volunteerOandTMap.containsKey(dbClassOffering.Id)){
                    classOffringMap.put(dbClassOffering.Id,dbClassOffering);
                    
                }
            }
            
            
        }    
        if(classOffringMap.size() > 0){
            
            for(User dbUser : [SELECT Id,UserName,ContactId,ProfileId,Profile.Name FROM User WHERE ContactId IN:volunteerIdSet AND (Profile.Name =: 'Prospective Volunteer (Login)' OR Profile.Name =: 'Prospective Volunteer (Member)')]){
                UserMap.put(dbUser.ContactId,dbUser);
                
            }
            
        }
        
        if(status == 'Volunteer Cancelled' && currentId.size() > 0){
            for(Volunteer_Orientation_Training__c  dbVolunteerOrientation : [SELECT Id,Volunteer__c,Type__c,Volunteer_Attendance__c  FROM Volunteer_Orientation_Training__c  WHERE Volunteer__c IN:UserMap.KeySet() AND Type__c =: 'Training' AND Id NOT IN: currentId]){
                if(dbVolunteerOrientation.Volunteer_Attendance__c == 'Registered'){
                    dbSet.add(dbVolunteerOrientation.Id);
                }
            }
            
            if(dbSet.size() == 0){
                isCanceled = true;
            }
            
        }
        
        if(UserMap.size() > 0){
            
            for(Volunteer_Orientation_Training__c processVolunteerOpp : volunteerOrientationTrainingList){
                
                if(classOffringMap.containsKey(processVolunteerOpp.Class_Offering__c)){
                    
                    if(UserMap.containsKey(processVolunteerOpp.Volunteer__c)){
                        
                        if(processVolunteerOpp.Volunteer_Attendance__c != 'Volunteer Cancelled'){
                            
                            processVolunteerOpp.Hidden_Volunteer_Training_Status__c = processVolunteerOpp.Volunteer_Attendance__c;
                        }
                        if(processVolunteerOpp.Volunteer_Attendance__c == 'Volunteer Cancelled' && isCanceled == true){
                            processVolunteerOpp.Hidden_Volunteer_Training_Status__c = processVolunteerOpp.Volunteer_Attendance__c;
                        }
                        processVolunteerOpp.Hidden_Volunteer_User_Name__c = UserMap.get(processVolunteerOpp.Volunteer__c).UserName;
                    }
                }
            }
        }
    }
    
    
    
    Public static void updateVolunteerHiddenVolOTStatus(Set<Id> volIdsSet, String action){
        List<Contact> updateContactList = new List<Contact>();
        for(Contact currentCon:[SELECT Id,Hidden_Volunteer_OT_Status__c FROM Contact WHERE Id in:volIdsSet])
        {
            if(action=='training'){
                currentCon.Hidden_Volunteer_OT_Status__c='Training Registered';
            }
            if(action=='Orientation'){
                currentCon.Hidden_Volunteer_OT_Status__c='Orientation With Completed';
            }
            updateContactList.add(currentCon);
        }
        
        if(updateContactList.size() > 0){
            update updateContactList;
        }
    }
    
    Public static void updateUserVolunteerStatus(Set<Id> volunteerContactIds, string Action){
        system.debug('inside user update method ---> ' + volunteerContactIds +  Action);
        List<User> userUpdateList=new List<User>();
        for(User userupdate:[SELECT Id,Volunteer_Orientation_Status__c,Profile.Name FROM User WHERE ContactId in:volunteerContactIds and (Profile.Name = 'Prospective Volunteer (Member)' OR Profile.Name = 'Prospective Volunteer (Login)')])
        {   system.debug('current User' + userupdate);
         User userUpdatebol=new User();
         if(Action == 'Registered'){
             system.debug('Inside Registered' + Action);
             userUpdatebol.Volunteer_Orientation_Status__c='Registered';
             system.debug('Volunteer_Orientation_Status__c -----> '+ userUpdatebol.Volunteer_Orientation_Status__c);
         }
         else if(Action == 'Volunteer Cancelled'){
             system.debug('Inside Cancelled' + Action);
             userUpdatebol.Volunteer_Orientation_Status__c='Cancelled'; 
             system.debug('Volunteer_Orientation_Status__c' + userUpdatebol.Volunteer_Orientation_Status__c);
         }
         userUpdatebol.Id=userupdate.Id;
         userUpdateList.add(userUpdatebol);
        }
        system.debug('userUpdateList ---->' + userUpdateList);
        if(userUpdateList.size() > 0){
            update userUpdateList;
        }
    }
}