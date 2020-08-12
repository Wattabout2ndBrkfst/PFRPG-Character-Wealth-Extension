# PFRPG-Character-Wealth-Extension
Extension for Fantasy Grounds 3.5E, 5E, and PFRPG.  
Allows a user to enter a command to calculate a single character's total wealth, all characters' total wealth, and the party's total wealth 

## Author
Wattabout2ndBrkfst

## Version Number
V1.0.0 - May 26, 2020 - Initial release  
v1.1.0 - August 12, 2020 - Added "-all" and "-party" support

## Rulesets
3.5E, 5E, and PFRPG

## Dependencies
Tested and works with Fantasy Grounds Classic Client 3.3.11  
Tested and works with Fantasy Grounds Unity 4.0.0

## Compatibility with Other Extensions
This extension adds a new command to use for the Host. It does not modify anything else besides this. 

## Installation
Under the Extension-Files folder, copy the extension file over to the extensions folder in Fantasy Grounds

## Usage
/charwealth [character name]  
"character name" is the exact name of a character  

/charwealth -all

/charwealth -party

## Notes
If you are not the Host, this command is unavailable to you.  
The command only takes into account the wealth of items in a character's inventory. If they have gold pieces not in their inventory, these will need to be added manually.

The "-all" argument prints out the character wealth for each character and the sum of all character wealths

The "-party" argument prints out the character wealth for each character in the party sheet and the sum of all character wealths in the party sheet

For 5E, many items have a non-number cost. These shall not be included in the character's wealth

## License
Please see the license.html file included with this distribution for attribution and copyright information.  
This extension uses [GNU GPLv3](https://choosealicense.com/licenses/gpl-3.0/)