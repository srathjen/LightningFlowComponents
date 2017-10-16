/**************************************************************************************
Description : This class used to update volunteer opportunity status as out of compliance or 
approved based on the volunteer role status      
a. Organizational affiliation should be 'Inactive' if volunteer only has one role 
and it is in status of 'former - chapter' - 'former - volunteer' or 'Out of Compliance' 
OR if volunteer has multiple roles and they are all in status of 'former - chapter' - 'former - volunteer' - 'Not Approved' 
or 'Out of Compliance'

b. Organizational affiliation should be 'Active' if volunteer has at least one role in 'Trained'
c. Organizational affiliation should be 'Declined' if volunteer has only one role and it is 'Not Approved'
d. Organizational affiliation should be 'Prospective' if volunteer has registered/completed/cancelled orientation but not completed application
e. Organizational affiliation should be 'Pending' if volunteer has completed application but not training and/or 
other requirements (i.e. not all roles require a training so those volunteers would just need to have interview)
***************************************************************************************/
public class VolunteerRoleTriggerHandler {
    
    public static void updateVolunteerOpportunity(map<id,list<Volunteer_Roles__c>> volRoleMap){
        //list<Volunteer_Opportunity__c> updateVolOppList = new list<Volunteer_Opportunity__c>();
        Map<Id,Volunteer_Opportunity__c> updateVolOppMap = new Map<Id,Volunteer_Opportunity__c>();
        if(volRoleMap.size() > 0){
            for(Volunteer_Opportunity__c currVolOpp : [SELECT ID,Status__c,Chapter_Name__c,Chapter_Name__r.Name,Volunteer_Name__c,Role__c FROM Volunteer_Opportunity__c WHERE Volunteer_Name__c IN: volRoleMap.keySet()]){
                
                if(volRoleMap.containsKey(currVolOpp.Volunteer_Name__c) ){
                    
                    for (Volunteer_Roles__c newVolRole : volRoleMap.get(currVolOpp.Volunteer_Name__c))
                    {
                        if(currVolOpp.Chapter_Name__r.Name == newVolRole.Chapter_Name__c && currVolOpp.Role__c == newVolRole.Role_Name__c ){
                            
                            if(newVolRole.Status__c == 'Trained' && currVolOpp.Status__c == 'Out of Compliance'){
                                
                                currVolOpp.Status__c = 'Approved';
                            }
                            else if(newVolRole.Status__c == 'Out of Compliance' && currVolOpp.Status__c == 'Approved'){
                                
                                currVolOpp.Status__c = 'Out of Compliance';
                            }
                            updateVolOppMap.put(currVolOpp.id,currVolOpp);
                        }
                    }
                }
            }
        }
        if(updateVolOppMap.size() > 0){
            update updateVolOppMap.Values();
        }
    }
    // Updating Affiliation Status based on the Volunteer Role Status.
    Public static void updateVolunteerRoleStatus(map<id,list<Volunteer_Roles__c>> volunteerRoleStatusMap,String action)
    {
        
        if(action == 'Update')
        {
            Map<String,Integer> volunteerRoleCountMap = new Map<String,Integer>();
            Map<id,list<Volunteer_Roles__c>> inActiveSingleStatusMap = new Map<id,list<Volunteer_Roles__c>>();
            Map<id,list<Volunteer_Roles__c>> declinedStatusMap = new Map<id,list<Volunteer_Roles__c>>();
            Map<id,list<Volunteer_Roles__c>> inActiveMultipleStatusMap = new Map<id,list<Volunteer_Roles__c>>();
            Set<Id> trainedVRsSet = new Set<Id>();
            
            for(AggregateResult currRes : [SELECT volunteer_name__c, count(id) cnt FROM Volunteer_Roles__c 
                                           WHERE volunteer_name__c IN :volunteerRoleStatusMap.keySet() GROUP by volunteer_name__c])
            {
                volunteerRoleCountMap.put(String.valueOf(currRes.get('volunteer_name__c')),integer.valueOf(currRes.get('cnt')));
            }
            
            for(Volunteer_Roles__c currRec : [SELECT id, volunteer_name__c, Status__c FROM Volunteer_Roles__c 
                                              WHERE volunteer_name__c IN :volunteerRoleStatusMap.keySet() AND
                                              (Status__c = 'Not Approved'  OR Status__c = 'Former - Volunteer' OR Status__c = 'Out of Compliance'
                                               OR Status__c = 'Former - Chapter' OR Status__c = 'Trained') ])
            {
                if(currRec.Status__c == 'Former - Volunteer' || currRec.Status__c == 'Former - Chapter' 
                   || currRec.Status__c == 'Out of Compliance')
                {
                    if(inActiveSingleStatusMap.containsKey(currRec.Volunteer_Name__c))
                    {
                        inActiveSingleStatusMap.get(currRec.Volunteer_Name__c).add(currRec);
                    }
                    else
                    {
                        inActiveSingleStatusMap.put(currRec.Volunteer_Name__c, new list<Volunteer_Roles__c>{currRec});
                    }
                }
                
                if(currRec.Status__c == 'Former - Volunteer' || currRec.Status__c == 'Former - Chapter' 
                   || currRec.Status__c == 'Not Approved' || currRec.Status__c == 'Out of Compliance')
                {
                    if(inActiveMultipleStatusMap.containsKey(currRec.Volunteer_Name__c))
                    {
                        inActiveMultipleStatusMap.get(currRec.Volunteer_Name__c).add(currRec);
                    }
                    else
                    {
                        inActiveMultipleStatusMap.put(currRec.Volunteer_Name__c, new list<Volunteer_Roles__c>{currRec});
                    }
                }
                
                if(currRec.Status__c == 'Not Approved')
                {
                    if(declinedStatusMap.containsKey(currRec.Volunteer_Name__c))
                    {
                        declinedStatusMap.get(currRec.Volunteer_Name__c).add(currRec);
                    }
                    else
                    {
                        declinedStatusMap.put(currRec.Volunteer_Name__c, new list<Volunteer_Roles__c>{currRec});
                    }
                }
                
                if(currRec.Status__c == 'Trained')
                    trainedVRsSet.add(currRec.Volunteer_Name__c);
                
            }
            
            List<npe5__Affiliation__c> updateRecList = new List<npe5__Affiliation__c>();
            for(npe5__Affiliation__c currRec : [SELECT id, npe5__Contact__c FROM npe5__Affiliation__c  WHERE npe5__Contact__c IN :volunteerRoleStatusMap.keySet()])
            {
                npe5__Affiliation__c updateAff = new npe5__Affiliation__c();
                updateAff.id = currRec.id;
                if(volunteerRoleCountMap.get(currRec.npe5__Contact__c) == 1)
                {
                    if(inActiveSingleStatusMap.containsKey(currRec.npe5__Contact__c))
                        updateAff.npe5__Status__c = 'Inactive';
                    else if(declinedStatusMap.containsKey(currRec.npe5__Contact__c))
                        updateAff.npe5__Status__c = 'Declined';
                }
                else if(volunteerRoleCountMap.get(currRec.npe5__Contact__c) > 1)
                {
                    if(inActiveMultipleStatusMap.containsKey(currRec.npe5__Contact__c) && (inActiveMultipleStatusMap.get(currRec.npe5__Contact__c)).size() == volunteerRoleCountMap.get(currRec.npe5__Contact__c))
                        updateAff.npe5__Status__c = 'Inactive';
                }
                
                if(trainedVRsSet.contains(currRec.npe5__Contact__c))
                    updateAff.npe5__Status__c = 'Active';
                updateRecList.add(updateAff);
            }
            
            if(updateRecList.size() > 0)
                update updateRecList;
        }
        
        if(action == 'Insert')
        {
            List<npe5__Affiliation__c> updateRecList = new List<npe5__Affiliation__c>();
            for(npe5__Affiliation__c currRec : [SELECT id, npe5__Contact__c FROM npe5__Affiliation__c  
                                                WHERE npe5__Contact__c IN :volunteerRoleStatusMap.keySet() 
                                                AND npe5__Status__c != 'Active' AND npe5__Status__c != 'Pending'])
            {
                npe5__Affiliation__c updateAff = new npe5__Affiliation__c();
                updateAff.id = currRec.id;
                updateAff.npe5__Status__c = 'Prospective';
                updateRecList.add(updateAff);
            }
            
            if(updateRecList.size() > 0)
                update updateRecList;
        }
    } 
    //The purpose of this method is to get the volunteer details to update the volunteer BC & COI based on the volunteer role status   
    public static void getVolunteerBasedOnVolunteerRoleStatus(Set<Id> volunteerRoleIdsSet, Set<id> volIdsSet){
        Set<ID> trainingVolunteersIdsSet = new Set<ID>();
        Set<ID> outOfComplianceVolunteersIdsSet = new Set<ID>();
        Set<ID> coiTrainingVolunteerIdsSet = new Set<ID>();
        Set<ID> coiOutOfComplianceVolunteerIdsSet = new Set<ID>();
        Set<ID> coiVOlunteerIdsSet = new Set<ID>();
        Set<ID> volunteerIdsSet = new Set<ID>();
        system.debug('-----> inside getVolunteerBasedOnVolunteerRoleStatus');
        for(Volunteer_Roles__c currVolunteerRole :[SELECT ID,Volunteer_Name__c,Chapter_Role__r.Background_Check_Required__c,Status__c FROM Volunteer_Roles__c WHERE Chapter_Role__c != Null AND Volunteer_Name__c IN: volIdsSet ]){
            if(currVolunteerRole.Status__c == 'Trained' || currVolunteerRole.Status__c == 'Pending Training' || currVolunteerRole.Status__c == 'Chapter Review'){
                system.debug('-----> inside Training' + currVolunteerRole.Status__c + currVolunteerRole.Chapter_Role__r.Background_Check_Required__c);
                if(currVolunteerRole.Chapter_Role__r.Background_Check_Required__c == true){
                    
                    trainingVolunteersIdsSet.add(currVolunteerRole.Volunteer_Name__c);
                    coiTrainingVolunteerIdsSet.add(currVolunteerRole.Volunteer_Name__c);
                }
                else{
                    coiTrainingVolunteerIdsSet.add(currVolunteerRole.Volunteer_Name__c);
                }
                
            }
            else if(currVolunteerRole.Status__c == 'Out of Compliance'){
                if(currVolunteerRole.Chapter_Role__r.Background_Check_Required__c == true){
                    outOfComplianceVolunteersIdsSet.add(currVolunteerRole.Volunteer_Name__c);
                    coiOutOfComplianceVolunteerIdsSet.add(currVolunteerRole.Volunteer_Name__c);
                }
                else{
                    coiOutOfComplianceVolunteerIdsSet.add(currVolunteerRole.Volunteer_Name__c);
                }
                
            }
            else{
                volunteerIdsSet.add(currVolunteerRole.Volunteer_Name__c);
            }
        }
        
        if(trainingVolunteersIdsSet.size() > 0){
            updateBackGroundCheck(trainingVolunteersIdsSet, 'training');
        }
        if(coiTrainingVolunteerIdsSet.size() > 0){
            updateConflictOfInterest(coiTrainingVolunteerIdsSet, 'training');
        }
        
        if(outOfComplianceVolunteersIdsSet.size() > 0){
            updateBackGroundCheck(outOfComplianceVolunteersIdsSet, 'outOfCompliance');
        }
        
        if(coiOutOfComplianceVolunteerIdsSet.size() > 0){
            updateConflictOfInterest(coiOutOfComplianceVolunteerIdsSet, 'outOfCompliance');
        }
        if(volunteerIdsSet.size() > 0 && outOfComplianceVolunteersIdsSet.size() == 0 && trainingVolunteersIdsSet.size() == 0){
            updateBackGroundCheck(volunteerIdsSet, 'none');
        }
        
        if(volunteerIdsSet.size() > 0 && coiOutOfComplianceVolunteerIdsSet.size() == 0 && coiTrainingVolunteerIdsSet.size() == 0){
            updateConflictOfInterest(volunteerIdsSet, 'none');
        }
        
        if(outOfComplianceVolunteersIdsSet.size() > 0 && trainingVolunteersIdsSet.size() == 0){
            updateBackGroundCheck(outOfComplianceVolunteersIdsSet, '1');
        }
        if(coiOutOfComplianceVolunteerIdsSet.size() > 0 && coiTrainingVolunteerIdsSet.size() == 0){
            updateConflictOfInterest(coiOutOfComplianceVolunteerIdsSet, '1');
        }
        
        if(trainingVolunteersIdsSet.size() > 0 && outOfComplianceVolunteersIdsSet.size() == 0 ){
            updateBackGroundCheck(trainingVolunteersIdsSet, '2');
        }
        
        if(coiTrainingVolunteerIdsSet.size() > 0 && coiOutOfComplianceVolunteerIdsSet.size() == 0 ){
            updateConflictOfInterest(coiTrainingVolunteerIdsSet, '2');
        }
    }
    
