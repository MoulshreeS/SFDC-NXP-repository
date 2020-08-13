public with sharing class EVE_ConversionResultDTO {
	public Integer converted;
	public Integer skipped;
	public Integer failed;
	public Integer expected;

	public EVE_ConversionResultDTO(Integer converted, Integer skipped, Integer failed) {
		this.converted = converted;
		this.skipped = skipped;
		this.failed = failed;
	}

	public EVE_ConversionResultDTO(Integer expected, Integer converted, Integer skipped, Integer failed) {
		this(converted, skipped, failed);
		this.expected = expected;
	}

	public EVE_ConversionResultDTO add(EVE_ConversionResultDTO addendum) {
		this.converted += addendum.converted;
		this.skipped += addendum.skipped;
		this.failed += addendum.failed;
		return this;
	}

	public override String toString() {
		return this.expected + ' records expected, '
			+ this.converted + ' records converted, '
			+ this.skipped + ' records skipped, '
			+ this.failed + ' records failed';
	}
}