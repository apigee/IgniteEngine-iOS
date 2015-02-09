//
//  IXAlertAction.h
//  Ignite iOS Engine (IX)
//
//  Created by Robert Walsh on 10/9/13.
//  Copyright (c) 2013 Apigee, Inc. All rights reserved.
//

/* Displays a native alert. Can be informational with a single button or actionable with two buttons.
*/


@interface Alert

/***************************************************************/

/** Alert has the following attributes:
 
 @param button.titles Button titles<br><pre>comma</pre>
 @param message Message of alert<br><pre>string</pre>
 @param title Title of alert<br><pre>string</pre>
 
*/

-(void)Attributes
{
}
/***************************************************************/
/***************************************************************/

/** Alert fires the following events:
 
 @param button.%lu.pressed Fires when %lu button pressed
 @param button.pressed Fires when button pressed
 @param didPresent Fires when alert did present
 @param willPresent Fires when alert will present
 
*/

-(void)Events
{
}
/***************************************************************/
/***************************************************************/

/** Alert has no functions.
 
 */

-(void)Functions
{
}
/***************************************************************/
/***************************************************************/

/** Alert returns no values.
 
 */

-(void)Returns
{
}
/***************************************************************/


@end