    // This method is used to update the BC record based on the volunteer role status 
    public static void updateBackGroundCheck(Set<ID> volunteerIdsSet, String status){
        List<Background_check__c> updatebackgroundCheckList = new List<Background_check__c>();
        system.debug('-----> inside updateBackGroundCheck' + status);
        for(Background_check__c currBack: [SELECT ID,Current__c,Volunteer__c FROM Background_check__c WHERE Volunteer__c IN:volunteerIdsSet AND Current__c = true]){
            if(status == 'training' ){
                currBack.VolunteerRoleTrainedTpendChapReview__c = true;
                
            }
            else if(status == 'outOfCompliance' ){
                currBack.VolunteerRoleOutofCompliance__c = true;
            }
            else if(status == 'none'){
                currBack.VolunteerRoleTrainedTpendChapReview__c = false;
                currBack.VolunteerRoleOutofCompliance__c = false;
                
            }
            else if(status == '1'){
                currBack.VolunteerRoleTrainedTpendChapReview__c = false;
            }
            else if(status == '2'){
                currBack.VolunteerRoleOutofCompliance__c = false;
            }
            updatebackgroundCheckList.add(currBack);
        }
        system.debug('-----> inside updatebackgroundCheckList' + updatebackgroundCheckList);
        if(updatebackgroundCheckList.size() > 0){
            update updatebackgroundCheckList;
        }
    }
    
