There are currently 3 types of datasets recognized:
1. `Normal`
1. `GridSearch`
1. `Shutterless`

Also, there are 4 types of shots recognized:
1. `normal`
1. `snap`
1. `segment`
1. `shutterless`

`px.nextshot2` processes datasets by (in addition to other things) takeing the centering stage and alignment stations positions
from the dataset.  No further modifcations are made for any `GridSearch` datasets but for the other datasets it looks at the shot type and selects either interpoates along the path defined by the centering points or just the first centering point.

|                 | Normal      | GridSearch  | Shutterless |
|-----------------|------------:|:-----------:|:-----------:|
| **normal**      | interpolate | from DS     | interpolate |
| **snap**        | 1st point   | from DS     | 1st point   |
| **segment**     | 1st point   | from DS     | 1st point   |
| **shutterless** | 1st point   | from DS     | 1st point   |

So basically `GridSearch` means the centering and alignment stage positions have to be in the datasets while for everything else the positions have to be stored in the centering array.

Shutterless data collection as implemented by `pgpmac` ignores the above table and only uses the centering array.  This means that "replayed" datasets will use what ever new centering points are in the array and ignore whatever might have been stored in the databaseL: Enabling retaking of shutterless frames will be confusing.

For the Eiger detector:
*  Dataset type is `Shutterless`
*  Snaps and Orthosnaps shot type is `snap`
*  Dataset shot type is `shutterless`
*  In explore mode "datasets" are `GridSearch` and shots are `normal`

For the Rayonix detectors
*  Dataset type is `Normal`
*  Snaps and Orthosnaps shottype is `snap`
*  As in the Eiger, explore mode datasets and shots are `GridSearch` and `normal`, respectively


The `segment` shot type does not appear to be used anywhere in the code.
