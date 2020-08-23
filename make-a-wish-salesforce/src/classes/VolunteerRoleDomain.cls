/**
 * @description Domain class for the Volunteer Role trigger
 * @author  Gustavo Mayer, Traction on Demand
 * @createdDate 4/14/2020
 */
public class VolunteerRoleDomain extends trac_TriggerHandlerBase {

    List<Volunteer_Roles__c> newVolunteerRoleList = (List<Volunteer_Roles__c>) newRecordsList;
    List<Volunteer_Roles__c> oldVolunteerRoleList = (List<Volunteer_Roles__c>) oldRecordsList;
    Map<Id, Volunteer_Roles__c> newVolunteerRolesMap = (Map<Id, Volunteer_Roles__c>) newRecordsMap;
    Map<Id, Volunteer_Roles__c> oldVolunteerRolesMap = (Map<Id, Volunteer_Roles__c>) oldRecordsMap;

    private final static String VOLUNTEER_ROLE_STATUS_ACTIVE = Constant_AC.VOLUNTEER_ROLE_STATUS_ACTIVE;
    private final static String VOLUNTEER_ROLE_STATUS_NOT_APPROVED = Constant_AC.VOLUNTEER_ROLE_STATUS_NOT_APPROVED;
    private final static String VOLUNTEER_ROLE_STATUS_OUT_OF_COMPLIANCE = Constant_AC.VOLUNTEER_ROLE_STATUS_OUT_OF_COMPLIANCE;
    private final static String VOLUNTEER_ROLE_STATUS_FORMER = Constant_AC.VOLUNTEER_ROLE_STATUS_FORMER;
    private final static String VOLUNTEER_ROLE_STATUS_PENDING = Constant_AC.VOLUNTEER_ROLE_STATUS_PENDING;
    private final static String VOLUNTEER_ROLE_STATUS_PENDING_TRAINING = Constant_AC.VOLUNTEER_ROLE_STATUS_PENDING_TRAINING;

    /**
     * Before update of Volunteer Role
     */
    public override void handleBeforeUpdate() {
        Set<String> chapterNamesSet = VolunteerRoleService.buildChapterNames(newVolunteerRoleList);
        Map<String, String> chapterRoleMap = ChapterStaffRecordSharing_AC.findChapterRole(chapterNamesSet);
        VolunteerRoleValidation.validatePermission(newVolunteerRoleList, chapterRoleMap);
        VolunteerRoleService.setSubStatusAndStartDate(newVolunteerRoleList);
    }

    /**
     * After insert of Volunteer Role
     */
    public override void handleAfterInsert() {
        Map<Id, List<Volunteer_Roles__c>> volunteerRoleStatusMap =
                VolunteerRoleService.buildVolunteerByVolunteerRolesMap(newVolunteerRoleList);
        AffiliationService.updateInactiveAffiliationFromContact(volunteerRoleStatusMap);
        Set<Id> volunteerWithPendingTrainingSet =
                VolunteerRoleService.buildVolunteerSetFromStatus(newVolunteerRoleList, VOLUNTEER_ROLE_STATUS_PENDING_TRAINING);
        VolunteerRoleService.updateVolunteerCoiAndBcg(volunteerWithPendingTrainingSet, newVolunteerRoleList);
        Set<Id> volunteerWithNonActiveRole = VolunteerRoleService.buildNonActiveVolunteerSet(newVolunteerRoleList);
        VolunteerJourneyService.processVolunteersChapterRequirements(volunteerWithNonActiveRole);
        Map<Id, Set<String>> volunteerWithActiveRoleByChapter =
                VolunteerRoleService.buildVolunteerByChapterNameMapFromStatus(newVolunteerRoleList, VOLUNTEER_ROLE_STATUS_ACTIVE);
        VolunteerJourneyService.processVolunteersRoleActiveBypass(volunteerWithActiveRoleByChapter);
    }

