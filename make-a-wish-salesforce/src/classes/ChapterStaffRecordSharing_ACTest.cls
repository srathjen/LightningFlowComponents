/*********************************************
Description : Test Class create ChapterStaffRecordSharing.
**********************************************/
//This class used to do the unit testing
// createRecords methosd will create chapter role record
@IsTest
public class ChapterStaffRecordSharing_ACTest {

    @TestSetup
    static void leadSharing() {
        User nationalStaff = OrientationandTrainingUtil.createUserWithRole([
                SELECT Id
                FROM UserRole
                WHERE Name = :Constant_AC.ROLE_NATIONAL_STAFF
        ].Id);

        System.runAs(nationalStaff) {
            Chapter_Vs_Role__c createRec = OrientationandTrainingUtil.createAlabamaChapter();
            insert createRec;

            Account chapterAccount = OrientationandTrainingUtil.createchapterAccount();
            chapterAccount.Intake_Manager__c = nationalStaff.Id;
            insert chapterAccount;

            Lead newLead = OrientationandTrainingUtil.createTestLeadRec(chapterAccount.Id);
            insert newLead;

            Map<String, List<Lead>> leadMap = new Map<String, List<Lead>>();
            leadMap.put(chapterAccount.Name, new List<Lead>{
                    newLead
            });
            ChapterStaffRecordSharing_AC.LeadSharing(leadMap);
            ChapterStaffRecordSharing_AC.getChapterName(new Set<Id>{
                    chapterAccount.Id
            });
        }
    }

    @IsTest
    static void contactSharing() {
        Chapter_Vs_Role__c getRec = [
                SELECT Chapter_Name__c,Role_Name__c
                FROM Chapter_Vs_Role__c
        ];
        Account chapterAccount = OrientationandTrainingUtil.createVolunteerAccount();
        insert chapterAccount;

        Contact newContact = OrientationandTrainingUtil.createWishFamily();
        insert newContact;

        Contact volunteerContact = OrientationandTrainingUtil.createVolunteerContact(chapterAccount.Id);
        insert volunteerContact;

        Conflict_Of_Interest__c coiRec = OrientationandTrainingUtil.createCOI(volunteerContact.Id);
        insert coiRec;

        Map<String, List<Contact>> contactMapforSharing = new Map<String, List<Contact>>();
        contactMapforSharing.put(chapterAccount.Name, new List<Contact>{
                newContact
        });
        ChapterStaffRecordSharing_AC.ContactSharing(contactMapforSharing);

        Map<String, List<Conflict_Of_Interest__c>> coiMapforSharing = new Map<String, List<Conflict_Of_Interest__c>>{
                getRec.Chapter_Name__c => new List<Conflict_Of_Interest__c>{
                        coiRec
                }
        };
        ChapterStaffRecordSharing_AC.COIRecordSharing(coiMapforSharing);

        Volunteer_Opportunity__c volOpp = OrientationandTrainingUtil.createVolunteerOpportunities(1)[0];
        insert volOpp;
        Map<String, List<Volunteer_Opportunity__c>> volMapForSharing = new Map<String, List<Volunteer_Opportunity__c>>{
                getRec.Chapter_Name__c => new List<Volunteer_Opportunity__c>{
                        volOpp
                }
        };
        ChapterStaffRecordSharing_AC.volunteerOpportunitySharing(volMapForSharing);
    }

    @IsTest
    static void accountSharing() {
        Map<String, List<Account>> accountMapforSharing = new Map<String, List<Account>>();
        Account newAccount = OrientationandTrainingUtil.inKindAccountWithStatus();
        Account chapterAccount = OrientationandTrainingUtil.createVolunteerAccount();
        accountMapforSharing.put(chapterAccount.Name, new List<Account>{
                newAccount
        });
        ChapterStaffRecordSharing_AC.AccountSharing(accountMapforSharing);
    }

    @IsTest
    static void backGroundCheckSharing() {
        User nationStaffUser = [
                SELECT Id
                FROM User
                WHERE UserRole.Name = :Constant_AC.ROLE_NATIONAL_STAFF AND IsActive = TRUE
                LIMIT 1
        ];
        System.runAs(nationStaffUser) {
            Map<String, List<Background_check__c>> bgcMap = new Map<String, List<Background_check__c>>();
            Account chapterAccount = OrientationandTrainingUtil.createVolunteerAccount();
            insert chapterAccount;

            Contact volContact = OrientationandTrainingUtil.createVolunteerContact(chapterAccount.Id);
            insert volContact;

            Background_check__c bgc = OrientationandTrainingUtil.createBackgroundCheck(volContact.Id);
            insert bgc;
            bgcMap.put(chapterAccount.Name, new List<Background_check__c>{
                    bgc
            });
            ChapterStaffRecordSharing_AC.BGCRecordSharing(bgcMap);
        }
    }

