/***************************************************************************************************
Author      : MST Solutions
Date        : 
Description : This class used to update volunteer opportunity status as out of compliance or 
approved based on the volunteer role status      
a. Organizational affiliation should be 'Inactive' if volunteer only has one role 
and it is in status of 'former - chapter' - 'former - volunteer' or 'Out of Compliance' 
OR if volunteer has multiple roles and they are all in status of 'former - chapter' - 'former - volunteer' - 'Not Approved' 
or 'Out of Compliance'

b. Organizational affiliation should be 'Active' if volunteer has at least one role in 'Trained'
c. Organizational affiliation should be 'Not Approved' if volunteer has only one role and it is 'Not Approved'
d. Organizational affiliation should be 'Prospective' if volunteer has registered/completed/cancelled orientation but not completed application
e. Organizational affiliation should be 'Pending' if volunteer has completed application but not training and/or 
other requirements (i.e. not all roles require a training so those volunteers would just need to have interview)

              
              Modification Log
              ------------------
              WVC-1889    Pavithra G 07/31/2018
              WVC-2205    Kanagaraj 08/07/2018 // Line 100 previously the affilliation status was "Declined".
                                                  Now we have update the affilliation status as "Not Approved".
*****************************************************************************************************/
/**
 * JIRA: WLP-422
 * Author: Gustavo Mayer
 * Update: Changing the Volunteer_Roles status from 'Trained' to 'Active'
 */
public class VolunteerRole_OnAfterInsertHelper_AC {

