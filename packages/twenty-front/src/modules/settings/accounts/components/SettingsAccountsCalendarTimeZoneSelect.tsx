import { detectTimeZone } from '@/localization/utils/detectTimeZone';
import { findAvailableTimeZoneOption } from '@/localization/utils/findAvailableTimeZoneOption';
import { AVAILABLE_TIMEZONE_OPTIONS } from '@/settings/accounts/constants/AvailableTimezoneOptions';

import { Select } from '@/ui/input/components/Select';

type SettingsAccountsCalendarTimeZoneSelectProps = {
  value?: string;
  onChange: (nextValue: string) => void;
};

export const SettingsAccountsCalendarTimeZoneSelect = ({
  value = detectTimeZone(),
  onChange,
}: SettingsAccountsCalendarTimeZoneSelectProps) => (
  <Select
    dropdownId="settings-accounts-calendar-time-zone"
    dropdownWidth={416}
    label="Time zone"
    fullWidth
    value={findAvailableTimeZoneOption(value)?.value}
    options={AVAILABLE_TIMEZONE_OPTIONS}
    onChange={onChange}
    withSearchInput
  />
);