    /**
     * After update of Volunteer Role
     */
    public override void handleAfterUpdate() {
        Map<Id, List<Volunteer_Roles__c>> volunteerRoleMap =
                VolunteerRoleService.buildVolunteerRolesByVolunteer(newVolunteerRoleList, oldVolunteerRolesMap);
        Set<Id> volunteerIdsSet = VolunteerRoleService.buildModifiedRoleStatusVolunteerSet(newVolunteerRoleList, oldVolunteerRolesMap);
        Map<Id, Set<String>> volunteerWithActiveRoleByChapter = VolunteerRoleService.buildVolunteerByChapterNameMapFromStatus(newVolunteerRoleList, VOLUNTEER_ROLE_STATUS_ACTIVE);
        List<Volunteer_Opportunity__c> volunteerOpportunities
                = VolunteerOpportunityService.findVolunteerOpportunityByVolunteer(volunteerRoleMap.keySet());
        Map<Id, Id> inactiveWishVolunteerIdMap = VolunteerRoleService.buildInactiveVolunteerByWish(volunteerRoleMap, volunteerOpportunities);
        Map<Id, Set<String>> inactiveVolunteerRoleMap = VolunteerRoleService.buildInactiveVolunteerRoleMap(volunteerRoleMap, volunteerOpportunities);
        VolunteerOpportunityService.updateVolunteerOpportunityByVolunteerRoles(volunteerRoleMap);
        CaseTeamMemberService.updateInactiveCaseTeamMember(inactiveWishVolunteerIdMap, inactiveVolunteerRoleMap);
        Map<String, Integer> volunteerRoleCountMap = VolunteerRoleService.findVolunteerByVolunteerRoleCount(volunteerRoleMap);
        List<Volunteer_Roles__c> volunteerRoles = VolunteerRoleService.findVolunteerRolesByStatusAndVolunteer(volunteerRoleMap, new Set<String>{
                VOLUNTEER_ROLE_STATUS_NOT_APPROVED, VOLUNTEER_ROLE_STATUS_FORMER, VOLUNTEER_ROLE_STATUS_OUT_OF_COMPLIANCE,
                VOLUNTEER_ROLE_STATUS_ACTIVE, VOLUNTEER_ROLE_STATUS_PENDING
        });
        Map<Id, List<Volunteer_Roles__c>> declinedStatusMap =
                VolunteerRoleService.buildVolunteerByVolunteerRolesMapFromStatus(volunteerRoles, VOLUNTEER_ROLE_STATUS_NOT_APPROVED);
        Map<Id, List<Volunteer_Roles__c>> inActiveSingleStatusMap =
                VolunteerRoleService.buildVolunteerByVolunteerRolesMapFromStatus(volunteerRoles, VOLUNTEER_ROLE_STATUS_FORMER);
        Map<Id, List<Volunteer_Roles__c>> OCCStatusMap =
                VolunteerRoleService.buildVolunteerByVolunteerRolesMapFromStatus(volunteerRoles, VOLUNTEER_ROLE_STATUS_OUT_OF_COMPLIANCE);
        Map<Id, List<Volunteer_Roles__c>> pendingStatusMap =
                VolunteerRoleService.buildVolunteerByVolunteerRolesMapFromStatus(volunteerRoles, VOLUNTEER_ROLE_STATUS_PENDING);
        Map<Id, List<Volunteer_Roles__c>> trainedVRsSet =
                VolunteerRoleService.buildVolunteerByVolunteerRolesMapFromStatus(volunteerRoles, VOLUNTEER_ROLE_STATUS_ACTIVE);
        AffiliationService.updateAffiliationFromVolunteerRoleStatus(volunteerRoleCountMap, volunteerRoleMap,
                inActiveSingleStatusMap, declinedStatusMap, OCCStatusMap, pendingStatusMap, trainedVRsSet);
        VolunteerRoleService.updateVolunteerCoiAndBcg(volunteerIdsSet, newVolunteerRoleList);
        VolunteerRoleService.processChatterMembers(newVolunteerRoleList, oldVolunteerRoleList);
        VolunteerJourneyService.processVolunteersRoleActiveBypass(volunteerWithActiveRoleByChapter);
    }
}