    // This method is used to update the BC record based on the volunteer role status  
    public static void updateConflictOfInterest(Set<ID> volunteerIdsSet, String status){
        List<Conflict_Of_Interest__c> updateConflictList = new List<Conflict_Of_Interest__c>();
        system.debug('-----> inside updateConflictOfInterest' + status);
        for(Conflict_Of_Interest__c currCOI: [SELECT ID,Current__c,Volunteer_Contact__c FROM Conflict_Of_Interest__c WHERE Volunteer_Contact__c IN:volunteerIdsSet AND Current__c = true]){
            system.debug('Inside COI Query'+ currCOI);
            if(status == 'training' ){
                currCOI.VolunteerRoleTrainedTpendChapReview__c = true;
            }
            else if(status == 'outOfCompliance' ){
                currCOI.VolunteerRoleOutofCompliance__c = true;
            }
            else if(status == 'none'){
                currCOI.VolunteerRoleTrainedTpendChapReview__c = false;
                currCOI.VolunteerRoleOutofCompliance__c = false;
            }
            else if(status == '1'){
                currCOI.VolunteerRoleTrainedTpendChapReview__c = false;
            }
            else if(status == '2'){
                currCOI.VolunteerRoleOutofCompliance__c = false;
            }
            updateConflictList.add(currCOI);
        }
        system.debug('---> updateConflictList'+ updateConflictList);
        if(updateConflictList.size() > 0){
            update updateConflictList;
        }
    }
}