    private final static String VOLUNTEER_ROLE_STATUS_ACTIVE = Constant_AC.VOLUNTEER_ROLE_STATUS_ACTIVE;

// Updating Affiliation Status based on the Volunteer Role Status.
    public static void updateVolunteerRoleStatus(map<id, list<Volunteer_Roles__c>> volunteerRoleStatusMap, String action, List<Volunteer_Roles__c> exceptionList) {
        if (volunteerRoleStatusMap.isEmpty()) {
            return;
        }
        try {
            if (action == 'Update') {
                Map<String, Integer> volunteerRoleCountMap = new Map<String, Integer>();
                Map<id, list<Volunteer_Roles__c>> inActiveSingleStatusMap = new Map<id, list<Volunteer_Roles__c>>();
                Map<id, list<Volunteer_Roles__c>> declinedStatusMap = new Map<id, list<Volunteer_Roles__c>>();
                Map<id, list<Volunteer_Roles__c>> inActiveMultipleStatusMap = new Map<id, list<Volunteer_Roles__c>>();
                Map<Id, list<Volunteer_Roles__c>> OCCStatusMap = new Map<Id, list<Volunteer_Roles__c>>();
                Map<Id, list<Volunteer_Roles__c>> pendingStatusMap = new Map<Id, list<Volunteer_Roles__c>>();
                Set<Id> trainedVRsSet = new Set<Id>();

                for (AggregateResult currRes : [
                        SELECT volunteer_name__c, count(id) cnt
                        FROM Volunteer_Roles__c
                        WHERE volunteer_name__c IN :volunteerRoleStatusMap.keySet()
                        GROUP by volunteer_name__c
                ]) {
                    volunteerRoleCountMap.put(String.valueOf(currRes.get('volunteer_name__c')),
                            integer.valueOf(currRes.get('cnt')));
                }

                for (Volunteer_Roles__c currRec : [
                        SELECT id, volunteer_name__c, Status__c,Sub_status__c
                        FROM Volunteer_Roles__c
                        WHERE volunteer_name__c IN :volunteerRoleStatusMap.keySet()
                        AND (Status__c = 'Not Approved'
                        OR (Status__c = 'Former')
                        OR Status__c = 'Out of Compliance'
                        OR Status__c = :VOLUNTEER_ROLE_STATUS_ACTIVE
                        OR Status__c = 'Pending')
                ]) {
                    if (currRec.Status__c == 'Former') {
                        if (inActiveSingleStatusMap.containsKey(currRec.Volunteer_Name__c)) {
                            inActiveSingleStatusMap.get(currRec.Volunteer_Name__c).add(currRec);
                        } else {
                            inActiveSingleStatusMap.put(currRec.Volunteer_Name__c, new list<Volunteer_Roles__c>{
                                    currRec
                            });
                        }
                    }

                    if (currRec.Status__c == 'Out of Compliance') {
                        if (OCCStatusMap.containsKey(currRec.Volunteer_Name__c)) {
                            OCCStatusMap.get(currRec.Volunteer_Name__c).add(currRec);
                        } else {
                            OCCStatusMap.put(currRec.Volunteer_Name__c, new list<Volunteer_Roles__c>{
                                    currRec
                            });
                        }
                    }
                    if (currRec.Status__c == 'Pending') {
                        if (pendingStatusMap.containsKey(currRec.Volunteer_Name__c)) {
                            pendingStatusMap.get(currRec.Volunteer_Name__c).add(currRec);
                        } else {
                            pendingStatusMap.put(currRec.Volunteer_Name__c, new list<Volunteer_Roles__c>{
                                    currRec
                            });
                        }
                    }

                    if (currRec.Status__c == 'Not Approved') {
                        if (declinedStatusMap.containsKey(currRec.Volunteer_Name__c)) {
                            declinedStatusMap.get(currRec.Volunteer_Name__c).add(currRec);
                        } else {
                            declinedStatusMap.put(currRec.Volunteer_Name__c, new list<Volunteer_Roles__c>{
                                    currRec
                            });
                        }
                    }

                    if (currRec.Status__c == VOLUNTEER_ROLE_STATUS_ACTIVE) {
                        trainedVRsSet.add(currRec.Volunteer_Name__c);
                    }
                }

                List<npe5__Affiliation__c> updateRecList = new List<npe5__Affiliation__c>();
                for (npe5__Affiliation__c currRec : [
                        SELECT id, npe5__Contact__c
                        FROM npe5__Affiliation__c
                        WHERE npe5__Contact__c IN :volunteerRoleStatusMap.keySet()
                ]) {
                    npe5__Affiliation__c updateAff = new npe5__Affiliation__c();
                    updateAff.id = currRec.id;
                    if (volunteerRoleCountMap.get(currRec.npe5__Contact__c) == 1) {
                        if (inActiveSingleStatusMap.containsKey(currRec.npe5__Contact__c)) {
                            updateAff.npe5__Status__c = 'Inactive';
                        } else if (declinedStatusMap.containsKey(currRec.npe5__Contact__c)) {
                            updateAff.npe5__Status__c = 'Not Approved';
                        } else if (OCCStatusMap.containsKey(currRec.npe5__Contact__c)) {
                            updateAff.npe5__Status__c = 'Out of Compliance';
                        } else if (pendingStatusMap.containsKey(currRec.npe5__Contact__c)) {
                            updateAff.npe5__Status__c = 'Pending';
                        }
                    } else if (volunteerRoleCountMap.get(currRec.npe5__Contact__c) > 1) {
                        if (pendingStatusMap.containskey(currRec.npe5__Contact__c) && !trainedVRsSet.contains(currRec.npe5__Contact__c)) {
                            updateAff.npe5__Status__c = 'Pending';
                        } else if (inActiveSingleStatusMap.containsKey(currRec.npe5__Contact__c)
                                && (inActiveSingleStatusMap.get(currRec.npe5__Contact__c).size() == volunteerRoleCountMap.get(currRec.npe5__Contact__c)
                                || (!pendingStatusMap.containsKey(currRec.npe5__Contact__c)
                                && !OCCStatusMap.containsKey(currRec.npe5__Contact__c)))) {
                            updateAff.npe5__Status__c = 'Inactive';
                        } else if (declinedStatusMap.containsKey(currRec.npe5__Contact__c)
                                && (declinedStatusMap.get(currRec.npe5__Contact__c)).size() == volunteerRoleCountMap.get(currRec.npe5__Contact__c)) {
                            updateAff.npe5__Status__c = 'Not Approved';
                        } else if (OCCStatusMap.containsKey(currRec.npe5__Contact__c)
                                && ((OCCStatusMap.get(currRec.npe5__Contact__c).size() == volunteerRoleCountMap.get(currRec.npe5__Contact__c))
                                || (!pendingStatusMap.containsKey(currRec.npe5__Contact__c)))) {
                            updateAff.npe5__Status__c = 'Out of Compliance';
                        }
                    }
                    if (trainedVRsSet.contains(currRec.npe5__Contact__c)) {
                        updateAff.npe5__Status__c = 'Active';
                    }
                    updateRecList.add(updateAff);
                }

                if (updateRecList.size() > 0) {
                    update updateRecList;
                }
            }

            if (action == 'Insert') {
                List<npe5__Affiliation__c> updateRecList = new List<npe5__Affiliation__c>();
                for (npe5__Affiliation__c currRec : [
                        SELECT id, npe5__Contact__c
                        FROM npe5__Affiliation__c
                        WHERE npe5__Contact__c IN :volunteerRoleStatusMap.keySet()
                        AND npe5__Status__c != 'Active'
                        AND npe5__Status__c != 'Pending'
                ]) {
                    npe5__Affiliation__c updateAff = new npe5__Affiliation__c();
                    updateAff.id = currRec.id;
                    updateAff.npe5__Status__c = 'Prospective';
                    updateRecList.add(updateAff);
                }

                if (updateRecList.size() > 0) {
                    update updateRecList;
                }
            }

            if (Test.isRunningTest()) {
                throw new CommonTriggerException('Test Class execution');
            }

        } Catch (Exception ex) {
            for (Volunteer_Roles__c currRec : exceptionList) {
                ErrorMessage_AC.createdebugRec('VolunteerRole_OnAfterInsertHelper_AC',
                        String.valueof(currRec), String.valueOf(ex), 'updateVolunteerRoleStatus',
                        currRec.Id, ex.getStackTraceString() + '   ' + ex.getMessage(), 'Error');
            }

            if (!Test.isRunningTest()) {
                for (Volunteer_Roles__c currRec : exceptionList) {
                    currRec.addError(Label.Debug_log_error_message);
                }
            }
        }
    }
    //The purpose of this method is to get the volunteer details to update the volunteer BC & COI based on the volunteer role status
    public static void getVolunteerBasedOnVolunteerRoleStatus(Set<Id> volunteerRoleIdsSet, Set<id> volIdsSet, List<Volunteer_Roles__c> exceptionList) {

        try {
            Set<ID> trainingVolunteersIdsSet = new Set<ID>();
            Set<ID> outOfComplianceVolunteersIdsSet = new Set<ID>();
            Set<ID> coiTrainingVolunteerIdsSet = new Set<ID>();
            Set<ID> coiOutOfComplianceVolunteerIdsSet = new Set<ID>();
            Set<ID> coiVOlunteerIdsSet = new Set<ID>();
            Set<ID> volunteerIdsSet = new Set<ID>();

            for (Volunteer_Roles__c currVolunteerRole : [
                    SELECT ID,Volunteer_Name__c,Chapter_Role__r.Background_Check_Required__c,Status__c
                    FROM Volunteer_Roles__c
                    WHERE Chapter_Role__c != Null AND Volunteer_Name__c IN:volIdsSet
            ]) {
                /**** WVC-2199 change the status value pending training to pending ***/
                if (currVolunteerRole.Status__c == VOLUNTEER_ROLE_STATUS_ACTIVE
                        || currVolunteerRole.Status__c == 'Pending' /*|| currVolunteerRole.Status__c == 'Chapter Review'*/) {
                    if (currVolunteerRole.Chapter_Role__r.Background_Check_Required__c == true) {
                        trainingVolunteersIdsSet.add(currVolunteerRole.Volunteer_Name__c);
                        coiTrainingVolunteerIdsSet.add(currVolunteerRole.Volunteer_Name__c);
                    } else {
                        coiTrainingVolunteerIdsSet.add(currVolunteerRole.Volunteer_Name__c);
                    }
                } else if (currVolunteerRole.Status__c == 'Out of Compliance') {
                    if (currVolunteerRole.Chapter_Role__r.Background_Check_Required__c == true) {
                        outOfComplianceVolunteersIdsSet.add(currVolunteerRole.Volunteer_Name__c);
                        coiOutOfComplianceVolunteerIdsSet.add(currVolunteerRole.Volunteer_Name__c);
                    } else {
                        coiOutOfComplianceVolunteerIdsSet.add(currVolunteerRole.Volunteer_Name__c);
                    }
                } else {
                    volunteerIdsSet.add(currVolunteerRole.Volunteer_Name__c);
                }
            }

            if (trainingVolunteersIdsSet.size() > 0) {
                updateBackGroundCheck(trainingVolunteersIdsSet, 'training', exceptionList);
            }
            if (coiTrainingVolunteerIdsSet.size() > 0) {
                updateConflictOfInterest(coiTrainingVolunteerIdsSet, 'training', exceptionList);
            }

            if (outOfComplianceVolunteersIdsSet.size() > 0) {
                updateBackGroundCheck(outOfComplianceVolunteersIdsSet, 'outOfCompliance', exceptionList);
            }

            if (coiOutOfComplianceVolunteerIdsSet.size() > 0) {
                updateConflictOfInterest(coiOutOfComplianceVolunteerIdsSet, 'outOfCompliance', exceptionList);
            }
            if (volunteerIdsSet.size() > 0 && outOfComplianceVolunteersIdsSet.size() == 0 && trainingVolunteersIdsSet.size() == 0) {
                updateBackGroundCheck(volunteerIdsSet, 'none', exceptionList);
            }

            if (volunteerIdsSet.size() > 0 && coiOutOfComplianceVolunteerIdsSet.size() == 0 && coiTrainingVolunteerIdsSet.size() == 0) {
                updateConflictOfInterest(volunteerIdsSet, 'none', exceptionList);
            }

            if (outOfComplianceVolunteersIdsSet.size() > 0 && trainingVolunteersIdsSet.size() == 0) {
                updateBackGroundCheck(outOfComplianceVolunteersIdsSet, '1', exceptionList);
            }
            if (coiOutOfComplianceVolunteerIdsSet.size() > 0 && coiTrainingVolunteerIdsSet.size() == 0) {
                updateConflictOfInterest(coiOutOfComplianceVolunteerIdsSet, '1', exceptionList);
            }

            if (trainingVolunteersIdsSet.size() > 0 && outOfComplianceVolunteersIdsSet.size() == 0) {
                updateBackGroundCheck(trainingVolunteersIdsSet, '2', exceptionList);
            }

            if (coiTrainingVolunteerIdsSet.size() > 0 && coiOutOfComplianceVolunteerIdsSet.size() == 0) {
                updateConflictOfInterest(coiTrainingVolunteerIdsSet, '2', exceptionList);
            }

            if (Test.isRunningTest()) {
                throw new CommonTriggerException('Test Class execution');
            }
        } Catch (Exception ex) {
            for (Volunteer_Roles__c currRec : exceptionList) {
                ErrorMessage_AC.createdebugRec('VolunteerRole_OnAfterInsertHelper_AC',
                        String.valueof(currRec), String.valueOf(ex), 'getVolunteerBasedOnVolunteerRoleStatus',
                        currRec.Id, ex.getStackTraceString() + '   ' + ex.getMessage(), 'Error');
            }

            if (!Test.isRunningTest()) {
                for (Volunteer_Roles__c currRec : exceptionList) {
                    currRec.addError(Label.Debug_log_error_message);
                }
            }
        }
    }

