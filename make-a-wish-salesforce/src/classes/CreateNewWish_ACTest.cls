@IsTest
public class CreateNewWish_ACTest {

    @IsTest
    static void createParentWish() {
        Account chapterAccount = OrientationandTrainingUtil.AlabamaAccount();
        insert chapterAccount;

        Contact wishChild = OrientationandTrainingUtil.CreateWishChild();
        insert wishChild;

        Account chapterAmericaAccount = OrientationandTrainingUtil.CreateAmericaAccount();
        insert chapterAmericaAccount;

        Case parentCase = OrientationandTrainingUtil.CreateParentCase(wishChild.Id);
        insert parentCase;

        Contact volunterCon = OrientationandTrainingUtil.createVolunteerContact(chapterAccount.Id);
        insert volunterCon;

        User volunterUser;
        User currUser = [
                SELECT Id
                FROM User
                WHERE Id = :UserInfo.getUserId()
                LIMIT 1
        ];
        System.runAs(currUser) {
            volunterUser = OrientationandTrainingUtil.CreateActiveVolunteerUser(volunterCon.Id);
            insert volunterUser;
        }

        CaseTeamRole roleRec = [
                SELECT Id
                FROM CaseTeamRole
                WHERE Name = 'Wish Granter'
        ];
        CaseTeamMember caseTeamMeber = OrientationandTrainingUtil.createCaseTeamMember(parentCase.Id, volunterUser.Id, roleRec.Id);
        insert caseTeamMeber;

        CreateNewWish_AC.createCase(parentCase.Id);
    }
}