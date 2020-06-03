/**
 * An apex page controller that supports self registration of users in communities that allow self registration
 */
@IsTest
public with sharing class CommunitiesSelfRegControllerTest {

    @TestSetup
    public static void setup() {
        trac_TriggerHandlerBase.blockTrigger = true;
        List<Account> accounts = TestDataFactory.createAccount(2);
        Account account1 = accounts.get(0);
        account1.Name = 'MAW Arizona';
        account1.RecordTypeId = Constant_AC.CHAPTER_RT_ID;
        account1.MAC_Email_del__c = 'test1@email.com';

        List<Office__c> offices = TestDataFactory.createOffice(1);
        Office__c office = offices.get(0);
        office.Chapter__c = account1.Id;
        office.External_Id__c = 'Test123';
        insert office;

        List<Zip_Code__c> zipCodes = TestDataFactory.createZipCode(1);
        Zip_Code__c zipCode = zipCodes.get(0);
        zipCode.Office__c = office.Id;
        zipCode.Name = '35004';
        zipCode.External_Id__c = 'Test123';
        insert zipCode;

        List<Contact> contacts = TestDataFactory.createContact(1);
        Contact contact = contacts.get(0);
        contact.LastName = 'Test';
        contact.Email = 'test@gmail.com';
        contact.AccountId = account1.Id;
        insert contact;

        List<Dynamic_Content__c> dynamicContents = TestDataFactory.createDynamicContent(1);
        Dynamic_Content__c newContent = dynamicContents.get(0);
        newContent.Sign_Up_Page__c = 'Hai';
        newContent.RecordTypeId = Constant_AC.NATIONAL_RT_ID;
        newContent.Application_Overview__c = 'An interview is a great way to better understand the role(s) and expectations of the volunteer opportunities that you are interested in';
        newContent .Active__c = true;
        newContent.Interview_Additional_Info__c = 'Test';
        newContent.Orientation_Add_l_Info__c = 'Test';
        newContent.Sign_Up_Page__c = 'Test';
        newContent.Training_Additional_Info__c = 'Test';
        newContent.Welcome_Message__c = 'Test';
        newContent.WelcomePage__c = 'Test';
        newContent.Welcome_Text__c = 'Test';
        newContent.Why_Need_Background_Check__c = 'Test';
        insert dynamicContents;

        trac_TriggerHandlerBase.blockTrigger = false;
    }

    @IsTest
	public static void testCommunitiesSelfRegController() {
		CommunitiesSelfRegController selfRegCtrl = new CommunitiesSelfRegController();
		selfRegCtrl.registerUser();
	}

    @IsTest
	public static void lastNameValidation() {
		CommunitiesSelfRegController selfRegCtrl = new CommunitiesSelfRegController();
		selfRegCtrl.email = 'test@gmail.com';
		selfRegCtrl.registerUser();
	}

    @IsTest
	public static void firstNameValidation() {
		CommunitiesSelfRegController selfRegCtrl = new CommunitiesSelfRegController();
		selfRegCtrl.email = 'test@gmail.com';
		selfRegCtrl.lastName = 'a';
		selfRegCtrl.registerUser();
	}

    @IsTest
	public static void zipCodeValidation() {
		CommunitiesSelfRegController selfRegCtrl = new CommunitiesSelfRegController();
		selfRegCtrl.email = 'test@gmail.com';
		selfRegCtrl.lastName = 'a';
		selfRegCtrl.firstName = 'a';
		selfRegCtrl.registerUser();
	}

    @IsTest
	public static void emailValidation() {
		CommunitiesSelfRegController selfRegCtrl = new CommunitiesSelfRegController();
		selfRegCtrl.lastName = 'test';
		selfRegCtrl.registerUser();
	}

    @IsTest
	public static void zipCodeSizeValidation() {
		CommunitiesSelfRegController selfRegCtrl = new CommunitiesSelfRegController();
		selfRegCtrl.email = 'test@gmail.com';
		selfRegCtrl.lastName = 'a';
		selfRegCtrl.firstName = 'a';
		selfRegCtrl.zipCode = '350043';
		selfRegCtrl.registerUser();
	}

    @IsTest
	public static void usernameValidation() {
		CommunitiesSelfRegController selfRegCtrl = new CommunitiesSelfRegController();
		selfRegCtrl.email = 'test@gmail.com';
		selfRegCtrl.lastName = 'a';
		selfRegCtrl.firstName = 'a';
		selfRegCtrl.zipCode = '35004';
		selfRegCtrl.username = 'test';
		selfRegCtrl.registerUser();
	}

    @IsTest
	public static void passwordValidation() {
		CommunitiesSelfRegController selfRegCtrl = new CommunitiesSelfRegController();
		selfRegCtrl.email = 'test@gmail.com';
		selfRegCtrl.lastName = 'a';
		selfRegCtrl.firstName = 'a';
		selfRegCtrl.zipCode = '35004';
		selfRegCtrl.username = 'test@username.com';
		selfRegCtrl.registerUser();
	}

    @IsTest
	public static void confirmPasswordValidation() {
		CommunitiesSelfRegController selfRegCtrl = new CommunitiesSelfRegController();
		selfRegCtrl.email = 'test@gmail.com';
		selfRegCtrl.lastName = 'a';
		selfRegCtrl.firstName = 'a';
		selfRegCtrl.zipCode = '35004';
		selfRegCtrl.username = 'test@username.com';
		selfRegCtrl.password = 'abcded';
		selfRegCtrl.registerUser();
	}

    @IsTest
	public static void volunteerAgeValidation() {
		CommunitiesSelfRegController selfRegCtrl = new CommunitiesSelfRegController();
		selfRegCtrl.email = 'test@gmail.com';
		selfRegCtrl.lastName = 'a';
		selfRegCtrl.firstName = 'a';
		selfRegCtrl.zipCode = '35004';
		selfRegCtrl.username = 'test@username.com';
		selfRegCtrl.password = 'abcded';
		selfRegCtrl.confirmPassword = 'abcded';
		selfRegCtrl.registerUser();
	}

    @IsTest
	public static void coverStatePicklist() {
		CommunitiesSelfRegController selfRegCtrl = new CommunitiesSelfRegController();
		selfRegCtrl.email = 'test@gmail.com';
		selfRegCtrl.lastName = 'a';
		selfRegCtrl.firstName = 'a';
		selfRegCtrl.zipCode = '35004';
		selfRegCtrl.username = 'test@username.com';
		selfRegCtrl.password = 'abcded';
		selfRegCtrl.confirmPassword = 'abcded';
		selfRegCtrl.isOver18YearsOld = true;
		selfRegCtrl.registerUser();
		selfRegCtrl.getStates();
	}

    @IsTest
	public static void validateBelow18Year() {
		CommunitiesSelfRegController selfRegCtrl = new CommunitiesSelfRegController();
		selfRegCtrl.email = 'test@gmail.com';
		selfRegCtrl.lastName = 'a';
		selfRegCtrl.firstName = 'a';
		selfRegCtrl.zipCode = '35004';
		selfRegCtrl.username = 'test@username.com';
		selfRegCtrl.password = 'abcded';
		selfRegCtrl.confirmPassword = 'abcded';
		selfRegCtrl.isOver18YearsOld = false;
		selfRegCtrl.registerUser();
	}

    @IsTest
	public static void createUserwithValidData() {
		CommunitiesSelfRegController selfRegCtrl = new CommunitiesSelfRegController();
		selfRegCtrl.email = 'test@gmail.com';
		selfRegCtrl.lastName = 'a';
		selfRegCtrl.firstName = 'a';
		selfRegCtrl.zipCode = '35004';
		selfRegCtrl.username = 'test@username.com';
		selfRegCtrl.password = 'abcded';
		selfRegCtrl.confirmPassword = 'abcded';
		selfRegCtrl.isOver18YearsOld = true;
		selfRegCtrl.registerUser();
		selfRegCtrl.getStates();
	}

    @IsTest
	public static void createDupUser() {
		CommunitiesSelfRegController selfRegCtrl = new CommunitiesSelfRegController();
		selfRegCtrl.email = 'test@gmail.com';
		selfRegCtrl.lastName = 'a';
		selfRegCtrl.firstName = 'a';
		selfRegCtrl.zipCode = '35004';
		selfRegCtrl.username = 'test@username.com';
		selfRegCtrl.password = 'abcded';
		selfRegCtrl.confirmPassword = 'abcded';
		selfRegCtrl.isOver18YearsOld = true;
		selfRegCtrl.registerUser();
		selfRegCtrl.getStates();
	}

	@IsTest
	public static void chapterListBlank() {
		CommunitiesSelfRegController selfRegCtrl = new CommunitiesSelfRegController();
		selfRegCtrl.email = 'test@gmail.com';
		selfRegCtrl.lastName = 'a';
		selfRegCtrl.firstName = 'a';
		selfRegCtrl.zipCode = '35004';
		selfRegCtrl.username = 'test@username.com';
		selfRegCtrl.password = 'abcded';
		selfRegCtrl.confirmPassword = 'abcded';
		selfRegCtrl.isOver18YearsOld = true;
		selfRegCtrl.registerUser();
		selfRegCtrl.getStates();
	}

    @IsTest
    public static void createZipCodeNotFound() {
        CommunitiesSelfRegController selfRegCtrl = new CommunitiesSelfRegController();
        selfRegCtrl.email = 'test@gmail.com';
        selfRegCtrl.lastName = 'a';
        selfRegCtrl.firstName = 'a';
        selfRegCtrl.zipCode = '88888';
        selfRegCtrl.username = 'test@username.com';
        selfRegCtrl.password = 'abcded';
        selfRegCtrl.confirmPassword = 'abcded';
        selfRegCtrl.isOver18YearsOld = true;
        selfRegCtrl.registerUser();
    }
}