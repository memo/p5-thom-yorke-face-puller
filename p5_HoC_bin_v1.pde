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

import processing.opengl.*; 

final static int GRIDX             = 100;
final static int GRIDY             = 100;
final static int MAX_PARTICLES     = GRIDX * GRIDY;

ParticleManager pm;

float rotY = 0;
float rotX = 0;

int mouseVelX;
int mouseVelY;


final static int RENDER_BOX         = 0;
final static int RENDER_SPHERE      = 1;
final static int RENDER_STRIP       = 2;
final static int RENDER_POINT       = 3;
final static int RENDER_MODE_COUNT  = 4;


int renderMode = RENDER_STRIP;
float particleSize = 6.0;

boolean mousePressedLastFrame = false;
boolean springOn = true;
boolean updateFrames = true;

void setup(){
    size(640, 480, P3D);
    pm = new ParticleManager();
    pm.init(0, MAX_PARTICLES);	// (maxSpeed, maxCount);
    frameRate(30);
    noStroke();    
    sphereDetail(3);
}


void draw(){
    mouseVelX = mouseX - pmouseX;
    mouseVelY = mouseY - pmouseY;

    background(0);

    if(updateFrames) {
        byte buffer[] = loadBytes(frameCount+".bin");        // load all bytes from binary file into buffer
        int fileSize = buffer.length;		           // file size in bytes
        int numDots = fileSize/2;				   // number of dots in the file (2 bits of info per dot)
        int index;
        for(int c=0; c<numDots; c++) {
            index = c<<1;
            int xx = c % GRIDX;
            int yy = floor(c / GRIDX);
            int zz = buffer[index];    
            if(zz < 0) zz += 255;     // because byte is signed!!!
            int cc = buffer[index+1];  
            if(cc < 0) cc += 255;     // because byte is signed!!!
            pm.particles[c].init((xx-50) * 4.5f, (yy-50) * 6.0f, zz * 1.5f, cc);		// load and scale data
        }
    }
    translate(width * 0.5f, height * 0.5f, -600);		// center stage
    //    rotY += 0.01;
    if(mousePressed && mouseButton == RIGHT) {
        rotY += mouseVelX * 0.01;
        rotX += mouseVelY *-0.01;
    }
    rotateY(rotY);
    rotateX(rotX);

    pm.updateAndRender();

    mousePressedLastFrame = mousePressed;

    //    println(frameRate);
    //    saveFrame("output/HoC_bin1-####.tif");

    if(frameCount>2101){
        exit();
        println("done");  
    }
}

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

