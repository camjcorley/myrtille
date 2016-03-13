/*
   FreeRDP: A Remote Desktop Protocol client.
   GDI Drawing Functions

   Copyright 2010-2011 Marc-Andre Moreau <marcandre.moreau@gmail.com>

   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.
*/

/* GDI Drawing Functions: http://msdn.microsoft.com/en-us/library/dd162760/ */

#include <stdio.h>
#include <string.h>
#include <stdlib.h>

#include <freerdp/freerdp.h>
#include "gdi.h"

#include "gdi_dc.h"

/**
 * Set current foreground draw mode.\n
 * @msdn{dd144922}
 * @param hdc device context
 * @return draw mode
 */

int GetROP2(HDC hdc)
{
	return hdc->drawMode;
}

/**
 * Set current foreground draw mode.\n
 * @msdn{dd145088}
 * @param hdc device context
 * @param fnDrawMode draw mode
 * @return previous draw mode
 */

int SetROP2(HDC hdc, int fnDrawMode)
{
	int prevDrawMode = hdc->drawMode;

	if (fnDrawMode > 0 && fnDrawMode <= 16)
		hdc->drawMode = fnDrawMode;

	return prevDrawMode;
}

/**
 * Get the current background color.\n
 * @msdn{dd144852}
 * @param hdc device context
 * @return background color
 */

COLORREF GetBkColor(HDC hdc)
{
	return hdc->bkColor;
}

/**
 * Set the current background color.\n
 * @msdn{dd162964}
 * @param hdc device color
 * @param crColor new background color
 * @return previous background color
 */

COLORREF SetBkColor(HDC hdc, COLORREF crColor)
{
	COLORREF previousBkColor = hdc->bkColor;
	hdc->bkColor = crColor;
	return previousBkColor;
}

/**
 * Get the current background mode.\n
 * @msdn{dd144853}
 * @param hdc device context
 * @return background mode
 */

int GetBkMode(HDC hdc)
{
	return hdc->bkMode;
}

/**
 * Set the current background mode.\n
 * @msdn{dd162965}
 * @param hdc device context
 * @param iBkMode background mode
 * @return
 */

int SetBkMode(HDC hdc, int iBkMode)
{
	if (iBkMode == OPAQUE || iBkMode == TRANSPARENT)
		hdc->bkMode = iBkMode;
	else
		hdc->bkMode = OPAQUE;

	return 0;
}

/**
 * Set the current text color.\n
 * @msdn{dd145093}
 * @param hdc device context
 * @param crColor new text color
 * @return previous text color
 */

COLORREF SetTextColor(HDC hdc, COLORREF crColor)
{
	COLORREF previousTextColor = hdc->textColor;
	hdc->textColor = crColor;
	return previousTextColor;
}