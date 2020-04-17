@IsTest
public class TimeRegexPatternTest {

	private final static String HOUR_MINUTE_AM_PM_REGEX = '(\\d{1,2}):(\\d{1,2}) ([PA]M)';
	private final static String HOUR_MINUTE_SECOND_AM_PM_REGEX = '(\\d{1,2}):(\\d{1,2}):(\\d{1,2}) ([PA]M)';

    @IsTest
	public static void shouldSetRegex() {
		TimeRegexPattern hourMinuteAmPm = new TimeRegexPattern(TimeRegexPattern.TimeRegexPatternEnum.HOUR_MINUTE_AM_PM);
		System.assertEquals(TimeRegexPattern.TimeRegexPatternEnum.HOUR_MINUTE_AM_PM, hourMinuteAmPm.getPatternKey());
		System.assertEquals(HOUR_MINUTE_AM_PM_REGEX, hourMinuteAmPm.getPattern());

		TimeRegexPattern hourMinuteSecondAmPm = new TimeRegexPattern(TimeRegexPattern.TimeRegexPatternEnum.HOUR_MINUTE_SECOND_AM_PM);
		System.assertEquals(TimeRegexPattern.TimeRegexPatternEnum.HOUR_MINUTE_SECOND_AM_PM, hourMinuteSecondAmPm.getPatternKey());
		System.assertEquals(HOUR_MINUTE_SECOND_AM_PM_REGEX, hourMinuteSecondAmPm.getPattern());
	}
}