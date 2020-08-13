public with sharing class EVE_MarvellConvertAttachements {

	public static final String CASE_EXTERNAL_ID_PREFIX = 'Marvell-';
	public static final String DEFAULT_EXPORT_FOLDER_PATH = 'c:\\export\\Attachments\\';

	private static final String CASE_PREFIX = '500';
	private static final String MARVELL_CASE_COMMENT_PREFIX = 'a0A';

	private static final String ATTACHMENT_SHARE_TYPE_C = 'C';
	private static final String ATTACHMENT_VISIBILITY_INTERNALL_USERS= 'InternalUsers';
	private static final String ATTACHMENT_VISIBILITY_ALL_USERS= 'AllUsers';

	public static final String MARVELL_CASE_COMMENT_INTERNAL = 'Internal';

	private static Map<Id, Id> existingCaseIdByMarvelId;
	private static Map<String, String> marvellUserEmailToNXPUserEmail;
	private static Map<Id, String> marvellUserEmailById;
	private static Map<String, Id> nxpUserIdByEmail;

	private static String exportFolderPath;

	private static Map<Id, Id> marvellCaseIdByMarvellCaseCommentId;

	private static Map<Id, String> caseCommentTypeByCaseCommentId;

	private static Id currentUserId = UserInfo.getUserId();

	public static void updateMarvellAttachments() {
		Database.executeBatch(new EVE_UpdateMarvellAttachmentsBatch(), 200);
	}

	public static EVE_ConversionResultDTO updateMarvellAttachments(Set<Id> marvellAttachmentIds) {
		Marvell_Attachment__c[] marvellAttachments = getAttachmentsToUpdate(marvellAttachmentIds);
		System.debug(LoggingLevel.Error, marvellAttachments.size() + ' Marvell Attachment found to update');

		exportFolderPath = String.isNotBlank(Label.MarvellMigrationAttachmentPath) ?
				Label.MarvellMigrationAttachmentPath : DEFAULT_EXPORT_FOLDER_PATH;

		Set<String> caseExternalIds = new Set<String>();
		Set<Id> caseCommentMarvellIds = new Set<Id>();
		Set<Id> ownerIds = new Set<Id>();

		for (Marvell_Attachment__c marvellAttachment : marvellAttachments) {
			if (String.isNotBlank(marvellAttachment.OwnerId__c)) {
				ownerIds.add(marvellAttachment.OwnerId__c);
			}
			if (String.isNotBlank(marvellAttachment.ParentId__c)) {
				String parentIdPrefix = marvellAttachment.ParentId__c.left(3);
				if (parentIdPrefix == CASE_PREFIX) {
					caseExternalIds.add(CASE_EXTERNAL_ID_PREFIX + marvellAttachment.ParentId__c);
				} else if (parentIdPrefix == MARVELL_CASE_COMMENT_PREFIX) {
					caseCommentMarvellIds.add(marvellAttachment.ParentId__c);
				}
			}
		}

		if (caseCommentMarvellIds.size() > 0) {
			Marvell_CaseComment__c[] marvellCaseComments = getMarvellCaseCommentsByMarvellId(caseCommentMarvellIds);
			marvellCaseIdByMarvellCaseCommentId = getMarvellCaseIdByMarvellCaseCommentId(marvellCaseComments);
			caseCommentTypeByCaseCommentId = getCaseCommentTypeByCaseCommentId(marvellCaseComments);
			Set<Id> marvellCaseIdsFromCaseComments = new Set<Id>(marvellCaseIdByMarvellCaseCommentId.values());
			for (Id marvellCaseId : marvellCaseIdsFromCaseComments) {
				caseExternalIds.add(CASE_EXTERNAL_ID_PREFIX + marvellCaseId);
			}
		}

		Case[] nxpCases = getCasesByMarvellId(caseExternalIds);
		existingCaseIdByMarvelId = getExistingCaseIdByMarvelId(nxpCases);

		marvellUserEmailToNXPUserEmail = getEmailMappingFromMetadata();
		marvellUserEmailById = getMarvellUserEmailById(ownerIds);
		Set<String> userEmails = new Set<String>(marvellUserEmailById.values());
		Set<String> nxpUserEmailsFromMapping = new Set<String>(marvellUserEmailToNXPUserEmail.values());
		userEmails.addAll(nxpUserEmailsFromMapping);
		nxpUserIdByEmail = getUserIdsByEmails(userEmails);

		for (Marvell_Attachment__c marvellAttachment : marvellAttachments) {
			amendMarvellAttachment(marvellAttachment);
		}
		update marvellAttachments;

		return new EVE_ConversionResultDTO(marvellAttachments.size(), 0, 0);
	}

	private static void amendMarvellAttachment(Marvell_Attachment__c attachment) {
		if (attachment.CreatedDate__c == null && attachment.CreatedDateText__c != null) {
			attachment.CreatedDate__c = parseAttachemntDateTime(attachment.CreatedDateText__c);
		}
		if (attachment.LastModifiedDate__c == null && attachment.LastModifiedDateText__c != null) {
			attachment.LastModifiedDate__c = parseAttachemntDateTime(attachment.LastModifiedDateText__c);
		}
		attachment.CaseID__c = convertMAttachmentParentIdToNXPCaseId(attachment.ParentId__c);
		attachment.Body__c = exportFolderPath + attachment.ID__c;
		attachment.OwnerIdNew__c = convertMarvellUserIdToNxpUserId(attachment.OwnerId__c);
		attachment.CreatedByIDNew__c = attachment.OwnerIdNew__c;
		attachment.LastModifiedByIDNew__c = convertMarvellUserIdToNxpUserId(attachment.LastModifiedByID__c);
		attachment.Description__c = 'Migrated from Marvell';
		attachment.ShareType__c = ATTACHMENT_SHARE_TYPE_C;
		Boolean isInternalCaseCommentAttachment = isInternalCaseCommentId(attachment.ParentId__c);
		attachment.Visibility__c = isInternalCaseCommentId(attachment.ParentId__c) ?
				ATTACHMENT_VISIBILITY_INTERNALL_USERS : ATTACHMENT_VISIBILITY_ALL_USERS;
	}

	//REPO
	private static Marvell_Attachment__c[] getAttachmentsToUpdate(Set<Id> ids) {
		Marvell_Attachment__c[] marvellAttachments = [
				SELECT
						Body__c,
						CaseID__c, CreatedDateText__c, CreatedDate__c,
						ID__c,
						LastModifiedByID__c, LastModifiedDateText__c, LastModifiedDate__c,
						OwnerId__c, OwnerIdNew__c,
						ParentId__c
				FROM Marvell_Attachment__c
				WHERE Id IN :ids
		];
		return marvellAttachments;
	}

	private static Case[] getCasesByMarvellId(Set<String> externalIds) {
		Case[] cases = [
				SELECT Id, RelatedToId__c, EntitlementId
				FROM Case
				WHERE RelatedToId__c IN :externalIds
		];
		return cases;
	}

	private static Marvell_CaseComment__c[] getMarvellCaseCommentsByMarvellId(Set<Id> marvellIds) {
		Marvell_CaseComment__c[] caseComments = [
				SELECT InternalCustomer__c, MarvellCaseId__c, Marvell_Id__c
				FROM Marvell_CaseComment__c
				WHERE Marvell_Id__c IN :marvellIds
		];
		return caseComments;
	}

	private static Map<String, Id> getUserIdsByEmails(Set<String> emails) {
		User[] users = [
				SELECT id, Email
				FROM User
				WHERE Email in :emails
				AND isActive = true
		];
		Map<String, Id> userIdsByEmail = new Map<String, Id>();
		for (User usr : users) {
			userIdsByEmail.put(usr.Email, usr.Id);
		}
		return userIdsByEmail;
	}

	//Marvell Attachemt Service
	private static Id convertMarvellUserIdToNxpUserId(Id ownerId) {
		Id nxpUserId = getNxpUserIdByMarvellUserId(ownerId);
		return nxpUserId != null ? nxpUserId : currentUserId;
	}

	private static Datetime parseAttachemntDateTime(String input) {
		if (String.isBlank(input)) {
			return null;
		}
		Datetime output = convertISO8601(input);
		if (output == null) {
			List<String> dateAndTime = input.split(' ');
			String aDate = dateAndTime.get(0);
			String aTime = dateAndTime.get(1);
			List<String> yearMonthDay = aDate.split('-');
			List<String> hourMinuteSecond = aTime.split(':');
			Integer year = Integer.valueOf(yearMonthDay.get(0));
			Integer month = Integer.valueOf(yearMonthDay.get(1));
			Integer day = Integer.valueOf(yearMonthDay.get(2));
			Integer hour = Integer.valueOf(hourMinuteSecond.get(0));
			Integer minute = Integer.valueOf(hourMinuteSecond.get(1));
			Integer second = Integer.valueOf(hourMinuteSecond.get(2));
			output = DateTime.newInstanceGmt(year, month, day, hour, minute, second).addHours(8);
		}
		return output;
	}

	// Case Service
	private static Map<Id, Id> getExistingCaseIdByMarvelId(Case[] existingCases) {
		Map<Id, Id> existingCaseIdByMarvelId = new Map<Id, Id>();
		for (Case aCase : existingCases) {
			String key = aCase.RelatedToId__c.removeStart(CASE_EXTERNAL_ID_PREFIX);
			if (!existingCaseIdByMarvelId.containsKey(key)) {
				existingCaseIdByMarvelId.put(key, aCase.Id);
			}
		}
		return existingCaseIdByMarvelId;
	}

	//Case Comment Service
	private static Map<Id, Id> getMarvellCaseIdByMarvellCaseCommentId (Marvell_CaseComment__c[] marvellCaseComments) {
		Map<Id, Id> result = new Map<Id, Id>();
		for (Marvell_CaseComment__c caseComment : marvellCaseComments) {
			result.put(caseComment.Marvell_Id__c, caseComment.MarvellCaseId__c);
		}
		return result;
	}

	private static Map<Id, String> getCaseCommentTypeByCaseCommentId (Marvell_CaseComment__c[] marvellCaseComments) {
		Map<Id, String> result = new Map<Id, String>();
		for (Marvell_CaseComment__c caseComment : marvellCaseComments) {
			result.put(caseComment.Marvell_Id__c, caseComment.InternalCustomer__c);
		}
		return result;
	}

	//User Service
	private static Map<String, String> getEmailMappingFromMetadata() {
		Map<String, String> emailMapping = new Map<String,String>();
		MarvellToNXPUserEmailMapping__mdt[] mappingRecords = [
				SELECT MasterLabel, DeveloperName, MarvellUserEmail__c, NXPUserEmail__c
				FROM MarvellToNXPUserEmailMapping__mdt
		];
		if (!mappingRecords.isEmpty()) {
			for (MarvellToNXPUserEmailMapping__mdt mapping : mappingRecords) {
				if (String.isNotBlank(mapping.MarvellUserEmail__c) && String.isNotBlank(mapping.NXPUserEmail__c)) {
					emailMapping.put(mapping.MarvellUserEmail__c, mapping.NXPUserEmail__c);
				}
			}
		}
		return emailMapping;
	}

	private static Map<Id, String> getMarvellUserEmailById(Set<Id> ids) {
		Marvell_MemberToEmailMapping__c[] memberToEmailMappings = [
				SELECT MemberId__c, Email__c
				FROM Marvell_MemberToEmailMapping__c
				WHERE MemberId__c IN :ids
		];
		Map<Id, String> result = new  Map<Id,String>();
		for (Marvell_MemberToEmailMapping__c mapping : memberToEmailMappings) {
			result.put(mapping.MemberId__c, mapping.Email__c);
		}
		return result;
	}

	private static Id getNxpUserIdByMarvellUserId(Id marvellUserId) {
		if (marvellUserEmailById.containsKey(marvellUserId)) {
			String userEmail = marvellUserEmailById.get(marvellUserId);
			if (marvellUserEmailToNXPUserEmail.containsKey(userEmail)) {
				userEmail = marvellUserEmailToNXPUserEmail.get(userEmail);
			}
			if (nxpUserIdByEmail.containsKey(userEmail)) {
				return nxpUserIdByEmail.get(userEmail);
			}
		}
		return null;
	}

	private static Id convertMAttachmentParentIdToNXPCaseId (Id attachmentParentId) {
		if (attachmentParentId == null) {
			return null;
		}
		String parentIdPrefix = String.valueOf(attachmentParentId).left(3);
		Id marvellCaseId;
		if (parentIdPrefix == CASE_PREFIX) {
			marvellCaseId = attachmentParentId;
		} else if (parentIdPrefix == MARVELL_CASE_COMMENT_PREFIX) {
			marvellCaseId = marvellCaseIdByMarvellCaseCommentId.get(attachmentParentId);
		}
		Id caseId = existingCaseIdByMarvelId.containsKey(marvellCaseId)
				? existingCaseIdByMarvelId.get(marvellCaseId)
				: null;
		return caseId;
	}

	private static DateTime convertISO8601( String iso8601_ts) {
		try {
			DateTime dt = (DateTime) JSON.deserialize('"' + iso8601_ts + '"', DateTime.class);
			return DateTime.newInstance(dt.getTime());
		} catch (JSONException ex) {
			return null;
		}
	}

	private static Boolean isInternalCaseCommentId(Id caseCommentParentId) {
		return caseCommentTypeByCaseCommentId != null
				&& caseCommentTypeByCaseCommentId.containsKey(caseCommentParentId)
				&& caseCommentTypeByCaseCommentId.get(caseCommentParentId).equals(MARVELL_CASE_COMMENT_INTERNAL);
	}
}