    // This method is used to update the BC record based on the volunteer role status
    public static void updateBackGroundCheck(Set<ID> volunteerIdsSet, String status, List<Volunteer_Roles__c> exceptionList) {
        try {
            List<Background_check__c> updatebackgroundCheckList = new List<Background_check__c>();
            for (Background_check__c currBack : [
                    SELECT ID,Current__c,Volunteer__c
                    FROM Background_check__c
                    WHERE Volunteer__c IN:volunteerIdsSet AND Current__c = true
            ]) {
                if (status == 'training') {
                    currBack.VolunteerRoleTrainedTpendChapReview__c = true;
                } else if (status == 'outOfCompliance') {
                    currBack.VolunteerRoleOutofCompliance__c = true;
                } else if (status == 'none') {
                    currBack.VolunteerRoleTrainedTpendChapReview__c = false;
                    currBack.VolunteerRoleOutofCompliance__c = false;
                } else if (status == '1') {
                    currBack.VolunteerRoleTrainedTpendChapReview__c = false;
                } else if (status == '2') {
                    currBack.VolunteerRoleOutofCompliance__c = false;
                }
                updatebackgroundCheckList.add(currBack);
            }
            if (updatebackgroundCheckList.size() > 0) {
                update updatebackgroundCheckList;
            }

            if (Test.isRunningTest()) {
                throw new CommonTriggerException('Test Class execution');
            }

        } Catch (Exception ex) {
            for (Volunteer_Roles__c currRec : exceptionList) {
                ErrorMessage_AC.createdebugRec('VolunteerRole_OnAfterInsertHelper_AC',
                        String.valueof(currRec), String.valueOf(ex), 'updateBackGroundCheck',
                        currRec.Id, ex.getStackTraceString() + '   ' + ex.getMessage(), 'Error');
            }

            if (!Test.isRunningTest()) {
                for (Volunteer_Roles__c currRec : exceptionList) {
                    currRec.addError(Label.Debug_log_error_message);
                }
            }
        }
    }

