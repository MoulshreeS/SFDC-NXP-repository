public with sharing class EVE_AdditionalNotifications {

	public static final String EMAIL_TEMPLATE_DEVNAME_CASE_CONTACT = 'Marvell_Contacts_Additional_Notification';
	public static final String EMAIL_TEMPLATE_DEVNAME_ENTITLEMENT_CONTACT = 'MarvellEntitlementContactAdditionalNotification';

//	public static final String EMAIL_NO_REPLY_AT_NXP_DOT_COM = 'no.reply@nxp.com';
	public static final String EMAIL_TECHSUPPORT_AT_NXP_DOT_COM = 'tech.support@nxp.com';

	public static final String CASE_STATUS_CLOSE = 'Close';

	public static final OrgWideEmailAddress orgWideEmailAddress = getOrgWideEmailAddressByAddress(EMAIL_TECHSUPPORT_AT_NXP_DOT_COM);


	public static void notifyCaseContacts() {
		if (orgWideEmailAddress == null ) {
			System.debug(LoggingLevel.Error, 'NO orgWideEmailAddress for ' + EMAIL_TECHSUPPORT_AT_NXP_DOT_COM);
			return;
		}
		Id tempateId = getTemplateIdByDeveloperName(EMAIL_TEMPLATE_DEVNAME_CASE_CONTACT);
		if (tempateId == null) {
			System.debug(LoggingLevel.Error, 'NO template with Name ' + EMAIL_TEMPLATE_DEVNAME_CASE_CONTACT);
			return;
		}

		Case[] convertedCases = getConvertedCases();
//		System.debug(LoggingLevel.Error, 'k33pdbg convertedCases = ' + JSON.serializePretty(convertedCases));

		sendNotificationForCases(convertedCases, tempateId);
	}

	public static void sendNotificationForCases(Case[] cases, Id templateId) {
		Messaging.SingleEmailMessage[] messages = new Messaging.SingleEmailMessage[]{};
		for (Case aCase : cases) {
			messages.add(createEmailMessage(templateId, aCase.Id, aCase.ContactId));
		}
		sendEmailMessages(messages);
	}

	public static void sendNotificationForEntitlements(Set<Id> convertedEntitlementIds, Id templateId) {
		Set<Id> entitlementIdsWithOpenCases = getEntitlementIdWithOpenCases(convertedEntitlementIds);
		Entitlement_Contact__c[] entitlementContacts = getEntitlementContactsByEntitlementId(entitlementIdsWithOpenCases);

		Messaging.SingleEmailMessage[] messages = new Messaging.SingleEmailMessage[]{};
		for (Entitlement_Contact__c entitlementContact : entitlementContacts) {
			messages.add(createEmailMessage(templateId, entitlementContact.Id, entitlementContact.Contact__c));
		}
		sendEmailMessages(messages);
	}

	public static void notifyCaseContactsBatchRun() {
		if (orgWideEmailAddress == null ) {
			System.debug(LoggingLevel.Error, 'NO orgWideEmailAddress for ' + EMAIL_TECHSUPPORT_AT_NXP_DOT_COM);
			return;
		}
		Id templateId = getTemplateIdByDeveloperName(EMAIL_TEMPLATE_DEVNAME_CASE_CONTACT);
		if (templateId == null) {
			System.debug(LoggingLevel.Error, 'NO template with Name ' + EMAIL_TEMPLATE_DEVNAME_CASE_CONTACT);
			return;
		}
		Database.executeBatch(new EVE_AddCaseContactNotificationBatch(templateId), 10);
	}

	public static void notifyCaseContacts(Set<Id> caseIds, Id templateId) {
		Case[] casesToSendNotification = getCasesById(caseIds);
		sendNotificationForCases(casesToSendNotification, templateId);
	}

	public static void notifyEntitlementContactsBatchRun() {
		if (orgWideEmailAddress == null ) {
			System.debug(LoggingLevel.Error, 'NO orgWideEmailAddress for ' + EMAIL_TECHSUPPORT_AT_NXP_DOT_COM);
			return;
		}
		Id templateId = getTemplateIdByDeveloperName(EMAIL_TEMPLATE_DEVNAME_ENTITLEMENT_CONTACT);
		if (templateId == null) {
			System.debug(LoggingLevel.Error, 'NO template with Name ' + EMAIL_TEMPLATE_DEVNAME_ENTITLEMENT_CONTACT);
			return;
		}
		Database.executeBatch(new EVE_AddEntContactNotificationBatch(templateId), 20);
	}

	public static void notifyEntitlementContacts() {
		if (orgWideEmailAddress == null ) {
			System.debug(LoggingLevel.Error, 'NO orgWideEmailAddress for ' + EMAIL_TECHSUPPORT_AT_NXP_DOT_COM);
			return;
		}
		Id tempateId = getTemplateIdByDeveloperName(EMAIL_TEMPLATE_DEVNAME_ENTITLEMENT_CONTACT);
		if (tempateId == null) {
			System.debug(LoggingLevel.Error, 'NO template with Name ' + EMAIL_TEMPLATE_DEVNAME_ENTITLEMENT_CONTACT);
			return;
		}

		Entitlement[] convertedEntitlements = getConvertedEntitlements();
		Set<Id> entitlementIds = (new Map<Id, Entitlement>(convertedEntitlements)).keySet();
		Set<Id> entitlementIdsWithOpenCases = getEntitlementIdWithOpenCases(entitlementIds);
		Entitlement_Contact__c[] entitlementContacts = getEntitlementContactsByEntitlementId(entitlementIdsWithOpenCases);

		Messaging.SingleEmailMessage[] messages = new Messaging.SingleEmailMessage[]{};
		for (Entitlement_Contact__c anEntitlementContact : entitlementContacts) {
			messages.add(createEmailMessage(tempateId, anEntitlementContact.Id, anEntitlementContact.Contact__c));
		}

		sendEmailMessages(messages);

	}

	public static Set<Id> getEntitlementIdWithOpenCases(Set<Id> entitlementIds) {
		Case[] openCases = getOpenCasesByEntitlementIds(entitlementIds);
		Set<Id> openCasesEntitlementIds = new Set<Id>();
		for (Case aCase : openCases) {
			openCasesEntitlementIds.add(aCase.EntitlementId);
		}
		return openCasesEntitlementIds;
	}

	public static Case[] getOpenCasesByEntitlementIds(Set<Id> entitlementIds) {
		return [
				SELECT Id, EntitlementId, Subject, Entitlement.Name, Status
				FROM Case
				WHERE EntitlementId IN :entitlementIds
				AND Status != :CASE_STATUS_CLOSE
				AND RelatedToId__c LIKE 'Marvell-%'
		];
	}

	public static Case[] getConvertedCases() {
		return [
				SELECT Id, RelatedToId__c, ContactId,
						Contact.Name, Subject, Entitlement.Name
				FROM Case
				WHERE RelatedToId__c LIKE 'Marvell-%'
				AND Status != :CASE_STATUS_CLOSE
				AND ContactId != null
		];
	}

	public static Case[] getCasesById(Set<Id> caseId) {
		return [
				SELECT Id, RelatedToId__c, ContactId,
						Contact.Name, Subject, Entitlement.Name
				FROM Case
				WHERE Id IN :caseId
		];
	}

	public static Entitlement[] getConvertedEntitlements() {
		return [
				SELECT Id, Name
				FROM Entitlement
				WHERE Marvell_Id__c != null
		];
	}

	public static Entitlement[] getEntitlementsByIds(Set<Id> entitlementIds) {
		return [
				SELECT Id, Name
				FROM Entitlement
				WHERE Marvell_Id__c != null
				AND Id IN :entitlementIds
		];
	}

	private static Entitlement_Contact__c[] getEntitlementContactsByEntitlementId(Set<Id> ids) {
		return [
				SELECT Id, Entitlement__c, Contact__c,
						Entitlement__r.Name, Contact__r.Name
				FROM Entitlement_Contact__c
				WHERE Entitlement__c IN :ids
		];
	}

	public static Set<Id> getContactIds(Case[] cases) {
		Set<Id> result = new Set<Id>();
		for (Case aCase : cases) {
			if (aCase.ContactId != null) {
				result.add(aCase.ContactId);
			}
		}
		return result;
	}

	public static Id getTemplateIdByDeveloperName(String devName) {
		EmailTemplate emailTemplate = [
				SELECT Id
				FROM EmailTemplate
				WHERE DeveloperName = :devName
				LIMIT 1
		];
		return emailTemplate != null ? emailTemplate.Id : null;
	}

	public static OrgWideEmailAddress getOrgWideEmailAddressByAddress(String emailAddress) {
		OrgWideEmailAddress[] result = [
				SELECT Id, Address
				FROM OrgWideEmailAddress
				WHERE Address = : emailAddress
				LIMIT 1
		];
		return result.size() > 0 ? result[0] : null;
	}

	public static void sendEmailMessages (Messaging.SingleEmailMessage[] messages) {
		Messaging.SendEmailResult[] results = Messaging.sendEmail(messages, false);
		for (Messaging.SendEmailResult res : results) {
			if (res.success) {
				System.debug('The email was sent successfully.');
			} else {
				System.debug('The email failed to send: ' +  res.errors[0].message);
			}
		}
	}

	public static Messaging.SingleEmailMessage createEmailMessage (Id templateId, Id whatId, Id targetOptionId) {
		Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
		message.setTargetObjectId(targetOptionId);
		message.setOrgWideEmailAddressId(orgWideEmailAddress.Id);
		message.setReplyTo(EMAIL_TECHSUPPORT_AT_NXP_DOT_COM);
		message.setUseSignature(false);
		message.setBccSender(false);
		message.setSaveAsActivity(false);
		message.setTemplateID(templateId);
		message.setWhatId(whatId); //This is important for the merge fields in template to work
		return message;
	}

//	public static void testk33p() {
//		Case[] convertedCases = [SELECT Id, ContactId FROM Case WHERE Id = '5004E00000Bt07Y'];
//		Id[] caseIds = new List<Id>((new Map<Id,Case>(convertedCases)).keySet());
//		System.debug(LoggingLevel.Error, 'k33pdbg caseIds = ' + JSON.serializePretty(caseIds));
//		Id[] contactIds = new List<Id>(getContactIds(convertedCases));
//		System.debug(LoggingLevel.Error, 'k33pdbg contactIds = ' + JSON.serializePretty(contactIds));
//		Contact[] contacts = [SELECT Id, Email FROM Contact WHERE Id IN :contactIds];
//		System.debug(LoggingLevel.Error, 'k33pdbg contacts = ' + JSON.serializePretty(contacts));
//		Map<Id, Contact> contactsMap = new Map<Id, Contact>(contacts);
//		Id tempateId = getTemplateIdByDeveloperName(EMAIL_TEMPLATE_DEVNAME_CASE_CONTACT);
//		System.debug(LoggingLevel.Error, 'k33pdbg tempateId = ' + tempateId);
//		Messaging.SingleEmailMessage[] messages = new Messaging.SingleEmailMessage[]{};
//
//		if (orgWideEmailAddress != null ) {
//			sendEmailMessages(messages);
//		} else  {
//			System.debug(LoggingLevel.Error, 'k33pdbg NO orgWideEmailAddress for ' + EMAIL_TECHSUPPORT_AT_NXP_DOT_COM);
//		}
//
//	}

//	public static void testk33pEnt () {
//		if (orgWideEmailAddress == null ) {
//			System.debug(LoggingLevel.Error, 'NO orgWideEmailAddress for ' + EMAIL_TECHSUPPORT_AT_NXP_DOT_COM);
//			return;
//		}
//		Id tempateId = getTemplateIdByDeveloperName(EMAIL_TEMPLATE_DEVNAME_ENTITLEMENT_CONTACT);
//		System.debug(LoggingLevel.Error, 'k33pdbg tempateId = ' + tempateId);
//		if (tempateId == null) {
//			System.debug(LoggingLevel.Error, 'NO template with Name ' + EMAIL_TEMPLATE_DEVNAME_ENTITLEMENT_CONTACT);
//			return;
//		}
//
//		Entitlement[] convertedEntitlements = [SELECT Id FROM Entitlement WHERE ID = '5504E000001cBWB'];
//		System.debug(LoggingLevel.Error, 'k33pdbg convertedEntitlements = ' + JSON.serializePretty(convertedEntitlements));
//		Set<Id> entitlementIds = (new Map<Id, Entitlement>(convertedEntitlements)).keySet();
//		System.debug(LoggingLevel.Error, 'k33pdbg entitlementIds = ' + JSON.serializePretty(entitlementIds));
//
//		Set<Id> entitlementIdsWithOpenCases = getEntitlementIdWithOpenCases(entitlementIds);
//		System.debug(LoggingLevel.Error, 'k33pdbg entitlementIdsWithOpenCases = ' + JSON.serializePretty(entitlementIdsWithOpenCases));
//
//		Entitlement_Contact__c[] entitlementContacts = getEntitlementContactsByEntitlementId(entitlementIdsWithOpenCases);
//		System.debug(LoggingLevel.Error, 'k33pdbg entitlementContacts = ' + JSON.serializePretty(entitlementContacts));
//
//		Messaging.SingleEmailMessage[] messages = new Messaging.SingleEmailMessage[]{};
//		for (Entitlement_Contact__c anEntitlementContact : entitlementContacts) {
//			messages.add(createEmailMessage(tempateId, anEntitlementContact.Id, anEntitlementContact.Contact__c));
//		}
//
//		sendEmailMessages(messages);
//	}
}