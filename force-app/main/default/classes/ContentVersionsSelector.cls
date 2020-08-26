public class ContentVersionsSelector extends ApplicationSelector {
	
	public override Schema.SObjectType getSObjectType() {
		return ContentVersion.SObjectType;
	}
	
	public List<Schema.SObjectField> getSObjectFieldList() {
		return new List<Schema.SObjectField> {
			ContentVersion.Id,
			ContentVersion.ContentDocumentId,
			ContentVersion.IsLatest,
			ContentVersion.Title,
			ContentVersion.SharingOption,
			ContentVersion.PathOnClient,
			ContentVersion.Category__c
		};
	}
	
	public List<ContentVersion> selectById(Set<Id> ids) {
		p('selectById');
		return (List<ContentVersion>)selectSObjectsById(ids);
	}

}