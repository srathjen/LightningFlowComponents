/**
 * A class to centralize logic related to trigger validations of the Case object
 *
 * @author Chris Shinnimin, Traction on Demand
 * @date 2020-04-14
 */
public with sharing class CaseValidations {
    private static final Boolean USER_HAS_RESTRICTED_PERMISSIONS_ON_CASE = CaseService.userHasRestrictedPermissionOnCase();
    private static final UserSetting__c usc = UserSetting__c.getValues(UserInfo.getUserId());

    /*
     * @description     Validations performed before update of Case records.
     *
     * @param           List<Case>
     *
     * @return          Boolean
     *
     * @author          MST Solutions
     * @createdDate     2018-03-23
     */
    public static Boolean beforeUpdateValidations(Case newCase, Case oldCase) {
        if (newCase.RecordTypeId == Constant_AC.WISH_RT_ID
            && Bypass_Triggers__c.getValues(UserInfo.getUserId()) == null
            && Constant_AC.CASE_STATUS_WISH_DETERMINED.equals(newCase.Status)
            && newCase.Wish_Type__c == null) {

            newCase.Wish_Type__c.addError(Label.CaseTrigger_Enter_Wish_Type);
        }

        Boolean isLocked = newCase.IsLocked__c;

        if ((!Constant_AC.CASE_STATUS_DNQ.equals(newCase.Status)
            && Constant_AC.CASE_STATUS_DNQ.equals(oldCase.Status))
            || (!Constant_AC.CASE_STATUS_COMPLETED.equals(newCase.Status)
            && Constant_AC.CASE_STATUS_COMPLETED.equals(oldCase.Status))
            || (!Constant_AC.CASE_STATUS_CLOSED.equals(newCase.Status)
            && Constant_AC.CASE_STATUS_CLOSED.equals(oldCase.Status))
            || (newCase.IsClosed == false
            && oldCase.IsClosed == true) &&
            newCase.RecordTypeId == Constant_AC.WISH_RT_ID) {

            isLocked = false;
        }

        if (isLocked
            && oldCase.IsLocked__c == true
            && usc != null) {
            if (usc.All_Closed_Cases_except_Abandoned__c == false
                && newCase.IsClosed == true
                && USER_HAS_RESTRICTED_PERMISSIONS_ON_CASE
                && newCase.RecordTypeId == Constant_AC.WISH_RT_ID
                && (!(Constant_AC.CASE_STATUS_COMPLETED.equals(newCase.Status)
                && (newCase.Adoptable__c != oldCase.Adoptable__c
                || newCase.Adopted__c != oldCase.Adopted__c
                || newCase.Adopted_By__c != oldCase.Adopted_By__c)))) {

                newCase.addError(Label.CaseTrigger_Permission_Error);
                return false;
            }

            if (usc.Edit_Abandoned_Cases__c == false
                && newCase.IsClosed == true
                && USER_HAS_RESTRICTED_PERMISSIONS_ON_CASE
                && newCase.RecordTypeId == Constant_AC.WISH_RT_ID) {

                newCase.addError(Label.CaseTrigger_Permission_Error);
                return false;
            }
        } else if (newCase.IsLocked__c == true
            && oldCase.IsLocked__c == true
            && USER_HAS_RESTRICTED_PERMISSIONS_ON_CASE
            && newCase.RecordTypeId == Constant_AC.WISH_RT_ID
            && (!(Constant_AC.CASE_STATUS_COMPLETED.equals(newCase.Status)
            && (newCase.Adoptable__c != oldCase.Adoptable__c
            || newCase.Adopted__c != oldCase.Adopted__c
            || newCase.Adopted_By__c != oldCase.Adopted_By__c)))) {

            newCase.addError(Label.CaseTrigger_Permission_Error);
            return false;
        }

        if (Constant_AC.CASE_SUB_STATUS_ABANDONED.equals(newCase.Sub_Status__c)
            && Constant_AC.CASE_STATUS_GRANTED.equals(oldCase.Status)
            && usc == null
            && Bypass_Triggers__c.getValues(UserInfo.getUserId()) == null
            && newCase.RecordTypeId == Constant_AC.WISH_RT_ID) {

            newCase.addError(Label.CaseTrigger_Permission_Error_Abandoned);
            return false;
        } else if (Constant_AC.CASE_SUB_STATUS_ABANDONED.equals(newCase.Sub_Status__c)
            && Constant_AC.CASE_STATUS_GRANTED.equals(oldCase.Status)
            && usc != null
            && Bypass_Triggers__c.getValues(UserInfo.getUserId()) == null
            && newCase.RecordTypeId == Constant_AC.WISH_RT_ID) {
            if (usc.Abandon_the_Granted_case__c == false) {

                newCase.addError(Label.CaseTrigger_Permission_Error_Abandoned);
                return false;
            }
        }

        return true;
    }
}