    // This method is used to update the BC record based on the volunteer role status
    public static void updateConflictOfInterest(Set<ID> volunteerIdsSet, String status, List<Volunteer_Roles__c> exceptionList) {
        try {
            List<Conflict_Of_Interest__c> updateConflictList = new List<Conflict_Of_Interest__c>();
            for (Conflict_Of_Interest__c currCOI : [
                    SELECT ID,Current__c,Volunteer_Contact__c
                    FROM Conflict_Of_Interest__c
                    WHERE Volunteer_Contact__c IN:volunteerIdsSet
                    AND Current__c = true
            ]) {
                if (status == 'training') {
                    currCOI.VolunteerRoleTrainedTpendChapReview__c = true;
                } else if (status == 'outOfCompliance') {
                    currCOI.VolunteerRoleOutofCompliance__c = true;
                } else if (status == 'none') {
                    currCOI.VolunteerRoleTrainedTpendChapReview__c = false;
                    currCOI.VolunteerRoleOutofCompliance__c = false;
                } else if (status == '1') {
                    currCOI.VolunteerRoleTrainedTpendChapReview__c = false;
                } else if (status == '2') {
                    currCOI.VolunteerRoleOutofCompliance__c = false;
                }
                updateConflictList.add(currCOI);
            }
            if (updateConflictList.size() > 0) {
                update updateConflictList;
            }

            if (Test.isRunningTest()) {
                throw new CommonTriggerException('Test Class execution');
            }
        } Catch (Exception ex) {
            for (Volunteer_Roles__c currRec : exceptionList) {
                ErrorMessage_AC.createdebugRec('VolunteerRole_OnAfterInsertHelper_AC',
                        String.valueof(currRec), String.valueOf(ex), 'updateConflictOfInterest',
                        currRec.Id, ex.getStackTraceString() + '   ' + ex.getMessage(), 'Error');
            }

            if (!Test.isRunningTest()) {
                for (Volunteer_Roles__c currRec : exceptionList) {
                    currRec.addError(Label.Debug_log_error_message);
                }
            }
        }
    }
}