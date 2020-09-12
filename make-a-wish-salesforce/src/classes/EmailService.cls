/**
 * @description Service class for Email Delivery
 * @author  Gustavo Mayer, Traction on Demand
 * @createdDate 08/Sep/2020
 */
public with sharing class EmailService {

	/**
	 * @description Build E-mails Messages
	 * @param emailMessageWrappers Email Message Wrapper
	 * @return List of Single Email Message
	 */
	public static List<Messaging.SingleEmailMessage> buildEmail(List<EmailMessageWrapper> emailMessageWrappers) {
		List<Messaging.SingleEmailMessage> emailMessages = new List<Messaging.SingleEmailMessage>();
		// Gathering the Email Templates
		Set<String> templatesSearch = new Set<String>();
		for (EmailMessageWrapper emailMessageWrapper : emailMessageWrappers) {
			if (String.isNotEmpty(emailMessageWrapper.templateApiName)) {
				templatesSearch.add(emailMessageWrapper.templateApiName);
			}
		}
		// Find Templates
		Map<String, EmailTemplate> emailTemplates = findTemplatesByApiName(templatesSearch);
		// Build the E-mail Message
		for (EmailMessageWrapper emailMessageWrapper : emailMessageWrappers) {
			if (!emailTemplates.containsKey(emailMessageWrapper.templateApiName)) {
				continue;
			}
			Messaging.SingleEmailMessage message = Messaging.renderStoredEmailTemplate(
					emailTemplates.get(emailMessageWrapper.templateApiName).Id,
					null,
					emailMessageWrapper.targetObjectId);
			message.toAddresses = emailMessageWrapper.toAddresses;
			message.setSaveAsActivity(false);
			emailMessages.add(message);
		}
		return emailMessages;
	}

	/**
	 * @description Send E-mails Messages
	 * @param emailMessages Email Messages to be sent
	 * @return List of Email Send Results
	 */
	public static List<Messaging.SendEmailResult> sendEmail(List<Messaging.SingleEmailMessage> emailMessages) {
		List<Messaging.SendEmailResult> sendEmailResults = new List<Messaging.SendEmailResult>();
		if (emailMessages.isEmpty()) {
			return sendEmailResults;
		}
		if(!Test.isRunningTest()){
			sendEmailResults = Messaging.sendEmail(emailMessages);
		}
		for (Messaging.SendEmailResult sendEmailResult : sendEmailResults) {
			if (!sendEmailResult.success) {
				System.debug('E-MAIL SERVICE ERROR: Send failed, errors: ' + sendEmailResult.errors);
			} else {
				System.debug('E-MAIL SERVICE SUCCESS: Sent');
			}
		}
		return sendEmailResults;
	}

	/**
	 * @description Find Templates by Developer Api Name
	 * @param templateDeveloperNames Set of Developer Template Names
	 * @return List of found Email Templates
	 */
	private static Map<String, EmailTemplate> findTemplatesByApiName(Set<String> templateDeveloperNames) {
		Map<String, EmailTemplate> emailTemplateMap = new Map<String, EmailTemplate>();
		for (EmailTemplate emailTemplate : [
				SELECT Id, DeveloperName, Subject, Description, HtmlValue, Body
				FROM EmailTemplate
				WHERE DeveloperName IN :templateDeveloperNames
		]) {
			emailTemplateMap.put(emailTemplate.DeveloperName, emailTemplate);
		}
		return emailTemplateMap;
	}

	/**
 	* @description Email Message Wrapper
	 */
	public class EmailMessageWrapper {
		Id targetObjectId;
		String templateApiName;
		List<String> toAddresses;
		public EmailMessageWrapper(Id targetObjectId, String templateApiName, List<String> toAddresses) {
			this.targetObjectId = targetObjectId;
			this.templateApiName = templateApiName;
			this.toAddresses = toAddresses;
		}
	}
}