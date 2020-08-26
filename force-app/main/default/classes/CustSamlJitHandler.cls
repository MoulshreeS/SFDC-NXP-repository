/*********************************************************************************************************
@Modified By:		Nisha Agrawal
@Modified Date:		Dec 11, 2018
@Description:		1. Modified to include scenario when user already exists as Lead Portal User and
					 need access to customer community
					2. Replace common functionality from library
***********************************************************************************************************/


//This class provides logic for inbound just-in-time provisioning of single sign-on users in your Salesforce organization.
global class CustSamlJitHandler implements Auth.SamlJitHandler 
{
    private static final String s_communityName = 'NXP Community';

    private user handleUser(boolean create, User u, String contactId, Map<String, String> attributes, String federationIdentifier) 
    {
        /*
         * If you are updating Contact or Account object fields, you cannot update the following User fields at the same time.
         * If your identity provider sends these User fields as attributes along with Contact 
         * or Account fields, you must modify the logic in this class to update either these 
         * User fields or the Contact and Account fields.
         * 
         * IsActive, ForecastEnabled, ProfileId, UserRoleId
         */

        //'NXP community' account and 'NXP Customer Community Login User' profile
        CommunitySettings__c cs = CommunitySettings__c.getValues('CommunityUrl');
        Id cs_accountId= cs.CommunityUserAccountId__c; 
        Id cs_profileId= cs.CommunityUserProfileId__c;
        Id cs_employeeProfileId = cs.CommunityEmployeeProfileId__c;

        String strEmail = '';
        Id userProfileId;
        if(attributes.containsKey('User.Email')) 
        {
            strEmail = attributes.get('User.Email');
        }
        
        if(strEmail !=null && (strEmail.tolowercase().contains('freescale.com') || strEmail.tolowercase().contains('nxp.com') ))
        {
            userProfileId = cs_employeeProfileId ;
        }
        else
        {
            userProfileId = cs_profileId;
        }
        
        if(create)
        {
            u = new User(ProfileId = userProfileId, ContactId = contactId, EmailEncodingkey='ISO-8859-1', LanguageLocaleKey='en_US', LocaleSidKey='en_US', TimeZoneSidKey='GMT');
            //set the username
            u.Username = strEmail;
        }
        
        if(attributes.containsKey('User.Email')) {
            u.Email = attributes.get('User.Email');
        } 
        
        if(attributes.containsKey('User.FirstName')) {
            u.FirstName = attributes.get('User.FirstName');
        }
        
        if(attributes.containsKey('User.LastName')) {
            u.LastName = attributes.get('User.LastName');
        }
    
        if(attributes.containsKey('User.CompanyName')) {
            u.CompanyName = attributes.get('User.CompanyName');
        }
        
        if(attributes.containsKey('User.Country')) {
            u.Country = attributes.get('User.Country');
        }

        if(u.FederationIdentifier == null || u.FederationIdentifier.trim().length() == 0)
        {
            if(federationIdentifier != null && federationIdentifier.trim().length() > 0) 
            {
                u.FederationIdentifier = federationIdentifier;  
            }
        }
        
        if(u.CommunityNickname == null || u.CommunityNickname.trim().length() == 0)
        {
            u.CommunityNickname = JITHandlerLib.createCommunityNickName(u.FirstName, u.LastName, u.FederationIdentifier);
        }
        if(u.Alias == null || u.Alias.trim().equals(''))
        {
            u.Alias = JITHandlerLib.createAlias(attributes, u.FirstName, u.LastName);
        }
        
        if(! create) 
        {
            update(u);
            
			//check the profileid for existing user - if lead portal user then need to assign customer community user permissions 
            if( u.ProfileId != userProfileId)
            {
            	LeadPortalLib.getExternalUserProfile();
                Id partnerUserProfileId = LeadPortalLib.LP_EXTERNAL_PROFILE_Id;        
                
                //get the profile id for Lead Portal user
                if(partnerUserProfileId == null)
                {
                    throw new JITHandlerLib.JitException('Error Occured : Profile Not found.');
                }
                
                if(partnerUserProfileId != null && u.ProfileId == partnerUserProfileId)
                {
                    List<PermissionSetAssignment> psa = [select PermissionSetId,AssigneeId from PermissionSetAssignment where PermissionSet.Name=:JITHandlerLib.CUSTOMER_COMMUNITY_PERMISSIONS and AssigneeId =:u.Id];
                    if(psa==null || psa.isEmpty())
                    	UserTriggerHandler.assignPermissionSetToUsers(new Set<Id>{u.Id});        
                }                
            }
        }
        
        return u;
    }
    
    private String handleContact(boolean create, String accountId, User u11, Map<String, String> attributes)
    {
        Contact c=null;
        boolean newContact = false;

        String contactId= u11.ContactId;
        if(contactId == null)
        {
            //if no contact provided, then check if a contact exist by email
            if(attributes.containsKey('User.Email')) 
            {
                String contactEmail = attributes.get('User.Email');
                Contact[] ca = [select id, accountId,Community_web_country__c from contact where email=:contactEmail order by LastModifiedDate DESC];
                if(ca.size()>0)
                {
                    c = ca[0];
                    newContact = false;
                }
            }
        }
        else
        {
            c = [SELECT Id, AccountId,Community_web_country__c FROM Contact WHERE Id=:contactId];
            newContact = false;
        }
      
        if(c==null)
        {
            c = new Contact();
            newContact = true;
        }
        
    /*    if(!newContact && c.AccountId != accountId) {
            throw new JitException('Mismatched account: ' + c.AccountId + ', ' + accountId);
        }*/

        if(attributes.containsKey('User.Email')) {
            c.Email = attributes.get('User.Email');
        }
        if(attributes.containsKey('User.FirstName')) {
            c.FirstName = attributes.get('User.FirstName');
        }
        if(attributes.containsKey('User.LastName')) {
            c.LastName = attributes.get('User.LastName');
        }
        if(attributes.containsKey('User.CompanyName')) {
            c.Company__c = attributes.get('User.CompanyName');
        }
        if(attributes.containsKey('User.Country') &&  String.isNotBlank(attributes.get('User.Country')) ) 
        {
            c.Community_web_country__c = attributes.get('User.Country');
        }        
        else 
        {
            if((!newContact) && String.isBlank( c.Community_web_country__c)){
                c.Community_web_country__c = 'Unknown';
            }else if(newContact){
            	c.Community_web_country__c = 'Unknown';    
            }
        }
        //set active community user flag as true
        c.Is_Active_Community_User__c = true;
        //set new checkbox to false here
        c.Not_Found_In_Marketing__c = false;
        if(newContact) {
            c.AccountId = accountId;
            System.debug('Account Id in HandleContact method: '+ accountId);
            System.debug('INSERTING new CONTACT: '+ c);
            try{
                 insert(c);
                } catch(Exception e)
                {
                    System.debug('EXCEPTION WHILE INSERTING CONTACT: ' + e.getMessage());
                }
         } else 
         {
           System.debug('UPDATING CONTACT: '+ c.id);
           // update(c);
           updateContact(JSON.serialize(c));
        }

         System.debug('Inside handleContact: returning ' + c.Id);
         return c.Id;
    }

    private String handleAccount() {
        Account a;
         a = [SELECT Id,  name FROM Account WHERE name=:s_communityName ];
         System.debug('Inside handleAccount, found acctObj: ' + a);
        return a.Id;
    }

    global User createUser(Id samlSsoProviderId, Id communityId, Id portalId,
        					String federationIdentifier, Map<String, String> attributes, String assertion) 
    {
        String email = null;
        
        if(attributes.containsKey('User.Email')) 
        {
            email = attributes.get('User.Email');
        }

        User user = new User();
        boolean createUser = true;
        
        //check if user already exist. first check by federation id, if not found then check by email
        User[] ua = [SELECT Id, name, alias, email, CommunityNickname, FederationIdentifier, AccountId, ContactId, ProfileId FROM User WHERE federationidentifier=:federationIdentifier];
        if(ua.size()>0)
        {    
            createUser = false;
            user = ua[0];
        }
        else
        {
            if(email != null) 
            {
                //check by username instead of email as username should be an email and always unique
                ua = [SELECT Id, name, alias, email, CommunityNickname, FederationIdentifier, AccountId, ContactId, ProfileId FROM User WHERE username=:email];
                if(ua.size()>0)
                {
                    createUser = false;
                    user = ua[0];
                }
            }
            else
            {
                System.debug('User.Email attribute not provided');
            }
        }

        user = handleJit(createUser, user, samlSsoProviderId, portalId, federationIdentifier, attributes, assertion);

        return user;
    }

    global void updateUser(Id userId, Id samlSsoProviderId, Id communityId, Id portalId,
        					String federationIdentifier, Map<String, String> attributes, String assertion) 
	{
        if(attributes.containsKey('User.Email')) 
        { 
            String email = attributes.get('User.Email');
        }
        
        User u = [SELECT Id, name, alias, email, CommunityNickname, FederationIdentifier, AccountId, ContactId, ProfileId  FROM User WHERE Id=:userId];
        handleJit(false, u, samlSsoProviderId, portalId,federationIdentifier, attributes, assertion);
    }
    
    private User handleJit(boolean create, User u, Id samlSsoProviderId, Id portalId,
        					String federationIdentifier, Map<String, String> attributes, String assertion) 
    {
        
        String accountId = handleAccount();
        String contactId = handleContact(create, accountId, u, attributes);
        return handleUser(create, u, contactId, attributes, federationIdentifier);
    }

	@future
    private static void updateContact(String contactAsJSON)
	{
        try
        {
            Contact objContact = (Contact)JSON.deserialize(contactAsJson, Contact.class);
           	update objContact;            
        } 
        catch(Exception e)
        {
            throw new JITHandlerLib.JitException('EXCEPTION WHILE UPDATING CONTACT: ' + e.getMessage());            
        }
	}    
}