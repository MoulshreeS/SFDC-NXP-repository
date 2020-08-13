public class AdminService {
	
	public class MarketSegmentation {
		public String segmentLabel { get; set; }
		public String segmentValue { get; set; }
		public String subsegmentLabel { get; set; }
		public String subsegmentValue { get; set; }
		public String applicationLabel { get; set; }
		public String applicationValue { get; set; }
	} 
	
	public static List<MarketSegmentation> getMarketSegmentationsFromOpportunity() {
		Map<MetadataUtils.PicklistItem, Set<MetadataUtils.PicklistItem>> subsegsBySeg = MetadataUtils.getDependentPicklistItems(Opportunity.SObjectType, Opportunity.Industry_Segment__c, Opportunity.Sub_Segment__c);
		Map<MetadataUtils.PicklistItem, Set<MetadataUtils.PicklistItem>> appsBySubseg = MetadataUtils.getDependentPicklistItems(Opportunity.SObjectType, Opportunity.Sub_Segment__c, Opportunity.Application__c);
		
		List<MarketSegmentation> marketSegmentations = new List<MarketSegmentation>(); 
		
		for (MetadataUtils.PicklistItem seg : subsegsBySeg.keySet()) {
			for (MetadataUtils.PicklistItem subseg : subsegsBySeg.get(seg)) {
				Set<MetadataUtils.PicklistItem> apps = appsBySubseg.get(subseg);
				
				for (MetadataUtils.PicklistItem app : apps) {
					MarketSegmentation ms = new MarketSegmentation();
					ms.segmentLabel = seg.label;
					ms.segmentValue = seg.value;
					ms.subsegmentLabel = subseg.label;
					ms.subsegmentValue = subseg.value;
					ms.applicationLabel = app.label;
					ms.applicationValue = app.value;
					
					marketSegmentations.add(ms);	
				}
			}	
		}
		
		return marketSegmentations;	
	}
	
	public static void createMarketSegmentationsFromOpportunity() {
		List<MarketSegmentation__c> marketSegmentations = new List<MarketSegmentation__c>(); 
		
		for (MarketSegmentation ms : getMarketSegmentationsFromOpportunity()) {
			marketSegmentations.add(
				new MarketSegmentation__c(
					Segment_Label__c = ms.segmentLabel, 
					Segment_Value__c = ms.segmentValue, 
					Subsegment_Label__c = ms.subsegmentLabel,
					Subsegment_Value__c = ms.subsegmentValue,
					Application_Label__c = ms.applicationLabel,
					Application_Value__c = ms.applicationValue
				)
			);	
		}
		
		insert marketSegmentations;	
	}
	
	public static void deleteMarketSegmentations() {
		delete new MarketSegmentationsSelector().selectAll();
	}
	
	public static List<MarketSegmentation> getMarketSegmentations() {
		List<MarketSegmentation> result = new List<MarketSegmentation>();
		
		for (MarketSegmentation__c ms : (List<MarketSegmentation__c>)new MarketSegmentationsSelector().selectAll()) {
			MarketSegmentation mktSeg = new MarketSegmentation();
			mktSeg.segmentLabel = ms.Segment_Label__c;
			mktSeg.segmentValue = ms.Segment_Value__c;
			mktSeg.subsegmentLabel = ms.Subsegment_Label__c;
			mktSeg.subsegmentValue = ms.Subsegment_Value__c;
			mktSeg.applicationLabel = ms.Application_Label__c;
			mktSeg.applicationValue = ms.Application_Value__c;
			
			result.add(mktSeg);
		}
		
		return result;	
	}
	
	public static void updateOpportunityMarketSegmentations() {
		Set<MetadataUtils.PicklistItem> segs = new Set<MetadataUtils.PicklistItem>();  	
		
		Map<MetadataUtils.PicklistItem, Set<MetadataUtils.PicklistItem>> subsegsBySeg = new Map<MetadataUtils.PicklistItem, Set<MetadataUtils.PicklistItem>>();
		Map<MetadataUtils.PicklistItem, Set<MetadataUtils.PicklistItem>> appsBySubseg = new Map<MetadataUtils.PicklistItem, Set<MetadataUtils.PicklistItem>>();
		
		for (MarketSegmentation ms : getMarketSegmentations()) {
			MetadataUtils.PicklistItem seg = new MetadataUtils.PicklistItem(ms.segmentLabel, ms.segmentValue);
			MetadataUtils.PicklistItem subseg = new MetadataUtils.PicklistItem(ms.subsegmentLabel, ms.subsegmentValue);
			MetadataUtils.PicklistItem app = new MetadataUtils.PicklistItem(ms.applicationLabel, ms.applicationValue);
			
			segs.add(seg);
						
			if (!subsegsBySeg.containsKey(seg)) {
				subsegsBySeg.put(seg, new Set<MetadataUtils.PicklistItem>());
			}
			
			subsegsBySeg.get(seg).add(subseg);
			
			if (!appsBySubseg.containsKey(subseg)) {
				appsBySubseg.put(subseg, new Set<MetadataUtils.PicklistItem>());
			}
			
			appsBySubseg.get(subseg).add(app); 
		}
		
		MetadataUtils.deactivatePicklistFieldValues(Opportunity.SObjectType, Opportunity.Industry_Segment__c, null);
		MetadataUtils.updatePicklistField(Opportunity.SObjectType, Opportunity.Industry_Segment__c, segs, null);
		
		MetadataUtils.deactivatePicklistFieldValues(Opportunity.SObjectType, Opportunity.Sub_Segment__c, Opportunity.Industry_Segment__c);
		MetadataUtils.updateDependentPicklistField(Opportunity.SObjectType, Opportunity.Industry_Segment__c, Opportunity.Sub_Segment__c, subsegsBySeg);
		
		MetadataUtils.deactivatePicklistFieldValues(Opportunity.SObjectType, Opportunity.Application__c, Opportunity.Sub_Segment__c);
		MetadataUtils.updateDependentPicklistField(Opportunity.SObjectType, Opportunity.Sub_Segment__c, Opportunity.Application__c, appsBySubseg);
	}
	
}