    @IsTest
    static void broadCastRecordSharing() {
        User nationStaffUser = [
                SELECT Id
                FROM User
                WHERE UserRole.Name = :Constant_AC.ROLE_NATIONAL_STAFF AND IsActive = TRUE
                LIMIT 1
        ];
        System.runAs(nationStaffUser) {
            Map<String, List<Broadcast__c>> broadCastMap = new Map<String, List<Broadcast__c>>();
            Account chapterAccount = OrientationandTrainingUtil.createVolunteerAccount();
            Broadcast__c newBroadcast = new Broadcast__c();
            newBroadcast.Broadcast_Message__c = 'test';
            newBroadcast.Chapter_Name__c = chapterAccount.Id;
            insert newBroadcast;
            broadCastMap.put(chapterAccount.Name, new List<Broadcast__c>{
                    newBroadcast
            });
            ChapterStaffRecordSharing_AC.broadRecordSharing(broadCastMap);
        }
    }

    @IsTest
    static void chapterActionSharing() {
        User nationStaffUser = [
                SELECT Id
                FROM User
                WHERE UserRole.Name = :Constant_AC.ROLE_NATIONAL_STAFF AND IsActive = TRUE
                LIMIT 1
        ];
        System.runAs(nationStaffUser) {

            Map<String, List<Chapter_Action_Track__c>> chapterActionMap = new Map<String, List<Chapter_Action_Track__c>>();
            Account chapterAccount = OrientationandTrainingUtil.createVolunteerAccount();
            Chapter_Action_Track__c newChapterTaction = new Chapter_Action_Track__c();
            newChapterTaction.Chapter_Name__c = chapterAccount.Id;
            insert newChapterTaction;
            chapterActionMap.put(chapterAccount.Name, new List<Chapter_Action_Track__c>{
                    newChapterTaction
            });
            ChapterStaffRecordSharing_AC.chapterActionTrackSharing(chapterActionMap);
        }
    }

    @IsTest
    static void chapterRoleSharing() {
        User nationStaffUser = [
                SELECT Id
                FROM User
                WHERE UserRole.Name = :Constant_AC.ROLE_NATIONAL_STAFF AND IsActive = TRUE
                LIMIT 1
        ];
        System.runAs(nationStaffUser) {
            Map<String, List<Chapter_Role__c>> chapterRoleMap = new Map<String, List<Chapter_Role__c>>();
            Account chapterAccount = OrientationandTrainingUtil.createVolunteerAccount();
            Chapter_Role__c newChapterRole = new Chapter_Role__c();
            newChapterRole.Chapter_Name__c = chapterAccount.Id;
            insert newChapterRole;
            chapterRoleMap.put(chapterAccount.Name, new List<Chapter_Role__c>{
                    newChapterRole
            });
            ChapterStaffRecordSharing_AC.chapterRoleSharing(chapterRoleMap);
        }
    }

    @IsTest
    static void chapterRoleOTSharing() {
        User nationStaffUser = [
                SELECT Id
                FROM User
                WHERE UserRole.Name = :Constant_AC.ROLE_NATIONAL_STAFF AND IsActive = TRUE
                LIMIT 1
        ];
        System.runAs(nationStaffUser) {
            Map<String, List<Chapter_Role_O_T__c>> chapterRoleMap = new Map<String, List<Chapter_Role_O_T__c>>();
            Account chapterAccount = OrientationandTrainingUtil.createVolunteerAccount();
            Chapter_Role__c newChapterRole = new Chapter_Role__c();
            newChapterRole.Chapter_Name__c = chapterAccount.Id;
            insert newChapterRole;
            Chapter_Role_O_T__c newChapterRoleOT = new Chapter_Role_O_T__c();
            newChapterRoleOT.Chapter_Role__c = newChapterRole.Id;
            insert newChapterRoleOT;
            chapterRoleMap.put(chapterAccount.Name, new List<Chapter_Role_O_T__c>{
                    newChapterRoleOT
            });
            ChapterStaffRecordSharing_AC.chapterRoleOTSharing(chapterRoleMap);
        }
    }

    @IsTest
    static void classOfferingSharing() {
        User nationStaffUser = [
                SELECT Id
                FROM User
                WHERE UserRole.Name = :Constant_AC.ROLE_NATIONAL_STAFF AND IsActive = TRUE
                LIMIT 1
        ];
        System.runAs(nationStaffUser) {

            Map<String, List<Class_Offering__c>> classOfferingMap = new Map<String, List<Class_Offering__c>>();
            Account chapterAccount = OrientationandTrainingUtil.createVolunteerAccount();
            insert chapterAccount;

            Chapter_Role__c newChapterRole = new Chapter_Role__c();
            newChapterRole.Chapter_Name__c = chapterAccount.Id;
            insert newChapterRole;

            Chapter_Role_O_T__c newChapterRoleOT = new Chapter_Role_O_T__c();
            newChapterRoleOT.Chapter_Role__c = newChapterRole.Id;
            insert newChapterRoleOT;

            Class_Offering__c newclassOffering = OrientationandTrainingUtil.createClassOffering(newChapterRoleOT.Id);
            insert newclassOffering;
            classOfferingMap.put(chapterAccount.Name, new List<Class_Offering__c>{
                    newclassOffering
            });
            ChapterStaffRecordSharing_AC.classOfferingSharing(classOfferingMap);
        }

    }
}