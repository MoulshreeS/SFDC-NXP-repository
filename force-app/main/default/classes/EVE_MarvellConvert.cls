public with sharing class EVE_MarvellConvert {

	private static final String ACCOUNT_NAME_NXP_COMMUNITY = 'NXP Community';
	private static final String CASE_ORIGIN_SELF_SERVICE_PORTAL = 'Self Service Portal';
	private static final String CASE_RECORDTYPE_DEVELOPER_NAME_TS_COMMUNITY = 'TS_Community';

	public static final String CASE_EXTERNAL_ID_PREFIX = 'Marvell-';
	public static final String EXPORT_FOLDER_PATH = 'c:\\export\\Attachments\\';

	public static final String AT_MARVELL_DOT_COM = '@marvell.com';
	public static final String INVALID_SUFFIX = '.invalid';

	public static final String DEFAULT_ENTITLEMENT_CREATED_BY_USER_EMAIL = 'sylvain.sevel@nxp.com';

	public static final String ENTITLEMENT_PRIORITY_MEDIUM = 'Medium';

	public static final Integer EMAIL_MESSAGE_HTML_BODY_MAX_LENGTH = 128000;
	public static final Integer FEEDITEM_BODY_MAX_LENGTH = 10000;

	public static final String QUEUE_NAME_TS_L3_WIRELESS_US_AE = 'TS L3 Wireless US AE';
	public static final String QUEUE_NAME_TS_L3_WIRELESS_CHINA_AE = 'TS L3 Wireless China AE';
	public static final String QUEUE_NAME_TS_L3_WIRELESS_INDIA_AE = 'TS L3 Wireless India AE';
	public static final String QUEUE_NAME_TS_L3_WIRELESS_TAIWAN_AE = 'TS L3 Wireless Taiwan AE';
	public static final String QUEUE_NAME_TS_L3_WIRELESS_DISPATCH = 'TS L3 Wireless Dispatch';

	public static final String MARVELL_CASE_TEAM_ROLE_NAME_CUSTOMERS = 'Customers';
	public static final String MARVELL_CASE_TEAM_ROLE_NAME_UNREGISTERED = 'Unregistered';

	public static final String USER_LICENSE_NAME_CUSTOMER_COMMUNITY_LOGIN = 'Customer Community Login';

	public static final String ENTITLEMENT_TYPE_FREE = 'Free';
	public static final String ENTITLEMENT_SUBTYPE_DEVELOPMENT_PROJECT = 'Development Project';

	public static final Set<String> QUEUE_NAMES_TS_L3_WIRELESS = new Set<String> {
		QUEUE_NAME_TS_L3_WIRELESS_US_AE,
		QUEUE_NAME_TS_L3_WIRELESS_CHINA_AE,
		QUEUE_NAME_TS_L3_WIRELESS_INDIA_AE,
		QUEUE_NAME_TS_L3_WIRELESS_TAIWAN_AE,
		QUEUE_NAME_TS_L3_WIRELESS_DISPATCH
	};

	public static String CASE_WEBREGION_AMERICAS = 'Americas';
	public static String CASE_WEBREGION_CHINA = 'China';
	public static String CASE_WEBREGION_KOREA = 'Korea';
	public static String CASE_WEBREGION_EMEA = 'EMEA';
	public static String CASE_WEBREGION_INDIA = 'India';
	public static String CASE_WEBREGION_JAPAN = 'Japan';
	public static String CASE_WEBREGION_SEA = 'SEA';

	public static String CONTACT_USER_REGION_AMERICAS = 'Americas';
	public static String CONTACT_USER_REGION_EMEA = 'EMEA';
	public static String CONTACT_USER_REGION_SOUTH_ASIA_PACIFIC = 'South Asia Pacific';
	public static String CONTACT_USER_REGION_JAPAN = 'Japan';
	public static String CONTACT_USER_REGION_KOREA = 'Korea';
	public static String CONTACT_USER_REGION_GREATER_CHINA = 'Greater China';

	private static final Map<String, String> MARVELL_TO_NXP_CONTACT_REGION_MAP = new Map<String, String> {
		'' => '',
		'Asia' => CONTACT_USER_REGION_SOUTH_ASIA_PACIFIC,
		'Asia - China' => CONTACT_USER_REGION_GREATER_CHINA,
		'Asia - India' => CONTACT_USER_REGION_SOUTH_ASIA_PACIFIC,
		'Asia - Japan' => CONTACT_USER_REGION_JAPAN,
		'Asia - Korea' => CONTACT_USER_REGION_KOREA,
		'Asia - Other' => CONTACT_USER_REGION_SOUTH_ASIA_PACIFIC,
		'Asia - Singapore' => CONTACT_USER_REGION_SOUTH_ASIA_PACIFIC,
		'Asia - Taiwan' => CONTACT_USER_REGION_SOUTH_ASIA_PACIFIC,
		'Canada' => CONTACT_USER_REGION_AMERICAS,
		'Europe' => CONTACT_USER_REGION_EMEA,
		'Europe - France' => CONTACT_USER_REGION_EMEA,
		'Europe - Germany' => CONTACT_USER_REGION_EMEA,
		'Europe - Other' => CONTACT_USER_REGION_EMEA,
		'Europe - UK' => CONTACT_USER_REGION_EMEA,
		'Israel' => CONTACT_USER_REGION_EMEA,
		'South America' => CONTACT_USER_REGION_AMERICAS,
		'USA' => CONTACT_USER_REGION_AMERICAS,
		'USA - Central' => CONTACT_USER_REGION_AMERICAS,
		'USA - East' => CONTACT_USER_REGION_AMERICAS,
		'USA - West' => CONTACT_USER_REGION_AMERICAS,
		'USA-West' => CONTACT_USER_REGION_AMERICAS
	};

	private static final Map<String, String> webRegionToQueueName = new Map<String, String> {
		CASE_WEBREGION_AMERICAS => QUEUE_NAME_TS_L3_WIRELESS_US_AE,
		CASE_WEBREGION_CHINA => QUEUE_NAME_TS_L3_WIRELESS_CHINA_AE,
		CASE_WEBREGION_KOREA => QUEUE_NAME_TS_L3_WIRELESS_CHINA_AE,
		CASE_WEBREGION_EMEA => QUEUE_NAME_TS_L3_WIRELESS_INDIA_AE,
		CASE_WEBREGION_INDIA => QUEUE_NAME_TS_L3_WIRELESS_INDIA_AE,
		CASE_WEBREGION_JAPAN => QUEUE_NAME_TS_L3_WIRELESS_TAIWAN_AE,
		CASE_WEBREGION_SEA => QUEUE_NAME_TS_L3_WIRELESS_TAIWAN_AE
	};

	private static final Map<String, String> MARVELL_TO_NXP_REGION_MAP = new Map<String, String> {
		'Asia' => CASE_WEBREGION_SEA,
		'Asia - China' => CASE_WEBREGION_CHINA,
		'Asia - India' => CASE_WEBREGION_INDIA,
		'Asia - Japan' => CASE_WEBREGION_JAPAN,
		'Asia - Korea' => CASE_WEBREGION_KOREA,
		'Asia - Other' => CASE_WEBREGION_SEA,
		'Asia - Singapore' => CASE_WEBREGION_SEA,
		'Asia - Taiwan' => CASE_WEBREGION_CHINA,
		'Australia' => CASE_WEBREGION_SEA,
		'Canada' => CASE_WEBREGION_AMERICAS,
		'Europe' => CASE_WEBREGION_EMEA,
		'Europe - France' => CASE_WEBREGION_EMEA,
		'Europe - Germany' => CASE_WEBREGION_EMEA,
		'Europe - Other' => CASE_WEBREGION_EMEA,
		'Europe - Poland' => CASE_WEBREGION_EMEA,
		'Europe - Spain' => CASE_WEBREGION_EMEA,
		'Europe - UK' => CASE_WEBREGION_EMEA,
		'Israel' => CASE_WEBREGION_EMEA,
		'South America' => CASE_WEBREGION_AMERICAS,
		'USA' => CASE_WEBREGION_AMERICAS,
		'USA - Central' => CASE_WEBREGION_AMERICAS,
		'USA - East' => CASE_WEBREGION_AMERICAS,
		'USA - West' => CASE_WEBREGION_AMERICAS,
		'USA-West' => CASE_WEBREGION_AMERICAS
	};

	public static final String CASE_TOPIC_HARDWARE_PRODUCT_SUPPORT = 'Hardware Product Support';
	public static final String CASE_TOPIC_SOFTWARE_PRODUCT_SUPPORT = 'Software Product Support';
	public static final String CASE_TOPIC_DOCUMENTATION = 'Documentation';
	public static final String CASE_TOPIC_OTHER = 'Other';

	public static final String CASE_PRODUCT_LVL1_WIRELESS_CONNECTIVITY = 'Wireless Connectivity';
	public static final String CASE_PRODUCT_LVL2_WIFI_AND_BLUETOOTH = 'Wi-Fi + Bluetooth';

	private static final Map<String, String> TYPE_TO_TOPIC_MAP = new Map<String, String> {
		'BT SW' => CASE_TOPIC_SOFTWARE_PRODUCT_SUPPORT,
		'Doc' => CASE_TOPIC_DOCUMENTATION,
		'HW' => CASE_TOPIC_HARDWARE_PRODUCT_SUPPORT,
		'IOT' => CASE_TOPIC_OTHER,
		'SW' => CASE_TOPIC_SOFTWARE_PRODUCT_SUPPORT,
		'SW BT' => CASE_TOPIC_SOFTWARE_PRODUCT_SUPPORT,
		'SW WiFi' => CASE_TOPIC_SOFTWARE_PRODUCT_SUPPORT,
		'WiFi SW' => CASE_TOPIC_SOFTWARE_PRODUCT_SUPPORT
	};

	private static final Map<String[], String[]> MARVELL_ISSUE_TO_NXP_TOPIC = new Map<String[],String[]> {
		new String[]{'BT SW',''} => new String[]{'Software Product Support','SDK / BSP'},
		new String[]{'Doc','--None--'} => new String[]{'Documentation',''},
		new String[]{'Doc',''} => new String[]{'Documentation',''},
		new String[]{'HW','DC Power consumption'} => new String[]{'Hardware Product Support',''},
		new String[]{'HW','Failure Analysis'} => new String[]{'Hardware Product Support',''},
		new String[]{'HW','Host Interface'} => new String[]{'Hardware Product Support',''},
		new String[]{'HW','HW Documentation'} => new String[]{'Hardware Product Support',''},
		new String[]{'HW','HW WiFI'} => new String[]{'Hardware Product Support',''},
		new String[]{'HW','HWStorage'} => new String[]{'Hardware Product Support',''},
		new String[]{'HW','HWStorage1'} => new String[]{'Hardware Product Support',''},
		new String[]{'HW','Layout'} => new String[]{'Hardware Product Support',''},
		new String[]{'HW','Manufacturing SW Lab tool'} => new String[]{'Hardware Product Support',''},
		new String[]{'HW','Manufacturing Test Automati'} => new String[]{'Hardware Product Support',''},
		new String[]{'HW','--None--'} => new String[]{'Hardware Product Support',''},
		new String[]{'HW','Other'} => new String[]{'Hardware Product Support',''},
		new String[]{'HW','Regulatory Compliance Test'} => new String[]{'Hardware Product Support',''},
		new String[]{'HW','RF performance'} => new String[]{'Hardware Product Support',''},
		new String[]{'HW','Schematic'} => new String[]{'Hardware Product Support',''},
		new String[]{'HW','Simulation'} => new String[]{'Hardware Product Support',''},
		new String[]{'HW','Thermal'} => new String[]{'Hardware Product Support',''},
		new String[]{'HW',''} => new String[]{'Hardware Product Support',''},
		new String[]{'IOT',''} => new String[]{'Others','Others'},
		new String[]{'SW','Bluetooth Audio/Voice'} => new String[]{'Software Product Support','SDK / BSP'},
		new String[]{'SW','Bluetooth Qualification'} => new String[]{'Software Product Support','Others'},
		new String[]{'SW','COEX'} => new String[]{'Software Product Support','SDK / BSP'},
		new String[]{'SW','Driver or Firmware'} => new String[]{'Software Product Support','SDK / BSP'},
		new String[]{'SW','Linux'} => new String[]{'Software Product Support','Runtime Software / RTOS'},
		new String[]{'SW','--None--'} => new String[]{'Software Product Support','SDK / BSP'},
		new String[]{'SW','Open Source Driver'} => new String[]{'Software Product Support','SDK / BSP'},
		new String[]{'SW','Operating System'} => new String[]{'Software Product Support','Runtime Software / RTOS'},
		new String[]{'SW','SDK'} => new String[]{'Software Product Support','SDK / BSP'},
		new String[]{'SW','SDK or Driver'} => new String[]{'Software Product Support','SDK / BSP'},
		new String[]{'SW','SW WiFI'} => new String[]{'Software Product Support','SDK / BSP'},
		new String[]{'SW','SWMulti Media'} => new String[]{'Software Product Support','Others'},
		new String[]{'SW','SWMulti Media1'} => new String[]{'Software Product Support','Others'},
		new String[]{'SW','SWStorage'} => new String[]{'Software Product Support','Others'},
		new String[]{'SW','SWStorage1'} => new String[]{'Software Product Support','Others'},
		new String[]{'SW','System Design'} => new String[]{'Software Product Support','Others'},
		new String[]{'SW','Throughput Performance'} => new String[]{'Software Product Support','Others'},
		new String[]{'SW','Tools'} => new String[]{'Software Product Support','Configuration Tools'},
		new String[]{'SW','Trusted Boot'} => new String[]{'Software Product Support','SDK / BSP'},
		new String[]{'SW','UMSD Driver'} => new String[]{'Software Product Support','SDK / BSP'},
		new String[]{'SW','WiFi alliance Certification'} => new String[]{'Software Product Support','Others'},
		new String[]{'SW',''} => new String[]{'Software Product Support','SDK / BSP'},
		new String[]{'SW BT',''} => new String[]{'Software Product Support','SDK / BSP'},
		new String[]{'SW WiFi',''} => new String[]{'Software Product Support','SDK / BSP'},
		new String[]{'WiFi SW',''} => new String[]{'Software Product Support','SDK / BSP'},
		new String[]{'','Driver or Firmware'} => new String[]{'Software Product Support','SDK / BSP'},
		new String[]{'','Manager'} => new String[]{'Others','Others'},
		new String[]{'','MCLI'} => new String[]{'Others','Others'},
		new String[]{'','MicroInit'} => new String[]{'Others','Others'},
		new String[]{'','NAN (Neighborhood Aware Net'} => new String[]{'Others','Others'},
		new String[]{'','--None--'} => new String[]{'Others','Others'},
		new String[]{'','Other'} => new String[]{'Others','Others'},
		new String[]{'',''} => new String[]{'Others','Others'}
	};

	public static String CASE_INTERNAL_PRIORITY_CRITICAL = 'Critical';
	public static String CASE_INTERNAL_PRIORITY_HIGH = 'High';
	public static String CASE_INTERNAL_PRIORITY_LOW = 'Low';
	public static String CASE_INTERNAL_PRIORITY_MEDIUM = 'Medium';
	public static String CASE_INTERNAL_PRIORITY_DEFAULT = 'Default';
	public static Set<String> NXP_PRIORTIES = new Set<String>{
		CASE_INTERNAL_PRIORITY_CRITICAL,
		CASE_INTERNAL_PRIORITY_HIGH,
		CASE_INTERNAL_PRIORITY_LOW,
		CASE_INTERNAL_PRIORITY_MEDIUM,
		CASE_INTERNAL_PRIORITY_DEFAULT
	};

	public static final String CASE_STATUS_NEW = 'New';
	public static final String CASE_STATUS_IN_PROGRESS = 'In Progress';
	public static final String CASE_STATUS_PENDING_CUSTOMER_REPLY = 'Pending Customer Reply';
	public static final String CASE_STATUS_ANSWERED_BACK = 'Answered Back';
	public static final String CASE_STATUS_PENDING_INTERNAL = 'Pending Internal';
	public static final String CASE_STATUS_CLOSE = 'Close';

	private static final Map<String, String> STATUS_MAP = new Map<String, String> {
		'New' => CASE_STATUS_NEW,
		'In Progress' => CASE_STATUS_IN_PROGRESS,
		'Awaiting Customer Response' => CASE_STATUS_PENDING_CUSTOMER_REPLY,
		'Assigned' => CASE_STATUS_IN_PROGRESS,
		'Resolved' => CASE_STATUS_ANSWERED_BACK,
		'On Hold' => CASE_STATUS_IN_PROGRESS,
		'In Engineering' => CASE_STATUS_PENDING_INTERNAL,
		'Closed' => CASE_STATUS_CLOSE
	};

	public static final String LOG_SOURCE_CUSTOMER_CASE_COMMENTS = 'Marvell Customer Case Comments Conversion';
	public static final String LOG_SOURCE_INTERNAL_CASE_COMMENTS = 'Marvell Internal Case Comments Conversion';
	public static final String LOG_SOURCE_CASE = 'Marvell Case Conversion';
	public static final String LOG_SOURCE_PROJECT = 'Marvell Project Conversion';
	public static final String LOG_SOURCE_CONTACT = 'Marvell Contact Conversion';
	public static final String LOG_SOURCE_CASE_TEAM = 'Marvell Case Team Conversion';
	public static final String LOG_SOURCE_ENTITLEMENT_CONTACT = 'Marvell Entitlement Contact Generation';

	private static Set<String> CONTACT_COUNTRY_VALUES;

	public static final String MARVELL_CASE_COMMENT_INTERNAL = 'Internal';
	public static final String MARVELL_CASE_COMMENT_CUSTOMER = 'Customer';

	public static final String FEEDITEM_VISIBILITY_INTERNAL_USERS = 'InternalUsers';
	public static final String FEEDITEM_VISIBILITY_ALL_USERS = 'AllUsers';

	private static Log__c[] conversionErrors;
	private static Integer converted = 0;
	private static Integer skipped = 0;
	private static Integer failed = 0;

	private static Map<String, Id> accountIdsByNameMap;
	private static Map<String, Id> contactIdByEmailMap;
	private static Map<Id, Id> portalUserIdByContactId;
	private static Map<String, String> marvellUserEmailToNXPUserEmail;
	private static Map<Id, String[]> marvellCaseOwnerEmailsByProjectId;
	private static Map<String, Id> queueIdByName;
	private static Map<String, Id> nxpUserIdByEmail;
	private static Map<Id, String> marvellUserEmailById;
	private static Map<Id, Set<String>> queueNamesByUserId;
	private static Map<Id, Id> entitlementIdByMarvellId;
	private static Map<Id, Id> existingCaseIdByMarvelId;
	private static Map<String, String> marvellAccountNameByAccountId;

	private static Map<Id, Id> nxpEntitlementIdByMarvellCaseId;
	private static Map<Id,Set<Id>> existingEntitlementContactsMap;

	private static Map<Id, Datetime> minCaseCreateDateByProjectId;
	private static Map<Id, Datetime> maxCaseClosedDateByProjectId;

	private static Id currentUserId = UserInfo.getUserId();
	private static Id nxpCommunityId = getNXPCommunityAccountId();

	private static Map<String, String> MARVELL_OBJECTS_MAP = new Map<String,String> {
		'Marvell_Attachment__c' => 'Marvell Attachment custom object',
		'Marvell_Case__c' => 'Marvell Case custom object',
		'Marvell_CaseComment__c' => 'Marvell Case Comment custom object',
		'Marvell_Case_Team__c' => 'Marvell Case Team custom object',
		'Marvell_Contact__c' => 'Marvell Contact custom object',
		'Log__c' => 'Marvell Conversion Log custom object',
		'Marvell_MemberToEmailMapping__c' => 'Marvell Member Email Mapping custom object',
		'Marvell_Project__c' => 'Marvell Project custom object',
		'MarvellToNXPUserEmailMapping__mdt' => 'Marvell To NXP User Email Mapping custom metadata object'
	};

	public static Boolean initCheck() {
		String[] messages = new String[]{};
		Map<String,RecordTypeInfo> recordTypeInfoMap = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName();
		Boolean caseHasCommunityRT = recordTypeInfoMap.containsKey(CASE_RECORDTYPE_DEVELOPER_NAME_TS_COMMUNITY);
		if (!caseHasCommunityRT) {
			messages.add('Case object doesn\'t have TS Community Record Type');
		}

		Boolean userHasAuditPermission = hasCreateAuditFieldsPermission();
		if (!userHasAuditPermission) {
			messages.add('User doesn\'t have Audit Permission');
		}

		Account[] accs = [SELECT ID FROM Account WHERE Name = :ACCOUNT_NAME_NXP_COMMUNITY LIMIT 1];
		Boolean doesNXPCommunityAccountExist = accs.size() == 1;
		if (!doesNXPCommunityAccountExist) {
			messages.add('NXP Community Account does not exist');
		}

		Group[] queues = [SELECT ID FROM Group WHERE Group.Type = 'Queue' AND Name IN :QUEUE_NAMES_TS_L3_WIRELESS];
		Boolean doQueuesExist = !queues.isEmpty() && queues.size() == QUEUE_NAMES_TS_L3_WIRELESS.size();
		if (!doesNXPCommunityAccountExist) {
			messages.add('TS L3 Wireless queues do not exist');
		}

		Map<String,SObjectType> objectsMap = Schema.getGlobalDescribe();

		for (String objectApiName : MARVELL_OBJECTS_MAP.keySet()) {
			Boolean doesObjExist = objectsMap.containsKey(objectApiName);
			if (!doesObjExist) {
				messages.add(objectsMap.get(objectApiName) + ' does not exist');
			}
		}

		Boolean doesMarvellMigrationCSExist = objectsMap.containsKey('Marvell_Migration__c');
		if (!doesMarvellMigrationCSExist) {
			messages.add('Marvell Migration custom setting object does not exist');
		}

		if (doesMarvellMigrationCSExist) {
			setupMarvellCustomSetting();
		}

		Log__c[] initLogs = new Log__c[]{};
		Datetime timestamp = Datetime.now();
		for (String msg : messages) {
			initLogs.add(new Log__c(
					Source__c = 'Init check',
					Message__c = msg,
					Timestamp__c = timestamp
			));
			System.debug(LoggingLevel.Error, 'init check : ' + msg);
		}
		if (initLogs.size() > 0) {
			insert initLogs;
		}
		System.debug(LoggingLevel.Error, 'init check : ' + (messages.isEmpty() ? 'OK' : 'Failed'));
		return messages.isEmpty();
	}


	public static void setupMarvellCustomSetting(){
		Marvell_Migration__c userCustomSetting = Marvell_Migration__c.getInstance(currentUserId);
		if (userCustomSetting == null) {
			userCustomSetting = new Marvell_Migration__c(SetupOwnerId = currentUserId);
		}
		userCustomSetting.IsActive__c = true;
		upsert userCustomSetting;
	}

	public static void disableMarvellCustomSetting(){
		System.debug(LoggingLevel.ERROR, 'k33pdbg IN EVE_MarvellConvert.disableMarvellCustomSetting');
		Marvell_Migration__c userCustomSetting = Marvell_Migration__c.getInstance(currentUserId);
		if (userCustomSetting != null) {
			userCustomSetting.IsActive__c = false;
			update userCustomSetting;
		}
	}


	public static void convertMarvellProjects() {
		if (!initCheck()) {
			return;
		}
		Marvell_Project__c[] marvellProjects = getProjectsToConvert();
		System.debug(LoggingLevel.Error, marvellProjects.size() + ' Marvell Projects found to convert');

		Entitlement[] nxpEntitlements = new Entitlement[]{};
		skipped = 0;
		failed = 0;
		converted = 0;

		Set<String> accountNames = new Set<String>();
		Set<Id> projectIds = new Set<Id>();

		for (Marvell_Project__c marvellProject : marvellProjects) {
			if (String.isNotBlank(marvellProject.AccountName__c)) {
				accountNames.add(marvellProject.AccountName__c);
			}
			projectIds.add(marvellProject.ProjectId__c);
		}

		Account[] accounts = getAccountsByAccountName(accountNames);
		Entitlement[] existingEntitlements = getEntitlementByMarvellProjectId(projectIds);

		marvellUserEmailToNXPUserEmail = getEmailMappingFromMetadata();
		marvellCaseOwnerEmailsByProjectId = getMarvellCasesOwnerEmailsByProjectId(projectIds);

		Set<String> marvellUserEmails = new Set<String>();
		for(Id projectId : marvellCaseOwnerEmailsByProjectId.keySet()) {
			String[] userEmails = marvellCaseOwnerEmailsByProjectId.get(projectId);
			marvellUserEmails.addAll(userEmails);
		}

		Set<String> nxpUsersEmails = new Set<String>();
		for(String marvellEmail : marvellUserEmailToNXPUserEmail.keySet()) {
			if (marvellUserEmails.contains(marvellEmail)) {
				nxpUsersEmails.add(marvellUserEmailToNXPUserEmail.get(marvellEmail));
			}
		}
		nxpUsersEmails.add(DEFAULT_ENTITLEMENT_CREATED_BY_USER_EMAIL);

		nxpUserIdByEmail = getUserIdsByEmails(nxpUsersEmails);

		accountIdsByNameMap = getAccountIdByName(accounts);
		minCaseCreateDateByProjectId = getMinCaseCreatedDateByProjectId(projectIds);
		maxCaseClosedDateByProjectId = getMaxCaseClosedDateByProjectId(projectIds);
		Map<Id,Id> existingEntitlementIdByMarvelProjectId = getEntitlementIdByMarvellId(existingEntitlements);

		conversionErrors = new Log__c[]{};

		for (Marvell_Project__c marvellProject : marvellProjects) {
			if (existingEntitlementIdByMarvelProjectId.containsKey(marvellProject.ProjectId__c)){
				skipped++;
				continue;
			}
			Entitlement newEntitlement = convertMarvellProject(marvellProject) ;
			if (newEntitlement != null) {
//				converted++;
				nxpEntitlements.add(newEntitlement);
			} else {
				failed++;
			}
		}

//		CommunityUpdateEntitlement objCommunityUpdateEntitlement = new CommunityUpdateEntitlement();
//		objCommunityUpdateEntitlement.UpdateEntitlementbeforeinsert(nxpEntitlements);

		if (nxpEntitlements.size() > 0) {
			Database.SaveResult[] saveResults = Database.insert(nxpEntitlements, false);
			for (Integer i = 0; i < saveResults.size(); i++) {
				Database.SaveResult saveResult = saveResults.get(i);
				if (saveResult.isSuccess()) {
					converted++;
				} else {
					failed++;
					Entitlement failedRecord = nxpEntitlements.get(i);
					for (Database.Error error : saveResult.getErrors()){
						conversionErrors.add(new Log__c(Timestamp__c = System.now(),
							MarvellRecordId__c = failedRecord.Marvell_Id__c,
							Message__c = error.getMessage()));
					}
				}
			}
		}

		EVE_ConversionResultDTO result = new EVE_ConversionResultDTO(marvellProjects.size(), converted, skipped, failed);

		System.debug(LoggingLevel.Error, 'converted = ' + converted);
		System.debug(LoggingLevel.Error, 'skipped = ' + skipped);
		System.debug(LoggingLevel.Error, 'failed = ' + failed);

		conversionErrors.add(new Log__c(Timestamp__c = Datetime.now(), Message__c = result.toString()));

		if (conversionErrors.size() > 0) {
			for (Log__c log : conversionErrors) {
				log.Source__c = LOG_SOURCE_PROJECT;
			}
			insert conversionErrors;
		}

		disableMarvellCustomSetting();
	}

	public static void convertMarvellCases() {
		if (!initCheck()) {
			return;
		}
		Database.executeBatch(new EVE_ConvertMarvellCasesBatch(), 200);
	}

	public static void deleteCreateRecordEventOnCases() {
		Database.executeBatch(new EVE_DeleteFeedItemsBatch('CreateRecordEvent'), 200);
	}

	public static EVE_ConversionResultDTO convertMarvellCases(Set<id> marvellCaseIds) {
		Marvell_Case__c[] marvellCases = getCasesToConvert(marvellCaseIds);
		System.debug(LoggingLevel.Error, marvellCases.size() + ' Marvell Cases found to convert');

		Case[] nxpCases = new Case[]{};

		skipped = 0;
		converted = 0;
		failed = 0;

		Id tsCommunityRecordTypeId = getTSCommunityCaseRecordTypeId();

		Set<String> accountNames = new Set<String>();
		Set<String> contactEmails = new Set<String>();
		Set<String> ownerEmails = new Set<String>();
		Set<Id> projectIds = new Set<Id>();
		Set<String> externalIds = new Set<String>();

		for (Marvell_Case__c marvellCase : marvellCases) {
			if (String.isNotBlank(marvellCase.AccountName__c)) {
				accountNames.add(marvellCase.AccountName__c);
			}
			if (String.isNotBlank(marvellCase.ContactEmail__c)) {
				if (isMarvellEmail(marvellCase.ContactEmail__c)) {
					contactEmails.add(marvellCase.ContactEmail__c + INVALID_SUFFIX);
				} else {
					contactEmails.add(marvellCase.ContactEmail__c );
				}
			}
			if (String.isNotBlank(marvellCase.OwnerEmail__c)) {
				ownerEmails.add(marvellCase.OwnerEmail__c);
			}
			if (String.isNotBlank(marvellCase.ProjectId__c)) {
				projectIds.add(marvellCase.ProjectId__c);
			}
			externalIds.add(CASE_EXTERNAL_ID_PREFIX + marvellCase.External_Id__c);
		}

		Account[] accounts = getAccountsByAccountName(accountNames);
		Contact[] contacts= getContactsByEmail(contactEmails);
		Entitlement[] entitlements = getEntitlementByMarvellProjectId(projectIds);
		Case[] existingCases = getCasesByMarvellId(externalIds);

		accountIdsByNameMap = getAccountIdByName(accounts);
		contactIdByEmailMap = getContactIdByEmail(contacts);
		portalUserIdByContactId = getPortalUserIdByContactId(contacts);
		marvellUserEmailToNXPUserEmail = getEmailMappingFromMetadata();
		queueIdByName = getTSQueueNamesById();
		entitlementIdByMarvellId = getEntitlementIdByMarvellId(entitlements);
		existingCaseIdByMarvelId = getExistingCaseIdByMarvelId(existingCases);

		Set<String> ownerNXPEmails = new Set<String>();
		for(String marvellEmail : marvellUserEmailToNXPUserEmail.keySet()) {
			if (ownerEmails.contains(marvellEmail)) {
				ownerNXPEmails.add(marvellUserEmailToNXPUserEmail.get(marvellEmail));
			}
		}

		nxpUserIdByEmail = getUserIdsByEmails(ownerNXPEmails);

		Set<Id> nxpUserIds = new Set<Id>(nxpUserIdByEmail.values());
		queueNamesByUserId = getQueueNameByUserId(nxpUserIds);

		conversionErrors = new Log__c[]{};

		Integer counter = 1;
		for (Marvell_Case__c marvellCase : marvellCases) {
			if (existingCaseIdByMarvelId.containsKey(marvellCase.External_Id__c)) {
				skipped++;
				continue;
			}
			Case nxpCase = convertMarvellCase(marvellCase);
			if (nxpCase != null) {
//				converted++;
				nxpCases.add(nxpCase);
			} else {
				failed++;
			}
			counter++;
		}

		if (nxpCases.size() > 0) {
			Database.SaveResult[] saveResults = Database.insert(nxpCases, false);
			for (Integer i = 0; i < saveResults.size(); i++) {
				Database.SaveResult saveResult = saveResults.get(i);
				if (saveResult.isSuccess()) {
					converted++;
				} else {
					failed++;
					Case failedRecord = nxpCases.get(i);
					for (Database.Error error : saveResult.getErrors()){
						String marvellRecordId = failedRecord.RelatedToId__c.removeStart(CASE_EXTERNAL_ID_PREFIX);
						conversionErrors.add(new Log__c(Timestamp__c = System.now(),
								MarvellRecordId__c = marvellRecordId,
								Message__c = error.getMessage()));
					}
				}
			}
		}

		System.debug(LoggingLevel.Error, 'converted = ' + converted);
		System.debug(LoggingLevel.Error, 'skipped = ' + skipped);
		System.debug(LoggingLevel.Error, 'failed = ' + failed);

		if (conversionErrors.size() > 0) {
			for (Log__c log : conversionErrors) {
				log.Source__c = LOG_SOURCE_CASE;
			}
			insert conversionErrors;
		}

		return new EVE_ConversionResultDTO(converted, skipped, failed);
	}

	public static void convertMarvellContacts () {
		if (!initCheck()) {
			return;
		}
		Marvell_Contact__c[] marvellContacts = getContactsToConvert();
		System.debug(LoggingLevel.Error, marvellContacts.size() + ' Marvell Contacts found to convert');

		CONTACT_COUNTRY_VALUES = getContactCountryValues();

		Contact[] newContacts = new Contact[]{};
		skipped = 0;
		failed = 0;
		converted = 0;

		Set<Id> accountIds = new Set<Id>();
		Set<String> contactEmails = new Set<String>();

		for (Marvell_Contact__c marvellContact : marvellContacts) {
			if (String.isNotBlank(marvellContact.AccountId__c)) {
				accountIds.add(marvellContact.AccountId__c);
			}
			if (String.isNotBlank(marvellContact.Email__c)) {
				if (isMarvellEmail(marvellContact.Email__c)) {
					contactEmails.add(marvellContact.Email__c + INVALID_SUFFIX);
				} else {
					contactEmails.add(marvellContact.Email__c );
				}
			}
		}
		

		marvellAccountNameByAccountId = getAccountMapFromMarvellCase(accountIds);
		Contact[] existingContacts = getContactsByEmail(contactEmails);
		Map<String, Id> existingContactIdByEmail = getContactIdByEmail(existingContacts);
		Set<String> convertedEmails = new Set<String>();
		conversionErrors = new Log__c[]{};

		for (Marvell_Contact__c marvellContact : marvellContacts) {
			String keyEmail = isMarvellEmail(marvellContact.Email__c)
					? marvellContact.Email__c + INVALID_SUFFIX 
					: marvellContact.Email__c;
			if (existingContactIdByEmail.containsKey(keyEmail)
					|| convertedEmails.contains(keyEmail)){
				skipped++;
				continue;
			}
			Contact nxpContact = convertMarvellContact(marvellContact);
			if (nxpContact != null) {
//				converted++;
				newContacts.add(nxpContact);
				convertedEmails.add(nxpContact.Email);
			} else {
				failed++;
			}
		}

		System.debug(LoggingLevel.Error, 'converted = ' + converted);
		System.debug(LoggingLevel.Error, 'skipped = ' + skipped);
		System.debug(LoggingLevel.Error, 'failed = ' + failed);

		if (newContacts.size() > 0) {
//			insert newContacts;
			Database.SaveResult[] saveResults = Database.insert(newContacts, false);
			for (Integer i = 0; i < saveResults.size(); i++) {
				Database.SaveResult saveResult = saveResults.get(i);
				if (saveResult.isSuccess()) {
					converted++;
				} else {
					failed++;
					Contact failedRecord = newContacts.get(i);
					for (Database.Error error : saveResult.getErrors()){
						conversionErrors.add(new Log__c(Timestamp__c = System.now(),
							MarvellRecordId__c = failedRecord.Legacy_Id__c,
							Message__c = error.getMessage()));
					}
				}
			}
		}

		conversionErrors.add(new Log__c(Timestamp__c = Datetime.now(),
				Message__c = converted + ' records converted, ' + skipped + ' records skipped, ' + failed + ' records failed'));
		
		System.debug(LoggingLevel.Error, 'conversionErrors = ' + JSON.serializePretty(conversionErrors));

		if (conversionErrors.size() > 0) {
			for (Log__c log : conversionErrors) {
				log.Source__c = LOG_SOURCE_CONTACT;
			}
			insert conversionErrors;
		}

		disableMarvellCustomSetting();
	}

	public static void convertMarvellCaseTeams() {
		System.debug(LoggingLevel.ERROR, 'k33pdbg IN EVE_MarvellConvert.convertMarvellCaseTeams');
		if (!initCheck()) {
			return;
		}
		Database.executeBatch(new EVE_ConvertCaseTeamsBatch(), 200);
	}

	public static EVE_ConversionResultDTO convertMarvellCaseTeams (Set<id> marvellCaseTeamIds) {
		Marvell_Case_Team__c[] marvellCaseTeams = getMarvellCaseTeamsToConvert(marvellCaseTeamIds);
		System.debug(LoggingLevel.Error, marvellCaseTeams.size() + ' Marvell Case Teams found to convert');

		Entitlement_Contact__c[] nxpEntitlementContacts = new Entitlement_Contact__c[]{};
		skipped = 0;
		failed = 0;
		converted = 0;

		Set<String> caseExternalIds = new Set<String>();
		Set<String> memberEmails = new Set<String>();

		for (Marvell_Case_Team__c marvellCaseTeam : marvellCaseTeams) {
			if (String.isNotBlank(marvellCaseTeam.MemberEmail__c)) {
				if (isMarvellEmail(marvellCaseTeam.MemberEmail__c)) {
					memberEmails.add(marvellCaseTeam.MemberEmail__c + INVALID_SUFFIX);
				} else {
					memberEmails.add(marvellCaseTeam.MemberEmail__c );
				}
			}
			if (String.isNotBlank(marvellCaseTeam.ParentId__c)) {
				caseExternalIds.add(CASE_EXTERNAL_ID_PREFIX + marvellCaseTeam.ParentId__c);
			}
		}

		Contact[] nxpContacts = getContactsByEmail(memberEmails);
		contactIdByEmailMap = getContactIdByEmail(nxpContacts);

		Case[] nxpCases = getCasesByMarvellId(caseExternalIds);
		nxpEntitlementIdByMarvellCaseId = getNxpEntitlementIdByMarvellCaseIdMap(nxpCases);

		Set<Id> entitlementIds = new Set<Id>(nxpEntitlementIdByMarvellCaseId.values());
		Entitlement_Contact__c[] existingEntitlementContacts = getEntitlementContactsByEntitlementId(entitlementIds);

		existingEntitlementContactsMap = generateExistingEntitlementContactsMap(existingEntitlementContacts);

		Set<String> convertedEmails = new Set<String>();
		conversionErrors = new Log__c[]{};

		for (Marvell_Case_Team__c marvellCaseTeam : marvellCaseTeams) {
			if (!nxpEntitlementIdByMarvellCaseId.containsKey(marvellCaseTeam.ParentId__c)) {
				skipped++;
				continue;
			}
			Entitlement_Contact__c nxpEntitlementContact = convertMarvellCaseTeam(marvellCaseTeam);
			if (nxpEntitlementContact != null) {
				if (doesEntitlementContactAlreadyExist(nxpEntitlementContact)) {
					skipped++;
				} else {
//					converted++;
					nxpEntitlementContacts.add(nxpEntitlementContact);
					addEntitlementContactToExistingMap(nxpEntitlementContact);
				}
			} else {
				failed++;
			}
		}

		if (nxpEntitlementContacts.size() > 0) {
//			insert nxpEntitlementContacts;
			transient Database.SaveResult[] saveResults = Database.insert(nxpEntitlementContacts, false);
			for (Integer i = 0; i < saveResults.size(); i++) {
				transient Database.SaveResult saveResult = saveResults.get(i);
				if (saveResult.isSuccess()) {
					converted++;
				} else {
					failed++;
					Entitlement_Contact__c failedRecord = nxpEntitlementContacts.get(i);
					for (Database.Error error : saveResult.getErrors()){
						String message = 'EntitlementId = ' + failedRecord.Entitlement__c
								+ ' , Contact Id = ' + failedRecord.Contact__c + ' : ' + error.getMessage();
						conversionErrors.add(new Log__c(Timestamp__c = System.now(),
								Message__c = message));
					}
				}
			}
		}

		System.debug(LoggingLevel.Error, 'converted = ' + converted);
		System.debug(LoggingLevel.Error, 'skipped = ' + skipped);
		System.debug(LoggingLevel.Error, 'failed = ' + failed);

		if (conversionErrors.size() > 0) {
			for (Log__c log : conversionErrors) {
				log.Source__c = LOG_SOURCE_CASE_TEAM;
			}
			insert conversionErrors;
		}

		return new EVE_ConversionResultDTO(converted, skipped, failed);
	}

	public static void createEntitlementContactsForAllEntitlements() {
		if (!initCheck()) {
			return;
		}
		Database.executeBatch(new EVE_CreateEntContactsForAllEntsBatch(), 20);
	}

	public static EVE_ConversionResultDTO createEntitlementContactsForAllEntitlements(Set<id> entitlementIdsToConvert) {
		Entitlement[] allEntitlementsWithCases = getAllEntitlementsWithCases(entitlementIdsToConvert);
		skipped = 0;
		failed = 0;
		converted = 0;

		Map<Id, Set<Id>> contactIdsByEntitlementId = new Map<Id, Set<Id>>();
		for (Entitlement entitlement : allEntitlementsWithCases) {
			Set<Id> contactIds = new Set<Id>();
			for (Case aCase : entitlement.Cases) {
				if (aCase.ContactId != null) {
					contactIds.add(aCase.ContactId);
				}
			}
			contactIdsByEntitlementId.put(entitlement.Id,contactIds);
		}

		Set<Id> entitlementIds = contactIdsByEntitlementId.keySet();

		Entitlement_Contact__c[] existingEntitlementContacts = getEntitlementContactsByEntitlementId(entitlementIds);
		existingEntitlementContactsMap = generateExistingEntitlementContactsMap(existingEntitlementContacts);

		Entitlement_Contact__c[] newEntitlementContacts = new Entitlement_Contact__c[]{};

		for (Id entitlementId : contactIdsByEntitlementId.keySet()) {
			Set<Id> contactIds = contactIdsByEntitlementId.get(entitlementId);
			for (Id contactId : contactIds) {
				Boolean entContactAlreadyExists = existingEntitlementContactsMap.containsKey(entitlementId) &&
						existingEntitlementContactsMap.get(entitlementId).contains(contactId);
				if (!entContactAlreadyExists) {
					Entitlement_Contact__c entitlementContact = createEntitlementContact(entitlementId, contactId);
					newEntitlementContacts.add(entitlementContact);
//					converted++;
				} else {
					skipped++;
				}
			}
		}

		conversionErrors = new Log__c[]{};

		if (newEntitlementContacts.size() > 0) {
			Database.SaveResult[] saveResults = Database.insert(newEntitlementContacts, false);
			for (Integer i = 0; i < saveResults.size(); i++) {
				Database.SaveResult saveResult = saveResults.get(i);
				if (saveResult.isSuccess()) {
					converted++;
				} else {
					failed++;
					Entitlement_Contact__c failedRecord = newEntitlementContacts.get(i);
					for (Database.Error error : saveResult.getErrors()){
						String message = 'EntitlementId = ' + failedRecord.Entitlement__c
								+ ' , Contact Id = ' + failedRecord.Contact__c + ' : ' + error.getMessage();
						conversionErrors.add(new Log__c(Timestamp__c = System.now(),
								Message__c = message));
					}
				}
			}
		}

//		conversionErrors.add(new Log__c(Timestamp__c = Datetime.now(),
//				Message__c = converted + ' records converted, ' + skipped + ' records skipped, ' + failed + ' records failed'));

		if (conversionErrors.size() > 0) {
			for (Log__c log : conversionErrors) {
				log.Source__c = LOG_SOURCE_ENTITLEMENT_CONTACT;
			}
			insert conversionErrors;
		}

		return new EVE_ConversionResultDTO(converted, skipped, failed);
	}

	public static void convertMarvellInternalCaseComments() {
		if (!initCheck()) {
			return;
		}
		Database.executeBatch(new EVE_ConvertInternalCaseCommentsBatch(), 100);
	}

	public static EVE_ConversionResultDTO convertMarvellInternalCaseComments (Set<Id> internalCaseCommentsIds) {
		Marvell_CaseComment__c[] internalCaseComments = getMarvellCaseCommentsToConvert(internalCaseCommentsIds);
		System.debug(LoggingLevel.Error, internalCaseComments.size() + ' Marvell Internal Case Comments found to convert');

		Set<String> caseExternalIds = new Set<String>();
		Set<Id> createdByIds = new Set<Id>();
		Set<Id> marvellIds = new Set<Id>();

		for (Marvell_CaseComment__c caseComment : internalCaseComments) {
			if (String.isNotBlank(caseComment.CreatedById__c)) {
				createdByIds.add(caseComment.CreatedById__c);
			}
			if (String.isNotBlank(caseComment.MarvellCaseId__c)) {
				caseExternalIds.add(CASE_EXTERNAL_ID_PREFIX + caseComment.MarvellCaseId__c);
			}
			marvellIds.add(caseComment.Marvell_Id__c);
		}

		FeedItem[] existingFeedItems = getFeedItemsByMarvellId(marvellIds);
		Map<Id, Id> existingFeedItemIdByMarvellId = getExistingFeedItemIdByMarvelProjectId(existingFeedItems);

		marvellUserEmailToNXPUserEmail = getEmailMappingFromMetadata();
		marvellUserEmailById = getMarvellUserEmailById(createdByIds);
		Set<String> userEmails = new Set<String>(marvellUserEmailById.values());
		Set<String> nxpUserEmailsFromMapping = new Set<String>(marvellUserEmailToNXPUserEmail.values());
		userEmails.addAll(nxpUserEmailsFromMapping);

		nxpUserIdByEmail = getUserIdsByEmails(userEmails);

		Case[] existingCases = getCasesByMarvellId(caseExternalIds);
		existingCaseIdByMarvelId = getExistingCaseIdByMarvelId(existingCases);

		FeedItem[] newFeedItems = new FeedItem[]{};
		conversionErrors = new Log__c[]{};
		skipped = 0;
		failed = 0;
		converted = 0;

		for (Marvell_CaseComment__c caseComment : internalCaseComments) {
			if (!existingCaseIdByMarvelId.containsKey(caseComment.MarvellCaseId__c)
				|| existingFeedItemIdByMarvellId.containsKey(caseComment.Marvell_Id__c)) {
				skipped++;
				continue;
			}
			FeedItem newFeedItem = convertInternalCaseComment(caseComment);
			if (newFeedItem != null) {
//				converted++;
				newFeedItems.add(newFeedItem);
			} else {
				failed++;
			}
		}

		if (newFeedItems.size() > 0) {
			transient Database.SaveResult[] saveResults = Database.insert(newFeedItems, false);
			for (Integer i = 0; i < saveResults.size(); i++) {
				transient Database.SaveResult saveResult = saveResults.get(i);
				if (saveResult.isSuccess()) {
					converted++;
				} else {
					failed++;
					FeedItem failedRecord = newFeedItems.get(i);
					for (Database.Error error : saveResult.getErrors()){
						conversionErrors.add(new Log__c(Timestamp__c = System.now(),
								MarvellRecordId__c = failedRecord.Title,
								Message__c = error.getMessage()));
					}
				}
			}
		}

		System.debug(LoggingLevel.Error, 'converted = ' + converted);
		System.debug(LoggingLevel.Error, 'skipped = ' + skipped);
		System.debug(LoggingLevel.Error, 'failed = ' + failed);

		if (conversionErrors.size() > 0) {
			for (Log__c log : conversionErrors) {
				log.Source__c = LOG_SOURCE_INTERNAL_CASE_COMMENTS;
			}
			insert conversionErrors;
		}

		return new EVE_ConversionResultDTO(converted, skipped, failed);
	}

	public static void convertMarvellCustomerCaseComments() {
		convertMarvellCustomerCaseComments(false);
	}

	public static void convertMarvellCustomerCaseComments(Boolean verboseFlag) {
		if (!initCheck()) {
			return;
		}
		Database.executeBatch(new EVE_ConvertCustomerCaseCommentsBatch(verboseFlag), 100);
	}

	public static EVE_ConversionResultDTO convertMarvellCustomerCaseComments (Set<Id> customerCaseCommentsIds) {
		return convertMarvellCustomerCaseComments(customerCaseCommentsIds, false);
	}

	public static EVE_ConversionResultDTO convertMarvellCustomerCaseComments (Set<Id> customerCaseCommentsIds, Boolean verbose) {
		Datetime startBatchDatetime = System.now();
		Marvell_CaseComment__c[] customerCaseComments = getMarvellCaseCommentsToConvert(customerCaseCommentsIds);
		System.debug(LoggingLevel.Error, customerCaseComments.size() + ' Marvell Customer Case Comments found to convert');

		Set<String> caseExternalIds = new Set<String>();
		Set<Id> createdByIds = new Set<Id>();
		Set<Id> marvellIds = new Set<Id>();

		for (Marvell_CaseComment__c caseComment : customerCaseComments) {
			if (String.isNotBlank(caseComment.CreatedById__c)) {
				createdByIds.add(caseComment.CreatedById__c);
			}
			if (String.isNotBlank(caseComment.MarvellCaseId__c)) {
				caseExternalIds.add(CASE_EXTERNAL_ID_PREFIX + caseComment.MarvellCaseId__c);
			}
			marvellIds.add(caseComment.Marvell_Id__c);
		}

		EmailMessage[] existingEmailMessages = getEmailMessagesByMarvellId(marvellIds);
		Map<Id, Id> existingEmailMessageIdByMarvellId = getExistingEmailMessageIdByMarvelCaseCommentId(existingEmailMessages);

		marvellUserEmailToNXPUserEmail = getEmailMappingFromMetadata();
		marvellUserEmailById = getMarvellUserEmailById(createdByIds);
		Set<String> userEmails = new Set<String>(marvellUserEmailById.values());
		Set<String> nxpUserEmailsFromMapping = new Set<String>(marvellUserEmailToNXPUserEmail.values());
		userEmails.addAll(nxpUserEmailsFromMapping);

		nxpUserIdByEmail = getUserIdsByEmails(userEmails);

		Case[] existingCases = getCasesByMarvellId(caseExternalIds);
		existingCaseIdByMarvelId = getExistingCaseIdByMarvelId(existingCases);

		EmailMessage[] newEmailMessages = new EmailMessage[]{};
		conversionErrors = new Log__c[]{};
		skipped = 0;
		failed = 0;
		converted = 0;

		Set<Id> convertedCaseCommentIds = new Set<Id>();

		for (Marvell_CaseComment__c caseComment : customerCaseComments) {
			if (!existingCaseIdByMarvelId.containsKey(caseComment.MarvellCaseId__c)
					|| existingEmailMessageIdByMarvellId.containsKey(caseComment.Marvell_Id__c)
					|| convertedCaseCommentIds.contains(caseComment.Marvell_Id__c)) {
				skipped++;
				String message;
				if (!existingCaseIdByMarvelId.containsKey(caseComment.MarvellCaseId__c)) {
					message = 'nxp Case for marvell Case wit Id:' + caseComment.MarvellCaseId__c + ' is not found';
				} else if (existingEmailMessageIdByMarvellId.containsKey(caseComment.Marvell_Id__c)) {
					message = 'marvell Case comment with Id:' + caseComment.Marvell_Id__c + 'already exists';
				} else if (convertedCaseCommentIds.contains(caseComment.Marvell_Id__c)) {
					message = 'marvell Case comment with Id:' + caseComment.Marvell_Id__c + 'already converted in this batch';
				}
				if (verbose) {
					System.debug(LoggingLevel.Error, message);
				}
				conversionErrors.add(new Log__c(Timestamp__c = Datetime.now(),
						MarvellRecordId__c = caseComment.Marvell_Id__c,
						Message__c = message));
				continue;
			}
			EmailMessage newEmailMessage = convertCustomerCaseCommentToEmailMessage(caseComment);
			if (newEmailMessage != null) {
//				converted++;
				convertedCaseCommentIds.add(newEmailMessage.ParentId);
				newEmailMessages.add(newEmailMessage);
			} else {
				failed++;
			}
		}

		if (newEmailMessages.size() > 0) {
			transient Database.SaveResult[] saveResults = Database.insert(newEmailMessages, false);
			for (Integer i = 0; i < saveResults.size(); i++) {
				transient Database.SaveResult saveResult = saveResults.get(i);
				if (saveResult.isSuccess()) {
					converted++;
				} else {
					failed++;
					EmailMessage failedRecord = newEmailMessages.get(i);
					for (Database.Error error : saveResult.getErrors()){
						conversionErrors.add(new Log__c(Timestamp__c = System.now(),
								MarvellRecordId__c = failedRecord.Marvell_Id__c,
								Message__c = error.getMessage()));
					}
				}
			}
		}

		System.debug(LoggingLevel.Error, 'converted = ' + converted);
		System.debug(LoggingLevel.Error, 'skipped = ' + skipped);
		System.debug(LoggingLevel.Error, 'failed = ' + failed);

		if (conversionErrors.size() > 0) {
			for (Log__c log : conversionErrors) {
				log.Source__c = LOG_SOURCE_CUSTOMER_CASE_COMMENTS;
			}
			insert conversionErrors;
		}

		return new EVE_ConversionResultDTO(converted, skipped, failed);
	}

	//Convert Methods
	private static Case convertMarvellCase(Marvell_Case__c marvellCase) {
		Case nxpCase = new Case();
		nxpCase.AccountId = convertMarvellAccountNameForCase(marvellCase.AccountName__c, nxpCommunityId, marvellCase.External_Id__c);
		nxpCase.EntitlementId = convertMarvellProjectId(marvellCase.ProjectId__c);
		nxpCase.Origin = CASE_ORIGIN_SELF_SERVICE_PORTAL;
		nxpCase.Web_Region__c = marvellCase.Region__c;
		nxpCase.LastModifiedById = currentUserId;
		nxpCase.LastModifiedDate = System.now();
		nxpCase.Internal_Priority__c = convertMarvellPriorityToNXPInternalPriority(marvellCase.Priority__c);
		nxpCase.Priority = convertMarvellPriorityToNXPPriority(marvellCase.Priority__c);
		nxpCase.Subject = convertMarvellSubject(marvellCase.Subject__c, marvellCase.CaseNumber__c);
		nxpCase.Device_No__c = null;
		nxpCase.Assigned_to__c = getAssignedToIdFromMarvellOnwerEmail(marvellCase.OwnerEmail__c);
		nxpCase.RelatedToId__c = CASE_EXTERNAL_ID_PREFIX + marvellCase.External_Id__c;
		nxpCase.Reference__c = String.valueOf(marvellCase.CaseNumber__c);
		nxpCase.Description = convertCaseDescription(marvellCase.Description__c);
		nxpCase.Company__c = marvellCase.AccountName__c;
		nxpCase.Web_Region__c = convertMarvellRegion(marvellCase.Region__c);
		nxpCase.My_Question_is_Related__c = getNXPTopic(marvellCase.IssueType__c, marvellCase.IssueSubType__c);
		nxpCase.Sub_Topic__c = getNXPSupTopic(marvellCase.IssueType__c, marvellCase.IssueSubType__c);
		nxpCase.Product_Type_Number__c = marvellCase.ServicesPartNumberName__c;
		nxpCase.ContactId = convertMarvellContactEmailToNXPContactId(marvellCase.ContactEmail__c);
		nxpCase.Status = convertMarvellStatus(marvellCase.Status__c);
		nxpCase.CreatedDate = marvellCase.CreatedDate__c;
		nxpCase.ClosedDate = marvellCase.ClosedDate__c;
		nxpCase.CreatedById = getCreatedById(nxpCase.ContactId);
		nxpCase.OwnerId = getCaseOwnerIdFromMarvellOnwerEmail(marvellCase.OwnerEmail__c, marvellCase.External_Id__c,
				nxpCase.My_Question_is_Related__c, nxpCase.Web_Region__c);
        nxpCase.SW_Jira_Ticket__c = marvellCase.Jira__c;
        nxpCase.Product__c = CASE_PRODUCT_LVL1_WIRELESS_CONNECTIVITY;
        nxpCase.Product_Category__c = CASE_PRODUCT_LVL2_WIFI_AND_BLUETOOTH;

		if (validateCase(nxpCase)) {
			return nxpCase;
		} else {
			conversionErrors.add(new Log__c(Timestamp__c = Datetime.now(),
					MarvellRecordId__c = marvellCase.External_Id__c,
					Message__c = 'Record was not converted'));
			return null;
		}

	}

	private static Contact convertMarvellContact(Marvell_Contact__c marvellContact) {
		Contact nxpContact = new Contact();
		nxpContact.AccountId = nxpCommunityId;
		nxpContact.Company__c = convertMarvellAccountId(marvellContact.AccountId__c);
		nxpContact.User_Region__c = convertMarvellContactRegion(marvellContact.Region__c);
		nxpContact.AssistantName = marvellContact.AssistantName__c;
		nxpContact.AssistantPhone = marvellContact.AssistantPhone__c;
		nxpContact.Birthdate = marvellContact.Birthdate__c;
		nxpContact.Email = convertMarvellContactEmail(marvellContact.Email__c);
		nxpContact.Fax = marvellContact.Fax__c;
		nxpContact.Phone = marvellContact.Phone__c;
		nxpContact.HomePhone = marvellContact.HomePhone__c;
		nxpContact.MobilePhone = marvellContact.MobilePhone__c;

		nxpContact.MailingStreet = marvellContact.MailingStreet__c;
		nxpContact.MailingCity = marvellContact.MailingCity__c;
		nxpContact.MailingState = marvellContact.MailingState__c;
		nxpContact.MailingPostalCode = marvellContact.MailingPostalCode__c;
		nxpContact.MailingCountry = marvellContact.MailingCountry__c;

		nxpContact.Community_web_country__c = CONTACT_COUNTRY_VALUES.contains(nxpContact.MailingCountry)
				? nxpContact.MailingCountry
				: nxpContact.MailingCountry == 'United States' ? 'USA' : null;

		nxpContact.OtherStreet = marvellContact.OtherStreet__c;
		nxpContact.OtherCity = marvellContact.OtherCity__c;
		nxpContact.OtherState = marvellContact.OtherState__c;
		nxpContact.OtherPostalCode = marvellContact.OtherPostalCode__c;
		nxpContact.OtherCountry = marvellContact.OtherStateCode__c;

		nxpContact.Salutation = marvellContact.Salutation__c;
		nxpContact.FirstName = marvellContact.FirstName__c;
		nxpContact.LastName = marvellContact.LastName__c;
		nxpContact.Title = marvellContact.Title__c;
		nxpContact.Custom_Description__c = marvellContact.Description__c;
		nxpContact.Job_Description__c = marvellContact.ContactRole__c;

		nxpContact.OwnerId = currentUserId;
		nxpContact.CreatedById = currentUserId;
		nxpContact.LastModifiedById = currentUserId;
		nxpContact.CreatedDate = System.now();
		nxpContact.LastModifiedDate = System.now();
		nxpContact.Legacy_Id__c = marvellContact.Marvell_Id__c;
		return nxpContact;
	}

	private static EmailMessage convertCustomerCaseCommentToEmailMessage(Marvell_CaseComment__c caseComment) {
		EmailMessage emailMessage = new EmailMessage();
		emailMessage.CreatedDate = caseComment.CreatedDate__c;
		emailMessage.LastModifiedDate = caseComment.CreatedDate__c;
		emailMessage.MessageDate = caseComment.CreatedDate__c;
		emailMessage.FromName = caseComment.CreatedByName__c;
		emailMessage.FromAddress = convertCaseCommentCreatedIdToAddress(caseComment.CreatedById__c);

		emailMessage.HtmlBody = trimString(caseComment.Comments__c, EMAIL_MESSAGE_HTML_BODY_MAX_LENGTH);
		emailMessage.ParentId = existingCaseIdByMarvelId.get(caseComment.MarvellCaseId__c);
		emailMessage.Subject = generateEmailMessageSubject(caseComment.Name, caseComment.CreatedByName__c, caseComment.CreatedDate__c);
		emailMessage.TextBody = trimString(caseComment.Comments__c.stripHtmlTags(), EMAIL_MESSAGE_HTML_BODY_MAX_LENGTH);
		emailMessage.Incoming = true;

		emailMessage.CreatedById = convertCreatedByFromCaseComment(caseComment.CreatedById__c);
		emailMessage.LastModifiedById = convertCreatedByFromCaseComment(caseComment.CreatedById__c);
		emailMessage.Marvell_Id__c = caseComment.Marvell_Id__c;

		return emailMessage;
	}

	private static Entitlement convertMarvellProject(Marvell_Project__c marvellProject) {
		Entitlement nxpEntitlement = new Entitlement();
		nxpEntitlement.AccountId = nxpCommunityId;
		nxpEntitlement.Name = marvellProject.Name;
		nxpEntitlement.Type = ENTITLEMENT_TYPE_FREE;
		nxpEntitlement.Entitlement_Sub_Type__c = ENTITLEMENT_SUBTYPE_DEVELOPMENT_PROJECT;
		nxpEntitlement.Priority__c = ENTITLEMENT_PRIORITY_MEDIUM;
		nxpEntitlement.Project_Annual_Volume__c = null;
		nxpEntitlement.Project_Stage__c = null;
		nxpEntitlement.StartDate = getStartDateByProjectId(marvellProject.ProjectId__c, marvellProject.CreatedDate__c);
		nxpEntitlement.CreatedById = getCreatedByByProjectId(marvellProject.ProjectId__c);
		nxpEntitlement.EndDate = null;
		nxpEntitlement.CreatedDate = marvellProject.CreatedDate__c;
		nxpEntitlement.LastModifiedDate = System.now();
		nxpEntitlement.LastModifiedById = currentUserId;
		nxpEntitlement.Marvell_Id__c = marvellProject.ProjectId__c;
		nxpEntitlement.Route_To_Case_Owner__c = QUEUE_NAME_TS_L3_WIRELESS_DISPATCH;
		return nxpEntitlement;
	}

	public static Entitlement_Contact__c createEntitlementContact(Id entitlementId, Id contactId) {
		Entitlement_Contact__c entitlementContact = new Entitlement_Contact__c();
		entitlementContact.Entitlement__c = entitlementId;
		entitlementContact.Contact__c = contactId;
		entitlementContact.CreatedById = currentUserId;
		entitlementContact.LastModifiedById = currentUserId;
		entitlementContact.Status__c = 'Accepted';
		entitlementContact.Type__c = 'Owner';
		return entitlementContact;
	}

	private static Entitlement_Contact__c convertMarvellCaseTeam(Marvell_Case_Team__c marvellCaseTeam) {
		Entitlement_Contact__c nxpEntitlementContact = new Entitlement_Contact__c();
		nxpEntitlementContact.Contact__c = searchContactByMemberEmail(marvellCaseTeam.MemberEmail__c, marvellCaseTeam.Marvell_Id__c);
		nxpEntitlementContact.Entitlement__c  = searchEntitlementByMarvellCaseId(marvellCaseTeam.ParentId__c, marvellCaseTeam.Marvell_Id__c);
		nxpEntitlementContact.CreatedById = currentUserId;
		nxpEntitlementContact.LastModifiedById = currentUserId;
		nxpEntitlementContact.Status__c = 'Accepted';
		nxpEntitlementContact.Type__c = 'Owner';

		if (validateEntitlementContact(nxpEntitlementContact)) {
			return nxpEntitlementContact;
		} else {
			conversionErrors.add(new Log__c(Timestamp__c = Datetime.now(),
					MarvellRecordId__c = marvellCaseTeam.Marvell_Id__c,
					Message__c = 'Record was not converted'));
			return null;
		}
	}

	private static FeedItem convertInternalCaseComment(Marvell_CaseComment__c caseComment) {
		FeedItem nxpFeedItem = new FeedItem();
		nxpFeedItem.ParentId = existingCaseIdByMarvelId.get(caseComment.MarvellCaseId__c);
		nxpFeedItem.CreatedDate = caseComment.CreatedDate__c;

		nxpFeedItem.Visibility = FEEDITEM_VISIBILITY_INTERNAL_USERS;
		nxpFeedItem.Type = 'TextPost';
		nxpFeedItem.Status = 'Published';
		nxpFeedItem.Title = caseComment.Marvell_Id__c;

		nxpFeedItem.CreatedById = convertCreatedByFromCaseComment(caseComment.CreatedById__c);
		nxpFeedItem.Body = convertAttachmentComments(caseComment.Comments__c, caseComment.CreatedByName__c, caseComment.CreatedById__c);

		return nxpFeedItem;
	}

	//REPO

	private static Marvell_Case__c[] getCasesToConvert(Set<Id> ids) {
		Marvell_Case__c[] marvellCases = [
			SELECT ID, AccountName__c,
				CaseNumber__c, ClosedDate__c, ContactEmail__c, CreatedDate__c,
				Description__c,
				External_Id__c,
				IssueType__c, IssueSubType__c,
				OwnerEmail__c,
				Priority__c, ProjectId__c,
				Region__c, Jira__c,
				ServicesPartNumberName__c, Status__c, Subject__c
			FROM Marvell_Case__c
			WHERE Id IN :ids
			AND ExcludeStats__c != true
		];
		return marvellCases;
	}

	private static Marvell_Case_Team__c[] getMarvellCaseTeamsToConvert(Set<Id> ids) {
		Marvell_Case_Team__c[] marvellCaseTeams = [
				SELECT Marvell_Id__c, MemberEmail__c, ParentId__c, TeamRoleName__c
				FROM Marvell_Case_Team__c
				WHERE Id IN :ids
		];
		return marvellCaseTeams;
	}

	private static Marvell_CaseComment__c[] getMarvellCaseCommentsToConvert(Set<Id> ids) {
		Marvell_CaseComment__c[] caseComments = [
			SELECT Id, Name,
				Comments__c, CreatedById__c, CreatedByName__c, CreatedDate__c,
				EmailToComments__c,
				InternalCustomer__c, IsInternal__c, IsMakePublic__c,
				LastModifiedDate__c,
				MarvellCaseId__c, Marvell_Id__c
			FROM Marvell_CaseComment__c
			WHERE Id IN :ids
		];
		return caseComments;
	}

	private static Marvell_Contact__c[] getContactsToConvert() {
		Marvell_Contact__c[] marvellContacts = [
			SELECT
				AccountId__c, AccountName__c, AssistantName__c, AssistantPhone__c,
				Birthdate__c,
				ContactRole__c,
				Description__c,
				Email__c,
				Fax__c, FirstName__c,
				HomePhone__c,
				LastName__c,
				MailingCity__c,MailingCountry__c, MailingCountryCode__c, MailingPostalCode__c, MailingState__c,
				MailingStateCode__c,MailingStreet__c, Marvell_Id__c, MobilePhone__c,
				Name,
				OtherCity__c, OtherCountry__c, OtherCountryCode__c, OtherPhone__c, OtherPostalCode__c, OtherState__c,
				OtherStateCode__c,OtherStreet__c,
				Phone__c,
				Region__c,
				Salutation__c,
				Title__c
			FROM Marvell_Contact__c
		];
		return marvellContacts;
	}

	private static Marvell_Project__c[] getProjectsToConvert() {
		Marvell_Case__c[] activeCases = [
			SELECT Id, ProjectId__c
			FROM Marvell_Case__c
			WHERE (Status__c != 'Closed' OR ClosedDate__c = LAST_N_DAYS:180)
			AND ExcludeStats__c != true
		];

		Set<Id> projectIds = new Set<Id>();
		for (Marvell_Case__c marvellCase : activeCases) {
			projectIds.add(marvellCase.ProjectId__c);
		}

		Marvell_Project__c[] marvellProjects = [
			SELECT ID, Name, AccountName__c,
					CreatedById__c, CreatedDate__c,
					ProjectId__c
			FROM Marvell_Project__c
			WHERE ProjectId__c IN :projectIds
		];
		return marvellProjects;
	}

	private static Account[] getAccountsByAccountName(Set<String> names) {
		Account[] accounts = new Account[]{};
		if (!names.isEmpty()) {
			accounts = [
				SELECT Id, Name
				FROM Account
				WHERE Name IN :names
			];
		}
		return accounts;
	}

	private static Case[] getCasesByMarvellId(Set<String> externalIds) {
		Case[] cases = [
			SELECT Id, RelatedToId__c, EntitlementId
			FROM Case
			WHERE RelatedToId__c IN :externalIds
		];
		return cases;
	}

	private static Contact[] getContactsByEmail(Set<String> emails) {
		Contact[] contacts = new Contact[]{};
		if (!emails.isEmpty()) {
			contacts = [
				SELECT Id, Email
				FROM Contact
				WHERE Email IN :emails
			];
		}
		return contacts;
	}

	private static Entitlement[] getAllEntitlementsWithCases(Set<Id> ids) {
		Entitlement[] entitlements = [
			SELECT Id, (
				SELECT Id, ContactId, Contact.Email
				FROM Cases
				WHERE NOT Contact.Email LIKE '%marvell.com%'
			)
			FROM Entitlement
			WHERE Id IN :ids
		];
		return entitlements;
	}

	private static Entitlement[] getEntitlementByMarvellProjectId(Set<Id> marvellProjectIds) {
		Entitlement[] entitlements = [
			SELECT Id, Marvell_Id__c
			FROM Entitlement
			WHERE Marvell_Id__c IN :marvellProjectIds
		];
		return entitlements;
	}

	private static Entitlement_Contact__c[] getEntitlementContactsByEntitlementId(Set<Id> ids) {
		return [
			SELECT Id, Entitlement__c, Contact__c
			FROM Entitlement_Contact__c
			WHERE Entitlement__c IN :ids
		];
	}

	private static EmailMessage[] getEmailMessagesByMarvellId(Set<Id> marvellIds) {
		return [
			SELECT Id, Marvell_Id__c
			FROM EmailMessage
			WHERE Marvell_Id__c IN :marvellIds
		];
	}

	private static FeedItem[] getFeedItemsByMarvellId(Set<Id> marvellIds) {
		return [
			SELECT Id, Title
			FROM FeedItem
			WHERE Title IN :marvellIds
			AND Visibility = :FEEDITEM_VISIBILITY_INTERNAL_USERS
			AND Type = 'TextPost'
			AND ParentId != null AND Parent.Type = 'Case'
			AND SystemModstamp = LAST_N_DAYS:3
		];
	}

	//Account Service
	private static Map<String, Id> getAccountIdByName(Account[] accounts) {
		Map<String, Id> idByName = new Map<String, Id>();
		for (Account acc : accounts) {
			if (!idByName.containsKey(acc.Name)) {
				idByName.put(acc.Name, acc.Id);
			}
		}
		return idByName;
	}

	private static Id getNXPCommunityAccountId() {
		Account[] accounts = [SELECT ID FROM Account WHERE Name = :ACCOUNT_NAME_NXP_COMMUNITY LIMIT 1];
		Account account;
		if (accounts.size() == 0) {
			account = new Account(Name = ACCOUNT_NAME_NXP_COMMUNITY);
			insert account;
		} else {
			account = accounts[0];
		}
		return account.Id;
	}

	//Marvell Project Service
	private static Map<Id, Datetime> getMinCaseCreatedDateByProjectId(Set<Id> projectIds) {
		Map<Id, Datetime> minCreatedDateByProjectId = new Map<Id, Datetime>();
		AggregateResult[] ars = [
			SELECT ProjectId__c, MIN(CreatedDate__c) minCreatedDate
			FROM Marvell_Case__c
			WHERE ProjectId__c IN :projectIds
			GROUP BY ProjectId__c
		];
		for (AggregateResult ar : ars) {
			minCreatedDateByProjectId.put((Id)ar.get('ProjectId__c'), (Datetime)ar.get('minCreatedDate'));
		}
		return minCreatedDateByProjectId;
	}

	private static Map<Id, Datetime> getMaxCaseClosedDateByProjectId(Set<Id> projectIds) {
		Map<Id, Datetime> maxCaseClosedDateByProjectId = new Map<Id, Datetime>();
		Marvell_Case__c[] marvellCases = [
			SELECT ProjectId__c, ClosedDate__c
			FROM Marvell_Case__c
			WHERE ProjectId__c IN :projectIds
		];

		Map<Id,Marvell_Case__c[]> casesByProjectId = new Map<Id, Marvell_Case__c[]>();
		for (Marvell_Case__c aCase : marvellCases) {
			ID key = aCase.ProjectId__c;
			if (!casesByProjectId.containsKey(key)) {
				casesByProjectId.put(key,new Marvell_Case__c[]{});
			}
			casesByProjectId.get(key).add(aCase);
		}

		for (Id projectId : casesByProjectId.keySet()) {
			Id key = projectId;
			Marvell_Case__c[] cases = casesByProjectId.get(key);
			Datetime maxCloseDate = cases[0].ClosedDate__c;
			for (Marvell_Case__c marvellCase : cases) {
				if (marvellCase.ClosedDate__c == null) {
					maxCloseDate = null;
					break;
				} else {
					if (marvellCase.ClosedDate__c > maxCloseDate) {
						maxCloseDate = marvellCase.ClosedDate__c;
					}
				}
			}
			maxCaseClosedDateByProjectId.put(key, maxCloseDate);
		}
		return maxCaseClosedDateByProjectId;
	}

	public static Map<Id, String[]> getMarvellCasesOwnerEmailsByProjectId(Set<Id> projectIds) {
		Marvell_Case__c[] marvellCases = [
			SELECT ProjectId__c, OwnerEmail__c
			FROM Marvell_Case__c
			WHERE ProjectId__c IN :projectIds
			ORDER By CreatedDate__c ASC
		];
		return getUniqueOwnerEmailsByProjectId(marvellCases);
	}

	public static Map<Id, String[]> getUniqueOwnerEmailsByProjectId(Marvell_Case__c[] marvellCases) {
		Map<Id, String[]> resultMap = new Map<Id, String[]>();
		for (Marvell_Case__c marvellCase : marvellCases) {
			Id key = marvellCase.ProjectId__c;
			String value = marvellCase.OwnerEmail__c;
			String[] values;
			if (!resultMap.containsKey(key)) {
				resultMap.put(key, new String[]{value});
			} else {
				values = resultMap.get(key);
				Set<String> valuesSet = new Set<String>(values);
				if (!valuesSet.contains(value)) {
					values.add(value);
					resultMap.put(key, values);
				}
			}
		}
		return resultMap;
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

	private static Boolean validateCase(Case theCase) {
		Boolean result = true;
		if (theCase.OwnerId == null) {
			System.debug(LoggingLevel.Error, 'Case OwnerId is null');
			result = false;
		}
		if (theCase.EntitlementId == null) {
			System.debug(LoggingLevel.Error, 'Case EntitlementId is null');
			result = false;
		}

		return result;
	}

	private static Id getTSCommunityCaseRecordTypeId() {
		Map<String,RecordTypeInfo> recordTypeInfoMap = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName();
		if (!recordTypeInfoMap.containsKey(CASE_RECORDTYPE_DEVELOPER_NAME_TS_COMMUNITY)) {
			throw new NoSuchElementException('TS Community Record Type does not exist');
		}
		return recordTypeInfoMap.get(CASE_RECORDTYPE_DEVELOPER_NAME_TS_COMMUNITY).getRecordTypeId();
	}

	//Contact Service
	private static Set<String> getContactCountryValues() {
		Set<String> countryValues = new Set<String>() ;
		List<Schema.PicklistEntry> ples = Contact.Community_web_country__c.getDescribe().getPicklistValues();
		for (Schema.PicklistEntry ple : ples) {
			countryValues.add(ple.value);
		}
		return countryValues;
	}

	private static Map<String, String> getAccountMapFromMarvellCase(Set<Id> ids) {
		Marvell_Case__c[] marvellCases = [
				SELECT AccountId__c, AccountName__c
				FROM Marvell_Case__c
				WHERE AccountId__c IN :ids
		];
		Map<String, String> accountNameById = new Map<String, String>();
		for (Marvell_Case__c marvellCase : marvellCases) {
			accountNameById.put(marvellCase.AccountId__c, marvellCase.AccountName__c);
		}
		return accountNameById;
	}

	private static Map<String, Id> getContactIdByEmail(Contact[] contacts) {
		Map<String, Id> idByEmail = new Map<String, Id>();
		for (Contact contact : contacts) {
			if (!idByEmail.containsKey(contact.Email)) {
				idByEmail.put(contact.Email, contact.Id);
			}
		}
		return idByEmail;
	}

	private static Id searchContactByMemberEmail(String email, String recordId) {
		String keyEmail = isMarvellEmail(email) ? email + INVALID_SUFFIX : email;
		if (contactIdByEmailMap.containsKey(keyEmail)) {
			return contactIdByEmailMap.get(keyEmail);
		} else {
			conversionErrors.add(new Log__c(Timestamp__c = Datetime.now(),
					MarvellRecordId__c = recordId,
					Message__c = 'Contact with email ' + email + ' was not found : ' + recordId));
			return null;
		}
	}

	//EmailMessage Service
	private static Map<Id, Id> getExistingEmailMessageIdByMarvelCaseCommentId(EmailMessage[] existingEmailMessages) {
		Map<Id, Id> resultMap = new Map<Id, Id>();
		for (EmailMessage emailMessage : existingEmailMessages) {
			if (!resultMap.containsKey(emailMessage.Marvell_Id__c)) {
				resultMap.put(emailMessage.Marvell_ID__c, emailMessage.Id);
			}
		}
		return resultMap;
	}

	private static String generateEmailMessageSubject(String caseCommentName, String createdByName, Datetime createdDate) {
		String result = '';
		if (!String.isBlank(caseCommentName)) {
			result += '[was Marvell - ' + caseCommentName + ']';
		}
		if (!String.isBlank(createdByName)) {
			result += ' From: ' + createdByName;
		}
		if (createdDate != null) {
			result += ', Date: ' + createdDate;
		}
		return result;
	}

	//Entitlement Service
	private static Map<Id, Id> getEntitlementIdByMarvellId(Entitlement[] entitlements) {
		Map<Id, Id> entitlementIdByMarvellId = new Map<Id, Id>();
		for (Entitlement entitlement : entitlements) {
			if (!entitlementIdByMarvellId.containsKey(entitlement.Marvell_Id__c)) {
				entitlementIdByMarvellId.put(entitlement.Marvell_Id__c, entitlement.Id);
			}
		}
		return entitlementIdByMarvellId;
	}

	private static Map<Id, ID> getNxpEntitlementIdByMarvellCaseIdMap(Case[] nxpCases) {
		Map<Id, Id> resultMap = new Map<Id, Id>();
		for (Case nxpCase : nxpCases) {
			String key = nxpCase.RelatedToId__c.removeStart(CASE_EXTERNAL_ID_PREFIX);
			if (!resultMap.containsKey(key)) {
				resultMap.put(key, nxpCase.EntitlementId);
			}
		}
		return resultMap;
	}

	private static Id searchEntitlementByMarvellCaseId(Id caseId, String recordId) {
		if (nxpEntitlementIdByMarvellCaseId.containsKey(caseId)) {
			return nxpEntitlementIdByMarvellCaseId.get(caseId);
		} else {
			conversionErrors.add(new Log__c(Timestamp__c = Datetime.now(),
					MarvellRecordId__c = recordId,
					Message__c = 'Entitlement for the case with id  ' + caseId + ' was not found : ' + recordId));
			return null;
		}
	}

	//Entitlement Contact Service
	private static Map<Id,Set<Id>> generateExistingEntitlementContactsMap(Entitlement_Contact__c[] entitlementContacts) {
		Map<Id, Set<Id>> resultMap = new Map<Id, Set<Id>>();
		for (Entitlement_Contact__c entitlementContact : entitlementContacts) {
			Id key = entitlementContact.Entitlement__c;
			Set<Id> values;
			if (!resultMap.containsKey(key)) {
				values = new Set<Id>();
				resultMap.put(key, values);
			} else {
				values = resultMap.get(key);
			}
			values.add(entitlementContact.Contact__c);
		}
		return resultMap;
	}

	private static Boolean doesEntitlementContactAlreadyExist(Entitlement_Contact__c entitlementContact) {
		Id entitlementId = entitlementContact.Entitlement__c;
		Id contactId = entitlementContact.Contact__c;
		if (existingEntitlementContactsMap.containsKey(entitlementId)) {
			Set<Id> contactIds = existingEntitlementContactsMap.get(entitlementId);
			if (contactIds.contains(contactId)) {
				return true;
			}
		}
		return false;
	}

	private static void addEntitlementContactToExistingMap(Entitlement_Contact__c entitlementContact) {
		Id entitlementId = entitlementContact.Entitlement__c;
		Id contactId = entitlementContact.Contact__c;
		Set<Id> contactIds;
		if (existingEntitlementContactsMap.containsKey(entitlementId)) {
			contactIds = existingEntitlementContactsMap.get(entitlementId);
		} else {
			contactIds = new Set<Id>();
			existingEntitlementContactsMap.put(entitlementId, contactIds);
		}
		contactIds.add(contactId);
	}

	private static Boolean validateEntitlementContact(Entitlement_Contact__c entitlementContact) {
		Boolean result = true;
		if (entitlementContact.Contact__c == null) {
			result = false;
			System.debug(LoggingLevel.Error, 'Contact__c = null');
		}
		if (entitlementContact.Entitlement__c == null) {
			result = false;
		}
		return result;
	}

	//FeedItem Service
	private static Map<Id, Id> getExistingFeedItemIdByMarvelProjectId(FeedItem[] existingFeedItems) {
		Map<Id, Id> existingFeedItemIdByMarvelProjectId = new Map<Id, Id>();
		for (FeedItem feedItem : existingFeedItems) {
			if (!existingFeedItemIdByMarvelProjectId.containsKey(feedItem.Title)) {
				existingFeedItemIdByMarvelProjectId.put(feedItem.Title, feedItem.Id);
			}
		}
		return existingFeedItemIdByMarvelProjectId;
	}

	//Group service
	private static Map<String, Id> getTSQueueNamesById() {
		Map<String, Id> queueIdByName = new Map<String,Id>();
		Group[] queues = [
			SELECT Id, Name
			FROM Group
			WHERE Name IN :QUEUE_NAMES_TS_L3_WIRELESS
			AND Type = 'Queue'
		];
		for (Group queue : queues) {
			queueIdByName.put(queue.Name, queue.Id);
		}
		return queueIdByName;
	}

	private static Map<Id, Set<String>> getQueueNameByUserId(Set<Id> ids) {
		GroupMember[] groupMembers = [
			SELECT UserOrGroupId, Group.Name, GroupID
			FROM GroupMember
			WHERE GroupId IN (
				SELECT ID
				FROM Group
				WHERE Group.Type = 'Queue'
				AND Name IN :QUEUE_NAMES_TS_L3_WIRELESS
			)
			AND UserOrGroupId IN :ids
		];

		Map<Id, Set<String>> queueNameByUserId = new Map<Id, Set<String>>();
		for (GroupMember groupMember : groupMembers) {
			Id key = groupMember.UserOrGroupId;
			Set<String> values = new Set<String>();
			if (!queueNameByUserId.containsKey(key)) {
				queueNameByUserId.put(key, values);
			} else {
				values = queueNameByUserId.get(key);
			}
			values.add(groupMember.Group.Name);
		}
		return queueNameByUserId;
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

	private static Map<Id, Id> getPortalUserIdByContactId(Contact[] contacts) {
		Map<Id, Id> portalUserIdByContactId = new Map<Id, Id>();
		Set<Id> contactIds = (new Map<Id, Contact>(contacts)).keySet();
		User[] portalUser = [
			SELECT Id, ContactId
			FROM User
			WHERE ContactId IN :contactIds
			AND Profile.UserLicense.Name = :USER_LICENSE_NAME_CUSTOMER_COMMUNITY_LOGIN
		];
		for (User user : portalUser) {
			if (!portalUserIdByContactId.containsKey(user.ContactId)) {
				portalUserIdByContactId.put(user.ContactId, user.Id);
			}
		}
		return portalUserIdByContactId;
	}

	private static Boolean hasCreateAuditFieldsPermission() {
		Boolean hasPermission = false;
		User cUser = [
			SELECT ID, Name, Profile.PermissionsCreateAuditFields,
			(SELECT ID, PermissionSet.PermissionsCreateAuditFields, PermissionSet.Name
			FROM PermissionSetAssignments)
			FROM USER WHERE ID = :currentUserId
		];
		if (cUser.Profile != null && cUser.Profile.PermissionsCreateAuditFields) {
			hasPermission = true;
		} else {
			List<PermissionSetAssignment> psaList = cUser.PermissionSetAssignments;
			if (psaList != null && psaList.isEmpty() == false) {
				for (PermissionSetAssignment psa : psaList) {
					if (psa.PermissionSet.PermissionsCreateAuditFields) {
						hasPermission = true;
						break;
					}
				}
			}
		}
		return hasPermission;
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

	//Marvell Contact Service
	private static String convertMarvellContactEmailToNXPContactId(String email) {
		String keyEmail = isMarvellEmail(email) ? email + INVALID_SUFFIX : email;
		return contactIdByEmailMap.containsKey(keyEmail) ? contactIdByEmailMap.get(keyEmail) : null;
	}

	private static String convertMarvellContactRegion(String marvellRegion) {
		return MARVELL_TO_NXP_CONTACT_REGION_MAP.containsKey(marvellRegion)
				? MARVELL_TO_NXP_CONTACT_REGION_MAP.get(marvellRegion)
				: null;
	}

	private static String convertMarvellContactEmail(String marvellEmail) {
		if (marvellEmail == null) {
			return null;
		}
		return isMarvellEmail(marvellEmail)
				? marvellEmail + INVALID_SUFFIX
				: marvellEmail;
	}

	private static Boolean isMarvellEmail(String theEmail) {
		return theEmail != null && theEmail.containsIgnoreCase(AT_MARVELL_DOT_COM);
	}

	private static String convertMarvellAccountId(String marvellAccountId) {
		return marvellAccountNameByAccountId.containsKey(marvellAccountId)
				? marvellAccountNameByAccountId.get(marvellAccountId)
				: null;
	}

	//Marvell Case
	private static String convertMarvellPriorityToNXPPriority(String priority) {
		String result = NXP_PRIORTIES.contains(priority)
				? priority
				: CASE_INTERNAL_PRIORITY_LOW;
		return result;
	}

	private static Id convertMarvellAccountNameForCase(String name, Id defaultId, String recordId) {
		return convertMarvellAccountName(name, defaultId, 'Case', recordId);
	}

	private static Id getCreatedById(Id nxpContactId) {
		Id createdById = currentUserId;
		if (nxpContactId != null) {
			if (portalUserIdByContactId.containsKey(nxpContactId)) {
				createdById = portalUserIdByContactId.get(nxpContactId);
			}
		}
		return createdById;
	}

	private static Id convertMarvellAccountName(String name, Id defaultId, String objName, String recordId) {
		if (accountIdsByNameMap.containsKey(name)) {
			return accountIdsByNameMap.get(name);
		} else {
			String message = 'Account ' + name + ' wasn\'t found for ' + objName + ' ' + recordId;
			conversionErrors.add(new Log__c(Timestamp__c = Datetime.now(),
					MarvellRecordId__c = recordId,
					Message__c = message));
			System.debug(LoggingLevel.Error, recordId + ' : ' + message);
			return defaultId;
		}
	}

	private static String convertMarvellSubject(String marvellSubject, Decimal marvellCaseNumber) {
		return '[was Marvell'
				+ (marvellCaseNumber != null ? ': #' + marvellCaseNumber : '')
				+ '] ' + marvellSubject;
	}

	private static String convertMarvellPriorityToNXPInternalPriority(String priority) {
		String result = NXP_PRIORTIES.contains(priority)
				? priority
				: CASE_INTERNAL_PRIORITY_DEFAULT;
		return result;
	}

	private static String getNXPSupTopic(String marvellIssueType, String marvellIssueSubType) {
		return getNXPTypeTuple(marvellIssueType, marvellIssueSubType)[1];
	}

	private static String[] getNXPTypeTuple(String theType, String subType) {
		theType = String.isBlank(theType) ? '' : theType;
		subType = String.isBlank(subType) ? '' : subType;
		String[] key = new String[]{theType, subType};
		if (MARVELL_ISSUE_TO_NXP_TOPIC.containsKey(key)) {
			return MARVELL_ISSUE_TO_NXP_TOPIC.get(key);
		} else {
			return new String[]{null, null};
		}
	}

	private static String getNXPTopic(String marvellIssueType, String marvellIssueSubType) {
		return getNXPTypeTuple(marvellIssueType, marvellIssueSubType)[0];
	}

	private static String convertMarvellStatus(String marvellStatus) {
		return STATUS_MAP.containsKey(marvellStatus)
				? STATUS_MAP.get(marvellStatus)
				: null;
	}

	private static String convertCaseDescription(String marvellDescription) {
		if (marvellDescription == null) {
			return null;
		}
		marvellDescription = marvellDescription.stripHtmlTags();
		return marvellDescription.length() > 32000
				? marvellDescription.left(32000)
				: marvellDescription;
	}

	private static String convertMarvellRegion(String marvellRegion) {
		String result = MARVELL_TO_NXP_REGION_MAP.containsKey(marvellRegion)
				? MARVELL_TO_NXP_REGION_MAP.get(marvellRegion)
				: null;
		return result;
	}

	private static Id convertMarvellProjectId(Id marvellProjectId) {
		return entitlementIdByMarvellId.containsKey(marvellProjectId) ? entitlementIdByMarvellId.get(marvellProjectId) : null;
	}

	private static Id getAssignedToIdFromMarvellOnwerEmail(String marvellOwnerEmail) {
		Id nxpUserId = null;
		if (marvellUserEmailToNXPUserEmail.containsKey(marvellOwnerEmail)) {
			String nxpOwnerEmail = marvellUserEmailToNXPUserEmail.get(marvellOwnerEmail);
			nxpUserId = nxpUserIdByEmail.get(nxpOwnerEmail);
		}
		return nxpUserId;
	}

	private static Id getCaseOwnerIdFromMarvellOnwerEmail(String marvellOwnerEmail, String recordId, String topic, String webRegion) {
		String assignedQueueName;
		if (marvellUserEmailToNXPUserEmail.containsKey(marvellOwnerEmail)) {
			String nxpOwnerEmail = marvellUserEmailToNXPUserEmail.get(marvellOwnerEmail);
			Id nxpOwnerUserId = nxpUserIdByEmail.get(nxpOwnerEmail);

			if (queueNamesByUserId.containsKey(nxpOwnerUserId)) {
				Set<String> queueNames = queueNamesByUserId.get(nxpOwnerUserId);
				if (queueNames.size() == 1) {
					String[] queueNamesList = new List<String>(queueNames);
					assignedQueueName = queueNamesList[0];
				} else {
					if (webRegion == CASE_WEBREGION_EMEA || webRegion == CASE_WEBREGION_JAPAN) {
						if (topic == CASE_TOPIC_DOCUMENTATION || topic == CASE_TOPIC_HARDWARE_PRODUCT_SUPPORT) {
							assignedQueueName = QUEUE_NAME_TS_L3_WIRELESS_TAIWAN_AE;
						} else {
							assignedQueueName = QUEUE_NAME_TS_L3_WIRELESS_INDIA_AE;
						}
					}
				}
			}
		} else {
			conversionErrors.add(new Log__c(Timestamp__c = Datetime.now(),
					MarvellRecordId__c = recordID,
					Message__c = 'Owner ' + marvellOwnerEmail + ' wasn\'t found'));
			System.debug(LoggingLevel.Error, 'Owner ' + marvellOwnerEmail + ' wasn\'t found : ' + recordID);
		}
		if (String.isBlank(assignedQueueName)) {
			assignedQueueName = String.isNotBlank(webRegion)
					? webRegionToQueueName.get(webRegion)
					: QUEUE_NAME_TS_L3_WIRELESS_DISPATCH;
		}
		return queueIdByName.get(assignedQueueName);
	}

	//Marvell Case Comment Service
	private static Id convertCreatedByFromCaseComment (Id marvellUserId) {
		Id nxpUserId = getNxpUserIdByMarvellUserId(marvellUserId);
		return nxpUserId != null ? nxpUserId : currentUserId;
	}

	private static String convertCaseCommentCreatedIdToAddress(Id userId) {
		String userEmail = marvellUserEmailById.containsKey(userId)
				? marvellUserEmailById.get(userId) : null;
		return userEmail;
	}

	private static String convertAttachmentComments (String comments, String createdByName, Id marvellUserId) {
		Id nxpUserId = getNxpUserIdByMarvellUserId(marvellUserId);
		String userEmail = marvellUserEmailById.containsKey(marvellUserId)
				? marvellUserEmailById.get(marvellUserId) : null;
		String result = '';
		if (nxpUserId == null) {
			result = '[was provided by Marvell'
					+ (createdByName != null ? ' ' + createdByName : '')
					+ (userEmail != null ? ' (' + userEmail + ')' : '' )
					+ ']:<br/> ';
		}
		result += comments;
		result = result.stripHtmlTags();
		return result.left(FEEDITEM_BODY_MAX_LENGTH);
	}

	//Marvell Project Service
	private static Date getStartDateByProjectId(String projectId, Datetime projectCreatedDate) {
		Datetime startDT =  minCaseCreateDateByProjectId.containsKey(projectId)
				? minCaseCreateDateByProjectId.get(projectId)
				: projectCreatedDate;
		return startDT.date();
	}

	private static Id getCreatedByByProjectId(String projectId) {
		if (marvellCaseOwnerEmailsByProjectId.containsKey(projectId)) {
			String[] caseOwnerEmailsSortedByCreatedDate = marvellCaseOwnerEmailsByProjectId.get(projectId);
			String nxpUserEmail = DEFAULT_ENTITLEMENT_CREATED_BY_USER_EMAIL;
			for (String caseOwnerEmail : caseOwnerEmailsSortedByCreatedDate) {
				if (marvellUserEmailToNXPUserEmail.containsKey(caseOwnerEmail)) {
					nxpUserEmail = marvellUserEmailToNXPUserEmail.get(caseOwnerEmail);
					break;
				}
			}
			if (nxpUserIdByEmail.containsKey(nxpUserEmail)) {
				return nxpUserIdByEmail.get(nxpUserEmail);
			}
		}

		if (!nxpUserIdByEmail.containsKey(DEFAULT_ENTITLEMENT_CREATED_BY_USER_EMAIL)) {
			System.debug(LoggingLevel.Error, 'User for ' + DEFAULT_ENTITLEMENT_CREATED_BY_USER_EMAIL + ' was not found');
			return currentUserId;
		}

		return nxpUserIdByEmail.get(DEFAULT_ENTITLEMENT_CREATED_BY_USER_EMAIL);
	}

	private static String trimString(String input, Integer trimTo) {
		if (String.isBlank(input) || input.length() <= trimTo) {
			return input;
		}
		return input.left(trimTo);
	}

}