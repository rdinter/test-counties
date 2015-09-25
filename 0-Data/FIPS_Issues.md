# FIPS Overview

[Federal Information Processing Standards](http://www.nist.gov/itl/fips.cfm) is a government system which geographically partitions the United States by disjoint regions. For our purposes, FIPS consistent to two parts: State and County. The State FIPS is a two-digit value which spans the United States across States and Territories. Given a State FIPS, a particular geographic location in a State is then partitioned into a County FIPS. A County FIPS is a three-digit value and represents a political polygon within a State/Territory. County FIPS are also disjoint regions, although as we will see in the [problems section][Problems with FIPS], the intended goal of a disjoint set may interfere with political practice.

## Problems with FIPS

Government agencies that collect county-level data may or may not be consistent across time and/or agencies. This may be because new counties emerge over time, counties change names, counties consolidate to another, or the definition of a county equivalent varies[^fn-cnty-eq] across time/agency. This can make construction of panel data involving county-level data frustrating to keep these changes consistent.

[^fn-cnty-eq]: The most egregious example for this comes from Virginia, which has designations for [counties and independent cities](http://www.pettitcompany.com/html/va_cities_and_counties.html). For some government data, a fips code will designate the county as well as all independent cities that lie within the border. Other government data will track data for independent cities as their own fips code.

The [National Resource Conservation Service](http://www.nrcs.usda.gov/wps/portal/nrcs/detail/pa/home/?cid=nrcs143_013710) has an excellent overview of FIPS changes where a fips code needs to be combined with other existing ones. Further, the Census Bureau [maintains county equivalent changes from 1970 to present](https://www.census.gov/geo/reference/county-changes.html) which are deemed:

>Substantial county changes include all county boundary changes affecting an estimated population of 200 or more people, changes of at least one square mile where no estimated population was provided and research indicated that the affected population may have been 200 people or more, or "large" annexations of unpopulated territory (10 square miles or more).

A short overview for each State is provided below with particular dates noted. The raw descriptions are from the [Census description](https://www.census.gov/geo/reference/county-changes.html) of county changes and are left at the bottom of each state overview. States that are not listed do not need any changes of note.

### Alabama
A name change from "De Kalb" to "DeKalb." County names should not be of interest in any analysis, only a unique identifier and so this should not be of concern.

1. **1980s:**
  - NAME CHANGE:
    * DeKalb County, Alabama (01-049): Name corrected from De Kalb County.

### Alaska
Alaska does not have counties, rather they designate "boroughs" and "census areas" which are generally termed counties. Over time, Alaska has had the most changes for FIPS and is the second most frustrating State to deal with. There is speculation that the vast number of changes from Alaska is a response to changes in government program requirements (i.e. minimum/maximum population requirements) and/or the nature of attempting to govern such a vast and low population density area given limited resources. I cannot find a specific reference for this.

A typical solution for Alaska is to drop the state (and Hawaii) from the analysis with the justification of focusing on the lower 48 States. This could be because it is a spatial island, outside the scope of analysis, or simple too different from the lower 48 for it to be included. The changes across time are shown below:

| Time | Deprecated FIP | Change to      |
|:-----|:---------------|:---------------|
| 1993 | 2231           | 2232/2282      |
| 2006 | 2232           | 2105/2230      |
| 2007 | N E W          | 2105           |
| 2008 | 2201           | 2198           |
| 2008 | 2280           | 2195           |
| 2008 | N E W          | 2275           |
| 2015 | 2270           | 2158           |

The data on FIPS 2201 and 2280 may be difficult to work with. Although they were eliminated in 2008, they sometimes appear and disappear in years surrounding. For example, for IRS migration data they exist before 2008 and in 2009 but not in 2007 or beyond 2009.

**TO BE COMPLETED AT SOME POINT IN THE FUTURE**

1. **1970s:** The county equivalent entities in Alaska changed from Census Divisions in 1970 to Boroughs and Census Areas in 1980. The inventory and boundaries of the Alaska county-level entities changed substantially during the decade.
  - ADDED:
    * Dillingham Census Area (02-070); North Slope Borough (02-185); and Valdez-Cordova Census Area (02-261).
  - DELETED:
    * Angoon Division (02-030); Barrow Division (02-040); Cordova-McCarthy Division (02-065); Kenai-Cook Inlet Division (02-120); Kuskokwim Division (02-160); Outer Ketchikan Division (02-190); Prince of Wales Division (02-200); Skagway-Yakutat Division (02-230); Upper Yukon Division (02-250); and Valdez-Chitina-Whittier Division (02-260).

2. **1980s:**
  - ADDED:
    * Aleutians East Borough, Alaska (02-013): Created from part of the former Aleutian Islands Census Area (02-010) effective October 23, 1987. The remainder of the former Aleutian Islands Census Area was established as the new Aleutians West Census Area (02-016); 1980 population: 1,643.
    * Aleutians West Census Area, Alaska (02-016): Created from the remainder of the former Aleutian Islands Census Area (02-010) when the new Aleutians East Borough (02-013) was created effective October 23, 1987; 1980 population: 6,125.
    * Lake and Peninsula Borough, Alaska (02-164): Created from part of the Dillingham Census Area (02-070) effective April 24, 1989; 1980 population: 1,384.
    * Northwest Arctic Borough, Alaska (02-188): Created from all of the former Kobuk Census Area (02-140) and an unpopulated part of the North Slope Borough (02-185) effective June 2, 1986; 1980 population: 4,831.
  - DELETED:
    * Aleutian Islands Census Area, Alaska (02-010): Split to create the Aleutians East Borough (02-013) and the Aleutians West Census Area (02-016) effective October 23, 1987.
    * Kobuk Census Area (02-140): All taken plus unpopulated part of the North Slope Borough (02-185) to create the new Northwest Arctic Borough (02-188) effective June 2, 1986.
  - BOUNDARY CHANGES:
    * Dillingham Census Area (02-070): Part taken to create the new Lake and Peninsula Borough (02-164) effective April 24, 1989; 1980 detached population: 1,384.
    * North Slope Borough (02-185): Unpopulated part plus all of the former Kobuk Census Area (02-140) taken to create the new Northwest Arctic Borough (02-188) effective June 2, 1986.

3. **1990s:**
  - ADDED:
    * Denali Borough, Alaska (02-068): Created from part of the Yukon-Koyukuk Census Area (02-290) and an unpopulated part of the Southeast Fairbanks Census Area (02-240) effective December 7, 1990; 1990 population: 1,682.
    * Skagway-Hoonah-Angoon Census Area, Alaska (02-232): Created from the remainder of the former Skagway-Yakutat-Angoon Census Area (02-231) when the new Yakutat City and Borough (02-282) was created effective September 22, 1992; 1990 population: 3,679.
    * Yakutat City and Borough, Alaska (02-282): Created from part of the former Skagway-Yakutat-Angoon Census Area (02-231) effective September 22, 1992. The remainder of the former Skagway-Yakutat-Angoon Census Area was established as the new Skagway-Hoonah-Angoon Census Area (02-232) effective September 22, 1992; 1990 population: 725.
  - DELETED:
    * Skagway-Yakutat-Angoon Census Area, Alaska (02-231): Split to create the Skagway-Hoonah-Angoon Census Area (02-232) and Yakutat City and Borough (02-282) effective September 22, 1992.
  - BOUNDARY CHANGES:
    * Southeast Fairbanks Census Area, Alaska (02-240): Unpopulated part taken to create the new Denali Borough (02-068) effective December 7, 1990.
    * Yukon-Koyukuk Census Area, Alaska (02-290): Part taken to create the new Denali Borough (02-068) effective December 7, 1990; 1990 detached population: 1,682.

4. **2000s:**
  - ADDED:
    * Wrangell City and Borough (02-275): Created from part of the former Wrangell-Petersburg Census Area (02-280) and part of Prince of Wales-Outer Ketchikan Census Area (02-201) (Meyers Chuck area) effective June 1, 2008; estimated population: 2,448. The remainder of the former Wrangell-Petersburg Census Area was established as the new Petersburg Census Area (02-195) effective June 1, 2008.
    * Petersburg Census Area (02-195): Created from the remainder of the former Wrangell-Petersburg Census Area (02-280) when the new Wrangell City and Borough was created effective June 1, 2008; estimated population: 4,260.
    * Prince of Wales-Hyder Census Area (02-198): Created from the remainder of the former Prince of Wales-Outer Ketchikan Census Area (02-201) after part (Outer Ketchikan area) was annexed by Ketchikan Gateway Borough (02-130) effective May 19, 2008, and part (Meyers Chuck area) included in the new Wrangell City and Borough effective June 1, 2008; estimated population: 6,115.
    * Skagway Municipality (02-230): Created from part of the former Skagway-Hoonah-Angoon Census Area (02-232) effective June 20, 2007; boundaries are identical to Skagway census subarea; population: 862. The remainder of the former Skagway-Hoonah-Angoon Census Area was established as the new Hoonah-Angoon Census Area (02-105).
    * Hoonah-Angoon Census Area (02-105): Created from the remainder of the former Skagway-Hoonah-Angoon Census Area (02-232) when the new Skagway Municipality (02-230) was created effective June 20, 2007; population: 2,574.
  - DELETED:
    * Wrangell-Petersburg Census Area (02-280): Split to create part of Wrangell City and Borough (02-275) and all of Petersburg Census Area (02-195), effective June 1, 2008.
    * Prince of Wales-Outer Ketchikan Census Area (02-201): Part (Outer Ketchikan area) annexed by Ketchikan Gateway Borough (02-130) and part (Meyers Chuck area) included in new Wrangell City and Borough (02-275), remainder renamed Prince of Wales-Hyder Census Area (02-198) effective May 19, 2008.
    * Skagway-Hoonah-Angoon Census Area (02-232): Split to create Skagway Municipality (02-230) and Hoonah-Angoon Census Area (02-105), effective June 20, 2007.
  - BOUNDARY CHANGES:
    * Ketchikan Gateway Borough (02-130): Annexed a substantial portion of the former Prince of Wales-Outer Ketchikan Census Area (02-201), including most of the area known as Outer Ketchikan effective May 19, 2008; estimated added population: 7. As a result, the remaining area of the former Prince of Wales-Outer Ketchikan Census Area was renamed Prince of Wales-Hyder Census Area (02-198).

5. **2010s:**
  - ADDED:
    * Petersburg Borough, Alaska (02-195): Created from part of former Petersburg Census Area (02-195) and part of Hoonah-Angoon Census Area (02-105) effective January 3, 2013; estimated population 3,203.
  - NAME CHANGE:
    * Kusilvak Census Area, Alaska (02-158): Changed name and code from Wade Hampton Census Area (02-270) effective July 1, 2015.
    * Wade Hampton Census Area, Alaska (02-270): Changed name and code to Kusilvak Census Area (02-158) effective July 1, 2015.
  - BOUNDARY CHANGES
    * Prince of Wales-Hyder Census Area, Alaska (02-198): Prince of Wales-Hyder Census Area (02-198) added part of the former Petersburg Census Area (02-195) effective January 3, 2013; estimated added population 613.
    * Hoonah-Angoon Census Area, Alaska (02-105): Part taken to create new Petersburg Borough (02-195) effective January 3, 2013; estimated detached population: 1

### Arizona
Only noted change is that the county of La Paz (04012) was created from Yuma County (04027) in 1983. The change is so small that there should be no recodes or retroactive changes necessary.

1. **1980s:**
  - ADDED:
    * La Paz County, Arizona (04-012): Created from part of Yuma County (04-027) effective January 1, 1983; 1980 population: 12,557.
  - BOUNDARY CHANGE:
    * Yuma County, Arizona (04-027): Part taken to create new La Paz County (04-012) effective January 1, 1983; 1980 detached population: 12,557.


### Colorado
There were minor goegraphical changes for Colorado that involved less than 5,000 people in the 1980s. These are inconsequential for most data. The biggest issue to be observed is that in 2001, a new county was created (Broomfield) from Adams, Coulder, Jefferson, and Weld counties.

Broomfield County, CO (08014) was created in 2001 from parts of four neighboring counties.

1. **1980s:**
  - BOUNDARY CHANGE:
    * Adams County, Colorado (08-001): Annexed part of Denver County (08-031) coextensive with Denver city effective October 18, 1980; estimated population: 2,500. Part annexed to Denver County (08-031) effective May 17, 1988; estimated area 43.31 square miles with no estimated population.
    * Arapahoe County, Colorado (08-005): Annexed part of Denver County (08-031) coextensive with Denver city effective July 28, 1980; estimated area one square mile with no estimated population.
    * Denver County, Colorado (08-001) coextensive with Denver city: Part annexed to Adams County (08-001) effective October 18, 1980; estimated population: 2,500. Annexed part of Adams County (08-001) effective May 17, 1988; estimated area 43.31 square miles with no estimated population. Part annexed to Arapahoe County (08-005) effective July 28, 1980; estimated area one square mile with no estimated population.

2. **2000s:**
  - ADDED:
    * Broomfield County, CO (08-014): Created from parts of Adams (08-001), Boulder (08-013), Jefferson (08-059), and Weld (08-123) counties effective November 15, 2001. The boundaries of Broomfield County reflect the boundaries of Broomfield city legally in effect on that date; estimated population: 39,177.
  - BOUNDARY CHANGES:
    * Adams County, Colorado (08-001): Part taken to create new Broomfield County (08-014) effective November 15, 2001; estimated detached population: 15,870.
    * Boulder County, Colorado (08-013): Part taken to create new Broomfield County (08-014) effective November 15, 2001; estimated detached population: 21,512.
    * Jefferson County, Colorado (08-059): Part taken to create new Broomfield County (08-014) effective November 15, 2001; estimated detached population: 1,726.
    * Weld County, Colorado (08-123): Part taken to create new Broomfield County (08-014) effective November 15, 2001; estimated detached population: 69.


Various other issues recorded:
- 08031 was collapsed into 08001

### Florida

1. **1980s:**
  - NAME CHANGE:
    * DeSoto County, Florida (12-027): Name corrected from De Soto County.

2. **1990s:**
  - BOUNDARY CHANGE:
    * Franklin County, Florida (12-037): Boundary correction added unpopulated part of Gulf County (12-045); estimated area added: 10.4 square miles.
    * Gulf County Florida (12-045): Boundary correction detached unpopulated part to Franklin County (12-037); estimated area detached: 10.4 square miles.
  - NAME CHANGE:
    * Dade County, Florida (12-025): Renamed as Miami-Dade County (12-086) effective July 22, 1997.
    * Miami-Dade County, Florida (12-086): Renamed from Dade County (12-025) effective July 22, 1997.

Dade County, FL (formerly 12025) changed its name to Miami-Dade (now 12086) and thus the FIPS code changed to maintain alphabetical order.

Solution: change any and all 12025 to 12086.

### Georgia
Nothing really, name change for DeKalb.

1. **1980s:**
  - NAME CHANGE:
    * DeKalb County, Georgia (13-089): Name corrected from De Kalb County.

### Illinois

1. **1980s:**
  - NAME CHANGE:
    * DeKalb County, Illinois (17-037): Name corrected from De Kalb County.
    * DuPage County, Illinois (17-043): Name corrected from Du Page County.

### Indiana

1. **1990s:**
  - NAME CHANGE:
    * DeKalb County, Indiana (18-033): Name corrected from De Kalb County
    * LaGrange County, Indiana (18-087): Name corrected from Lagrange County.
    * LaPorte County, Indiana (18-091): Name corrected from La Porte County.


### Maryland

1. **1990s:**
  - BOUNDARY CHANGES:
    * Montgomery County, Maryland (24-031): Added territory (Takoma Park city) from Prince George's County (24-033) effective July 1, 1997; 1990 added population: 5,156.
    * Prince George?s County, Maryland (24-033): Lost territory (Takoma Park city) to Montgomery County (24-031) effective July 1, 1997; 1990 detached population: 5,156.


### Mississippi

1. **1980s:**
  - NAME CHANGE:
    * DeSoto County, Mississippi (28-033): Name corrected from De Soto County.


### Missouri

1. **1980s:**
  - NAME CHANGE:
    * DeKalb County, Missouri (29-063): Name corrected from De Kalb County.

Various other issues recorded:
- 29510 was collapsed into 29189


### Montana
Yellowstone National Park (30113) was its own "county equivalent" in 1990, but was merged with Gallatin (30031) and Park (30067) Counties.

1. **1990s:**
  - BOUNDARY CHANGES:
    * Gallatin County, Montana (30-031): Annexed unpopulated portion of deleted Yellowstone National Park (county equivalent) (30-113) effective November 7, 1997.
    * Park County, Montana (30-067): Annexed portion of deleted Yellowstone National Park (county equivalent) (30-113) effective November 7, 1997; 1990 added population: 52.

### New Mexico

1. **1980s:**
  - ADDED:
    * Cibola County, New Mexico (35-006): Created from part of Valencia County (35-061) effective June 19, 1981; 1980 population: 30,347.
  - BOUNDARY CHANGES:
    * Valencia County, New Mexico (35-061): Part taken to create new Cibola County (35-006) effective June 19, 1981; 1980 detached population: 30,347.

2. **1990s:**
  - NAME CHANGE:
    * De Baca County, New Mexico (35-011): Name corrected from DeBaca County (erroneously changed in the 1980s).

3. **2000s:**
  - NAME CHANGE:
    * Doña Ana County, New Mexico (35-013): Name corrected from Dona Ana County (added tilde).

### North Carolina

1. **1990s:**
  - BOUNDARY CHANGES:
    * Carteret County, North Carolina (37-031): Boundary correction added from and detached unpopulated parts to Craven County (37-049); estimated area added: five square miles; estimated area detached: 16 square miles.
    * Craven County, North Carolina (37-049): Boundary correction added from and detached unpopulated parts to Carteret County (37-031); estimated area added: 16 square miles; estimated area detached: five square miles.

### North Dakota

1. **1980s:**
  - NAME CHANGE:
    * LaMoure County, North Dakota (38-045): Name corrected from La Moure County.

### Pennsylvania

1. **1990s:**
  - NAME CHANGE:
    * McKean County, Pennsylvania (42-083): Name corrected from Mc Kean County.

### South Dakota

1. **1970s:**
  - DELETED:
    * Washabaugh County, South Dakota (46-131): Combined into Jackson County (46-071) effective January 1, 1979.
  - BOUNDARY CHANGES:
    * Jackson County, South Dakota (46-071): Added all of the former Washabaugh County (46-131), effective January 1, 1979.

2. **2010s:**
  - NAME CHANGE:
    * Oglala Lakota County, South Dakota (46-102) Changed name and code from Shannon County (46-113) effective May 1, 2015.
    * Shannon County, South Dakota (46-113) Changed name and code to Oglala Lakota County (46-102) effective May 1, 2015.


### Tennessee

1. **1980s:**
  - NAME CHANGE:
    * DeKalb County, Tennessee (47-041): Name corrected from De Kalb County.

### Texas

1. **1980s:**
  - NAME CHANGE:
    * DeWitt County, Texas (48-123): Name corrected from De Witt County.


### Virginia
Virginia has both counties and "independent cities" with their own FIPS codes. The city of South Boston, VA (formerly 51780) was incorporated into Halifax County, VA (51083). The city of Clifton Forge (51560) was incorporated into Allegheny County (51005).

1. **1970s:**
  - ADDED:
    * Manassas (independent) city, Virginia (51-683): Changed from a town to a city and became independent of Prince William County (51-153) effective June 1, 1975; 1970 population: 9,164.
    * Manassas Park (independent) city, Virginia (51-685): Changed from a town to a city and became independent of Prince William County (51-153) effective May 1, 1975; 1970 population: 6,844.
    * Poquoson (independent) city, Virginia (51-735): Changed from a town to a city and became independent of York County (51-199) effective June 1, 1975; 1970 population: 5,441.
  - DELETED:
    * Nansemond County, Virginia (51-123): Combined into Suffolk (independent) city (51-800) effective July 1, 1972.
  - BOUNDARY CHANGES:
    * Bedford County, Virginia (51-019): Part annexed to Lynchburg (independent) city (51-520), effective December 31, 1975; estimated population: 1,500.
    * Campbell County, Virginia (51-031): Part annexed to Lynchburg (independent) city (51-520) effective December 31, 1975; estimated population: 9,000.
    * Dinwiddie County, Virginia (51-053): Part annexed to Petersburg (independent) city (51-730) effective December 31, 1971; estimated population: 3,400.
    * Frederick County, Virginia (51-069): Part annexed to Winchester (independent) city (51-840) effective December 31, 1970; estimated population: 4,800.
    * Montgomery County, Virginia (51-121): Part annexed to Radford (independent) city (51-750) effective December 31, 1976; estimated population: 400.
    * Prince George County, Virginia (51-149): Part annexed to Petersburg (independent) city (51-730) effective December 31, 1975; estimated population: 4,700. 
    * Prince William County, Virginia (51-153): Part taken when Manassas (51-683) and Manassas Park (51-685) became cities and separated from the county effective June 1, 1975, and May 1, 1975, respectively; 1970 population detached: 16,008.
    * Roanoke County, Virginia (51-161): Part annexed to Roanoke (independent) city (51-770) effective December 31, 1975; estimated population: 13,500.
    * Washington County, Virginia (51-191): Part annexed to Bristol (independent) city (51-520); estimated population: 4,800.
    * York County, Virginia (51-199): Part taken when Poquoson (51-735) became a city and separated from the county effective June 1, 1975; 1970 population detached: 5,441.
    * Bristol (independent) city, Virginia (51-520): Annexed part of Washington County (51-191); estimated population: 4,800.
    * Lynchburg (independent) city, Virginia (51-680): Annexed part of Bedford County (51-019) effective December 31, 1975; estimated population: 1,500. Annexed part of Campbell County (51-031) effective December 31, 1975; estimated population: 9,000.
    * Petersburg (independent) city, Virginia (51-730): Annexed part of Dinwiddie County (51-053) effective December 31, 1971; estimated population: 3,400. Annexed part of Prince George County (51-149) effective December 31, 1971; estimated population: 4,700.
    * Radford (independent) city, Virginia (51-750): Annexed part of Montgomery County (51-121) effective December 31, 1976; estimated population: 400.
    * Roanoke (independent) city, Virginia (51-770): Annexed part of Roanoke County (51-161) effective December 31, 1975; estimated population: 13,500.
    * Suffolk (independent) city, Virginia (51-800): Added all of former Nansemond County (51-123) effective July 1, 1972.
    * Winchester (independent) city, Virginia (51-840): Annexed part of Frederick County (51-069) effective December 31, 1970; estimated population: 4,800.

2. **1980s:**
  - BOUNDARY CHANGES:
    * Albemarle County, Virginia (51-003): Part annexed to Charlottesville (independent) city (51-540) effective February 9, 1988; no estimated population available.
    * Augusta County, Virginia (51-015): Part annexed to Staunton (independent) city (51-790) effective December 31, 1986; estimated population: 2,300. Part annexed to Waynesboro (independent) city (51-820) effective December 31, 1985; estimated population 3,000.
    * Fairfax County, Virginia (51-059): Part annexed to Fairfax (independent) city (51-600) effective December 31, 1980; estimated population: 1,100.
    * Greensville County, Virginia (51-081): Part annexed to Emporia (independent) city (51-595) effective January 1, 1988; estimated population: 400.
    * James City County, Virginia (51-095): Part annexed to Williamsburg (independent) city (51-830) effective January 1, 1983; estimated population: 400.
    * Pittsylvania County, Virginia (51-143): Part annexed to Danville (independent) city (51-590) effective December 31, 1987 and December 31, 1988; estimated population: 10,500.
    * Prince William County, Virginia (51-153): Part annexed to Manassas (independent) city (51-683) effective December 31, 1983; estimated population: 300.
    * Rockbridge County, Virginia (51-163): Part annexed to Buena Vista (independent) city (51-530) effective December 31, 1983; estimated population: 200.
    * Rockingham County, Virginia (51-165): Part annexed to Harrisonburg (independent) city (51-660) effective December 31, 1982; estimated population: 5,500.
    * Southampton County, Virginia (51-175): Part annexed to Franklin (independent) city (51-620) effective December 31, 1985; estimated population: 600.
    * Spotsylvania County, Virginia (51-177): Part annexed to Fredericksburg (independent) city (51-630) effective December 31, 1983; estimated population: 2,800.
    * Buena Vista (independent) city, Virginia (51-530): Annexed part of Rockbridge County (51-163) effective December 31, 1983; estimated population: 200.
    * Charlottesville (independent) city, Virginia (51-540): Annexed part of Albemarle County (51-003) effective February 9, 1988; no estimated population available.
    * Danville (independent) city, Virginia (51-590): Annexed part of Pittsylvania County (51-143) effective December 31, 1987 and December 31, 1988; estimated population: 10,500.
    * Emporia (independent) city, Virginia (51-595): Annexed part of Greensville County (51-081) effective January 1, 1988; estimated population: 400.
    * Fairfax (independent) city, Virginia (51-600): Annexed part of Fairfax County (51-059) effective December 31, 1980; estimated population: 1,100.
    * Franklin (independent) city, Virginia (51-620): Annexed part of Southampton County (51-175) effective December 31, 1985; estimated population: 600.
    * Fredericksburg (independent) city, Virginia (51-630): Annexed part of Spotsylvania County (51-177) effective December 31, 1983; estimated population: 2,800.
    * Harrisonburg (independent) city, Virginia (51-660): Annexed part of Rockingham County (51-165) effective December 31, 1982; estimated population: 5,500.
    * Manassas (independent) city, Virginia (51-683): Annexed part of Prince William County (51-153) effective December 31, 1983; estimated population: 300.
    * Staunton (independent) city, Virginia (51-790): Annexed part of Augusta County (51-015) effective December 31, 1986; estimated population: 2,300.
    * Waynesboro (independent) city, Virginia (51-820): Annexed part of Augusta County (51-015) effective December 31, 1985; estimated population: 3,000.
    * Williamsburg (independent) city, Virginia (51-830): Annexed part of James City County (51-095) effective December 31, 1983; estimated population: 400.

3. **1990s:**
  - DELETED:
    * South Boston (independent) city, Virginia (51-780): Changed to town status and added to Halifax County (51-083) effective June 30, 1995.
  - BOUNDARY CHANGES:
    * Augusta County, Virginia (51-015): Part annexed to Waynesboro (independent) city (51-820) effective July 1, 1994; no estimated population available.
    * Bedford County, Virginia (51-019): Part annexed to Bedford (independent) city (51-515) effective July 1, 1993; estimated population: 200.
    * Fairfax County, Virginia (51-059): Parts annexed to Fairfax (independent) city (51-600) effective December 31, 1991 and January 1, 1994; estimated population: 400.
    * Halifax County, Virginia (51-083): Added the former independent city of South Boston (51-780) effective June 30, 1995.
    * Prince William County, Virginia (51-153): Part annexed to Manassas Park (independent) city (51-685) effective December 31, 1990; no estimated population available.
    * Southampton County, Virginia (51-175): Part annexed to Franklin (independent) city (51-620) effective December 31, 1995; estimated population: 400.
    * Bedford (independent) city, Virginia (51-515): Annexed part of Bedford County (51-019) effective July 1, 1993; estimated population: 200.
    * Fairfax (independent) city, Virginia (51-600): Annexed parts of Fairfax County (51-059) effective December 31, 1991 and January 1, 1994; estimated population: 400.
    * Franklin (independent) city, Virginia (51-620): Annexed part of Southampton County (51-175) effective December 31, 1995; estimated population: 400.
    * Manassas Park (independent) city, Virginia (51-685): Annexed part of Prince William County (51-153) effective December 31, 1990; no estimated population available.
    * Waynesboro (independent) city, Virginia (51-820): Annexed part of Augusta County (51-015) effective July 1, 1994; no estimated population available.

4. **2000s:**
  - DELETED:
    * Clifton Forge (independent) city, Virginia (51-560): Changed to town status and added to Alleghany County (51-005) effective July 1, 2001.
  - BOUNDARY CHANGES:
    * Alleghany County, Virginia (51-005): Added the former independent city of Clifton Forge (51-560) effective July 1, 2001; estimated added population: 4,289.
    * York County, Virginia (51-199): Exchanged territory with Newport News (independent) city (51-700) effective July 1, 2007; estimated net detached population: 293.
    * Newport News (independent) city, Virginia (51-700): Exchanged territory with York County (51-199) effective July 1, 2007; estimated net added population: 293.

5. **2010s:**
  - DELETED:
    * Bedford (independent) city, Virginia (51-515): Changed to town status and added to Bedford County (51-019) effective July 1, 2013.
  - BOUNDARY CHANGES:
    * Bedford County, Virginia (51-019): Added the former independent city of Bedford (51-515) effective July 1, 2013; estimated net added population 6,222.

Various other issues recorded:

- 51540 was collapsed into 51003
- 51560 and 51580 were collapsed into 51005
- 51790 and 51820 were collapsed into 51015
- 51515 was collapsed into 51019
- 51640 was collapsed into 51035
- 51570 was collapsed into 51041
- 51013, 51510, 51600 and 51610 were collapsed into 51059
- 51840 was collapsed into 51069
- 51595 was collapsed into 51081
- 51780 was collapsed into 51083
- 51690 was collapsed into 51089
- 51830 was collapsed into 51095
- 51750 was collapsed into 51121
- 51590 was collapsed into 51143
- 51670 and 51730 were collapsed into 51149
- 51683 and 51685 were collapsed into 51153
- 51770 and 51775 were collapsed into 51161
- 51530 and 51678 were collapsed into 51163
- 51660 was collapsed into 51165
- 51620 was collapsed into 51175
- 51630 was collapsed into 51177
- 51520 was collapsed into 51191
- 51720 was collapsed into 51195

| Troubled FIPS | Assignment |
|:--------------|:-----------|
| 51013         | 51059      |
| 51510         | 51059      |
| 51515         | 51019      |
| 51520         | 51191      |
| 51530         | 51163      |
| 51540         | 51003      |
| 51560         | 51005      |
| 51570         | 51041      |
| 51580         | 51005      |
| 51590         | 51143      |
| 51595         | 51081      |
| 51600         | 51059      |
| 51610         | 51059      |
| 51620         | 51175      |
| 51630         | 51177      |
| 51640         | 51035      |
| 51660         | 51165      |
| 51670         | 51149      |
| 51678         | 51163      |
| 51683         | 51153      |
| 51685         | 51153      |
| 51690         | 51089      |
| 51720         | 51195      |
| 51730         | 51149      |
| 51750         | 51121      |
| 51770         | 51161      |
| 51775         | 51161      |
| 51780         | 51083      |
| 51790         | 51015      |
| 51820         | 51015      |
| 51840         | 51069      |

### Wyoming

According to [decinneal census counts](http://www.census.gov/population/cencounts/wy190090.txt), Wyoming had Yellowstone National Park (56047) up until 1960. After that, this county disappeared although it never had more than 519 residents. 
- parts of 56029 and 56039 were used to create 56047


# Sources:

- http://www.udel.edu/johnmack/frec682/fips_codes.html
- https://www.census.gov/geo/reference/county-changes.html
- http://www.ddorn.net/data/FIPS_County_Code_Changes.pdf
- http://www.nrcs.usda.gov/wps/portal/nrcs/detail/pa/home/?cid=nrcs143_013710