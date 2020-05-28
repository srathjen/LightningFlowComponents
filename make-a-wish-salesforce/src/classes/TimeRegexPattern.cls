/**
 * @description Time Regex Pattern
 * @author Gustavo Mayer, Traction on Demand
 * @date 4/16/2020
 */
public class TimeRegexPattern {

    private TimeRegexPatternEnum patternKey;
    private String pattern;
    private final static String HOUR_MINUTE_AM_PM_REGEX = '(\\d{1,2}):(\\d{1,2}) ([PA]M)';
    private final static String HOUR_MINUTE_SECOND_AM_PM_REGEX = '(\\d{1,2}):(\\d{1,2}):(\\d{1,2}) ([PA]M)';

    public TimeRegexPattern(TimeRegexPatternEnum patternKey) {
        if (patternKey.equals(TimeRegexPatternEnum.HOUR_MINUTE_AM_PM)) {
            this.patternKey = TimeRegexPatternEnum.HOUR_MINUTE_AM_PM;
            pattern = HOUR_MINUTE_AM_PM_REGEX;
        } else if (patternKey.equals(TimeRegexPatternEnum.HOUR_MINUTE_SECOND_AM_PM)) {
            this.patternKey = TimeRegexPatternEnum.HOUR_MINUTE_SECOND_AM_PM;
            pattern = HOUR_MINUTE_SECOND_AM_PM_REGEX;
        }
    }

    public TimeRegexPatternEnum getPatternKey() {
        return this.patternKey;
    }

    public String getPattern() {
        return this.pattern;
    }

    public enum TimeRegexPatternEnum {
        HOUR_MINUTE_AM_PM,
        HOUR_MINUTE_SECOND_AM_PM
    }
}