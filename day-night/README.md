# Day Night Mode

This is a set of scripts that will help control temperature (screen warmth) automatically or manually.

### Installation

Install [DayNightMode](https://github.com/plaidman/cube-xx/raw/refs/heads/main/day-night/DayNightMode.zip) through archive manager. This will install the following features:

- manual toggle between night and day mode in tasks
    - color will instantly change
- the automatic color shift scripts into init files
    - this is optional and can be disabled
    - color will gradually change according to your configuration
    - you must enable user scripts in `muos settings -> general -> advanced -> user init scripts` for the automatic color shifting to work

### Configuration

You can find the config file in `SD1/MUOS/task/.daynight/daynight.ini`.

| var name | notes |
| -------- |------ |
| automatic | 'yes' if you want to automatically switch between temperature modes at certain times |
| interval | how *often* per second the color changes. this can be a decimal number greater than 0 (e.g. 0.2) |
| increment | how *much* the screen changes for each interval. this MUST be a whole number greater than 0 |
| hour | the hour of the day that the mode switches. 24h format (e.g. `17` is `5pm`) |
| temp | the desired temperature to switch for that time. range is from -255 to 255 |
