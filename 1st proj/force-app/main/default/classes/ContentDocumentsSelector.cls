public class ContentDocumentsSelector extends ApplicationSelector {
	
	public override Schema.SObjectType getSObjectType() {
		return ContentDocument.SObjectType;
	}
	
	public List<Schema.SObjectField> getSObjectFieldList() {
		return new List<Schema.SObjectField> {
			ContentDocument.Id,
			ContentDocument.LastModifiedDate,
			ContentDocument.LatestPublishedVersionId,
			ContentDocument.OwnerId,
			ContentDocument.Title
		};
	}

	public List<ContentDocument> selectById(Set<Id> ids) {
		p('selectById');
		return (List<ContentDocument>)selectSObjectsById(ids);
	}

}