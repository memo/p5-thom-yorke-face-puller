/***********************************************************************
 * -----------------------------------
 * 
 * Copyright (c) 2008, Memo Akten, www.memo.tv
 * 
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 * 
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 * 	
 ***********************************************************************/

/***********************************************************************
 * 
 * This sample uses the pre-processed binary data found here:
 * http://www.memo.tv/radiohead_house_of_cards_binary_pre_processed_data
 * 
 ***********************************************************************/
 
 See http://vimeo.com/1371683 for demo
 
 Keys:
 void keyPressed() {
    switch(key) {
    case '0':
    case '1':
    case '2':
    case '3':
    case '4':
    case '5':
        renderMode = key-'0'; 
        break;
        //    case 'r': renderMode = (renderMode + 1) % RENDER_MODE_COUNT; break;
    case 's': 
        springOn = !springOn;
    case '+': 
        particleSize *= 1.1; 
        break;
    case '-': 
        particleSize /= 1.1; 
        break;
    case 'u':
        updateFrames = !updateFrames;
        break;
    }
}
